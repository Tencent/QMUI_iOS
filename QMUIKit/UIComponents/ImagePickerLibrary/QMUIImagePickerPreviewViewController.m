//
//  QMUIImagePickerPreviewViewController.m
//  qmui
//
//  Created by Kayo Lee on 15/5/3.
//  Copyright (c) 2015年 QMUI Team. All rights reserved.
//

#import "QMUIImagePickerPreviewViewController.h"
#import "QMUICommonDefines.h"
#import "QMUIConfiguration.h"
#import "QMUIHelper.h"
#import "QMUIImagePickerViewController.h"
#import "QMUIImagePickerHelper.h"
#import "QMUIAssetsManager.h"
#import "QMUIZoomImageView.h"
#import "QMUIAsset.h"
#import "QMUIButton.h"
#import "QMUIImagePickerHelper.h"
#import "QMUIPieProgressView.h"
#import "QMUIAlertController.h"
#import "UIImage+QMUI.h"
#import "UIView+QMUI.h"
#import "UIControl+QMUI.h"
#import <AssetsLibrary/AssetsLibrary.h>

#define TopToolBarViewHeight 64

#pragma mark - QMUIImagePickerPreviewViewController (UIAppearance)

@implementation QMUIImagePickerPreviewViewController (UIAppearance)

+ (void)initialize {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        [self appearance]; // +initialize 时就先设置好默认样式
    });
}

static QMUIImagePickerPreviewViewController *imagePickerPreviewViewControllerAppearance;
+ (instancetype)appearance {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (!imagePickerPreviewViewControllerAppearance) {
            imagePickerPreviewViewControllerAppearance = [[QMUIImagePickerPreviewViewController alloc] init];
            imagePickerPreviewViewControllerAppearance.toolBarBackgroundColor = UIColorMakeWithRGBA(27, 27, 27, .9f);
            imagePickerPreviewViewControllerAppearance.toolBarTintColor = UIColorWhite;
        }
    });
    return imagePickerPreviewViewControllerAppearance;
}

@end

