//
//  UIView+QMUI.m
//  qmui
//
//  Created by ZhoonChen on 15/7/20.
//  Copyright (c) 2015年 QMUI Team. All rights reserved.
//

#import "UIView+QMUI.h"
#import "QMUICommonDefines.h"
#import "QMUIConfiguration.h"
#import "QMUIHelper.h"
#import "CALayer+QMUI.h"
#import "UIColor+QMUI.h"

@interface UIView ()

/// QMUI_Debug
@property(nonatomic, assign, readwrite) BOOL hasDebugColor;
/// QMUI_Border
@property(nonatomic, strong, readwrite) CAShapeLayer *borderLayer;

@end


@implementation UIView (QMUI)

- (void)setWidth:(CGFloat)width height:(CGFloat)height {
    CGRect frame = self.frame;
    frame.size.height = height;
    frame.size.width = width;
    self.frame = frame;
}

- (void)setWidth:(CGFloat)width {
    CGRect frame = self.frame;
    frame.size.width = width;
    self.frame = frame;
}

- (void)setHeight:(CGFloat)height {
    CGRect frame = self.frame;
    frame.size.height = height;
    self.frame = frame;
}

- (void)setOriginX:(CGFloat)x y:(CGFloat)y {
    CGRect frame = self.frame;
    frame.origin.x = x;
    frame.origin.y = y;
    self.frame = frame;
}

- (void)setOriginX:(CGFloat)x {
    CGRect frame = self.frame;
    frame.origin.x = x;
    self.frame = frame;
}

- (void)setOriginY:(CGFloat)y {
    CGRect frame = self.frame;
    frame.origin.y = y;
    self.frame = frame;
}

- (CGFloat)minXWhenCenterInSuperview {
    return CGFloatGetCenter(CGRectGetWidth(self.superview.bounds), CGRectGetWidth(self.frame));
}

- (CGFloat)minYWhenCenterInSuperview {
    return CGFloatGetCenter(CGRectGetHeight(self.superview.bounds), CGRectGetHeight(self.frame));
}

- (void)removeAllSubviews {
    [self.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
}

@end


@implementation UIView (QMUI_Debug)

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        ReplaceMethod([self class], @selector(layoutSubviews), @selector(qmui_layoutSubviews));
        ReplaceMethod([self class], @selector(addSubview:), @selector(qmui_addSubview:));
    });
}

static char kAssociatedObjectKey_needsDifferentDebugColor;
- (void)setNeedsDifferentDebugColor:(BOOL)needsDifferentDebugColor {
    objc_setAssociatedObject(self, &kAssociatedObjectKey_needsDifferentDebugColor, @(needsDifferentDebugColor), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}
- (BOOL)needsDifferentDebugColor {
    BOOL flag = [objc_getAssociatedObject(self, &kAssociatedObjectKey_needsDifferentDebugColor) boolValue];
    return flag;
}

static char kAssociatedObjectKey_shouldShowDebugColor;
- (void)setShouldShowDebugColor:(BOOL)shouldShowDebugColor {
    objc_setAssociatedObject(self, &kAssociatedObjectKey_shouldShowDebugColor, @(shouldShowDebugColor), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}
- (BOOL)shouldShowDebugColor {
    BOOL flag = [objc_getAssociatedObject(self, &kAssociatedObjectKey_shouldShowDebugColor) boolValue];
    return flag;
}

static char kAssociatedObjectKey_hasDebugColor;
- (void)setHasDebugColor:(BOOL)hasDebugColor {
    objc_setAssociatedObject(self, &kAssociatedObjectKey_hasDebugColor, @(hasDebugColor), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}
- (BOOL)hasDebugColor {
    BOOL flag = [objc_getAssociatedObject(self, &kAssociatedObjectKey_hasDebugColor) boolValue];
    return flag;
}

- (void)qmui_layoutSubviews {
    [self qmui_layoutSubviews];
    if (self.shouldShowDebugColor) {
        self.hasDebugColor = YES;
        self.backgroundColor = [self debugColor];
        [self renderColorWithSubviews:self.subviews];
    }
}

- (void)renderColorWithSubviews:(NSArray *)subviews {
    for (UIView *view in subviews) {
        if ([view isKindOfClass:[UIStackView class]]) {
            UIStackView *stackView = (UIStackView *)view;
            [self renderColorWithSubviews:stackView.arrangedSubviews];
        }
        view.hasDebugColor = YES;
        view.shouldShowDebugColor = self.shouldShowDebugColor;
        view.needsDifferentDebugColor = self.needsDifferentDebugColor;
        view.backgroundColor = [self debugColor];
    }
}

- (UIColor *)debugColor {
    if (!self.needsDifferentDebugColor) {
        return UIColorTestRed;
    } else {
        return [[UIColor randomColor] colorWithAlphaComponent:.8];
    }
}

- (void)qmui_addSubview:(UIView *)view {
    if (view == self) {
        NSAssert(NO, @"把自己作为 subview 添加到自己身上！\n%@", [NSThread callStackSymbols]);
    }
    [self qmui_addSubview:view];
}

@end


@implementation UIView (QMUI_Border)

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        ReplaceMethod([self class], @selector(layoutSublayersOfLayer:), @selector(qmui_layoutSublayersOfLayer:));
    });
}

