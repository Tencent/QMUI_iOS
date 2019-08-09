/*****
 * Tencent is pleased to support the open source community by making QMUI_iOS available.
 * Copyright (C) 2016-2019 THL A29 Limited, a Tencent company. All rights reserved.
 * Licensed under the MIT License (the "License"); you may not use this file except in compliance with the License. You may obtain a copy of the License at
 * http://opensource.org/licenses/MIT
 * Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.
 *****/

//
//  QMUIAsset.h
//  qmui
//
//  Created by QMUI Team on 15/6/30.
//

#import <UIKit/UIKit.h>
#import <Photos/PHImageManager.h>

typedef NS_ENUM(NSUInteger, QMUIAssetType) {
    QMUIAssetTypeUnknow,
    QMUIAssetTypeImage,
    QMUIAssetTypeVideo,
    QMUIAssetTypeAudio
};

typedef NS_ENUM(NSUInteger, QMUIAssetSubType) {
    QMUIAssetSubTypeUnknow,
    QMUIAssetSubTypeImage,
    QMUIAssetSubTypeLivePhoto NS_ENUM_AVAILABLE_IOS(9_1),
    QMUIAssetSubTypeGIF
};

/// Status when download asset from iCloud
typedef NS_ENUM(NSUInteger, QMUIAssetDownloadStatus) {
    QMUIAssetDownloadStatusSucceed,
    QMUIAssetDownloadStatusDownloading,
    QMUIAssetDownloadStatusCanceled,
    QMUIAssetDownloadStatusFailed
};


@class PHAsset;

/**
 *  相册里某一个资源的包装对象，该资源可能是图片、视频等。
 *  @note QMUIAsset 重写了 isEqual: 方法，只要两个 QMUIAsset 的 identifier 相同，则认为是同一个对象，以方便在数组、字典等容器中对大量 QMUIAsset 进行遍历查找等操作。
 */
@interface QMUIAsset : NSObject

@property(nonatomic, assign, readonly) QMUIAssetType assetType;
@property(nonatomic, assign, readonly) QMUIAssetSubType assetSubType;

- (instancetype)initWithPHAsset:(PHAsset *)phAsset;

@property(nonatomic, strong, readonly) PHAsset *phAsset;
@property(nonatomic, assign, readonly) QMUIAssetDownloadStatus downloadStatus; // 从 iCloud 下载资源大图的状态
@property(nonatomic, assign) double downloadProgress; // 从 iCloud 下载资源大图的进度
@property(nonatomic, assign) NSInteger requestID; // 从 iCloud 请求获得资源的大图的请求 ID
@property (nonatomic, copy, readonly) NSString *identifier;// Asset 的标识，每个 QMUIAsset 的 identifier 都不同。只要两个 QMUIAsset 的 identifier 相同则认为它们是同一个 asset

/// Asset 的原图（包含系统相册“编辑”功能处理后的效果）
- (UIImage *)originImage;

/**
 *  Asset 的缩略图
 *
 *  @param size 指定返回的缩略图的大小，pt 为单位
 *
 *  @return Asset 的缩略图
 */
- (UIImage *)thumbnailWithSize:(CGSize)size;

/**
 *  Asset 的预览图
 *
 *  @warning 输出与当前设备屏幕大小相同尺寸的图片，如果图片原图小于当前设备屏幕的尺寸，则只输出原图大小的图片
 *  @return Asset 的全屏图
 */
- (UIImage *)previewImage;

/**
 *  异步请求 Asset 的原图，包含了系统照片“编辑”功能处理后的效果（剪裁，旋转和滤镜等），可能会有网络请求
 *
 *  @param completion        完成请求后调用的 block，参数中包含了请求的原图以及图片信息，这个 block 会被多次调用，
 *                           其中第一次调用获取到的尺寸很小的低清图，然后不断调用，直到获取到高清图。
 *  @param phProgressHandler 处理请求进度的 handler，不在主线程上执行，在 block 中修改 UI 时注意需要手工放到主线程处理。
 *
 *  @return 返回请求图片的请求 id
 */
