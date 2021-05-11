/**
 * Tencent is pleased to support the open source community by making QMUI_iOS available.
 * Copyright (C) 2016-2021 THL A29 Limited, a Tencent company. All rights reserved.
 * Licensed under the MIT License (the "License"); you may not use this file except in compliance with the License. You may obtain a copy of the License at
 * http://opensource.org/licenses/MIT
 * Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.
 */

//
//  QMUIToastAnimator.m
//  qmui
//
//  Created by QMUI Team on 2016/12/12.
//

#import "QMUIToastAnimator.h"
#import "QMUICore.h"
#import "QMUIToastView.h"

#define kSlideAnimationKey @"kSlideAnimationKey"

@interface QMUIToastAnimator ()<CAAnimationDelegate>

@property (nonatomic, assign) BOOL isShowing;
@property (nonatomic, assign) BOOL isAnimating;
@property (nonatomic, copy) void (^basicAnimationCompletion)(BOOL finished);

@end

@implementation QMUIToastAnimator

- (instancetype)init {
    NSAssert(NO, @"请使用initWithToastView:初始化");
    return [self initWithToastView:nil];
}

- (instancetype)initWithCoder:(NSCoder *)coder {
    NSAssert(NO, @"请使用initWithToastView:初始化");
    return [self initWithToastView:nil];
}

- (instancetype)initWithToastView:(QMUIToastView *)toastView {
    NSAssert(toastView, @"toastView不能为空");
    if (self = [super init]) {
        _toastView = toastView;
    }
    return self;
}

- (void)showWithCompletion:(void (^)(BOOL finished))completion {
    self.isShowing = YES;
    switch (self.animationType) {
        case QMUIToastAnimationTypeZoom:{
            [self zoomAnimationForShow:YES withCompletion:completion];
        }
            break;
        case QMUIToastAnimationTypeSlide:{
            [self slideAnimationForShow:YES withCompletion:completion];
        }
            break;
        case QMUIToastAnimationTypeFade:
        default:{
            [self fadeAnimationForShow:YES withCompletion:completion];
        }
            break;
    }
}

- (void)hideWithCompletion:(void (^)(BOOL finished))completion {
    self.isShowing = NO;
    switch (self.animationType) {
        case QMUIToastAnimationTypeZoom:{
            [self zoomAnimationForShow:NO withCompletion:completion];
        }
            break;
        case QMUIToastAnimationTypeSlide:{
            [self slideAnimationForShow:NO withCompletion:completion];
        }
            break;
        case QMUIToastAnimationTypeFade:
        default:{
            [self fadeAnimationForShow:NO withCompletion:completion];
        }
            break;
    }
}

- (void)zoomAnimationForShow:(BOOL)show withCompletion:(void (^)(BOOL))completion {
    CGFloat alpha = show ? 1.f : 0.f;
    CGAffineTransform small = CGAffineTransformMakeScale(0.5f, 0.5f);
    CGAffineTransform endTransform = show ? CGAffineTransformIdentity : small;
    self.isAnimating = YES;
    if (show) {
        self.toastView.backgroundView.transform = small;
        self.toastView.contentView.transform = small;
    }
    [UIView animateWithDuration:0.25
                          delay:0.0
                        options:QMUIViewAnimationOptionsCurveOut|UIViewAnimationOptionBeginFromCurrentState
                     animations:^{
        self.toastView.backgroundView.alpha = alpha;
        self.toastView.contentView.alpha = alpha;
        self.toastView.backgroundView.transform = endTransform;
        self.toastView.contentView.transform = endTransform;
    } completion:^(BOOL finished) {
        self.toastView.backgroundView.transform = endTransform;
        self.toastView.contentView.transform = endTransform;
        self.isAnimating = NO;
        if (completion) {
            completion(finished);
        }
    }];
}

- (void)slideAnimationForShow:(BOOL)show withCompletion:(void (^)(BOOL))completion {
    self.basicAnimationCompletion = [completion copy];
    self.isAnimating = YES;
    if (show) {
        [self showSlideAnimationOnView:self.toastView.backgroundView withIndentifier:@"showBackgroundView"];
        [self showSlideAnimationOnView:self.toastView.contentView withIndentifier:@"showContentView"];
    }else{
        [self hideSlideAnimationOnView:self.toastView.backgroundView withIndentifier:@"hideBackgroundView"];
        [self hideSlideAnimationOnView:self.toastView.contentView withIndentifier:@"hideContentView"];
    }
}

- (void)fadeAnimationForShow:(BOOL)show withCompletion:(void (^)(BOOL))completion {
    CGFloat alpha = show ? 1.f : 0.f;
    self.isAnimating = YES;
    [UIView animateWithDuration:0.25
                          delay:0.0
                        options:QMUIViewAnimationOptionsCurveOut|UIViewAnimationOptionBeginFromCurrentState
                     animations:^{
        self.toastView.backgroundView.alpha = alpha;
        self.toastView.contentView.alpha = alpha;
    } completion:^(BOOL finished) {
        self.isAnimating = NO;
        if (completion) {
            completion(finished);
        }
    }];
}

