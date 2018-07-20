//
//  QMUITabBarViewController.h
//  qmui
//
//  Created by QMUI Team on 15/3/29.
//  Copyright (c) 2015年 QMUI Team. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
 *  建议作为项目里 tabBarController 的基类，内部处理了几件事情：
 *  1. 配合配置表修改 tabBar 的样式。
 *  2. 管理界面支持显示的方向。
 *
 *  @warning 当你需要实现“tabBarController 首页那几个界面显示 tabBar，而 push 进去的所有子界面都隐藏 tabBar”的效果时，可将配置表里的 HidesBottomBarWhenPushedInitially 改为 YES，然后手动将 tabBarController 首页的那几个界面的 hidesBottomBarWhenPushed 属性改为 NO，即可实现。
 *
 *  Inherent your tabBarController from this, so you can enjoy:
 *  1. a tabBar with styles defined in configuration templates
 *. 2. a tabBar that manages supported interface orientations
 *
 */
@interface QMUITabBarViewController : UITabBarController

/**
 *  初始化时调用的方法，会在 initWithNibName:bundle: 和 initWithCoder: 这两个指定的初始化方法中被调用，所以子类如果需要同时支持两个初始化方法，则建议把初始化时要做的事情放到这个方法里。否则仅需重写要支持的那个初始化方法即可。
 *  Initialization method. Will be called in `initWithNibName:bundle:` and `initWithCoder:`. Implement this method to be called in both initializers.
 */
- (void)didInitialize NS_REQUIRES_SUPER;
@end
