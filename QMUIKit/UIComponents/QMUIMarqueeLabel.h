//
//  QMUIMarqueeLabel.h
//  qmui
//
//  Created by MoLice on 2017/5/31.
//  Copyright © 2017年 QMUI Team. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
 *  简易的跑马灯 label 控件，在文字超过 label 可视区域时会自动开启跑马灯效果展示文字。
 *  @warning 会忽略 textAlignment 属性，强制以 NSTextAlignmentLeft 来展示。
 *  @warning 会忽略 numberOfLines 属性，强制以 1 来展示。
 */
@interface QMUIMarqueeLabel : UILabel

/// TODO: 控制滚动的速度，暂时没实现
@property(nonatomic, assign) NSTimeInterval speed;

/// 当文字滚动到开头和结尾两处时都要停顿一下，这个属性控制停顿的时长，默认为 1，单位为秒。
@property(nonatomic, assign) NSTimeInterval pauseDurationWhenMoveToEdge;
@end
