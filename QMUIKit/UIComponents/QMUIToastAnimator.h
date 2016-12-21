//
//  QMUIToastAnimator.h
//  qmui
//
//  Created by zhoonchen on 2016/12/12.
//  Copyright © 2016年 QMUI Team. All rights reserved.
//

#import <Foundation/Foundation.h>

@class QMUIToastView;

/**
 * `QMUIToastAnimatorDelegate`是所有`QMUIToastAnimator`或者其子类必须遵循的协议，是整个动画过程实现的地方。
 */
@protocol QMUIToastAnimatorDelegate <NSObject>

@required

- (void)showWithCompletion:(void (^)(BOOL finished))completion;

- (void)hideWithCompletion:(void (^)(BOOL finished))completion;

- (BOOL)isShowing;

- (BOOL)isAnimating;

@end


// TODO: 实现多种animation类型

typedef NS_ENUM(NSInteger, QMUIToastAnimationType) {
    QMUIToastAnimationTypeFade      = 0,
    QMUIToastAnimationTypeZoom,
    QMUIToastAnimationTypeSlide
};

/**
 * `QMUIToastAnimator`可以让你通过实现一些协议来自定义ToastView显示和隐藏的动画。你可以继承`QMUIToastAnimator`，然后实现`QMUIToastAnimatorDelegate`中的方法，即可实现自定义的动画。QMUIToastAnimator默认也提供了几种type的动画：1、QMUIToastAnimationTypeFade；2、QMUIToastAnimationTypeZoom；3、QMUIToastAnimationTypeSlide；
 */
@interface QMUIToastAnimator : NSObject <QMUIToastAnimatorDelegate>

/**
 * 初始化方法，请务必使用这个方法来初始化。
 *
 * @param toastView 要使用这个animator的QMUIToastView实例。
 */
- (instancetype)initWithToastView:(QMUIToastView *)toastView NS_DESIGNATED_INITIALIZER;

/**
 * 获取初始化传进来的QMUIToastView。
 */
@property(nonatomic, weak, readonly) QMUIToastView *toastView;

/**
 * 指定QMUIToastAnimator做动画的类型type。此功能暂时未实现，目前所有动画类型都是QMUIToastAnimationTypeFade。
 */
@property(nonatomic, assign) QMUIToastAnimationType animationType;

@end
