/*****
 * Tencent is pleased to support the open source community by making QMUI_iOS available.
 * Copyright (C) 2016-2019 THL A29 Limited, a Tencent company. All rights reserved.
 * Licensed under the MIT License (the "License"); you may not use this file except in compliance with the License. You may obtain a copy of the License at
 * http://opensource.org/licenses/MIT
 * Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.
 *****/

//
//  UILabel+QMUI.h
//  qmui
//
//  Created by QMUI Team on 15/7/20.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UILabel (QMUI)

- (instancetype)qmui_initWithFont:(nullable UIFont *)font textColor:(nullable UIColor *)textColor;

/**
 * @brief 在需要特殊样式时，可通过此属性直接给整个 label 添加 NSAttributeName 系列样式，然后 setText 即可，无需使用繁琐的 attributedText
 *
 * @note 即使先调用 setText/attributedText ，然后再设置此属性，此属性仍然会生效
 * @note 如果此属性包含了 NSKernAttributeName ，则最后一个字的 kern 效果会自动被移除，否则容易导致文字在视觉上不居中
 *
 * @note 当你设置了此属性后，每次你调用 setText: 时，其实都会被自动转而调用 setAttributedText:
 *
 * 现在你有三种方法控制 label 的样式：
 * 1. 本身的样式属性（如 textColor, font 等）
 * 2. qmui_textAttributes
 * 3. 构造 NSAttributedString
 * 这三种方式可以同时使用，如果样式发生冲突（比如先通过方法1将文字设成红色，又通过方法2将文字设成蓝色），则绝大部分情况下代码执行顺序靠后的会最终生效
 * 唯一例外的极端情况是：先用方法2将文字设成红色，再用方法1将文字设成蓝色，最后再 setText，这时虽然代码执行顺序靠后的是方法1，但最终生效的会是方法2，为了避免这种极端情况的困扰，建议不要同时使用方法1和方法2去设置同一种样式。
 *
 */
@property(nullable, nonatomic, copy) NSDictionary<NSAttributedStringKey, id> *qmui_textAttributes;

/** 
 *  Setter 设置当前整段文字的行高
 *  @note 如果同时通过 qmui_textAttributes 或 attributedText 给整段文字设置了行高，则此方法将不再生效。换句话说，此方法设置的行高将永远不会覆盖 qmui_textAttributes 或 attributedText 设置的行高。
 *  @note 比如对于字符串"abc"，你通过 attributedText 设置 {0, 1} 这个 range 范围内的行高为 10，又通过 setQmui_lineHeight: 设置了整体行高为 20，则最终 {0, 1} 内的行高将为 10，而 {1, 2} 内的行高将为全局行高 20
 *  @note 比如对于字符串"abc"，你先通过 setQmui_lineHeight: 设置整体行高为 10，又通过 attributedText/qmui_textAttributes 设置整体行高为 20，无论这两个设置的代码的先后顺序如何，最终行高都将为 20
 *
 *  @note 当你设置了此属性后，每次你调用 setText: 时，其实都会被自动转而调用 setAttributedText:
 *
 *  -----------------------------------
 *
 *  Getter 获取整段文字的行高
 *  @note 如果通过 setQmui_lineHeight 设置行高，会优先返回该值。
 *  @note 如果通过 NSParagraphStyleAttributeName 设置了行高，同时 range 是整段文字，则会返回 paraStyle.maximumLineHeight。
 *  @note 如果通过 setText 设置文本，会返回 font.lineHeight。
 *  @warning 除上述情况外，计算的数值都可能不准确，会返回 0。
 *
 */

@property(nonatomic, assign) CGFloat qmui_lineHeight;

/**
 * 将目标UILabel的样式属性设置到当前UILabel上
 *
 * 将会复制的样式属性包括：font、textColor、backgroundColor
 * @param label 要从哪个目标UILabel上复制样式
 */
- (void)qmui_setTheSameAppearanceAsLabel:(UILabel *)label;

/**
 * 在UILabel的样式（如字体）设置完后，将label的text设置为一个测试字符，再调用sizeToFit，从而令label的高度适应字体
 * @warning 会setText:，因此确保在配置完样式后、设置text之前调用
 */
- (void)qmui_calculateHeightAfterSetAppearance;

/**
 * UILabel在显示中文字符时，会比显示纯英文字符额外多了一个sublayers，并且这个layer超出了label.bounds的范围，这会导致label必定需要做像素合成，所以通过一些方式来避免合成操作
 * @see http://stackoverflow.com/questions/34895641/uilabel-is-marked-as-red-when-color-blended-layers-is-selected
 */
- (void)qmui_avoidBlendedLayersIfShowingChineseWithBackgroundColor:(UIColor *)color;

@end

NS_ASSUME_NONNULL_END
