//
//  QMUIImagePickerHelper.m
//  qmui
//
//  Created by Kayo Lee on 15/5/9.
//  Copyright (c) 2015年 QMUI Team. All rights reserved.
//

#import "QMUIImagePickerHelper.h"
#import "QMUICommonDefines.h"
#import "QMUIConfiguration.h"
#import "QMUIHelper.h"
#import "QMUIHelper.h"
#import "QMUIAssetsManager.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import <Photos/PHCollection.h>
#import <Photos/PHFetchResult.h>
#import "UIImage+QMUI.h"


static NSString * const kLastAlbumKeyPrefix = @"QMUILastAlbumKeyWith";
static NSString * const kContentTypeOfLastAlbumKeyPrefix = @"QMUIContentTypeOfLastAlbumKeyWith";

@implementation QMUIImagePickerHelper

+ (BOOL)imageAssetArray:(NSMutableArray *)imageAssetArray containsImageAsset:(QMUIAsset *)targetImageAsset {
    NSString *targetAssetIdentify = [targetImageAsset assetIdentity];
    for (NSUInteger i = 0; i < [imageAssetArray count]; i++) {
        QMUIAsset *imageAsset = [imageAssetArray objectAtIndex:i];
        if ([[imageAsset assetIdentity] isEqual:targetAssetIdentify]) {
            return YES;
        }
    }
    return NO;
}

+ (void)imageAssetArray:(NSMutableArray *)imageAssetArray removeImageAsset:(QMUIAsset *)targetImageAsset {
    NSString *targetAssetIdentify = [targetImageAsset assetIdentity];
    for (NSUInteger i = 0; i < [imageAssetArray count]; i++) {
        QMUIAsset *imageAsset = [imageAssetArray objectAtIndex:i];
        if ([[imageAsset assetIdentity] isEqual:targetAssetIdentify]) {
            [imageAssetArray removeObject:imageAsset];
            break;
        }
    }
}

+ (void)springAnimationOfImageSelectedCountChangeWithCountLabel:(UILabel *)label {
    [QMUIHelper actionSpringAnimationForView:label];
}

+ (void)springAnimationOfImageCheckedWithCheckboxButton:(UIButton *)button {
    [QMUIHelper actionSpringAnimationForView:button];
}

+ (void)removeSpringAnimationOfImageCheckedWithCheckboxButton:(UIButton *)button {
    [button.layer removeAnimationForKey:QMUISpringAnimationKey];
}

+ (QMUIAssetsGroup *)assetsGroupOfLastestPickerAlbumWithUserIdentify:(NSString *)userIdentify {
    // 获取 NSUserDefaults，里面储存了所有 updateLastestAlbumWithAssetsGroup 的结果
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    // 使用特定的前缀和可以标记不同用户的字符串拼接成 key，用于获取当前用户最近调用 updateLastestAlbumWithAssetsGroup 储存的相册以及对于的 QMUIAlbumContentType 值
    NSString *lastAlbumKey = [NSString stringWithFormat:@"%@%@", kLastAlbumKeyPrefix, userIdentify];
    NSString *contentTypeOflastAlbumKey = [NSString stringWithFormat:@"%@%@", kContentTypeOfLastAlbumKeyPrefix, userIdentify];
    
    __block QMUIAssetsGroup *assetsGroup;
    BOOL usePhotoKit = IOS_VERSION >= 8.0 ? YES : NO;
    
    QMUIAlbumContentType albumContentType = (QMUIAlbumContentType)[userDefaults integerForKey:contentTypeOflastAlbumKey];
    
    if (usePhotoKit) {
        NSString *groupIdentifier = [userDefaults valueForKey:lastAlbumKey];
        /**
         *  如果获取到的 PHAssetCollection localIdentifier 不为空，则获取该 URL 对应的相册。
         *  用户升级设备的系统后，这里会从原来的 AssetsLibrary 改为用 PhotoKit，
         *  因此原来储存的 groupIdentifier 实际上会是一个 NSURL 而不是我们需要的 NSString。
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
            QMUILog(@"Group For localIdentifier is not found!");
        }
    } else {
        NSURL *groupUrl = [userDefaults URLForKey:lastAlbumKey];
        // 如果获取到的 ALAssetsGroup URL 不为空，则获取该 URL 对应的相册
        if (groupUrl) {
            [[[QMUIAssetsManager sharedInstance] alAssetsLibrary] groupForURL:groupUrl resultBlock:^(ALAssetsGroup *group) {
                if (group) {
                    assetsGroup = [[QMUIAssetsGroup alloc] initWithALAssetsGroup:group];
                    // 对内容类型进行控制
                    switch (albumContentType) {
                        case QMUIAlbumContentTypeOnlyPhoto:
                            [group setAssetsFilter:[ALAssetsFilter allPhotos]];
                            break;
                            
                        case QMUIAlbumContentTypeOnlyVideo:
                            [group setAssetsFilter:[ALAssetsFilter allVideos]];
                            break;
                            
                        default:
                            break;
                    }
                }
            } failureBlock:^(NSError *error) {
                QMUILog(@"Group For URL is Error!");
            }];
        }
    }
    return assetsGroup;
}

+ (void)updateLastestAlbumWithAssetsGroup:(QMUIAssetsGroup *)assetsGroup ablumContentType:(QMUIAlbumContentType)albumContentType userIdentify:(NSString *)userIdentify {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    // 使用特定的前缀和可以标记不同用户的字符串拼接成 key，用于为当前用户储存相册对应的 QMUIAssetsGroup 与 QMUIAlbumContentType
    NSString *lastAlbumKey = [NSString stringWithFormat:@"%@%@", kLastAlbumKeyPrefix, userIdentify];
    NSString *contentTypeOflastAlbumKey = [NSString stringWithFormat:@"%@%@", kContentTypeOfLastAlbumKeyPrefix, userIdentify];
    if (assetsGroup.alAssetsGroup) {
        [userDefaults setURL:[assetsGroup.alAssetsGroup valueForProperty:ALAssetsGroupPropertyURL] forKey:lastAlbumKey];
    } else {
        // 使用 PhotoKit
        [userDefaults setValue:assetsGroup.phAssetCollection.localIdentifier forKey:lastAlbumKey];
    }
    
    [userDefaults setInteger:albumContentType forKey:contentTypeOflastAlbumKey];
    
    [userDefaults synchronize];
}

@end


