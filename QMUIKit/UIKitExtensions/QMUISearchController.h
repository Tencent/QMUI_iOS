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
 * 配合QMUISearchController使用的protocol，主要负责两件事情：
 *
 * <ol>
 * <li>响应用户的输入，在搜索框内的文字发生变化后被调用，可在<i>searchController:updateResultsForSearchString:</i>方法内更新搜索结果的数据集，在里面请自行调用<i>[searchController.tableView reloadData]</i></li>
 * <li>渲染最终用于显示搜索结果的UITableView的数据，该tableView的delegate、dataSource均在这里实现</li>
 * </ol>
 */
@protocol QMUISearchControllerDelegate <UITableViewDataSource,UITableViewDelegate>

@required
/**
 * 搜索框文字发生变化时的回调，请自行调用 `[tableView reloadData]` 来更新界面。
 * @warning 搜索框文字为空（例如第一次点击搜索框进入搜索状态时，或者文字全被删掉了，或者点击搜索框的×）也会走进来，此时参数searchString为@""，这是为了和系统的UISearchController保持一致
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
 * 兼容iOS7及以后的版本的searchController，在iOS7下会使用UISearchDisplayController实现，在iOS8及以后会使用UISearchController实现。<br/>
 * 使用方法：
 * <ol>
 * <li>使用<i>initWithContentsViewController:</i>初始化</li>
 * <li>指定<i>searchResultsDelegate</i>属性并在其中实现<i>searchController:updateResultsForSearchString:</i>方法以更新搜索结果数据集</li>
 * <li>通过<i>searchBar</i>属性得到搜索框的引用并直接使用，例如 @code tableHeaderView = searchController.searchBar @endcode</li>
 * </ol>
 */
@interface QMUISearchController : QMUICommonViewController

/**
 * 在某个指定的UIViewController上创建一个与其绑定的searchController
 * @param viewController 要在哪个viewController上添加搜索功能
 */
- (instancetype)initWithContentsViewController:(UIViewController *)viewController;

@property(nonatomic,weak) id<QMUISearchControllerDelegate> searchResultsDelegate;

@property(nonatomic,strong,readonly) UISearchBar *searchBar;
@property(nonatomic,strong,readonly) UITableView *tableView;
@property(nonatomic,assign,readonly) BOOL active;
@end
