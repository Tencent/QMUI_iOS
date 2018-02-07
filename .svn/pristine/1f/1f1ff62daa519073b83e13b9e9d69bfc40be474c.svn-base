//
//  QMUICommonTableViewController.m
//  qmui
//
//  Created by QQMail on 14-6-24.
//  Copyright (c) 2014年 QMUI Team. All rights reserved.
//

#import "QMUICommonTableViewController.h"
#import "QMUICommonDefines.h"
#import "QMUIConfiguration.h"
#import "QMUITableView.h"
#import "QMUIEmptyView.h"
#import "QMUILabel.h"
#import "UIScrollView+QMUI.h"
#import "UITableView+QMUI.h"
#import "UICollectionView+QMUI.h"

const UIEdgeInsets QMUICommonTableViewControllerInitialContentInsetNotSet = {-1, -1, -1, -1};
const NSInteger kSectionHeaderFooterLabelTag = 1024;

@interface QMUICommonTableViewController () {
    BOOL                    _shouldShowSearchBar;
    QMUISearchController    *_searchController;
    UISearchBar             *_searchBar;
}

@property(nonatomic,strong,readwrite) QMUITableView *tableView;
@property(nonatomic,assign) BOOL hasSetInitialContentInset;
@property(nonatomic,assign) BOOL hasHideTableHeaderViewInitial;

@end


@implementation QMUICommonTableViewController

- (instancetype)initWithStyle:(UITableViewStyle)style {
    if (self = [super initWithNibName:nil bundle:nil]) {
        [self didInitializedWithStyle:style];
    }
    return self;
}

- (instancetype)init {
    return [self initWithStyle:UITableViewStylePlain];
}

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    return [self init];
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
        [self didInitializedWithStyle:UITableViewStylePlain];
    }
    return self;
}

- (void)didInitializedWithStyle:(UITableViewStyle)style {
    _style = style;
    self.hasHideTableHeaderViewInitial = NO;
    self.tableViewInitialContentInset = QMUICommonTableViewControllerInitialContentInsetNotSet;
    self.tableViewInitialScrollIndicatorInsets = QMUICommonTableViewControllerInitialContentInsetNotSet;
}

- (void)dealloc {
    // 用下划线而不是self.xxx来访问tableView，避免dealloc时self.view尚未被加载，此时调用self.tableView反而会触发loadView
    _tableView.delegate = nil;
    _tableView.dataSource = nil;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    UIColor *backgroundColor = nil;
    if (self.style == UITableViewStylePlain) {
        backgroundColor = TableViewBackgroundColor;
    } else {
        backgroundColor = TableViewGroupedBackgroundColor;
    }
    if (backgroundColor) {
        self.view.backgroundColor = backgroundColor;
    }
}

- (void)initSubviews {
    [super initSubviews];
    [self initTableView];
    [self initSearchController];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.tableView qmui_clearsSelection];
    [self.searchController.tableView qmui_clearsSelection];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    BOOL shouldChangeTableViewFrame = !CGRectEqualToRect(self.view.bounds, self.tableView.frame);
    if (shouldChangeTableViewFrame) {
        self.tableView.frame = self.view.bounds;
    }
    
    if ([self shouldAdjustTableViewContentInsetsInitially] && !self.hasSetInitialContentInset) {
        self.tableView.contentInset = self.tableViewInitialContentInset;
        if ([self shouldAdjustTableViewScrollIndicatorInsetsInitially]) {
            self.tableView.scrollIndicatorInsets = self.tableViewInitialScrollIndicatorInsets;
        } else {
            // 默认和tableView.contentInset一致
            self.tableView.scrollIndicatorInsets = self.tableView.contentInset;
        }
        [self.tableView qmui_scrollToTop];
        self.hasSetInitialContentInset = YES;
    }
    
    [self hideTableHeaderViewInitialIfCanWithAnimated:NO];
    
    [self layoutEmptyView];
}


#pragma mark - 工具方法

- (QMUITableView *)tableView {
    if (!_tableView) {
        [self loadViewIfNeeded];
    }
    return _tableView;
}

