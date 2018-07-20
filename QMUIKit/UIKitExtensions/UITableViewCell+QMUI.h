//
//  UITableViewCell+QMUI.h
//  QMUIKit
//
//  Created by MoLice on 2018/7/5.
//  Copyright © 2018年 QMUI Team. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UITableViewCell (QMUI)

/// 获取当前 cell 的 accessoryView，优先级分别是：编辑状态下的 editingAccessoryView -> 编辑状态下的系统自己的 accessoryView -> 普通状态下的自定义 accessoryView -> 普通状态下系统自己的 accessoryView
@property(nonatomic, strong, readonly) __kindof UIView *qmui_accessoryView;

@end
