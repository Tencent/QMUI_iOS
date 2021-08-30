/**
 * Tencent is pleased to support the open source community by making QMUI_iOS available.
 * Copyright (C) 2016-2021 THL A29 Limited, a Tencent company. All rights reserved.
 * Licensed under the MIT License (the "License"); you may not use this file except in compliance with the License. You may obtain a copy of the License at
 * http://opensource.org/licenses/MIT
 * Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.
 */

//
//  UIView+QMUIBorder.m
//  QMUIKit
//
//  Created by MoLice on 2020/6/28.
//

#import "UIView+QMUIBorder.h"
#import "QMUICore.h"
#import "CALayer+QMUI.h"

@interface QMUIBorderLayer : CAShapeLayer

@property(nonatomic, weak) UIView *_qmuibd_targetBorderView;
@end

@implementation UIView (QMUIBorder)

QMUISynthesizeIdStrongProperty(qmui_borderLayer, setQmui_borderLayer)

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        ExtendImplementationOfNonVoidMethodWithSingleArgument([UIView class], @selector(initWithFrame:), CGRect, UIView *, ^UIView *(UIView *selfObject, CGRect frame, UIView *originReturnValue) {
            [selfObject _qmuibd_setDefaultStyle];
            return originReturnValue;
        });
        
        ExtendImplementationOfNonVoidMethodWithSingleArgument([UIView class], @selector(initWithCoder:), NSCoder *, UIView *, ^UIView *(UIView *selfObject, NSCoder *aDecoder, UIView *originReturnValue) {
            [selfObject _qmuibd_setDefaultStyle];
            return originReturnValue;
        });
    });
}

- (void)_qmuibd_setDefaultStyle {
    self.qmui_borderWidth = PixelOne;
    self.qmui_borderColor = UIColorSeparator;
}

- (void)_qmuibd_createBorderLayerIfNeeded {
    BOOL shouldShowBorder = self.qmui_borderWidth > 0 && self.qmui_borderColor && self.qmui_borderPosition != QMUIViewBorderPositionNone;
    if (!shouldShowBorder) {
        self.qmui_borderLayer.hidden = YES;
        return;
    }
    
    [QMUIHelper executeBlock:^{
        OverrideImplementation([UIView class], @selector(layoutSublayersOfLayer:), ^id(__unsafe_unretained Class originClass, SEL originCMD, IMP (^originalIMPProvider)(void)) {
            return ^(UIView *selfObject, CALayer *firstArgv) {
                
                // call super
                void (*originSelectorIMP)(id, SEL, CALayer *);
                originSelectorIMP = (void (*)(id, SEL, CALayer *))originalIMPProvider();
                originSelectorIMP(selfObject, originCMD, firstArgv);
                
                if (!selfObject.qmui_borderLayer || selfObject.qmui_borderLayer.hidden) return;
                selfObject.qmui_borderLayer.frame = selfObject.bounds;
                [selfObject.layer qmui_bringSublayerToFront:selfObject.qmui_borderLayer];
                [selfObject.qmui_borderLayer setNeedsLayout];// 把布局刷新逻辑剥离到 layer 内，方便在子线程里直接刷新 layer，如果放在 UIView 内，子线程里就无法主动请求刷新了
            };
        });
    } oncePerIdentifier:@"UIView (QMUIBorder) layoutSublayers"];
    
    if (!self.qmui_borderLayer) {
        QMUIBorderLayer *layer = [QMUIBorderLayer layer];
        layer._qmuibd_targetBorderView = self;
        [layer qmui_removeDefaultAnimations];
        layer.fillColor = UIColorClear.CGColor;
        [self.layer addSublayer:layer];
        self.qmui_borderLayer = layer;
    }
    self.qmui_borderLayer.lineWidth = self.qmui_borderWidth;
    self.qmui_borderLayer.strokeColor = self.qmui_borderColor.CGColor;
    self.qmui_borderLayer.lineDashPhase = self.qmui_dashPhase;
    self.qmui_borderLayer.lineDashPattern = self.qmui_dashPattern;
    self.qmui_borderLayer.hidden = NO;
}

