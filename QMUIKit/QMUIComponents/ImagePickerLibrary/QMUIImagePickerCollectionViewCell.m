//
//  QMUIImagePickerCollectionViewCell.m
//  qmui
//
//  Created by 李浩成 on 16/8/29.
//  Copyright © 2016年 QMUI Team. All rights reserved.
//

#import "QMUIImagePickerCollectionViewCell.h"
#import "QMUICore.h"
#import "QMUIImagePickerHelper.h"
#import "QMUIPieProgressView.h"
#import "UIControl+QMUI.h"
#import "UILabel+QMUI.h"
#import "CALayer+QMUI.h"
#import "QMUIButton.h"

// checkbox 的 margin 默认值
const UIEdgeInsets QMUIImagePickerCollectionViewCellDefaultCheckboxButtonMargins = {6, 0, 0, 6};
const UIEdgeInsets QMUIImagePickerCollectionViewCellDefaultVideoMarkImageViewMargins = {0, 8, 8, 0};


@interface QMUIImagePickerCollectionViewCell ()

@property(nonatomic, strong, readwrite) QMUIButton *checkboxButton;

@end


@implementation QMUIImagePickerCollectionViewCell

@synthesize videoMarkImageView = _videoMarkImageView;
@synthesize videoDurationLabel = _videoDurationLabel;
@synthesize videoBottomShadowLayer = _videoBottomShadowLayer;

+ (void)initialize {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        [QMUIImagePickerCollectionViewCell appearance].checkboxImage = [QMUIHelper imageWithName:@"QMUI_pickerImage_checkbox"];
        [QMUIImagePickerCollectionViewCell appearance].checkboxCheckedImage = [QMUIHelper imageWithName:@"QMUI_pickerImage_checkbox_checked"];
        [QMUIImagePickerCollectionViewCell appearance].checkboxButtonMargins = QMUIImagePickerCollectionViewCellDefaultCheckboxButtonMargins;
        [QMUIImagePickerCollectionViewCell appearance].videoMarkImage = [QMUIHelper imageWithName:@"QMUI_pickerImage_video_mark"];
        [QMUIImagePickerCollectionViewCell appearance].videoMarkImageViewMargins = QMUIImagePickerCollectionViewCellDefaultVideoMarkImageViewMargins;
        [QMUIImagePickerCollectionViewCell appearance].videoDurationLabelFont = UIFontMake(12);
        [QMUIImagePickerCollectionViewCell appearance].videoDurationLabelTextColor = UIColorWhite;
        [QMUIImagePickerCollectionViewCell appearance].videoDurationLabelMargins = UIEdgeInsetsMake(0, 0, 6, 6);
    });
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self initImagePickerCollectionViewCellUI];
        self.checkboxImage = [QMUIImagePickerCollectionViewCell appearance].checkboxImage;
        self.checkboxCheckedImage = [QMUIImagePickerCollectionViewCell appearance].checkboxCheckedImage;
        self.checkboxButtonMargins = [QMUIImagePickerCollectionViewCell appearance].checkboxButtonMargins;
        self.videoMarkImage = [QMUIImagePickerCollectionViewCell appearance].videoMarkImage;
        self.videoMarkImageViewMargins = [QMUIImagePickerCollectionViewCell appearance].videoMarkImageViewMargins;
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
    
    self.checkboxButton = [[QMUIButton alloc] init];
    self.checkboxButton.qmui_automaticallyAdjustTouchHighlightedInScrollView = YES;
    self.checkboxButton.qmui_outsideEdge = UIEdgeInsetsMake(-6, -6, -6, -6);
    self.checkboxButton.hidden = YES;
    [self.contentView addSubview:self.checkboxButton];
}

- (void)initVideoBottomShadowLayerIfNeeded {
    if (!_videoBottomShadowLayer) {
        _videoBottomShadowLayer = [CAGradientLayer layer];
        [_videoBottomShadowLayer qmui_removeDefaultAnimations];
        _videoBottomShadowLayer.colors = @[(id)UIColorMakeWithRGBA(0, 0, 0, 0).CGColor, (id)UIColorMakeWithRGBA(0, 0, 0, .6).CGColor];
        [self.contentView.layer addSublayer:_videoBottomShadowLayer];
        [self setNeedsLayout];
    }
}

