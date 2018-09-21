//
//  CALayer+QMUI.m
//  qmui
//
//  Created by MoLice on 16/8/12.
//  Copyright © 2016年 QMUI Team. All rights reserved.
//

#import "CALayer+QMUI.h"
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
            @selector(setPosition:)
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

- (instancetype)qmui_init {
    [self qmui_init];
    self.qmui_speedBeforePause = self.speed;
    return self;
}

- (void)qmui_setBounds:(CGRect)bounds {
    // 对非法的 bounds，Debug 下中 assert，Release 下会将其中的 NaN 改为 0，避免 crash
    if (CGRectIsNaN(bounds)) {
        QMUILog(@"CALayer (QMUI)", @"%@ setBounds:%@，参数包含 NaN，已被拦截并处理为 0。%@", self, NSStringFromCGRect(bounds), [NSThread callStackSymbols]);
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
        QMUILog(@"CALayer (QMUI)", @"%@ setPosition:%@，参数包含 NaN，已被拦截并处理为 0。%@", self, NSStringFromCGPoint(position), [NSThread callStackSymbols]);
        NSAssert(NO, @"CALayer setPosition: 出现 NaN");
        if (!IS_DEBUG) {
            position = CGPointMake(CGFloatSafeValue(position.x), CGFloatSafeValue(position.y));
        }
    }
    [self qmui_setPosition:position];
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

@end
