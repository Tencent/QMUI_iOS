/*****
 * Tencent is pleased to support the open source community by making QMUI_iOS available.
 * Copyright (C) 2016-2019 THL A29 Limited, a Tencent company. All rights reserved.
 * Licensed under the MIT License (the "License"); you may not use this file except in compliance with the License. You may obtain a copy of the License at
 * http://opensource.org/licenses/MIT
 * Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.
 *****/

//
//  QMUIZoomImageView.h
//  qmui
//
//  Created by QMUI Team on 14-9-14.
//

#import <UIKit/UIKit.h>
#import <PhotosUI/PhotosUI.h>
#import "QMUIAsset.h"

@class QMUIZoomImageView;
@class QMUIEmptyView;
@class QMUIButton;
@class QMUISlider;
@class QMUIZoomImageViewVideoToolbar;
@class QMUIPieProgressView;

@protocol QMUIZoomImageViewDelegate <NSObject>
@optional
- (void)singleTouchInZoomingImageView:(QMUIZoomImageView *)zoomImageView location:(CGPoint)location;
- (void)doubleTouchInZoomingImageView:(QMUIZoomImageView *)zoomImageView location:(CGPoint)location;
- (void)longPressInZoomingImageView:(QMUIZoomImageView *)zoomImageView;

/**
 *  告知 delegate 用户点击了 iCloud 图片的重试按钮
 */
- (void)didTouchICloudRetryButtonInZoomImageView:(QMUIZoomImageView *)imageView;

/**
 *  告知 delegate 在视频预览界面里，由于用户点击了空白区域或播放视频等导致了底部的视频工具栏被显示或隐藏
 *  @param didHide 如果为 YES 则表示工具栏被隐藏，NO 表示工具栏被显示了出来
 */
- (void)zoomImageView:(QMUIZoomImageView *)imageView didHideVideoToolbar:(BOOL)didHide;

/// 是否支持缩放，默认为 YES
- (BOOL)enabledZoomViewInZoomImageView:(QMUIZoomImageView *)zoomImageView;

@end

/**
 *  支持缩放查看静态图片、live photo、视频的控件
 *  默认显示完整图片或视频，可双击查看原始大小，再次双击查看放大后的大小，第三次双击恢复到初始大小。
 *
 *  支持通过修改 contentMode 来控制静态图片和 live photo 默认的显示模式，目前仅支持 UIViewContentModeCenter、UIViewContentModeScaleAspectFill、UIViewContentModeScaleAspectFit，默认为 UIViewContentModeCenter。注意这里的显示模式是基于 viewportRect 而言的而非整个 zoomImageView
 *  @see viewportRect
 *
 *  QMUIZoomImageView 提供最基础的图片预览和缩放功能以及 loading、错误等状态的展示支持，其他功能请通过继承来实现。
 */
@interface QMUIZoomImageView : UIView <UIScrollViewDelegate>

@property(nonatomic, weak) id<QMUIZoomImageViewDelegate> delegate;

@property(nonatomic, strong, readonly) UIScrollView *scrollView;

/**
 * 比如常见的上传头像预览界面中间有一个用于裁剪的方框，则 viewportRect 必须被设置为这个方框在 zoomImageView 坐标系内的 frame，否则拖拽图片或视频时无法正确限制它们的显示范围
 * @note 图片或视频的初始位置会位于 viewportRect 正中间
 * @note 如果想要图片覆盖整个 viewportRect，将 contentMode 设置为 UIViewContentModeScaleAspectFill 即可
 * 如果设置为 CGRectZero 则表示使用默认值，默认值为和整个 zoomImageView 一样大
 */
@property(nonatomic, assign) CGRect viewportRect;

@property(nonatomic, assign) CGFloat maximumZoomScale;

@property(nonatomic, copy) NSObject<NSCopying> *reusedIdentifier;

/// 设置当前要显示的图片，会把 livePhoto/video 相关内容清空，因此注意不要直接通过 imageView.image 来设置图片。
@property(nonatomic, weak) UIImage *image;

/// 用于显示图片的 UIImageView，注意不要通过 imageView.image 来设置图片，请使用 image 属性。
@property(nonatomic, strong, readonly) UIImageView *imageView;

/// 设置当前要显示的 Live Photo，会把 image/video 相关内容清空，因此注意不要直接通过 livePhotoView.livePhoto 来设置
@property(nonatomic, weak) PHLivePhoto *livePhoto NS_AVAILABLE_IOS(9_1);

/// 用于显示 Live Photo 的 view，仅在 iOS 9.1 及以后才有效
@property(nonatomic, strong, readonly) PHLivePhotoView *livePhotoView NS_AVAILABLE_IOS(9_1);

