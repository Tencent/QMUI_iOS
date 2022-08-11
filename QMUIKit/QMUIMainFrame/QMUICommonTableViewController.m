/**
 * Tencent is pleased to support the open source community by making QMUI_iOS available.
 * Copyright (C) 2016-2021 THL A29 Limited, a Tencent company. All rights reserved.
 * Licensed under the MIT License (the "License"); you may not use this file except in compliance with the License. You may obtain a copy of the License at
 * http://opensource.org/licenses/MIT
 * Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.
 */

//
//  QMUICommonTableViewController.m
//  qmui
//
//  Created by QMUI Team on 14-6-24.
//

#import "QMUICommonTableViewController.h"
#import "QMUICore.h"
#import "QMUITableView.h"
#import "QMUIEmptyView.h"
#import "QMUITableViewHeaderFooterView.h"
#import "UIScrollView+QMUI.h"
#import "UITableView+QMUI.h"
#import "UICollectionView+QMUI.h"
#import "UIView+QMUI.h"
#import "UIViewController+QMUI.h"

NSString *const QMUICommonTableViewControllerSectionHeaderIdentifier = @"QMUISectionHeaderView";
NSString *const QMUICommonTableViewControllerSectionFooterIdentifier = @"QMUISectionFooterView";

@interface QMUICommonTableViewController ()

@property(nonatomic, assign) BOOL hasHideTableHeaderViewInitial;
@end


@implementation QMUICommonTableViewController

- (instancetype)initWithStyle:(UITableViewStyle)style {
    if (self = [super initWithNibName:nil bundle:nil]) {
        [self didInitializeWithStyle:style];
    }
    return self;
}

- (instancetype)init {
    return [self initWithStyle:UITableViewStylePlain];
}

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    return [self init];
}

- (nullable instancetype)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
        [self didInitializeWithStyle:UITableViewStylePlain];
    }
    return self;
}

- (void)didInitializeWithStyle:(UITableViewStyle)style {
    _style = style;
    self.hasHideTableHeaderViewInitial = NO;
}

- (void)dealloc {
    // 用下划线而不是self.xxx来访问tableView，避免dealloc时self.view尚未被加载，此时调用self.tableView反而会触发loadView
    _tableView.dataSource = nil;
    _tableView.delegate = nil;
}

- (NSString *)description {
#ifdef DEBUG
    if (![self isViewLoaded]) {
        return [super description];
    }
    
    NSString *tableView = [NSString stringWithFormat:@"<%@: %p>", NSStringFromClass(self.tableView.class), self.tableView];
    NSString *result = [NSString stringWithFormat:@"%@\ntableView:\t\t\t\t%@", [super description], tableView];
    NSInteger sections = [self.tableView.dataSource respondsToSelector:@selector(numberOfSectionsInTableView:)] ? [self.tableView.dataSource numberOfSectionsInTableView:self.tableView] : 1;
    if (sections > 0) {
        NSMutableString *sectionCountString = [[NSMutableString alloc] init];
        [sectionCountString appendFormat:@"\ndataCount(%@):\t\t\t(\n", @(sections)];
        for (NSInteger i = 0; i < sections; i++) {
            NSInteger rows = [self.tableView.dataSource tableView:self.tableView numberOfRowsInSection:i];
            [sectionCountString appendFormat:@"\t\t\t\t\t\t\tsection%@ - rows%@%@\n", @(i), @(rows), i < sections - 1 ? @"," : @""];
        }
        [sectionCountString appendString:@"\t\t\t\t\t\t)"];
        result = [result stringByAppendingString:sectionCountString];
    }
    return result;
#else
    return [super description];
#endif
}

- (void)viewDidLoad {
    [super viewDidLoad];
    if (self.tableView.backgroundColor) {
        self.view.backgroundColor = self.tableView.backgroundColor;// 让 self.view 背景色跟随不同的 UITableViewStyle 走
    }
}