static char kAssociatedObjectKey_borderPosition;
- (void)setBorderPosition:(QMUIBorderViewPosition)borderPosition {
    objc_setAssociatedObject(self, &kAssociatedObjectKey_borderPosition, @(borderPosition), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    [self setNeedsLayout];
}

- (QMUIBorderViewPosition)borderPosition {
    return (QMUIBorderViewPosition)[objc_getAssociatedObject(self, &kAssociatedObjectKey_borderPosition) integerValue];
}

static char kAssociatedObjectKey_borderWidth;
- (void)setBorderWidth:(CGFloat)borderWidth {
    objc_setAssociatedObject(self, &kAssociatedObjectKey_borderWidth, @(borderWidth), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    [self setNeedsLayout];
}

- (CGFloat)borderWidth {
    return (CGFloat)[objc_getAssociatedObject(self, &kAssociatedObjectKey_borderWidth) floatValue];
}

static char kAssociatedObjectKey_borderColor;
- (void)setBorderColor:(UIColor *)borderColor {
    objc_setAssociatedObject(self, &kAssociatedObjectKey_borderColor, borderColor, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    [self setNeedsLayout];
}

- (UIColor *)borderColor {
    return (UIColor *)objc_getAssociatedObject(self, &kAssociatedObjectKey_borderColor);
}

static char kAssociatedObjectKey_dashPhase;
- (void)setDashPhase:(CGFloat)dashPhase {
    objc_setAssociatedObject(self, &kAssociatedObjectKey_dashPhase, @(dashPhase), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    [self setNeedsLayout];
}

- (CGFloat)dashPhase {
    return (CGFloat)[objc_getAssociatedObject(self, &kAssociatedObjectKey_dashPhase) floatValue];
}

static char kAssociatedObjectKey_dashPattern;
- (void)setDashPattern:(NSArray<NSNumber *> *)dashPattern {
    objc_setAssociatedObject(self, &kAssociatedObjectKey_dashPattern, dashPattern, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    [self setNeedsLayout];
}

- (NSArray *)dashPattern {
    return (NSArray *)objc_getAssociatedObject(self, &kAssociatedObjectKey_dashPattern);
}

static char kAssociatedObjectKey_borderLayer;
- (void)setBorderLayer:(CAShapeLayer *)borderLayer {
    objc_setAssociatedObject(self, &kAssociatedObjectKey_borderLayer, borderLayer, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (CAShapeLayer *)borderLayer {
    return (CAShapeLayer *)objc_getAssociatedObject(self, &kAssociatedObjectKey_borderLayer);
}

- (void)qmui_layoutSublayersOfLayer:(CALayer *)layer {
    
    [self qmui_layoutSublayersOfLayer:layer];
    
    if (self.borderPosition == QMUIBorderViewPositionNone) {
        return;
    }
    
    if (!self.borderLayer) {
        self.borderLayer = [CAShapeLayer layer];
        [self.borderLayer removeDefaultAnimations];
        [self.layer addSublayer:self.borderLayer];
        
        // 设置默认值
        self.dashPhase = self.dashPhase == 0 ? 0 : self.dashPhase;
        self.borderColor = self.borderColor ? self.borderColor : UIColorSeparator;
        self.borderWidth = self.borderWidth == 0 ? PixelOne : self.borderWidth;
    }
    self.borderLayer.frame = self.bounds;
    
    CGFloat borderWidth = self.borderWidth;
    self.borderLayer.lineWidth = borderWidth;
    self.borderLayer.strokeColor = self.borderColor.CGColor;
    self.borderLayer.lineDashPhase = self.dashPhase;
    if (self.dashPattern) {
        self.borderLayer.lineDashPattern = self.dashPattern;
    }
    
    UIBezierPath *path = [UIBezierPath bezierPath];
    
    if ((self.borderPosition & QMUIBorderViewPositionTop) == QMUIBorderViewPositionTop) {
        [path moveToPoint:CGPointMake(0, borderWidth / 2)];
        [path addLineToPoint:CGPointMake(CGRectGetWidth(self.bounds), borderWidth / 2)];
    }
    
    if ((self.borderPosition & QMUIBorderViewPositionLeft) == QMUIBorderViewPositionLeft) {
        [path moveToPoint:CGPointMake(borderWidth / 2, 0)];
        [path addLineToPoint:CGPointMake(borderWidth / 2, CGRectGetHeight(self.bounds) - 0)];
    }
    
    if ((self.borderPosition & QMUIBorderViewPositionBottom) == QMUIBorderViewPositionBottom) {
        [path moveToPoint:CGPointMake(0, CGRectGetHeight(self.bounds) - borderWidth / 2)];
        [path addLineToPoint:CGPointMake(CGRectGetWidth(self.bounds), CGRectGetHeight(self.bounds) - borderWidth / 2)];
    }
    
    if ((self.borderPosition & QMUIBorderViewPositionRight) == QMUIBorderViewPositionRight) {
        [path moveToPoint:CGPointMake(CGRectGetWidth(self.bounds) - borderWidth / 2, 0)];
        [path addLineToPoint:CGPointMake(CGRectGetWidth(self.bounds) - borderWidth / 2, CGRectGetHeight(self.bounds))];
    }
    
    self.borderLayer.path = path.CGPath;
}

@end
