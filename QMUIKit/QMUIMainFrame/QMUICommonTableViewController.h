/**
 * Tencent is pleased to support the open source community by making QMUI_iOS available.
 * Copyright (C) 2016-2021 THL A29 Limited, a Tencent company. All rights reserved.
 * Licensed under the MIT License (the "License"); you may not use this file except in compliance with the License. You may obtain a copy of the License at
 * http://opensource.org/licenses/MIT
 * Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.
 */

//
//  QMUICommonTableViewController.h
//  qmui
//
//  Created by QMUI Team on 14-6-24.
//

#import "QMUICommonViewController.h"
#import "QMUITableView.h"

NS_ASSUME_NONNULL_BEGIN

extern NSString *const QMUICommonTableViewControllerSectionHeaderIdentifier;
extern NSString *const QMUICommonTableViewControllerSectionFooterIdentifier;

/**
 *  可作为项目内所有 `UITableViewController` 的基类，注意是继承自 `QMUICommonViewController` 而不是 `UITableViewController`。
 *
 *  一般通过 `initWithStyle:` 方法初始化，对于要生成 `UITableViewStylePlain` 类型的列表，推荐使用 `init` 方法。
 *
 *  提供的功能包括：
 *
 *  1. 集成 `QMUISearchController`，可通过属性 `shouldShowSearchBar` 来快速为列表生成一个 searchBar 及 searchController，具体请查看 QMUICommonTableViewController (Search)。
 *  2. 支持仅设置 tableView:titleForHeaderInSection: 就能自动生成 sectionHeader 并且样式统一由配置表设置，无需编写 viewForHeaderInSection:、heightForHeaderInSection: 等方法。
 *  3. 自带一个 QMUIEmptyView，作为 tableView 的 subview，可用于显示 loading、空或错误提示语等。
 *
 *  @note emptyView 会从 tableHeaderView 的下方开始布局到 tableView 最底部，因此它会遮挡 tableHeaderView 之外的部分（比如 tableFooterView 和 cells ），你可以重写 layoutEmptyView 来改变这个布局方式
 *
 *  @see QMUISearchController
 */
@interface QMUICommonTableViewController : QMUICommonViewController<QMUITableViewDelegate, QMUITableViewDataSource>

- (instancetype)initWithStyle:(UITableViewStyle)style NS_DESIGNATED_INITIALIZER;
- (nullable instancetype)initWithCoder:(NSCoder *)aDecoder NS_DESIGNATED_INITIALIZER;

/**
 *  初始化时调用的方法，会在两个 NS_DESIGNATED_INITIALIZER 方法中被调用，所以子类如果需要同时支持两个 NS_DESIGNATED_INITIALIZER 方法，则建议把初始化时要做的事情放到这个方法里。否则仅需重写要支持的那个 NS_DESIGNATED_INITIALIZER 方法即可。
 */
- (void)didInitializeWithStyle:(UITableViewStyle)style NS_REQUIRES_SUPER;

/// 获取当前的 `UITableViewStyle`
@property(nonatomic, assign, readonly) UITableViewStyle style;

/// 当前的 tableView，如果需要使用自定义的 tableView class，可重写 initTableView 并在里面通过 self.tableView = xxx 为 tableView 赋值，注意需要自行指定 dataSource 和 delegate 但不需要 add 到 self.view 上。
/// @note 直接把自定义 tableView 赋值给 self.tableView 也可以，但 QMUI 将会多余地创建一次 QMUITableView，会造成浪费。
#if !TARGET_INTERFACE_BUILDER
@property(nonatomic, strong, null_resettable) IBOutlet __kindof QMUITableView *tableView;
#else
@property(nonatomic, strong, null_resettable) IBOutlet QMUITableView *tableView;
#endif

- (void)hideTableHeaderViewInitialIfCanWithAnimated:(BOOL)animated force:(BOOL)force;

@end


@interface QMUICommonTableViewController (QMUISubclassingHooks)

/**
 *  初始化 tableView，在 tableView getter 被调用时会触发，可重写这个方法并通过 self.tableView = xxx 来指定自定义的 tableView class，注意需要自行指定 dataSource 和 delegate，但不需要手动 add 到 self.view 上。一般情况下，有关tableView的设置属性的代码都应该写在这里。
 *
 *  @note 如果要为 self.tableView = xxx 赋值则不需要调用 super。
 *  @example
 *  - (void)initTableView {
 *      self.tableView = [MyTableView alloc] initWithFrame:self.view.bounds style:self.style];
 *      self.tableView.delegate = self;
 *      self.tableView.dataSource = self;
 *  }
 */
- (void)initTableView;

/**
 *  布局 tableView 的方法独立抽取出来，方便子类在需要自定义 tableView.frame 时能重写并且屏蔽掉 super 的代码。如果不独立一个方法而是放在 viewDidLayoutSubviews 里，子类就很难屏蔽 super 里对 tableView.frame 的修改。
 *  默认的实现是撑满 self.view，如果要自定义，可以写在这里而不调用 super，或者干脆重写这个方法但留空
 */
- (void)layoutTableView;

/**
 *  是否需要在第一次进入界面时将tableHeaderView隐藏（通过调整self.tableView.contentOffset实现）
 *
 *  默认为NO
 *
 *  @see QMUITableViewDelegate
 */
- (BOOL)shouldHideTableHeaderViewInitial;

@end

NS_ASSUME_NONNULL_END