- (void)hideTableHeaderViewInitialIfCanWithAnimated:(BOOL)animated {
    if (self.tableView.tableHeaderView && [self shouldHideTableHeaderViewInitial] && !self.hasHideTableHeaderViewInitial) {
        CGPoint contentOffset = CGPointMake(self.tableView.contentOffset.x, self.tableView.contentOffset.y + CGRectGetHeight(self.tableView.tableHeaderView.frame));
        [self.tableView setContentOffset:contentOffset animated:animated];
        self.hasHideTableHeaderViewInitial = YES;
    }
}

- (void)contentSizeCategoryDidChanged:(NSNotification *)notification {
    [super contentSizeCategoryDidChanged:notification];
    [self.tableView reloadData];
}

- (void)setTableViewInitialContentInset:(UIEdgeInsets)tableViewInitialContentInset {
    _tableViewInitialContentInset = tableViewInitialContentInset;
    if (UIEdgeInsetsEqualToEdgeInsets(tableViewInitialContentInset, QMUICommonTableViewControllerInitialContentInsetNotSet)) {
        self.automaticallyAdjustsScrollViewInsets = YES;
    } else {
        self.automaticallyAdjustsScrollViewInsets = NO;
    }
}

- (BOOL)shouldAdjustTableViewContentInsetsInitially {
    BOOL shouldAdjust = !UIEdgeInsetsEqualToEdgeInsets(self.tableViewInitialContentInset, QMUICommonTableViewControllerInitialContentInsetNotSet);
    return shouldAdjust;
}

- (BOOL)shouldAdjustTableViewScrollIndicatorInsetsInitially {
    BOOL shouldAdjust = !UIEdgeInsetsEqualToEdgeInsets(self.tableViewInitialScrollIndicatorInsets, QMUICommonTableViewControllerInitialContentInsetNotSet);
    return shouldAdjust;
}

#pragma mark - 空列表视图 QMUIEmptyView

- (void)showEmptyView {
    if (!self.emptyView) {
        self.emptyView = [[QMUIEmptyView alloc] init];
    }
    [self.tableView addSubview:self.emptyView];
    [self layoutEmptyView];
    if ([self shouldHideSearchBarWhenEmptyViewShowing] && self.tableView.tableHeaderView == self.searchBar) {
        self.tableView.tableHeaderView = nil;
    }
}

- (void)hideEmptyView {
    [self.emptyView removeFromSuperview];
BeginIgnoreDeprecatedWarning
    if ((self.shouldShowSearchBar || [self shouldShowSearchBarInTableView:self.tableView]) && [self shouldHideSearchBarWhenEmptyViewShowing] && self.tableView.tableHeaderView == nil) {
EndIgnoreDeprecatedWarning
        [self initSearchController];
        self.tableView.tableHeaderView = self.searchBar;
        [self hideTableHeaderViewInitialIfCanWithAnimated:NO];
    }
}

- (BOOL)layoutEmptyView {
    if (!self.emptyView || !self.emptyView.superview) {
        return NO;
    }
    // 当存在 tableHeaderView 时，emptyView 的高度为 tableView 的高度减去 headerView 的高度
    if (self.tableView.tableHeaderView) {
        self.emptyView.frame = CGRectMake(0, CGRectGetMaxY(self.tableView.tableHeaderView.frame), CGRectGetWidth(self.tableView.bounds) - UIEdgeInsetsGetHorizontalValue(self.tableView.contentInset), CGRectGetHeight(self.tableView.bounds) - UIEdgeInsetsGetVerticalValue(self.tableView.contentInset) - CGRectGetMaxY(self.tableView.tableHeaderView.frame));
    } else {
        self.emptyView.frame = CGRectMake(0, 0, CGRectGetWidth(self.tableView.bounds) - UIEdgeInsetsGetHorizontalValue(self.tableView.contentInset), CGRectGetHeight(self.tableView.bounds) - UIEdgeInsetsGetVerticalValue(self.tableView.contentInset));
    }
    return YES;
}

#pragma mark - <QMUITableViewDelegate, QMUITableViewDataSource>

- (BOOL)shouldShowSearchBarInTableView:(QMUITableView *)tableView {
    return NO;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 0;
}

