//
//  QMUIAsset.m
//  qmui
//
//  Created by Kayo Lee on 15/6/30.
//  Copyright (c) 2015年 QMUI Team. All rights reserved.
//

#import "QMUIAsset.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import <Photos/Photos.h>
#import "QMUICommonDefines.h"
#import "QMUIAssetsManager.h"
#import "NSString+QMUI.h"

@interface QMUIAsset ()

@property (nonatomic, assign, readwrite) QMUIAssetType assetType;

@end


@implementation QMUIAsset {
    BOOL _usePhotoKit;
    
    PHAsset *_phAsset;
    
    ALAsset *_alAsset;
    ALAssetRepresentation *_alAssetRepresentation;
    NSDictionary *_phAssetInfo;
    float imageSize;
    
    NSString *_assetIdentityHash;
}

- (instancetype)initWithPHAsset:(PHAsset *)phAsset {
    if (self = [super init]) {
        _phAsset = phAsset;
        _usePhotoKit = YES;
        
        switch (phAsset.mediaType) {
            case PHAssetMediaTypeImage:
                if (phAsset.mediaSubtypes & PHAssetMediaSubtypePhotoLive) {
                    self.assetType = QMUIAssetTypeLivePhoto;
                } else {
                    self.assetType = QMUIAssetTypeImage;
                }
                break;
            case PHAssetMediaTypeVideo:
                self.assetType = QMUIAssetTypeVideo;
                break;
            case PHAssetMediaTypeAudio:
                self.assetType = QMUIAssetTypeAudio;
                break;
            default:
                self.assetType = QMUIAssetTypeUnknow;
                break;
        }
    }
    return self;
}

- (instancetype)initWithALAsset:(ALAsset *)alAsset {
    if (self = [super init]) {
        _alAsset = alAsset;
        _alAssetRepresentation = [alAsset defaultRepresentation];
        _usePhotoKit = NO;
        
        NSString *propertyType = [alAsset valueForProperty:ALAssetPropertyType];
        if ([propertyType isEqualToString:ALAssetTypePhoto]) {
            self.assetType = QMUIAssetTypeImage;
        } else if ([propertyType isEqualToString:ALAssetTypeVideo]) {
            self.assetType = QMUIAssetTypeVideo;
        } else {
            self.assetType = QMUIAssetTypeUnknow;
        }
    }
    return self;
}

- (UIImage *)originImage {
    __block UIImage *resultImage = nil;
    if (_usePhotoKit) {
        PHImageRequestOptions *phImageRequestOptions = [[PHImageRequestOptions alloc] init];
        phImageRequestOptions.synchronous = YES;
        [[[QMUIAssetsManager sharedInstance] phCachingImageManager] requestImageForAsset:_phAsset
                                                                              targetSize:PHImageManagerMaximumSize
                                                                             contentMode:PHImageContentModeDefault
                                                                                 options:phImageRequestOptions
                                                                           resultHandler:^(UIImage *result, NSDictionary *info) {
                                                                               resultImage = result;
                                                                           }];
    } else {
        CGImageRef fullResolutionImageRef = [_alAssetRepresentation fullResolutionImage];
        // 通过 fullResolutionImage 获取到的的高清图实际上并不带上在照片应用中使用“编辑”处理的效果，需要额外在 AlAssetRepresentation 中获取这些信息
        NSString *adjustment = [[_alAssetRepresentation metadata] objectForKey:@"AdjustmentXMP"];
        if (adjustment) {
            // 如果有在照片应用中使用“编辑”效果，则需要获取这些编辑后的滤镜，手工叠加到原图中
            NSData *xmpData = [adjustment dataUsingEncoding:NSUTF8StringEncoding];
            CIImage *tempImage = [CIImage imageWithCGImage:fullResolutionImageRef];
            
            NSError *error;
            NSArray *filterArray = [CIFilter filterArrayFromSerializedXMP:xmpData
                                                         inputImageExtent:tempImage.extent
                                                                    error:&error];
            CIContext *context = [CIContext contextWithOptions:nil];
            if (filterArray && !error) {
                for (CIFilter *filter in filterArray) {
                    [filter setValue:tempImage forKey:kCIInputImageKey];
                    tempImage = [filter outputImage];
                }
                fullResolutionImageRef = [context createCGImage:tempImage fromRect:[tempImage extent]];
            }   
        }
        // 生成最终返回的 UIImage，同时把图片的 orientation 也补充上去
        resultImage = [UIImage imageWithCGImage:fullResolutionImageRef scale:[_alAssetRepresentation scale] orientation:(UIImageOrientation)[_alAssetRepresentation orientation]];
    }
    return resultImage;
}

