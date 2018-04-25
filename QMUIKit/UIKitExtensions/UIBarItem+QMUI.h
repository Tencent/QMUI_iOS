//
//  UIBarItem+QMUI.h
//  QMUIKit
//
//  Created by MoLice on 2018/4/5.
//  Copyright © 2018年 QMUI Team. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIBarItem (QMUI)

/// 获取 UIBarItem（UIBarButtonItem、UITabBarItem） 内部的 view，通常对于 navigationItem 而言，需要在设置了 navigationItem 后并且在 navigationBar 可见时（例如 viewDidAppear: 及之后）获取 UIBarButtonItem.qmui_view 才有值。
/// 对于 UIBarButtonItem 和 UITabBarItem 而言，获取到的 view 均为 UIControl 的私有子类。
@property(nullable, nonatomic, weak, readonly) UIView *qmui_view;
@end
