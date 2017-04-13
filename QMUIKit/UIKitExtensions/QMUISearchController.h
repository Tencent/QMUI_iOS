//
//  QMUISearchController.h
//  Test
//
//  Created by MoLice on 16/5/25.
//  Copyright © 2016年 MoLice. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "QMUICommonViewController.h"

@class QMUIEmptyView;
@class QMUISearchController;

/**
 *  配合 QMUISearchController 使用的 protocol，主要负责两件事情：
 *
 *  1. 响应用户的输入，在搜索框内的文字发生变化后被调用，可在 searchController:updateResultsForSearchString: 方法内更新搜索结果的数据集，在里面请自行调用 [searchController.tableView reloadData]
 *  2. 渲染最终用于显示搜索结果的 UITableView 的数据，该 tableView 的 delegate、dataSource 均包含在这个 protocol 里
 */
@protocol QMUISearchControllerDelegate <UITableViewDataSource, UITableViewDelegate>

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
 *  兼容 iOS 7 及以后的版本的 searchController，在 iOS7 下会使用 UISearchDisplayController 实现，在 iOS 8 及以后会使用 UISearchController 实现。
 *  支持在搜索文字为空时（注意并非“搜索结果为空”）显示一个界面，例如常见的“最近搜索”功能，具体请查看属性 launchView。
 *  使用方法：
 *  1. 使用 initWithContentsViewController: 初始化
 *  2. 通过 searchBar 属性得到搜索框的引用并直接使用，例如 `tableHeaderView = searchController.searchBar`
 *  3. 指定 searchResultsDelegate 属性并在其中实现 searchController:updateResultsForSearchString: 方法以更新搜索结果数据集
 *
 *  @note QMUICommonTableViewController 内部自带 QMUISearchController，只需将属性 shouldShowSearchBar 置为 YES 即可，无需自行初始化 QMUISearchController。
 */
@interface QMUISearchController : QMUICommonViewController

/**
 *  在某个指定的UIViewController上创建一个与其绑定的searchController
 *  @param viewController 要在哪个viewController上添加搜索功能
 */
- (instancetype)initWithContentsViewController:(UIViewController *)viewController;

@property(nonatomic, weak) id<QMUISearchControllerDelegate> searchResultsDelegate;

/// 搜索框，在 iOS 7 下是 QMUISearchBar，在 iOS 8 及以后是 UISearchBar
@property(nonatomic, strong, readonly) UISearchBar *searchBar;

/// 搜索结果列表，在 iOS 7 下是 UITableView，并且每次进行搜索时指针都会发生变化（系统如此），在 iOS 8 及以后是 QMUITableView
@property(nonatomic, strong, readonly) UITableView *tableView;

/// 在搜索文字为空时会展示的一个 view，通常用于实现“最近搜索”之类的功能。launchView 最终会被布局为撑满搜索框以下的所有空间。
@property(nonatomic, strong) UIView *launchView;

/// 控制以无动画的形式进入/退出搜索状态
@property(nonatomic, assign, getter=isActive) BOOL active;

/**
 *  控制进入/退出搜索状态
 *  @param active YES 表示进入搜索状态，NO 表示退出搜索状态
 *  @param animated 是否要以动画的形式展示状态切换
 */
- (void)setActive:(BOOL)active animated:(BOOL)animated;

/// 进入搜索状态时是否要把原界面的 navigationBar 推走，默认为 YES，仅在 iOS 8 及以后有效
@property(nonatomic, assign) BOOL hidesNavigationBarDuringPresentation;
@end
