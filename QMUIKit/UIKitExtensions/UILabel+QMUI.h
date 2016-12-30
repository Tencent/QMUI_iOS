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