- (void)initSubviews {
    [super initSubviews];
    [self initTableView];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if (!self.tableView.allowsMultipleSelection) {
        [self qmui_animateAlongsideTransition:^(id<UIViewControllerTransitionCoordinatorContext>  _Nonnull context) {
            [self.tableView qmui_clearsSelection];
        } completion:nil];
    }
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    
    [self layoutTableView];
    
    [self hideTableHeaderViewInitialIfCanWithAnimated:NO force:NO];
    
    [self layoutEmptyView];
}

#pragma mark - 工具方法

@synthesize tableView = _tableView;
- (__kindof QMUITableView *)tableView {
    if (!_tableView) {
        [self loadViewIfNeeded];
    }
    return _tableView;
}

- (void)setTableView:(__kindof QMUITableView *)tableView {
    if (_tableView != tableView) {
        if (_tableView) {
            // 这里不用移除 delegate、dataSource，因为原本的值也不一定是指向 self，而且可能是个 QMUIMultipleDelegate，反正这两个属性都是 weak 的
            if (self.isViewLoaded && _tableView.superview == self.view) {
                [_tableView removeFromSuperview];
            }
        }
        
        _tableView = tableView;
        [_tableView registerClass:[QMUITableViewHeaderFooterView class] forHeaderFooterViewReuseIdentifier:QMUICommonTableViewControllerSectionHeaderIdentifier];
        [_tableView registerClass:[QMUITableViewHeaderFooterView class] forHeaderFooterViewReuseIdentifier:QMUICommonTableViewControllerSectionFooterIdentifier];
        
        // 从 nib 初始化的界面，loadView 里 tableView 已经被加到 self.view 上了，但此时 loadView 尚未结束，所以 isViewLoaded 为 NO。这种场景不需要自己 addSubview，也不应该去调用 self.view 触发 loadView
        // https://github.com/Tencent/QMUI_iOS/issues/1156
        if (tableView.superview && self.nibName && !self.isViewLoaded) {
        } else {
            // 触发 loadView
            [self.view addSubview:_tableView];
        }
    }
}

- (void)hideTableHeaderViewInitialIfCanWithAnimated:(BOOL)animated force:(BOOL)force {
    if (self.tableView.tableHeaderView && [self shouldHideTableHeaderViewInitial] && (force || !self.hasHideTableHeaderViewInitial)) {
        CGPoint contentOffset = CGPointMake(self.tableView.contentOffset.x, -self.tableView.adjustedContentInset.top + CGRectGetHeight(self.tableView.tableHeaderView.frame));
        [self.tableView setContentOffset:contentOffset animated:animated];
        self.hasHideTableHeaderViewInitial = YES;
    }
}

- (void)contentSizeCategoryDidChanged:(NSNotification *)notification {
    [super contentSizeCategoryDidChanged:notification];
    if (self.viewLoaded) {
        [self.tableView reloadData];
    }
}

#pragma mark - 空列表视图 QMUIEmptyView

- (void)handleTableViewContentInsetChangeEvent {
    if (self.isEmptyViewShowing) {
        [self layoutEmptyView];
    }
}

- (void)showEmptyView {
    [self.tableView addSubview:self.emptyView];
    [self layoutEmptyView];
}

