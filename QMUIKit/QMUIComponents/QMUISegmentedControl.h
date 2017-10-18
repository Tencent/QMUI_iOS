//
//  QMUISegmentedControl.h
//  qmui
//
//  Created by ZhoonChen on 14/11/3.
//  Copyright (c) 2014年 QMUI Team. All rights reserved.
//

#import <UIKit/UIKit.h>

/*
 * QMUISegmentedControl，继承自 UISegmentedControl
 * 如果需要更大程度地修改样式，比如说字体大小，选中的 segment 的文字颜色等等，可以使用下面的第一个方法来做
 * QMUISegmentedControl 也同样支持使用图片来做样式，需要五张图片。
 */
@interface QMUISegmentedControl : UISegmentedControl

/// 获取当前的所有 segmentItem，可能包括 NSString 或 UIImage。
@property(nonatomic, copy, readonly) NSArray *segmentItems;

/**
 * 重新渲染 UISegmentedControl 的 UI，可以比较大程度地修改样式。比如 tintColor，selectedTextColor 等等。
 *
 * @param tintColor             Segmented 的 tintColor，作用范围包括字体颜色和按钮 border
 * @param selectedTextColor     Segmented 选中状态的字体颜色
 * @param fontSize              Segmented 上字体的大小
 */
- (void)updateSegmentedUIWithTintColor:(UIColor *)tintColor
                     selectedTextColor:(UIColor *)selectedTextColor
                              fontSize:(UIFont *)fontSize;

/**
 * 用图片而非 tintColor 来渲染 UISegmentedControl 的 UI
 *
 * @param normalImage               Segmented 非选中状态的背景图
 * @param selectedImage             Segmented 选中状态的背景图
 * @param devideImage00             Segmented 在两个没有选中按钮 item 之间的分割线
 * @param devideImage01             Segmented 在左边没选中右边选中两个 item 之间的分割线
 * @param devideImage10             Segmented 在左边选中右边没选中两个 item 之间的分割线
 * @param textColor                 Segmented 的字体颜色
 * @param selectedTextColor         Segmented 选中状态的字体颜色
 * @param fontSize                  Segmented 的字体大小
 */
- (void)setBackgroundWithNormalImage:(UIImage *)normalImage
                       selectedImage:(UIImage *)selectedImage
                       devideImage00:(UIImage *)devideImage00
                       devideImage01:(UIImage *)devideImage01
                       devideImage10:(UIImage *)devideImage10
                           textColor:(UIColor *)textColor
                   selectedTextColor:(UIColor *)selectedTextColor
                            fontSize:(UIFont *)fontSize;
@end
