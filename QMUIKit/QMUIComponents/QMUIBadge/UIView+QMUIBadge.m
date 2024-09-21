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
#import "QMUIBadgeLabel.h"

@interface UIView ()
@property(nullable, nonatomic, strong) void (^qmuibdg_layoutSubviewsBlock)(__kindof UIView *view);
@end

@implementation UIView (QMUIBadge)

QMUISynthesizeIdStrongProperty(qmuibdg_layoutSubviewsBlock, setQmuibdg_layoutSubviewsBlock)
QMUISynthesizeIdCopyProperty(qmui_badgeViewDidLayoutBlock, setQmui_badgeViewDidLayoutBlock)
QMUISynthesizeIdCopyProperty(qmui_updatesIndicatorViewDidLayoutBlock, setQmui_updatesIndicatorViewDidLayoutBlock)

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
        if (!self.qmui_badgeView) {
            QMUIBadgeLabel *badgeLabel = [[QMUIBadgeLabel alloc] init];
            badgeLabel.backgroundColor = self.qmui_badgeBackgroundColor;
            badgeLabel.textColor = self.qmui_badgeTextColor;
            badgeLabel.font = self.qmui_badgeFont;
            badgeLabel.contentEdgeInsets = self.qmui_badgeContentEdgeInsets;
            self.qmui_badgeView = badgeLabel;
        }
        if ([self.qmui_badgeView respondsToSelector:@selector(setText:)]) {
            ((UILabel *)self.qmui_badgeView).text = qmui_badgeString;
        }
        self.qmui_badgeView.hidden = NO;
        [self setNeedsUpdateBadgeLabelLayout];
        QMUIAssert(!self.clipsToBounds, @"QMUIBadge", @"clipsToBounds should be NO when showing badgeString");
        self.clipsToBounds = NO;
    } else {
        self.qmui_badgeView.hidden = YES;
    }
}

- (NSString *)qmui_badgeString {
    return (NSString *)objc_getAssociatedObject(self, &kAssociatedObjectKey_badgeString);
}

