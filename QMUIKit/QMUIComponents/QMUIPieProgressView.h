/**
 * Tencent is pleased to support the open source community by making QMUI_iOS available.
 * Copyright (C) 2016-2021 THL A29 Limited, a Tencent company. All rights reserved.
 * Licensed under the MIT License (the "License"); you may not use this file except in compliance with the License. You may obtain a copy of the License at
 * http://opensource.org/licenses/MIT
 * Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.
 */

//
//  QMUIPieProgressView.h
//  qmui
//
//  Created by QMUI Team on 15/9/8.
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

typedef NS_ENUM(NSUInteger, QMUIPieProgressViewShape) {
    QMUIPieProgressViewShapeSector, // 扇形，默认
    QMUIPieProgressViewShapeRing // 环形
};

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
 外边框的大小，默认为 1。
 */
@property(nonatomic, assign) IBInspectable CGFloat borderWidth;

/**
 外边框与内部扇形之间的间隙，默认为 0。
 */
@property(nonatomic, assign) IBInspectable CGFloat borderInset;

/**
 线宽，用于环形绘制，默认为 0。
 */
@property(nonatomic, assign) IBInspectable CGFloat lineWidth;

/**
 绘制形状，默认是扇形。
 */
@property(nonatomic, assign) IBInspectable QMUIPieProgressViewShape shape;

/**
 修改当前的进度，会触发 UIControlEventValueChanged 事件

 @param progress 当前的进度，取值范围 [0.0-1.0]
 @param animated 是否以动画来表现
 */
- (void)setProgress:(float)progress animated:(BOOL)animated;

@end
