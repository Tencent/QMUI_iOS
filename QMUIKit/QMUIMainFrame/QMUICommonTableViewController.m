//
//  QMUICommonTableViewController.m
//  qmui
//
//  Created by QMUI Team on 14-6-24.
//  Copyright (c) 2014年 QMUI Team. All rights reserved.
//

#import "QMUICommonTableViewController.h"
#import "QMUICore.h"
#import "QMUITableView.h"
#import "QMUIEmptyView.h"
#import "QMUILabel.h"
#import "UIScrollView+QMUI.h"
#import "UITableView+QMUI.h"
#import "UICollectionView+QMUI.h"

const UIEdgeInsets QMUICommonTableViewControllerInitialContentInsetNotSet = {-1, -1, -1, -1};
const NSInteger kSectionHeaderFooterLabelTag = 1024;

@interface QMUICommonTableViewController ()

@property(nonatomic, strong, readwrite) QMUITableView *tableView;
@property(nonatomic, assign) BOOL hasSetInitialContentInset;
@property(nonatomic, assign) BOOL hasHideTableHeaderViewInitial;

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

- (NSString *)description {
    if (![self isViewLoaded]) {
        return [super description];
    }
    
    NSString *result = [NSString stringWithFormat:@"%@\ntableView:\t\t\t\t%@", [super description], self.tableView];
    NSInteger sections = [self.tableView.dataSource numberOfSectionsInTableView:self.tableView];
    if (sections > 0) {
        NSMutableString *sectionCountString = [[NSMutableString alloc] init];
        [sectionCountString appendFormat:@"\ndataCount(%@):\t\t\t\t(\n", @(sections)];
        NSInteger sections = [self.tableView.dataSource numberOfSectionsInTableView:self.tableView];
        for (NSInteger i = 0; i < sections; i++) {
            NSInteger rows = [self.tableView.dataSource tableView:self.tableView numberOfRowsInSection:i];
            [sectionCountString appendFormat:@"\t\t\t\t\t\t\tsection%@ - rows%@%@\n", @(i), @(rows), i < sections - 1 ? @"," : @""];
        }
        [sectionCountString appendString:@"\t\t\t\t\t\t)"];
        result = [result stringByAppendingString:sectionCountString];
    }
    return result;
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
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.tableView qmui_clearsSelection];
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
    
    [self hideTableHeaderViewInitialIfCanWithAnimated:NO force:NO];
    
    [self layoutEmptyView];
}


#pragma mark - 工具方法

- (QMUITableView *)tableView {
    if (!_tableView) {
        [self loadViewIfNeeded];
    }
    return _tableView;
}

