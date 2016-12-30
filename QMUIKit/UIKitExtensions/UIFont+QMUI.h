//
//  UIFont+QMUI.h
//  qmui
//
//  Created by ZhoonChen on 15/7/20.
//  Copyright (c) 2015年 QMUI Team. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIFont (QMUI)

/**
 * 返回系统字体的细体
 *
 * @param fontSize 字体大小
 *
 * @return 变细的系统字体的UIFont对象
 */
+ (UIFont *)qmui_lightSystemFontOfSize:(CGFloat)fontSize;

/**
 * 返回支持动态字体的UIFont
 *
 * @param pointSize 默认的size
 * @param bold 是否加粗
 *
 * @return 支持动态字体的UIFont对象
 */
+ (UIFont *)qmui_dynamicFontWithSize:(CGFloat)pointSize bold:(BOOL)bold;

/**
 * 返回支持动态字体的UIFont，支持定义最小和最大字号
 *
 * @param pointSize 默认的size
 * @param upperLimitSize 最大的字号限制
 * @param lowerLimitSize 最小的字号显示
 * @param bold 是否加粗
 *
 * @return 支持动态字体的UIFont对象
 */
+ (UIFont *)qmui_dynamicFontWithSize:(CGFloat)pointSize upperLimitSize:(CGFloat)upperLimitSize lowerLimitSize:(CGFloat)lowerLimitSize bold:(BOOL)bold;

@end
