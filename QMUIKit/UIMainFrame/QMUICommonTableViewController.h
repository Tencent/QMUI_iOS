//
//  QMUICommonTableViewController.h
//  qmui
//
//  Created by QQMail on 14-6-24.
//  Copyright (c) 2014年 QMUI Team. All rights reserved.
//

#import "QMUICommonViewController.h"
#import "QMUISearchController.h"
#import "QMUITableView.h"

/**
 *  配合属性 `tableViewInitialContentInset` 使用，标志 `tableViewInitialContentInset` 是否有被修改过
 *  @see tableViewInitialContentInset
 */
extern const UIEdgeInsets QMUICommonTableViewControllerInitialContentInsetNotSet;

/**
 *  可作为项目内所有 `UITableViewController` 的基类，注意是继承自 `QMUICommonViewController` 而不是 `UITableViewController`。
 *
 *  一般通过 `initWithStyle:` 方法初始化，对于要生成 `UITableViewStylePlain` 类型的列表，推荐使用 `init:` 方法。
 *
 *  提供的功能包括：
 *
 *  1. 集成 `QMUISearchController`，可通过在 `shouldShowSearchBarInTableView:` 里返回 `YES` 来快速为列表生成一个搜索框。
 *
 *  2. 通过属性 `tableViewInitialContentInset` 和 `tableViewInitialScrollIndicatorInsets` 来提供对界面初始状态下的列表 `contentInset`、`contentOffset` 的调整能力，一般在系统的 `automaticallyAdjustsScrollViewInsets` 属性无法满足需求时使用。
 *
 *  @warning 在 `QMUICommonTableViewController` 里的 emptyView 将会以 `tableFooterView` 的方式显示出来，所以如果你的界面拥有自己的 `tableFooterView`，则需要重写 `showEmptyView`、`hideEmptyView` 来处理你的 footerView 和 emptyView 的显隐冲突问题。
 *
 *  @see QMUISearchController
 */
@interface QMUICommonTableViewController : QMUICommonViewController<QMUITableViewDelegate, QMUITableViewDataSource>

- (instancetype)initWithStyle:(UITableViewStyle)style NS_DESIGNATED_INITIALIZER;
- (instancetype)initWithCoder:(NSCoder *)aDecoder NS_DESIGNATED_INITIALIZER;

/// 获取当前的 `UITableViewStyle`
@property(nonatomic, assign, readonly) UITableViewStyle style;

/// 获取当前的 tableView
@property(nonatomic, strong, readonly) QMUITableView *tableView;

/**
 *  列表使用自定义的contentInset，不使用系统默认计算的，默认为QMUICommonTableViewControllerInitialContentInsetNotSet。<br/>
 *  当更改了这个值后，会把self.automaticallyAdjustsScrollViewInsets = NO
 */
@property(nonatomic,assign) UIEdgeInsets tableViewInitialContentInset;

/**
 *  是否需要让scrollIndicatorInsets与tableView.contentInsets区分开来，如果不设置，则与tableView.contentInset保持一致。
 *
 *  只有当更改了tableViewInitialContentInset后，这个属性才会生效。
 */
@property(nonatomic,assign) UIEdgeInsets tableViewInitialScrollIndicatorInsets;

@end


@interface QMUICommonTableViewController (QMUISubclassingHooks)

/**
 *  初始化tableView，在initSubViews的时候被自动调用。
 *
 *  一般情况下，有关tableView的设置属性的代码都应该写在这里。
 */
- (void)initTableView;

/**
 *  是否需要在第一次进入界面时将tableHeaderView隐藏（通过调整self.tableView.contentOffset实现）
 *
 *  默认为NO
 *
 *  @see QMUITableViewDelegate
 */
- (BOOL)shouldHideTableHeaderViewInitial;

@end


@interface QMUICommonTableViewController (Search) <QMUISearchControllerDelegate>

/**
 *  获取当前的searchController，注意只有当 `shouldShowSearchBarInTableView:` 返回 `YES` 时才有用
 *
 *  默认为 `nil`
 *
 *  @see QMUITableViewDelegate
 */
@property(nonatomic, strong, readonly) QMUISearchController *searchController;

/**
 *  获取当前的searchBar，注意只有当 `shouldShowSearchBarInTableView:` 返回 `YES` 时才有用
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
 *  会询问 `[self.tableView.delegate shouldShowSearchBarInTableView:]`，若返回 `YES`，则创建 searchBar 并将其以 `tableHeaderView` 的形式呈现在界面里；若返回 `NO`，则将 `tableHeaderView` 置为nil。
 *
 *  @warning `shouldShowSearchBarInTableView:` 默认返回 NO，需要 searchBar 的界面必须重写该方法并返回 `YES`
 */
- (void)initSearchController;

@end