// 注意，emptyView 的布局依赖于 tableView.contentInset，因此我们必须监听 tableView.contentInset 的变化以及时更新 emptyView 的布局
- (BOOL)layoutEmptyView {
    if (!_emptyView || !_emptyView.superview) {
        return NO;
    }
    
    UIEdgeInsets insets = self.tableView.adjustedContentInset;
    
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

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    NSString *title = [self tableView:tableView realTitleForHeaderInSection:section];
    if (title) {
        QMUITableViewHeaderFooterView *headerView = [tableView dequeueReusableHeaderFooterViewWithIdentifier:QMUICommonTableViewControllerSectionHeaderIdentifier];
        headerView.parentTableView = tableView;
        headerView.type = QMUITableViewHeaderFooterViewTypeHeader;
        headerView.titleLabel.text = title;
        return headerView;
    }
    return nil;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    NSString *title = [self tableView:tableView realTitleForFooterInSection:section];
    if (title) {
        QMUITableViewHeaderFooterView *footerView = [tableView dequeueReusableHeaderFooterViewWithIdentifier:QMUICommonTableViewControllerSectionFooterIdentifier];
        footerView.parentTableView = tableView;
        footerView.type = QMUITableViewHeaderFooterViewTypeFooter;
        footerView.titleLabel.text = title;
        return footerView;
    }
    return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if ([tableView.delegate respondsToSelector:@selector(tableView:viewForHeaderInSection:)]) {
        // 系统的行为是当你实现了 tableView:viewForHeaderInSection: 后，无论你在其中是否 return nil，唯一隐藏 header 的方式就是在 tableView:heightForHeaderInSection: 里返回 0/CGFLOAT_MAX，所以这里需要判断返回值非空就用 self-sizing 自动计算，否则都视为不需要显示 header
        UIView *view = [tableView.delegate tableView:tableView viewForHeaderInSection:section];
        if (view) {
            return UITableViewAutomaticDimension;
        }
    }
    // 分别测试过 iOS 13 及以下的所有版本，最终总结，对于 Plain 类型的 tableView 而言，要去掉 header / footer 请使用 0，对于 Grouped 类型的 tableView 而言，要去掉 header / footer 请使用 CGFLOAT_MIN
    return PreferredValueForTableViewStyle(tableView.qmui_style, 0, TableViewGroupedSectionHeaderDefaultHeight, TableViewInsetGroupedSectionHeaderDefaultHeight);
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    if ([tableView.delegate respondsToSelector:@selector(tableView:viewForFooterInSection:)]) {
        // 系统的行为是当你实现了 tableView:viewForFooterInSection: 后，无论你在其中是否 return nil，唯一隐藏 footer 的方式就是在 tableView:heightForFooterInSection: 里返回 0/CGFLOAT_MAX，所以这里需要判断返回值非空就用 self-sizing 自动计算，否则都视为不需要显示 footer
        UIView *view = [tableView.delegate tableView:tableView viewForFooterInSection:section];
        if (view) {
            return UITableViewAutomaticDimension;
        }
    }
    // 分别测试过 iOS 13 及以下的所有版本，最终总结，对于 Plain 类型的 tableView 而言，要去掉 header / footer 请使用 0，对于 Grouped 类型的 tableView 而言，要去掉 header / footer 请使用 CGFLOAT_MIN
    return PreferredValueForTableViewStyle(tableView.qmui_style, 0, TableViewGroupedSectionFooterDefaultHeight, TableViewInsetGroupedSectionFooterDefaultHeight);
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

/**
 *  监听 contentInset 的变化以及时更新 emptyView 的布局，详见 layoutEmptyView 方法的注释
 */
- (void)scrollViewDidChangeAdjustedContentInset:(UIScrollView *)scrollView {
    if (_tableView != scrollView) return;
    [self handleTableViewContentInsetChangeEvent];
}

@end


@implementation QMUICommonTableViewController (QMUISubclassingHooks)

- (void)initTableView {
    if (!_tableView) {
        self.tableView = [[QMUITableView alloc] initWithFrame:self.isViewLoaded ? self.view.bounds : CGRectZero style:self.style];
        // setDataSource: 不会触发 tableView reload，而 setDelegate: 可以，所以把 setDelegate: 放在后面，保证 reload 时能访问到 dataSource 里的数据源。
        // 否则如果列表开启了 estimated，然后在 viewDidLoad 里设置 tableHeaderView，则 setTableHeaderView: 时由于 setDataSource: 后 tableView 其实没再刷新过，所以内部依然认为 numberOfSections 是默认的1，于是就会去调用 numberOfRows，如果此时 numberOfRows 里用 indexPath 作为下标去访问数据源就会产生越界（因为此时数据源可能还是空的）
        _tableView.dataSource = self;
        _tableView.delegate = self;
    }
}

- (void)layoutTableView {
    BOOL shouldChangeTableViewFrame = !CGRectEqualToRect(self.view.bounds, self.tableView.frame);
    if (shouldChangeTableViewFrame) {
        self.tableView.qmui_frameApplyTransform = self.view.bounds;
    }
}

- (BOOL)shouldHideTableHeaderViewInitial {
    return NO;
}

@end