/// 设置当前要显示的 video ，会把 image/livePhoto 相关内容清空，因此注意不要直接通过 videoPlayerLayer 来设置
@property(nonatomic, weak) AVPlayerItem *videoPlayerItem;

/// 用于显示 video 的 layer
@property(nonatomic, weak, readonly) AVPlayerLayer *videoPlayerLayer;

// 播放 video 时底部的工具栏，你可通过此属性来拿到并修改上面的播放/暂停按钮、进度条、Label 等的样式
// @see QMUIZoomImageViewVideoToolbar
@property(nonatomic, strong, readonly) QMUIZoomImageViewVideoToolbar *videoToolbar;

// 视频底部控制条的 margins，会在此基础上自动叠加 QMUIZoomImageView.qmui_safeAreaInsets，因此无需考虑在 iPhone X 下的兼容
// 默认值为 {0, 25, 25, 18}
@property(nonatomic, assign) UIEdgeInsets videoToolbarMargins UI_APPEARANCE_SELECTOR;

// 播放 video 时屏幕中央的播放按钮
@property(nonatomic, strong, readonly) QMUIButton *videoCenteredPlayButton;

// 可通过此属性修改 video 播放时屏幕中央的播放按钮图片
@property(nonatomic, strong) UIImage *videoCenteredPlayButtonImage UI_APPEARANCE_SELECTOR;

// 从 iCloud 加载资源的进度展示
@property(nonatomic, strong) QMUIPieProgressView *cloudProgressView;

// 从 iCloud 加载资源失败的重试按钮
@property(nonatomic, strong) QMUIButton *cloudDownloadRetryButton;

// 当前展示的资源的下载状态
@property(nonatomic, assign) QMUIAssetDownloadStatus cloudDownloadStatus;

/// 暂停视频播放
- (void)pauseVideo;
/// 停止视频播放，将播放状态重置到初始状态
- (void)endPlayingVideo;

/// 获取当前正在显示的图片/视频的容器
@property(nonatomic, weak, readonly) __kindof UIView *contentView;

/**
 *  获取当前正在显示的图片/视频在整个 QMUIZoomImageView 坐标系里的 rect（会按照当前的缩放状态来计算）
 */
- (CGRect)contentViewRectInZoomImageView;

/**
 *  重置图片或视频的大小，使用的场景例如：相册控件里放大当前图片、划到下一张、再回来，当前的图片或视频应该恢复到原来大小。
 *  注意子类重写需要调一下super。
 */
- (void)revertZooming;

@property(nonatomic, strong, readonly) QMUIEmptyView *emptyView;

/**
 *  显示一个 loading
 *  @info 注意 cell 复用可能导致当前页面显示一张错误的旧图片/视频，所以一般情况下需要视情况同时将 image/livePhoto/videoPlayerItem 等属性置为 nil 以清除图片/视频的显示
 */
- (void)showLoading;

/**
 *  显示一句提示语
 *  @info 注意 cell 复用可能导致当前页面显示一张错误的旧图片/视频，所以一般情况下需要视情况同时将 image/livePhoto/videoPlayerItem 等属性置为 nil 以清除图片/视频的显示
 */
- (void)showEmptyViewWithText:(NSString *)text;
- (void)showEmptyViewWithText:(NSString *)text
                   detailText:(NSString *)detailText
                  buttonTitle:(NSString *)buttonTitle
                 buttonTarget:(id)buttonTarget
                 buttonAction:(SEL)action;

/**
 *  将 emptyView 隐藏
 */
- (void)hideEmptyView;

@end

@interface QMUIZoomImageViewVideoToolbar : UIView

@property(nonatomic, strong, readonly) QMUIButton *playButton;
@property(nonatomic, strong, readonly) QMUIButton *pauseButton;
@property(nonatomic, strong, readonly) QMUISlider *slider;
@property(nonatomic, strong, readonly) UILabel *sliderLeftLabel;
@property(nonatomic, strong, readonly) UILabel *sliderRightLabel;

// 可通过调整此属性来调整 toolbar 内部的间距，默认为 {0, 0, 0, 0}
@property(nonatomic, assign) UIEdgeInsets paddings UI_APPEARANCE_SELECTOR;

// 可通过这些属性修改 video 播放时屏幕底部工具栏的播放/暂停图标
@property(nonatomic, strong) UIImage *playButtonImage UI_APPEARANCE_SELECTOR;
@property(nonatomic, strong) UIImage *pauseButtonImage UI_APPEARANCE_SELECTOR;

@end
