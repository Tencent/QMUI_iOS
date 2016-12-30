//
//  UITabBarItem+QMUI.h
//  qmui
//
//  Created by ZhoonChen on 15/7/20.
//  Copyright (c) 2015年 QMUI Team. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UITabBarItem (QMUI)

/**
 * 获取一个UITabBarItem内的按钮，里面包含imageView、label等子View
 */
- (UIControl *)qmui_barButton;

/**
 * 获取一个UITabBarItem内显示图标的UIImageView，如果找不到则返回nil
 * @warning 需要对nil的返回值做保护
 */
- (UIImageView *)qmui_imageView;

@end
