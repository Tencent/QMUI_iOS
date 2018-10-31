//
//  UITabBar+QMUI.h
//  qmui
//
//  Created by MoLice on 2017/2/14.
//  Copyright © 2017年 QMUI Team. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UITabBar (QMUI)

/**
 UITabBar 的背景 view，可能显示磨砂、背景图，顶部有一部分溢出到 UITabBar 外。
 
 在 iOS 10 及以后是私有的 _UIBarBackground 类。
 
 在 iOS 9 及以前是私有的 _UITabBarBackgroundView 类。
 */
@property(nonatomic, strong, readonly) UIView *qmui_backgroundView;

/**
 qmui_backgroundView 内的 subview，用于显示顶部分隔线 shadowImage，注意这个 view 是溢出到 qmui_backgroundView 外的。若 shadowImage 为 [UIImage new]，则这个 view 的高度为 0。
 */
@property(nonatomic, strong, readonly) UIImageView *qmui_shadowImageView;

@end
