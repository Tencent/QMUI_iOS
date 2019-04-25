/*****
 * Tencent is pleased to support the open source community by making QMUI_iOS available.
 * Copyright (C) 2016-2019 THL A29 Limited, a Tencent company. All rights reserved.
 * Licensed under the MIT License (the "License"); you may not use this file except in compliance with the License. You may obtain a copy of the License at
 * http://opensource.org/licenses/MIT
 * Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.
 *****/

//
//  UIBarItem+QMUIBadge.m
//  QMUIKit
//
//  Created by QMUI Team on 2018/6/2.
//

#import "UIBarItem+QMUIBadge.h"
#import "QMUICore.h"
#import "QMUILog.h"
#import "QMUILabel.h"
#import "UIView+QMUI.h"
#import "UIBarItem+QMUI.h"
#import "UITabBarItem+QMUI.h"
#import "UIViewController+QMUI.h"

@interface _QMUIBadgeLabel : QMUILabel

@property(nonatomic, assign) CGPoint centerOffset;
@property(nonatomic, assign) CGPoint centerOffsetLandscape;
@end

@interface _QMUIUpdatesIndicatorView : UIView

@property(nonatomic, assign) CGPoint centerOffset;
@property(nonatomic, assign) CGPoint centerOffsetLandscape;
@end

@interface UIBarItem ()

@property(nonatomic, strong, readwrite) _QMUIBadgeLabel *qmui_badgeLabel;
@property(nonatomic, strong, readwrite) _QMUIUpdatesIndicatorView *qmui_updatesIndicatorView;
@end

@implementation UIBarItem (QMUIBadge)

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        // 保证配置表里的默认值正确被设置
        ExtendImplementationOfNonVoidMethodWithoutArguments([UIBarItem class], @selector(init), __kindof UIBarItem *, ^__kindof UIBarItem *(UIBarItem *selfObject, __kindof UIBarItem *originReturnValue) {
            [selfObject qmuibaritem_didInitialize];
            return originReturnValue;
        });
        
        ExtendImplementationOfNonVoidMethodWithSingleArgument([UIBarItem class], @selector(initWithCoder:), NSCoder *, __kindof UIBarItem *, ^__kindof UIBarItem *(UIBarItem *selfObject, NSCoder *firstArgv, __kindof UIBarItem *originReturnValue) {
            [selfObject qmuibaritem_didInitialize];
            return originReturnValue;
        });
        
        // UITabBarButton 在 layoutSubviews 时每次都重新让 imageView 和 label addSubview:，这会导致我们用 qmui_layoutSubviewsBlock 时产生持续的重复调用（但又不死循环，因为每次都在下一次 runloop 执行，而且奇怪的是如果不放到下一次 runloop，反而不会重复调用），所以这里 hack 地屏蔽 addSubview: 操作
        OverrideImplementation(NSClassFromString([NSString stringWithFormat:@"%@%@", @"UITab", @"BarButton"]), @selector(addSubview:), ^id(__unsafe_unretained Class originClass, SEL originCMD, IMP (^originalIMPProvider)(void)) {
            return ^(UIView *selfObject, UIView *firstArgv) {
                
                if ([selfObject isKindOfClass:originClass] && firstArgv.superview == selfObject) {
                    return;
                }
                
                if (selfObject == firstArgv) {
                    UIViewController *visibleViewController = [QMUIHelper visibleViewController];
                    NSString *log = [NSString stringWithFormat:@"UIBarItem (QMUIBadge) addSubview:, 把自己作为 subview 添加到自己身上，self = %@, visibleViewController = %@, visibleState = %@, viewControllers = %@\n%@", selfObject, visibleViewController, @(visibleViewController.qmui_visibleState), visibleViewController.navigationController.viewControllers, [NSThread callStackSymbols]];
                    NSAssert(NO, log);
                    QMUILogWarn(@"UIBarItem (QMUIBadge)", @"%@", log);
                }
                
                // call super
                IMP originalIMP = originalIMPProvider();
                void (*originSelectorIMP)(id, SEL, UIView *);
                originSelectorIMP = (void (*)(id, SEL, UIView *))originalIMP;
                originSelectorIMP(selfObject, originCMD, firstArgv);
            };
        });
    });
}

