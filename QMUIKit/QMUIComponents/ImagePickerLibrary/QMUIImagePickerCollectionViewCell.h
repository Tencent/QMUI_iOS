/*****
 * Tencent is pleased to support the open source community by making QMUI_iOS available.
 * Copyright (C) 2016-2019 THL A29 Limited, a Tencent company. All rights reserved.
 * Licensed under the MIT License (the "License"); you may not use this file except in compliance with the License. You may obtain a copy of the License at
 * http://opensource.org/licenses/MIT
 * Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.
 *****/

//
//  QMUIImagePickerCollectionViewCell.h
//  qmui
//
//  Created by QMUI Team on 16/8/29.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "QMUIAsset.h"

@class QMUIButton;

/**
 *  图片选择空间里的九宫格 cell，支持显示 checkbox、饼状进度条及重试按钮（iCloud 图片需要）
 */
@interface QMUIImagePickerCollectionViewCell : UICollectionViewCell

/// 收藏的资源的心形图片
@property(nonatomic, strong) UIImage *favoriteImage UI_APPEARANCE_SELECTOR;

/// 收藏的资源的心形图片的上下左右间距，相对于 cell 左下角零点而言，也即如果 left 越大则越往右，bottom 越大则越往上，另外 top 会影响底部遮罩的高度
@property(nonatomic, assign) UIEdgeInsets favoriteImageMargins UI_APPEARANCE_SELECTOR;

/// checkbox 未被选中时显示的图片
@property(nonatomic, strong) UIImage *checkboxImage UI_APPEARANCE_SELECTOR;

/// checkbox 被选中时显示的图片
@property(nonatomic, strong) UIImage *checkboxCheckedImage UI_APPEARANCE_SELECTOR;

/// checkbox 的 margin，定位从每个 cell（即每张图片）的最右边开始计算
@property(nonatomic, assign) UIEdgeInsets checkboxButtonMargins UI_APPEARANCE_SELECTOR;

/// videoDurationLabel 的字号
@property(nonatomic, strong) UIFont *videoDurationLabelFont UI_APPEARANCE_SELECTOR;

/// videoDurationLabel 的字体颜色
@property(nonatomic, strong) UIColor *videoDurationLabelTextColor UI_APPEARANCE_SELECTOR;

/// 视频时长文字的间距，相对于 cell 右下角而言，也即如果 right 越大则越往左，bottom 越大则越往上，另外 top 会影响底部遮罩的高度
@property(nonatomic, assign) UIEdgeInsets videoDurationLabelMargins UI_APPEARANCE_SELECTOR;

@property(nonatomic, strong, readonly) UIImageView *contentImageView;
@property(nonatomic, strong, readonly) UIImageView *favoriteImageView;
@property(nonatomic, strong, readonly) QMUIButton *checkboxButton;
@property(nonatomic, strong, readonly) UILabel *videoDurationLabel;
@property(nonatomic, strong, readonly) CAGradientLayer *bottomShadowLayer;// 当出现收藏或者视频时长文字时就会显示遮罩，遮罩高度为 favoriteImage 和 videoDurationLabel 中最高者的高度

@property(nonatomic, assign, getter=isSelectable) BOOL selectable;
@property(nonatomic, assign, getter=isChecked) BOOL checked;
@property(nonatomic, assign) QMUIAssetDownloadStatus downloadStatus; // Cell 中对应资源的下载状态，这个值的变动会相应地调整 UI 表现
@property(nonatomic, copy) NSString *assetIdentifier;// 当前这个 cell 正在展示的 QMUIAsset 的 identifier

- (void)renderWithAsset:(QMUIAsset *)asset referenceSize:(CGSize)referenceSize;

@end
