/**
 * Tencent is pleased to support the open source community by making QMUI_iOS available.
 * Copyright (C) 2016-2021 THL A29 Limited, a Tencent company. All rights reserved.
 * Licensed under the MIT License (the "License"); you may not use this file except in compliance with the License. You may obtain a copy of the License at
 * http://opensource.org/licenses/MIT
 * Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.
 */

//
//  QMUIFillButton.h
//  QMUIKit
//
//  Created by QMUI Team on 2018/4/9.
//

#import "QMUIButton.h"

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, QMUIFillButtonColor) {
    QMUIFillButtonColorBlue,
    QMUIFillButtonColorRed,
    QMUIFillButtonColorGreen,
    QMUIFillButtonColorGray,
    QMUIFillButtonColorWhite,
};

/**
 *  QMUIFillButton
 *  实心填充颜色的按钮，支持预定义的几个色值
 *  圆角自动保持为按钮高度的一半，可通过 QMUIButton.cornerRadius 属性修改
 */
@interface QMUIFillButton : QMUIButton

@property(nonatomic, strong, nullable) IBInspectable UIColor *fillColor; // 默认为 FillButtonColorBlue
@property(nonatomic, strong, nullable) IBInspectable UIColor *titleTextColor; // 默认为 UIColorWhite

/**
 *  控制按钮里面的图片是否也要跟随 `titleTextColor` 一起变化，默认为 `NO`
 */
@property(nonatomic, assign) BOOL adjustsImageWithTitleTextColor UI_APPEARANCE_SELECTOR;

- (instancetype)initWithFillType:(QMUIFillButtonColor)fillType;
- (instancetype)initWithFillType:(QMUIFillButtonColor)fillType frame:(CGRect)frame;
- (instancetype)initWithFillColor:(nullable UIColor *)fillColor titleTextColor:(nullable UIColor *)textColor;
- (instancetype)initWithFillColor:(nullable UIColor *)fillColor titleTextColor:(nullable UIColor *)textColor frame:(CGRect)frame;

@end

NS_ASSUME_NONNULL_END