static char kAssociatedObjectKey_borderLocation;
- (void)setQmui_borderLocation:(QMUIViewBorderLocation)qmui_borderLocation {
    BOOL valueChanged = self.qmui_borderLocation != qmui_borderLocation;
    objc_setAssociatedObject(self, &kAssociatedObjectKey_borderLocation, @(qmui_borderLocation), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    [self _qmuibd_createBorderLayerIfNeeded];
    if (valueChanged && self.qmui_borderLayer && !self.qmui_borderLayer.hidden) {
        [self setNeedsLayout];
    }
}

- (QMUIViewBorderLocation)qmui_borderLocation {
    return [((NSNumber *)objc_getAssociatedObject(self, &kAssociatedObjectKey_borderLocation)) unsignedIntegerValue];
}

static char kAssociatedObjectKey_borderPosition;
- (void)setQmui_borderPosition:(QMUIViewBorderPosition)qmui_borderPosition {
    BOOL valueChanged = self.qmui_borderPosition != qmui_borderPosition;
    objc_setAssociatedObject(self, &kAssociatedObjectKey_borderPosition, @(qmui_borderPosition), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    [self _qmuibd_createBorderLayerIfNeeded];
    if (valueChanged && self.qmui_borderLayer && !self.qmui_borderLayer.hidden) {
        [self setNeedsLayout];
    }
}

- (QMUIViewBorderPosition)qmui_borderPosition {
    return (QMUIViewBorderPosition)[objc_getAssociatedObject(self, &kAssociatedObjectKey_borderPosition) unsignedIntegerValue];
}

static char kAssociatedObjectKey_borderWidth;
- (void)setQmui_borderWidth:(CGFloat)qmui_borderWidth {
    BOOL valueChanged = self.qmui_borderWidth != qmui_borderWidth;
    objc_setAssociatedObject(self, &kAssociatedObjectKey_borderWidth, @(qmui_borderWidth), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    [self _qmuibd_createBorderLayerIfNeeded];
    if (valueChanged && self.qmui_borderLayer && !self.qmui_borderLayer.hidden) {
        [self setNeedsLayout];
    }
}

- (CGFloat)qmui_borderWidth {
    return [((NSNumber *)objc_getAssociatedObject(self, &kAssociatedObjectKey_borderWidth)) qmui_CGFloatValue];
}

static char kAssociatedObjectKey_borderInsets;
- (void)setQmui_borderInsets:(UIEdgeInsets)qmui_borderInsets {
    BOOL valueChanged = !UIEdgeInsetsEqualToEdgeInsets(self.qmui_borderInsets, qmui_borderInsets);
    objc_setAssociatedObject(self, &kAssociatedObjectKey_borderInsets, @(qmui_borderInsets), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    [self _qmuibd_createBorderLayerIfNeeded];
    if (valueChanged && self.qmui_borderLayer && !self.qmui_borderLayer.hidden) {
        [self setNeedsLayout];
    }
}

- (UIEdgeInsets)qmui_borderInsets {
    return [((NSNumber *)objc_getAssociatedObject(self, &kAssociatedObjectKey_borderInsets)) UIEdgeInsetsValue];
}

static char kAssociatedObjectKey_borderColor;
- (void)setQmui_borderColor:(UIColor *)qmui_borderColor {
    objc_setAssociatedObject(self, &kAssociatedObjectKey_borderColor, qmui_borderColor, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    [self _qmuibd_createBorderLayerIfNeeded];
    if (self.qmui_borderLayer && !self.qmui_borderLayer.hidden) {
        [self setNeedsLayout];
    }
}

- (UIColor *)qmui_borderColor {
    return (UIColor *)objc_getAssociatedObject(self, &kAssociatedObjectKey_borderColor);
}

static char kAssociatedObjectKey_dashPhase;
- (void)setQmui_dashPhase:(CGFloat)qmui_dashPhase {
    BOOL valueChanged = self.qmui_dashPhase != qmui_dashPhase;
    objc_setAssociatedObject(self, &kAssociatedObjectKey_dashPhase, @(qmui_dashPhase), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    [self _qmuibd_createBorderLayerIfNeeded];
    if (valueChanged && self.qmui_borderLayer && !self.qmui_borderLayer.hidden) {
        [self setNeedsLayout];
    }
}

- (CGFloat)qmui_dashPhase {
    return [(NSNumber *)objc_getAssociatedObject(self, &kAssociatedObjectKey_dashPhase) qmui_CGFloatValue];
}

static char kAssociatedObjectKey_dashPattern;
- (void)setQmui_dashPattern:(NSArray<NSNumber *> *)qmui_dashPattern {
    BOOL valueChanged = [self.qmui_dashPattern isEqualToArray:qmui_dashPattern];
    objc_setAssociatedObject(self, &kAssociatedObjectKey_dashPattern, qmui_dashPattern, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    [self _qmuibd_createBorderLayerIfNeeded];
    if (valueChanged && self.qmui_borderLayer && !self.qmui_borderLayer.hidden) {
        [self setNeedsLayout];
    }
}

- (NSArray *)qmui_dashPattern {
    return (NSArray<NSNumber *> *)objc_getAssociatedObject(self, &kAssociatedObjectKey_dashPattern);
}

@end

@implementation QMUIBorderLayer

- (void)layoutSublayers {
    [super layoutSublayers];
    if (!self._qmuibd_targetBorderView) return;
    
    UIView *view = self._qmuibd_targetBorderView;
    CGFloat borderWidth = self.lineWidth;
    UIEdgeInsets borderInsets = view.qmui_borderInsets;
    
    UIBezierPath *path = [UIBezierPath bezierPath];;
    
    CGFloat (^adjustsLocation)(CGFloat, CGFloat, CGFloat) = ^CGFloat(CGFloat inside, CGFloat center, CGFloat outside) {
        return view.qmui_borderLocation == QMUIViewBorderLocationInside ? inside : (view.qmui_borderLocation == QMUIViewBorderLocationCenter ? center : outside);
    };
    
    CGFloat lineOffset = adjustsLocation(borderWidth / 2.0, 0, -borderWidth / 2.0); // 为了像素对齐而做的偏移
    CGFloat lineCapOffset = adjustsLocation(0, borderWidth / 2.0, borderWidth); // 两条相邻的边框连接的位置
    CGFloat verticalInset = borderInsets.top - borderInsets.bottom;
    
    BOOL shouldShowTopBorder = (view.qmui_borderPosition & QMUIViewBorderPositionTop) == QMUIViewBorderPositionTop;
    BOOL shouldShowLeftBorder = (view.qmui_borderPosition & QMUIViewBorderPositionLeft) == QMUIViewBorderPositionLeft;
    BOOL shouldShowBottomBorder = (view.qmui_borderPosition & QMUIViewBorderPositionBottom) == QMUIViewBorderPositionBottom;
    BOOL shouldShowRightBorder = (view.qmui_borderPosition & QMUIViewBorderPositionRight) == QMUIViewBorderPositionRight;
    
    NSDictionary<NSString *, NSArray<NSValue *> *> *points = @{
        @"toppath": @[
                [NSValue valueWithCGPoint:CGPointMake(
                                                      (shouldShowLeftBorder ? (-lineCapOffset + verticalInset) : 0) + borderInsets.left,
                                                      lineOffset + verticalInset
                                                      )],
                [NSValue valueWithCGPoint:CGPointMake(
                                                      CGRectGetWidth(self.bounds) + (shouldShowRightBorder ? (lineCapOffset - verticalInset) : 0) - borderInsets.right,
                                                      lineOffset + verticalInset
                                                      )],
        ],
        @"leftpath": @[
                [NSValue valueWithCGPoint:CGPointMake(
                                                      lineOffset + verticalInset,
                                                      CGRectGetHeight(self.bounds) + (shouldShowBottomBorder ? lineCapOffset - verticalInset : 0) - borderInsets.left
                                                      )],
                [NSValue valueWithCGPoint:CGPointMake(
                                                      lineOffset + verticalInset,
                                                      (shouldShowTopBorder ? -lineCapOffset + verticalInset : 0) + borderInsets.right
                                                      )],
        ],
        @"bottompath": @[
                [NSValue valueWithCGPoint:CGPointMake(
                                                      CGRectGetWidth(self.bounds) + (shouldShowRightBorder ? (lineCapOffset - verticalInset) : 0) - borderInsets.left,
                                                      CGRectGetHeight(self.bounds) - lineOffset - verticalInset
                                                      )],
                [NSValue valueWithCGPoint:CGPointMake(
                                                      (shouldShowLeftBorder ? (-lineCapOffset + verticalInset) : 0) + borderInsets.right,
                                                      CGRectGetHeight(self.bounds) - lineOffset - verticalInset
                                                      )],
        ],
        @"rightpath": @[
                [NSValue valueWithCGPoint:CGPointMake(
                                                      CGRectGetWidth(self.bounds) - lineOffset - verticalInset,
                                                      (shouldShowTopBorder ? -lineCapOffset + verticalInset : 0) + borderInsets.left
                                                      )],
                [NSValue valueWithCGPoint:CGPointMake(
                                                      CGRectGetWidth(self.bounds) - lineOffset - verticalInset,
                                                      CGRectGetHeight(self.bounds) + (shouldShowBottomBorder ? lineCapOffset - verticalInset : 0) - borderInsets.right
                                                      )],
        ],
    };
    
    UIBezierPath *topPath = [UIBezierPath bezierPath];
    UIBezierPath *leftPath = [UIBezierPath bezierPath];
    UIBezierPath *bottomPath = [UIBezierPath bezierPath];
    UIBezierPath *rightPath = [UIBezierPath bezierPath];
    
    if (view.layer.qmui_originCornerRadius > 0) {
        
        CGFloat cornerRadius = view.layer.qmui_originCornerRadius;
        CGFloat radius = cornerRadius - lineOffset;
        
        if (view.layer.qmui_maskedCorners) {
            if ((view.layer.qmui_maskedCorners & QMUILayerMinXMinYCorner) == QMUILayerMinXMinYCorner) {
                [topPath addArcWithCenter:CGPointMake(cornerRadius + borderInsets.left + (shouldShowLeftBorder ? verticalInset : 0), cornerRadius + verticalInset) radius:radius startAngle:1.25 * M_PI endAngle:1.5 * M_PI clockwise:YES];
                [topPath addLineToPoint:CGPointMake(CGRectGetWidth(self.bounds) - cornerRadius - borderInsets.right - (shouldShowRightBorder ? verticalInset : 0), lineOffset + verticalInset)];
                [leftPath addArcWithCenter:CGPointMake(cornerRadius + verticalInset, cornerRadius + borderInsets.right + (shouldShowTopBorder ? verticalInset : 0)) radius:radius startAngle:-0.75 * M_PI endAngle:-1 * M_PI clockwise:NO];
                [leftPath addLineToPoint:CGPointMake(lineOffset + verticalInset, CGRectGetHeight(self.bounds) - cornerRadius - borderInsets.left - (shouldShowBottomBorder ? verticalInset : 0))];
            } else {
                [topPath moveToPoint:points[@"toppath"][0].CGPointValue];
                [topPath addLineToPoint:CGPointMake(points[@"toppath"][1].CGPointValue.x - cornerRadius, points[@"toppath"][1].CGPointValue.y)];
                [leftPath moveToPoint:CGPointMake(points[@"leftpath"][0].CGPointValue.x, points[@"leftpath"][0].CGPointValue.y - cornerRadius)];
                [leftPath addLineToPoint:points[@"leftpath"][1].CGPointValue];
            }
            if ((view.layer.qmui_maskedCorners & QMUILayerMinXMaxYCorner) == QMUILayerMinXMaxYCorner) {
                [leftPath addArcWithCenter:CGPointMake(cornerRadius + verticalInset, CGRectGetHeight(self.bounds) - cornerRadius - borderInsets.left - (shouldShowBottomBorder ? verticalInset : 0)) radius:radius startAngle:-1 * M_PI endAngle:-1.25 * M_PI clockwise:NO];
                [bottomPath addArcWithCenter:CGPointMake(cornerRadius + borderInsets.right + (shouldShowLeftBorder ? verticalInset : 0), CGRectGetHeight(self.bounds) - cornerRadius - verticalInset) radius:radius startAngle:-1.25 * M_PI endAngle:-1.5 * M_PI clockwise:NO];
                [bottomPath addLineToPoint:CGPointMake(CGRectGetWidth(self.bounds) - cornerRadius - borderInsets.left - (shouldShowRightBorder ? verticalInset : 0), CGRectGetHeight(self.bounds) - lineOffset - verticalInset)];
            } else {
                [leftPath moveToPoint:points[@"leftpath"][0].CGPointValue];
                [leftPath addLineToPoint:CGPointMake(points[@"leftpath"][0].CGPointValue.x, points[@"leftpath"][0].CGPointValue.y - cornerRadius)];
                [bottomPath moveToPoint:points[@"bottompath"][1].CGPointValue];
                [bottomPath addLineToPoint:CGPointMake(points[@"bottompath"][0].CGPointValue.x - cornerRadius, points[@"bottompath"][0].CGPointValue.y)];
            }
            if ((view.layer.qmui_maskedCorners & QMUILayerMaxXMaxYCorner) == QMUILayerMaxXMaxYCorner) {
                [bottomPath addArcWithCenter:CGPointMake(CGRectGetWidth(self.bounds) - cornerRadius - borderInsets.left - (shouldShowRightBorder ? verticalInset : 0), CGRectGetHeight(self.bounds) - cornerRadius - verticalInset) radius:radius startAngle:-1.5 * M_PI endAngle:-1.75 * M_PI clockwise:NO];
                [rightPath addArcWithCenter:CGPointMake(CGRectGetWidth(self.bounds) - cornerRadius - verticalInset, CGRectGetHeight(self.bounds) - cornerRadius - borderInsets.right - (shouldShowBottomBorder ? verticalInset : 0)) radius:radius startAngle:-1.75 * M_PI endAngle:-2 * M_PI clockwise:NO];
                [rightPath addLineToPoint:CGPointMake(CGRectGetWidth(self.bounds) - lineOffset - verticalInset, cornerRadius + borderInsets.left + (shouldShowTopBorder ? verticalInset : 0))];
            } else {
                [bottomPath addLineToPoint:points[@"bottompath"][0].CGPointValue];
                [rightPath moveToPoint:points[@"rightpath"][1].CGPointValue];
                [rightPath addLineToPoint:CGPointMake(points[@"rightpath"][0].CGPointValue.x, points[@"rightpath"][0].CGPointValue.y + cornerRadius)];
            }
            if ((view.layer.qmui_maskedCorners & QMUILayerMaxXMinYCorner) == QMUILayerMaxXMinYCorner) {
                [rightPath addArcWithCenter:CGPointMake(CGRectGetWidth(self.bounds) - cornerRadius - verticalInset, cornerRadius + borderInsets.left + (shouldShowTopBorder ? verticalInset : 0)) radius:radius startAngle:0 * M_PI endAngle:-0.25 * M_PI clockwise:NO];
                [topPath addArcWithCenter:CGPointMake(CGRectGetWidth(self.bounds) - cornerRadius - borderInsets.right - (shouldShowRightBorder ? verticalInset : 0), cornerRadius + verticalInset) radius:radius startAngle:1.5 * M_PI endAngle:1.75 * M_PI clockwise:YES];
            } else {
                [rightPath addLineToPoint:points[@"rightpath"][0].CGPointValue];
                [topPath addLineToPoint:points[@"toppath"][1].CGPointValue];
            }
        } else {
            [topPath addArcWithCenter:CGPointMake(cornerRadius, cornerRadius) radius:radius startAngle:1.25 * M_PI endAngle:1.5 * M_PI clockwise:YES];
            [topPath addLineToPoint:CGPointMake(CGRectGetWidth(self.bounds) - cornerRadius, lineOffset)];
            [topPath addArcWithCenter:CGPointMake(CGRectGetWidth(self.bounds) - cornerRadius, cornerRadius) radius:radius startAngle:1.5 * M_PI endAngle:1.75 * M_PI clockwise:YES];
            
            [leftPath addArcWithCenter:CGPointMake(cornerRadius, cornerRadius) radius:radius startAngle:-0.75 * M_PI endAngle:-1 * M_PI clockwise:NO];
            [leftPath addLineToPoint:CGPointMake(lineOffset, CGRectGetHeight(self.bounds) - cornerRadius)];
            [leftPath addArcWithCenter:CGPointMake(cornerRadius, CGRectGetHeight(self.bounds) - cornerRadius) radius:radius startAngle:-1 * M_PI endAngle:-1.25 * M_PI clockwise:NO];
            
            [bottomPath addArcWithCenter:CGPointMake(cornerRadius, CGRectGetHeight(self.bounds) - cornerRadius) radius:radius startAngle:-1.25 * M_PI endAngle:-1.5 * M_PI clockwise:NO];
            [bottomPath addLineToPoint:CGPointMake(CGRectGetWidth(self.bounds) - cornerRadius, CGRectGetHeight(self.bounds) - lineOffset)];
            [bottomPath addArcWithCenter:CGPointMake(CGRectGetHeight(self.bounds) - cornerRadius, CGRectGetHeight(self.bounds) - cornerRadius) radius:radius startAngle:-1.5 * M_PI endAngle:-1.75 * M_PI clockwise:NO];
            
            [rightPath addArcWithCenter:CGPointMake(CGRectGetWidth(self.bounds) - cornerRadius, CGRectGetHeight(self.bounds) - cornerRadius) radius:radius startAngle:-1.75 * M_PI endAngle:-2 * M_PI clockwise:NO];
            [rightPath addLineToPoint:CGPointMake(CGRectGetWidth(self.bounds) - lineOffset, cornerRadius)];
            [rightPath addArcWithCenter:CGPointMake(CGRectGetWidth(self.bounds) - cornerRadius, cornerRadius) radius:radius startAngle:0 * M_PI endAngle:-0.25 * M_PI clockwise:NO];
        }
        
    } else {
        
        [topPath moveToPoint:points[@"toppath"][0].CGPointValue];           // 左上角
        [topPath addLineToPoint:points[@"toppath"][1].CGPointValue];        // 右上角
        
        [leftPath moveToPoint:points[@"leftpath"][0].CGPointValue];         // 左下角
        [leftPath addLineToPoint:points[@"leftpath"][1].CGPointValue];      // 左上角
        
        [bottomPath moveToPoint:points[@"bottompath"][0].CGPointValue];     // 右下角
        [bottomPath addLineToPoint:points[@"bottompath"][1].CGPointValue];  // 左下角
        
        [rightPath moveToPoint:points[@"rightpath"][0].CGPointValue];       // 右上角
        [rightPath addLineToPoint:points[@"rightpath"][1].CGPointValue];    // 右下角
    }
    
    if (shouldShowTopBorder && ![topPath isEmpty]) {
        [path appendPath:topPath];
    }
    if (shouldShowLeftBorder && ![leftPath isEmpty]) {
        [path appendPath:leftPath];
    }
    if (shouldShowBottomBorder && ![bottomPath isEmpty]) {
        [path appendPath:bottomPath];
    }
    if (shouldShowRightBorder && ![rightPath isEmpty]) {
        [path appendPath:rightPath];
    }
    
    self.path = path.CGPath;
}

@end