- (void)initVideoMarkImageViewIfNeed {
    if (_videoMarkImageView) {
        return;
    }
    _videoMarkImageView = [[UIImageView alloc] init];
    [_videoMarkImageView setImage:self.videoMarkImage];
    [_videoMarkImageView sizeToFit];
    [self.contentView addSubview:_videoMarkImageView];
    [self setNeedsLayout];
}

- (void)initVideoDurationLabelIfNeed {
    if (_videoDurationLabel) {
        return;
    }
    _videoDurationLabel = [[UILabel alloc] init];
    _videoDurationLabel.font = self.videoDurationLabelFont;
    _videoDurationLabel.textColor = self.videoDurationLabelTextColor;
    [self.contentView addSubview:_videoDurationLabel];
    [self setNeedsLayout];
}

- (void)initVideoRelatedViewsIfNeeded {
    [self initVideoBottomShadowLayerIfNeeded];
    [self initVideoMarkImageViewIfNeed];
    [self initVideoDurationLabelIfNeed];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    self.contentImageView.frame = self.contentView.bounds;
    if (_selectable) {
        self.checkboxButton.frame = CGRectSetXY(self.checkboxButton.frame, CGRectGetWidth(self.contentView.bounds) - self.checkboxButtonMargins.right - CGRectGetWidth(self.checkboxButton.bounds), self.checkboxButtonMargins.top);
    }
    
    if (_videoBottomShadowLayer && _videoMarkImageView && _videoDurationLabel) {
        _videoMarkImageView.frame = CGRectSetXY(_videoMarkImageView.frame, self.videoMarkImageViewMargins.left, CGRectGetHeight(self.contentView.bounds) - CGRectGetHeight(_videoMarkImageView.bounds) - self.videoMarkImageViewMargins.bottom);

        [_videoDurationLabel sizeToFit];
        _videoDurationLabel.frame = ({
            CGFloat minX = CGRectGetWidth(self.contentView.bounds) - self.videoDurationLabelMargins.right - CGRectGetWidth(_videoDurationLabel.bounds);
            CGFloat minY = CGRectGetHeight(self.contentView.bounds) - self.videoDurationLabelMargins.bottom - CGRectGetHeight(_videoDurationLabel.bounds);
            CGRectSetXY(_videoDurationLabel.frame, minX, minY);
        });
        
        CGFloat videoBottomShadowLayerHeight = CGRectGetHeight(self.contentView.bounds) - CGRectGetMinY(_videoMarkImageView.frame) + self.videoMarkImageViewMargins.bottom;// 背景阴影遮罩的高度取决于（视频 icon 的高度 + 上下 margin）
        _videoBottomShadowLayer.frame = CGRectFlatMake(0, CGRectGetHeight(self.contentView.bounds) - videoBottomShadowLayerHeight, CGRectGetWidth(self.contentView.bounds), videoBottomShadowLayerHeight);
    }
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

- (void)setVideoMarkImage:(UIImage *)videoMarkImage {
    if (![self.videoMarkImage isEqual:videoMarkImage]) {
        [_videoMarkImageView setImage:videoMarkImage];
        [_videoMarkImageView sizeToFit];
    }
    _videoMarkImage = videoMarkImage;
}

- (void)setVideoDurationLabelFont:(UIFont *)videoDurationLabelFont {
    if (![self.videoDurationLabelFont isEqual:videoDurationLabelFont]) {
        _videoDurationLabel.font = videoDurationLabelFont;
        [_videoDurationLabel qmui_calculateHeightAfterSetAppearance];
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

- (UILabel *)videoDurationLabel {
    [self initVideoRelatedViewsIfNeeded];
    return _videoDurationLabel;
}

- (UIImageView *)videoMarkImageView {
    [self initVideoRelatedViewsIfNeeded];
    return _videoMarkImageView;
}

- (CAGradientLayer *)videoBottomShadowLayer {
    [self initVideoRelatedViewsIfNeeded];
    return _videoBottomShadowLayer;
}

@end
