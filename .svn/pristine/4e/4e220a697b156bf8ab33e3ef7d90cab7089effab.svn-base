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
#import <MobileCoreServices/UTCoreTypes.h>
#import "QMUICore.h"
#import "QMUIAssetsManager.h"
#import "NSString+QMUI.h"

static NSString * const kAssetInfoImageData = @"imageData";
static NSString * const kAssetInfoOriginInfo = @"originInfo";
static NSString * const kAssetInfoDataUTI = @"dataUTI";
static NSString * const kAssetInfoOrientation = @"orientation";
static NSString * const kAssetInfoSize = @"size";

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

- (NSInteger)requestOriginImageWithCompletion:(void (^)(UIImage *result, NSDictionary<NSString *, id> *info))completion withProgressHandler:(PHAssetImageProgressHandler)phProgressHandler {
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

- (NSInteger)requestThumbnailImageWithSize:(CGSize)size completion:(void (^)(UIImage *result, NSDictionary<NSString *, id> *info))completion {
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

- (NSInteger)requestPreviewImageWithCompletion:(void (^)(UIImage *result, NSDictionary<NSString *, id> *info))completion withProgressHandler:(PHAssetImageProgressHandler)phProgressHandler {
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

- (NSInteger)requestLivePhotoWithCompletion:(void (^)(PHLivePhoto *livePhoto, NSDictionary<NSString *, id> *info))completion withProgressHandler:(PHAssetImageProgressHandler)phProgressHandler {
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

- (NSInteger)requestPlayerItemWithCompletion:(void (^)(AVPlayerItem *playerItem, NSDictionary<NSString *, id> *info))completion withProgressHandler:(PHAssetVideoProgressHandler)phProgressHandler {
    if (_usePhotoKit && [[PHCachingImageManager class] instancesRespondToSelector:@selector(requestPlayerItemForVideo:options:resultHandler:)]) {
        PHVideoRequestOptions *videoRequestOptions = [[PHVideoRequestOptions alloc] init];
        videoRequestOptions.networkAccessAllowed = YES; // 允许访问网络
        videoRequestOptions.progressHandler = phProgressHandler;
        return [[[QMUIAssetsManager sharedInstance] phCachingImageManager] requestPlayerItemForVideo:_phAsset options:videoRequestOptions resultHandler:^(AVPlayerItem * _Nullable playerItem, NSDictionary * _Nullable info) {
            if (completion) {
                completion(playerItem, info);
            }
        }];
    } else {
        NSURL *url = [_alAssetRepresentation url];
        AVPlayerItem *playerItem = [AVPlayerItem playerItemWithURL:url];
        if (completion) {
            completion(playerItem, nil);
        }
        return 0;
    }
}

- (void)requestImageData:(void (^)(NSData *imageData, NSDictionary<NSString *, id> *info, BOOL isGif))completion {
    if (self.assetType != QMUIAssetTypeImage && self.assetType != QMUIAssetTypeLivePhoto) {
        if (completion) {
            completion(nil, nil, NO);
        }
        return;
    }
    if (_usePhotoKit) {
        if (!_phAssetInfo) {
            // PHAsset 的 UIImageOrientation 需要调用过 requestImageDataForAsset 才能获取
            [self requestPhAssetInfo:^(NSDictionary *phAssetInfo) {
                _phAssetInfo = phAssetInfo;
                if (completion) {
                    NSString *dataUTI = phAssetInfo[kAssetInfoDataUTI];
                    BOOL isGif = [dataUTI isEqualToString:(__bridge NSString *)kUTTypeGIF];
                    NSDictionary<NSString *, id> *originInfo = phAssetInfo[kAssetInfoOriginInfo];
                    /**
                     *  这里不在主线程执行，若用户在该 block 中操作 UI 时会产生一些问题，
                     *  为了避免这种情况，这里该 block 主动放到主线程执行。
                     */
                    dispatch_async(dispatch_get_main_queue(), ^{
                        completion(phAssetInfo[kAssetInfoImageData], originInfo, isGif);
                    });
                }
            }];
        } else {
            if (completion) {
                NSString *dataUTI = _phAssetInfo[kAssetInfoDataUTI];
                BOOL isGif = [dataUTI isEqualToString:(__bridge NSString *)kUTTypeGIF];
                NSDictionary<NSString *, id> *originInfo = _phAssetInfo[kAssetInfoOriginInfo];
                completion(_phAssetInfo[kAssetInfoImageData], originInfo, isGif);
            }
        }
    } else {
        if (completion) {
            [self assetSize:^(long long size) {
                // 获取 NSData 数据
                uint8_t *buffer = malloc((size_t)size);
                NSError *error;
                NSUInteger bytes = [_alAssetRepresentation getBytes:buffer fromOffset:0 length:(NSUInteger)size error:&error];
                NSData *imageData = [NSData dataWithBytes:buffer length:bytes];
                free(buffer);
                // 判断是否为 GIF 图
                ALAssetRepresentation *gifRepresentation = [_alAsset representationForUTI: (__bridge NSString *)kUTTypeGIF];
                if (gifRepresentation) {
                    completion(imageData, nil, YES);
                } else {
                    completion(imageData, nil, NO);
                }
            }];
        }
    }
}

- (UIImageOrientation)imageOrientation {
    UIImageOrientation orientation;
    if (self.assetType == QMUIAssetTypeImage || self.assetType == QMUIAssetTypeLivePhoto) {
        if (_usePhotoKit) {
            if (!_phAssetInfo) {
                // PHAsset 的 UIImageOrientation 需要调用过 requestImageDataForAsset 才能获取
                [self requestImagePhAssetInfo:^(NSDictionary *phAssetInfo) {
                    _phAssetInfo = phAssetInfo;
                } synchronous:YES];
            }
            // 从 PhAssetInfo 中获取 UIImageOrientation 对应的字段
            orientation = (UIImageOrientation)[_phAssetInfo[kAssetInfoOrientation] integerValue];
        } else {
            orientation = (UIImageOrientation)[[_alAsset valueForProperty:@"ALAssetPropertyOrientation"] integerValue];
        }
    } else {
        orientation = UIImageOrientationUp;
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

- (void)requestPhAssetInfo:(void (^)(NSDictionary *))completion {
    if (!_phAsset && completion) {
        completion(nil);
    }
    
    if (self.assetType == QMUIAssetTypeVideo) {
        [[[QMUIAssetsManager sharedInstance] phCachingImageManager] requestAVAssetForVideo:_phAsset options:NULL resultHandler:^(AVAsset * _Nullable asset, AVAudioMix * _Nullable audioMix, NSDictionary * _Nullable info) {
            if ([asset isKindOfClass:[AVURLAsset class]]) {
                NSMutableDictionary *tempInfo = [[NSMutableDictionary alloc] init];
                if (info) {
                    [tempInfo setObject:info forKey:kAssetInfoOriginInfo];
                }
                
                AVURLAsset *urlAsset = (AVURLAsset*)asset;
                NSNumber *size;
                [urlAsset.URL getResourceValue:&size forKey:NSURLFileSizeKey error:nil];
                [tempInfo setObject:size forKey:kAssetInfoSize];
                if (completion) {
                    completion(tempInfo);
                }
            }
        }];
    } else {
        [self requestImagePhAssetInfo:^(NSDictionary *phAssetInfo) {
            if (completion) {
                completion(phAssetInfo);
            }
        } synchronous:NO];
    }
}

- (void)requestImagePhAssetInfo:(void (^)(NSDictionary *))completion synchronous:(BOOL)synchronous {
    PHImageRequestOptions *imageRequestOptions = [[PHImageRequestOptions alloc] init];
    imageRequestOptions.synchronous = synchronous;
    imageRequestOptions.networkAccessAllowed = YES;
    [[[QMUIAssetsManager sharedInstance] phCachingImageManager] requestImageDataForAsset:_phAsset options:imageRequestOptions resultHandler:^(NSData *imageData, NSString *dataUTI, UIImageOrientation orientation, NSDictionary *info) {
        if (info) {
            NSMutableDictionary *tempInfo = [[NSMutableDictionary alloc] init];
            if (imageData) {
                [tempInfo setObject:imageData forKey:kAssetInfoImageData];
                [tempInfo setObject:@(imageData.length) forKey:kAssetInfoSize];
            }
            
            [tempInfo setObject:info forKey:kAssetInfoOriginInfo];
            if (dataUTI) {
                [tempInfo setObject:dataUTI forKey:kAssetInfoDataUTI];
            }
            [tempInfo setObject:@(orientation) forKey:kAssetInfoOrientation];
            if (completion) {
                completion(tempInfo);
            }
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

- (void)assetSize:(void (^)(long long size))completion {
    if (_usePhotoKit) {
        if (!_phAssetInfo) {
            // PHAsset 的 UIImageOrientation 需要调用过 requestImageDataForAsset 才能获取
            [self requestPhAssetInfo:^(NSDictionary *phAssetInfo) {
                _phAssetInfo = phAssetInfo;
                if (completion) {
                    /**
                     *  这里不在主线程执行，若用户在该 block 中操作 UI 时会产生一些问题，
                     *  为了避免这种情况，这里该 block 主动放到主线程执行。
                     */
                    dispatch_async(dispatch_get_main_queue(), ^{
                        completion([phAssetInfo[kAssetInfoSize] longLongValue]);
                    });
                }
            }];
        } else {
            if (completion) {
                completion([_phAssetInfo[kAssetInfoSize] longLongValue]);
            }
        }
    } else {
        if (completion) {
            completion(_alAssetRepresentation.size);
        }
    }
}

- (NSTimeInterval)duration {
    if (self.assetType != QMUIAssetTypeVideo) {
        return 0;
    }
    if (_usePhotoKit) {
        return _phAsset.duration;
    } else {
        return [[_alAsset valueForProperty:ALAssetPropertyDuration] doubleValue];
    }
}

@end
