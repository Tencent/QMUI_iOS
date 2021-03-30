/**
 * Tencent is pleased to support the open source community by making QMUI_iOS available.
 * Copyright (C) 2016-2021 THL A29 Limited, a Tencent company. All rights reserved.
 * Licensed under the MIT License (the "License"); you may not use this file except in compliance with the License. You may obtain a copy of the License at
 * http://opensource.org/licenses/MIT
 * Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.
 */

//
//  QMUIImagePickerHelper.m
//  qmui
//
//  Created by QMUI Team on 15/5/9.
//

#import "QMUIImagePickerHelper.h"
#import "QMUICore.h"
#import "QMUIAssetsManager.h"
#import "QMUIAsset.h"
#import <Photos/PHCollection.h>
#import <Photos/PHFetchResult.h>
#import "UIImage+QMUI.h"
#import "QMUILog.h"

static NSString * const kLastAlbumKeyPrefix = @"QMUILastestAlbumKeyWith";
static NSString * const kContentTypeOfLastAlbumKeyPrefix = @"QMUIContentTypeOfLastestAlbumKeyWith";

@implementation QMUIImagePickerHelper

+ (void)springAnimationOfImageSelectedCountChangeWithCountLabel:(UILabel *)label {
    [self actionSpringAnimationForView:label];
}

+ (void)springAnimationOfImageCheckedWithCheckboxButton:(UIButton *)button {
    [self actionSpringAnimationForView:button];
}

+ (void)actionSpringAnimationForView:(UIView *)view {
    NSTimeInterval duration = 0.6;
    CAKeyframeAnimation *springAnimation = [CAKeyframeAnimation animationWithKeyPath:@"transform.scale"];
    springAnimation.values = @[@.85, @1.15, @.9, @1.0,];
    springAnimation.keyTimes = @[@(0.0 / duration), @(0.15 / duration) , @(0.3 / duration), @(0.45 / duration),];
    springAnimation.duration = duration;
    [view.layer addAnimation:springAnimation forKey:@"imagePickerActionSpring"];
}

+ (void)removeSpringAnimationOfImageCheckedWithCheckboxButton:(UIButton *)button {
    [button.layer removeAnimationForKey:@"imagePickerActionSpring"];
}

+ (QMUIAssetsGroup *)assetsGroupOfLastPickerAlbumWithUserIdentify:(NSString *)userIdentify {
    // 获取 NSUserDefaults，里面储存了所有 updateLastestAlbumWithAssetsGroup 的结果
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    // 使用特定的前缀和可以标记不同用户的字符串拼接成 key，用于获取当前用户最近调用 updateLastestAlbumWithAssetsGroup 储存的相册以及对于的 QMUIAlbumContentType 值
    NSString *lastAlbumKey = [NSString stringWithFormat:@"%@%@", kLastAlbumKeyPrefix, userIdentify];
    NSString *contentTypeOflastAlbumKey = [NSString stringWithFormat:@"%@%@", kContentTypeOfLastAlbumKeyPrefix, userIdentify];
    
    __block QMUIAssetsGroup *assetsGroup;
    
    QMUIAlbumContentType albumContentType = (QMUIAlbumContentType)[userDefaults integerForKey:contentTypeOflastAlbumKey];
    
    NSString *groupIdentifier = [userDefaults valueForKey:lastAlbumKey];
    /**
     *  如果获取到的 PHAssetCollection localIdentifier 不为空，则获取该 URL 对应的相册。
     *  在 QMUI 2.0.0 及较早的版本中，QMUI 兼容 AssetsLibrary 的使用，
     *  因此原来储存的 groupIdentifier 实际上可能会是一个 NSURL 而不是我们需要的 NSString，
     *  所以这里还需要判断一下实际拿到的数据的类型是否为 NSString，如果是才继续进行。
     */
    if (groupIdentifier && [groupIdentifier isKindOfClass:[NSString class]]) {
        PHFetchResult *phFetchResult = [PHAssetCollection fetchAssetCollectionsWithLocalIdentifiers:@[groupIdentifier] options:nil];
        if (phFetchResult.count > 0) {
            // 创建一个 PHFetchOptions，用于对内容类型进行控制
            PHFetchOptions *phFetchOptions;
            // 旧版本中没有存储 albumContentType，因此为了防止 crash，这里做一下判断
            if (albumContentType) {
                phFetchOptions = [PHPhotoLibrary createFetchOptionsWithAlbumContentType:albumContentType];
            }
            PHAssetCollection *phAssetCollection = [phFetchResult firstObject];
            assetsGroup = [[QMUIAssetsGroup alloc] initWithPHCollection:phAssetCollection fetchAssetsOptions:phFetchOptions];
        }
    } else {
        QMUILog(@"QMUIImagePickerLibrary", @"Group For localIdentifier is not found! groupIdentifier is %@", groupIdentifier);
    }
    return assetsGroup;
}

