/**
 * Tencent is pleased to support the open source community by making QMUI_iOS available.
 * Copyright (C) 2016-2021 THL A29 Limited, a Tencent company. All rights reserved.
 * Licensed under the MIT License (the "License"); you may not use this file except in compliance with the License. You may obtain a copy of the License at
 * http://opensource.org/licenses/MIT
 * Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.
 */

//
//  UISearchBar+QMUI.h
//  qmui
//
//  Created by QMUI Team on 16/5/26.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

/**
 提供更丰富的接口来修改 UISearchBar 的样式，注意大部分接口都同时支持配置表和 UIAppearance，如果有使用配置表并且该项的值不为 nil，则以配置表的值为准。
 */
@interface UISearchBar (QMUI)

/**
 获取与 searchBar 关联的 UISearchController
 */
@property(nonatomic, strong, readonly) UISearchController *qmui_searchController;

/**
 当以 tableHeaderView 的方式使用 UISearchBar 时，建议将这个属性置为 YES，从而可以帮你处理 https://github.com/Tencent/QMUI_iOS/issues/233 里列出的问题（抖动、iPhone X 适配等），默认为 NO
 */
@property(nonatomic, assign) BOOL qmui_usedAsTableHeaderView;

/// 是否让搜索框的 search icon、placeholder 在非搜索状态下居中（iOS 11 及以上，系统默认是居左的，iOS 10 及以下版本，系统默认就是居中），默认为 NO，也即维持系统默认表现不变。
@property(nonatomic, assign) BOOL qmui_centerPlaceholder UI_APPEARANCE_SELECTOR;

/// 输入框内 placeholder 的颜色
@property(nullable, nonatomic, strong) UIColor *qmui_placeholderColor UI_APPEARANCE_SELECTOR;

/// 输入框的文字颜色
@property(nullable, nonatomic, strong) UIColor *qmui_textColor UI_APPEARANCE_SELECTOR;

/// 输入框的文字字体，会同时影响 placeholder 的字体
@property(nullable, nonatomic, strong) UIFont *qmui_font UI_APPEARANCE_SELECTOR;

/// 输入框相对于系统原有布局位置的上下左右的偏移，正值表示向内缩小，负值表示向外扩大。注意输入框默认情况下就自带 (10, 8, 10, 8) 的间距，qmui_textFieldMargins 是基于这个间距的基础上做调整，换句话说，当 qmui_textFieldMargins 为 UIEdgeInsetsZero 时不代表输入框会上下左右都撑满父容器。
@property(nonatomic, assign) UIEdgeInsets qmui_textFieldMargins UI_APPEARANCE_SELECTOR;

/// 支持根据 active 的值的不同来设置不一样的输入框位置偏移，当使用这个 block 后 @c qmui_textFieldMargins 无效。
@property(nonatomic, copy) UIEdgeInsets (^qmui_textFieldMarginsBlock)(__kindof UISearchBar *searchBar, BOOL active);

/// 获取 searchBar 内部的输入框的引用，在 searchBar 初始化完即可被获取
@property(nullable, nonatomic, weak, readonly) UITextField *qmui_textField;

/// 获取 searchBar 的背景 view，为一个 UIImageView 的子类 UISearchBarBackground，在 searchBar 初始化完即可被获取
@property(nullable, nonatomic, weak, readonly) UIView *qmui_backgroundView;

/// 获取 searchBar 内的取消按钮，注意 UISearchBar 的取消按钮是在需要的时候才会生成（具体时机可以看 .m 内的 +load 方法）
@property(nullable, nonatomic, weak, readonly) UIButton *qmui_cancelButton;

/// 取消按钮的字体，由于系统的 cancelButton 是懒加载的，所以当不存在 cancelButton 时该值为 nil
@property(nullable, nonatomic, strong) UIFont *qmui_cancelButtonFont UI_APPEARANCE_SELECTOR;

