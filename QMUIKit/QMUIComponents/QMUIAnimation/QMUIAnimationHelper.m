/**
 * Tencent is pleased to support the open source community by making QMUI_iOS available.
 * Copyright (C) 2016-2021 THL A29 Limited, a Tencent company. All rights reserved.
 * Licensed under the MIT License (the "License"); you may not use this file except in compliance with the License. You may obtain a copy of the License at
 * http://opensource.org/licenses/MIT
 * Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.
 */
//
//  QMUIAnimationHelper.m
//  WeRead
//
//  Created by zhoonchen on 2018/9/3.
//

#import "QMUIAnimationHelper.h"
#import "QMUICore.h"

#define SpringDefaultMass 1.0
#define SpringDefaultDamping 18.0
#define SpringDefaultStiffness 82.0
#define SpringDefaultInitialVelocity 0.0

@implementation QMUIAnimationHelper

+ (id)interpolateFromValue:(id)fromValue
                   toValue:(id)toValue
                      time:(CGFloat)time
                    easing:(QMUIAnimationEasings)easing {
    return [self interpolateSpringFromValue:fromValue toValue:toValue time:time mass:SpringDefaultMass damping:SpringDefaultDamping stiffness:SpringDefaultStiffness initialVelocity:SpringDefaultInitialVelocity easing:easing];
}

/*
 * 插值器，遇到新的类型再添加
 */
