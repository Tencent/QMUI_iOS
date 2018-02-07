//
//  QMUIAssetsManager.h
//  qmui
//
//  Created by Kayo Lee on 15/6/9.
//  Copyright (c) 2015年 QMUI Team. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import <Photos/PHPhotoLibrary.h>
#import <Photos/PHCollection.h>
#import <Photos/PHFetchResult.h>
#import <Photos/PHAssetChangeRequest.h>
#import <Photos/PHAssetCollectionChangeRequest.h>
#import <Photos/PHFetchOptions.h>
#import <Photos/PHImageManager.h>
#import "QMUIAsset.h"
#import "QMUIAssetsGroup.h"

#define EnforceUseAssetsLibraryForTest NO // 强制在 iOS 8.0 下也使用 ALAssetLibrary，用于调试

/// Asset授权的状态
typedef enum {
    QMUIAssetAuthorizationStatusNotUsingPhotoKit,   // 对于iOS7及以下不支持PhotoKit的系统，没有所谓的“授权状态”，所以定义一个特定的status用于表示这种情况
    QMUIAssetAuthorizationStatusNotDetermined,      // 还不确定有没有授权
    QMUIAssetAuthorizationStatusAuthorized,         // 已经授权
    QMUIAssetAuthorizationStatusNotAuthorized       // 手动禁止了授权
} QMUIAssetAuthorizationStatus;

typedef void (^QMUIWriteAssetCompletionBlock)(QMUIAsset *asset, NSError *error);


/// 保存图片到指定相册，该方法是一个 C 方法，与系统 ALAssetLibrary 保存图片的 C 方法 UIImageWriteToSavedPhotosAlbum 对应，方便调用
extern void QMUIImageWriteToSavedPhotosAlbumWithAlbumAssetsGroup(UIImage *image, QMUIAssetsGroup *albumAssetsGroup, QMUIWriteAssetCompletionBlock completionBlock);

/// 保存视频到指定相册，该方法是一个 C 方法，与系统 ALAssetLibrary 保存图片的 C 方法 UISaveVideoAtPathToSavedPhotosAlbum 对应，方便调用
extern void QMUISaveVideoAtPathToSavedPhotosAlbumWithAlbumAssetsGroup(NSString *videoPath, QMUIAssetsGroup *albumAssetsGroup, QMUIWriteAssetCompletionBlock completionBlock);


@class PHCachingImageManager;

/**
 *  构建 QMUIAssetsManager 这个对象并提供单例的调用方式主要出于下面几点考虑：
 *  1. 由于需要有同时兼顾 ALAssetsLibrary 和 PhotoKit 的保存图片方法，因此保存图片的方法变得比较复杂。
 *     这时有一个不同于 ALAssetsLibrary 和 PhotoKit 的对象去定义这些保存图片的方法会更便于管理这些方法。
 *  2. 如果使用 ALAssetsLibrary 保存图片，那么最终都会调用 ALAssetsLibrary 的一个实例方法，
 *     而 init ALAssetsLibrary 消耗比较大，因此构建一个单例对象，在对象内部 init 一个 ALAssetsLibrary，
 *     需要保存图片到指定相册时建议统一调用这个单例的方法，减少重复消耗。
 *  3. 与上面相似，使用 PhotoKit 获取图片，基本都需要一个 PHCachingImageManager 的实例，为了减少消耗，
 *     所以 QMUIAssetsManager 单例内部也构建了一个 PHCachingImageManager，并且暴露给外面，方便获取
 *     PHCachingImageManager 的实例。
 */
@interface QMUIAssetsManager : NSObject

/// 获取 QMUIAssetsManager 的单例
+ (instancetype)sharedInstance;

/// 获取当前应用的“照片”访问授权状态
+ (QMUIAssetAuthorizationStatus)authorizationStatus;

/**
 *  调起系统询问是否授权访问“照片”的 UIAlertView
 *  @param handler 授权结束后调用的 block，默认不在主线程上执行，如果需要在 block 中修改 UI，记得dispatch到mainqueue
 */
+ (void)requestAuthorization:(void(^)(QMUIAssetAuthorizationStatus status))handler;

/**
 *  获取所有的相册，在 iOS 8.0 及以上版本中，同时在该方法内部调用了 PhotoKit，可以获取如个人收藏，最近添加，自拍这类“智能相册”
 *
 *  @param contentType               相册的内容类型，设定了内容类型后，所获取的相册中只包含对应类型的资源
 *  @param showEmptyAlbum            是否显示空相册（经过 contentType 过滤后仍为空的相册）
 *  @param showSmartAlbumIfSupported 是否显示"智能相册"（仅 iOS 8.0 及以上版本可以显示“智能相册”）
 *  @param enumerationBlock          参数 resultAssetsGroup 表示每次枚举时对应的相册。枚举所有相册结束后，enumerationBlock 会被再调用一次，
 *                                   这时 resultAssetsGroup 的值为 nil。可以以此作为判断枚举结束的标记。
 */
- (void)enumerateAllAlbumsWithAlbumContentType:(QMUIAlbumContentType)contentType showEmptyAlbum:(BOOL)showEmptyAlbum showSmartAlbumIfSupported:(BOOL)showSmartAlbumIfSupported usingBlock:(void (^)(QMUIAssetsGroup *resultAssetsGroup))enumerationBlock;

/// 获取所有相册，默认在 iOS 8.0 及以上系统中显示系统的“智能相册”，不显示空相册（经过 contentType 过滤后为空的相册）
- (void)enumerateAllAlbumsWithAlbumContentType:(QMUIAlbumContentType)contentType usingBlock:(void (^)(QMUIAssetsGroup *resultAssetsGroup))enumerationBlock;

