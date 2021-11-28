/**
 * Tencent is pleased to support the open source community by making QMUI_iOS available.
 * Copyright (C) 2016-2021 THL A29 Limited, a Tencent company. All rights reserved.
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
#import "QMUIHelper.h"
#import "NSString+QMUI.h"

NS_ASSUME_NONNULL_BEGIN

/// 如果某个 NSAttributedString 是通过 +[NSAttributedString qmui_attributedStringWithImage:margins:] 创建的，则该 string 会被添加以这个 name 为 key 的 attribute，值为 NSValue 包裹的 UIEdgeInsets。
UIKIT_EXTERN NSAttributedStringKey const QMUIImageMarginsAttributeName;

@interface NSAttributedString (QMUI)<QMUIStringProtocol>

/**
 * @brief 将指定 image 作为 NSTextAttachment 用以生成一段 NSAttributedString。
 * @note 如果该 image 是由 [UIImage qmui_imageWithAttributedString:] 生成的，则会利用 image 内部关联的 attributes 来试图调整 image 的 y 轴偏移值，以使其与其他文本垂直对齐。
 * @param image 要用的图片
 */
+ (instancetype)qmui_attributedStringWithImage:(UIImage *)image;

/**
 * @brief 将指定 image 作为 NSTextAttachment 用以生成一段 NSAttributedString，并利用给定的一整段文字的 attributes 来自动居中 image
 * @note 一般情况下我们会将某个 image 作为一串富文本里的某一个部分拼接在一起，为了保证 image、string 垂直对齐，需要根据 font、lineHeight 等信息做一些垂直方向的调整，此时你可以将整段文字的 attributes 传进来，内部根据一定规则帮你计算。
 * @param image 要用的图片
 * @param attributes 最终一整段文字的 attributes
 */
+ (instancetype)qmui_attributedStringWithImage:(UIImage *)image alignByAttributes:(NSDictionary<NSAttributedStringKey,id> *)attributes;

/**
 * @brief 创建一个包含图片的 attributedString
 * @param image 要用的图片
 * @param offset 图片相对基线的垂直偏移（当 offset > 0 时，图片会向上偏移）
 * @param leftMargin 图片距离左侧内容的间距
 * @param rightMargin 图片距离右侧内容的间距
 * @note leftMargin 和 rightMargin 必须大于或等于 0
 */
+ (instancetype)qmui_attributedStringWithImage:(UIImage *)image baselineOffset:(CGFloat)offset leftMargin:(CGFloat)leftMargin rightMargin:(CGFloat)rightMargin DEPRECATED_MSG_ATTRIBUTE("由于命名、参数不够友好，内部用 baseline 的实现方式也可能影响输入框后续文本的样式，因此本方法废弃，请改为用 qmui_attributedStringWithImage:margins:");

/**
 * @brief 创建一个包含图片的 attributedString，可通过 margins 调整图片在文本里的位置，上下调整不会影响文本布局，左右调整会在图片和文字之间形成空白区域。
 * 注意该方法返回的 string 里会用 QMUIImageMarginsAttributeName 带上 margins 的值（由 NSValue 包裹的 UIEdgeInsets）。
 * @param image 要用的图片
 * @param margins 图片相对默认位置（baseline）的偏移，其中：
 * top > 0 则在图片上方增加空隙，图片会往下
 * top < 0 会将图片往上移动
 * left > 0 会在图片左边增加空隙，图片及后续的文本都往右，不支持负值
 * right > 0 会在图片右边增加空隙，图片后面的文本往右，不支持负值
 */
+ (instancetype)qmui_attributedStringWithImage:(UIImage *)image margins:(UIEdgeInsets)margins;

/**
 * @brief 创建一个用来占位的空白 attributedString
 * @param width 空白占位符的宽度
 */
+ (instancetype)qmui_attributedStringWithFixedSpace:(CGFloat)width;

@end

@interface UIImage (QMUI_NSAttributedStringSupports)

/**
 *  将富文本渲染成图片，图片的尺寸与文本大小一致，且只按一行来计算。
 *
 *  特别地，对于将 NSAttributedString 用于 UITextView 的场景（例如输入框里@人），UITextView 的特性是当前节点的 attributes 会决定后续继续输入的文本的 attributes，而不管 UITextView 是否主动设置了 font、typingAttributes。对于这种场景，如果不作任何处理，在插入由 UIImage 生成的 NSTextAttachment 后，由于这段 NSTextAttacment 已经不带任何 attributes 了，会导致后续输入的文本都回到系统 UITextView 默认样式（例如字号 12pt），这通常不符合开发者预期。因此通过本方法生成的 UIImage，参数 @c attributedString 对象将会被 copy 后关联在生成的 UIImage 内，假设最终这个 UIImage 通过 [NSAttributedString qmui_attributedStringWithImage:] 转为 NSAttributedString，关联的 attributes 也会被作为这段 NSAttributedString 的 attributes，以保证后续输入的文本样式与 image 保持一致。
 */
+ (nullable UIImage *)qmui_imageWithAttributedString:(NSAttributedString *)attributedString;

/**
 如果当前 UIImage 是通过 [UIImage qmui_imageWithAttributedString:] 生成的，则通过这个属性可以获取生成图片时使用的 NSAttributedString。
 */
@property(nullable, nonatomic, strong, readonly) NSAttributedString *qmui_attributedString;

/**
 如果当前 UIImage 是通过 [UIImage qmui_imageWithAttributedString:] 生成的，则通过这个属性可以获取生成图片时使用的 NSAttributedString 的 attributes。
 */
@property(nullable, nonatomic, strong, readonly) NSDictionary<NSAttributedStringKey, id> *qmui_stringAttributes;
@end

@interface QMUIHelper (NSAttributedStringSupports)

/**
 利用 image 的 size、attributes 里的 font、lineHeight 综合计算出一个垂直方向上的偏移，令该 image 能在一段富文本里与文字垂直居中（这段富文本的 attributes 与参数 attributes 一致）
 @param image 富文本里的 image
 @param attributes 整段富文本的 attributes
 @return image 的垂直偏移，正值表示向下，负值表示向上。可以将这个值作为 -[NSAttributedString qmui_attributedStringWithImage:margins:] 里的参数 margins.top 的值
 */
+ (CGFloat)topMarginForAttributedImage:(UIImage *)image attributes:(NSDictionary<NSAttributedStringKey, id> *)attributes;
@end

NS_ASSUME_NONNULL_END
