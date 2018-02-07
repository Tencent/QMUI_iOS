//
//  UISearchBar+QMUI.h
//  qmui
//
//  Created by MoLice on 16/5/26.
//  Copyright © 2016年 QMUI Team. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface UISearchBar (QMUI)

/// 当以 tableHeaderView 的方式使用 UISearchBar 时，建议将这个属性置为 YES，从而可以帮你处理 https://github.com/QMUI/QMUI_iOS/issues/233 里列出的问题（抖动、iPhone X 适配等）
/// 默认值为 NO
@property(nonatomic, assign) BOOL qmui_usedAsTableHeaderView;

@property(nullable, nonatomic, strong) UIColor *qmui_placeholderColor;
@property(nullable, nonatomic, strong) UIColor *qmui_textColor;
@property(nullable, nonatomic, strong) UIFont *qmui_font;
@property(nonatomic, assign) UIEdgeInsets qmui_textFieldMargins;

/// 获取 searchBar 内的输入框
@property(nullable, nonatomic, weak, readonly) UITextField *qmui_textField;

/// 获取 searchBar 内的取消按钮
@property(nullable, nonatomic, weak, readonly) UIButton *qmui_cancelButton;

/// 获取 scopeBar 里的 UISegmentedControl
@property(nullable, nonatomic, weak, readonly) UISegmentedControl *qmui_segmentedControl;

- (void)qmui_styledAsQMUISearchBar;

@end