// 默认拿title来构建一个view然后添加到viewForHeaderInSection里面，如果业务重写了viewForHeaderInSection，则titleForHeaderInSection被覆盖
// viewForFooterInSection同上
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    NSString *title = [self tableView:tableView realTitleForHeaderInSection:section];
    if (title) {
        UITableViewHeaderFooterView *headerFooterView = [self tableHeaderFooterLabelInTableView:tableView identifier:@"headerTitle"];
        QMUILabel *label = (QMUILabel *)[headerFooterView.contentView viewWithTag:kSectionHeaderFooterLabelTag];
        label.text = title;
        label.contentEdgeInsets = tableView.style == UITableViewStylePlain ? TableViewSectionHeaderContentInset : TableViewGroupedSectionHeaderContentInset;
        label.font = tableView.style == UITableViewStylePlain ? TableViewSectionHeaderFont : TableViewGroupedSectionHeaderFont;
        label.textColor = tableView.style == UITableViewStylePlain ? TableViewSectionHeaderTextColor : TableViewGroupedSectionHeaderTextColor;
        label.backgroundColor = tableView.style == UITableViewStylePlain ? TableViewSectionHeaderBackgroundColor : UIColorClear;
        CGFloat labelLimitWidth = CGRectGetWidth(tableView.bounds) - UIEdgeInsetsGetHorizontalValue(tableView.contentInset);
        CGSize labelSize = [label sizeThatFits:CGSizeMake(labelLimitWidth, CGFLOAT_MAX)];
        label.frame = CGRectMake(0, 0, labelLimitWidth, labelSize.height);
        return label;
    }
    return nil;
}

// 同viewForHeaderInSection
- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    NSString *title = [self tableView:tableView realTitleForFooterInSection:section];
    if (title) {
        UITableViewHeaderFooterView *headerFooterView = [self tableHeaderFooterLabelInTableView:tableView identifier:@"footerTitle"];
        QMUILabel *label = (QMUILabel *)[headerFooterView.contentView viewWithTag:kSectionHeaderFooterLabelTag];
        label.text = title;
        label.contentEdgeInsets = tableView.style == UITableViewStylePlain ? TableViewSectionFooterContentInset : TableViewGroupedSectionFooterContentInset;
        label.font = tableView.style == UITableViewStylePlain ? TableViewSectionFooterFont : TableViewGroupedSectionFooterFont;
        label.textColor = tableView.style == UITableViewStylePlain ? TableViewSectionFooterTextColor : TableViewGroupedSectionFooterTextColor;
        label.backgroundColor = tableView.style == UITableViewStylePlain ? TableViewSectionFooterBackgroundColor : UIColorClear;
        CGFloat labelLimitWidth = CGRectGetWidth(tableView.bounds) - UIEdgeInsetsGetHorizontalValue(tableView.contentInset);
        CGSize labelSize = [label sizeThatFits:CGSizeMake(labelLimitWidth, CGFLOAT_MAX)];
        label.frame = CGRectMake(0, 0, labelLimitWidth, labelSize.height);
        return label;
    }
    return nil;
}

- (UITableViewHeaderFooterView *)tableHeaderFooterLabelInTableView:(UITableView *)tableView identifier:(NSString *)identifier {
    UITableViewHeaderFooterView *headerFooterView = [tableView dequeueReusableHeaderFooterViewWithIdentifier:identifier];
    if (!headerFooterView) {
        QMUILabel *label = [[QMUILabel alloc] init];
        label.tag = kSectionHeaderFooterLabelTag;
        label.numberOfLines = 0;
        headerFooterView = [[UITableViewHeaderFooterView alloc] initWithReuseIdentifier:identifier];
        [headerFooterView.contentView addSubview:label];
    }
    return headerFooterView;
}

