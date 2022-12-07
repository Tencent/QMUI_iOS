/**
 * Tencent is pleased to support the open source community by making QMUI_iOS available.
 * Copyright (C) 2016-2021 THL A29 Limited, a Tencent company. All rights reserved.
 * Licensed under the MIT License (the "License"); you may not use this file except in compliance with the License. You may obtain a copy of the License at
 * http://opensource.org/licenses/MIT
 * Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.
 */

//
//  UIBezierPath+QMUI.m
//  qmui
//
//  Created by QMUI Team on 16/8/9.
//

#import "UIBezierPath+QMUI.h"

@implementation UIBezierPath (QMUI)

+ (instancetype)qmui_bezierPathWithRoundedRect:(CGRect)rect cornerRadiusArray:(NSArray<NSNumber *> *)cornerRadius lineWidth:(CGFloat)lineWidth {
    NSAssert(cornerRadius.count == 4, @"cornerRadiusArray.count should be 4.");
    CGFloat topLeftCornerRadius = cornerRadius[0].floatValue;
    CGFloat bottomLeftCornerRadius = cornerRadius[1].floatValue;
    CGFloat bottomRightCornerRadius = cornerRadius[2].floatValue;
    CGFloat topRightCornerRadius = cornerRadius[3].floatValue;
    CGFloat lineCenter = lineWidth / 2.0;
    
    UIBezierPath *path = [self bezierPath];
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

+ (instancetype)qmui_bezierPathWithMediaTimingFunction:(CAMediaTimingFunction *)function {
    float point1[2], point2[2];
    [function getControlPointAtIndex:1 values:(float *)&point1];
    [function getControlPointAtIndex:2 values:(float *)&point2];
    UIBezierPath *path = [self bezierPath];
    [path moveToPoint:CGPointZero];
    [path addCurveToPoint:CGPointMake(1, 1) controlPoint1:CGPointMake(point1[0], point1[1]) controlPoint2:CGPointMake(point2[0], point2[1])];
    return path;
}

@end
