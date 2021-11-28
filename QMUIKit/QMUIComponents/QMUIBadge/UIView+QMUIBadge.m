/**
 * Tencent is pleased to support the open source community by making QMUI_iOS available.
 * Copyright (C) 2016-2021 THL A29 Limited, a Tencent company. All rights reserved.
 * Licensed under the MIT License (the "License"); you may not use this file except in compliance with the License. You may obtain a copy of the License at
 * http://opensource.org/licenses/MIT
 * Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.
 */

//
//  UIView+QMUIBadge.m
//  QMUIKit
//
//  Created by MoLice on 2020/5/26.
//

#import "UIView+QMUIBadge.h"
#import "QMUICore.h"
#import "QMUILabel.h"
#import "UIView+QMUI.h"
#import "UITabBarItem+QMUI.h"

@protocol _QMUIBadgeViewProtocol <NSObject>

@required

@property(nonatomic, assign) CGPoint offset;
@property(nonatomic, assign) CGPoint offsetLandscape;
@property(nonatomic, assign) CGPoint centerOffset;
@property(nonatomic, assign) CGPoint centerOffsetLandscape;

@end

@interface _QMUIBadgeLabel : QMUILabel <_QMUIBadgeViewProtocol>
@end

@interface _QMUIUpdatesIndicatorView : UIView <_QMUIBadgeViewProtocol>
@end

@interface UIView ()

@property(nonatomic, strong, readwrite) _QMUIBadgeLabel *qmui_badgeLabel;
@property(nonatomic, strong, readwrite) _QMUIUpdatesIndicatorView *qmui_updatesIndicatorView;
@property(nullable, nonatomic, strong) void (^qmuibdg_layoutSubviewsBlock)(__kindof UIView *view);
@end

@implementation UIView (QMUIBadge)

QMUISynthesizeIdStrongProperty(qmuibdg_layoutSubviewsBlock, setQmuibdg_layoutSubviewsBlock)

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        // 保证配置表里的默认值正确被设置
        ExtendImplementationOfNonVoidMethodWithSingleArgument([UIView class], @selector(initWithFrame:), CGRect, UIView *, ^UIView *(UIView *selfObject, CGRect firstArgv, UIView *originReturnValue) {
            [selfObject qmuibdg_didInitialize];
            return originReturnValue;
        });
        
        ExtendImplementationOfNonVoidMethodWithSingleArgument([UIView class], @selector(initWithCoder:), NSCoder *, UIView *, ^UIView *(UIView *selfObject, NSCoder *firstArgv, UIView *originReturnValue) {
            [selfObject qmuibdg_didInitialize];
            return originReturnValue;
        });
        
        OverrideImplementation([UIView class], @selector(setQmui_layoutSubviewsBlock:), ^id(__unsafe_unretained Class originClass, SEL originCMD, IMP (^originalIMPProvider)(void)) {
            return ^(UIView *selfObject, void (^firstArgv)(__kindof UIView *aView)) {
                
                if (firstArgv && selfObject.qmuibdg_layoutSubviewsBlock && firstArgv != selfObject.qmuibdg_layoutSubviewsBlock) {
                    firstArgv = ^void(__kindof UIView *aaView) {
                        firstArgv(aaView);
                        aaView.qmuibdg_layoutSubviewsBlock(aaView);
                    };
                }
                
                // call super
                void (*originSelectorIMP)(id, SEL, void (^firstArgv)(__kindof UIView *aView));
                originSelectorIMP = (void (*)(id, SEL, void (^firstArgv)(__kindof UIView *aView)))originalIMPProvider();
                originSelectorIMP(selfObject, originCMD, firstArgv);
            };
        });
    });
}

- (void)qmuibdg_didInitialize {
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
        EndIgnoreDeprecatedWarning
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
        if (!self.qmui_badgeLabel) {
            self.qmui_badgeLabel = [[_QMUIBadgeLabel alloc] init];
            self.qmui_badgeLabel.clipsToBounds = YES;
            self.qmui_badgeLabel.textAlignment = NSTextAlignmentCenter;
            self.qmui_badgeLabel.backgroundColor = self.qmui_badgeBackgroundColor;
            self.qmui_badgeLabel.textColor = self.qmui_badgeTextColor;
            self.qmui_badgeLabel.font = self.qmui_badgeFont;
            self.qmui_badgeLabel.contentEdgeInsets = self.qmui_badgeContentEdgeInsets;
            self.qmui_badgeLabel.offset = self.qmui_badgeOffset;
            self.qmui_badgeLabel.offsetLandscape = self.qmui_badgeOffsetLandscape;
            BeginIgnoreDeprecatedWarning
            self.qmui_badgeLabel.centerOffset = self.qmui_badgeCenterOffset;
            self.qmui_badgeLabel.centerOffsetLandscape = self.qmui_badgeCenterOffsetLandscape;
            EndIgnoreDeprecatedWarning
            [self addSubview:self.qmui_badgeLabel];
            
            [self updateLayoutSubviewsBlockIfNeeded];
        }
        self.qmui_badgeLabel.text = qmui_badgeString;
        self.qmui_badgeLabel.hidden = NO;
        [self setNeedsUpdateBadgeLabelLayout];
        self.clipsToBounds = NO;
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
    self.qmui_badgeLabel.backgroundColor = qmui_badgeBackgroundColor;
}

