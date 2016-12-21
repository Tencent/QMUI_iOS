//
//  UIColor+QMUI.h
//  qmui
//
//  Created by ZhoonChen on 15/7/20.
//  Copyright (c) 2015年 QMUI Team. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIColor (QMUI)

/**
 *  使用HEX命名方式的颜色字符串生成一个UIColor对象
 *
 *  @param hexString
 *      #RGB        例如#f0f，等同于#ffff00ff，RGBA(255, 0, 255, 1)
 *      #ARGB       例如#0f0f，等同于#00ff00ff，RGBA(255, 0, 255, 0)
 *      #RRGGBB     例如#ff00ff，等同于#ffff00ff，RGBA(255, 0, 255, 1)
 *      #AARRGGBB   例如#00ff00ff，等同于RGBA(255, 0, 255, 0)
 *
 * @return UIColor对象
 */
+ (UIColor *)colorWithHexString:(NSString *)hexString;

/**
 *  将当前色值转换为hex字符串，通道排序是AARRGGBB（与Android保持一致）
 */
- (NSString *)hexString;

/**
 *  获取当前UIColor对象里的红色色值
 *
 *  @return 红色通道的色值，值范围为0.0-1.0
 */
- (CGFloat)red;

/**
 *  获取当前UIColor对象里的绿色色值
 *
 *  @return 绿色通道的色值，值范围为0.0-1.0
 */
- (CGFloat)green;

/**
 *  获取当前UIColor对象里的蓝色色值
 *
 *  @return 蓝色通道的色值，值范围为0.0-1.0
 */
- (CGFloat)blue;

/**
 *  获取当前UIColor对象里的透明色值
 *
 *  @return 透明通道的色值，值范围为0.0-1.0
 */
- (CGFloat)alpha;

/**
 *  获取当前UIColor对象里的hue（色相）
 */
- (CGFloat)hue;

/**
 *  获取当前UIColor对象里的saturation（饱和度）
 */
- (CGFloat)saturation;

/**
 *  获取当前UIColor对象里的brightness（亮度）
 */
- (CGFloat)brightness;

/**
 *  将当前UIColor对象剥离掉alpha通道后得到的色值。相当于把当前颜色的半透明值强制设为1.0后返回
 *
 *  @return alpha通道为1.0，其他rgb通道与原UIColor对象一致的新UIColor对象
 */
- (UIColor *)colorWithoutAlpha;

/**
 *  计算当前color叠加了alpha之后放在指定颜色的背景上的色值
 */
- (UIColor *)colorWithAlpha:(CGFloat)alpha backgroundColor:(UIColor *)backgroundColor;

/**
 *  计算当前color叠加了alpha之后放在白色背景上的色值
 */
- (UIColor *)colorWithAlphaAddedToWhite:(CGFloat)alpha;

/**
 *  将自身变化到某个目标颜色，可通过参数progress控制变化的程度，最终得到一个纯色
 *  @param toColor 目标颜色
 *  @param progress 变化程度，取值范围0.0f~1.0f
 */
- (UIColor *)transitionToColor:(UIColor *)toColor progress:(CGFloat)progress;

/**
 *  计算两个颜色叠加之后的最终色（注意区分前景色后景色的顺序）<br/>
 *  @link http://stackoverflow.com/questions/10781953/determine-rgba-colour-received-by-combining-two-colours @/link
 */
+ (UIColor *)colorWithBackendColor:(UIColor *)backendColor frontColor:(UIColor *)frontColor;

/**
 *  将颜色A变化到颜色B，可通过progress控制变化的程度
 *  @param fromColor 起始颜色
 *  @param toColor 目标颜色
 *  @param progress 变化程度，取值范围0.0f~1.0f
 */
+ (UIColor *)colorFromColor:(UIColor *)fromColor toColor:(UIColor *)toColor progress:(CGFloat)progress;

/**
 *  产生一个随机色，大部分情况下用于测试
 */
+ (UIColor *)randomColor;

/**
 *  判断当前颜色是否为深色，可用于根据不同色调动态设置不同文字颜色的场景。
 *
 *  @link http://stackoverflow.com/questions/19456288/text-color-based-on-background-image @/link
 *
 *  @return 若为深色则返回“YES”，浅色则返回“NO”
 */
- (BOOL)colorIsDark;

/**
 *  当前颜色的反色
 *
 *  @link http://stackoverflow.com/questions/5893261/how-to-get-inverse-color-from-uicolor @/link
 */
- (UIColor *)inverseColor;

@end
