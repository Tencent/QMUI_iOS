/*****
 * Tencent is pleased to support the open source community by making QMUI_iOS available.
 * Copyright (C) 2016-2019 THL A29 Limited, a Tencent company. All rights reserved.
 * Licensed under the MIT License (the "License"); you may not use this file except in compliance with the License. You may obtain a copy of the License at
 * http://opensource.org/licenses/MIT
 * Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.
 *****/

//
//  QMUIImagePickerCollectionViewCell.m
//  qmui
//
//  Created by QMUI Team on 16/8/29.
//

#import "QMUIImagePickerCollectionViewCell.h"
#import "QMUICore.h"
#import "QMUIImagePickerHelper.h"
#import "QMUIPieProgressView.h"
#import "UIControl+QMUI.h"
#import "UILabel+QMUI.h"
#import "CALayer+QMUI.h"
#import "QMUIButton.h"
#import "UIView+QMUI.h"
#import "NSString+QMUI.h"

@interface QMUIImagePickerCollectionViewCell ()

@property(nonatomic, strong, readwrite) UIImageView *favoriteImageView;
@property(nonatomic, strong, readwrite) QMUIButton *checkboxButton;
@property(nonatomic, strong, readwrite) CAGradientLayer *bottomShadowLayer;

@end


@implementation QMUIImagePickerCollectionViewCell

@synthesize videoDurationLabel = _videoDurationLabel;

+ (void)initialize {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        [QMUIImagePickerCollectionViewCell appearance].favoriteImage = [QMUIHelper imageWithName:@"QMUI_pickerImage_favorite"];
        [QMUIImagePickerCollectionViewCell appearance].favoriteImageMargins = UIEdgeInsetsMake(6, 6, 6, 6);
        [QMUIImagePickerCollectionViewCell appearance].checkboxImage = [QMUIHelper imageWithName:@"QMUI_pickerImage_checkbox"];
        [QMUIImagePickerCollectionViewCell appearance].checkboxCheckedImage = [QMUIHelper imageWithName:@"QMUI_pickerImage_checkbox_checked"];
        [QMUIImagePickerCollectionViewCell appearance].checkboxButtonMargins = UIEdgeInsetsMake(6, 6, 6, 6);
        [QMUIImagePickerCollectionViewCell appearance].videoDurationLabelFont = UIFontMake(12);
        [QMUIImagePickerCollectionViewCell appearance].videoDurationLabelTextColor = UIColorWhite;
        [QMUIImagePickerCollectionViewCell appearance].videoDurationLabelMargins = UIEdgeInsetsMake(5, 5, 5, 7);
    });
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self initImagePickerCollectionViewCellUI];
        self.favoriteImage = [QMUIImagePickerCollectionViewCell appearance].favoriteImage;
        self.favoriteImageMargins = [QMUIImagePickerCollectionViewCell appearance].favoriteImageMargins;
        self.checkboxImage = [QMUIImagePickerCollectionViewCell appearance].checkboxImage;
        self.checkboxCheckedImage = [QMUIImagePickerCollectionViewCell appearance].checkboxCheckedImage;
        self.checkboxButtonMargins = [QMUIImagePickerCollectionViewCell appearance].checkboxButtonMargins;
        self.videoDurationLabelFont = [QMUIImagePickerCollectionViewCell appearance].videoDurationLabelFont;
        self.videoDurationLabelTextColor = [QMUIImagePickerCollectionViewCell appearance].videoDurationLabelTextColor;
        self.videoDurationLabelMargins = [QMUIImagePickerCollectionViewCell appearance].videoDurationLabelMargins;
    }
    return self;
}

- (void)initImagePickerCollectionViewCellUI {
    _contentImageView = [[UIImageView alloc] init];
    self.contentImageView.contentMode = UIViewContentModeScaleAspectFill;
    self.contentImageView.clipsToBounds = YES;
    [self.contentView addSubview:self.contentImageView];
    
    self.bottomShadowLayer = [CAGradientLayer layer];
    [self.bottomShadowLayer qmui_removeDefaultAnimations];
    self.bottomShadowLayer.colors = @[(id)UIColorMakeWithRGBA(0, 0, 0, 0).CGColor, (id)UIColorMakeWithRGBA(0, 0, 0, .6).CGColor];
    self.bottomShadowLayer.hidden = YES;
    [self.contentView.layer addSublayer:self.bottomShadowLayer];
    [self setNeedsLayout];
    
    self.favoriteImageView = [[UIImageView alloc] init];
    self.favoriteImageView.hidden = YES;
    [self.contentView addSubview:self.favoriteImageView];
    
    self.checkboxButton = [[QMUIButton alloc] init];
    self.checkboxButton.qmui_automaticallyAdjustTouchHighlightedInScrollView = YES;
    self.checkboxButton.qmui_outsideEdge = UIEdgeInsetsMake(-6, -6, -6, -6);
    self.checkboxButton.hidden = YES;
    [self.contentView addSubview:self.checkboxButton];
}