- (UIColor *)qmui_badgeBackgroundColor {
    return (UIColor *)objc_getAssociatedObject(self, &kAssociatedObjectKey_badgeBackgroundColor);
}

static char kAssociatedObjectKey_badgeTextColor;
- (void)setQmui_badgeTextColor:(UIColor *)qmui_badgeTextColor {
    objc_setAssociatedObject(self, &kAssociatedObjectKey_badgeTextColor, qmui_badgeTextColor, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    self.qmui_badgeLabel.textColor = qmui_badgeTextColor;
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

static char kAssociatedObjectKey_badgeOffset;
- (void)setQmui_badgeOffset:(CGPoint)qmui_badgeOffset {
    objc_setAssociatedObject(self, &kAssociatedObjectKey_badgeOffset, @(qmui_badgeOffset), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    self.qmui_badgeLabel.offset = qmui_badgeOffset;
}

- (CGPoint)qmui_badgeOffset {
    return [((NSNumber *)objc_getAssociatedObject(self, &kAssociatedObjectKey_badgeOffset)) CGPointValue];
}

static char kAssociatedObjectKey_badgeOffsetLandscape;
- (void)setQmui_badgeOffsetLandscape:(CGPoint)qmui_badgeOffsetLandscape {
    objc_setAssociatedObject(self, &kAssociatedObjectKey_badgeOffsetLandscape, @(qmui_badgeOffsetLandscape), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    self.qmui_badgeLabel.offsetLandscape = qmui_badgeOffsetLandscape;
}

- (CGPoint)qmui_badgeOffsetLandscape {
    return [((NSNumber *)objc_getAssociatedObject(self, &kAssociatedObjectKey_badgeOffsetLandscape)) CGPointValue];
}

BeginIgnoreDeprecatedWarning
BeginIgnoreClangWarning(-Wdeprecated-implementations)

static char kAssociatedObjectKey_badgeCenterOffset;
- (void)setQmui_badgeCenterOffset:(CGPoint)qmui_badgeCenterOffset {
    objc_setAssociatedObject(self, &kAssociatedObjectKey_badgeCenterOffset, [NSValue valueWithCGPoint:qmui_badgeCenterOffset], OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    self.qmui_badgeLabel.centerOffset = qmui_badgeCenterOffset;
}

- (CGPoint)qmui_badgeCenterOffset {
    return [((NSValue *)objc_getAssociatedObject(self, &kAssociatedObjectKey_badgeCenterOffset)) CGPointValue];
}

static char kAssociatedObjectKey_badgeCenterOffsetLandscape;
- (void)setQmui_badgeCenterOffsetLandscape:(CGPoint)qmui_badgeCenterOffsetLandscape {
    objc_setAssociatedObject(self, &kAssociatedObjectKey_badgeCenterOffsetLandscape, [NSValue valueWithCGPoint:qmui_badgeCenterOffsetLandscape], OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    self.qmui_badgeLabel.centerOffsetLandscape = qmui_badgeCenterOffsetLandscape;
}

- (CGPoint)qmui_badgeCenterOffsetLandscape {
    return [((NSValue *)objc_getAssociatedObject(self, &kAssociatedObjectKey_badgeCenterOffsetLandscape)) CGPointValue];
}

EndIgnoreClangWarning
EndIgnoreDeprecatedWarning

static char kAssociatedObjectKey_badgeLabel;
- (void)setQmui_badgeLabel:(UILabel *)qmui_badgeLabel {
    objc_setAssociatedObject(self, &kAssociatedObjectKey_badgeLabel, qmui_badgeLabel, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (_QMUIBadgeLabel *)qmui_badgeLabel {
    return (_QMUIBadgeLabel *)objc_getAssociatedObject(self, &kAssociatedObjectKey_badgeLabel);
}

- (void)setNeedsUpdateBadgeLabelLayout {
    if (self.qmui_badgeString.length) {
        [self setNeedsLayout];
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
            self.qmui_updatesIndicatorView.offset = self.qmui_updatesIndicatorOffset;
            self.qmui_updatesIndicatorView.offsetLandscape = self.qmui_updatesIndicatorOffsetLandscape;
            BeginIgnoreDeprecatedWarning
            self.qmui_updatesIndicatorView.centerOffset = self.qmui_updatesIndicatorCenterOffset;
            self.qmui_updatesIndicatorView.centerOffsetLandscape = self.qmui_updatesIndicatorCenterOffsetLandscape;
            EndIgnoreDeprecatedWarning
            [self addSubview:self.qmui_updatesIndicatorView];
            [self updateLayoutSubviewsBlockIfNeeded];
        }
        [self setNeedsUpdateIndicatorLayout];
        self.clipsToBounds = NO;
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
    self.qmui_updatesIndicatorView.backgroundColor = qmui_updatesIndicatorColor;
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

static char kAssociatedObjectKey_updatesIndicatorOffset;
- (void)setQmui_updatesIndicatorOffset:(CGPoint)qmui_updatesIndicatorOffset {
    objc_setAssociatedObject(self, &kAssociatedObjectKey_updatesIndicatorOffset, @(qmui_updatesIndicatorOffset), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    if (self.qmui_updatesIndicatorView) {
        self.qmui_updatesIndicatorView.offset = qmui_updatesIndicatorOffset;
        [self setNeedsUpdateIndicatorLayout];
    }
}

- (CGPoint)qmui_updatesIndicatorOffset {
    return [((NSNumber *)objc_getAssociatedObject(self, &kAssociatedObjectKey_updatesIndicatorOffset)) CGPointValue];
}

static char kAssociatedObjectKey_updatesIndicatorOffsetLandscape;
- (void)setQmui_updatesIndicatorOffsetLandscape:(CGPoint)qmui_updatesIndicatorOffsetLandscape {
    objc_setAssociatedObject(self, &kAssociatedObjectKey_updatesIndicatorOffsetLandscape, @(qmui_updatesIndicatorOffsetLandscape), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    if (self.qmui_updatesIndicatorView) {
        self.qmui_updatesIndicatorView.offsetLandscape = qmui_updatesIndicatorOffsetLandscape;
        [self setNeedsUpdateIndicatorLayout];
    }
}

- (CGPoint)qmui_updatesIndicatorOffsetLandscape {
    return [((NSNumber *)objc_getAssociatedObject(self, &kAssociatedObjectKey_updatesIndicatorOffsetLandscape)) CGPointValue];
}

BeginIgnoreDeprecatedWarning
BeginIgnoreClangWarning(-Wdeprecated-implementations)

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

EndIgnoreClangWarning
EndIgnoreDeprecatedWarning

static char kAssociatedObjectKey_updatesIndicatorView;
- (void)setQmui_updatesIndicatorView:(UIView *)qmui_updatesIndicatorView {
    objc_setAssociatedObject(self, &kAssociatedObjectKey_updatesIndicatorView, qmui_updatesIndicatorView, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (_QMUIUpdatesIndicatorView *)qmui_updatesIndicatorView {
    return (_QMUIUpdatesIndicatorView *)objc_getAssociatedObject(self, &kAssociatedObjectKey_updatesIndicatorView);
}

- (void)setNeedsUpdateIndicatorLayout {
    if (self.qmui_shouldShowUpdatesIndicator) {
        [self setNeedsLayout];
    }
}

#pragma mark - Common

- (void)updateLayoutSubviewsBlockIfNeeded {
    if (!self.qmuibdg_layoutSubviewsBlock) {
        self.qmuibdg_layoutSubviewsBlock = ^(UIView *view) {
            [view qmuibdg_layoutSubviews];
        };
    }
    if (!self.qmui_layoutSubviewsBlock) {
        self.qmui_layoutSubviewsBlock = self.qmuibdg_layoutSubviewsBlock;
    } else if (self.qmui_layoutSubviewsBlock != self.qmuibdg_layoutSubviewsBlock) {
        void (^originalLayoutSubviewsBlock)(__kindof UIView *) = self.qmui_layoutSubviewsBlock;
        self.qmuibdg_layoutSubviewsBlock = ^(__kindof UIView *view) {
            originalLayoutSubviewsBlock(view);
            [view qmuibdg_layoutSubviews];
        };
        self.qmui_layoutSubviewsBlock = self.qmuibdg_layoutSubviewsBlock;
    }
}

- (UIView *)findBarButtonImageViewIfOffsetByTopRight:(BOOL)offsetByTopRight {
    NSString *classString = NSStringFromClass(self.class);
    if ([classString isEqualToString:@"UITabBarButton"]) {
        // 特别的，对于 UITabBarItem，将 imageView 作为参考 view
        UIView *imageView = [UITabBarItem qmui_imageViewInTabBarButton:self];
        return imageView;
    }
    
    // 如果使用 centerOffset 则不特殊处理 UIBarButtonItem，以保持与旧版的逻辑一致
    // TODO: molice 等废弃 qmui_badgeCenterOffset 系列接口后再删除
    if (!offsetByTopRight) return nil;
    
    if ([classString isEqualToString:@"_UIButtonBarButton"]) {
        for (UIView *subview in self.subviews) {
            if ([subview isKindOfClass:UIButton.class]) {
                UIView *imageView = ((UIButton *)subview).imageView;
                if (imageView && !imageView.hidden) {
                    return imageView;
                }
            }
        }
    }
    
    return nil;
}

- (void)qmuibdg_layoutSubviews {
    
    void (^layoutBlock)(UIView *view, UIView<_QMUIBadgeViewProtocol> *badgeView) = ^void(UIView *view, UIView<_QMUIBadgeViewProtocol> *badgeView) {
        BOOL offsetByTopRight = !CGPointEqualToPoint(badgeView.offset, QMUIBadgeInvalidateOffset) || !CGPointEqualToPoint(badgeView.offsetLandscape, QMUIBadgeInvalidateOffset);
        CGPoint offset = IS_LANDSCAPE ? (offsetByTopRight ? badgeView.offsetLandscape : badgeView.centerOffsetLandscape) : (offsetByTopRight ? badgeView.offset : badgeView.centerOffset);
        
        UIView *imageView = [view findBarButtonImageViewIfOffsetByTopRight:offsetByTopRight];
        if (imageView) {
            CGRect imageViewFrame = [view convertRect:imageView.frame fromView:imageView.superview];
            if (offsetByTopRight) {
                badgeView.frame = CGRectSetXY(badgeView.frame, CGRectGetMaxX(imageViewFrame) + offset.x, CGRectGetMinY(imageViewFrame) - CGRectGetHeight(badgeView.frame) + offset.y);
            } else {
                badgeView.center = CGPointMake(CGRectGetMidX(imageViewFrame) + offset.x, CGRectGetMidY(imageViewFrame) + offset.y);
            }
        } else {
            if (offsetByTopRight) {
                badgeView.frame = CGRectSetXY(badgeView.frame, CGRectGetWidth(view.bounds) + offset.x, - CGRectGetHeight(badgeView.frame) + offset.y);
            } else {
                badgeView.center = CGPointMake(CGRectGetMidX(view.bounds) + offset.x, CGRectGetMidY(view.bounds) + offset.y);
            }
        }
        [view bringSubviewToFront:badgeView];
    };
    
    if (self.qmui_updatesIndicatorView && !self.qmui_updatesIndicatorView.hidden) {
        layoutBlock(self, self.qmui_updatesIndicatorView);
    }
    if (self.qmui_badgeLabel && !self.qmui_badgeLabel.hidden) {
        [self.qmui_badgeLabel sizeToFit];
        self.qmui_badgeLabel.layer.cornerRadius = MIN(self.qmui_badgeLabel.qmui_height / 2, self.qmui_badgeLabel.qmui_width / 2);
        layoutBlock(self, self.qmui_badgeLabel);
    }
}

@end

@implementation _QMUIUpdatesIndicatorView

@synthesize offset = _offset, offsetLandscape = _offsetLandscape, centerOffset = _centerOffset, centerOffsetLandscape = _centerOffsetLandscape;

- (void)setOffset:(CGPoint)offset {
    _offset = offset;
    if (!IS_LANDSCAPE) {
        [self.superview setNeedsLayout];
    }
}

- (void)setOffsetLandscape:(CGPoint)offsetLandscape {
    _offsetLandscape = offsetLandscape;
    if (IS_LANDSCAPE) {
        [self.superview setNeedsLayout];
    }
}

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

@synthesize offset = _offset, offsetLandscape = _offsetLandscape, centerOffset = _centerOffset, centerOffsetLandscape = _centerOffsetLandscape;

- (void)setOffset:(CGPoint)offset {
    _offset = offset;
    if (!IS_LANDSCAPE) {
        [self.superview setNeedsLayout];
    }
}

- (void)setOffsetLandscape:(CGPoint)offsetLandscape {
    _offsetLandscape = offsetLandscape;
    if (IS_LANDSCAPE) {
        [self.superview setNeedsLayout];
    }
}

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
    result = CGSizeMake(MAX(result.width, result.height), result.height);
    return result;
}

@end
