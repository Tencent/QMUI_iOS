/**
 * Tencent is pleased to support the open source community by making QMUI_iOS available.
 * Copyright (C) 2016-2020 THL A29 Limited, a Tencent company. All rights reserved.
 * Licensed under the MIT License (the "License"); you may not use this file except in compliance with the License. You may obtain a copy of the License at
 * http://opensource.org/licenses/MIT
 * Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.
 */

//
//  QMUIImagePickerHelper.h
//  qmui
//
//  Created by QMUI Team on 15/5/9.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "QMUIAsset.h"
#import "QMUIAssetsGroup.h"

/**
 *  配合 QMUIImagePickerViewController 使用的工具类
 */
@interface QMUIImagePickerHelper : NSObject

/**
 *  选中图片数量改变时，展示图片数量的 Label 的动画，动画过程如下：
 *  Label 背景色改为透明，同时产生一个与背景颜色和形状、大小都相同的图形置于 Label 底下，做先缩小再放大的 spring 动画
 *  动画结束后移除该图形，并恢复 Label 的背景色
 *
 *  @warning iOS6 下降级处理不调用动画效果
 *
 *  @param label 需要做动画的 UILabel
 */
+ (void)springAnimationOfImageSelectedCountChangeWithCountLabel:(UILabel *)label;

/**
 *  图片 checkBox 被选中时的动画
 *  @warning iOS6 下降级处理不调用动画效果
 *
 *  @param button 需要做动画的 checkbox 按钮
 */
+ (void)springAnimationOfImageCheckedWithCheckboxButton:(UIButton *)button;

/**
 * 搭配<i>springAnimationOfImageCheckedWithCheckboxButton:</i>一起使用，添加animation之前建议先remove
 */
+ (void)removeSpringAnimationOfImageCheckedWithCheckboxButton:(UIButton *)button;


/**
 *  获取最近一次调用 updateLastAlbumWithAssetsGroup 方法调用时储存的 QMUIAssetsGroup 对象
 *
 *  @param userIdentify 用户标识，由于每个用户可能需要分开储存一个最近调用过的 QMUIAssetsGroup，因此增加一个标识区分用户。
 *  一个常见的应用场景是选择图片时保存图片所在相册的对应的 QMUIAssetsGroup，并使用用户的 user id 作为区分不同用户的标识，
 *  当用户再次选择图片时可以根据已经保存的 QMUIAssetsGroup 直接进入上次使用过的相册。
 */
+ (QMUIAssetsGroup *)assetsGroupOfLastPickerAlbumWithUserIdentify:(NSString *)userIdentify;

/**
 *  储存一个 QMUIAssetsGroup，从而储存一个对应的相册，与 assetsGroupOfLatestPickerAlbumWithUserIdentify 方法对应使用
 *
 *  @param assetsGroup   要被储存的 QMUIAssetsGroup
 *  @param albumContentType 相册的内容类型
 *  @param userIdentify 用户标识，由于每个用户可能需要分开储存一个最近调用过的 QMUIAssetsGroup，因此增加一个标识区分用户
 */
+ (void)updateLastestAlbumWithAssetsGroup:(QMUIAssetsGroup *)assetsGroup ablumContentType:(QMUIAlbumContentType)albumContentType userIdentify:(NSString *)userIdentify;

/**
 * 检测一组资源是否全部下载成功，如果有资源仍未从 iCloud 中下载成功，则返回 NO
 *
 * 可以用于选择图片后，业务需要自行处理 iCloud 下载的场景。
 */
+ (BOOL)imageAssetsDownloaded:(NSMutableArray<QMUIAsset *> *)imagesAssetArray;

/**
 * 检测资源是否已经在本地，如果资源仍未从 iCloud 中成功下载，则会发出请求从 iCloud 加载资源，并通过多次调用 block 返回请求结果
 *
 * 可以用于选择图片后，业务需要自行处理 iCloud 下载的场景。
 */
+ (void)requestImageAssetIfNeeded:(QMUIAsset *)asset completion: (void (^)(QMUIAssetDownloadStatus downloadStatus, NSError *error))completion;

@end
