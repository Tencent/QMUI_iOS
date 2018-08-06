//
//  CAAnimation+QMUI.h
//  QMUIKit
//
//  Created by MoLice on 2018/7/31.
//  Copyright © 2018年 QMUI Team. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>

@interface CAAnimation (QMUI)

@property(nonatomic, copy) void (^qmui_animationDidStartBlock)(__kindof CAAnimation *aAnimation);
@property(nonatomic, copy) void (^qmui_animationDidStopBlock)(__kindof CAAnimation *aAnimation, BOOL finished);
@end
