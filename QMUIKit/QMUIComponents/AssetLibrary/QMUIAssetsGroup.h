/*****
 * Tencent is pleased to support the open source community by making QMUI_iOS available.
 * Copyright (C) 2016-2019 THL A29 Limited, a Tencent company. All rights reserved.
 * Licensed under the MIT License (the "License"); you may not use this file except in compliance with the License. You may obtain a copy of the License at
 * http://opensource.org/licenses/MIT
 * Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.
 *****/

//
//  QMUIAssetsGroup.h
//  qmui
//
//  Created by QMUI Team on 15/6/30.
//

#import <UIKit/UIKit.h>
#import <Photos/PHAsset.h>
#import <Photos/PHFetchOptions.h>
#import <Photos/PHCollection.h>
#import <Photos/PHFetchResult.h>
#import <Photos/PHImageManager.h>

@class QMUIAsset;

/// 相册展示内容的类型
typedef NS_ENUM(NSUInteger, QMUIAlbumContentType) {
    QMUIAlbumContentTypeAll,                                  // 展示所有资源
    QMUIAlbumContentTypeOnlyPhoto,                            // 只展示照片
    QMUIAlbumContentTypeOnlyVideo,                            // 只展示视频
    QMUIAlbumContentTypeOnlyAudio                             // 只展示音频
};

/// 相册展示内容按日期排序的方式
typedef NS_ENUM(NSUInteger, QMUIAlbumSortType) {
    QMUIAlbumSortTypePositive,  // 日期最新的内容排在后面
    QMUIAlbumSortTypeReverse  // 日期最新的内容排在前面
};


@interface QMUIAssetsGroup : NSObject

- (instancetype)initWithPHCollection:(PHAssetCollection *)phAssetCollection;

- (instancetype)initWithPHCollection:(PHAssetCollection *)phAssetCollection fetchAssetsOptions:(PHFetchOptions *)pHFetchOptions;

/// 仅能通过 initWithPHCollection 和 initWithPHCollection:fetchAssetsOption 方法修改 phAssetCollection 的值
@property(nonatomic, strong, readonly) PHAssetCollection *phAssetCollection;

/// 仅能通过 initWithPHCollection 和 initWithPHCollection:fetchAssetsOption 方法修改 phAssetCollection 后，产生一个对应的 PHAssetsFetchResults 保存到 phFetchResult 中
@property(nonatomic, strong, readonly) PHFetchResult *phFetchResult;

/// 相册的名称
- (NSString *)name;

/// 相册内的资源数量，包括视频、图片、音频（如果支持）这些类型的所有资源
- (NSInteger)numberOfAssets;

/**
 *  相册的缩略图，即系统接口中的相册海报（Poster Image）
 *
 *  @return 相册的缩略图
 */
- (UIImage *)posterImageWithSize:(CGSize)size;

/**
 *  枚举相册内所有的资源
 *
 *  @param albumSortType    相册内资源的排序方式，可以选择日期最新的排在最前面，也可以选择日期最新的排在最后面
 *  @param enumerationBlock 枚举相册内资源时调用的 block，参数 result 表示每次枚举时对应的资源。
 *                          枚举所有资源结束后，enumerationBlock 会被再调用一次，这时 result 的值为 nil。
 *                          可以以此作为判断枚举结束的标记
 */
- (void)enumerateAssetsWithOptions:(QMUIAlbumSortType)albumSortType usingBlock:(void (^)(QMUIAsset *resultAsset))enumerationBlock;

/**
 *  枚举相册内所有的资源，相册内资源按日期最新的排在最后面
 *
 *  @param enumerationBlock 枚举相册内资源时调用的 block，参数 result 表示每次枚举时对应的资源。
 *                          枚举所有资源结束后，enumerationBlock 会被再调用一次，这时 result 的值为 nil。
 *                          可以以此作为判断枚举结束的标记
 */
- (void)enumerateAssetsUsingBlock:(void (^)(QMUIAsset *result))enumerationBlock;

@end
