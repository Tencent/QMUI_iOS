//
//  UITableView+QMUI.m
//  qmui
//
//  Created by ZhoonChen on 15/7/20.
//  Copyright (c) 2015年 QMUI Team. All rights reserved.
//

#import "UITableView+QMUI.h"
#import "QMUICore.h"
#import "UIScrollView+QMUI.h"

@implementation UITableView (QMUI)

- (void)qmui_styledAsQMUITableView {
    UIColor *backgroundColor = nil;
    if (self.style == UITableViewStylePlain) {
        backgroundColor = TableViewBackgroundColor;
        self.tableFooterView = [[UIView alloc] init]; // 去掉空白的cell
    } else {
        backgroundColor = TableViewGroupedBackgroundColor;
    }
    if (backgroundColor) {
        self.backgroundColor = backgroundColor;
    }
    self.separatorColor = TableViewSeparatorColor;
    self.backgroundView = [[UIView alloc] init]; // 设置一个空的 backgroundView，去掉系统的，以使 backgroundColor 生效
    
    self.sectionIndexColor = TableSectionIndexColor;
    self.sectionIndexTrackingBackgroundColor = TableSectionIndexTrackingBackgroundColor;
    self.sectionIndexBackgroundColor = TableSectionIndexBackgroundColor;
}

- (NSIndexPath *)qmui_indexPathForRowAtView:(UIView *)view {
    if (!view || !view.superview) {
        return nil;
    }
    
    if ([view isKindOfClass:[UITableViewCell class]] && ([NSStringFromClass(view.superview.class) isEqualToString:@"UITableViewWrapperView"] ? view.superview.superview : view.superview) == self) {
        // iOS 11 下，cell.superview 是 UITableView，iOS 11 以前，cell.superview 是 UITableViewWrapperView
        return [self indexPathForCell:(UITableViewCell *)view];
    }
    
    return [self qmui_indexPathForRowAtView:view.superview];
}

- (NSInteger)qmui_indexForSectionHeaderAtView:(UIView *)view {
    if (!view || ![view isKindOfClass:[UIView class]]) {
        return -1;
    }
    
    CGPoint origin = [self convertPoint:view.frame.origin fromView:view.superview];
    origin = CGPointToFixed(origin, 4);
    
    NSUInteger numberOfSection = [self numberOfSections];
    for (NSInteger i = numberOfSection - 1; i >= 0; i--) {
        CGRect rectForHeader = [self rectForHeaderInSection:i];// 这个接口获取到的 rect 是在 contentSize 里的 rect，而不是实际看到的 rect，所以要自行区分 headerView 是否被停靠在顶部
        BOOL isHeaderViewPinToTop = self.style == UITableViewStylePlain && (CGRectGetMinY(rectForHeader) - self.contentOffset.y < self.contentInset.top);
        if (isHeaderViewPinToTop) {
            rectForHeader = CGRectSetY(rectForHeader, CGRectGetMinY(rectForHeader) + (self.contentInset.top - CGRectGetMinY(rectForHeader) + self.contentOffset.y));
        }
        
        rectForHeader = CGRectToFixed(rectForHeader, 4);
        if (CGRectContainsPoint(rectForHeader, origin)) {
            return i;
        }
    }
    return -1;
}

- (QMUITableViewCellPosition)qmui_positionForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSInteger numberOfRowsInSection = [self.dataSource tableView:self numberOfRowsInSection:indexPath.section];
    if (numberOfRowsInSection == 1) {
        return QMUITableViewCellPositionSingleInSection;
    }
    if (indexPath.row == 0) {
        return QMUITableViewCellPositionFirstInSection;
    }
    if (indexPath.row == numberOfRowsInSection - 1) {
        return QMUITableViewCellPositionLastInSection;
    }
    return QMUITableViewCellPositionMiddleInSection;
}

- (BOOL)qmui_cellVisibleAtIndexPath:(NSIndexPath *)indexPath {
    NSArray *visibleCellIndexPaths = self.indexPathsForVisibleRows;
    for (NSIndexPath *visibleIndexPath in visibleCellIndexPaths) {
        if ([indexPath isEqual:visibleIndexPath]) {
            return YES;
        }
    }
    return NO;
}

- (void)qmui_clearsSelection {
    NSArray *selectedIndexPaths = [self indexPathsForSelectedRows];
    for (NSIndexPath *indexPath in selectedIndexPaths) {
        [self deselectRowAtIndexPath:indexPath animated:YES];
    }
}

- (void)qmui_scrollToRowFittingOffsetY:(CGFloat)offsetY atIndexPath:(NSIndexPath *)indexPath animated:(BOOL)animated {
    if (![self qmui_canScroll]) {
        return;
    }
    
    CGRect rectForRow = [self rectForRowAtIndexPath:indexPath];
    
    // 如果要滚到的row在列表尾部，则这个row是不可能滚到顶部的（因为列表尾部已经不够空间了），所以要判断一下
    BOOL canScrollRowToTop = CGRectGetMaxY(rectForRow) + CGRectGetHeight(self.frame) - (offsetY + CGRectGetHeight(rectForRow)) <= self.contentSize.height;
    if (canScrollRowToTop) {
        [self setContentOffset:CGPointMake(self.contentOffset.x, CGRectGetMinY(rectForRow) - offsetY) animated:animated];
    } else {
        [self qmui_scrollToBottomAnimated:animated];
    }
}

- (CGSize)qmui_realContentSize {
    if (!self.dataSource || !self.delegate) {
        return CGSizeZero;
    }
    
    CGSize contentSize = self.contentSize;
    CGFloat footerViewMaxY = CGRectGetMaxY(self.tableFooterView.frame);
    CGSize realContentSize = CGSizeMake(contentSize.width, footerViewMaxY);
    
    NSInteger lastSection = [self numberOfSections] - 1;
    if (lastSection < 0) {
        // 说明numberOfSetions为0，tableView没有cell，则直接取footerView的底边缘
        return realContentSize;
    }
    
    CGRect lastSectionRect = [self rectForSection:lastSection];
    realContentSize.height = fmax(realContentSize.height, CGRectGetMaxY(lastSectionRect));
    return realContentSize;
}

- (BOOL)qmui_canScroll {
    // 没有高度就不用算了，肯定不可滚动，这里只是做个保护
    if (CGRectGetHeight(self.bounds) <= 0) {
        return NO;
    }
    
    if ([self.tableHeaderView isKindOfClass:[UISearchBar class]]) {
        BOOL canScroll = self.qmui_realContentSize.height + UIEdgeInsetsGetVerticalValue(self.contentInset) > CGRectGetHeight(self.bounds);
        return canScroll;
    } else {
        return [super qmui_canScroll];
    }
}

@end
