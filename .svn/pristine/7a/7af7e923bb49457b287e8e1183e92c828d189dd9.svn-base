//
//  QMUIImagePickerCollectionViewCell.m
//  qmui
//
//  Created by 李浩成 on 16/8/29.
//  Copyright © 2016年 QMUI Team. All rights reserved.
//

#import "QMUIImagePickerCollectionViewCell.h"
#import "QMUICommonDefines.h"
#import "QMUIConfiguration.h"
#import "QMUIHelper.h"
#import "QMUIImagePickerHelper.h"
#import "QMUIPieProgressView.h"
#import "UIControl+QMUI.h"

// checkbox 的 margin 默认值
const UIEdgeInsets QMUIImagePickerCollectionViewCellDefaultCheckboxButtonMargins = {2, 0, 0, 2};


@interface QMUIImagePickerCollectionViewCell ()

@property(nonatomic, strong, readwrite) UIButton *checkboxButton;

@end


@implementation QMUIImagePickerCollectionViewCell

+ (void)initialize {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        [QMUIImagePickerCollectionViewCell appearance].checkboxImage = [QMUIHelper imageWithName:@"QMUI_pickerImage_checkbox"];
        [QMUIImagePickerCollectionViewCell appearance].checkboxCheckedImage = [QMUIHelper imageWithName:@"QMUI_pickerImage_checkbox_checked"];
        [QMUIImagePickerCollectionViewCell appearance].checkboxButtonMargins = QMUIImagePickerCollectionViewCellDefaultCheckboxButtonMargins;
        [QMUIImagePickerCollectionViewCell appearance].progressViewTintColor = UIColorWhite;
        [QMUIImagePickerCollectionViewCell appearance].downloadRetryImage = [QMUIHelper imageWithName:@"QMUI_icloud_download_fault_small"];
    });
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self initImagePickerCollectionViewCellUI];
        self.checkboxImage = [QMUIImagePickerCollectionViewCell appearance].checkboxImage;
        self.checkboxCheckedImage = [QMUIImagePickerCollectionViewCell appearance].checkboxCheckedImage;
        self.checkboxButtonMargins = [QMUIImagePickerCollectionViewCell appearance].checkboxButtonMargins;
        self.progressViewTintColor = [QMUIImagePickerCollectionViewCell appearance].progressViewTintColor;
        self.downloadRetryImage = [QMUIImagePickerCollectionViewCell appearance].downloadRetryImage;
    }
    return self;
}

- (void)initImagePickerCollectionViewCellUI {
    _contentImageView = [[UIImageView alloc] init];
    _contentImageView.contentMode = UIViewContentModeScaleAspectFill;
    _contentImageView.clipsToBounds = YES;
    [self.contentView addSubview:_contentImageView];
    
    self.checkboxButton = [[UIButton alloc] init];
    self.checkboxButton.qmui_outsideEdge = UIEdgeInsetsMake(-6, -6, -6, -6);
    self.checkboxButton.hidden = YES;
    [self.contentView addSubview:self.checkboxButton];
    
    _progressView = [[QMUIPieProgressView alloc] init];
    self.progressView.hidden = YES;
    [self.contentView addSubview:self.progressView];
    
    _downloadRetryButton = [[UIButton alloc] init];
    self.downloadRetryButton.qmui_outsideEdge = UIEdgeInsetsMake(-6, -6, -6, -6);
    self.downloadRetryButton.hidden = YES;
    [self.contentView addSubview:self.downloadRetryButton];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    _contentImageView.frame = self.contentView.bounds;
    if (_editing) {
        self.checkboxButton.frame = CGRectFlatted(CGRectSetXY(self.checkboxButton.frame, CGRectGetWidth(self.contentView.bounds) - self.checkboxButtonMargins.right - CGRectGetWidth(self.checkboxButton.frame), self.checkboxButtonMargins.top));
    }
    
    /* 理论上 downloadRetryButton 应该在 setImage 后 sizeToFit 计算大小，
     * 但因为当图片小于某个高度时， UIButton sizeToFit 时会自动改写 height 值，
     * 因此，这里 downloadRetryButton 直接拿 downloadRetryButton 的 image 图片尺寸作为 frame size
     */
    self.downloadRetryButton.frame = CGRectFlatted(CGRectMake(CGRectGetWidth(self.contentView.bounds) - self.checkboxButtonMargins.right - _downloadRetryImage.size.width, self.checkboxButtonMargins.top, _downloadRetryImage.size.width, _downloadRetryImage.size.height));
    self.progressView.frame = CGRectMake(CGRectGetMinX(self.downloadRetryButton.frame), CGRectGetMinY(self.downloadRetryButton.frame) + self.downloadRetryButton.contentEdgeInsets.top, CGRectGetWidth(self.downloadRetryButton.frame), CGRectGetHeight(self.downloadRetryButton.frame));
}

- (void)setCheckboxImage:(UIImage *)checkboxImage {
    if (![self.checkboxImage isEqual:checkboxImage]) {
        [self.checkboxButton setImage:checkboxImage forState:UIControlStateNormal];
        [self.checkboxButton sizeToFit];
    }
    _checkboxImage = checkboxImage;
}

- (void)setCheckboxCheckedImage:(UIImage *)checkboxCheckedImage {
    if (![self.checkboxCheckedImage isEqual:checkboxCheckedImage]) {
        [self.checkboxButton setImage:checkboxCheckedImage forState:UIControlStateSelected];
        [self.checkboxButton setImage:checkboxCheckedImage forState:UIControlStateSelected|UIControlStateHighlighted];
        [self.checkboxButton sizeToFit];
    }
    _checkboxCheckedImage = checkboxCheckedImage;
}

- (void)setDownloadRetryImage:(UIImage *)downloadRetryImage {
    if (![self.downloadRetryImage isEqual:downloadRetryImage]) {
        [self.downloadRetryButton setImage:downloadRetryImage forState:UIControlStateNormal];
    }
    _downloadRetryImage = downloadRetryImage;
}

- (void)setProgressViewTintColor:(UIColor *)progressViewTintColor {
    _progressView.tintColor = progressViewTintColor;
    _progressViewTintColor = progressViewTintColor;
}


- (void)setChecked:(BOOL)checked {
    _checked = checked;
    if (_editing) {
        self.checkboxButton.selected = checked;
        [QMUIImagePickerHelper removeSpringAnimationOfImageCheckedWithCheckboxButton:self.checkboxButton];
        if (checked) {
            [QMUIImagePickerHelper springAnimationOfImageCheckedWithCheckboxButton:self.checkboxButton];
        }
    }
}

- (void)setEditing:(BOOL)editing {
    _editing = editing;
    if (self.downloadStatus == QMUIAssetDownloadStatusSucceed) {
        self.checkboxButton.hidden = !_editing;
    }
}

- (void)setDownloadStatus:(QMUIAssetDownloadStatus)downloadStatus {
    _downloadStatus = downloadStatus;
    switch (downloadStatus) {
        case QMUIAssetDownloadStatusSucceed:
            if (_editing) {
                self.checkboxButton.hidden = !_editing;
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

@end
