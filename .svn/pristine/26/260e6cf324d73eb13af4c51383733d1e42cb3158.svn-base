//
//  QMUITips.h
//  qmui
//
//  Created by zhoonchen on 15/12/25.
//  Copyright © 2015年 QMUI Team. All rights reserved.
//

#import "QMUIToastView.h"

/**
 * 简单封装了 QMUIToastView，支持弹出纯文本、loading、succeed、error、info 等五种 tips。如果这些接口还满足不了业务的需求，可以通过 QMUITips 的分类自行添加接口。
 */

@interface QMUITips : QMUIToastView

/// 实例方法：需要自己addSubview，hide之后不会自动removeFromSuperView

- (void)showWithText:(NSString *)text;
- (void)showWithText:(NSString *)text hideAfterDelay:(NSTimeInterval)delay;
- (void)showWithText:(NSString *)text detailText:(NSString *)detailText;
- (void)showWithText:(NSString *)text detailText:(NSString *)detailText hideAfterDelay:(NSTimeInterval)delay;

- (void)showLoading;
- (void)showLoading:(NSString *)text;
- (void)showLoadingHideAfterDelay:(NSTimeInterval)delay;
- (void)showLoading:(NSString *)text hideAfterDelay:(NSTimeInterval)delay;
- (void)showLoading:(NSString *)text detailText:(NSString *)detailText;
- (void)showLoading:(NSString *)text detailText:(NSString *)detailText hideAfterDelay:(NSTimeInterval)delay;

- (void)showSucceed:(NSString *)text;
- (void)showSucceed:(NSString *)text hideAfterDelay:(NSTimeInterval)delay;
- (void)showSucceed:(NSString *)text detailText:(NSString *)detailText;
- (void)showSucceed:(NSString *)text detailText:(NSString *)detailText hideAfterDelay:(NSTimeInterval)delay;

- (void)showError:(NSString *)text;
- (void)showError:(NSString *)text hideAfterDelay:(NSTimeInterval)delay;
- (void)showError:(NSString *)text detailText:(NSString *)detailText;
- (void)showError:(NSString *)text detailText:(NSString *)detailText hideAfterDelay:(NSTimeInterval)delay;

- (void)showInfo:(NSString *)text;
- (void)showInfo:(NSString *)text hideAfterDelay:(NSTimeInterval)delay;
- (void)showInfo:(NSString *)text detailText:(NSString *)detailText;
- (void)showInfo:(NSString *)text detailText:(NSString *)detailText hideAfterDelay:(NSTimeInterval)delay;

/// 类方法：主要用在局部一次性使用的场景，hide之后会自动removeFromSuperView

+ (QMUITips *)createTipsToView:(UIView *)view;

+ (QMUITips *)showWithText:(NSString *)text inView:(UIView *)view;
+ (QMUITips *)showWithText:(NSString *)text inView:(UIView *)view hideAfterDelay:(NSTimeInterval)delay;
+ (QMUITips *)showWithText:(NSString *)text detailText:(NSString *)detailText inView:(UIView *)view;
+ (QMUITips *)showWithText:(NSString *)text detailText:(NSString *)detailText inView:(UIView *)view hideAfterDelay:(NSTimeInterval)delay;

+ (QMUITips *)showLoadingInView:(UIView *)view;
+ (QMUITips *)showLoading:(NSString *)text inView:(UIView *)view;
+ (QMUITips *)showLoadingInView:(UIView *)view hideAfterDelay:(NSTimeInterval)delay;
+ (QMUITips *)showLoading:(NSString *)text inView:(UIView *)view hideAfterDelay:(NSTimeInterval)delay;
+ (QMUITips *)showLoading:(NSString *)text detailText:(NSString *)detailText inView:(UIView *)view;
+ (QMUITips *)showLoading:(NSString *)text detailText:(NSString *)detailText inView:(UIView *)view hideAfterDelay:(NSTimeInterval)delay;

+ (QMUITips *)showSucceed:(NSString *)text inView:(UIView *)view;
+ (QMUITips *)showSucceed:(NSString *)text inView:(UIView *)view hideAfterDelay:(NSTimeInterval)delay;
+ (QMUITips *)showSucceed:(NSString *)text detailText:(NSString *)detailText inView:(UIView *)view;
+ (QMUITips *)showSucceed:(NSString *)text detailText:(NSString *)detailText inView:(UIView *)view hideAfterDelay:(NSTimeInterval)delay;

+ (QMUITips *)showError:(NSString *)text inView:(UIView *)view;
+ (QMUITips *)showError:(NSString *)text inView:(UIView *)view hideAfterDelay:(NSTimeInterval)delay;
+ (QMUITips *)showError:(NSString *)text detailText:(NSString *)detailText inView:(UIView *)view;
+ (QMUITips *)showError:(NSString *)text detailText:(NSString *)detailText inView:(UIView *)view hideAfterDelay:(NSTimeInterval)delay;

+ (QMUITips *)showInfo:(NSString *)text inView:(UIView *)view;
+ (QMUITips *)showInfo:(NSString *)text inView:(UIView *)view hideAfterDelay:(NSTimeInterval)delay;
+ (QMUITips *)showInfo:(NSString *)text detailText:(NSString *)detailText inView:(UIView *)view;
+ (QMUITips *)showInfo:(NSString *)text detailText:(NSString *)detailText inView:(UIView *)view hideAfterDelay:(NSTimeInterval)delay;

@end
