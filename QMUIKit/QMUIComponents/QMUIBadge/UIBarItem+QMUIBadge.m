/**
 * Tencent is pleased to support the open source community by making QMUI_iOS available.
 * Copyright (C) 2016-2021 THL A29 Limited, a Tencent company. All rights reserved.
 * Licensed under the MIT License (the "License"); you may not use this file except in compliance with the License. You may obtain a copy of the License at
 * http://opensource.org/licenses/MIT
 * Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.
 */

//
//  UIBarItem+QMUIBadge.m
//  QMUIKit
//
//  Created by QMUI Team on 2018/6/2.
//

#import "UIBarItem+QMUIBadge.h"
#import "QMUICore.h"
#import "UIView+QMUIBadge.h"
#import "UIBarItem+QMUI.h"

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
                
                if (firstArgv.superview == selfObject) {
                    return;
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
    if (QMUICMIActivated) {
        self.qmui_badgeBackgroundColor = BadgeBackgroundColor;
        self.qmui_badgeTextColor = BadgeTextColor;
        self.qmui_badgeFont = BadgeFont;
        self.qmui_badgeContentEdgeInsets = BadgeContentEdgeInsets;
        self.qmui_badgeOffset = BadgeOffset;
        self.qmui_badgeOffsetLandscape = BadgeOffsetLandscape;
        
        self.qmui_updatesIndicatorColor = UpdatesIndicatorColor;
        self.qmui_updatesIndicatorSize = UpdatesIndicatorSize;
        self.qmui_updatesIndicatorOffset = UpdatesIndicatorOffset;
        self.qmui_updatesIndicatorOffsetLandscape = UpdatesIndicatorOffsetLandscape;
        
        BeginIgnoreDeprecatedWarning
        self.qmui_badgeCenterOffset = BadgeCenterOffset;
        self.qmui_badgeCenterOffsetLandscape = BadgeCenterOffsetLandscape;
        self.qmui_updatesIndicatorCenterOffset = UpdatesIndicatorCenterOffset;
        self.qmui_updatesIndicatorCenterOffsetLandscape = UpdatesIndicatorCenterOffsetLandscape;
        EndIgnoreClangWarning
    }
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
        [self updateViewDidSetBlockIfNeeded];
    }
    self.qmui_view.qmui_badgeString = qmui_badgeString;
}

- (NSString *)qmui_badgeString {
    return (NSString *)objc_getAssociatedObject(self, &kAssociatedObjectKey_badgeString);
}

