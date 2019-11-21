/*****
 * Tencent is pleased to support the open source community by making QMUI_iOS available.
 * Copyright (C) 2016-2019 THL A29 Limited, a Tencent company. All rights reserved.
 * Licensed under the MIT License (the "License"); you may not use this file except in compliance with the License. You may obtain a copy of the License at
 * http://opensource.org/licenses/MIT
 * Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.
 *****/

//
//  QMUIImagePreviewView.h
//  qmui
//
//  Created by QMUI Team on 2016/11/30.
//

#import <UIKit/UIKit.h>
#import "QMUIZoomImageView.h"

@class QMUIImagePreviewView;
@class QMUICollectionViewPagingLayout;

typedef NS_ENUM (NSUInteger, QMUIImagePreviewMediaType) {
    QMUIImagePreviewMediaTypeImage,
    QMUIImagePreviewMediaTypeLivePhoto,
    QMUIImagePreviewMediaTypeVideo,
    QMUIImagePreviewMediaTypeOthers
};

@protocol QMUIImagePreviewViewDelegate <QMUIZoomImageViewDelegate>

@required
- (NSUInteger)numberOfImagesInImagePreviewView:(QMUIImagePreviewView *)imagePreviewView;
- (void)imagePreviewView:(QMUIImagePreviewView *)imagePreviewView renderZoomImageView:(QMUIZoomImageView *)zoomImageView atIndex:(NSUInteger)index;

@optional
// 返回要展示的媒体资源的类型（图片、live photo、视频），如果不实现此方法，则 QMUIImagePreviewView 将无法选择最合适的 cell 来复用从而略微增大系统开销
- (QMUIImagePreviewMediaType)imagePreviewView:(QMUIImagePreviewView *)imagePreviewView assetTypeAtIndex:(NSUInteger)index;

/**
 *  当左右的滚动停止时会触发这个方法
 *  @param  imagePreviewView 当前预览的 QMUIImagePreviewView
 *  @param  index 当前滚动到的图片所在的索引
 */
- (void)imagePreviewView:(QMUIImagePreviewView *)imagePreviewView didScrollToIndex:(NSUInteger)index;

/**
 *  在滚动过程中，如果某一张图片的边缘（左/右）经过预览控件的中心点时，就会触发这个方法
 *  @param  imagePreviewView 当前预览的 QMUIImagePreviewView
 *  @param  index 当前滚动到的图片所在的索引
 */
- (void)imagePreviewView:(QMUIImagePreviewView *)imagePreviewView willScrollHalfToIndex:(NSUInteger)index;

@end

/**
 *  查看图片的控件，支持横向滚动、放大缩小、loading 及错误语展示，内部使用 UICollectionView 实现横向滚动及 cell 复用，因此与其他普通的 UICollectionView 一样，也可使用 reloadData、collectionViewLayout 等常用方法。
 *
 *  使用方式：
 *
 *  1. 使用 initWithFrame: 或 init 方法初始化。
 *  2. 设置 delegate。
 *  3. 在 delegate 的 numberOfImagesInImagePreviewView: 方法里返回图片总数。
 *  4. 在 delegate 的 imagePreviewView:renderZoomImageView:atIndex: 方法里为 zoomImageView.image 设置图片，如果需要，也可调用 [zoomImageView showLoading] 等方法来显示 loading。
 *  5. 由于 QMUIImagePreviewViewDelegate 继承自 QMUIZoomImageViewDelegate，所以若需要响应单击、双击、长按事件，请实现 QMUIZoomImageViewDelegate 里的对应方法。
 *  6. 若需要从指定的某一张图片开始查看，可使用 currentImageIndex 属性。
 *
 *  @see QMUIImagePreviewViewController
 */
@interface QMUIImagePreviewView : UIView<UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>

@property(nonatomic, weak) id<QMUIImagePreviewViewDelegate> delegate;
@property(nonatomic, strong, readonly) UICollectionView *collectionView;
@property(nonatomic, strong, readonly) QMUICollectionViewPagingLayout *collectionViewLayout;

/// 获取当前正在查看的图片 index，也可强制将图片滚动到指定的 index
@property(nonatomic, assign) NSUInteger currentImageIndex;
- (void)setCurrentImageIndex:(NSUInteger)currentImageIndex animated:(BOOL)animated;

/// 每一页里的 loading 的颜色，默认为 UIColorWhite
@property(nonatomic, strong) UIColor *loadingColor;

@end

@interface QMUIImagePreviewView (QMUIZoomImageView) <QMUIZoomImageViewDelegate>

/**
 *  获取某个 QMUIZoomImageView 所对应的 index
 *  @return zoomImageView 对应的 index，若当前的 zoomImageView 不可见，会返回 0
 */
- (NSInteger)indexForZoomImageView:(QMUIZoomImageView *)zoomImageView;

/**
 *  获取某个 index 对应的 zoomImageView
 *  @return 指定的 index 所在的 zoomImageView，若该 index 对应的图片当前不可见（不处于可视区域），则返回 nil
 */
- (QMUIZoomImageView *)zoomImageViewAtIndex:(NSUInteger)index;
@end
