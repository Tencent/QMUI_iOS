/*****
 * Tencent is pleased to support the open source community by making QMUI_iOS available.
 * Copyright (C) 2016-2019 THL A29 Limited, a Tencent company. All rights reserved.
 * Licensed under the MIT License (the "License"); you may not use this file except in compliance with the License. You may obtain a copy of the License at
 * http://opensource.org/licenses/MIT
 * Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.
 *****/

//
//  UITabBar+QMUI.m
//  qmui
//
//  Created by QMUI Team on 2017/2/14.
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

QMUISynthesizeBOOLProperty(canItemRespondDoubleTouch, setCanItemRespondDoubleTouch)
QMUISynthesizeNSIntegerProperty(lastTouchedTabBarItemViewIndex, setLastTouchedTabBarItemViewIndex)
QMUISynthesizeNSIntegerProperty(tabBarItemViewTouchCount, setTabBarItemViewTouchCount)

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
        
        ExtendImplementationOfVoidMethodWithTwoArguments([UITabBar class], @selector(setItems:animated:), NSArray<UITabBarItem *> *, BOOL, ^(UITabBar *selfObject, NSArray<UITabBarItem *> *items, BOOL animated) {
            for (UITabBarItem *item in items) {
                UIControl *itemView = (UIControl *)item.qmui_view;
                [itemView addTarget:selfObject action:@selector(handleTabBarItemViewEvent:) forControlEvents:UIControlEventTouchUpInside];
            }
        });
        
        OverrideImplementation([UITabBar class], @selector(setSelectedItem:), ^id(__unsafe_unretained Class originClass, SEL originCMD, IMP (^originalIMPProvider)(void)) {
            return ^(UITabBar *selfObject, UITabBarItem *selectedItem) {
                
                // call super
                void (^callSuperBlock)(UITabBarItem *) = ^void(UITabBarItem *aSelectedItem) {
                    void (*originSelectorIMP)(id, SEL, UITabBarItem *);
                    originSelectorIMP = (void (*)(id, SEL, UITabBarItem *))originalIMPProvider();
                    originSelectorIMP(selfObject, originCMD, aSelectedItem);
                };
                
                // avoid superclass
                if ([selfObject isKindOfClass:originClass]) {
                    NSInteger olderSelectedIndex = selfObject.selectedItem ? [selfObject.items indexOfObject:selfObject.selectedItem] : -1;
                    callSuperBlock(selectedItem);
                    NSInteger newerSelectedIndex = [selfObject.items indexOfObject:selectedItem];
                    // 只有双击当前正在显示的界面的 tabBarItem，才能正常触发双击事件
                    selfObject.canItemRespondDoubleTouch = olderSelectedIndex == newerSelectedIndex;
                } else {
                    callSuperBlock(selectedItem);
                }
            };
        });
        
        OverrideImplementation([UITabBar class], @selector(setFrame:), ^id(__unsafe_unretained Class originClass, SEL originCMD, IMP (^originalIMPProvider)(void)) {
            return ^(UITabBar *selfObject, CGRect frame) {
                // avoid superclass
                if ([selfObject isKindOfClass:originClass]) {
                    if (IOS_VERSION < 11.2 && IS_58INCH_SCREEN && ShouldFixTabBarTransitionBugInIPhoneX) {
                        if (CGRectGetHeight(frame) == TabBarHeight && CGRectGetMaxY(frame) < CGRectGetHeight(selfObject.superview.bounds)) {
                            // iOS 11 在界面 push 的过程中 tabBar 会瞬间往上跳，所以做这个修复。这个 bug 在 iOS 11.2 里已被系统修复。
                            // https://github.com/Tencent/QMUI_iOS/issues/217
                            frame = CGRectSetY(frame, CGRectGetHeight(selfObject.superview.bounds) - CGRectGetHeight(frame));
                        }
                    }
                    
                    // 修复这个 bug：https://github.com/Tencent/QMUI_iOS/issues/309
                    if (@available(iOS 11, *)) {
                        if (IS_NOTCHED_SCREEN && ((CGRectGetHeight(frame) == 49 || CGRectGetHeight(frame) == 32))) {// 只关注全面屏设备下的这两种非正常的 tabBar 高度即可
                            CGFloat bottomSafeAreaInsets = selfObject.safeAreaInsets.bottom > 0 ? selfObject.safeAreaInsets.bottom : selfObject.superview.safeAreaInsets.bottom;// 注意，如果只是拿 selfObject.safeAreaInsets 判断，会肉眼看到高度的跳变，因此引入 superview 的值（虽然理论上 tabBar 不一定都会布局到 UITabBarController.view 的底部）
                            if (bottomSafeAreaInsets == CGRectGetHeight(selfObject.frame)) {
                                return;// 由于这个系统 bug https://github.com/Tencent/QMUI_iOS/issues/446，这里先暂时屏蔽本次 frame 变化
                            }
                            frame.size.height += bottomSafeAreaInsets;
                            frame.origin.y -= bottomSafeAreaInsets;
                        }
                    }
                }
                
                // call super
                void (*originSelectorIMP)(id, SEL, CGRect);
                originSelectorIMP = (void (*)(id, SEL, CGRect))originalIMPProvider();
                originSelectorIMP(selfObject, originCMD, frame);
            };
        });
        
        // 以下代码修复两个仅存在于 12.1.0 版本的系统 bug，实测 12.1.1 苹果已经修复
        if (@available(iOS 12.1, *)) {
            
            OverrideImplementation(NSClassFromString(@"UITabBarButton"), @selector(setFrame:), ^id(__unsafe_unretained Class originClass, SEL originCMD, IMP (^originalIMPProvider)(void)) {
                return ^(UIView *selfObject, CGRect firstArgv) {
                    
                    if ([selfObject isKindOfClass:originClass]) {
                        // Fixed: UITabBar layout is broken on iOS 12.1
                        // https://github.com/Tencent/QMUI_iOS/issues/410
                        
                        if (IOS_VERSION_NUMBER < 120101 || (QMUICMIActivated && ShouldFixTabBarButtonBugForAll)) {
                            if (!CGRectIsEmpty(selfObject.frame) && CGRectIsEmpty(firstArgv)) {
                                return;
                            }
                        }
                        
                        if (IOS_VERSION_NUMBER < 120101) {
                            // Fixed: iOS 12.1 UITabBarItem positioning issue during swipe back gesture (when UINavigationBar is hidden)
                            // https://github.com/Tencent/QMUI_iOS/issues/422
                            if (IS_NOTCHED_SCREEN) {
                                if ((CGRectGetHeight(selfObject.frame) == 48 && CGRectGetHeight(firstArgv) == 33) || (CGRectGetHeight(selfObject.frame) == 31 && CGRectGetHeight(firstArgv) == 20)) {
                                    return;
                                }
                            }
                        }
                    }
                    
                    // call super
                    void (*originSelectorIMP)(id, SEL, CGRect);
                    originSelectorIMP = (void (*)(id, SEL, CGRect))originalIMPProvider();
                    originSelectorIMP(selfObject, originCMD, firstArgv);
                };
            });
        }
    });
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

@end
