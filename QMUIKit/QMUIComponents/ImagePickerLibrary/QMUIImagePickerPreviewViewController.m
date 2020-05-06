/**
 * Tencent is pleased to support the open source community by making QMUI_iOS available.
 * Copyright (C) 2016-2020 THL A29 Limited, a Tencent company. All rights reserved.
 * Licensed under the MIT License (the "License"); you may not use this file except in compliance with the License. You may obtain a copy of the License at
 * http://opensource.org/licenses/MIT
 * Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.
 */

//
//  QMUIImagePickerPreviewViewController.m
//  qmui
//
//  Created by QMUI Team on 15/5/3.
//

#import "QMUIImagePickerPreviewViewController.h"
#import "QMUICore.h"
#import "QMUIImagePickerViewController.h"
#import "QMUIImagePickerHelper.h"
#import "QMUIAssetsManager.h"
#import "QMUIZoomImageView.h"
#import "QMUIAsset.h"
#import "QMUIButton.h"
#import "QMUINavigationButton.h"
#import "QMUIImagePickerHelper.h"
#import "QMUIPieProgressView.h"
#import "QMUIAlertController.h"
#import "UIImage+QMUI.h"
#import "UIView+QMUI.h"
#import "UIControl+QMUI.h"
#import "QMUILog.h"
#import "QMUIAppearance.h"

#pragma mark - QMUIImagePickerPreviewViewController (UIAppearance)

@implementation QMUIImagePickerPreviewViewController (UIAppearance)

+ (instancetype)appearance {
    return [QMUIAppearance appearanceForClass:self];
}

+ (void)initialize {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        [self initAppearance];
    });
}

+ (void)initAppearance {
    QMUIImagePickerPreviewViewController.appearance.toolBarBackgroundColor = UIColorMakeWithRGBA(27, 27, 27, .9f);
    QMUIImagePickerPreviewViewController.appearance.toolBarTintColor = UIColorWhite;
}

@end

@implementation QMUIImagePickerPreviewViewController {
    BOOL _singleCheckMode;
}

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        self.maximumSelectImageCount = INT_MAX;
        self.minimumSelectImageCount = 0;
        
        [self qmui_applyAppearance];
    }
    return self;
}

