//
//  QMUIAssetsGroup.m
//  qmui
//
//  Created by Kayo Lee on 15/6/30.
//  Copyright (c) 2015年 QMUI Team. All rights reserved.
//

#import "QMUIAssetsGroup.h"
#import "QMUICommonDefines.h"
#import "QMUIAsset.h"
#import "QMUIAssetsManager.h"

@interface QMUIAssetsGroup()

@property(nonatomic, strong, readwrite) ALAssetsGroup *alAssetsGroup;
@property(nonatomic, strong, readwrite) PHAssetCollection *phAssetCollection;
@property(nonatomic, strong, readwrite) PHFetchResult *phFetchResult;

@end

@implementation QMUIAssetsGroup {
    BOOL _usePhotoKit;
}

- (instancetype)initWithALAssetsGroup:(ALAssetsGroup *)alAssetsGroup {
    self = [super init];
    if (self) {
        self.alAssetsGroup = alAssetsGroup;
        _usePhotoKit = NO;
    }
    return self;
}

- (instancetype)initWithPHCollection:(PHAssetCollection *)phAssetCollection fetchAssetsOptions:(PHFetchOptions *)pHFetchOptions {
    self = [super init];
    if (self) {
        PHFetchResult *phFetchResult = [PHAsset fetchAssetsInAssetCollection:phAssetCollection options:pHFetchOptions];
        self.phFetchResult = phFetchResult;
        self.phAssetCollection = phAssetCollection;
        _usePhotoKit = YES;
    }
    return self;
}

- (instancetype)initWithPHCollection:(PHAssetCollection *)phAssetCollection {
    return [self initWithPHCollection:phAssetCollection fetchAssetsOptions:nil];
}

- (NSInteger)numberOfAssets {
    if (_usePhotoKit) {
        return self.phFetchResult.count;
    } else {
        return [self.alAssetsGroup numberOfAssets];
    }
}

- (NSString *)name {
    NSString *resultName = nil;
    if (_usePhotoKit) {
        resultName = self.phAssetCollection.localizedTitle;
    } else {
        resultName = [self.alAssetsGroup valueForProperty:ALAssetsGroupPropertyName];
    }
    return NSLocalizedString(resultName, resultName);
}

- (UIImage *)posterImageWithSize:(CGSize)size {
    __block UIImage *resultImage;
    if (_usePhotoKit) {
        NSInteger count = self.phFetchResult.count;
        if (count > 0) {
            PHAsset *asset = self.phFetchResult[count - 1];
            PHImageRequestOptions *pHImageRequestOptions = [[PHImageRequestOptions alloc] init];
            pHImageRequestOptions.synchronous = YES; // 同步请求
            pHImageRequestOptions.resizeMode = PHImageRequestOptionsResizeModeExact;
            // targetSize 中对传入的 Size 进行处理，宽高各自乘以 ScreenScale，从而得到正确的图片
            [[[QMUIAssetsManager sharedInstance] phCachingImageManager] requestImageForAsset:asset targetSize:CGSizeMake(size.width * ScreenScale, size.height * ScreenScale) contentMode:PHImageContentModeAspectFill options:pHImageRequestOptions resultHandler:^(UIImage *result, NSDictionary *info) {
                resultImage = result;
            }];
        }
    } else {
        CGImageRef posterImageRef = [self.alAssetsGroup posterImage];
        if (posterImageRef) {
            resultImage = [UIImage imageWithCGImage:posterImageRef];
        }
    }
    return resultImage;
}

- (void)enumerateAssetsWithOptions:(QMUIAlbumSortType)albumSortType usingBlock:(void (^)(QMUIAsset *resultAsset))enumerationBlock {
    if (_usePhotoKit) {
        NSInteger resultCount = self.phFetchResult.count;
        if (albumSortType == QMUIAlbumSortTypeReverse) {
            for (NSInteger i = resultCount - 1; i >= 0; i--) {
                PHAsset *pHAsset = self.phFetchResult[i];
                QMUIAsset *asset = [[QMUIAsset alloc] initWithPHAsset:pHAsset];
                if (enumerationBlock) {
                    enumerationBlock(asset);
                }
            }
        } else {
            for (NSInteger i = 0; i < resultCount; i++) {
                PHAsset *pHAsset = self.phFetchResult[i];
                QMUIAsset *asset = [[QMUIAsset alloc] initWithPHAsset:pHAsset];
                if (enumerationBlock) {
                    enumerationBlock(asset);
                }
            }
        }
        /**
         *  For 循环遍历完毕，这时再调用一次 enumerationBlock，并传递 nil 作为实参，作为枚举资源结束的标记。
         *  该处理方式也是参照系统 ALAssetGroup 枚举结束的处理。
         */
        if (enumerationBlock) {
            enumerationBlock(nil);
        }
    } else {
        NSEnumerationOptions enumerationOptions;
        if (albumSortType == QMUIAlbumSortTypeReverse) {
            enumerationOptions = NSEnumerationReverse;
        } else {
            enumerationOptions = NSEnumerationConcurrent;
        }
        [self.alAssetsGroup enumerateAssetsWithOptions:enumerationOptions usingBlock:^(ALAsset *result, NSUInteger index, BOOL *stop) {
            if (result) {
                QMUIAsset *asset = [[QMUIAsset alloc] initWithALAsset:result];
                if (enumerationBlock) {
                    enumerationBlock(asset);
                }
            } else {
                /**
                 *  ALAssetGroup 枚举结束。
                 *  与上面 PHAssetsFetchResults 相似，再调用一次 enumerationBlock，并传递 nil 作为实参，作为枚举资源结束的标记。
                 *  与 ALAssetGroup 本身处理枚举结束的方式保持一致。
                 */
                if (enumerationBlock) {
                    enumerationBlock(nil);
                }
            }
        }];
        
    }
}

- (void)enumerateAssetsUsingBlock:(void (^)(QMUIAsset *resultAsset))enumerationBlock {
    [self enumerateAssetsWithOptions:QMUIAlbumSortTypePositive usingBlock:enumerationBlock];
}

@end
