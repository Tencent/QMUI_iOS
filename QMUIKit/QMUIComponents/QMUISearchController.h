/**
 * Tencent is pleased to support the open source community by making QMUI_iOS available.
 * Copyright (C) 2016-2021 THL A29 Limited, a Tencent company. All rights reserved.
 * Licensed under the MIT License (the "License"); you may not use this file except in compliance with the License. You may obtain a copy of the License at
 * http://opensource.org/licenses/MIT
 * Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.
 */

//
//  QMUISearchController.h
//
//  Created by QMUI Team on 16/5/25.
//

#import <UIKit/UIKit.h>
#import "QMUICommonViewController.h"
#import "QMUICommonTableViewController.h"

@class QMUIEmptyView;
@class QMUISearchController;

/**
 *  配合 QMUISearchController 使用的 protocol，主要负责两件事情：
 *
 *  1. 响应用户的输入，在搜索框内的文字发生变化后被调用，可在 searchController:updateResultsForSearchString: 方法内更新搜索结果的数据集，在里面请自行调用 [searchController.tableView reloadData]
 *  2. 渲染最终用于显示搜索结果的 UITableView 的数据，该 tableView 的 delegate、dataSource 均包含在这个 protocol 里
 */
@protocol QMUISearchControllerDelegate <QMUITableViewDataSource, QMUITableViewDelegate>

@required
/**
 *  搜索框文字发生变化时的回调，请自行调用 `[tableView reloadData]` 来更新界面。
 *  @warning 搜索框文字为空（例如第一次点击搜索框进入搜索状态时，或者文字全被删掉了，或者点击搜索框的×）也会走进来，此时参数searchString为@""，这是为了和系统的UISearchController保持一致
 */
- (void)searchController:(QMUISearchController *)searchController updateResultsForSearchString:(NSString *)searchString;

@optional
- (void)willPresentSearchController:(QMUISearchController *)searchController;
- (void)didPresentSearchController:(QMUISearchController *)searchController;
- (void)willDismissSearchController:(QMUISearchController *)searchController;
- (void)didDismissSearchController:(QMUISearchController *)searchController;
- (void)searchController:(QMUISearchController *)searchController didLoadSearchResultsTableView:(UITableView *)tableView;
- (void)searchController:(QMUISearchController *)searchController willShowEmptyView:(QMUIEmptyView *)emptyView;

@end

/**
 *  支持在搜索文字为空时（注意并非“搜索结果为空”）显示一个界面，例如常见的“最近搜索”功能，具体请查看属性 launchView。
 *  使用方法：
 *  1. 使用 initWithContentsViewController: 初始化
 *  2. 通过 searchBar 属性得到搜索框的引用并直接使用，例如 `tableHeaderView = searchController.searchBar`
 *  3. 指定 searchResultsDelegate 属性并在其中实现 searchController:updateResultsForSearchString: 方法以更新搜索结果数据集
 *  4. 如果需要，可通过 @c qmui_preferredStatusBarStyleBlock 来控制搜索状态下的状态栏样式。
 *
 *  @note QMUICommonTableViewController 内部自带 QMUISearchController，只需将属性 shouldShowSearchBar 置为 YES 即可，无需自行初始化 QMUISearchController。
 */
@interface QMUISearchController : QMUICommonViewController<UISearchResultsUpdating, UISearchControllerDelegate>

/**
 *  在某个指定的 UIViewController 上创建一个与其绑定的 searchController，并指定结果列表的 style。
 *  @param viewController 要在哪个viewController上添加搜索功能
 */
- (instancetype)initWithContentsViewController:(UIViewController *)viewController resultsTableViewStyle:(UITableViewStyle)resultsTableViewStyle;

/**
 *  在某个指定的 UIViewController 上创建一个与其绑定的 searchController
 *  @param viewController 要在哪个viewController上添加搜索功能
 */
- (instancetype)initWithContentsViewController:(UIViewController *)viewController;

@property(nonatomic, weak) id<QMUISearchControllerDelegate> searchResultsDelegate;

/// 搜索框
@property(nonatomic, strong, readonly) UISearchBar *searchBar;

/// 搜索结果列表
@property(nonatomic, strong, readonly) QMUITableView *tableView;

/// 在搜索文字为空时会展示的一个 view，通常用于实现“最近搜索”之类的功能。launchView 最终会被布局为撑满搜索框以下的所有空间。
@property(nonatomic, strong) UIView *launchView;

/// 升起键盘时的半透明遮罩，nil 表示用系统的，非 nil 则用自己的。默认为 nil。
/// @note 如果使用了 launchView 则该属性无效。
@property(nonatomic, strong) UIColor *dimmingColor;

/// 控制以无动画的形式进入/退出搜索状态
@property(nonatomic, assign, getter=isActive) BOOL active;

/**
 *  控制进入/退出搜索状态
 *  @param active YES 表示进入搜索状态，NO 表示退出搜索状态
 *  @param animated 是否要以动画的形式展示状态切换
 */
- (void)setActive:(BOOL)active animated:(BOOL)animated;

/// 进入搜索状态时是否要把原界面的 navigationBar 推走，默认为 YES
@property(nonatomic, assign) BOOL hidesNavigationBarDuringPresentation;
@end



@interface QMUICommonTableViewController (Search) <QMUISearchControllerDelegate>

/**
 *  控制列表里是否需要搜索框，如果为 YES，则会在 viewDidLoad 之后创建一个 searchBar 作为 tableHeaderView；如果为 NO，则会移除已有的 searchBar 和 searchController。
 *  默认为 NO。
 *  @note 若在 viewDidLoad 之前设置为 YES，也会等到 viewDidLoad 时才去创建搜索框。
 */
@property(nonatomic, assign) BOOL shouldShowSearchBar;

/**
 *  获取当前的 searchController，注意只有当 `shouldShowSearchBar` 为 `YES` 时才有用
 *
 *  默认为 `nil`
 *
 *  @see QMUITableViewDelegate
 */
@property(nonatomic, strong, readonly) QMUISearchController *searchController;

/**
 *  获取当前的 searchBar，注意只有当 `shouldShowSearchBar` 为 `YES` 时才有用
 *
 *  默认为 `nil`
 *
 *  @see QMUITableViewDelegate
 */
@property(nonatomic, strong, readonly) UISearchBar *searchBar;

/**
 *  是否应该在显示空界面时自动隐藏搜索框
 *
 *  默认为 `NO`
 */
- (BOOL)shouldHideSearchBarWhenEmptyViewShowing;

/**
 *  初始化searchController和searchBar，在initSubViews的时候被自动调用。
 *
 *  会询问 `self.shouldShowSearchBar`，若返回 `YES`，则创建 searchBar 并将其以 `tableHeaderView` 的形式呈现在界面里；若返回 `NO`，则将 `tableHeaderView` 置为nil。
 *
 *  @warning `self.shouldShowSearchBar` 默认为 NO，需要 searchBar 的界面必须手动将其置为 `YES`。
 */
- (void)initSearchController;

@end
