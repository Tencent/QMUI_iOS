//
//  UISearchBar+QMUI.h
//  qmui
//
//  Created by MoLice on 16/5/26.
//  Copyright © 2016年 QMUI Team. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

/**
 提供更丰富的接口来修改 UISearchBar 的样式，注意大部分接口都同时支持配置表和 UIAppearance，如果有使用配置表并且该项的值不为 nil，则以配置表的值为准。
 */
@interface UISearchBar (QMUI)

/**
 当以 tableHeaderView 的方式使用 UISearchBar 时，建议将这个属性置为 YES，从而可以帮你处理 https://github.com/QMUI/QMUI_iOS/issues/233 里列出的问题（抖动、iPhone X 适配等），默认为 NO
 */
@property(nonatomic, assign) BOOL qmui_usedAsTableHeaderView;

/// 输入框内 placeholder 的颜色
@property(nullable, nonatomic, strong) UIColor *qmui_placeholderColor UI_APPEARANCE_SELECTOR;

/// 输入框的文字颜色
@property(nullable, nonatomic, strong) UIColor *qmui_textColor UI_APPEARANCE_SELECTOR;

/// 输入框的文字字体，会同时影响 placeholder 的字体
@property(nullable, nonatomic, strong) UIFont *qmui_font UI_APPEARANCE_SELECTOR;

/// 输入框相对于系统原有布局位置的上下左右的偏移，正值表示向内缩小，负值表示向外扩大
@property(nonatomic, assign) UIEdgeInsets qmui_textFieldMargins UI_APPEARANCE_SELECTOR;

/// 获取 searchBar 内的输入框
@property(nullable, nonatomic, weak, readonly) UITextField *qmui_textField;

/// 获取 searchBar 内的取消按钮，注意 UISearchBar 的取消按钮是在 setShowsCancelButton:animated: 被调用之后才会生成
@property(nullable, nonatomic, weak, readonly) UIButton *qmui_cancelButton;

/// 取消按钮的字体，由于系统的 cancelButton 是懒加载的，所以当不存在 cancelButton 时该值为 nil
@property(nullable, nonatomic, strong) UIFont *qmui_cancelButtonFont UI_APPEARANCE_SELECTOR;

/// 获取 scopeBar 里的 UISegmentedControl
@property(nullable, nonatomic, weak, readonly) UISegmentedControl *qmui_segmentedControl;

- (void)qmui_styledAsQMUISearchBar;

@end
