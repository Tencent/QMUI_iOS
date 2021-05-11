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

@interface CAShapeLayer (QMUIBorder)

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
        self.qmui_borderLayer = [CAShapeLayer layer];
        self.qmui_borderLayer._qmuibd_targetBorderView = self;
        [self.qmui_borderLayer qmui_removeDefaultAnimations];
        self.qmui_borderLayer.fillColor = UIColorClear.CGColor;
        [self.layer addSublayer:self.qmui_borderLayer];
    }
    self.qmui_borderLayer.lineWidth = self.qmui_borderWidth;
    self.qmui_borderLayer.strokeColor = self.qmui_borderColor.CGColor;
    self.qmui_borderLayer.lineDashPhase = self.qmui_dashPhase;
    self.qmui_borderLayer.lineDashPattern = self.qmui_dashPattern;
    self.qmui_borderLayer.hidden = NO;
}

static char kAssociatedObjectKey_borderLocation;
- (void)setQmui_borderLocation:(QMUIViewBorderLocation)qmui_borderLocation {
    BOOL shouldUpdateLayout = self.qmui_borderLocation != qmui_borderLocation;
    objc_setAssociatedObject(self, &kAssociatedObjectKey_borderLocation, @(qmui_borderLocation), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    [self _qmuibd_createBorderLayerIfNeeded];
    if (shouldUpdateLayout) {
        [self setNeedsLayout];
    }
}

- (QMUIViewBorderLocation)qmui_borderLocation {
    return [((NSNumber *)objc_getAssociatedObject(self, &kAssociatedObjectKey_borderLocation)) unsignedIntegerValue];
}

static char kAssociatedObjectKey_borderPosition;
- (void)setQmui_borderPosition:(QMUIViewBorderPosition)qmui_borderPosition {
    BOOL shouldUpdateLayout = self.qmui_borderPosition != qmui_borderPosition;
    objc_setAssociatedObject(self, &kAssociatedObjectKey_borderPosition, @(qmui_borderPosition), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    [self _qmuibd_createBorderLayerIfNeeded];
    if (shouldUpdateLayout) {
        [self setNeedsLayout];
    }
}

- (QMUIViewBorderPosition)qmui_borderPosition {
    return (QMUIViewBorderPosition)[objc_getAssociatedObject(self, &kAssociatedObjectKey_borderPosition) unsignedIntegerValue];
}

static char kAssociatedObjectKey_borderWidth;
- (void)setQmui_borderWidth:(CGFloat)qmui_borderWidth {
    BOOL shouldUpdateLayout = self.qmui_borderWidth != qmui_borderWidth;
    objc_setAssociatedObject(self, &kAssociatedObjectKey_borderWidth, @(qmui_borderWidth), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    [self _qmuibd_createBorderLayerIfNeeded];
    if (shouldUpdateLayout) {
        [self setNeedsLayout];
    }
}

- (CGFloat)qmui_borderWidth {
    return [((NSNumber *)objc_getAssociatedObject(self, &kAssociatedObjectKey_borderWidth)) qmui_CGFloatValue];
}

static char kAssociatedObjectKey_borderColor;
- (void)setQmui_borderColor:(UIColor *)qmui_borderColor {
    objc_setAssociatedObject(self, &kAssociatedObjectKey_borderColor, qmui_borderColor, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    [self _qmuibd_createBorderLayerIfNeeded];
    [self setNeedsLayout];
}

- (UIColor *)qmui_borderColor {
    return (UIColor *)objc_getAssociatedObject(self, &kAssociatedObjectKey_borderColor);
}

static char kAssociatedObjectKey_dashPhase;
- (void)setQmui_dashPhase:(CGFloat)qmui_dashPhase {
    BOOL shouldUpdateLayout = self.qmui_dashPhase != qmui_dashPhase;
    objc_setAssociatedObject(self, &kAssociatedObjectKey_dashPhase, @(qmui_dashPhase), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    [self _qmuibd_createBorderLayerIfNeeded];
    if (shouldUpdateLayout) {
        [self setNeedsLayout];
    }
}

- (CGFloat)qmui_dashPhase {
    return [(NSNumber *)objc_getAssociatedObject(self, &kAssociatedObjectKey_dashPhase) qmui_CGFloatValue];
}

static char kAssociatedObjectKey_dashPattern;
- (void)setQmui_dashPattern:(NSArray<NSNumber *> *)qmui_dashPattern {
    objc_setAssociatedObject(self, &kAssociatedObjectKey_dashPattern, qmui_dashPattern, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    [self _qmuibd_createBorderLayerIfNeeded];
    [self setNeedsLayout];
}

- (NSArray *)qmui_dashPattern {
    return (NSArray<NSNumber *> *)objc_getAssociatedObject(self, &kAssociatedObjectKey_dashPattern);
}

@end

@implementation CAShapeLayer (QMUIBorder)
QMUISynthesizeIdWeakProperty(_qmuibd_targetBorderView, set_qmuibd_targetBorderView)

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        ExtendImplementationOfVoidMethodWithoutArguments([CAShapeLayer class], @selector(layoutSublayers), ^(CAShapeLayer *selfObject) {
            if (!selfObject._qmuibd_targetBorderView) return;
            
            UIView *view = selfObject._qmuibd_targetBorderView;
            CGFloat borderWidth = selfObject.lineWidth;
            
            UIBezierPath *path = [UIBezierPath bezierPath];;
            
            CGFloat (^adjustsLocation)(CGFloat, CGFloat, CGFloat) = ^CGFloat(CGFloat inside, CGFloat center, CGFloat outside) {
                return view.qmui_borderLocation == QMUIViewBorderLocationInside ? inside : (view.qmui_borderLocation == QMUIViewBorderLocationCenter ? center : outside);
            };
            
            CGFloat lineOffset = adjustsLocation(borderWidth / 2.0, 0, -borderWidth / 2.0); // 为了像素对齐而做的偏移
            CGFloat lineCapOffset = adjustsLocation(0, borderWidth / 2.0, borderWidth); // 两条相邻的边框连接的位置
            
            BOOL shouldShowTopBorder = (view.qmui_borderPosition & QMUIViewBorderPositionTop) == QMUIViewBorderPositionTop;
            BOOL shouldShowLeftBorder = (view.qmui_borderPosition & QMUIViewBorderPositionLeft) == QMUIViewBorderPositionLeft;
            BOOL shouldShowBottomBorder = (view.qmui_borderPosition & QMUIViewBorderPositionBottom) == QMUIViewBorderPositionBottom;
            BOOL shouldShowRightBorder = (view.qmui_borderPosition & QMUIViewBorderPositionRight) == QMUIViewBorderPositionRight;
            
            UIBezierPath *topPath = [UIBezierPath bezierPath];
            UIBezierPath *leftPath = [UIBezierPath bezierPath];
            UIBezierPath *bottomPath = [UIBezierPath bezierPath];
            UIBezierPath *rightPath = [UIBezierPath bezierPath];
            
            if (view.layer.qmui_originCornerRadius > 0) {
                
                CGFloat cornerRadius = view.layer.qmui_originCornerRadius;
                
                if (view.layer.qmui_maskedCorners) {
                    if ((view.layer.qmui_maskedCorners & QMUILayerMinXMinYCorner) == QMUILayerMinXMinYCorner) {
                        [topPath addArcWithCenter:CGPointMake(cornerRadius, cornerRadius) radius:cornerRadius - lineOffset startAngle:1.25 * M_PI endAngle:1.5 * M_PI clockwise:YES];
                        [topPath addLineToPoint:CGPointMake(CGRectGetWidth(selfObject.bounds) - cornerRadius, lineOffset)];
                        [leftPath addArcWithCenter:CGPointMake(cornerRadius, cornerRadius) radius:cornerRadius - lineOffset startAngle:-0.75 * M_PI endAngle:-1 * M_PI clockwise:NO];
                        [leftPath addLineToPoint:CGPointMake(lineOffset, CGRectGetHeight(selfObject.bounds) - cornerRadius)];
                    } else {
                        [topPath moveToPoint:CGPointMake(shouldShowLeftBorder ? -lineCapOffset : 0, lineOffset)];
                        [topPath addLineToPoint:CGPointMake(CGRectGetWidth(selfObject.bounds) - cornerRadius, lineOffset)];
                        [leftPath moveToPoint:CGPointMake(lineOffset, shouldShowTopBorder ? -lineCapOffset : 0)];
                        [leftPath addLineToPoint:CGPointMake(lineOffset, CGRectGetHeight(selfObject.bounds) - cornerRadius)];
                    }
                    if ((view.layer.qmui_maskedCorners & QMUILayerMinXMaxYCorner) == QMUILayerMinXMaxYCorner) {
                        [leftPath addArcWithCenter:CGPointMake(cornerRadius, CGRectGetHeight(selfObject.bounds) - cornerRadius) radius:cornerRadius - lineOffset startAngle:-1 * M_PI endAngle:-1.25 * M_PI clockwise:NO];
                        [bottomPath addArcWithCenter:CGPointMake(cornerRadius, CGRectGetHeight(selfObject.bounds) - cornerRadius) radius:cornerRadius - lineOffset startAngle:-1.25 * M_PI endAngle:-1.5 * M_PI clockwise:NO];
                        [bottomPath addLineToPoint:CGPointMake(CGRectGetWidth(selfObject.bounds) - cornerRadius, CGRectGetHeight(selfObject.bounds) - lineOffset)];
                    } else {
                        [leftPath addLineToPoint:CGPointMake(lineOffset, CGRectGetHeight(selfObject.bounds) + (shouldShowBottomBorder ? lineCapOffset : 0))];
                        CGFloat y = CGRectGetHeight(selfObject.bounds) - lineOffset;
                        [bottomPath moveToPoint:CGPointMake(shouldShowLeftBorder ? -lineCapOffset : 0, y)];
                        [bottomPath addLineToPoint:CGPointMake(CGRectGetWidth(selfObject.bounds) - cornerRadius, y)];
                    }
                    if ((view.layer.qmui_maskedCorners & QMUILayerMaxXMaxYCorner) == QMUILayerMaxXMaxYCorner) {
                        [bottomPath addArcWithCenter:CGPointMake(CGRectGetWidth(selfObject.bounds) - cornerRadius, CGRectGetHeight(selfObject.bounds) - cornerRadius) radius:cornerRadius - lineOffset startAngle:-1.5 * M_PI endAngle:-1.75 * M_PI clockwise:NO];
                        [rightPath addArcWithCenter:CGPointMake(CGRectGetWidth(selfObject.bounds) - cornerRadius, CGRectGetHeight(selfObject.bounds) - cornerRadius) radius:cornerRadius - lineOffset startAngle:-1.75 * M_PI endAngle:-2 * M_PI clockwise:NO];
                        [rightPath addLineToPoint:CGPointMake(CGRectGetWidth(selfObject.bounds) - lineOffset, cornerRadius)];
                    } else {
                        CGFloat y = CGRectGetHeight(selfObject.bounds) - lineOffset;
                        [bottomPath addLineToPoint:CGPointMake(CGRectGetWidth(selfObject.bounds) + (shouldShowRightBorder ? lineCapOffset : 0), y)];
                        CGFloat x = CGRectGetWidth(selfObject.bounds) - lineOffset;
                        [rightPath moveToPoint:CGPointMake(x, CGRectGetHeight(selfObject.bounds) + (shouldShowBottomBorder ? lineCapOffset : 0))];
                        [rightPath addLineToPoint:CGPointMake(x, cornerRadius)];
                    }
                    if ((view.layer.qmui_maskedCorners & QMUILayerMaxXMinYCorner) == QMUILayerMaxXMinYCorner) {
                        [rightPath addArcWithCenter:CGPointMake(CGRectGetWidth(selfObject.bounds) - cornerRadius, cornerRadius) radius:cornerRadius - lineOffset startAngle:0 * M_PI endAngle:-0.25 * M_PI clockwise:NO];
                        [topPath addArcWithCenter:CGPointMake(CGRectGetWidth(selfObject.bounds) - cornerRadius, cornerRadius) radius:cornerRadius - lineOffset startAngle:1.5 * M_PI endAngle:1.75 * M_PI clockwise:YES];
                    } else {
                        CGFloat x = CGRectGetWidth(selfObject.bounds) - lineOffset;
                        [rightPath addLineToPoint:CGPointMake(x, shouldShowTopBorder ? -lineCapOffset : 0)];
                        [topPath addLineToPoint:CGPointMake(CGRectGetWidth(selfObject.bounds) + (shouldShowRightBorder ? lineCapOffset : 0), lineOffset)];
                    }
                } else {
                    [topPath addArcWithCenter:CGPointMake(cornerRadius, cornerRadius) radius:cornerRadius - lineOffset startAngle:1.25 * M_PI endAngle:1.5 * M_PI clockwise:YES];
                    [topPath addLineToPoint:CGPointMake(CGRectGetWidth(selfObject.bounds) - cornerRadius, lineOffset)];
                    [topPath addArcWithCenter:CGPointMake(CGRectGetWidth(selfObject.bounds) - cornerRadius, cornerRadius) radius:cornerRadius - lineOffset startAngle:1.5 * M_PI endAngle:1.75 * M_PI clockwise:YES];
                    
                    [leftPath addArcWithCenter:CGPointMake(cornerRadius, cornerRadius) radius:cornerRadius - lineOffset startAngle:-0.75 * M_PI endAngle:-1 * M_PI clockwise:NO];
                    [leftPath addLineToPoint:CGPointMake(lineOffset, CGRectGetHeight(selfObject.bounds) - cornerRadius)];
                    [leftPath addArcWithCenter:CGPointMake(cornerRadius, CGRectGetHeight(selfObject.bounds) - cornerRadius) radius:cornerRadius - lineOffset startAngle:-1 * M_PI endAngle:-1.25 * M_PI clockwise:NO];
                    
                    [bottomPath addArcWithCenter:CGPointMake(cornerRadius, CGRectGetHeight(selfObject.bounds) - cornerRadius) radius:cornerRadius - lineOffset startAngle:-1.25 * M_PI endAngle:-1.5 * M_PI clockwise:NO];
                    [bottomPath addLineToPoint:CGPointMake(CGRectGetWidth(selfObject.bounds) - cornerRadius, CGRectGetHeight(selfObject.bounds) - lineOffset)];
                    [bottomPath addArcWithCenter:CGPointMake(CGRectGetHeight(selfObject.bounds) - cornerRadius, CGRectGetHeight(selfObject.bounds) - cornerRadius) radius:cornerRadius - lineOffset startAngle:-1.5 * M_PI endAngle:-1.75 * M_PI clockwise:NO];
                    
                    [rightPath addArcWithCenter:CGPointMake(CGRectGetWidth(selfObject.bounds) - cornerRadius, CGRectGetHeight(selfObject.bounds) - cornerRadius) radius:cornerRadius - lineOffset startAngle:-1.75 * M_PI endAngle:-2 * M_PI clockwise:NO];
                    [rightPath addLineToPoint:CGPointMake(CGRectGetWidth(selfObject.bounds) - lineOffset, cornerRadius)];
                    [rightPath addArcWithCenter:CGPointMake(CGRectGetWidth(selfObject.bounds) - cornerRadius, cornerRadius) radius:cornerRadius - lineOffset startAngle:0 * M_PI endAngle:-0.25 * M_PI clockwise:NO];
                }
                
            } else {
                [topPath moveToPoint:CGPointMake(shouldShowLeftBorder ? -lineCapOffset : 0, lineOffset)];
                [topPath addLineToPoint:CGPointMake(CGRectGetWidth(selfObject.bounds) + (shouldShowRightBorder ? lineCapOffset : 0), lineOffset)];
                
                [leftPath moveToPoint:CGPointMake(lineOffset, shouldShowTopBorder ? -lineCapOffset : 0)];
                [leftPath addLineToPoint:CGPointMake(lineOffset, CGRectGetHeight(selfObject.bounds) + (shouldShowBottomBorder ? lineCapOffset : 0))];
                
                CGFloat y = CGRectGetHeight(selfObject.bounds) - lineOffset;
                [bottomPath moveToPoint:CGPointMake(shouldShowLeftBorder ? -lineCapOffset : 0, y)];
                [bottomPath addLineToPoint:CGPointMake(CGRectGetWidth(selfObject.bounds) + (shouldShowRightBorder ? lineCapOffset : 0), y)];
                
                CGFloat x = CGRectGetWidth(selfObject.bounds) - lineOffset;
                [rightPath moveToPoint:CGPointMake(x, CGRectGetHeight(selfObject.bounds) + (shouldShowBottomBorder ? lineCapOffset : 0))];
                [rightPath addLineToPoint:CGPointMake(x, shouldShowTopBorder ? -lineCapOffset : 0)];
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
            
            selfObject.path = path.CGPath;
        });
    });
}
@end
