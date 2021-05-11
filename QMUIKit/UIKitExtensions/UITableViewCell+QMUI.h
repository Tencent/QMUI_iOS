/**
 * Tencent is pleased to support the open source community by making QMUI_iOS available.
 * Copyright (C) 2016-2021 THL A29 Limited, a Tencent company. All rights reserved.
 * Licensed under the MIT License (the "License"); you may not use this file except in compliance with the License. You may obtain a copy of the License at
 * http://opensource.org/licenses/MIT
 * Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.
 */

//
//  UITableViewCell+QMUI.h
//  QMUIKit
//
//  Created by QMUI Team on 2018/7/5.
//

#import <UIKit/UIKit.h>
#import "UITableView+QMUI.h"

NS_ASSUME_NONNULL_BEGIN

/// 用于在 @c qmui_separatorInsetsBlock @c qmui_topSeparatorInsetsBlock 里作为”不需要分隔线“的标志返回
extern const UIEdgeInsets QMUITableViewCellSeparatorInsetsNone;

@interface UITableViewCell (QMUI)

/// 获取当前 cell 所在的 tableView，iOS 13 下在 cellForRow(heightForRow 内不可以) 内 init 完 cell 就可以获取到值，而 iOS 12 及以下只能在 cell 即将显示时（也即 willDisplay 之前）才能获取到值
@property(nonatomic, weak, readonly, nullable) UITableView *qmui_tableView;

/// 当 cell 内部可以访问到 tableView 时就会调用这个 block，内部会做过滤，tableView 指针不变就不会再调用
/// @note 一般情况下 iOS 13 及以后的版本，cellForRow 里的 cell init 完立马就可以访问到 tableView 了，而其他低版本要等到 willDisplayCell 之前才可以访问到。
@property(nonatomic, copy, nullable) void (^qmui_didAddToTableViewBlock)(__kindof UITableView *tableView, __kindof UITableViewCell *cell);

/// 获取当前 cell 初始化时用的 style 值
@property(nonatomic, assign, readonly) UITableViewCellStyle qmui_style;

/// cell 在当前 section 里的位置，在 willDisplayCell 时可以使用，cellForRow 里只能自己使用 -[UITableView qmui_positionForRowAtIndexPath:] 获取。
@property(nonatomic, assign, readonly) QMUITableViewCellPosition qmui_cellPosition;

/**
 设置 cell 的样式（不影响 cell 高度的那些，例如各种颜色、圆角等），会在 willDisplayCell 之前被调用，在 block 被调用时已经能拿到 tableView 的引用，所以便于根据 tableView 的不同属性来配置 cell 不同的外观（例如同一个 cell 被分别用于 Plain、Grouped 的列表时要展示不一样的外观）。亦可以通过 cell.qmui_cellPosition 得到 cell 在 section 里的位置。
 @note 该 block 可能会不断调用（参考 UITableViewDelegate willDisplayCell），注意不要在里面做耗时操作。
 */
@property(nonatomic, copy, nullable) void (^qmui_configureStyleBlock)(__kindof UITableView *tableView, __kindof UITableViewCell *cell, NSIndexPath * _Nullable indexPath);

/**
 控制 cell 的分隔线位置，做成 block 的形式是为了方便根据不同的 UITableViewStyle 以及不同的 QMUITableViewCellPosition （通过 cell.qmui_cellPosition 获取）来设置不同的分隔线缩进。分隔线默认是左右撑满整个 cell 的，通过这个 block 返回一个 insets 则会基于整个 cell 的宽度减去 insets 的值得到最终分隔线的布局，如果某些位置不需要分隔线可以返回 QMUITableViewCellSeparatorInsetsNone。
 
 @note 只有在 tableView.separatorStyle != UITableViewCellSeparatorStyleNone 时才会出现分隔线，而分隔线的颜色则由 tableView.separatorColor 控制。创建这个属性的背景是当你希望用 UITableView 系统提供的接口去控制分隔线显隐时，会发现很难调整每个 cell 内的分隔线位置及显示/隐藏逻辑（例如最后一个 cell 不要分隔线），此时你可以用这个属性来达到自定义的目的。当 block 不为空时，内部实际上会创建一条自定义的分隔线来代替系统的，系统自带的分隔线会被隐藏。
 
 @warning 注意分隔线是放在 cell 上的，而 cell.textLabel 等 subviews 是放在 cell.contentView 上的，所以如果分隔线要参照其他 subviews 布局的话，要注意坐标系转换。
 */
@property(nonatomic, copy, nullable) UIEdgeInsets (^qmui_separatorInsetsBlock)(__kindof UITableView *tableView, __kindof UITableViewCell *cell);

/**
 控制 cell 的顶部分隔线位置，其他信息参考 @c qmui_separatorInsetsBlock
 */
@property(nonatomic, copy, nullable) UIEdgeInsets (^qmui_topSeparatorInsetsBlock)(__kindof UITableView *tableView, __kindof UITableViewCell *cell);

/// 设置 cell 点击时的背景色，如果没有 selectedBackgroundView 会创建一个。
/// @warning 请勿再使用 self.selectedBackgroundView.backgroundColor 修改，因为 QMUITheme 里会重新应用 qmui_selectedBackgroundColor，会覆盖 self.selectedBackgroundView.backgroundColor 的效果。
@property(nonatomic, strong, nullable) UIColor *qmui_selectedBackgroundColor;

/// setHighlighted:animated: 方法的回调 block
@property(nonatomic, copy, nullable) void (^qmui_setHighlightedBlock)(BOOL highlighted, BOOL animated);

/// setSelected:animated: 方法的回调 block
@property(nonatomic, copy, nullable) void (^qmui_setSelectedBlock)(BOOL selected, BOOL animated);

/**
 获取当前 cell 的 accessoryView，优先级分别是：编辑状态下的 editingAccessoryView -> 编辑状态下的系统自己的 accessoryView -> 普通状态下的自定义 accessoryView -> 普通状态下系统自己的 accessoryView。
 @note 对于系统的 UITableViewCellAccessoryDetailDisclosureButton，iOS 12 及以下是一个 UITableViewCellDetailDisclosureView，而 iOS 13 及以上被拆成两个独立的 view，此时 qmui_accessoryView 只能返回布局上更靠左的那个 view。
*/
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
