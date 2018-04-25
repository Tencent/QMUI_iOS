//
//  QMUIToastAnimator.m
//  qmui
//
//  Created by zhoonchen on 2016/12/12.
//  Copyright © 2016年 QMUI Team. All rights reserved.
//

#import "QMUIToastAnimator.h"
#import "QMUICore.h"
#import "QMUIToastView.h"

@interface QMUIToastAnimator ()

@property(nonatomic, assign) BOOL isShowing;
@property(nonatomic, assign) BOOL isAnimating;
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
    self.isAnimating = YES;
    [UIView animateWithDuration:0.25 delay:0.0 options:QMUIViewAnimationOptionsCurveOut|UIViewAnimationOptionBeginFromCurrentState animations:^{
        self.toastView.backgroundView.alpha = 1.0;
        self.toastView.contentView.alpha = 1.0;
    } completion:^(BOOL finished) {
        self.isAnimating = NO;
        if (completion) {
            completion(finished);
        }
    }];
}

- (void)hideWithCompletion:(void (^)(BOOL finished))completion {
    self.isShowing = NO;
    self.isAnimating = YES;
    [UIView animateWithDuration:0.25 delay:0.0 options:QMUIViewAnimationOptionsCurveOut|UIViewAnimationOptionBeginFromCurrentState animations:^{
        self.toastView.backgroundView.alpha = 0.0;
        self.toastView.contentView.alpha = 0.0;
    } completion:^(BOOL finished) {
        self.isAnimating = NO;
        if (completion) {
            completion(finished);
        }
    }];
}

- (BOOL)isShowing {
    return self.isShowing;
}

- (BOOL)isAnimating {
    return self.isAnimating;
}

@end
