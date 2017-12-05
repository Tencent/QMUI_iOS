//
//  QMUIImagePickerHelper.m
//  qmui
//
//  Created by Kayo Lee on 15/5/9.
//  Copyright (c) 2015年 QMUI Team. All rights reserved.
//

#import "QMUIImagePickerHelper.h"
#import "QMUICore.h"
#import "QMUIAssetsManager.h"
#import <Photos/PHCollection.h>
#import <Photos/PHFetchResult.h>
#import "UIImage+QMUI.h"


static NSString * const kLastAlbumKeyPrefix = @"QMUILastestAlbumKeyWith";
static NSString * const kContentTypeOfLastAlbumKeyPrefix = @"QMUIContentTypeOfLastestAlbumKeyWith";

@implementation QMUIImagePickerHelper

+ (BOOL)imageAssetArray:(NSMutableArray *)imageAssetArray containsImageAsset:(QMUIAsset *)targetImageAsset {
    NSString *targetAssetIdentify = [targetImageAsset assetIdentity];
    for (NSUInteger i = 0; i < [imageAssetArray count]; i++) {
        QMUIAsset *imageAsset = [imageAssetArray objectAtIndex:i];
        if ([[imageAsset assetIdentity] isEqualToString:targetAssetIdentify]) {
            return YES;
        }
    }
    return NO;
}

+ (void)imageAssetArray:(NSMutableArray *)imageAssetArray removeImageAsset:(QMUIAsset *)targetImageAsset {
    NSString *targetAssetIdentify = [targetImageAsset assetIdentity];
    for (NSUInteger i = 0; i < [imageAssetArray count]; i++) {
        QMUIAsset *imageAsset = [imageAssetArray objectAtIndex:i];
        if ([[imageAsset assetIdentity] isEqualToString:targetAssetIdentify]) {
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
        QMUILog(@"Group For localIdentifier is not found! groupIdentifier is %@", groupIdentifier);
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

@end


