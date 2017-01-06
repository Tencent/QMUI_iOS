//
//  QMUIZoomImageView.h
//  qmui
//
//  Created by ZhoonChen on 14-9-14.
//  Copyright (c) 2014年 QMUI Team. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <PhotosUI/PhotosUI.h>

@class QMUIZoomImageView;
@class QMUIEmptyView;

@protocol QMUIZoomImageViewDelegate <NSObject>
@optional
- (void)singleTouchInZoomingImageView:(QMUIZoomImageView *)zoomImageView location:(CGPoint)location;
- (void)doubleTouchInZoomingImageView:(QMUIZoomImageView *)zoomImageView location:(CGPoint)location;
- (void)longPressInZoomingImageView:(QMUIZoomImageView *)zoomImageView;

/// 是否支持缩放，默认为 YES
- (BOOL)enabledZoomViewInZoomImageView:(QMUIZoomImageView *)zoomImageView;
@end

/**
 *  支持缩放查看图片（包括 Live Photo）的控件，默认显示完整图片，可双击查看原始大小，再次双击查看放大后的大小，第三次双击恢复到初始大小。
 *
 *  支持通过修改 contentMode 来控制图片默认的显示模式，目前仅支持 UIViewContentModeCenter、UIViewContentModeScaleAspectFill、UIViewContentModeScaleAspectFit，默认为 UIViewContentModeCenter。
 *
 *  QMUIZoomImageView 提供最基础的图片预览和缩放功能以及 loading、错误等状态的展示支持，其他功能请通过继承来实现。
 */
@interface QMUIZoomImageView : UIView <UIScrollViewDelegate>

@property(nonatomic, weak) id<QMUIZoomImageViewDelegate> delegate;

@property(nonatomic, assign) CGFloat maximumZoomScale;

/// 设置当前要显示的图片，会把 livePhoto 相关内容清空，因此注意不要直接通过 imageView.image 来设置图片。
@property(nonatomic, strong) UIImage *image;

/// 用于显示图片的 UIImageView，注意不要通过 imageView.image 来设置图片，请使用 image 属性。
@property(nonatomic, strong, readonly) UIImageView *imageView;

/// 设置当前要显示的 Live Photo，会把 image 相关内容清空，因此注意不要直接通过 livePhotoView.livePhoto 来设置
@property(nonatomic, strong) PHLivePhoto *livePhoto NS_AVAILABLE_IOS(9_1);

/// 用于显示 Live Photo 的 view，仅在 iOS 9 以后才有效
@property(nonatomic, strong, readonly) PHLivePhotoView *livePhotoView NS_AVAILABLE_IOS(9_1);

/**
 *  获取当前正在显示的图片在整个 QMUIZoomImageView 坐标系里的 rect（会按照当前的缩放状态来计算）
 */
- (CGRect)imageViewRectInZoomImageView;

/**
 *  重置图片的大小，使用的场景例如：相册控件，放大当前图片，划到下一张，再回来，当前的图片应该恢复到原来大小。
 *  注意子类重写需要调一下super。
 */
- (void)revertZooming;



@property(nonatomic, strong, readonly) QMUIEmptyView *emptyView;

/**
 *  显示一个 loading，注意一般情况下需要同时调用 self.image = nil 来清除图片，避免 cell 复用导致的问题。
 */
- (void)showLoading;

/**
 *  显示一句提示语，注意一般情况下需要同时调用 self.image = nil 来清除图片，避免 cell 复用导致的问题。
 */
- (void)showEmptyViewWithText:(NSString *)text;

/**
 *  将 emptyView 隐藏
 */
- (void)hideEmptyView;

@end
