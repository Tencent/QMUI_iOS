//
//  QMUIPieProgressView.h
//  qmui
//
//  Created by MoLice on 15/9/8.
//  Copyright (c) 2015年 QMUI Team. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
 * 饼状进度条控件
 *
 * 使用 `tintColor` 更改进度条饼状部分和边框部分的颜色
 *
 * 使用 `backgroundColor` 更改圆形背景色
 *
 * 通过 `UIControlEventValueChanged` 来监听进度变化
 */
@interface QMUIPieProgressView : UIControl

/**
 进度动画的时长，默认为 0.5
 */
@property(nonatomic, assign) IBInspectable CFTimeInterval progressAnimationDuration;

/**
 当前进度值，默认为 0.0。调用 `setProgress:` 相当于调用 `setProgress:animated:NO`
 */
@property(nonatomic, assign) IBInspectable float progress;

/**
 修改当前的进度，会触发 UIControlEventValueChanged 事件

 @param progress 当前的进度，取值范围 [0.0-1.0]
 @param animated 是否以动画来表现
 */
- (void)setProgress:(float)progress animated:(BOOL)animated;
@end