- (void)initSubviews {
    [super initSubviews];
    
    self.imagePreviewView.delegate = self;
    
    _topToolBarView = [[UIView alloc] init];
    self.topToolBarView.backgroundColor = self.toolBarBackgroundColor;
    self.topToolBarView.tintColor = self.toolBarTintColor;
    [self.view addSubview:self.topToolBarView];
    
    _backButton = [[QMUINavigationButton alloc] initWithType:QMUINavigationButtonTypeBack];
    [self.backButton addTarget:self action:@selector(handleCancelPreviewImage:) forControlEvents:UIControlEventTouchUpInside];
    self.backButton.qmui_outsideEdge = UIEdgeInsetsMake(-30, -20, -50, -80);
    [self.topToolBarView addSubview:self.backButton];
    
    _checkboxButton = [[QMUIButton alloc] init];
    self.checkboxButton.adjustsTitleTintColorAutomatically = YES;
    self.checkboxButton.adjustsImageTintColorAutomatically = YES;
    UIImage *checkboxImage = [QMUIHelper imageWithName:@"QMUI_previewImage_checkbox"];
    UIImage *checkedCheckboxImage = [QMUIHelper imageWithName:@"QMUI_previewImage_checkbox_checked"];
    [self.checkboxButton setImage:checkboxImage forState:UIControlStateNormal];
    [self.checkboxButton setImage:checkedCheckboxImage forState:UIControlStateSelected];
    [self.checkboxButton setImage:[self.checkboxButton imageForState:UIControlStateSelected] forState:UIControlStateSelected|UIControlStateHighlighted];
    [self.checkboxButton sizeToFit];
    [self.checkboxButton addTarget:self action:@selector(handleCheckButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    self.checkboxButton.qmui_outsideEdge = UIEdgeInsetsMake(-6, -6, -6, -6);
    [self.topToolBarView addSubview:self.checkboxButton];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if (!_singleCheckMode) {
        QMUIAsset *imageAsset = self.imagesAssetArray[self.imagePreviewView.currentImageIndex];
        self.checkboxButton.selected = [self.selectedImageAssetArray containsObject:imageAsset];
    }
    
    if ([self conformsToProtocol:@protocol(QMUICustomNavigationBarTransitionDelegate)]) {
        UIViewController<QMUICustomNavigationBarTransitionDelegate> *vc = (UIViewController<QMUICustomNavigationBarTransitionDelegate> *)self;
        if ([vc respondsToSelector:@selector(shouldCustomizeNavigationBarTransitionIfHideable)] &&
            [vc shouldCustomizeNavigationBarTransitionIfHideable]) {
        } else {
            [self.navigationController setNavigationBarHidden:YES animated:NO];
        }
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    if ([self conformsToProtocol:@protocol(QMUICustomNavigationBarTransitionDelegate)]) {
        UIViewController<QMUICustomNavigationBarTransitionDelegate> *vc = (UIViewController<QMUICustomNavigationBarTransitionDelegate> *)self;
        if ([vc respondsToSelector:@selector(shouldCustomizeNavigationBarTransitionIfHideable)] &&
            [vc shouldCustomizeNavigationBarTransitionIfHideable]) {
        } else {
            [self.navigationController setNavigationBarHidden:NO animated:NO];
        }
    }
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    self.topToolBarView.frame = CGRectMake(0, 0, CGRectGetWidth(self.view.bounds), NavigationContentTopConstant);
    CGFloat topToolbarPaddingTop = SafeAreaInsetsConstantForDeviceWithNotch.top;
    CGFloat topToolbarContentHeight = CGRectGetHeight(self.topToolBarView.bounds) - topToolbarPaddingTop;
    self.backButton.frame = CGRectSetXY(self.backButton.frame, 16 + self.view.qmui_safeAreaInsets.left, topToolbarPaddingTop + CGFloatGetCenter(topToolbarContentHeight, CGRectGetHeight(self.backButton.frame)));
    if (!self.checkboxButton.hidden) {
        self.checkboxButton.frame = CGRectSetXY(self.checkboxButton.frame, CGRectGetWidth(self.topToolBarView.frame) - 10 - self.view.qmui_safeAreaInsets.right - CGRectGetWidth(self.checkboxButton.frame), topToolbarPaddingTop + CGFloatGetCenter(topToolbarContentHeight, CGRectGetHeight(self.checkboxButton.frame)));
    }
}

- (BOOL)preferredNavigationBarHidden {
    return YES;
}

- (BOOL)prefersStatusBarHidden {
    return YES;
}

- (void)setToolBarBackgroundColor:(UIColor *)toolBarBackgroundColor {
    _toolBarBackgroundColor = toolBarBackgroundColor;
    self.topToolBarView.backgroundColor = self.toolBarBackgroundColor;
}

- (void)setToolBarTintColor:(UIColor *)toolBarTintColor {
    _toolBarTintColor = toolBarTintColor;
    self.topToolBarView.tintColor = toolBarTintColor;
}

- (void)setDownloadStatus:(QMUIAssetDownloadStatus)downloadStatus {
    _downloadStatus = downloadStatus;
    if (!_singleCheckMode) {
        self.checkboxButton.hidden = NO;
    }
}

- (void)updateImagePickerPreviewViewWithImagesAssetArray:(NSMutableArray<QMUIAsset *> *)imageAssetArray
                                 selectedImageAssetArray:(NSMutableArray<QMUIAsset *> *)selectedImageAssetArray
                                       currentImageIndex:(NSInteger)currentImageIndex
                                         singleCheckMode:(BOOL)singleCheckMode {
    self.imagesAssetArray = imageAssetArray;
    self.selectedImageAssetArray = selectedImageAssetArray;
    self.imagePreviewView.currentImageIndex = currentImageIndex;
    _singleCheckMode = singleCheckMode;
    if (singleCheckMode) {
        self.checkboxButton.hidden = YES;
    }
}

#pragma mark - <QMUIImagePreviewViewDelegate>

- (NSUInteger)numberOfImagesInImagePreviewView:(QMUIImagePreviewView *)imagePreviewView {
    return [self.imagesAssetArray count];
}

- (QMUIImagePreviewMediaType)imagePreviewView:(QMUIImagePreviewView *)imagePreviewView assetTypeAtIndex:(NSUInteger)index {
    QMUIAsset *imageAsset = [self.imagesAssetArray objectAtIndex:index];
    if (imageAsset.assetType == QMUIAssetTypeImage) {
        if (@available(iOS 9.1, *)) {
            if (imageAsset.assetSubType == QMUIAssetSubTypeLivePhoto) {
                return QMUIImagePreviewMediaTypeLivePhoto;
            }
        }
        return QMUIImagePreviewMediaTypeImage;
    } else if (imageAsset.assetType == QMUIAssetTypeVideo) {
        return QMUIImagePreviewMediaTypeVideo;
    } else {
        return QMUIImagePreviewMediaTypeOthers;
    }
}

- (void)imagePreviewView:(QMUIImagePreviewView *)imagePreviewView renderZoomImageView:(QMUIZoomImageView *)zoomImageView atIndex:(NSUInteger)index {
    [self requestImageForZoomImageView:zoomImageView withIndex:index];
}

- (void)imagePreviewView:(QMUIImagePreviewView *)imagePreviewView willScrollHalfToIndex:(NSUInteger)index {
    if (!_singleCheckMode) {
        QMUIAsset *imageAsset = self.imagesAssetArray[index];
        self.checkboxButton.selected = [self.selectedImageAssetArray containsObject:imageAsset];
    }
}

#pragma mark - <QMUIZoomImageViewDelegate>

- (void)singleTouchInZoomingImageView:(QMUIZoomImageView *)zoomImageView location:(CGPoint)location {
    self.topToolBarView.hidden = !self.topToolBarView.hidden;
}

- (void)didTouchICloudRetryButtonInZoomImageView:(QMUIZoomImageView *)imageView {
    NSInteger index = [self.imagePreviewView indexForZoomImageView:imageView];
    [self.imagePreviewView.collectionView reloadItemsAtIndexPaths:@[[NSIndexPath indexPathForItem:index inSection:0]]];
}

- (void)zoomImageView:(QMUIZoomImageView *)imageView didHideVideoToolbar:(BOOL)didHide {
    self.topToolBarView.hidden = didHide;
}

#pragma mark - 按钮点击回调

- (void)handleCancelPreviewImage:(QMUIButton *)button {
    if (self.navigationController) {
        [self.navigationController popViewControllerAnimated:YES];
    } else {
//        [self exitPreviewAutomatically];
    }
    if (self.delegate && [self.delegate respondsToSelector:@selector(imagePickerPreviewViewControllerDidCancel:)]) {
        [self.delegate imagePickerPreviewViewControllerDidCancel:self];
    }
}

- (void)handleCheckButtonClick:(QMUIButton *)button {
    [QMUIImagePickerHelper removeSpringAnimationOfImageCheckedWithCheckboxButton:button];
    
    if (button.selected) {
        if ([self.delegate respondsToSelector:@selector(imagePickerPreviewViewController:willUncheckImageAtIndex:)]) {
            [self.delegate imagePickerPreviewViewController:self willUncheckImageAtIndex:self.imagePreviewView.currentImageIndex];
        }
        
        button.selected = NO;
        QMUIAsset *imageAsset = self.imagesAssetArray[self.imagePreviewView.currentImageIndex];
        [self.selectedImageAssetArray removeObject:imageAsset];
        
        if ([self.delegate respondsToSelector:@selector(imagePickerPreviewViewController:didUncheckImageAtIndex:)]) {
            [self.delegate imagePickerPreviewViewController:self didUncheckImageAtIndex:self.imagePreviewView.currentImageIndex];
        }
    } else {
        if ([self.selectedImageAssetArray count] >= self.maximumSelectImageCount) {
            if (!self.alertTitleWhenExceedMaxSelectImageCount) {
                self.alertTitleWhenExceedMaxSelectImageCount = [NSString stringWithFormat:@"你最多只能选择%@张图片", @(self.maximumSelectImageCount)];
            }
            if (!self.alertButtonTitleWhenExceedMaxSelectImageCount) {
                self.alertButtonTitleWhenExceedMaxSelectImageCount = [NSString stringWithFormat:@"我知道了"];
            }
            
            QMUIAlertController *alertController = [QMUIAlertController alertControllerWithTitle:self.alertTitleWhenExceedMaxSelectImageCount message:nil preferredStyle:QMUIAlertControllerStyleAlert];
            [alertController addAction:[QMUIAlertAction actionWithTitle:self.alertButtonTitleWhenExceedMaxSelectImageCount style:QMUIAlertActionStyleCancel handler:nil]];
            [alertController showWithAnimated:YES];
            return;
        }
        
        if (self.delegate && [self.delegate respondsToSelector:@selector(imagePickerPreviewViewController:willCheckImageAtIndex:)]) {
            [self.delegate imagePickerPreviewViewController:self willCheckImageAtIndex:self.imagePreviewView.currentImageIndex];
        }
        
        button.selected = YES;
        [QMUIImagePickerHelper springAnimationOfImageCheckedWithCheckboxButton:button];
        QMUIAsset *imageAsset = [self.imagesAssetArray objectAtIndex:self.imagePreviewView.currentImageIndex];
        [self.selectedImageAssetArray addObject:imageAsset];
        
        if (self.delegate && [self.delegate respondsToSelector:@selector(imagePickerPreviewViewController:didCheckImageAtIndex:)]) {
            [self.delegate imagePickerPreviewViewController:self didCheckImageAtIndex:self.imagePreviewView.currentImageIndex];
        }
    }
}

#pragma mark - Request Image

- (void)requestImageForZoomImageView:(QMUIZoomImageView *)zoomImageView withIndex:(NSInteger)index {
    QMUIZoomImageView *imageView = zoomImageView ? : [self.imagePreviewView zoomImageViewAtIndex:index];
    // 如果是走 PhotoKit 的逻辑，那么这个 block 会被多次调用，并且第一次调用时返回的图片是一张小图，
    // 拉取图片的过程中可能会多次返回结果，且图片尺寸越来越大，因此这里调整 contentMode 以防止图片大小跳动
    imageView.contentMode = UIViewContentModeScaleAspectFit;
    QMUIAsset *imageAsset = [self.imagesAssetArray objectAtIndex:index];
    // 获取资源图片的预览图，这是一张适合当前设备屏幕大小的图片，最终展示时把图片交给组件控制最终展示出来的大小。
    // 系统相册本质上也是这么处理的，因此无论是系统相册，还是这个系列组件，由始至终都没有显示照片原图，
    // 这也是系统相册能加载这么快的原因。
    // 另外这里采用异步请求获取图片，避免获取图片时 UI 卡顿
    PHAssetImageProgressHandler phProgressHandler = ^(double progress, NSError *error, BOOL *stop, NSDictionary *info) {
        imageAsset.downloadProgress = progress;
        dispatch_async(dispatch_get_main_queue(), ^{
            QMUILogInfo(@"QMUIImagePickerLibrary", @"Download iCloud image in preview, current progress is: %f", progress);
            
            if (self.downloadStatus != QMUIAssetDownloadStatusDownloading) {
                self.downloadStatus = QMUIAssetDownloadStatusDownloading;
                imageView.cloudDownloadStatus = QMUIAssetDownloadStatusDownloading;

                // 重置 progressView 的显示的进度为 0
                [imageView.cloudProgressView setProgress:0 animated:NO];
            }
            // 拉取资源的初期，会有一段时间没有进度，猜测是发出网络请求以及与 iCloud 建立连接的耗时，这时预先给个 0.02 的进度值，看上去好看些
            float targetProgress = fmax(0.02, progress);
            if (targetProgress < imageView.cloudProgressView.progress) {
                [imageView.cloudProgressView setProgress:targetProgress animated:NO];
            } else {
                imageView.cloudProgressView.progress = fmax(0.02, progress);
            }
            if (error) {
                QMUILog(@"QMUIImagePickerLibrary", @"Download iCloud image Failed, current progress is: %f", progress);
                self.downloadStatus = QMUIAssetDownloadStatusFailed;
                imageView.cloudDownloadStatus = QMUIAssetDownloadStatusFailed;
            }
        });
    };
    if (imageAsset.assetType == QMUIAssetTypeVideo) {
        imageView.tag = -1;
        imageAsset.requestID = [imageAsset requestPlayerItemWithCompletion:^(AVPlayerItem *playerItem, NSDictionary *info) {
            // 这里可能因为 imageView 复用，导致前面的请求得到的结果显示到别的 imageView 上，
            // 因此判断如果是新请求（无复用问题）或者是当前的请求才把获得的图片结果展示出来
            dispatch_async(dispatch_get_main_queue(), ^{
                BOOL isNewRequest = (imageView.tag == -1 && imageAsset.requestID == 0);
                BOOL isCurrentRequest = imageView.tag == imageAsset.requestID;
                BOOL loadICloudImageFault = !playerItem || info[PHImageErrorKey];
                if (!loadICloudImageFault && (isNewRequest || isCurrentRequest)) {
                    imageView.videoPlayerItem = playerItem;
                }
            });
        } withProgressHandler:phProgressHandler];
        imageView.tag = imageAsset.requestID;
    } else {
        if (imageAsset.assetType != QMUIAssetTypeImage) {
            return;
        }
        
        // 这么写是为了消除 Xcode 的 API available warning
        BOOL isLivePhoto = NO;
        if (@available(iOS 9.1, *)) {
            if (imageAsset.assetSubType == QMUIAssetSubTypeLivePhoto) {
                isLivePhoto = YES;
                imageView.tag = -1;
                imageAsset.requestID = [imageAsset requestLivePhotoWithCompletion:^void(PHLivePhoto *livePhoto, NSDictionary *info) {
                    // 这里可能因为 imageView 复用，导致前面的请求得到的结果显示到别的 imageView 上，
                    // 因此判断如果是新请求（无复用问题）或者是当前的请求才把获得的图片结果展示出来
                    dispatch_async(dispatch_get_main_queue(), ^{
                        BOOL isNewRequest = (imageView.tag == -1 && imageAsset.requestID == 0);
                        BOOL isCurrentRequest = imageView.tag == imageAsset.requestID;
                        BOOL loadICloudImageFault = !livePhoto || info[PHImageErrorKey];
                        if (!loadICloudImageFault && (isNewRequest || isCurrentRequest)) {
                            // 如果是走 PhotoKit 的逻辑，那么这个 block 会被多次调用，并且第一次调用时返回的图片是一张小图，
                            // 这时需要把图片放大到跟屏幕一样大，避免后面加载大图后图片的显示会有跳动
                            if (@available(iOS 9.1, *)) {
                                imageView.livePhoto = livePhoto;
                            }
                        }
                        BOOL downloadSucceed = (livePhoto && !info) || (![[info objectForKey:PHLivePhotoInfoCancelledKey] boolValue] && ![info objectForKey:PHLivePhotoInfoErrorKey] && ![[info objectForKey:PHLivePhotoInfoIsDegradedKey] boolValue]);
                        if (downloadSucceed) {
                            // 资源资源已经在本地或下载成功
                            [imageAsset updateDownloadStatusWithDownloadResult:YES];
                            self.downloadStatus = QMUIAssetDownloadStatusSucceed;
                            imageView.cloudDownloadStatus = QMUIAssetDownloadStatusSucceed;
                        } else if ([info objectForKey:PHLivePhotoInfoErrorKey] ) {
                            // 下载错误
                            [imageAsset updateDownloadStatusWithDownloadResult:NO];
                            self.downloadStatus = QMUIAssetDownloadStatusFailed;
                            imageView.cloudDownloadStatus = QMUIAssetDownloadStatusFailed;
                        }
                    });
                } withProgressHandler:phProgressHandler];
                imageView.tag = imageAsset.requestID;
            }
        }
        
        if (isLivePhoto) {
        } else if (imageAsset.assetSubType == QMUIAssetSubTypeGIF) {
            [imageAsset requestImageData:^(NSData *imageData, NSDictionary<NSString *,id> *info, BOOL isGIF, BOOL isHEIC) {
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                    UIImage *resultImage = [UIImage qmui_animatedImageWithData:imageData];
                    dispatch_async(dispatch_get_main_queue(), ^{
                        imageView.image = resultImage;
                    });
                });
            }];
        } else {
            imageView.tag = -1;
            imageView.image = [imageAsset thumbnailWithSize:CGSizeMake([QMUIImagePickerViewController appearance].minimumImageWidth, [QMUIImagePickerViewController appearance].minimumImageWidth)];
            imageAsset.requestID = [imageAsset requestOriginImageWithCompletion:^void(UIImage *result, NSDictionary *info) {
                // 这里可能因为 imageView 复用，导致前面的请求得到的结果显示到别的 imageView 上，
                // 因此判断如果是新请求（无复用问题）或者是当前的请求才把获得的图片结果展示出来
                dispatch_async(dispatch_get_main_queue(), ^{
                    BOOL isNewRequest = (imageView.tag == -1 && imageAsset.requestID == 0);
                    BOOL isCurrentRequest = imageView.tag == imageAsset.requestID;
                    BOOL loadICloudImageFault = !result || info[PHImageErrorKey];
                    if (!loadICloudImageFault && (isNewRequest || isCurrentRequest)) {
                        imageView.image = result;
                    }
                    BOOL downloadSucceed = (result && !info) || (![[info objectForKey:PHImageCancelledKey] boolValue] && ![info objectForKey:PHImageErrorKey] && ![[info objectForKey:PHImageResultIsDegradedKey] boolValue]);
                    if (downloadSucceed) {
                        // 资源资源已经在本地或下载成功
                        [imageAsset updateDownloadStatusWithDownloadResult:YES];
                        self.downloadStatus = QMUIAssetDownloadStatusSucceed;
                        imageView.cloudDownloadStatus = QMUIAssetDownloadStatusSucceed;
                    } else if ([info objectForKey:PHImageErrorKey] ) {
                        // 下载错误
                        [imageAsset updateDownloadStatusWithDownloadResult:NO];
                        self.downloadStatus = QMUIAssetDownloadStatusFailed;
                        imageView.cloudDownloadStatus = QMUIAssetDownloadStatusFailed;
                    }
                });
            } withProgressHandler:phProgressHandler];
            imageView.tag = imageAsset.requestID;
        }
    }
}

@end