/**
 * iOS5之前的版本，如果viewForHeaderInSection返回的是nil，那么heightForHeaderInSection会自动计算数值为0，iOS5以及之后的版本，则不会自动计算，需要手动来计算heightForHeaderInSection。
 *
 * Apple Document: Prior to iOS 5.0, table views would automatically resize the heights of headers to 0 for sections where tableView:viewForHeaderInSection: returned a nil view. In iOS 5.0 and later, you must return the actual height for each section header in this method.
 * @see https://developer.apple.com/library/ios/DOCUMENTATION/UIKit/Reference/UITableViewDelegate_Protocol/Reference/Reference.html#//apple_ref/occ/intfm/UITableViewDelegate/tableView%3aheightForHeaderInSection%3a
 */
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if ([tableView.delegate respondsToSelector:@selector(tableView:viewForHeaderInSection:)]) {
        UIView *view = [tableView.delegate tableView:tableView viewForHeaderInSection:section];
        if (view) {
            return MAX(CGRectGetHeight(view.bounds), tableView.style == UITableViewStylePlain ? TableViewSectionHeaderHeight : TableViewGroupedSectionHeaderHeight);
        }
    }
    // 默认 plain 类型直接设置为 0，TableViewSectionHeaderHeight 是在需要重写 headerHeight 的时候才用的
    return tableView.style == UITableViewStylePlain ? 0 : TableViewGroupedSectionHeaderHeight;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    if ([tableView.delegate respondsToSelector:@selector(tableView:viewForFooterInSection:)]) {
        UIView *view = [tableView.delegate tableView:tableView viewForFooterInSection:section];
        if (view) {
            return MAX(CGRectGetHeight(view.bounds), tableView.style == UITableViewStylePlain ? TableViewSectionFooterHeight : TableViewGroupedSectionFooterHeight);
        }
    }
    // 默认 plain 类型直接设置为 0，TableViewSectionFooterHeight 是在需要重写 footerHeight 的时候才用的
    return tableView.style == UITableViewStylePlain ? 0 : TableViewGroupedSectionFooterHeight;
}

// 是否有定义某个section的header title
- (NSString *)tableView:(UITableView *)tableView realTitleForHeaderInSection:(NSInteger)section {
    if ([tableView.dataSource respondsToSelector:@selector(tableView:titleForHeaderInSection:)]) {
        NSString *sectionTitle = [tableView.dataSource tableView:tableView titleForHeaderInSection:section];
        if (sectionTitle && sectionTitle.length > 0) {
            return sectionTitle;
        }
    }
    return nil;
}

// 是否有定义某个section的footer title
- (NSString *)tableView:(UITableView *)tableView realTitleForFooterInSection:(NSInteger)section {
    if ([tableView.dataSource respondsToSelector:@selector(tableView:titleForFooterInSection:)]) {
        NSString *sectionFooter = [tableView.dataSource tableView:tableView titleForFooterInSection:section];
        if (sectionFooter && sectionFooter.length > 0) {
            return sectionFooter;
        }
    }
    return nil;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return TableViewCellNormalHeight;
}

@end


@implementation QMUICommonTableViewController (QMUISubclassingHooks)

- (void)initTableView {
    _tableView = [[QMUITableView alloc] initWithFrame:self.view.bounds style:self.style];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self.view addSubview:self.tableView];
}

- (BOOL)shouldHideTableHeaderViewInitial {
    return NO;
}

@end


@implementation QMUICommonTableViewController (Search)

- (BOOL)shouldShowSearchBar {
    return _shouldShowSearchBar;
}

- (void)setShouldShowSearchBar:(BOOL)shouldShowSearchBar {
    BOOL isValueChanged = _shouldShowSearchBar != shouldShowSearchBar;
    if (!isValueChanged) {
        return;
    }
    
    _shouldShowSearchBar = shouldShowSearchBar;
    
    if (shouldShowSearchBar) {
        [self initSearchController];
    } else {
        if (self.searchBar) {
            if (self.tableView.tableHeaderView == self.searchBar) {
                self.tableView.tableHeaderView = nil;
            }
            [self.searchBar removeFromSuperview];
            _searchBar = nil;
        }
        if (self.searchController) {
            self.searchController.searchResultsDelegate = nil;
            _searchController = nil;
        }
    }
}

- (QMUISearchController *)searchController {
    return _searchController;
}

- (UISearchBar *)searchBar {
    return _searchBar;
}

- (void)initSearchController {
BeginIgnoreDeprecatedWarning
    if ([self isViewLoaded] && (self.shouldShowSearchBar || [self.tableView.delegate shouldShowSearchBarInTableView:self.tableView]) && !self.searchController) {
EndIgnoreDeprecatedWarning
        _searchController = [[QMUISearchController alloc] initWithContentsViewController:self];
        self.searchController.searchResultsDelegate = self;
        self.searchController.searchBar.placeholder = @"搜索";
        self.tableView.tableHeaderView = self.searchController.searchBar;
        _searchBar = self.searchController.searchBar;
    }
}

- (BOOL)shouldHideSearchBarWhenEmptyViewShowing {
    return NO;
}

#pragma mark - <QMUISearchControllerDelegate>

- (void)searchController:(QMUISearchController *)searchController updateResultsForSearchString:(NSString *)searchString {
    
}

@end