static char kAssociatedObjectKey_badgeBackgroundColor;
- (void)setQmui_badgeBackgroundColor:(UIColor *)qmui_badgeBackgroundColor {
    objc_setAssociatedObject(self, &kAssociatedObjectKey_badgeBackgroundColor, qmui_badgeBackgroundColor, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    self.qmui_badgeView.backgroundColor = qmui_badgeBackgroundColor;
}

- (UIColor *)qmui_badgeBackgroundColor {
    return (UIColor *)objc_getAssociatedObject(self, &kAssociatedObjectKey_badgeBackgroundColor);
}

static char kAssociatedObjectKey_badgeTextColor;
- (void)setQmui_badgeTextColor:(UIColor *)qmui_badgeTextColor {
    objc_setAssociatedObject(self, &kAssociatedObjectKey_badgeTextColor, qmui_badgeTextColor, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    if ([self.qmui_badgeView isKindOfClass:UILabel.class]) {
        ((UILabel *)self.qmui_badgeView).textColor = qmui_badgeTextColor;
    }
}

- (UIColor *)qmui_badgeTextColor {
    return (UIColor *)objc_getAssociatedObject(self, &kAssociatedObjectKey_badgeTextColor);
}

static char kAssociatedObjectKey_badgeFont;
- (void)setQmui_badgeFont:(UIFont *)qmui_badgeFont {
    objc_setAssociatedObject(self, &kAssociatedObjectKey_badgeFont, qmui_badgeFont, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    if ([self.qmui_badgeView isKindOfClass:UILabel.class]) {
        ((UILabel *)self.qmui_badgeView).font = qmui_badgeFont;
        [self setNeedsUpdateBadgeLabelLayout];
    }
}

- (UIFont *)qmui_badgeFont {
    return (UIFont *)objc_getAssociatedObject(self, &kAssociatedObjectKey_badgeFont);
}

static char kAssociatedObjectKey_badgeContentEdgeInsets;
- (void)setQmui_badgeContentEdgeInsets:(UIEdgeInsets)qmui_badgeContentEdgeInsets {
    objc_setAssociatedObject(self, &kAssociatedObjectKey_badgeContentEdgeInsets, [NSValue valueWithUIEdgeInsets:qmui_badgeContentEdgeInsets], OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    if ([self.qmui_badgeView isKindOfClass:QMUILabel.class]) {
        ((QMUILabel *)self.qmui_badgeView).contentEdgeInsets = qmui_badgeContentEdgeInsets;
        [self setNeedsUpdateBadgeLabelLayout];
    }
}

- (UIEdgeInsets)qmui_badgeContentEdgeInsets {
    return [((NSValue *)objc_getAssociatedObject(self, &kAssociatedObjectKey_badgeContentEdgeInsets)) UIEdgeInsetsValue];
}

static char kAssociatedObjectKey_badgeOffset;
- (void)setQmui_badgeOffset:(CGPoint)qmui_badgeOffset {
    objc_setAssociatedObject(self, &kAssociatedObjectKey_badgeOffset, @(qmui_badgeOffset), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    [self setNeedsUpdateBadgeLabelLayout];
}

- (CGPoint)qmui_badgeOffset {
    return [((NSNumber *)objc_getAssociatedObject(self, &kAssociatedObjectKey_badgeOffset)) CGPointValue];
}

static char kAssociatedObjectKey_badgeOffsetLandscape;
- (void)setQmui_badgeOffsetLandscape:(CGPoint)qmui_badgeOffsetLandscape {
    objc_setAssociatedObject(self, &kAssociatedObjectKey_badgeOffsetLandscape, @(qmui_badgeOffsetLandscape), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    [self setNeedsUpdateBadgeLabelLayout];
}

- (CGPoint)qmui_badgeOffsetLandscape {
    return [((NSNumber *)objc_getAssociatedObject(self, &kAssociatedObjectKey_badgeOffsetLandscape)) CGPointValue];
}

static char kAssociatedObjectKey_badgeView;
- (void)setQmui_badgeView:(UIView *)qmui_badgeView {
    objc_setAssociatedObject(self, &kAssociatedObjectKey_badgeView, qmui_badgeView, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    if (qmui_badgeView) {
        [self updateLayoutSubviewsBlockIfNeeded];
        [self addSubview:qmui_badgeView];
        [self setNeedsUpdateBadgeLabelLayout];
    }
}

- (__kindof UIView *)qmui_badgeView {
    return (UIView *)objc_getAssociatedObject(self, &kAssociatedObjectKey_badgeView);
}

- (void)setNeedsUpdateBadgeLabelLayout {
    if (self.qmui_badgeView && !self.qmui_badgeView.hidden) {
        [self qmuibdg_layoutSubviews];
    }
}

#pragma mark - UpdatesIndicator

static char kAssociatedObjectKey_shouldShowUpdatesIndicator;
- (void)setQmui_shouldShowUpdatesIndicator:(BOOL)qmui_shouldShowUpdatesIndicator {
    objc_setAssociatedObject(self, &kAssociatedObjectKey_shouldShowUpdatesIndicator, @(qmui_shouldShowUpdatesIndicator), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    if (qmui_shouldShowUpdatesIndicator) {
        if (!self.qmui_updatesIndicatorView) {
            self.qmui_updatesIndicatorView = [[UIView alloc] qmui_initWithSize:self.qmui_updatesIndicatorSize];
            self.qmui_updatesIndicatorView.layer.cornerRadius = CGRectGetHeight(self.qmui_updatesIndicatorView.bounds) / 2;
            self.qmui_updatesIndicatorView.backgroundColor = self.qmui_updatesIndicatorColor;
        }
        [self setNeedsUpdateIndicatorLayout];
        QMUIAssert(!self.clipsToBounds, @"QMUIBadge", @"clipsToBounds should be NO when showing updatesIndicator");
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
        [self setNeedsUpdateIndicatorLayout];
    }
}

- (CGPoint)qmui_updatesIndicatorOffsetLandscape {
    return [((NSNumber *)objc_getAssociatedObject(self, &kAssociatedObjectKey_updatesIndicatorOffsetLandscape)) CGPointValue];
}

static char kAssociatedObjectKey_updatesIndicatorView;
- (void)setQmui_updatesIndicatorView:(__kindof UIView *)qmui_updatesIndicatorView {
    objc_setAssociatedObject(self, &kAssociatedObjectKey_updatesIndicatorView, qmui_updatesIndicatorView, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    if (qmui_updatesIndicatorView) {
        [self updateLayoutSubviewsBlockIfNeeded];
        [self addSubview:qmui_updatesIndicatorView];
        [self setNeedsUpdateIndicatorLayout];
    }
}

- (__kindof UIView *)qmui_updatesIndicatorView {
    return (UIView *)objc_getAssociatedObject(self, &kAssociatedObjectKey_updatesIndicatorView);
}

- (void)setNeedsUpdateIndicatorLayout {
    if (self.qmui_shouldShowUpdatesIndicator) {
        [self qmuibdg_layoutSubviews];
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

// 不管 image 还是 text 的 UIBarButtonItem 都获取内部的 _UIModernBarButton 即可
- (UIView *)findBarButtonContentView {
    NSString *classString = NSStringFromClass(self.class);
    if ([classString isEqualToString:@"UITabBarButton"]) {
        // 特别的，对于 UITabBarItem，将 imageView 作为参考 view
        UIView *imageView = [UITabBarItem qmui_imageViewInTabBarButton:self];
        return imageView;
    }
    
    if ([classString isEqualToString:@"_UIButtonBarButton"]) {
        for (UIView *subview in self.subviews) {
            if ([subview isKindOfClass:UIButton.class]) {
                return subview;
            }
        }
    }
    
    return nil;
}

- (void)qmuibdg_layoutSubviews {
    
    void (^layoutBlock)(UIView *view, UIView *badgeView) = ^void(UIView *view, UIView *badgeView) {
        BeginIgnoreDeprecatedWarning
        CGPoint offset = badgeView == view.qmui_badgeView
            ? (IS_LANDSCAPE ? view.qmui_badgeOffsetLandscape : view.qmui_badgeOffset)
            : (IS_LANDSCAPE ? view.qmui_updatesIndicatorOffsetLandscape : view.qmui_updatesIndicatorOffset);
        EndIgnoreDeprecatedWarning
        
        UIView *contentView = [view findBarButtonContentView];
        if (contentView) {
            CGRect imageViewFrame = [view convertRect:contentView.frame fromView:contentView.superview];
            badgeView.frame = CGRectSetXY(badgeView.frame, CGRectGetMaxX(imageViewFrame) + offset.x, CGRectGetMinY(imageViewFrame) - CGRectGetHeight(badgeView.frame) + offset.y);
        } else {
            badgeView.frame = CGRectSetXY(badgeView.frame, CGRectGetWidth(view.bounds) + offset.x, - CGRectGetHeight(badgeView.frame) + offset.y);
        }
        [view bringSubviewToFront:badgeView];
    };
    
    if (self.qmui_updatesIndicatorView && !self.qmui_updatesIndicatorView.hidden) {
        layoutBlock(self, self.qmui_updatesIndicatorView);
        if (self.qmui_updatesIndicatorViewDidLayoutBlock) {
            self.qmui_updatesIndicatorViewDidLayoutBlock(self, self.qmui_updatesIndicatorView);
        }
    }
    if (self.qmui_badgeView && !self.qmui_badgeView.hidden) {
        [self.qmui_badgeView sizeToFit];
        layoutBlock(self, self.qmui_badgeView);
        if (self.qmui_badgeViewDidLayoutBlock) {
            self.qmui_badgeViewDidLayoutBlock(self, self.qmui_badgeView);
        }
    }
}

@end