- (void)showSlideAnimationOnView:(UIView *)popupView withIndentifier:(NSString *)key {
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"transform.translation.y"];
    animation.fromValue = [NSNumber numberWithFloat:- [[UIScreen mainScreen] bounds].size.height / 2 - popupView.frame.size.height / 2];
    animation.toValue = [NSNumber numberWithFloat:0];
    animation.duration = 0.6;
    animation.delegate = self;
    animation.removedOnCompletion = NO;
    animation.fillMode = kCAFillModeBoth;
    animation.timingFunction = [CAMediaTimingFunction functionWithControlPoints:0.51 : 1.24 : 0.02 : 0.99];
    [animation setValue:key forKey:kSlideAnimationKey];
    [popupView.layer addAnimation:animation forKey:@"showPopupView"];
    
    CABasicAnimation *opacityAnimation = [CABasicAnimation animationWithKeyPath:@"opacity"];
    opacityAnimation.fromValue = [NSNumber numberWithFloat:0.0];
    opacityAnimation.toValue = [NSNumber numberWithFloat:1];
    opacityAnimation.duration = 0.27;
    opacityAnimation.beginTime=CACurrentMediaTime() + 0.03;
    opacityAnimation.removedOnCompletion = NO;
    opacityAnimation.fillMode = kCAFillModeBoth;
    opacityAnimation.timingFunction = [CAMediaTimingFunction functionWithControlPoints:0.25 : 0.1: 0.25 : 1];
    
    [popupView.layer addAnimation:opacityAnimation forKey:@"showOpacityKey"];
    
    CABasicAnimation *rotateAnimation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
    rotateAnimation.fromValue = [NSNumber numberWithFloat:2 * M_PI/180];
    rotateAnimation.toValue = [NSNumber numberWithFloat:0];
    rotateAnimation.duration = 0.17;
    rotateAnimation.beginTime=CACurrentMediaTime() + 0.26;
    rotateAnimation.removedOnCompletion = NO;
    rotateAnimation.fillMode = kCAFillModeBoth;
    rotateAnimation.timingFunction = [CAMediaTimingFunction functionWithControlPoints:0.25 : 0.1 : 0.25 : 1];
    
    [popupView.layer addAnimation:rotateAnimation forKey:@"showRotateKey"];
}

- (void)hideSlideAnimationOnView:(UIView *)popupView withIndentifier:(NSString *)key {
    CABasicAnimation *animationY = [CABasicAnimation animationWithKeyPath:@"transform.translation.y"];
    animationY.fromValue = [NSNumber numberWithFloat:0];
    animationY.toValue = [NSNumber numberWithFloat:[[UIScreen mainScreen] bounds].size.height/2+popupView.frame.size.height/2];
    animationY.duration = 0.7;
    animationY.removedOnCompletion = NO;
    animationY.fillMode = kCAFillModeBoth;
    animationY.timingFunction = [CAMediaTimingFunction functionWithControlPoints:0.73 : -0.38 : 0.03 : 1.41];
    animationY.delegate = self;
    [animationY setValue:key forKey:kSlideAnimationKey];
    [popupView.layer addAnimation:animationY forKey:@"hidePopupView"];
    
    CABasicAnimation *rotateAnimation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
    rotateAnimation.fromValue = [NSNumber numberWithFloat:0];
    rotateAnimation.toValue = [NSNumber numberWithFloat:3 * M_PI/180];
    rotateAnimation.duration = 0.4;
    rotateAnimation.beginTime=CACurrentMediaTime() + 0.05;
    rotateAnimation.removedOnCompletion = NO;
    rotateAnimation.fillMode = kCAFillModeBoth;
    rotateAnimation.timingFunction = [CAMediaTimingFunction functionWithControlPoints:0.25 : 0.1 : 0.25 : 1];
    
    [popupView.layer addAnimation:rotateAnimation forKey:@"hideRotateKey"];
    
    
    CABasicAnimation *opacityAnimation = [CABasicAnimation animationWithKeyPath:@"opacity"];
    opacityAnimation.fromValue = [NSNumber numberWithFloat:1];
    opacityAnimation.toValue = [NSNumber numberWithFloat:0];
    opacityAnimation.duration = 0.25;
    opacityAnimation.beginTime=CACurrentMediaTime() + 0.15;
    opacityAnimation.removedOnCompletion = NO;
    opacityAnimation.fillMode = kCAFillModeBoth;
    opacityAnimation.timingFunction = [CAMediaTimingFunction functionWithControlPoints:0.53 : 0.92 : 1 : 1];
    
    [popupView.layer addAnimation:opacityAnimation forKey:@"hideOpacityKey"];
}

- (void)animationDidStop:(CAAnimation *)animation finished:(BOOL)flag {
    if([[animation valueForKey:kSlideAnimationKey] isEqual:@"showContentView"] ||
       [[animation valueForKey:kSlideAnimationKey] isEqual:@"hideContentView"]) {
        if (self.basicAnimationCompletion) {
            self.basicAnimationCompletion(flag);
        }
        self.isAnimating = NO;
    }
}

- (BOOL)isShowing {
    return self.isShowing;
}

- (BOOL)isAnimating {
    return self.isAnimating;
}

@end