+ (id)interpolateSpringFromValue:(id)fromValue
                         toValue:(id)toValue
                            time:(CGFloat)time
                            mass:(CGFloat)mass
                         damping:(CGFloat)damping
                       stiffness:(CGFloat)stiffness
                 initialVelocity:(CGFloat)initialVelocity
                          easing:(QMUIAnimationEasings)easing {
    
    if ([fromValue isKindOfClass:[NSNumber class]]) { // NSNumber
        CGFloat from = [fromValue floatValue];
        CGFloat to = [toValue floatValue];
        CGFloat result = interpolateSpring(from, to, time, easing, mass, damping, stiffness, initialVelocity);
        return [NSNumber numberWithFloat:result];
    }
    
    else if ([fromValue isKindOfClass:[UIColor class]]) { // UIColor
        UIColor *from = (UIColor *)fromValue;
        UIColor *to = (UIColor *)toValue;
        CGFloat fromRed, toRed, curRed = 0;
        CGFloat fromGreen, toGreen, curGreen = 0;
        CGFloat fromBlue, toBlue, curBlue = 0;
        CGFloat fromAlpha, toAlpha, curAlpha = 0;
        [from getRed:&fromRed green:&fromGreen blue:&fromBlue alpha:&fromAlpha];
        [to getRed:&toRed green:&toGreen blue:&toBlue alpha:&toAlpha];
        curRed = interpolateSpring(fromRed, toRed, time, easing, mass, damping, stiffness, initialVelocity);
        curGreen = interpolateSpring(fromGreen, toGreen, time, easing, mass, damping, stiffness, initialVelocity);
        curBlue = interpolateSpring(fromBlue, toBlue, time, easing, mass, damping, stiffness, initialVelocity);
        curAlpha = interpolateSpring(fromAlpha, toAlpha, time, easing, mass, damping, stiffness, initialVelocity);
        UIColor *result = [UIColor colorWithRed:curRed green:curGreen blue:curBlue alpha:curAlpha];
        return result;
    }
    
    else if ([fromValue isKindOfClass:[NSValue class]]) { // NSValue
        const char *type = [(NSValue *)fromValue objCType];
        if (strcmp(type, @encode(CGPoint)) == 0) {
            CGPoint from = [fromValue CGPointValue];
            CGPoint to = [toValue CGPointValue];
            CGPoint result = CGPointMake(interpolateSpring(from.x, to.x, time, easing, mass, damping, stiffness, initialVelocity), interpolateSpring(from.y, to.y, time, easing, mass, damping, stiffness, initialVelocity));
            return [NSValue valueWithCGPoint:result];
        }
        else if (strcmp(type, @encode(CGSize)) == 0) {
            CGSize from = [fromValue CGSizeValue];
            CGSize to = [toValue CGSizeValue];
            CGSize result = CGSizeMake(interpolateSpring(from.width, to.width, time, easing, mass, damping, stiffness, initialVelocity), interpolateSpring(from.height, to.height, time, easing, mass, damping, stiffness, initialVelocity));
            return [NSValue valueWithCGSize:result];
        }
        else if (strcmp(type, @encode(CGRect)) == 0) {
            CGRect from = [fromValue CGRectValue];
            CGRect to = [toValue CGRectValue];
            CGRect result = CGRectMake(interpolateSpring(from.origin.x, to.origin.x, time, easing, mass, damping, stiffness, initialVelocity), interpolateSpring(from.origin.y, to.origin.y, time, easing, mass, damping, stiffness, initialVelocity), interpolateSpring(from.size.width, to.size.width, time, easing, mass, damping, stiffness, initialVelocity), interpolateSpring(from.size.height, to.size.height, time, easing, mass, damping, stiffness, initialVelocity));
            return [NSValue valueWithCGRect:result];
        }
        else if (strcmp(type, @encode(CGAffineTransform)) == 0) {
            CGAffineTransform from = [fromValue CGAffineTransformValue];
            CGAffineTransform to = [toValue CGAffineTransformValue];
            CGAffineTransform result = CGAffineTransformIdentity;
            result.a = interpolateSpring(from.a, to.a, time, easing, mass, damping, stiffness, initialVelocity);
            result.b = interpolateSpring(from.b, to.b, time, easing, mass, damping, stiffness, initialVelocity);
            result.c = interpolateSpring(from.c, to.c, time, easing, mass, damping, stiffness, initialVelocity);
            result.d = interpolateSpring(from.d, to.d, time, easing, mass, damping, stiffness, initialVelocity);
            result.tx = interpolateSpring(from.tx, to.tx, time, easing, mass, damping, stiffness, initialVelocity);
            result.ty = interpolateSpring(from.ty, to.ty, time, easing, mass, damping, stiffness, initialVelocity);
            return [NSValue valueWithCGAffineTransform:result];
        }
        else if (strcmp(type, @encode(UIEdgeInsets)) == 0) {
            UIEdgeInsets from = [fromValue UIEdgeInsetsValue];
            UIEdgeInsets to = [toValue UIEdgeInsetsValue];
            UIEdgeInsets result = UIEdgeInsetsZero;
            result.top = interpolateSpring(from.top, to.top, time, easing, mass, damping, stiffness, initialVelocity);
            result.left = interpolateSpring(from.left, to.left, time, easing, mass, damping, stiffness, initialVelocity);
            result.bottom = interpolateSpring(from.bottom, to.bottom, time, easing, mass, damping, stiffness, initialVelocity);
            result.right = interpolateSpring(from.right, to.right, time, easing, mass, damping, stiffness, initialVelocity);
            return [NSValue valueWithUIEdgeInsets:result];
        }
    }
    
    return (time < 0.5) ? fromValue: toValue;
}

CGFloat interpolate(CGFloat from, CGFloat to, CGFloat time, QMUIAnimationEasings easing) {
    return interpolateSpring(from, to, time, easing, SpringDefaultMass, SpringDefaultDamping, SpringDefaultStiffness, SpringDefaultInitialVelocity);
}

