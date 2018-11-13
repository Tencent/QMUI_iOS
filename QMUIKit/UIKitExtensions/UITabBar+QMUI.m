//
//  UITabBar+QMUI.m
//  qmui
//
//  Created by MoLice on 2017/2/14.
//  Copyright © 2017年 QMUI Team. All rights reserved.
//

#import "UITabBar+QMUI.h"
#import "QMUICore.h"
#import "UITabBarItem+QMUI.h"
#import "UIBarItem+QMUI.h"

NSInteger const kLastTouchedTabBarItemIndexNone = -1;

@interface UITabBar ()

@property(nonatomic, assign) BOOL canItemRespondDoubleTouch;
@property(nonatomic, assign) NSInteger lastTouchedTabBarItemViewIndex;
@property(nonatomic, assign) NSInteger tabBarItemViewTouchCount;
@end

@implementation UITabBar (QMUI)

- (UIView *)qmui_backgroundView {
    return [self valueForKey:@"_backgroundView"];
}

- (UIImageView *)qmui_shadowImageView {
    if (@available(iOS 10, *)) {
        // iOS 10 及以后，在 UITabBar 初始化之后就能获取到 backgroundView 和 shadowView 了
        return [self.qmui_backgroundView valueForKey:@"_shadowView"];
    }
    // iOS 9 及以前，shadowView 要在 UITabBar 第一次 layoutSubviews 之后才会被创建，直至 UITabBarController viewWillAppear: 时仍未能获取到 shadowView，所以为了省去调用时机的考虑，这里获取不到的时候会主动触发一次 tabBar 的布局
    UIImageView *shadowView = [self valueForKey:@"_shadowView"];
    if (!shadowView) {
        [self setNeedsLayout];
        [self layoutIfNeeded];
        shadowView = [self valueForKey:@"_shadowView"];
    }
    return shadowView;
}

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        ExchangeImplementations([self class], @selector(setItems:animated:), @selector(qmui_setItems:animated:));
        ExchangeImplementations([self class], @selector(setSelectedItem:), @selector(qmui_setSelectedItem:));
        ExchangeImplementations([self class], @selector(setFrame:), @selector(qmuiTabBar_setFrame:));
        
        if (@available(iOS 12.1, *)) {
            OverrideImplementation(NSClassFromString(@"UITabBarButton"), @selector(setFrame:), ^id(__unsafe_unretained Class originClass, SEL originCMD, IMP originIMP) {
                return ^(UIView *selfObject, CGRect firstArgv) {
                    
                    if ([selfObject isKindOfClass:originClass]) {
                        
                        // https://github.com/QMUI/QMUI_iOS/issues/410
                        if (!CGRectIsEmpty(selfObject.frame) && CGRectIsEmpty(firstArgv)) {
                            return;
                        }
                        
                        // https://github.com/QMUI/QMUI_iOS/issues/422
                        if (IS_NOTCHED_SCREEN) {
                            if ((CGRectGetHeight(selfObject.frame) == 48 && CGRectGetHeight(firstArgv) == 33) || (CGRectGetHeight(selfObject.frame) == 31 && CGRectGetHeight(firstArgv) == 20)) {
                                return;
                            }
                        }
                    }
                    
                    // call super
                    void (*originSelectorIMP)(id, SEL, CGRect);
                    originSelectorIMP = (void (*)(id, SEL, CGRect))originIMP;
                    originSelectorIMP(selfObject, originCMD, firstArgv);
                };
            });
        }
    });
}

- (void)qmui_setItems:(NSArray<UITabBarItem *> *)items animated:(BOOL)animated {
    [self qmui_setItems:items animated:animated];
    
    for (UITabBarItem *item in items) {
        UIControl *itemView = (UIControl *)item.qmui_view;
        [itemView addTarget:self action:@selector(handleTabBarItemViewEvent:) forControlEvents:UIControlEventTouchUpInside];
    }
}

- (void)qmui_setSelectedItem:(UITabBarItem *)selectedItem {
    NSInteger olderSelectedIndex = self.selectedItem ? [self.items indexOfObject:self.selectedItem] : -1;
    [self qmui_setSelectedItem:selectedItem];
    NSInteger newerSelectedIndex = [self.items indexOfObject:selectedItem];
    // 只有双击当前正在显示的界面的 tabBarItem，才能正常触发双击事件
    self.canItemRespondDoubleTouch = olderSelectedIndex == newerSelectedIndex;
}

