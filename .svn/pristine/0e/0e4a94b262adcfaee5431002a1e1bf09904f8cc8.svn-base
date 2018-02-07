//
//  CALayer+QMUI.h
//  qmui
//
//  Created by MoLice on 16/8/12.
//  Copyright © 2016年 QMUI Team. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <QuartzCore/QuartzCore.h>

@interface CALayer (QMUI)

/**
 *  把某个 sublayer 移动到当前所有 sublayers 的最后面
 *  @param sublayer 要被移动的 layer
 *  @warning 要被移动的 sublayer 必须已经添加到当前 layer 上
 */
- (void)qmui_sendSublayerToBack:(CALayer *)sublayer;

/**
 *  把某个 sublayer 移动到当前所有 sublayers 的最前面
 *  @param sublayer 要被移动的layer
 *  @warning 要被移动的 sublayer 必须已经添加到当前 layer 上
 */
- (void)qmui_bringSublayerToFront:(CALayer *)sublayer;

/**
 * 移除 CALayer（包括 CAShapeLayer 和 CAGradientLayer）所有支持动画的属性的默认动画，方便需要一个不带动画的 layer 时使用。
 */
- (void)qmui_removeDefaultAnimations;

/**
 * 生成虚线的方法，注意返回的是 CAShapeLayer
 * @param lineLength   每一段的线宽
 * @param lineSpacing  线之间的间隔
 * @param lineWidth    线的宽度
 * @param lineColor    线的颜色
 * @param isHorizontal 是否横向，因为画虚线的缘故，需要指定横向或纵向，横向是 YES，纵向是 NO。
 * 注意：暂不支持 dashPhase 和 dashPattens 数组设置，因为这些都定制性太强，如果用到则自己调用系统方法即可。
 */

+ (CAShapeLayer *)qmui_seperatorDashLayerWithLineLength:(NSInteger)lineLength
                                            lineSpacing:(NSInteger)lineSpacing
                                              lineWidth:(CGFloat)lineWidth
                                              lineColor:(CGColorRef)lineColor
                                           isHorizontal:(BOOL)isHorizontal;

/**
 
 * 产生一个通用分隔虚线的 layer，高度为 PixelOne，线宽为 2，线距为 2，默认会移除动画，并且背景色用 UIColorSeparator，注意返回的是 CAShapeLayer。
 
 * 其中，InHorizon 是横向；InVertical 是纵向。
 
 */

+ (CAShapeLayer *)qmui_seperatorDashLayerInHorizontal;

+ (CAShapeLayer *)qmui_seperatorDashLayerInVertical;

/**
 * 产生一个适用于做通用分隔线的 layer，高度为 PixelOne，默认会移除动画，并且背景色用 UIColorSeparator
 */
+ (CALayer *)qmui_separatorLayer;

/**
 * 产生一个适用于做列表分隔线的 layer，高度为 PixelOne，默认会移除动画，并且背景色用 TableViewSeparatorColor
 */
+ (CALayer *)qmui_separatorLayerForTableView;

@end