CGFloat interpolateSpring(CGFloat from, CGFloat to, CGFloat time, QMUIAnimationEasings easing, CGFloat springMass, CGFloat springDamping, CGFloat springStiffness, CGFloat springInitialVelocity) {
    switch (easing) {
        case QMUIAnimationEasingsLinear:
            time = QMUI_Linear(time);
            break;
        case QMUIAnimationEasingsEaseInSine:
            time = QMUI_EaseInSine(time);
            break;
        case QMUIAnimationEasingsEaseOutSine:
            time = QMUI_EaseOutSine(time);
            break;
        case QMUIAnimationEasingsEaseInOutSine:
            time = QMUI_EaseInOutSine(time);
            break;
        case QMUIAnimationEasingsEaseInQuad:
            time = QMUI_EaseInQuad(time);
            break;
        case QMUIAnimationEasingsEaseOutQuad:
            time = QMUI_EaseOutQuad(time);
            break;
        case QMUIAnimationEasingsEaseInOutQuad:
            time = QMUI_EaseInOutQuad(time);
            break;
        case QMUIAnimationEasingsEaseInCubic:
            time = QMUI_EaseInCubic(time);
            break;
        case QMUIAnimationEasingsEaseOutCubic:
            time = QMUI_EaseOutCubic(time);
            break;
        case QMUIAnimationEasingsEaseInOutCubic:
            time = QMUI_EaseInOutCubic(time);
            break;
        case QMUIAnimationEasingsEaseInQuart:
            time = QMUI_EaseInQuart(time);
            break;
        case QMUIAnimationEasingsEaseOutQuart:
            time = QMUI_EaseOutQuart(time);
            break;
        case QMUIAnimationEasingsEaseInOutQuart:
            time = QMUI_EaseInOutQuart(time);
            break;
        case QMUIAnimationEasingsEaseInQuint:
            time = QMUI_EaseInQuint(time);
            break;
        case QMUIAnimationEasingsEaseOutQuint:
            time = QMUI_EaseOutQuint(time);
            break;
        case QMUIAnimationEasingsEaseInOutQuint:
            time = QMUI_EaseInOutQuint(time);
            break;
        case QMUIAnimationEasingsEaseInExpo:
            time = QMUI_EaseInExpo(time);
            break;
        case QMUIAnimationEasingsEaseOutExpo:
            time = QMUI_EaseOutExpo(time);
            break;
        case QMUIAnimationEasingsEaseInOutExpo:
            time = QMUI_EaseInOutExpo(time);
            break;
        case QMUIAnimationEasingsEaseInCirc:
            time = QMUI_EaseInCirc(time);
            break;
        case QMUIAnimationEasingsEaseOutCirc:
            time = QMUI_EaseOutCirc(time);
            break;
        case QMUIAnimationEasingsEaseInOutCirc:
            time = QMUI_EaseInOutCirc(time);
            break;
        case QMUIAnimationEasingsEaseInBack:
            time = QMUI_EaseInBack(time);
            break;
        case QMUIAnimationEasingsEaseOutBack:
            time = QMUI_EaseOutBack(time);
            break;
        case QMUIAnimationEasingsEaseInOutBack:
            time = QMUI_EaseInOutBack(time);
            break;
        case QMUIAnimationEasingsEaseInElastic:
            time = QMUI_EaseInElastic(time);
            break;
        case QMUIAnimationEasingsEaseOutElastic:
            time = QMUI_EaseOutElastic(time);
            break;
        case QMUIAnimationEasingsEaseInOutElastic:
            time = QMUI_EaseInOutElastic(time);
            break;
        case QMUIAnimationEasingsEaseInBounce:
            time = QMUI_EaseInBounce(time);
            break;
        case QMUIAnimationEasingsEaseOutBounce:
            time = QMUI_EaseOutBounce(time);
            break;
        case QMUIAnimationEasingsEaseInOutBounce:
            time = QMUI_EaseInOutBounce(time);
            break;
        case QMUIAnimationEasingsSpring:
            time = QMUI_EaseSpring(time, springMass, springDamping, springStiffness, springInitialVelocity);
            break;
        case QMUIAnimationEasingsSpringKeyboard:
            time = QMUI_EaseSpring(time, SpringDefaultMass, SpringDefaultDamping, SpringDefaultStiffness, SpringDefaultInitialVelocity);
            break;
        default:
            time = QMUI_Linear(time);
            break;
    }
    return (to - from) * time + from;
}

@end