- (void)renderWithAsset:(QMUIAsset *)asset referenceSize:(CGSize)referenceSize {
    self.assetIdentifier = asset.identifier;
    
    // 异步请求资源对应的缩略图
    [asset requestThumbnailImageWithSize:referenceSize completion:^(UIImage *result, NSDictionary *info) {
        if ([self.assetIdentifier isEqualToString:asset.identifier]) {
            self.contentImageView.image = result;
        } else {
            self.contentImageView.image = nil;
        }
    }];
    
    if (asset.assetType == QMUIAssetTypeVideo) {
        [self initVideoDurationLabelIfNeeded];
        self.videoDurationLabel.text = [NSString qmui_timeStringWithMinsAndSecsFromSecs:asset.duration];
        self.videoDurationLabel.hidden = NO;
    } else {
        self.videoDurationLabel.hidden = YES;
    }
    
    self.favoriteImageView.hidden = !asset.phAsset.favorite;
    
    self.bottomShadowLayer.hidden = !((self.videoDurationLabel && !self.videoDurationLabel.hidden) || !self.favoriteImageView.hidden);
    
    [self setNeedsLayout];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    self.contentImageView.frame = self.contentView.bounds;
    if (_selectable) {
        self.checkboxButton.frame = CGRectSetXY(self.checkboxButton.frame, CGRectGetWidth(self.contentView.bounds) - self.checkboxButtonMargins.right - CGRectGetWidth(self.checkboxButton.bounds), self.checkboxButtonMargins.top);
    }
    
    CGFloat bottomShadowLayerHeight = 0;
    
    if (!self.favoriteImageView.hidden) {
        self.favoriteImageView.frame = CGRectSetXY(self.favoriteImageView.frame, self.favoriteImageMargins.left, CGRectGetHeight(self.contentView.bounds) - self.favoriteImageMargins.bottom - CGRectGetHeight(self.favoriteImageView.frame));
        bottomShadowLayerHeight = CGRectGetHeight(self.favoriteImageView.frame) + UIEdgeInsetsGetVerticalValue(self.favoriteImageMargins);
    }
    
    if (self.videoDurationLabel && !self.videoDurationLabel.hidden) {
        [self.videoDurationLabel sizeToFit];
        self.videoDurationLabel.frame = CGRectSetXY(self.videoDurationLabel.frame, CGRectGetWidth(self.contentView.bounds) - self.videoDurationLabelMargins.right - CGRectGetWidth(self.videoDurationLabel.frame), CGRectGetHeight(self.contentView.bounds) - self.videoDurationLabelMargins.bottom - CGRectGetHeight(self.videoDurationLabel.frame));
        bottomShadowLayerHeight = MAX(bottomShadowLayerHeight, CGRectGetHeight(self.videoDurationLabel.frame) + UIEdgeInsetsGetVerticalValue(self.videoDurationLabelMargins));
    }
    
    if (!self.bottomShadowLayer.hidden) {
        self.bottomShadowLayer.frame = CGRectMake(0, CGRectGetHeight(self.contentView.bounds) - bottomShadowLayerHeight, CGRectGetWidth(self.contentView.bounds), bottomShadowLayerHeight);
    }
}

- (void)setFavoriteImage:(UIImage *)favoriteImage {
    if (![self.favoriteImage isEqual:favoriteImage]) {
        self.favoriteImageView.image = favoriteImage;
        [self.favoriteImageView sizeToFit];
        [self setNeedsLayout];
    }
    _favoriteImage = favoriteImage;
}

- (void)setCheckboxImage:(UIImage *)checkboxImage {
    if (![self.checkboxImage isEqual:checkboxImage]) {
        [self.checkboxButton setImage:checkboxImage forState:UIControlStateNormal];
        [self.checkboxButton sizeToFit];
        [self setNeedsLayout];
    }
    _checkboxImage = checkboxImage;
}

- (void)setCheckboxCheckedImage:(UIImage *)checkboxCheckedImage {
    if (![self.checkboxCheckedImage isEqual:checkboxCheckedImage]) {
        [self.checkboxButton setImage:checkboxCheckedImage forState:UIControlStateSelected];
        [self.checkboxButton setImage:checkboxCheckedImage forState:UIControlStateSelected|UIControlStateHighlighted];
        [self.checkboxButton sizeToFit];
        [self setNeedsLayout];
    }
    _checkboxCheckedImage = checkboxCheckedImage;
}

- (void)setVideoDurationLabelFont:(UIFont *)videoDurationLabelFont {
    if (![self.videoDurationLabelFont isEqual:videoDurationLabelFont]) {
        _videoDurationLabel.font = videoDurationLabelFont;
        [_videoDurationLabel qmui_calculateHeightAfterSetAppearance];
        [self setNeedsLayout];
    }
    _videoDurationLabelFont = videoDurationLabelFont;
}

- (void)setVideoDurationLabelTextColor:(UIColor *)videoDurationLabelTextColor {
    if (![self.videoDurationLabelTextColor isEqual:videoDurationLabelTextColor]) {
        _videoDurationLabel.textColor = videoDurationLabelTextColor;
    }
    _videoDurationLabelTextColor = videoDurationLabelTextColor;
}

- (void)setChecked:(BOOL)checked {
    _checked = checked;
    if (_selectable) {
        self.checkboxButton.selected = checked;
        [QMUIImagePickerHelper removeSpringAnimationOfImageCheckedWithCheckboxButton:self.checkboxButton];
        if (checked) {
            [QMUIImagePickerHelper springAnimationOfImageCheckedWithCheckboxButton:self.checkboxButton];
        }
    }
}

- (void)setSelectable:(BOOL)editing {
    _selectable = editing;
    if (self.downloadStatus == QMUIAssetDownloadStatusSucceed) {
        self.checkboxButton.hidden = !_selectable;
    }
}

- (void)setDownloadStatus:(QMUIAssetDownloadStatus)downloadStatus {
    _downloadStatus = downloadStatus;
    if (_selectable) {
        self.checkboxButton.hidden = !_selectable;
    }
}

- (void)initVideoDurationLabelIfNeeded {
    if (!self.videoDurationLabel) {
        _videoDurationLabel = [[UILabel alloc] qmui_initWithFont:self.videoDurationLabelFont textColor:self.videoDurationLabelTextColor];
        [self.contentView addSubview:_videoDurationLabel];
        [self setNeedsLayout];
    }
}

@end
