//
//  UILabel+QMUI.h
//  qmui
//
//  Created by ZhoonChen on 15/7/20.
//  Copyright (c) 2015年 QMUI Team. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UILabel (QMUI)

- (instancetype)initWithFont:(UIFont *)font textColor:(UIColor *)textColor;

/**
 * @brief 在需要特殊样式时，可通过此属性直接给整个 label 添加 NSAttributeName 系列样式，然后 setText 即可，无需使用繁琐的 attributedText
 *
 * @note 即使先调用 setText/attributedText ，然后再设置此属性，此属性仍然会生效
 * @note 如果此属性包含了 NSKernAttributeName ，则最后一个字的 kern 效果会自动被移除，否则容易导致文字在视觉上不居中
 *
 * 现在你有三种方法控制 label 的样式：
 * 1. 本身的样式属性（如 textColor, font 等）
 * 2. qmui_textAttributes
 * 3. 构造 NSAttributedString
 * 这三种方式可以同时使用，如果样式发生冲突（比如先通过方法1将文字设成红色，又通过方法2将文字设成蓝色），则绝大部分情况下代码执行顺序靠后的会最终生效
 * 唯一例外的极端情况是：先用方法2将文字设成红色，再用方法1将文字设成蓝色，最后再 setText，这时虽然代码执行顺序靠后的是方法1，但最终生效的会是方法2，为了避免这种极端情况的困扰，建议不要同时使用方法1和方法2去设置同一种样式。
 *
 */
@property(nonatomic, copy) NSDictionary<NSString *, id> *qmui_textAttributes;

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
