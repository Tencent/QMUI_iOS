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
 *  把某个sublayer移动到当前所有sublayers的最后面
 *  @param  sublayer    要被移动的layer
 *  @warning 要被移动的sublayer必须已经添加到当前layer上
 */
- (void)qmui_sendSublayerToBack:(CALayer *)sublayer;

/**
 *  把某个sublayer移动到当前所有sublayers的最前面
 *  @param  sublayer    要被移动的layer
 *  @warning 要被移动的sublayer必须已经添加到当前layer上
 */
- (void)qmui_bringSublayerToFront:(CALayer *)sublayer;

/**
 * 移除 CALayer（包括 CAShapeLayer 和 CAGradientLayer）所有支持动画的属性的默认动画，方便需要一个不带动画的 layer 时使用。
 */
- (void)qmui_removeDefaultAnimations;

/**
 * 产生一个适用于做通用分隔线的 layer，高度为 PixelOne，默认会移除动画，并且背景色用 UIColorSeparator
 */
+ (CALayer *)qmui_separatorLayer;

/**
 * 产生一个适用于做列表分隔线的 layer，高度为 PixelOne，默认会移除动画，并且背景色用 TableViewSeparatorColor
 */
+ (CALayer *)qmui_separatorLayerForTableView;
@end
