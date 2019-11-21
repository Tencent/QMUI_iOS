/*****
 * Tencent is pleased to support the open source community by making QMUI_iOS available.
 * Copyright (C) 2016-2019 THL A29 Limited, a Tencent company. All rights reserved.
 * Licensed under the MIT License (the "License"); you may not use this file except in compliance with the License. You may obtain a copy of the License at
 * http://opensource.org/licenses/MIT
 * Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.
 *****/

//
//  UITableViewCell+QMUI.h
//  QMUIKit
//
//  Created by QMUI Team on 2018/7/5.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UITableViewCell (QMUI)

/// 获取当前 cell 所在的 tableView，iOS 13 下在 init 时就可以获取到值，而 iOS 12 及以下只能在 cell 被塞给 tableView 后才能获取到值
@property(nonatomic, weak, readonly, nullable) UITableView *qmui_tableView;

/// 设置 cell 点击时的背景色，如果没有 selectedBackgroundView 会创建一个。
/// @warning 请勿再使用 self.selectedBackgroundView.backgroundColor 修改，因为 QMUITheme 里会重新应用 qmui_selectedBackgroundColor，会覆盖 self.selectedBackgroundView.backgroundColor 的效果。
@property(nonatomic, strong, nullable) UIColor *qmui_selectedBackgroundColor;

/// setHighlighted:animated: 方法的回调 block
@property(nonatomic, copy, nullable) void (^qmui_setHighlightedBlock)(BOOL highlighted, BOOL animated);

/// setSelected:animated: 方法的回调 block
@property(nonatomic, copy, nullable) void (^qmui_setSelectedBlock)(BOOL selected, BOOL animated);

/// 获取当前 cell 的 accessoryView，优先级分别是：编辑状态下的 editingAccessoryView -> 编辑状态下的系统自己的 accessoryView -> 普通状态下的自定义 accessoryView -> 普通状态下系统自己的 accessoryView
@property(nonatomic, strong, readonly, nullable) __kindof UIView *qmui_accessoryView;

@end

@interface UITableViewCell (QMUI_Styled)

/// 按照 QMUI 配置表的值来将 cell 设置为全局统一的样式
- (void)qmui_styledAsQMUITableViewCell;

@property(nonatomic, strong, readonly, nullable) UIColor *qmui_styledTextLabelColor;
@property(nonatomic, strong, readonly, nullable) UIColor *qmui_styledDetailTextLabelColor;
@property(nonatomic, strong, readonly, nullable) UIColor *qmui_styledBackgroundColor;
@property(nonatomic, strong, readonly, nullable) UIColor *qmui_styledSelectedBackgroundColor;
@property(nonatomic, strong, readonly, nullable) UIColor *qmui_styledWarningBackgroundColor;
@end

NS_ASSUME_NONNULL_END