/**
 *  保存图片或视频到指定的相册
 *
 *  @warning 无论用户保存到哪个自行创建的相册，系统都会在“相机胶卷”相册中同时保存这个图片。
 *           因为系统没有把图片和视频直接保存到指定相册的接口，都只能先保存到“相机胶卷”，从而生成了 Asset 对象，
 *           再把 Asset 对象添加到指定相册中，从而达到保存资源到指定相册的效果。
 *           即使调用 PhotoKit 保存图片或视频到指定相册的新接口也是如此，并且官方 PhotoKit SampleCode 中例子也是表现如此，
 *           因此这应该是一个合符官方预期的表现。
 *  @warning 在支持“智能相册”的系统版本（iOS 8.0 及以上版本）也中无法通过该方法把图片保存到“智能相册”，
 *           “智能相册”只能由系统控制资源的增删。
 */
- (void)saveImageWithImageRef:(CGImageRef)imageRef albumAssetsGroup:(QMUIAssetsGroup *)albumAssetsGroup orientation:(UIImageOrientation)orientation completionBlock:(QMUIWriteAssetCompletionBlock)completionBlock;

- (void)saveVideoWithVideoPathURL:(NSURL *)videoPathURL albumAssetsGroup:(QMUIAssetsGroup *)albumAssetsGroup completionBlock:(QMUIWriteAssetCompletionBlock)completionBlock;

/// 强制刷新单例中的 ALAssetLibrary，但你的相册资源发生改变时（创建或删除相册）可以手工调用该方法及时更新
- (void)refreshAssetsLibrary;

/// 获取一个 ALAssetsLibrary 的实例
- (ALAssetsLibrary *)alAssetsLibrary;

/// 获取一个 PHCachingImageManager 的实例
- (PHCachingImageManager *)phCachingImageManager;

@end


@interface PHPhotoLibrary (QMUI)

/**
 *  根据 contentType 的值产生一个合适的 PHFetchOptions，并把内容以资源创建日期排序，创建日期较新的资源排在前面
 *
 *  @param contentType 相册的内容类型
 *
 *  @return 返回一个合适的 PHFetchOptions
 */
+ (PHFetchOptions *)createFetchOptionsWithAlbumContentType:(QMUIAlbumContentType)contentType;

/**
 *  获取所有相册
 *
 *  @param contentType    相册的内容类型，设定了内容类型后，所获取的相册中只包含对应类型的资源
 *  @param showEmptyAlbum 是否显示空相册（经过 contentType 过滤后仍为空的相册）
 *  @param showSmartAlbum 是否显示“智能相册”
 *
 *  @return 返回包含所有合适相册的数组
 */
+ (NSArray *)fetchAllAlbumsWithAlbumContentType:(QMUIAlbumContentType)contentType showEmptyAlbum:(BOOL)showEmptyAlbum showSmartAlbum:(BOOL)showSmartAlbum;

/// 获取一个 PHAssetCollection 中创建日期最新的资源
+ (PHAsset *)fetchLatestAssetWithAssetCollection:(PHAssetCollection *)assetCollection;

/**
 *  保存图片或视频到指定的相册
 *
 *  @warning 无论用户保存到哪个自行创建的相册，系统都会在“相机胶卷”相册中同时保存这个图片。
 *           原因请参考 QMUIAssetsManager 对象的保存图片和视频方法的注释。
 *  @warning 无法通过该方法把图片保存到“智能相册”，“智能相册”只能由系统控制资源的增删。
 */
- (void)addImageToAlbum:(CGImageRef)imageRef albumAssetCollection:(PHAssetCollection *)albumAssetCollection orientation:(UIImageOrientation)orientation completionHandler:(void(^)(BOOL success, NSError *error))completionHandler;

- (void)addVideoToAlbum:(NSURL *)videoPathURL albumAssetCollection:(PHAssetCollection *)albumAssetCollection completionHandler:(void(^)(BOOL success, NSError *error))completionHandler;

@end


@interface ALAssetsLibrary (QMUI)

/**
 *  获取所有相册
 *
 *  @param contentType      相册的内容类型，设定了内容类型后，所获取的相册中只包含对应类型的资源
 *  @param enumerationBlock 参数 group 表示每次枚举时对应的相册。枚举所有相册结束后，enumerationBlock 会被再调用一次，
 *                          这时 group 的值为 nil。可以以此作为判断枚举结束的标记。
 */
- (void)enumerateAllAlbumsWithAlbumContentType:(QMUIAlbumContentType)contentType usingBlock:(ALAssetsLibraryGroupsEnumerationResultsBlock)enumerationBlock;

/**
 *  保存图片或视频到指定的相册
 *
 *  @warning 无论用户保存到哪个自行创建的相册，系统都会在“相机胶卷”相册中同时保存这个图片。
 *           原因请参考 QMUIAssetsManager 对象的保存图片和视频方法的注释。
 *           如果直接调用该接口保存图片或视频到“相机胶卷”中，并不会产生重复保存。
 */
- (void)writeImageToSavedPhotosAlbum:(CGImageRef)imageRef albumAssetsGroup:(ALAssetsGroup *)albumAssetsGroup orientation:(UIImageOrientation)orientation completionBlock:(ALAssetsLibraryWriteImageCompletionBlock)completionBlock;

- (void)writeVideoAtPathToSavedPhotosAlbum:(NSURL *)videoPathURL albumAssetsGroup:(ALAssetsGroup *)albumAssetsGroup completionBlock:(ALAssetsLibraryWriteImageCompletionBlock)completionBlock;

@end
