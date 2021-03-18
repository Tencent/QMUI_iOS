/**
 * Tencent is pleased to support the open source community by making QMUI_iOS available.
 * Copyright (C) 2016-2020 THL A29 Limited, a Tencent company. All rights reserved.
 * Licensed under the MIT License (the "License"); you may not use this file except in compliance with the License. You may obtain a copy of the License at
 * http://opensource.org/licenses/MIT
 * Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.
 */

//
//  NSAttributedString+QMUI.h
//  qmui
//
//  Created by QMUI Team on 16/9/23.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface NSAttributedString (QMUI)

/**
 *  按照中文 2 个字符、英文 1 个字符的方式来计算文本长度
 */
- (NSUInteger)qmui_lengthWhenCountingNonASCIICharacterAsTwo;

/**
 * @brief 创建一个包含图片的 attributedString
 * @param image 要用的图片
 */
+ (instancetype)qmui_attributedStringWithImage:(UIImage *)image;

/**
 * @brief 创建一个包含图片的 attributedString
 * @param image 要用的图片
 * @param offset 图片相对基线的垂直偏移（当 offset > 0 时，图片会向上偏移）
 * @param leftMargin 图片距离左侧内容的间距
 * @param rightMargin 图片距离右侧内容的间距
 * @note leftMargin 和 rightMargin 必须大于或等于 0
 */
+ (instancetype)qmui_attributedStringWithImage:(UIImage *)image baselineOffset:(CGFloat)offset leftMargin:(CGFloat)leftMargin rightMargin:(CGFloat)rightMargin;

/**
 * @brief 创建一个用来占位的空白 attributedString
 * @param width 空白占位符的宽度
 */
+ (instancetype)qmui_attributedStringWithFixedSpace:(CGFloat)width;

@end

@interface NSMutableAttributedString (QMUI)

@end