- (void)qmuibaritem_didInitialize {
    self.qmui_badgeBackgroundColor = BadgeBackgroundColor;
    self.qmui_badgeTextColor = BadgeTextColor;
    self.qmui_badgeFont = BadgeFont;
    self.qmui_badgeContentEdgeInsets = BadgeContentEdgeInsets;
    self.qmui_badgeCenterOffset = BadgeCenterOffset;
    self.qmui_badgeCenterOffsetLandscape = BadgeCenterOffsetLandscape;
    
    self.qmui_updatesIndicatorColor = UpdatesIndicatorColor;
    self.qmui_updatesIndicatorSize = UpdatesIndicatorSize;
    self.qmui_updatesIndicatorCenterOffset = UpdatesIndicatorCenterOffset;
    self.qmui_updatesIndicatorCenterOffsetLandscape = UpdatesIndicatorCenterOffsetLandscape;
}

#pragma mark - Badge

static char kAssociatedObjectKey_badgeInteger;
- (void)setQmui_badgeInteger:(NSUInteger)qmui_badgeInteger {
    objc_setAssociatedObject(self, &kAssociatedObjectKey_badgeInteger, @(qmui_badgeInteger), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    self.qmui_badgeString = qmui_badgeInteger > 0 ? [NSString stringWithFormat:@"%@", @(qmui_badgeInteger)] : nil;
}

- (NSUInteger)qmui_badgeInteger {
    return [((NSNumber *)objc_getAssociatedObject(self, &kAssociatedObjectKey_badgeInteger)) unsignedIntegerValue];
}

static char kAssociatedObjectKey_badgeString;
- (void)setQmui_badgeString:(NSString *)qmui_badgeString {
    objc_setAssociatedObject(self, &kAssociatedObjectKey_badgeString, qmui_badgeString, OBJC_ASSOCIATION_COPY_NONATOMIC);
    if (qmui_badgeString.length) {
        if (!self.qmui_badgeLabel) {
            self.qmui_badgeLabel = [[_QMUIBadgeLabel alloc] init];
            self.qmui_badgeLabel.clipsToBounds = YES;
            self.qmui_badgeLabel.textAlignment = NSTextAlignmentCenter;
            self.qmui_badgeLabel.backgroundColor = self.qmui_badgeBackgroundColor;
            self.qmui_badgeLabel.textColor = self.qmui_badgeTextColor;
            self.qmui_badgeLabel.font = self.qmui_badgeFont;
            self.qmui_badgeLabel.contentEdgeInsets = self.qmui_badgeContentEdgeInsets;
            self.qmui_badgeLabel.centerOffset = self.qmui_badgeCenterOffset;
            self.qmui_badgeLabel.centerOffsetLandscape = self.qmui_badgeCenterOffsetLandscape;
            if (!self.qmui_viewDidSetBlock) {
                self.qmui_viewDidSetBlock = ^(__kindof UIBarItem * _Nonnull item, UIView * _Nullable view) {
                    [view addSubview:item.qmui_updatesIndicatorView];
                    [view addSubview:item.qmui_badgeLabel];
                    [view setNeedsLayout];
                    [view layoutIfNeeded];
                };
            }
            // 之前 item 已经 set 完 view，则手动触发一次
            if (self.qmui_view) {
                self.qmui_viewDidSetBlock(self, self.qmui_view);
            }
            if (!self.qmui_viewDidLayoutSubviewsBlock) {
                self.qmui_viewDidLayoutSubviewsBlock = ^(__kindof UIBarItem * _Nonnull item, UIView * _Nullable view) {
                    [item layoutSubviews];
                };
            }
        }
        self.qmui_badgeLabel.text = qmui_badgeString;
        self.qmui_badgeLabel.hidden = NO;
        [self setNeedsUpdateBadgeLabelLayout];
    } else {
        self.qmui_badgeLabel.hidden = YES;
    }
}

- (NSString *)qmui_badgeString {
    return (NSString *)objc_getAssociatedObject(self, &kAssociatedObjectKey_badgeString);
}

static char kAssociatedObjectKey_badgeBackgroundColor;
- (void)setQmui_badgeBackgroundColor:(UIColor *)qmui_badgeBackgroundColor {
    objc_setAssociatedObject(self, &kAssociatedObjectKey_badgeBackgroundColor, qmui_badgeBackgroundColor, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    if (self.qmui_badgeLabel) {
        self.qmui_badgeLabel.backgroundColor = qmui_badgeBackgroundColor;
    }
}

- (UIColor *)qmui_badgeBackgroundColor {
    return (UIColor *)objc_getAssociatedObject(self, &kAssociatedObjectKey_badgeBackgroundColor);
}

static char kAssociatedObjectKey_badgeTextColor;
- (void)setQmui_badgeTextColor:(UIColor *)qmui_badgeTextColor {
    objc_setAssociatedObject(self, &kAssociatedObjectKey_badgeTextColor, qmui_badgeTextColor, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    if (self.qmui_badgeLabel) {
        self.qmui_badgeLabel.textColor = qmui_badgeTextColor;
    }
}

- (UIColor *)qmui_badgeTextColor {
    return (UIColor *)objc_getAssociatedObject(self, &kAssociatedObjectKey_badgeTextColor);
}

static char kAssociatedObjectKey_badgeFont;
- (void)setQmui_badgeFont:(UIFont *)qmui_badgeFont {
    objc_setAssociatedObject(self, &kAssociatedObjectKey_badgeFont, qmui_badgeFont, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    if (self.qmui_badgeLabel) {
        self.qmui_badgeLabel.font = qmui_badgeFont;
        [self setNeedsUpdateBadgeLabelLayout];
    }
}

- (UIFont *)qmui_badgeFont {
    return (UIFont *)objc_getAssociatedObject(self, &kAssociatedObjectKey_badgeFont);
}

static char kAssociatedObjectKey_badgeContentEdgeInsets;
- (void)setQmui_badgeContentEdgeInsets:(UIEdgeInsets)qmui_badgeContentEdgeInsets {
    objc_setAssociatedObject(self, &kAssociatedObjectKey_badgeContentEdgeInsets, [NSValue valueWithUIEdgeInsets:qmui_badgeContentEdgeInsets], OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    if (self.qmui_badgeLabel) {
        self.qmui_badgeLabel.contentEdgeInsets = qmui_badgeContentEdgeInsets;
        [self setNeedsUpdateBadgeLabelLayout];
    }
}

- (UIEdgeInsets)qmui_badgeContentEdgeInsets {
    return [((NSValue *)objc_getAssociatedObject(self, &kAssociatedObjectKey_badgeContentEdgeInsets)) UIEdgeInsetsValue];
}

static char kAssociatedObjectKey_badgeCenterOffset;
- (void)setQmui_badgeCenterOffset:(CGPoint)qmui_badgeCenterOffset {
    objc_setAssociatedObject(self, &kAssociatedObjectKey_badgeCenterOffset, [NSValue valueWithCGPoint:qmui_badgeCenterOffset], OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    if (self.qmui_badgeLabel) {
        self.qmui_badgeLabel.centerOffset = qmui_badgeCenterOffset;
    }
}

- (CGPoint)qmui_badgeCenterOffset {
    return [((NSValue *)objc_getAssociatedObject(self, &kAssociatedObjectKey_badgeCenterOffset)) CGPointValue];
}

static char kAssociatedObjectKey_badgeCenterOffsetLandscape;
- (void)setQmui_badgeCenterOffsetLandscape:(CGPoint)qmui_badgeCenterOffsetLandscape {
    objc_setAssociatedObject(self, &kAssociatedObjectKey_badgeCenterOffsetLandscape, [NSValue valueWithCGPoint:qmui_badgeCenterOffsetLandscape], OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    if (self.qmui_badgeLabel) {
        self.qmui_badgeLabel.centerOffsetLandscape = qmui_badgeCenterOffsetLandscape;
    }
}

- (CGPoint)qmui_badgeCenterOffsetLandscape {
    return [((NSValue *)objc_getAssociatedObject(self, &kAssociatedObjectKey_badgeCenterOffsetLandscape)) CGPointValue];
}

static char kAssociatedObjectKey_badgeLabel;
- (void)setQmui_badgeLabel:(UILabel *)qmui_badgeLabel {
    objc_setAssociatedObject(self, &kAssociatedObjectKey_badgeLabel, qmui_badgeLabel, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (_QMUIBadgeLabel *)qmui_badgeLabel {
    return (_QMUIBadgeLabel *)objc_getAssociatedObject(self, &kAssociatedObjectKey_badgeLabel);
}

- (void)setNeedsUpdateBadgeLabelLayout {
    if (self.qmui_badgeString.length) {
        [self.qmui_view setNeedsLayout];
    }
}

#pragma mark - UpdatesIndicator

static char kAssociatedObjectKey_shouldShowUpdatesIndicator;
- (void)setQmui_shouldShowUpdatesIndicator:(BOOL)qmui_shouldShowUpdatesIndicator {
    objc_setAssociatedObject(self, &kAssociatedObjectKey_shouldShowUpdatesIndicator, @(qmui_shouldShowUpdatesIndicator), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    if (qmui_shouldShowUpdatesIndicator) {
        if (!self.qmui_updatesIndicatorView) {
            self.qmui_updatesIndicatorView = [[_QMUIUpdatesIndicatorView alloc] qmui_initWithSize:self.qmui_updatesIndicatorSize];
            self.qmui_updatesIndicatorView.layer.cornerRadius = CGRectGetHeight(self.qmui_updatesIndicatorView.bounds) / 2;
            self.qmui_updatesIndicatorView.backgroundColor = self.qmui_updatesIndicatorColor;
            self.qmui_updatesIndicatorView.centerOffset = self.qmui_updatesIndicatorCenterOffset;
            self.qmui_updatesIndicatorView.centerOffsetLandscape = self.qmui_updatesIndicatorCenterOffsetLandscape;
            if (!self.qmui_viewDidLayoutSubviewsBlock) {
                self.qmui_viewDidLayoutSubviewsBlock = ^(__kindof UIBarItem * _Nonnull item, UIView * _Nullable view) {
                    [item layoutSubviews];
                };
            }
            if (!self.qmui_viewDidSetBlock) {
                self.qmui_viewDidSetBlock = ^(__kindof UIBarItem * _Nonnull item, UIView * _Nullable view) {
                    [view addSubview:item.qmui_updatesIndicatorView];
                    [view addSubview:item.qmui_badgeLabel];
                    [view setNeedsLayout];
                    [view layoutIfNeeded];
                };
            }
            // 之前 item 已经 set 完 view，则手动触发一次
            if (self.qmui_view) {
                self.qmui_viewDidSetBlock(self, self.qmui_view);
            }
        }
        [self setNeedsUpdateIndicatorLayout];
        self.qmui_updatesIndicatorView.hidden = NO;
    } else {
        self.qmui_updatesIndicatorView.hidden = YES;
    }
}

- (BOOL)qmui_shouldShowUpdatesIndicator {
    return [((NSNumber *)objc_getAssociatedObject(self, &kAssociatedObjectKey_shouldShowUpdatesIndicator)) boolValue];
}

static char kAssociatedObjectKey_updatesIndicatorColor;
- (void)setQmui_updatesIndicatorColor:(UIColor *)qmui_updatesIndicatorColor {
    objc_setAssociatedObject(self, &kAssociatedObjectKey_updatesIndicatorColor, qmui_updatesIndicatorColor, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    if (self.qmui_updatesIndicatorView) {
        self.qmui_updatesIndicatorView.backgroundColor = qmui_updatesIndicatorColor;
    }
}

- (UIColor *)qmui_updatesIndicatorColor {
    return (UIColor *)objc_getAssociatedObject(self, &kAssociatedObjectKey_updatesIndicatorColor);
}

static char kAssociatedObjectKey_updatesIndicatorSize;
- (void)setQmui_updatesIndicatorSize:(CGSize)qmui_updatesIndicatorSize {
    objc_setAssociatedObject(self, &kAssociatedObjectKey_updatesIndicatorSize, [NSValue valueWithCGSize:qmui_updatesIndicatorSize], OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    if (self.qmui_updatesIndicatorView) {
        self.qmui_updatesIndicatorView.frame = CGRectSetSize(self.qmui_updatesIndicatorView.frame, qmui_updatesIndicatorSize);
        self.qmui_updatesIndicatorView.layer.cornerRadius = qmui_updatesIndicatorSize.height / 2;
        [self setNeedsUpdateIndicatorLayout];
    }
}

- (CGSize)qmui_updatesIndicatorSize {
    return [((NSValue *)objc_getAssociatedObject(self, &kAssociatedObjectKey_updatesIndicatorSize)) CGSizeValue];
}

static char kAssociatedObjectKey_updatesIndicatorCenterOffset;
- (void)setQmui_updatesIndicatorCenterOffset:(CGPoint)qmui_updatesIndicatorCenterOffset {
    objc_setAssociatedObject(self, &kAssociatedObjectKey_updatesIndicatorCenterOffset, [NSValue valueWithCGPoint:qmui_updatesIndicatorCenterOffset], OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    if (self.qmui_updatesIndicatorView) {
        self.qmui_updatesIndicatorView.centerOffset = qmui_updatesIndicatorCenterOffset;
        [self setNeedsUpdateIndicatorLayout];
    }
}

- (CGPoint)qmui_updatesIndicatorCenterOffset {
    return [((NSValue *)objc_getAssociatedObject(self, &kAssociatedObjectKey_updatesIndicatorCenterOffset)) CGPointValue];
}

static char kAssociatedObjectKey_updatesIndicatorCenterOffsetLandscape;
- (void)setQmui_updatesIndicatorCenterOffsetLandscape:(CGPoint)qmui_updatesIndicatorCenterOffsetLandscape {
    objc_setAssociatedObject(self, &kAssociatedObjectKey_updatesIndicatorCenterOffsetLandscape, [NSValue valueWithCGPoint:qmui_updatesIndicatorCenterOffsetLandscape], OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    if (self.qmui_updatesIndicatorView) {
        self.qmui_updatesIndicatorView.centerOffsetLandscape = qmui_updatesIndicatorCenterOffsetLandscape;
        [self setNeedsUpdateIndicatorLayout];
    }
}

- (CGPoint)qmui_updatesIndicatorCenterOffsetLandscape {
    return [((NSValue *)objc_getAssociatedObject(self, &kAssociatedObjectKey_updatesIndicatorCenterOffsetLandscape)) CGPointValue];
}

static char kAssociatedObjectKey_updatesIndicatorView;
- (void)setQmui_updatesIndicatorView:(UIView *)qmui_updatesIndicatorView {
    objc_setAssociatedObject(self, &kAssociatedObjectKey_updatesIndicatorView, qmui_updatesIndicatorView, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (_QMUIUpdatesIndicatorView *)qmui_updatesIndicatorView {
    return (_QMUIUpdatesIndicatorView *)objc_getAssociatedObject(self, &kAssociatedObjectKey_updatesIndicatorView);
}

- (void)setNeedsUpdateIndicatorLayout {
    if (self.qmui_shouldShowUpdatesIndicator) {
        [self.qmui_view setNeedsLayout];
    }
}

#pragma mark - Common

- (void)layoutSubviews {
    
    if (self.qmui_updatesIndicatorView && !self.qmui_updatesIndicatorView.hidden) {
        CGPoint centerOffset = IS_LANDSCAPE ? self.qmui_updatesIndicatorView.centerOffsetLandscape : self.qmui_updatesIndicatorView.centerOffset;

        UIView *superview = self.qmui_updatesIndicatorView.superview;
        if ([NSStringFromClass(superview.class) hasPrefix:@"UITabBar"]) {
            // 特别的，对于 UITabBarItem，将 imageView 的 center 作为参考点
            UIView *imageView = [UITabBarItem qmui_imageViewInTabBarButton:superview];
            if (!imageView) return;

            self.qmui_updatesIndicatorView.frame = CGRectSetXY(self.qmui_updatesIndicatorView.frame, CGRectGetMinXHorizontallyCenter(imageView.frame, self.qmui_updatesIndicatorView.frame) + centerOffset.x, CGRectGetMinYVerticallyCenter(imageView.frame, self.qmui_updatesIndicatorView.frame) + centerOffset.y);
        } else {
            self.qmui_updatesIndicatorView.frame = CGRectSetXY(self.qmui_updatesIndicatorView.frame, CGFloatGetCenter(superview.qmui_width, self.qmui_updatesIndicatorView.qmui_width) + centerOffset.x, CGFloatGetCenter(superview.qmui_height, self.qmui_updatesIndicatorView.qmui_height) + centerOffset.y);
        }

        [superview bringSubviewToFront:self.qmui_updatesIndicatorView];
    }
    
    if (self.qmui_badgeLabel && !self.qmui_badgeLabel.hidden) {
        [self.qmui_badgeLabel sizeToFit];
        self.qmui_badgeLabel.layer.cornerRadius = MIN(self.qmui_badgeLabel.qmui_height / 2, self.qmui_badgeLabel.qmui_width / 2);
        
        CGPoint centerOffset = IS_LANDSCAPE ? self.qmui_badgeLabel.centerOffsetLandscape : self.qmui_badgeLabel.centerOffset;
        
        UIView *superview = self.qmui_badgeLabel.superview;
        if ([NSStringFromClass(superview.class) hasPrefix:@"UITabBar"]) {
            // 特别的，对于 UITabBarItem，将 imageView 的 center 作为参考点
            UIView *imageView = [UITabBarItem qmui_imageViewInTabBarButton:superview];
            if (!imageView) return;
            
            self.qmui_badgeLabel.frame = CGRectSetXY(self.qmui_badgeLabel.frame, CGRectGetMinXHorizontallyCenter(imageView.frame, self.qmui_badgeLabel.frame) + centerOffset.x, CGRectGetMinYVerticallyCenter(imageView.frame, self.qmui_badgeLabel.frame) + centerOffset.y);
        } else {
            self.qmui_badgeLabel.frame = CGRectSetXY(self.qmui_badgeLabel.frame, CGFloatGetCenter(superview.qmui_width, self.qmui_badgeLabel.qmui_width) + centerOffset.x, CGFloatGetCenter(superview.qmui_height, self.qmui_badgeLabel.qmui_height) + centerOffset.y);
        }
        
        [superview bringSubviewToFront:self.qmui_badgeLabel];
    }
}

@end

@implementation _QMUIUpdatesIndicatorView

- (void)setCenterOffset:(CGPoint)centerOffset {
    _centerOffset = centerOffset;
    if (!IS_LANDSCAPE) {
        [self.superview setNeedsLayout];
    }
}

- (void)setCenterOffsetLandscape:(CGPoint)centerOffsetLandscape {
    _centerOffsetLandscape = centerOffsetLandscape;
    if (IS_LANDSCAPE) {
        [self.superview setNeedsLayout];
    }
}

@end

@implementation _QMUIBadgeLabel

- (void)setCenterOffset:(CGPoint)centerOffset {
    _centerOffset = centerOffset;
    if (!IS_LANDSCAPE) {
        [self.superview setNeedsLayout];
    }
}

- (void)setCenterOffsetLandscape:(CGPoint)centerOffsetLandscape {
    _centerOffsetLandscape = centerOffsetLandscape;
    if (IS_LANDSCAPE) {
        [self.superview setNeedsLayout];
    }
}

- (CGSize)sizeThatFits:(CGSize)size {
    CGSize result = [super sizeThatFits:size];
    
    // 只有一个字的时候保证它是一个正方形
    if (self.text.length <= 1) {
        CGFloat finalSize = MAX(result.width, result.height);
        result = CGSizeMake(finalSize, finalSize);
    }
    
    return result;
}

@end
