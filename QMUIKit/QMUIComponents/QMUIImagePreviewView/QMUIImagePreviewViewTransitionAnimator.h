/*****
 * Tencent is pleased to support the open source community by making QMUI_iOS available.
 * Copyright (C) 2016-2019 THL A29 Limited, a Tencent company. All rights reserved.
 * Licensed under the MIT License (the "License"); you may not use this file except in compliance with the License. You may obtain a copy of the License at
 * http://opensource.org/licenses/MIT
 * Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.
 *****/

//
//  QMUIImagePreviewViewTransitionAnimator.h
//  QMUIKit
//
//  Created by MoLice on 2018/D/19.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "QMUIImagePreviewViewController.h"

NS_ASSUME_NONNULL_BEGIN

/**
 负责处理 QMUIImagePreviewViewController 被 present/dismiss 时的动画，如果需要自定义动画效果，可按需修改 animationEnteringBlock、animationBlock、animationCompletionBlock。
 @see QMUIImagePreviewViewController.transitioningAnimator
 */
@interface QMUIImagePreviewViewTransitionAnimator : NSObject<UIViewControllerAnimatedTransitioning>

/// 当前图片预览控件的引用，在为 QMUIImagePreviewViewController.transitioningAnimator 赋值时会自动建立这个引用关系
@property(nonatomic, weak) QMUIImagePreviewViewController *imagePreviewViewController;

/// 转场动画的持续时长，默认为 0.25
@property(nonatomic, assign) NSTimeInterval duration;

/// 当 sourceImageView 本身带圆角时，动画过程中会通过这个 layer 来处理圆角的动画
@property(nonatomic, strong, readonly) CALayer *cornerRadiusMaskLayer;

/**
 动画开始前的准备工作可以在这里做
 
 @param animator 当前的动画器 animator
 @param isPresenting YES 表示当前正在 present，NO 表示正在 dismiss
 @param style 当前动画的样式
 @param sourceImageRect 原界面上显示图片的 view 在 imagePreviewViewController.view 坐标系里的 rect，仅在 style 为 zoom 时有值，style 为 fade 时为 CGRectZero
 @param zoomImageView 当前图片
 @param transitionContext 转场动画的上下文，可通过它获取前后界面、动画容器等信息
 */
@property(nonatomic, copy) void (^animationEnteringBlock)(__kindof QMUIImagePreviewViewTransitionAnimator *animator, BOOL isPresenting, QMUIImagePreviewViewControllerTransitioningStyle style, CGRect sourceImageRect, QMUIZoomImageView *zoomImageView, id<UIViewControllerContextTransitioning> _Nullable transitionContext);

/**
 转场时的实际动画内容，整个 block 会在一个 UIView animation block 里被调用，因此直接写动画内容即可，无需包裹一个 animation block
 
 @param animator 当前的动画器 animator
 @param isPresenting YES 表示当前正在 present，NO 表示正在 dismiss
 @param style 当前动画的样式
 @param sourceImageRect 原界面上显示图片的 view 在 imagePreviewViewController.view 坐标系里的 rect，仅在 style 为 zoom 时有值，style 为 fade 时为 CGRectZero
 @param zoomImageView 当前图片
 @param transitionContext 转场动画的上下文，可通过它获取前后界面、动画容器等信息
 */
@property(nonatomic, copy) void (^animationBlock)(__kindof QMUIImagePreviewViewTransitionAnimator *animator, BOOL isPresenting, QMUIImagePreviewViewControllerTransitioningStyle style, CGRect sourceImageRect, QMUIZoomImageView *zoomImageView, id<UIViewControllerContextTransitioning> _Nullable transitionContext);

/**
 动画结束后的事情，在执行完这个 block 后才会调用 [transitionContext completeTransition:]
 
 @param animator 当前的动画器 animator
 @param isPresenting YES 表示当前正在 present，NO 表示正在 dismiss
 @param style 当前动画的样式
 @param sourceImageRect 原界面上显示图片的 view 在 imagePreviewViewController.view 坐标系里的 rect，仅在 style 为 zoom 时有值，style 为 fade 时为 CGRectZero
 @param zoomImageView 当前图片
 @param transitionContext 转场动画的上下文，可通过它获取前后界面、动画容器等信息
 */
@property(nonatomic, copy) void (^animationCompletionBlock)(__kindof QMUIImagePreviewViewTransitionAnimator *animator, BOOL isPresenting, QMUIImagePreviewViewControllerTransitioningStyle style, CGRect sourceImageRect, QMUIZoomImageView *zoomImageView, id<UIViewControllerContextTransitioning> _Nullable transitionContext);

@end

NS_ASSUME_NONNULL_END