- (NSInteger)requestOriginImageWithCompletion:(void (^)(UIImage *result, NSDictionary<NSString *, id> *info))completion withProgressHandler:(PHAssetImageProgressHandler)phProgressHandler;

/**
 *  异步请求 Asset 的缩略图，不会产生网络请求
 *
 *  @param size       指定返回的缩略图的大小
 *  @param completion 完成请求后调用的 block，参数中包含了请求的缩略图以及图片信息，这个 block 会被多次调用，
 *                    其中第一次调用获取到的尺寸很小的低清图，然后不断调用，直到获取到高清图，这时 block 中的第二个参数（图片信息）返回的为 nil。
 *
 *  @return 返回请求图片的请求 id
 */
- (NSInteger)requestThumbnailImageWithSize:(CGSize)size completion:(void (^)(UIImage *result, NSDictionary<NSString *, id> *info))completion;

/**
 *  异步请求 Asset 的预览图，可能会有网络请求
 *
 *  @param completion        完成请求后调用的 block，参数中包含了请求的预览图以及图片信息，这个 block 会被多次调用，
 *                           其中第一次调用获取到的尺寸很小的低清图，然后不断调用，直到获取到高清图。
 *  @param phProgressHandler 处理请求进度的 handler，不在主线程上执行，在 block 中修改 UI 时注意需要手工放到主线程处理。
 *
 *  @return 返回请求图片的请求 id
 */
- (NSInteger)requestPreviewImageWithCompletion:(void (^)(UIImage *result, NSDictionary<NSString *, id> *info))completion withProgressHandler:(PHAssetImageProgressHandler)phProgressHandler;

/**
 *  异步请求 Live Photo，可能会有网络请求
 *
 *  @param completion        完成请求后调用的 block，参数中包含了请求的 Live Photo 以及相关信息，若 assetType 不是 QMUIAssetTypeLivePhoto 则为 nil
 *  @param phProgressHandler 处理请求进度的 handler，不在主线程上执行，在 block 中修改 UI 时注意需要手工放到主线程处理。
 *
 *  @warning iOS 9.1 以下中并没有 Live Photo，因此无法获取有效结果。
 *
 *  @return 返回请求图片的请求 id
 */
- (NSInteger)requestLivePhotoWithCompletion:(void (^)(PHLivePhoto *livePhoto, NSDictionary<NSString *, id> *info))completion withProgressHandler:(PHAssetImageProgressHandler)phProgressHandler NS_AVAILABLE_IOS(9_1);

/**
 *  异步请求 AVPlayerItem，可能会有网络请求
 *
 *  @param completion        完成请求后调用的 block，参数中包含了请求的 AVPlayerItem 以及相关信息，若 assetType 不是 QMUIAssetTypeVideo 则为 nil
 *  @param phProgressHandler 处理请求进度的 handler，不在主线程上执行，在 block 中修改 UI 时注意需要手工放到主线程处理。
 *
 *  @return 返回请求 AVPlayerItem 的请求 id
 */
- (NSInteger)requestPlayerItemWithCompletion:(void (^)(AVPlayerItem *playerItem, NSDictionary<NSString *, id> *info))completion withProgressHandler:(PHAssetVideoProgressHandler)phProgressHandler;

/**
 *  异步请求图片的 Data
 *
 *  @param completion 完成请求后调用的 block，参数中包含了请求的图片 Data（若 assetType 不是 QMUIAssetTypeImage 或 QMUIAssetTypeLivePhoto 则为 nil），该图片是否为 GIF 的判断值，以及该图片的文件格式是否为 HEIC
 */
- (void)requestImageData:(void (^)(NSData *imageData, NSDictionary<NSString *, id> *info, BOOL isGIF, BOOL isHEIC))completion;

/**
 * 获取图片的 UIImageOrientation 值，仅 assetType 为 QMUIAssetTypeImage 或 QMUIAssetTypeLivePhoto 时有效
 */
- (UIImageOrientation)imageOrientation;

/// 更新下载资源的结果
- (void)updateDownloadStatusWithDownloadResult:(BOOL)succeed;

/**
 * 获取 Asset 的体积（数据大小）
 */
- (void)assetSize:(void (^)(long long size))completion;

- (NSTimeInterval)duration;

@end