- (void)hideTableHeaderViewInitialIfCanWithAnimated:(BOOL)animated force:(BOOL)force {
    if (self.tableView.tableHeaderView && [self shouldHideTableHeaderViewInitial] && (force || !self.hasHideTableHeaderViewInitial)) {
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
        if (@available(iOS 11, *)) {
            if (self.isViewLoaded) {
                self.tableView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentAutomatic;
            }
        } else {
            self.automaticallyAdjustsScrollViewInsets = YES;
        }
    } else {
        if (@available(iOS 11, *)) {
            if (self.isViewLoaded) {
                self.tableView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
            }
        } else {
            self.automaticallyAdjustsScrollViewInsets = NO;
        }
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
}

- (void)hideEmptyView {
    [self.emptyView removeFromSuperview];
}

- (BOOL)layoutEmptyView {
    if (!self.emptyView || !self.emptyView.superview) {
        return NO;
    }
    
    UIEdgeInsets insets = self.tableView.contentInset;
    if (@available(iOS 11, *)) {
        if (self.tableView.contentInsetAdjustmentBehavior != UIScrollViewContentInsetAdjustmentNever) {
            insets = self.tableView.adjustedContentInset;
        }
    }
    
    // 当存在 tableHeaderView 时，emptyView 的高度为 tableView 的高度减去 headerView 的高度
    if (self.tableView.tableHeaderView) {
        self.emptyView.frame = CGRectMake(0, CGRectGetMaxY(self.tableView.tableHeaderView.frame), CGRectGetWidth(self.tableView.bounds) - UIEdgeInsetsGetHorizontalValue(insets), CGRectGetHeight(self.tableView.bounds) - UIEdgeInsetsGetVerticalValue(insets) - CGRectGetMaxY(self.tableView.tableHeaderView.frame));
    } else {
        self.emptyView.frame = CGRectMake(0, 0, CGRectGetWidth(self.tableView.bounds) - UIEdgeInsetsGetHorizontalValue(insets), CGRectGetHeight(self.tableView.bounds) - UIEdgeInsetsGetVerticalValue(insets));
    }
    return YES;
}

#pragma mark - <QMUITableViewDelegate, QMUITableViewDataSource>

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
        // 针对 iPhone X 机型，应该在用户定义的 Insets 基础上增加 iPhone X 的安全 insets
        label.contentEdgeInsets = UIEdgeInsetsSetLeft(label.contentEdgeInsets, label.contentEdgeInsets.left + IPhoneXSafeAreaInsets.left);
        label.contentEdgeInsets = UIEdgeInsetsSetRight(label.contentEdgeInsets, label.contentEdgeInsets.right + IPhoneXSafeAreaInsets.right);
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
        // 针对 iPhone X 机型，应该在用户定义的 Insets 基础上增加 iPhone X 的安全 insets
        label.contentEdgeInsets = UIEdgeInsetsSetLeft(label.contentEdgeInsets, label.contentEdgeInsets.left + IPhoneXSafeAreaInsets.left);
        label.contentEdgeInsets = UIEdgeInsetsSetRight(label.contentEdgeInsets, label.contentEdgeInsets.right + IPhoneXSafeAreaInsets.right);
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

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if ([tableView.delegate respondsToSelector:@selector(tableView:viewForHeaderInSection:)]) {
        UIView *view = [tableView.delegate tableView:tableView viewForHeaderInSection:section];
        if (view) {
            CGFloat height = [view sizeThatFits:CGSizeMake(CGRectGetWidth(tableView.bounds), CGFLOAT_MAX)].height;
            return height;
        }
    }
    // 分别测试过 iOS 11 前后的系统版本，最终总结，对于 Plain 类型的 tableView 而言，要去掉 header / footer 请使用 0，对于 Grouped 类型的 tableView 而言，要去掉 header / footer 请使用 CGFLOAT_MIN
    return tableView.style == UITableViewStylePlain ? 0 : TableViewGroupedSectionHeaderDefaultHeight;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    if ([tableView.delegate respondsToSelector:@selector(tableView:viewForFooterInSection:)]) {
        UIView *view = [tableView.delegate tableView:tableView viewForFooterInSection:section];
        if (view) {
            CGFloat height = [view sizeThatFits:CGSizeMake(CGRectGetWidth(tableView.bounds), CGFLOAT_MAX)].height;
            return height;
        }
    }
    // 分别测试过 iOS 11 前后的系统版本，最终总结，对于 Plain 类型的 tableView 而言，要去掉 header / footer 请使用 0，对于 Grouped 类型的 tableView 而言，要去掉 header / footer 请使用 CGFLOAT_MIN
    return tableView.style == UITableViewStylePlain ? 0 : TableViewGroupedSectionFooterDefaultHeight;
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
    return [[UITableViewCell alloc] init];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return TableViewCellNormalHeight;
}

@end


@implementation QMUICommonTableViewController (QMUISubclassingHooks)

- (void)initTableView {
    if (!_tableView) {
        _tableView = [[QMUITableView alloc] initWithFrame:self.view.bounds style:self.style];
        self.tableView.delegate = self;
        self.tableView.dataSource = self;
        [self.view addSubview:self.tableView];
        
        if (@available(iOS 11, *)) {
            if ([self shouldAdjustTableViewContentInsetsInitially]) {
                self.tableView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
            }
        }
    }
}

- (BOOL)shouldHideTableHeaderViewInitial {
    return NO;
}

@end