static char kAssociatedObjectKey_badgeBackgroundColor;
- (void)setQmui_badgeBackgroundColor:(UIColor *)qmui_badgeBackgroundColor {
    objc_setAssociatedObject(self, &kAssociatedObjectKey_badgeBackgroundColor, qmui_badgeBackgroundColor, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    self.qmui_view.qmui_badgeBackgroundColor = qmui_badgeBackgroundColor;
}

- (UIColor *)qmui_badgeBackgroundColor {
    return (UIColor *)objc_getAssociatedObject(self, &kAssociatedObjectKey_badgeBackgroundColor);
}

static char kAssociatedObjectKey_badgeTextColor;
- (void)setQmui_badgeTextColor:(UIColor *)qmui_badgeTextColor {
    objc_setAssociatedObject(self, &kAssociatedObjectKey_badgeTextColor, qmui_badgeTextColor, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    self.qmui_view.qmui_badgeTextColor = qmui_badgeTextColor;
}

- (UIColor *)qmui_badgeTextColor {
    return (UIColor *)objc_getAssociatedObject(self, &kAssociatedObjectKey_badgeTextColor);
}

static char kAssociatedObjectKey_badgeFont;
- (void)setQmui_badgeFont:(UIFont *)qmui_badgeFont {
    objc_setAssociatedObject(self, &kAssociatedObjectKey_badgeFont, qmui_badgeFont, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    self.qmui_view.qmui_badgeFont = qmui_badgeFont;
}

- (UIFont *)qmui_badgeFont {
    return (UIFont *)objc_getAssociatedObject(self, &kAssociatedObjectKey_badgeFont);
}

static char kAssociatedObjectKey_badgeContentEdgeInsets;
- (void)setQmui_badgeContentEdgeInsets:(UIEdgeInsets)qmui_badgeContentEdgeInsets {
    objc_setAssociatedObject(self, &kAssociatedObjectKey_badgeContentEdgeInsets, [NSValue valueWithUIEdgeInsets:qmui_badgeContentEdgeInsets], OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    self.qmui_view.qmui_badgeContentEdgeInsets = qmui_badgeContentEdgeInsets;
}

- (UIEdgeInsets)qmui_badgeContentEdgeInsets {
    return [((NSValue *)objc_getAssociatedObject(self, &kAssociatedObjectKey_badgeContentEdgeInsets)) UIEdgeInsetsValue];
}

static char kAssociatedObjectKey_badgeOffset;
- (void)setQmui_badgeOffset:(CGPoint)qmui_badgeOffset {
    objc_setAssociatedObject(self, &kAssociatedObjectKey_badgeOffset, @(qmui_badgeOffset), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    self.qmui_view.qmui_badgeOffset = qmui_badgeOffset;
}

- (CGPoint)qmui_badgeOffset {
    return [((NSNumber *)objc_getAssociatedObject(self, &kAssociatedObjectKey_badgeOffset)) CGPointValue];
}

static char kAssociatedObjectKey_badgeOffsetLandscape;
- (void)setQmui_badgeOffsetLandscape:(CGPoint)qmui_badgeOffsetLandscape {
    objc_setAssociatedObject(self, &kAssociatedObjectKey_badgeOffsetLandscape, @(qmui_badgeOffsetLandscape), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    self.qmui_view.qmui_badgeOffsetLandscape = qmui_badgeOffsetLandscape;
}

- (CGPoint)qmui_badgeOffsetLandscape {
    return [((NSNumber *)objc_getAssociatedObject(self, &kAssociatedObjectKey_badgeOffsetLandscape)) CGPointValue];
}

BeginIgnoreDeprecatedWarning
BeginIgnoreClangWarning(-Wdeprecated-implementations)

static char kAssociatedObjectKey_badgeCenterOffset;
- (void)setQmui_badgeCenterOffset:(CGPoint)qmui_badgeCenterOffset {
    objc_setAssociatedObject(self, &kAssociatedObjectKey_badgeCenterOffset, [NSValue valueWithCGPoint:qmui_badgeCenterOffset], OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    self.qmui_view.qmui_badgeCenterOffset = qmui_badgeCenterOffset;
}

- (CGPoint)qmui_badgeCenterOffset {
    return [((NSValue *)objc_getAssociatedObject(self, &kAssociatedObjectKey_badgeCenterOffset)) CGPointValue];
}

static char kAssociatedObjectKey_badgeCenterOffsetLandscape;
- (void)setQmui_badgeCenterOffsetLandscape:(CGPoint)qmui_badgeCenterOffsetLandscape {
    objc_setAssociatedObject(self, &kAssociatedObjectKey_badgeCenterOffsetLandscape, [NSValue valueWithCGPoint:qmui_badgeCenterOffsetLandscape], OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    self.qmui_view.qmui_badgeCenterOffsetLandscape = qmui_badgeCenterOffsetLandscape;
}

- (CGPoint)qmui_badgeCenterOffsetLandscape {
    return [((NSValue *)objc_getAssociatedObject(self, &kAssociatedObjectKey_badgeCenterOffsetLandscape)) CGPointValue];
}

EndIgnoreClangWarning
EndIgnoreDeprecatedWarning

- (QMUILabel *)qmui_badgeLabel {
    return self.qmui_view.qmui_badgeLabel;
}

#pragma mark - UpdatesIndicator

static char kAssociatedObjectKey_shouldShowUpdatesIndicator;
- (void)setQmui_shouldShowUpdatesIndicator:(BOOL)qmui_shouldShowUpdatesIndicator {
    objc_setAssociatedObject(self, &kAssociatedObjectKey_shouldShowUpdatesIndicator, @(qmui_shouldShowUpdatesIndicator), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    if (qmui_shouldShowUpdatesIndicator) {
        [self updateViewDidSetBlockIfNeeded];
    }
    self.qmui_view.qmui_shouldShowUpdatesIndicator = qmui_shouldShowUpdatesIndicator;
}

- (BOOL)qmui_shouldShowUpdatesIndicator {
    return [((NSNumber *)objc_getAssociatedObject(self, &kAssociatedObjectKey_shouldShowUpdatesIndicator)) boolValue];
}

static char kAssociatedObjectKey_updatesIndicatorColor;
- (void)setQmui_updatesIndicatorColor:(UIColor *)qmui_updatesIndicatorColor {
    objc_setAssociatedObject(self, &kAssociatedObjectKey_updatesIndicatorColor, qmui_updatesIndicatorColor, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    self.qmui_view.qmui_updatesIndicatorColor = qmui_updatesIndicatorColor;
}

- (UIColor *)qmui_updatesIndicatorColor {
    return (UIColor *)objc_getAssociatedObject(self, &kAssociatedObjectKey_updatesIndicatorColor);
}

static char kAssociatedObjectKey_updatesIndicatorSize;
- (void)setQmui_updatesIndicatorSize:(CGSize)qmui_updatesIndicatorSize {
    objc_setAssociatedObject(self, &kAssociatedObjectKey_updatesIndicatorSize, [NSValue valueWithCGSize:qmui_updatesIndicatorSize], OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    self.qmui_view.qmui_updatesIndicatorSize = qmui_updatesIndicatorSize;
}

- (CGSize)qmui_updatesIndicatorSize {
    return [((NSValue *)objc_getAssociatedObject(self, &kAssociatedObjectKey_updatesIndicatorSize)) CGSizeValue];
}

static char kAssociatedObjectKey_updatesIndicatorOffset;
- (void)setQmui_updatesIndicatorOffset:(CGPoint)qmui_updatesIndicatorOffset {
    objc_setAssociatedObject(self, &kAssociatedObjectKey_updatesIndicatorOffset, @(qmui_updatesIndicatorOffset), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    self.qmui_view.qmui_updatesIndicatorOffset = qmui_updatesIndicatorOffset;
}

- (CGPoint)qmui_updatesIndicatorOffset {
    return [((NSNumber *)objc_getAssociatedObject(self, &kAssociatedObjectKey_updatesIndicatorOffset)) CGPointValue];
}

static char kAssociatedObjectKey_updatesIndicatorOffsetLandscape;
- (void)setQmui_updatesIndicatorOffsetLandscape:(CGPoint)qmui_updatesIndicatorOffsetLandscape {
    objc_setAssociatedObject(self, &kAssociatedObjectKey_updatesIndicatorOffsetLandscape, @(qmui_updatesIndicatorOffsetLandscape), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    self.qmui_view.qmui_updatesIndicatorOffsetLandscape = qmui_updatesIndicatorOffsetLandscape;
}

- (CGPoint)qmui_updatesIndicatorOffsetLandscape {
    return [((NSNumber *)objc_getAssociatedObject(self, &kAssociatedObjectKey_updatesIndicatorOffsetLandscape)) CGPointValue];
}

BeginIgnoreDeprecatedWarning
BeginIgnoreClangWarning(-Wdeprecated-implementations)

static char kAssociatedObjectKey_updatesIndicatorCenterOffset;
- (void)setQmui_updatesIndicatorCenterOffset:(CGPoint)qmui_updatesIndicatorCenterOffset {
    objc_setAssociatedObject(self, &kAssociatedObjectKey_updatesIndicatorCenterOffset, [NSValue valueWithCGPoint:qmui_updatesIndicatorCenterOffset], OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    self.qmui_view.qmui_updatesIndicatorCenterOffset = qmui_updatesIndicatorCenterOffset;
}

- (CGPoint)qmui_updatesIndicatorCenterOffset {
    return [((NSValue *)objc_getAssociatedObject(self, &kAssociatedObjectKey_updatesIndicatorCenterOffset)) CGPointValue];
}

static char kAssociatedObjectKey_updatesIndicatorCenterOffsetLandscape;
- (void)setQmui_updatesIndicatorCenterOffsetLandscape:(CGPoint)qmui_updatesIndicatorCenterOffsetLandscape {
    objc_setAssociatedObject(self, &kAssociatedObjectKey_updatesIndicatorCenterOffsetLandscape, [NSValue valueWithCGPoint:qmui_updatesIndicatorCenterOffsetLandscape], OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    self.qmui_view.qmui_updatesIndicatorCenterOffsetLandscape = qmui_updatesIndicatorCenterOffsetLandscape;
}

- (CGPoint)qmui_updatesIndicatorCenterOffsetLandscape {
    return [((NSValue *)objc_getAssociatedObject(self, &kAssociatedObjectKey_updatesIndicatorCenterOffsetLandscape)) CGPointValue];
}

EndIgnoreClangWarning
EndIgnoreDeprecatedWarning

- (UIView *)qmui_updatesIndicatorView {
    return self.qmui_view.qmui_updatesIndicatorView;
}

#pragma mark - Common

- (void)updateViewDidSetBlockIfNeeded {
    if (!self.qmui_viewDidSetBlock) {
        self.qmui_viewDidSetBlock = ^(__kindof UIBarItem * _Nonnull item, UIView * _Nullable view) {
            view.qmui_badgeBackgroundColor = item.qmui_badgeBackgroundColor;
            view.qmui_badgeTextColor = item.qmui_badgeTextColor;
            view.qmui_badgeFont = item.qmui_badgeFont;
            view.qmui_badgeContentEdgeInsets = item.qmui_badgeContentEdgeInsets;
            view.qmui_badgeOffset = item.qmui_badgeOffset;
            view.qmui_badgeOffsetLandscape = item.qmui_badgeOffsetLandscape;
            
            view.qmui_updatesIndicatorColor = item.qmui_updatesIndicatorColor;
            view.qmui_updatesIndicatorSize = item.qmui_updatesIndicatorSize;
            view.qmui_updatesIndicatorOffset = item.qmui_updatesIndicatorOffset;
            view.qmui_updatesIndicatorOffsetLandscape = item.qmui_updatesIndicatorOffsetLandscape;
            
            BeginIgnoreDeprecatedWarning
            view.qmui_badgeCenterOffset = item.qmui_badgeCenterOffset;
            view.qmui_badgeCenterOffsetLandscape = item.qmui_badgeCenterOffsetLandscape;
            view.qmui_updatesIndicatorCenterOffset = item.qmui_updatesIndicatorCenterOffset;
            view.qmui_updatesIndicatorCenterOffsetLandscape = item.qmui_updatesIndicatorCenterOffsetLandscape;
            EndIgnoreDeprecatedWarning
            
            view.qmui_badgeString = item.qmui_badgeString;
            view.qmui_shouldShowUpdatesIndicator = item.qmui_shouldShowUpdatesIndicator;
        };
        
        // 为 qmui_viewDidSetBlock 赋值前 item 已经 set 完 view，则手动触发一次
        if (self.qmui_view) {
            self.qmui_viewDidSetBlock(self, self.qmui_view);
        }
    }
}

@end
