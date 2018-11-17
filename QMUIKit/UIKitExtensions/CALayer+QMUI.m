//
//  CALayer+QMUI.m
//  qmui
//
//  Created by MoLice on 16/8/12.
//  Copyright © 2016年 QMUI Team. All rights reserved.
//

#import "CALayer+QMUI.h"
#import "UIView+QMUI.h"
#import "QMUICore.h"
#import "QMUILog.h"

@interface CALayer ()

@property(nonatomic, assign) float qmui_speedBeforePause;

@end

@implementation CALayer (QMUI)

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        SEL selectors[] = {
            @selector(init),
            @selector(setBounds:),
            @selector(setPosition:),
            @selector(setCornerRadius:)
        };
        for (NSUInteger index = 0; index < sizeof(selectors) / sizeof(SEL); index++) {
            SEL originalSelector = selectors[index];
            SEL swizzledSelector = NSSelectorFromString([@"qmui_" stringByAppendingString:NSStringFromSelector(originalSelector)]);
            ExchangeImplementations([self class], originalSelector, swizzledSelector);
        }
    });
}

static char kAssociatedObjectKey_speedBeforePause;
- (void)setQmui_speedBeforePause:(float)qmui_speedBeforePause {
    objc_setAssociatedObject(self, &kAssociatedObjectKey_speedBeforePause, @(qmui_speedBeforePause), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (float)qmui_speedBeforePause {
    return [((NSNumber *)objc_getAssociatedObject(self, &kAssociatedObjectKey_speedBeforePause)) floatValue];
}

static char kAssociatedObjectKey_cornerRadius;
- (void)setQmui_originCornerRadius:(CGFloat)qmui_originCornerRadius {
    objc_setAssociatedObject(self, &kAssociatedObjectKey_cornerRadius, @(qmui_originCornerRadius), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (CGFloat)qmui_originCornerRadius {
    return [((NSNumber *)objc_getAssociatedObject(self, &kAssociatedObjectKey_cornerRadius)) floatValue];
}

static char kAssociatedObjectKey_pause;
- (void)setQmui_pause:(BOOL)qmui_pause {
    if (qmui_pause == self.qmui_pause) {
        return;
    }
    if (qmui_pause) {
        self.qmui_speedBeforePause = self.speed;
        CFTimeInterval pausedTime = [self convertTime:CACurrentMediaTime() fromLayer:nil];
        self.speed = 0;
        self.timeOffset = pausedTime;
    } else {
        CFTimeInterval pausedTime = self.timeOffset;
        self.speed = self.qmui_speedBeforePause;
        self.timeOffset = 0;
        self.beginTime = 0;
        CFTimeInterval timeSincePause = [self convertTime:CACurrentMediaTime() fromLayer:nil] - pausedTime;
        self.beginTime = timeSincePause;
    }
    objc_setAssociatedObject(self, &kAssociatedObjectKey_pause, @(qmui_pause), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (BOOL)qmui_pause {
    return [((NSNumber *)objc_getAssociatedObject(self, &kAssociatedObjectKey_pause)) boolValue];
}

static char kAssociatedObjectKey_maskedCorners;
- (void)setQmui_maskedCorners:(QMUICornerMask)qmui_maskedCorners {
    BOOL maskedCornersChanged = qmui_maskedCorners != self.qmui_maskedCorners;
    objc_setAssociatedObject(self, &kAssociatedObjectKey_maskedCorners, @(qmui_maskedCorners), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    if (@available(iOS 11, *)) {
        self.maskedCorners = (CACornerMask)qmui_maskedCorners;
    } else {
        if (qmui_maskedCorners && ![self hasFourCornerRadius]) {
            [self qmui_setCornerRadius:0];
        }
        if (maskedCornersChanged) {
            // 需要刷新mask
            if ([NSThread isMainThread]) {
                [self setNeedsLayout];
            } else {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self setNeedsLayout];
                });
            }
        }
    }
    if (maskedCornersChanged) {
        // 需要刷新border
        if ([self.delegate respondsToSelector:@selector(layoutSublayersOfLayer:)]) {
            UIView *view = (UIView *)self.delegate;
            if (view.qmui_borderPosition > 0 && view.qmui_borderWidth > 0) {
                [view layoutSublayersOfLayer:self];
            }
        }
    }
}

- (QMUICornerMask)qmui_maskedCorners {
    return [objc_getAssociatedObject(self, &kAssociatedObjectKey_maskedCorners) unsignedIntegerValue];
} 

- (instancetype)qmui_init {
    [self qmui_init];
    self.qmui_speedBeforePause = self.speed;
    self.qmui_maskedCorners = QMUILayerMinXMinYCorner|QMUILayerMaxXMinYCorner|QMUILayerMinXMaxYCorner|QMUILayerMaxXMaxYCorner;
    return self;
}

- (void)qmui_setBounds:(CGRect)bounds {
    // 对非法的 bounds，Debug 下中 assert，Release 下会将其中的 NaN 改为 0，避免 crash
    if (CGRectIsNaN(bounds)) {
        QMUILogWarn(@"CALayer (QMUI)", @"%@ setBounds:%@，参数包含 NaN，已被拦截并处理为 0。%@", self, NSStringFromCGRect(bounds), [NSThread callStackSymbols]);
        NSAssert(NO, @"CALayer setBounds: 出现 NaN");
        if (!IS_DEBUG) {
            bounds = CGRectSafeValue(bounds);
        }
    }
    [self qmui_setBounds:bounds];
}

- (void)qmui_setPosition:(CGPoint)position {
    // 对非法的 position，Debug 下中 assert，Release 下会将其中的 NaN 改为 0，避免 crash
    if (isnan(position.x) || isnan(position.y)) {
        QMUILogWarn(@"CALayer (QMUI)", @"%@ setPosition:%@，参数包含 NaN，已被拦截并处理为 0。%@", self, NSStringFromCGPoint(position), [NSThread callStackSymbols]);
        NSAssert(NO, @"CALayer setPosition: 出现 NaN");
        if (!IS_DEBUG) {
            position = CGPointMake(CGFloatSafeValue(position.x), CGFloatSafeValue(position.y));
        }
    }
    [self qmui_setPosition:position];
}

- (void)qmui_setCornerRadius:(CGFloat)cornerRadius {
    BOOL cornerRadiusChanged = flat(self.qmui_originCornerRadius) != flat(cornerRadius);
    self.qmui_originCornerRadius = cornerRadius;
    if (@available(iOS 11, *)) {
        [self qmui_setCornerRadius:cornerRadius];
    } else {
        if (self.qmui_maskedCorners && ![self hasFourCornerRadius]) {
            [self qmui_setCornerRadius:0];
        } else {
            [self qmui_setCornerRadius:cornerRadius];
        }
        if (cornerRadiusChanged) {
            // 需要刷新mask
            [self setNeedsLayout];
        }
    }
    if (cornerRadiusChanged) {
        // 需要刷新border
        if ([self.delegate respondsToSelector:@selector(layoutSublayersOfLayer:)]) {
            UIView *view = (UIView *)self.delegate;
            if (view.qmui_borderPosition > 0 && view.qmui_borderWidth > 0) {
                [view layoutSublayersOfLayer:self];
            }
        }
    }
}

- (void)qmui_sendSublayerToBack:(CALayer *)sublayer {
    if (sublayer.superlayer == self) {
        [sublayer removeFromSuperlayer];
        [self insertSublayer:sublayer atIndex:0];
    }
}

- (void)qmui_bringSublayerToFront:(CALayer *)sublayer {
    if (sublayer.superlayer == self) {
        [sublayer removeFromSuperlayer];
        [self insertSublayer:sublayer atIndex:(unsigned)self.sublayers.count];
    }
}

- (void)qmui_removeDefaultAnimations {
    NSMutableDictionary<NSString *, id<CAAction>> *actions = @{NSStringFromSelector(@selector(bounds)): [NSNull null],
                                                               NSStringFromSelector(@selector(position)): [NSNull null],
                                                               NSStringFromSelector(@selector(zPosition)): [NSNull null],
                                                               NSStringFromSelector(@selector(anchorPoint)): [NSNull null],
                                                               NSStringFromSelector(@selector(anchorPointZ)): [NSNull null],
                                                               NSStringFromSelector(@selector(transform)): [NSNull null],
                                                               BeginIgnoreClangWarning(-Wundeclared-selector)
                                                               NSStringFromSelector(@selector(hidden)): [NSNull null],
                                                               NSStringFromSelector(@selector(doubleSided)): [NSNull null],
                                                               EndIgnoreClangWarning
                                                               NSStringFromSelector(@selector(sublayerTransform)): [NSNull null],
                                                               NSStringFromSelector(@selector(masksToBounds)): [NSNull null],
                                                               NSStringFromSelector(@selector(contents)): [NSNull null],
                                                               NSStringFromSelector(@selector(contentsRect)): [NSNull null],
                                                               NSStringFromSelector(@selector(contentsScale)): [NSNull null],
                                                               NSStringFromSelector(@selector(contentsCenter)): [NSNull null],
                                                               NSStringFromSelector(@selector(minificationFilterBias)): [NSNull null],
                                                               NSStringFromSelector(@selector(backgroundColor)): [NSNull null],
                                                               NSStringFromSelector(@selector(cornerRadius)): [NSNull null],
                                                               NSStringFromSelector(@selector(borderWidth)): [NSNull null],
                                                               NSStringFromSelector(@selector(borderColor)): [NSNull null],
                                                               NSStringFromSelector(@selector(opacity)): [NSNull null],
                                                               NSStringFromSelector(@selector(compositingFilter)): [NSNull null],
                                                               NSStringFromSelector(@selector(filters)): [NSNull null],
                                                               NSStringFromSelector(@selector(backgroundFilters)): [NSNull null],
                                                               NSStringFromSelector(@selector(shouldRasterize)): [NSNull null],
                                                               NSStringFromSelector(@selector(rasterizationScale)): [NSNull null],
                                                               NSStringFromSelector(@selector(shadowColor)): [NSNull null],
                                                               NSStringFromSelector(@selector(shadowOpacity)): [NSNull null],
                                                               NSStringFromSelector(@selector(shadowOffset)): [NSNull null],
                                                               NSStringFromSelector(@selector(shadowRadius)): [NSNull null],
                                                               NSStringFromSelector(@selector(shadowPath)): [NSNull null]}.mutableCopy;
    
    if ([self isKindOfClass:[CAShapeLayer class]]) {
        [actions addEntriesFromDictionary:@{NSStringFromSelector(@selector(path)): [NSNull null],
                                            NSStringFromSelector(@selector(fillColor)): [NSNull null],
                                            NSStringFromSelector(@selector(strokeColor)): [NSNull null],
                                            NSStringFromSelector(@selector(strokeStart)): [NSNull null],
                                            NSStringFromSelector(@selector(strokeEnd)): [NSNull null],
                                            NSStringFromSelector(@selector(lineWidth)): [NSNull null],
                                            NSStringFromSelector(@selector(miterLimit)): [NSNull null],
                                            NSStringFromSelector(@selector(lineDashPhase)): [NSNull null]}];
    }
    
    if ([self isKindOfClass:[CAGradientLayer class]]) {
        [actions addEntriesFromDictionary:@{NSStringFromSelector(@selector(colors)): [NSNull null],
                                            NSStringFromSelector(@selector(locations)): [NSNull null],
                                            NSStringFromSelector(@selector(startPoint)): [NSNull null],
                                            NSStringFromSelector(@selector(endPoint)): [NSNull null]}];
    }
    
    self.actions = actions;
}

+ (CAShapeLayer *)qmui_separatorDashLayerWithLineLength:(NSInteger)lineLength
                                            lineSpacing:(NSInteger)lineSpacing
                                              lineWidth:(CGFloat)lineWidth
                                              lineColor:(CGColorRef)lineColor
                                           isHorizontal:(BOOL)isHorizontal {
    CAShapeLayer *layer = [CAShapeLayer layer];
    layer.fillColor = UIColorClear.CGColor;
    layer.strokeColor = lineColor;
    layer.lineWidth = lineWidth;
    layer.lineDashPattern = [NSArray arrayWithObjects:[NSNumber numberWithInteger:lineLength], [NSNumber numberWithInteger:lineSpacing], nil];
    layer.masksToBounds = YES;
    
    CGMutablePathRef path = CGPathCreateMutable();
    if (isHorizontal) {
        CGPathMoveToPoint(path, NULL, 0, lineWidth / 2);
        CGPathAddLineToPoint(path, NULL, SCREEN_WIDTH, lineWidth / 2);
    } else {
        CGPathMoveToPoint(path, NULL, lineWidth / 2, 0);
        CGPathAddLineToPoint(path, NULL, lineWidth / 2, SCREEN_HEIGHT);
    }
    layer.path = path;
    CGPathRelease(path);
    
    return layer;
}

+ (CAShapeLayer *)qmui_separatorDashLayerInHorizontal {
    CAShapeLayer *layer = [CAShapeLayer qmui_separatorDashLayerWithLineLength:2 lineSpacing:2 lineWidth:PixelOne lineColor:UIColorSeparatorDashed.CGColor isHorizontal:YES];
    return layer;
}

+ (CAShapeLayer *)qmui_separatorDashLayerInVertical {
    CAShapeLayer *layer = [CAShapeLayer qmui_separatorDashLayerWithLineLength:2 lineSpacing:2 lineWidth:PixelOne lineColor:UIColorSeparatorDashed.CGColor isHorizontal:NO];
    return layer;
}

+ (CALayer *)qmui_separatorLayer {
    CALayer *layer = [CALayer layer];
    [layer qmui_removeDefaultAnimations];
    layer.backgroundColor = UIColorSeparator.CGColor;
    layer.frame = CGRectMake(0, 0, 0, PixelOne);
    return layer;
}

+ (CALayer *)qmui_separatorLayerForTableView {
    CALayer *layer = [self qmui_separatorLayer];
    layer.backgroundColor = TableViewSeparatorColor.CGColor;
    return layer;
}

- (BOOL)hasFourCornerRadius {
    return (self.qmui_maskedCorners & QMUILayerMinXMinYCorner) == QMUILayerMinXMinYCorner &&
           (self.qmui_maskedCorners & QMUILayerMaxXMinYCorner) == QMUILayerMaxXMinYCorner &&
           (self.qmui_maskedCorners & QMUILayerMinXMaxYCorner) == QMUILayerMinXMaxYCorner &&
           (self.qmui_maskedCorners & QMUILayerMaxXMaxYCorner) == QMUILayerMaxXMaxYCorner;
}

@end

@interface UIView (QMUI_CornerRadius)

@end

@implementation UIView (QMUI_CornerRadius)

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        ExchangeImplementations([self class], @selector(layoutSublayersOfLayer:), @selector(QMUICornerRadius_layoutSublayersOfLayer:));
    });
}

static NSString *kMaskName = @"QMUI_CornerRadius_Mask";

- (void)QMUICornerRadius_layoutSublayersOfLayer:(CALayer *)layer {
    [self QMUICornerRadius_layoutSublayersOfLayer:layer];
    if (@available(iOS 11, *)) {
    } else {
        if (self.layer.mask && ![self.layer.mask.name isEqualToString:kMaskName]) {
            return;
        }
        if (self.layer.qmui_maskedCorners) {
            if (self.layer.qmui_originCornerRadius <= 0 || [self hasFourCornerRadius]) {
                if (self.layer.mask) {
                    self.layer.mask = nil;
                }
            } else {
                CAShapeLayer *cornerMaskLayer = [CAShapeLayer layer];
                cornerMaskLayer.name = kMaskName;
                UIRectCorner rectCorner = 0;
                if ((self.layer.qmui_maskedCorners & QMUILayerMinXMinYCorner) == QMUILayerMinXMinYCorner) {
                    rectCorner |= UIRectCornerTopLeft;
                }
                if ((self.layer.qmui_maskedCorners & QMUILayerMaxXMinYCorner) == QMUILayerMaxXMinYCorner) {
                    rectCorner |= UIRectCornerTopRight;
                }
                if ((self.layer.qmui_maskedCorners & QMUILayerMinXMaxYCorner) == QMUILayerMinXMaxYCorner) {
                    rectCorner |= UIRectCornerBottomLeft;
                }
                if ((self.layer.qmui_maskedCorners & QMUILayerMaxXMaxYCorner) == QMUILayerMaxXMaxYCorner) {
                    rectCorner |= UIRectCornerBottomRight;
                }
                UIBezierPath *path = [UIBezierPath bezierPathWithRoundedRect:self.bounds byRoundingCorners:rectCorner cornerRadii:CGSizeMake(self.layer.qmui_originCornerRadius, self.layer.qmui_originCornerRadius)];
                cornerMaskLayer.frame = self.bounds;
                cornerMaskLayer.path = path.CGPath;
                self.layer.mask = cornerMaskLayer;
            }
        }
    }
}
                
- (BOOL)hasFourCornerRadius {
    return (self.layer.qmui_maskedCorners & QMUILayerMinXMinYCorner) == QMUILayerMinXMinYCorner &&
           (self.layer.qmui_maskedCorners & QMUILayerMaxXMinYCorner) == QMUILayerMaxXMinYCorner &&
           (self.layer.qmui_maskedCorners & QMUILayerMinXMaxYCorner) == QMUILayerMinXMaxYCorner &&
           (self.layer.qmui_maskedCorners & QMUILayerMaxXMaxYCorner) == QMUILayerMaxXMaxYCorner;
}

@end
