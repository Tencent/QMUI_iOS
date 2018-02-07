//
//  UIBezierPath+QMUI.m
//  qmui
//
//  Created by MoLice on 16/8/9.
//  Copyright © 2016年 QMUI Team. All rights reserved.
//

#import "UIBezierPath+QMUI.h"

@implementation UIBezierPath (QMUI)

+ (UIBezierPath *)qmui_bezierPathWithRoundedRect:(CGRect)rect cornerRadiusArray:(NSArray<NSNumber *> *)cornerRadius lineWidth:(CGFloat)lineWidth {
    CGFloat topLeftCornerRadius = cornerRadius[0].floatValue;
    CGFloat bottomLeftCornerRadius = cornerRadius[1].floatValue;
    CGFloat bottomRightCornerRadius = cornerRadius[2].floatValue;
    CGFloat topRightCornerRadius = cornerRadius[3].floatValue;
    CGFloat lineCenter = lineWidth / 2.0;
    
    UIBezierPath *path = [UIBezierPath bezierPath];
    [path moveToPoint:CGPointMake(topLeftCornerRadius, lineCenter)];
    [path addArcWithCenter:CGPointMake(topLeftCornerRadius, topLeftCornerRadius) radius:topLeftCornerRadius - lineCenter startAngle:M_PI * 1.5 endAngle:M_PI clockwise:NO];
    [path addLineToPoint:CGPointMake(lineCenter, CGRectGetHeight(rect) - bottomLeftCornerRadius)];
    [path addArcWithCenter:CGPointMake(bottomLeftCornerRadius, CGRectGetHeight(rect) - bottomLeftCornerRadius) radius:bottomLeftCornerRadius - lineCenter startAngle:M_PI endAngle:M_PI * 0.5 clockwise:NO];
    [path addLineToPoint:CGPointMake(CGRectGetWidth(rect) - bottomRightCornerRadius, CGRectGetHeight(rect) - lineCenter)];
    [path addArcWithCenter:CGPointMake(CGRectGetWidth(rect) - bottomRightCornerRadius, CGRectGetHeight(rect) - bottomRightCornerRadius) radius:bottomRightCornerRadius - lineCenter startAngle:M_PI * 0.5 endAngle:0.0 clockwise:NO];
    [path addLineToPoint:CGPointMake(CGRectGetWidth(rect) - lineCenter, topRightCornerRadius)];
    [path addArcWithCenter:CGPointMake(CGRectGetWidth(rect) - topRightCornerRadius, topRightCornerRadius) radius:topRightCornerRadius - lineCenter startAngle:0.0 endAngle:M_PI * 1.5 clockwise:NO];
    [path closePath];
    
    return path;
}

@end