- (void)handleTabBarItemViewEvent:(UIControl *)itemView {
    
    if (!self.canItemRespondDoubleTouch) {
        return;
    }
    
    if (!self.selectedItem.qmui_doubleTapBlock) {
        return;
    }
    
    // 如果一定时间后仍未触发双击，则废弃当前的点击状态
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(.25 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self revertTabBarItemTouch];
    });
    
    NSInteger selectedIndex = [self.items indexOfObject:self.selectedItem];
    
    if (self.lastTouchedTabBarItemViewIndex == kLastTouchedTabBarItemIndexNone) {
        // 记录第一次点击的 index
        self.lastTouchedTabBarItemViewIndex = selectedIndex;
    } else if (self.lastTouchedTabBarItemViewIndex != selectedIndex) {
        // 后续的点击如果与第一次点击的 index 不一致，则认为是重新开始一次新的点击
        [self revertTabBarItemTouch];
        self.lastTouchedTabBarItemViewIndex = selectedIndex;
        return;
    }
    
    self.tabBarItemViewTouchCount ++;
    if (self.tabBarItemViewTouchCount == 2) {
        // 第二次点击了相同的 tabBarItem，触发双击事件
        UITabBarItem *item = self.items[selectedIndex];
        if (item.qmui_doubleTapBlock) {
            item.qmui_doubleTapBlock(item, selectedIndex);
        }
        [self revertTabBarItemTouch];
    }
}

- (void)revertTabBarItemTouch {
    self.lastTouchedTabBarItemViewIndex = kLastTouchedTabBarItemIndexNone;
    self.tabBarItemViewTouchCount = 0;
}

- (void)qmuiTabBar_setFrame:(CGRect)frame {
    if (IOS_VERSION < 11.2 && IS_58INCH_SCREEN && ShouldFixTabBarTransitionBugInIPhoneX) {
        if (CGRectGetHeight(frame) == TabBarHeight && CGRectGetMaxY(frame) < CGRectGetHeight(self.superview.bounds)) {
            // iOS 11 在界面 push 的过程中 tabBar 会瞬间往上跳，所以做这个修复。这个 bug 在 iOS 11.2 里已被系统修复。
            // https://github.com/QMUI/QMUI_iOS/issues/217
            frame = CGRectSetY(frame, CGRectGetHeight(self.superview.bounds) - CGRectGetHeight(frame));
        }
    }
    
    // 修复这个 bug：https://github.com/QMUI/QMUI_iOS/issues/309
    if (@available(iOS 11, *)) {
        if (IS_NOTCHED_SCREEN && ((CGRectGetHeight(frame) == 49 || CGRectGetHeight(frame) == 32))) {// 只关注全面屏设备下的这两种非正常的 tabBar 高度即可
            CGFloat bottomSafeAreaInsets = self.safeAreaInsets.bottom > 0 ? self.safeAreaInsets.bottom : self.superview.safeAreaInsets.bottom;// 注意，如果只是拿 self.safeAreaInsets 判断，会肉眼看到高度的跳变，因此引入 superview 的值（虽然理论上 tabBar 不一定都会布局到 UITabBarController.view 的底部）
            frame.size.height += bottomSafeAreaInsets;
            frame.origin.y -= bottomSafeAreaInsets;
        }
    }
    
    [self qmuiTabBar_setFrame:frame];
}

#pragma mark - Swizzle Property Getter/Setter

static char kAssociatedObjectKey_canItemRespondDoubleTouch;
- (void)setCanItemRespondDoubleTouch:(BOOL)canItemRespondDoubleTouch {
    objc_setAssociatedObject(self, &kAssociatedObjectKey_canItemRespondDoubleTouch, @(canItemRespondDoubleTouch), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (BOOL)canItemRespondDoubleTouch {
    return [((NSNumber *)objc_getAssociatedObject(self, &kAssociatedObjectKey_canItemRespondDoubleTouch)) boolValue];
}

static char kAssociatedObjectKey_lastTouchedTabBarItemViewIndex;
- (void)setLastTouchedTabBarItemViewIndex:(NSInteger)lastTouchedTabBarItemViewIndex {
    objc_setAssociatedObject(self, &kAssociatedObjectKey_lastTouchedTabBarItemViewIndex, @(lastTouchedTabBarItemViewIndex), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSInteger)lastTouchedTabBarItemViewIndex {
    return [((NSNumber *)objc_getAssociatedObject(self, &kAssociatedObjectKey_lastTouchedTabBarItemViewIndex)) integerValue];
}

static char kAssociatedObjectKey_tabBarItemViewTouchCount;
- (void)setTabBarItemViewTouchCount:(NSInteger)tabBarItemViewTouchCount {
    objc_setAssociatedObject(self, &kAssociatedObjectKey_tabBarItemViewTouchCount, @(tabBarItemViewTouchCount), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSInteger)tabBarItemViewTouchCount {
    return [((NSNumber *)objc_getAssociatedObject(self, &kAssociatedObjectKey_tabBarItemViewTouchCount)) integerValue];
}

@end
