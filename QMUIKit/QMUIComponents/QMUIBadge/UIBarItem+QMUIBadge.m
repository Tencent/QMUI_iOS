/*****
 * Tencent is pleased to support the open source community by making QMUI_iOS available.
 * Copyright (C) 2016-2018 THL A29 Limited, a Tencent company. All rights reserved.
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
#import "QMUILabel.h"
#import "UIView+QMUI.h"
#import "UIBarItem+QMUI.h"
#import "UITabBarItem+QMUI.h"

@interface _QMUIBadgeLabel : QMUILabel

@property(nonatomic, assign) CGPoint centerOffset;
@property(nonatomic, assign) CGPoint centerOffsetLandscape;

- (void)updateLayout;
@end

@interface _QMUIUpdatesIndicatorView : UIView

@property(nonatomic, assign) CGPoint centerOffset;
@property(nonatomic, assign) CGPoint centerOffsetLandscape;

- (void)updateLayout;
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
        ExchangeImplementations([UIBarItem class], @selector(init), @selector(qmuibaritem_init));
        ExchangeImplementations([UIBarItem class], @selector(initWithCoder:), @selector(qmuibaritem_initWithCoder:));
        
        // 针对非 customView 的 UIBarButtonItem，负责将红点添加上去
        ExtendImplementationOfVoidMethodWithSingleArgument([UIBarButtonItem class], @selector(setView:), UIView *, ^(UIBarButtonItem *selfObject, UIView *firstArgv) {
            if (selfObject.qmui_badgeString.length && selfObject.qmui_badgeLabel) {
                [firstArgv addSubview:selfObject.qmui_badgeLabel];
            }
            if (selfObject.qmui_shouldShowUpdatesIndicator && selfObject.qmui_updatesIndicatorView) {
                [firstArgv addSubview:selfObject.qmui_updatesIndicatorView];
            }
        });
        
        // 针对 UITabBarItem，负责将红点添加上去
        ExtendImplementationOfVoidMethodWithSingleArgument([UITabBarItem class], @selector(setView:), UIView *, ^(UITabBarItem *selfObject, UIView *firstArgv) {
            if (selfObject.qmui_badgeString.length && selfObject.qmui_badgeLabel) {
                [firstArgv addSubview:selfObject.qmui_badgeLabel];
            }
            if (selfObject.qmui_shouldShowUpdatesIndicator && selfObject.qmui_updatesIndicatorView) {
                [firstArgv addSubview:selfObject.qmui_updatesIndicatorView];
            }
        });
        
        // 针对 UITabBarItem 和非 customView 的 UIBarButtonItem，在 item 布局时更新红点的布局
        void (^layoutSubviewsBlock)(UIView *selfObject) = ^(UIView *selfObject){
            for (UIView *subview in selfObject.subviews) {
                if ([subview isKindOfClass:[_QMUIBadgeLabel class]]) {
                    [(_QMUIBadgeLabel *)subview updateLayout];
                } else if ([subview isKindOfClass:[_QMUIUpdatesIndicatorView class]]) {
                    [(_QMUIUpdatesIndicatorView *)subview updateLayout];
                }
            }
        };
        Class navigationButtonClass = nil;
        if (@available(iOS 11, *)) {
            navigationButtonClass = NSClassFromString([NSString stringWithFormat:@"_%@%@", @"UIButton", @"BarButton"]);
        } else {
            navigationButtonClass = NSClassFromString([NSString stringWithFormat:@"%@%@", @"UINavigation", @"Button"]);
        }
        ExtendImplementationOfVoidMethodWithoutArguments(navigationButtonClass, @selector(layoutSubviews), layoutSubviewsBlock);
        ExtendImplementationOfVoidMethodWithoutArguments(NSClassFromString([NSString stringWithFormat:@"%@%@", @"UITab", @"BarButton"]), @selector(layoutSubviews), layoutSubviewsBlock);
    });
}

- (instancetype)qmuibaritem_init {
    [self qmuibaritem_init];
    [self qmuibaritem_didInitialize];
    return self;
}

- (instancetype)qmuibaritem_initWithCoder:(NSCoder *)aDecoder {
    [self qmuibaritem_initWithCoder:aDecoder];
    [self qmuibaritem_didInitialize];
    return self;
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
            [self.qmui_view addSubview:self.qmui_badgeLabel];
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
        if ([self isKindOfClass:[UIBarButtonItem class]] && ((UIBarButtonItem *)self).customView) {
            // 如果是 customView，由于无法重写它的 layoutSubviews，所以认为它目前的 frame 已经是最终的 frame，直接按照当前 frame 来布局即可
            [self.qmui_badgeLabel updateLayout];
        } else {
            [self.qmui_view setNeedsLayout];
        }
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
            [self.qmui_view addSubview:self.qmui_updatesIndicatorView];
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
        if ([self isKindOfClass:[UIBarButtonItem class]] && ((UIBarButtonItem *)self).customView) {
            // 如果是 customView，由于无法重写它的 layoutSubviews，所以认为它目前的 frame 已经是最终的 frame，直接按照当前 frame 来布局即可
            [self.qmui_updatesIndicatorView updateLayout];
        } else {
            [self.qmui_view setNeedsLayout];
        }
    }
}

@end

@implementation _QMUIUpdatesIndicatorView

- (void)setCenterOffset:(CGPoint)centerOffset {
    _centerOffset = centerOffset;
    if (!IS_LANDSCAPE) {
        [self updateLayout];
    }
}

- (void)setCenterOffsetLandscape:(CGPoint)centerOffsetLandscape {
    _centerOffsetLandscape = centerOffsetLandscape;
    if (IS_LANDSCAPE) {
        [self updateLayout];
    }
}

- (void)updateLayout {
    UIView *superview = self.superview;
    if (!superview) return;
    
    CGPoint centerOffset = IS_LANDSCAPE ? self.centerOffsetLandscape : self.centerOffset;
    
    if ([NSStringFromClass(superview.class) hasPrefix:@"UITabBar"]) {
        // 特别的，对于 UITabBarItem，将 imageView 的 center 作为参考点
        UIView *imageView = [UITabBarItem qmui_imageViewInTabBarButton:superview];
        if (!imageView) return;
        
        self.frame = CGRectSetXY(self.frame, CGRectGetMinXHorizontallyCenter(imageView.frame, self.frame) + centerOffset.x, CGRectGetMinYVerticallyCenter(imageView.frame, self.frame) + centerOffset.y);
    } else {
        self.frame = CGRectSetXY(self.frame, CGFloatGetCenter(superview.qmui_width, self.qmui_width) + centerOffset.x, CGFloatGetCenter(superview.qmui_height, self.qmui_height) + centerOffset.y);
    }
    
    [self.superview bringSubviewToFront:self];
}

@end

@implementation _QMUIBadgeLabel

- (void)setCenterOffset:(CGPoint)centerOffset {
    _centerOffset = centerOffset;
    if (!IS_LANDSCAPE) {
        [self updateLayout];
    }
}

- (void)setCenterOffsetLandscape:(CGPoint)centerOffsetLandscape {
    _centerOffsetLandscape = centerOffsetLandscape;
    if (IS_LANDSCAPE) {
        [self updateLayout];
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

- (void)updateLayout {
    UIView *superview = self.superview;
    if (!superview) return;
    
    [self sizeToFit];
    self.layer.cornerRadius = MIN(self.qmui_height / 2, self.qmui_width / 2);
    
    CGPoint centerOffset = IS_LANDSCAPE ? self.centerOffsetLandscape : self.centerOffset;
    
    if ([NSStringFromClass(superview.class) hasPrefix:@"UITabBar"]) {
        // 特别的，对于 UITabBarItem，将 imageView 的 center 作为参考点
        UIView *imageView = [UITabBarItem qmui_imageViewInTabBarButton:superview];
        if (!imageView) return;
        
        self.frame = CGRectSetXY(self.frame, CGRectGetMinXHorizontallyCenter(imageView.frame, self.frame) + centerOffset.x, CGRectGetMinYVerticallyCenter(imageView.frame, self.frame) + centerOffset.y);
    } else {
        self.frame = CGRectSetXY(self.frame, CGFloatGetCenter(superview.qmui_width, self.qmui_width) + centerOffset.x, CGFloatGetCenter(superview.qmui_height, self.qmui_height) + centerOffset.y);
    }
    
    [self.superview bringSubviewToFront:self];
}

@end