/// 取消按钮相对于系统原有布局位置的上下左右的偏移。
@property(nonatomic, copy) UIEdgeInsets (^qmui_cancelButtonMarginsBlock)(__kindof UISearchBar *searchBar, BOOL active);

/// 当 UISearchBar 被直接初始化后使用时（也即不存在关联的 UISearchController），cancelButton 只有在 searchBar 聚焦升起键盘时才是 enabled，键盘降下时就 disabled。通常这不是我们想要的，所以提供这个开关，允许你强制保持 cancelButton 一直为 enabled。
/// 默认为 YES。
/// @note 注意只有 searchBar 不存在关联的 UISearchController 时，这个属性才会生效。
@property(nonatomic, assign) BOOL qmui_alwaysEnableCancelButton UI_APPEARANCE_SELECTOR;

/// 获取 scopeBar 里的 UISegmentedControl
@property(nullable, nonatomic, weak, readonly) UISegmentedControl *qmui_segmentedControl;

/// 控制 @c qmui_leftAccessoryView 的显隐，默认为 YES，仅当 @c qmui_leftAccessoryView 有值时才生效
@property(nonatomic, assign) BOOL qmui_showsLeftAccessoryView;
- (void)qmui_setShowsLeftAccessoryView:(BOOL)showsLeftAccessoryView animated:(BOOL)animated;

/// 在 searchBar 的输入框左边显示一个 view，当显示该 view 时会调用该 view 的 sizeToFit 来确定 view 的大小。注意系统默认行为是 UISearchBar 内只有 UIButton 类型的 view 才能接受点击事件，其他类型的 view 点击都是进入搜索状态。
@property(nonatomic, strong) UIView *qmui_leftAccessoryView;

/// 调整 @c qmui_leftAccessoryView 的布局，默认为 UIEdgeInsetsZero，也即左边贴紧 searchBar 边缘，右边与 textField 之间间隔系统默认的 8，垂直方向与 textField 居中。
@property(nonatomic, assign) UIEdgeInsets qmui_leftAccessoryViewMargins UI_APPEARANCE_SELECTOR;

/// 控制 @c qmui_rightAccessoryView 的显隐，默认为 YES，仅当 @c qmui_rightAccessoryView 有值时才生效
@property(nonatomic, assign) BOOL qmui_showsRightAccessoryView;
- (void)qmui_setShowsRightAccessoryView:(BOOL)showsRightAccessoryView animated:(BOOL)animated;

/// 在 searchBar 的输入框右边显示一个 view，当显示该 view 时会调用该 view 的 sizeToFit 来确定 view 的大小。注意系统默认行为是 UISearchBar 内只有 UIButton 类型的 view 才能接受点击事件，其他类型的 view 点击都是进入搜索状态。
@property(nonatomic, strong) UIView *qmui_rightAccessoryView;

/// 调整 @c qmui_rightAccessoryView 的布局，默认为 UIEdgeInsetsZero，也即左边与 textField 之间间隔系统默认的 8，右边贴紧 searchBar 边缘，垂直方向与 textField 居中。
@property(nonatomic, assign) UIEdgeInsets qmui_rightAccessoryViewMargins UI_APPEARANCE_SELECTOR;

/// 修复当 UISearchController.searchBar 被当做 tableHeaderView 使用时可能产生的布局问题
/// https://github.com/Tencent/QMUI_iOS/issues/950
@property(nonatomic, assign) BOOL qmui_fixMaskViewLayoutBugAutomatically;

- (void)qmui_styledAsQMUISearchBar;

/// 生成指定颜色的搜索框输入框背景图，大小与系统默认的保持一致，只是颜色不同
+ (nullable UIImage *)qmui_generateTextFieldBackgroundImageWithColor:(nullable UIColor *)color;

/// 生成指定背景色和底部边框颜色的搜索框背景图
+ (nullable UIImage *)qmui_generateBackgroundImageWithColor:(nullable UIColor *)backgroundColor borderColor:(nullable UIColor *)borderColor;

@end

NS_ASSUME_NONNULL_END
