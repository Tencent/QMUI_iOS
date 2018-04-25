//
//  QMUIImagePickerCollectionViewCell.h
//  qmui
//
//  Created by 李浩成 on 16/8/29.
//  Copyright © 2016年 QMUI Team. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "QMUIAsset.h"

// checkbox 的 margin 默认值
extern const UIEdgeInsets QMUIImagePickerCollectionViewCellDefaultCheckboxButtonMargins;

@class QMUIButton;

/**
 *  图片选择空间里的九宫格 cell，支持显示 checkbox、饼状进度条及重试按钮（iCloud 图片需要）
 */
@interface QMUIImagePickerCollectionViewCell : UICollectionViewCell

/// checkbox 未被选中时显示的图片
@property(nonatomic, strong) UIImage *checkboxImage UI_APPEARANCE_SELECTOR;

/// checkbox 被选中时显示的图片
@property(nonatomic, strong) UIImage *checkboxCheckedImage UI_APPEARANCE_SELECTOR;

/// checkbox 的 margin，定位从每个 cell（即每张图片）的最右边开始计算
@property(nonatomic, assign) UIEdgeInsets checkboxButtonMargins UI_APPEARANCE_SELECTOR;

/// videoMarkImageView 的 icon
@property(nonatomic, strong) UIImage *videoMarkImage UI_APPEARANCE_SELECTOR;

/// videoMarkImageView 的 margin，定位从每个 cell（即每张图片）的左下角开始计算
@property(nonatomic, assign) UIEdgeInsets videoMarkImageViewMargins UI_APPEARANCE_SELECTOR;

/// videoDurationLabel 的字号
@property(nonatomic, strong) UIFont *videoDurationLabelFont UI_APPEARANCE_SELECTOR;

/// videoDurationLabel 的字体颜色
@property(nonatomic, strong) UIColor *videoDurationLabelTextColor UI_APPEARANCE_SELECTOR;

/// videoDurationLabel 布局是对齐右下角再做 margins 偏移
@property(nonatomic, assign) UIEdgeInsets videoDurationLabelMargins UI_APPEARANCE_SELECTOR;

@property(nonatomic, strong, readonly) UIImageView *contentImageView;
@property(nonatomic, strong, readonly) QMUIButton *checkboxButton;
@property(nonatomic, strong, readonly) UIImageView *videoMarkImageView;
@property(nonatomic, strong, readonly) UILabel *videoDurationLabel;
@property(nonatomic, strong, readonly) CAGradientLayer *videoBottomShadowLayer;

@property(nonatomic, assign, getter=isSelectable) BOOL selectable;
@property(nonatomic, assign, getter=isChecked) BOOL checked;
@property(nonatomic, assign) QMUIAssetDownloadStatus downloadStatus; // Cell 中对应资源的下载状态，这个值的变动会相应地调整 UI 表现
@property(nonatomic, copy) NSString *assetIdentifier;// 当前这个 cell 正在展示的 QMUIAsset 的 identifier

@end