- (UIImage *)thumbnailWithSize:(CGSize)size {
    __block UIImage *resultImage;
    if (_usePhotoKit) {
        PHImageRequestOptions *phImageRequestOptions = [[PHImageRequestOptions alloc] init];
        phImageRequestOptions.resizeMode = PHImageRequestOptionsResizeModeExact;
            // 在 PHImageManager 中，targetSize 等 size 都是使用 px 作为单位，因此需要对targetSize 中对传入的 Size 进行处理，宽高各自乘以 ScreenScale，从而得到正确的图片
        [[[QMUIAssetsManager sharedInstance] phCachingImageManager] requestImageForAsset:_phAsset
                                                                              targetSize:CGSizeMake(size.width * ScreenScale, size.height * ScreenScale)
                                                                             contentMode:PHImageContentModeAspectFill options:phImageRequestOptions
                                                                           resultHandler:^(UIImage *result, NSDictionary *info) {
                                                                               resultImage = result;
                                                                           }];
    } else {
        CGImageRef thumbnailImageRef = [_alAsset thumbnail];
        if (thumbnailImageRef) {
            resultImage = [UIImage imageWithCGImage:thumbnailImageRef];
        }
    }
    return resultImage;
}

- (UIImage *)previewImage {
    __block UIImage *resultImage = nil;
    if (_usePhotoKit) {
        PHImageRequestOptions *imageRequestOptions = [[PHImageRequestOptions alloc] init];
        imageRequestOptions.synchronous = YES;
        [[[QMUIAssetsManager sharedInstance] phCachingImageManager] requestImageForAsset:_phAsset
                                                                            targetSize:CGSizeMake(SCREEN_WIDTH, SCREEN_HEIGHT)
                                                                           contentMode:PHImageContentModeAspectFill
                                                                               options:imageRequestOptions
                                                                         resultHandler:^(UIImage *result, NSDictionary *info) {
                                                                             resultImage = result;
                                                                         }];
    } else {
        CGImageRef fullScreenImageRef = [_alAssetRepresentation fullScreenImage];
        resultImage = [UIImage imageWithCGImage:fullScreenImageRef];
    }
    return resultImage;
}

- (NSInteger)requestOriginImageWithCompletion:(void (^)(UIImage *, NSDictionary *))completion withProgressHandler:(PHAssetImageProgressHandler)phProgressHandler {
    if (_usePhotoKit) {
        PHImageRequestOptions *imageRequestOptions = [[PHImageRequestOptions alloc] init];
        imageRequestOptions.networkAccessAllowed = YES; // 允许访问网络
        imageRequestOptions.progressHandler = phProgressHandler;
        return [[[QMUIAssetsManager sharedInstance] phCachingImageManager] requestImageForAsset:_phAsset targetSize:PHImageManagerMaximumSize contentMode:PHImageContentModeDefault options:imageRequestOptions resultHandler:^(UIImage *result, NSDictionary *info) {
            if (completion) {
                completion(result, info);
            }
        }];
    } else {
        if (completion) {
            completion([self originImage], nil);
        }
        return 0;
    }
}

- (NSInteger)requestThumbnailImageWithSize:(CGSize)size completion:(void (^)(UIImage *, NSDictionary *))completion {
    if (_usePhotoKit) {
        PHImageRequestOptions *imageRequestOptions = [[PHImageRequestOptions alloc] init];
        imageRequestOptions.resizeMode = PHImageRequestOptionsResizeModeFast;
        // 在 PHImageManager 中，targetSize 等 size 都是使用 px 作为单位，因此需要对targetSize 中对传入的 Size 进行处理，宽高各自乘以 ScreenScale，从而得到正确的图片
        return [[[QMUIAssetsManager sharedInstance] phCachingImageManager] requestImageForAsset:_phAsset targetSize:CGSizeMake(size.width * ScreenScale, size.height * ScreenScale) contentMode:PHImageContentModeAspectFill options:imageRequestOptions resultHandler:^(UIImage *result, NSDictionary *info) {
              if (completion) {
                  completion(result, info);
              }
        }];

    } else {
        if (completion) {
            completion([self thumbnailWithSize:size], nil);
        }
        return 0;
    }
}

- (NSInteger)requestPreviewImageWithCompletion:(void (^)(UIImage *, NSDictionary *))completion withProgressHandler:(PHAssetImageProgressHandler)phProgressHandler {
    if (_usePhotoKit) {
        PHImageRequestOptions *imageRequestOptions = [[PHImageRequestOptions alloc] init];
        imageRequestOptions.networkAccessAllowed = YES; // 允许访问网络
        imageRequestOptions.progressHandler = phProgressHandler;
        return [[[QMUIAssetsManager sharedInstance] phCachingImageManager] requestImageForAsset:_phAsset targetSize:CGSizeMake(SCREEN_WIDTH, SCREEN_HEIGHT) contentMode:PHImageContentModeAspectFill options:imageRequestOptions resultHandler:^(UIImage *result, NSDictionary *info) {
            if (completion) {
                completion(result, info);
            }
        }];
    } else {
        if (completion) {
            completion([self previewImage], nil);
        }
        return 0;
    }
}