@implementation QMUIImagePickerPreviewViewController {
    BOOL _singleCheckMode;
    BOOL _usePhotoKit;
}

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        self.maximumSelectImageCount = INT_MAX;
        self.minimumSelectImageCount = 0;
        _usePhotoKit = EnforceUseAssetsLibraryForTest ? NO : ((IOS_VERSION >= 8.0) ? YES : NO);
        
        if (imagePickerPreviewViewControllerAppearance) {
            // 避免 imagePickerPreviewViewControllerAppearance init 时走到这里来，导致死循环
            self.toolBarBackgroundColor = [QMUIImagePickerPreviewViewController appearance].toolBarBackgroundColor;
            self.toolBarTintColor = [QMUIImagePickerPreviewViewController appearance].toolBarTintColor;
        }
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
    
    _backButton = [[QMUIButton alloc] init];
    self.backButton.adjustsImageTintColorAutomatically = YES;
    [self.backButton setImage:NavBarBackIndicatorImage forState:UIControlStateNormal];
    self.backButton.tintColor = self.topToolBarView.tintColor;
    [self.backButton sizeToFit];
    [self.backButton addTarget:self action:@selector(handleCancelPreviewImage:) forControlEvents:UIControlEventTouchUpInside];
    self.backButton.qmui_outsideEdge = UIEdgeInsetsMake(-30, -20, -50, -80);
    [self.topToolBarView addSubview:self.backButton];
    
    _checkboxButton = [[QMUIButton alloc] init];
    self.checkboxButton.adjustsImageTintColorAutomatically = YES;
    [self.checkboxButton setImage:[QMUIHelper imageWithName:@"QMUI_previewImage_checkbox"] forState:UIControlStateNormal];
    [self.checkboxButton setImage:[QMUIHelper imageWithName:@"QMUI_previewImage_checkbox_checked"] forState:UIControlStateSelected];
    [self.checkboxButton setImage:[QMUIHelper imageWithName:@"QMUI_previewImage_checkbox_checked"] forState:UIControlStateSelected|UIControlStateHighlighted];
    self.checkboxButton.tintColor = self.topToolBarView.tintColor;
    [self.checkboxButton sizeToFit];
    [self.checkboxButton addTarget:self action:@selector(handleCheckButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    self.checkboxButton.qmui_outsideEdge = UIEdgeInsetsMake(-6, -6, -6, -6);
    [self.topToolBarView addSubview:self.checkboxButton];
    
    _progressView = [[QMUIPieProgressView alloc] init];
    self.progressView.hidden = YES;
    [self.topToolBarView addSubview:self.progressView];
    
    _downloadRetryButton = [[UIButton alloc] init];
    [self.downloadRetryButton setImage:[QMUIHelper imageWithName:@"QMUI_icloud_download_fault"] forState:UIControlStateNormal];
    [self.downloadRetryButton sizeToFit];
    [self.downloadRetryButton addTarget:self action:@selector(handleDownloadRetryButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    self.downloadRetryButton.qmui_outsideEdge = UIEdgeInsetsMake(-6, -6, -6, -6);
    self.downloadRetryButton.hidden = YES;
    [self.topToolBarView addSubview:self.downloadRetryButton];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [[UIApplication sharedApplication] setStatusBarHidden:YES];
    [self.navigationController setNavigationBarHidden:YES animated:NO];
    if (!_singleCheckMode) {
        QMUIAsset *imageAsset = [self.imagesAssetArray objectAtIndex:self.imagePreviewView.currentImageIndex];
        self.checkboxButton.selected = [self.selectedImageAssetArray containsObject:imageAsset];
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [[UIApplication sharedApplication] setStatusBarHidden:NO];
    [self.navigationController setNavigationBarHidden:NO animated:NO];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    self.topToolBarView.frame = CGRectMake(0, 0, CGRectGetWidth(self.view.bounds), TopToolBarViewHeight);
    
    CGFloat topToolbarPaddingTop = [[UIApplication sharedApplication] isStatusBarHidden] ? 0 : StatusBarHeight;
    CGFloat topToolbarContentHeight = CGRectGetHeight(self.topToolBarView.bounds) - topToolbarPaddingTop;
    self.backButton.frame = CGRectSetXY(self.backButton.frame, 8, topToolbarPaddingTop + CGFloatGetCenter(topToolbarContentHeight, CGRectGetHeight(self.backButton.frame)));
    if (!self.checkboxButton.hidden) {
        self.checkboxButton.frame = CGRectSetXY(self.checkboxButton.frame, CGRectGetWidth(self.topToolBarView.frame) - 10 - CGRectGetWidth(self.checkboxButton.frame), topToolbarPaddingTop + CGFloatGetCenter(topToolbarContentHeight, CGRectGetHeight(self.checkboxButton.frame)));
    }
    UIImage *downloadRetryImage = [self.downloadRetryButton imageForState:UIControlStateNormal];
    self.downloadRetryButton.frame = CGRectSetXY(self.downloadRetryButton.frame, CGRectGetWidth(self.topToolBarView.frame) - 10 - downloadRetryImage.size.width, topToolbarPaddingTop + CGFloatGetCenter(topToolbarContentHeight, CGRectGetHeight(self.downloadRetryButton.frame)));
    /* 理论上 progressView 作为进度按钮，应该需要跟错误重试按钮 downloadRetryButton 的 frame 保持一致，但这里并没有直接使用
     * self.progressView.frame = self.downloadRetryButton.frame，这是因为 self.downloadRetryButton 具有 1pt 的 top
     * contentEdgeInsets，因此最终的 frame 是椭圆型，如果按上面的操作，progressView 内部绘制出的饼状图形就会变成椭圆型，
     * 因此，这里 progressView 直接拿 downloadRetryButton 的 image 图片尺寸作为 frame size
     */
    self.progressView.frame = CGRectFlatMake(CGRectGetMinX(self.downloadRetryButton.frame), CGRectGetMinY(self.downloadRetryButton.frame) + self.downloadRetryButton.contentEdgeInsets.top, downloadRetryImage.size.width, downloadRetryImage.size.height);
}

- (void)setToolBarBackgroundColor:(UIColor *)toolBarBackgroundColor {
    _toolBarBackgroundColor = toolBarBackgroundColor;
    self.topToolBarView.backgroundColor = self.toolBarBackgroundColor;
}

- (void)setToolBarTintColor:(UIColor *)toolBarTintColor {
    _toolBarTintColor = toolBarTintColor;
    self.topToolBarView.tintColor = toolBarTintColor;
    self.backButton.tintColor = toolBarTintColor;
    self.checkboxButton.tintColor = toolBarTintColor;
}

- (void)setDownloadStatus:(QMUIAssetDownloadStatus)downloadStatus {
    _downloadStatus = downloadStatus;
    switch (downloadStatus) {
        case QMUIAssetDownloadStatusSucceed:
            if (!_singleCheckMode) {
                self.checkboxButton.hidden = NO;
            }
            self.progressView.hidden = YES;
            self.downloadRetryButton.hidden = YES;
            break;
            
        case QMUIAssetDownloadStatusDownloading:
            self.checkboxButton.hidden = YES;
            self.progressView.hidden = NO;
            self.downloadRetryButton.hidden = YES;
            break;
            
        case QMUIAssetDownloadStatusCanceled:
            self.checkboxButton.hidden = NO;
            self.progressView.hidden = YES;
            self.downloadRetryButton.hidden = YES;
            break;
            
        case QMUIAssetDownloadStatusFailed:
            self.progressView.hidden = YES;
            self.checkboxButton.hidden = YES;
            self.downloadRetryButton.hidden = NO;
            break;
            
        default:
            break;
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

- (void)imagePreviewView:(QMUIImagePreviewView *)imagePreviewView renderZoomImageView:(QMUIZoomImageView *)zoomImageView atIndex:(NSUInteger)index {
    [self requestImageForZoomImageView:zoomImageView withIndex:index];
}

- (void)imagePreviewView:(QMUIImagePreviewView *)imagePreviewView willScrollHalfToIndex:(NSUInteger)index {
    if (!_singleCheckMode) {
        QMUIAsset *imageAsset = [self.imagesAssetArray objectAtIndex:index];
        self.checkboxButton.selected = [self.selectedImageAssetArray containsObject:imageAsset];
    }
}

#pragma mark - <QMUIZoomImageViewDelegate>

- (void)singleTouchInZoomingImageView:(QMUIZoomImageView *)zoomImageView location:(CGPoint)location {
    self.topToolBarView.hidden = !self.topToolBarView.hidden;
}

#pragma mark - 按钮点击回调

- (void)handleCancelPreviewImage:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
    if (self.delegate && [self.delegate respondsToSelector:@selector(imagePickerPreviewViewControllerDidCancel:)]) {
        [self.delegate imagePickerPreviewViewControllerDidCancel:self];
    }
}

- (void)handleCheckButtonClick:(id)sender {
    QMUINavigationButton *button = sender;
    [QMUIImagePickerHelper removeSpringAnimationOfImageCheckedWithCheckboxButton:button];
    
    if (button.selected) {
        if ([self.delegate respondsToSelector:@selector(imagePickerPreviewViewController:willUncheckImageAtIndex:)]) {
            [self.delegate imagePickerPreviewViewController:self willUncheckImageAtIndex:self.imagePreviewView.currentImageIndex];
        }
        
        button.selected = NO;
        QMUIAsset *imageAsset = [self.imagesAssetArray objectAtIndex:self.imagePreviewView.currentImageIndex];
        [QMUIImagePickerHelper imageAssetArray:self.selectedImageAssetArray removeImageAsset:imageAsset];
        
        if ([self.delegate respondsToSelector:@selector(imagePickerPreviewViewController:didUncheckImageAtIndex:)]) {
            [self.delegate imagePickerPreviewViewController:self didUncheckImageAtIndex:self.imagePreviewView.currentImageIndex];
        }
    } else {
        if ([self.selectedImageAssetArray count] >= self.maximumSelectImageCount) {
            if (!self.alertTitleWhenExceedMaxSelectImageCount) {
                self.alertTitleWhenExceedMaxSelectImageCount = [NSString stringWithFormat:@"你最多只能选择%lu张图片", (long)self.maximumSelectImageCount];
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

- (void)handleDownloadRetryButtonClick:(id)sender {
    [self requestImageForZoomImageView:nil withIndex:self.imagePreviewView.currentImageIndex];
}

#pragma mark - Request Image

- (void)requestImageForZoomImageView:(QMUIZoomImageView *)zoomImageView withIndex:(NSInteger)index {
    QMUIZoomImageView *imageView = zoomImageView ? : [self.imagePreviewView zoomImageViewAtIndex:index];
    QMUIAsset *imageAsset = [self.imagesAssetArray objectAtIndex:index];
    
    // 获取资源图片的预览图，这是一张适合当前设备屏幕大小的图片，最终展示时把图片交给组件控制最终展示出来的大小。
    // 系统相册本质上也是这么处理的，因此无论是系统相册，还是这个系列组件，由始至终都没有显示照片原图，
    // 这也是系统相册能加载这么快的原因。
    // 另外这里采用异步请求获取图片，避免获取图片时 UI 卡顿
    PHAssetImageProgressHandler phProgressHandler = ^(double progress, NSError *error, BOOL *stop, NSDictionary *info) {
        imageAsset.downloadProgress = progress;
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if (index == self.imagePreviewView.currentImageIndex) {
                // 只有当前显示的预览图才会展示下载进度
                QMUILog(@"Download iCloud image in preview, current progress is: %f", progress);
                
                if (self.downloadStatus != QMUIAssetDownloadStatusDownloading) {
                    self.downloadStatus = QMUIAssetDownloadStatusDownloading;
                    // 重置 progressView 的显示的进度为 0
                    [self.progressView setProgress:0 animated:NO];
                }
                // 拉取资源的初期，会有一段时间没有进度，猜测是发出网络请求以及与 iCloud 建立连接的耗时，这时预先给个 0.02 的进度值，看上去好看些
                float targetProgress = fmaxf(0.02, progress);
                if ( targetProgress < self.progressView.progress ) {
                    [self.progressView setProgress:targetProgress animated:NO];
                } else {
                    self.progressView.progress = fmaxf(0.02, progress);
                }
                if (error) {
                    QMUILog(@"Download iCloud image Failed, current progress is: %f", progress);
                    self.downloadStatus = QMUIAssetDownloadStatusFailed;
                }
            }
        });
    };
    
    if (imageAsset.assetType == QMUIAssetTypeLivePhoto) {
        imageAsset.requestID = [imageAsset requestLivePhotoWithCompletion:^void(PHLivePhoto *result, NSDictionary *info) {
            // 如果是走 PhotoKit 的逻辑，那么这个 block 会被多次调用，并且第一次调用时返回的图片是一张小图，
            // 这时需要把图片放大到跟屏幕一样大，避免后面加载大图后图片的显示会有跳动
            if (_usePhotoKit && [info[PHLivePhotoInfoIsDegradedKey] boolValue]) {
                imageView.contentMode = UIViewContentModeScaleAspectFit;
            } else {
                imageView.contentMode = UIViewContentModeCenter;
            }
            
            imageView.livePhoto = result;
            
            BOOL downlaodSucceed = (result && !info) || (![[info objectForKey:PHLivePhotoInfoCancelledKey] boolValue] && ![info objectForKey:PHLivePhotoInfoErrorKey] && ![[info objectForKey:PHLivePhotoInfoIsDegradedKey] boolValue]);
            
            if (downlaodSucceed) {
                // 资源资源已经在本地或下载成功
                [imageAsset updateDownloadStatusWithDownloadResult:YES];
                self.downloadStatus = QMUIAssetDownloadStatusSucceed;
                
            } else if ([info objectForKey:PHLivePhotoInfoErrorKey] ) {
                // 下载错误
                [imageAsset updateDownloadStatusWithDownloadResult:NO];
                self.downloadStatus = QMUIAssetDownloadStatusFailed;
            }
            
        } withProgressHandler:phProgressHandler];
    } else {
        imageAsset.requestID = [imageAsset requestPreviewImageWithCompletion:^void(UIImage *result, NSDictionary *info) {
            // 如果是走 PhotoKit 的逻辑，那么这个 block 会被多次调用，并且第一次调用时返回的图片是一张小图，
            // 这时需要把图片放大到跟屏幕一样大，避免后面加载大图后图片的显示会有跳动
            if (_usePhotoKit && [info[PHImageResultIsDegradedKey] boolValue]) {
                imageView.contentMode = UIViewContentModeScaleAspectFit;
            } else {
                imageView.contentMode = UIViewContentModeCenter;
            }
            
            imageView.image = result;
            
            BOOL downlaodSucceed = (result && !info) || (![[info objectForKey:PHImageCancelledKey] boolValue] && ![info objectForKey:PHImageErrorKey] && ![[info objectForKey:PHImageResultIsDegradedKey] boolValue]);
            
            if (downlaodSucceed) {
                // 资源资源已经在本地或下载成功
                [imageAsset updateDownloadStatusWithDownloadResult:YES];
                self.downloadStatus = QMUIAssetDownloadStatusSucceed;
                
            } else if ([info objectForKey:PHImageErrorKey] ) {
                // 下载错误
                [imageAsset updateDownloadStatusWithDownloadResult:NO];
                self.downloadStatus = QMUIAssetDownloadStatusFailed;
            }
            
        } withProgressHandler:phProgressHandler];
    }
}

@end
