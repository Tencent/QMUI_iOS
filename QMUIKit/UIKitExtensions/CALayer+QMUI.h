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
 * 移除CALayer一些常见action，方便需要一个不带动画的layer时使用。
 */
- (void)qmui_removeDefaultAnimations;

@end