- (NSInteger)requestLivePhotoWithCompletion:(void (^)(PHLivePhoto *, NSDictionary *))completion withProgressHandler:(PHAssetImageProgressHandler)phProgressHandler {
    if (_usePhotoKit && [[PHCachingImageManager class] instancesRespondToSelector:@selector(requestLivePhotoForAsset:targetSize:contentMode:options:resultHandler:)]) {
        PHLivePhotoRequestOptions *livePhotoRequestOptions = [[PHLivePhotoRequestOptions alloc] init];
        livePhotoRequestOptions.networkAccessAllowed = YES; // 允许访问网络
        livePhotoRequestOptions.progressHandler = phProgressHandler;
        return [[[QMUIAssetsManager sharedInstance] phCachingImageManager] requestLivePhotoForAsset:_phAsset targetSize:CGSizeMake(SCREEN_WIDTH, SCREEN_HEIGHT) contentMode:PHImageContentModeDefault options:livePhotoRequestOptions resultHandler:^(PHLivePhoto * _Nullable livePhoto, NSDictionary * _Nullable info) {
            if (completion) {
                completion(livePhoto, info);
            }
        }];
    } else {
        return 0;
    }
}

- (UIImageOrientation)imageOrientation {
    UIImageOrientation orientation;
    if (_usePhotoKit) {
        if (!_phAssetInfo) {
            // PHAsset 的 UIImageOrientation 需要调用过 requestImageDataForAsset 才能获取
            [self requestPhAssetInfo];
        }
        // 从 PhAssetInfo 中获取 UIImageOrientation 对应的字段
        orientation = (UIImageOrientation)[_phAssetInfo[@"orientation"] integerValue];
    } else {
        orientation = (UIImageOrientation)[[_alAsset valueForProperty:@"ALAssetPropertyOrientation"] integerValue];
    }
    return orientation;
}

- (NSString *)assetIdentity {
    if (_assetIdentityHash) {
        return _assetIdentityHash;
    }
    NSString *identity;
    if (_usePhotoKit) {
        identity = _phAsset.localIdentifier;
    } else {
        identity = [[_alAssetRepresentation url] absoluteString];
    }
    // 系统输出的 identity 可能包含特殊字符，为了避免引起问题，统一使用 md5 转换
    _assetIdentityHash = [identity qmui_md5];
    return _assetIdentityHash;
}

- (void)requestPhAssetInfo {
    if (_phAssetInfo || !_phAsset) {
        return;
    }
    PHImageRequestOptions *imageRequestOptions = [[PHImageRequestOptions alloc] init];
    imageRequestOptions.synchronous = YES;
    [[[QMUIAssetsManager sharedInstance] phCachingImageManager] requestImageDataForAsset:_phAsset options:imageRequestOptions resultHandler:^(NSData *imageData, NSString *dataUTI, UIImageOrientation orientation, NSDictionary *info) {
        if (info) {
            NSMutableDictionary *tempInfo = [[NSMutableDictionary alloc] init];
            if (info) {
                [tempInfo addEntriesFromDictionary:info];
            }
            if (dataUTI) {
                [tempInfo setObject:dataUTI forKey:@"dataUTI"];
            }
            [tempInfo setObject:@(orientation) forKey:@"orientation"];
            [tempInfo setObject:@(imageData.length) forKey:@"imageSize"];
            _phAssetInfo = tempInfo;
        }
    }];
}

- (void)setDownloadProgress:(double)downloadProgress {
    _downloadProgress = downloadProgress;
    _downloadStatus = QMUIAssetDownloadStatusDownloading;
}

- (void)updateDownloadStatusWithDownloadResult:(BOOL)succeed {
    _downloadStatus = succeed ? QMUIAssetDownloadStatusSucceed : QMUIAssetDownloadStatusFailed;
}

- (long long)assetSize {
    long long size;
    if (_usePhotoKit) {
        if (!_phAssetInfo) {
            // PHAsset 的 UIImageOrientation 需要调用过 requestImageDataForAsset 才能获取
            [self requestPhAssetInfo];
        }
        // 从 PhAssetInfo 中获取 UIImageOrientation 对应的字段
        size = [_phAssetInfo[@"imageSize"] longLongValue];
    } else {
        size = [_alAsset defaultRepresentation].size;
    }
    return size;
}

@end