+ (void)updateLastestAlbumWithAssetsGroup:(QMUIAssetsGroup *)assetsGroup ablumContentType:(QMUIAlbumContentType)albumContentType userIdentify:(NSString *)userIdentify {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    // 使用特定的前缀和可以标记不同用户的字符串拼接成 key，用于为当前用户储存相册对应的 QMUIAssetsGroup 与 QMUIAlbumContentType
    NSString *lastAlbumKey = [NSString stringWithFormat:@"%@%@", kLastAlbumKeyPrefix, userIdentify];
    NSString *contentTypeOflastAlbumKey = [NSString stringWithFormat:@"%@%@", kContentTypeOfLastAlbumKeyPrefix, userIdentify];
    [userDefaults setValue:assetsGroup.phAssetCollection.localIdentifier forKey:lastAlbumKey];
    [userDefaults setInteger:albumContentType forKey:contentTypeOflastAlbumKey];
    [userDefaults synchronize];
}

+ (BOOL)imageAssetsDownloaded:(NSMutableArray<QMUIAsset *> *)imagesAssetArray {
    for (QMUIAsset *asset in imagesAssetArray) {
        if (asset.downloadStatus != QMUIAssetDownloadStatusSucceed) {
            return NO;
        }
    }
    return YES;
}

+ (void)requestImageAssetIfNeeded:(QMUIAsset *)asset completion: (void (^)(QMUIAssetDownloadStatus downloadStatus, NSError *error))completion {
    if (asset.downloadStatus != QMUIAssetDownloadStatusSucceed) {
        
        // 资源加载中
        if (completion) {
            completion(QMUIAssetDownloadStatusDownloading, nil);
        }

        [asset requestOriginImageWithCompletion:^(UIImage *result, NSDictionary<NSString *,id> *info) {
            BOOL downloadSucceed = (result && !info) || (![[info objectForKey:PHImageCancelledKey] boolValue] && ![info objectForKey:PHImageErrorKey] && ![[info objectForKey:PHImageResultIsDegradedKey] boolValue]);
            
            if (downloadSucceed) {
                // 资源资源已经在本地或下载成功
                [asset updateDownloadStatusWithDownloadResult:YES];
                
                if (completion) {
                    completion(QMUIAssetDownloadStatusSucceed, nil);
                }
                
            } else if ([info objectForKey:PHImageErrorKey]) {
                // 下载错误
                [asset updateDownloadStatusWithDownloadResult:NO];
                
                if (completion) {
                    completion(QMUIAssetDownloadStatusFailed, [info objectForKey:PHImageErrorKey]);
                }
            }
        } withProgressHandler:^(double progress, NSError * _Nullable error, BOOL * _Nonnull stop, NSDictionary * _Nullable info) {
            QMUILog(@"QMUIImagePickerLibrary", @"current progress is %f", progress);
            asset.downloadProgress = progress;
        }];
    } else {
        // 资源资源已经在本地或下载成功
        if (completion) {
            completion(QMUIAssetDownloadStatusSucceed, nil);
        }
    }
}

@end


