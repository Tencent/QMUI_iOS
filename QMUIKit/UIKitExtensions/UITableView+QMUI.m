//
//  UITableView+QMUI.m
//  qmui
//
//  Created by ZhoonChen on 15/7/20.
//  Copyright (c) 2015年 QMUI Team. All rights reserved.
//

#import "UITableView+QMUI.h"
#import "QMUICommonDefines.h"
#import "QMUIConfiguration.h"
#import "UIScrollView+QMUI.h"

@implementation UITableView (QMUI)

- (void)styledAsQMUITableView {
    self.backgroundColor = self.style == UITableViewStylePlain ? TableViewBackgroundColor : TableViewGroupedBackgroundColor;
    self.separatorColor = TableViewSeparatorColor;
    self.tableFooterView = [[UIView alloc] init];// 去掉尾部空cell
    self.backgroundView = [[UIView alloc] init];// 设置一个空的backgroundView，去掉系统的，以使backgroundColor生效
    
    self.sectionIndexColor = TableSectionIndexColor;
    self.sectionIndexTrackingBackgroundColor = TableSectionIndexTrackingBackgroundColor;
    self.sectionIndexBackgroundColor = TableSectionIndexBackgroundColor;
}

- (NSIndexPath *)indexPathForRowAtView:(UIView *)view {
    if (view && [view isKindOfClass:[UIView class]]) {
        CGPoint origin = [self convertPoint:view.frame.origin fromView:view.superview];
        return [self indexPathForRowAtPoint:origin];
    }
    return nil;
}

- (NSInteger)indexForSectionHeaderAtView:(UIView *)view {
    if (!view || ![view isKindOfClass:[UIView class]]) {
        return -1;
    }
    
    CGPoint origin = [self convertPoint:view.frame.origin fromView:view.superview];
    
    NSUInteger numberOfSection = [self numberOfSections];
    for (NSInteger i = numberOfSection - 1; i >= 0; i--) {
        CGRect rectForHeader = [self rectForHeaderInSection:i];// 这个接口获取到的 rect 是在 contentSize 里的 rect，而不是实际看到的 rect，所以要自行区分 headerView 是否被停靠在顶部
        BOOL isHeaderViewPinToTop = self.style == UITableViewStylePlain && (CGRectGetMinY(rectForHeader) - self.contentOffset.y < self.contentInset.top);
        if (isHeaderViewPinToTop) {
            rectForHeader = CGRectSetY(rectForHeader, CGRectGetMinY(rectForHeader) + (self.contentInset.top - CGRectGetMinY(rectForHeader) + self.contentOffset.y));
        }
        if (CGRectContainsPoint(rectForHeader, origin)) {
            return i;
        }
    }
    return -1;
}

- (QMUITableViewCellPosition)positionForRowAtIndexPath:(NSIndexPath *)indexPath {
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

- (BOOL)cellVisibleAtIndexPath:(NSIndexPath *)indexPath {
    NSArray *visibleCellIndexPaths = self.indexPathsForVisibleRows;
    for (NSIndexPath *visibleIndexPath in visibleCellIndexPaths) {
        if ([indexPath isEqual:visibleIndexPath]) {
            return YES;
        }
    }
    return NO;
}

- (void)clearsSelection {
    NSArray *selectedIndexPaths = [self indexPathsForSelectedRows];
    for (NSIndexPath *indexPath in selectedIndexPaths) {
        [self deselectRowAtIndexPath:indexPath animated:YES];
    }
}

- (void)scrollToRowFittingOffsetY:(CGFloat)offsetY atIndexPath:(NSIndexPath *)indexPath animated:(BOOL)animated {
    if (![self canScroll]) {
        return;
    }
    
    CGRect rectForRow = [self rectForRowAtIndexPath:indexPath];
    
    // 如果要滚到的row在列表尾部，则这个row是不可能滚到顶部的（因为列表尾部已经不够空间了），所以要判断一下
    BOOL canScrollRowToTop = CGRectGetMaxY(rectForRow) + CGRectGetHeight(self.frame) - (offsetY + CGRectGetHeight(rectForRow)) <= self.contentSize.height;
    if (canScrollRowToTop) {
        [self setContentOffset:CGPointMake(self.contentOffset.x, CGRectGetMinY(rectForRow) - offsetY) animated:animated];
    } else {
        [self scrollToBottomAnimated:animated];
    }
}

- (CGSize)realContentSize {
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
    realContentSize.height = fmaxf(realContentSize.height, CGRectGetMaxY(lastSectionRect));
    return realContentSize;
}

- (BOOL)canScroll {
    // 没有高度就不用算了，肯定不可滚动，这里只是做个保护
    if (CGRectGetHeight(self.bounds) <= 0) {
        return NO;
    }
    
    if ([self.tableHeaderView isKindOfClass:[UISearchBar class]]) {
        BOOL canScroll = self.realContentSize.height + UIEdgeInsetsGetVerticalValue(self.contentInset) > CGRectGetHeight(self.bounds);
        return canScroll;
    } else {
        return [super canScroll];
    }
}

@end


/// ====================== 计算动态cell高度相关 =======================

@implementation UITableView (QMUIKeyedHeightCache)

- (QMUICellHeightKeyCache *)keyedHeightCache {
    QMUICellHeightKeyCache *cache = objc_getAssociatedObject(self, _cmd);
    if (!cache) {
        cache = [[QMUICellHeightKeyCache alloc] init];
        objc_setAssociatedObject(self, _cmd, cache, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    return cache;
}

@end

@implementation UITableView (QMUICellHeightIndexPathCache)

- (QMUICellHeightIndexPathCache *)indexPathHeightCache {
    QMUICellHeightIndexPathCache *cache = objc_getAssociatedObject(self, _cmd);
    if (!cache) {
        cache = [[QMUICellHeightIndexPathCache alloc] init];
        objc_setAssociatedObject(self, _cmd, cache, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    return cache;
}

@end

@implementation UITableView (QMUIIndexPathHeightCacheInvalidation)

- (void)reloadDataWithoutInvalidateIndexPathHeightCache {
    [self qmui_reloadData];
}

+ (void)load {
    SEL selectors[] = {
        @selector(reloadData),
        @selector(insertSections:withRowAnimation:),
        @selector(deleteSections:withRowAnimation:),
        @selector(reloadSections:withRowAnimation:),
        @selector(moveSection:toSection:),
        @selector(insertRowsAtIndexPaths:withRowAnimation:),
        @selector(deleteRowsAtIndexPaths:withRowAnimation:),
        @selector(reloadRowsAtIndexPaths:withRowAnimation:),
        @selector(moveRowAtIndexPath:toIndexPath:)
    };
    for (NSUInteger index = 0; index < sizeof(selectors) / sizeof(SEL); ++index) {
        SEL originalSelector = selectors[index];
        SEL swizzledSelector = NSSelectorFromString([@"qmui_" stringByAppendingString:NSStringFromSelector(originalSelector)]);
        Method originalMethod = class_getInstanceMethod(self, originalSelector);
        Method swizzledMethod = class_getInstanceMethod(self, swizzledSelector);
        method_exchangeImplementations(originalMethod, swizzledMethod);
    }
}

- (void)qmui_reloadData {
    if (self.indexPathHeightCache.automaticallyInvalidateEnabled) {
        [self.indexPathHeightCache enumerateAllOrientationsUsingBlock:^(NSMutableArray *heightsBySection) {
            [heightsBySection removeAllObjects];
        }];
    }
    [self qmui_reloadData];
}

- (void)qmui_insertSections:(NSIndexSet *)sections withRowAnimation:(UITableViewRowAnimation)animation {
    if (self.indexPathHeightCache.automaticallyInvalidateEnabled) {
        [sections enumerateIndexesUsingBlock:^(NSUInteger section, BOOL *stop) {
            [self.indexPathHeightCache buildSectionsIfNeeded:section];
            [self.indexPathHeightCache enumerateAllOrientationsUsingBlock:^(NSMutableArray *heightsBySection) {
                [heightsBySection insertObject:[NSMutableArray array] atIndex:section];
            }];
        }];
    }
    [self qmui_insertSections:sections withRowAnimation:animation];
}

- (void)qmui_deleteSections:(NSIndexSet *)sections withRowAnimation:(UITableViewRowAnimation)animation {
    if (self.indexPathHeightCache.automaticallyInvalidateEnabled) {
        [sections enumerateIndexesUsingBlock:^(NSUInteger section, BOOL *stop) {
            [self.indexPathHeightCache buildSectionsIfNeeded:section];
            [self.indexPathHeightCache enumerateAllOrientationsUsingBlock:^(NSMutableArray *heightsBySection) {
                [heightsBySection removeObjectAtIndex:section];
            }];
        }];
    }
    [self qmui_deleteSections:sections withRowAnimation:animation];
}

- (void)qmui_reloadSections:(NSIndexSet *)sections withRowAnimation:(UITableViewRowAnimation)animation {
    if (self.indexPathHeightCache.automaticallyInvalidateEnabled) {
        [sections enumerateIndexesUsingBlock: ^(NSUInteger section, BOOL *stop) {
            [self.indexPathHeightCache buildSectionsIfNeeded:section];
            [self.indexPathHeightCache enumerateAllOrientationsUsingBlock:^(NSMutableArray *heightsBySection) {
                [heightsBySection[section] removeAllObjects];
            }];
        }];
    }
    [self qmui_reloadSections:sections withRowAnimation:animation];
}

- (void)qmui_moveSection:(NSInteger)section toSection:(NSInteger)newSection {
    if (self.indexPathHeightCache.automaticallyInvalidateEnabled) {
        [self.indexPathHeightCache buildSectionsIfNeeded:section];
        [self.indexPathHeightCache buildSectionsIfNeeded:newSection];
        [self.indexPathHeightCache enumerateAllOrientationsUsingBlock:^(NSMutableArray *heightsBySection) {
            [heightsBySection exchangeObjectAtIndex:section withObjectAtIndex:newSection];
        }];
    }
    [self qmui_moveSection:section toSection:newSection];
}

- (void)qmui_insertRowsAtIndexPaths:(NSArray *)indexPaths withRowAnimation:(UITableViewRowAnimation)animation {
    if (self.indexPathHeightCache.automaticallyInvalidateEnabled) {
        [self.indexPathHeightCache buildCachesAtIndexPathsIfNeeded:indexPaths];
        [indexPaths enumerateObjectsUsingBlock:^(NSIndexPath *indexPath, NSUInteger idx, BOOL *stop) {
            [self.indexPathHeightCache enumerateAllOrientationsUsingBlock:^(NSMutableArray *heightsBySection) {
                NSMutableArray *rows = heightsBySection[indexPath.section];
                [rows insertObject:@-1 atIndex:indexPath.row];
            }];
        }];
    }
    [self qmui_insertRowsAtIndexPaths:indexPaths withRowAnimation:animation];
}

- (void)qmui_deleteRowsAtIndexPaths:(NSArray *)indexPaths withRowAnimation:(UITableViewRowAnimation)animation {
    if (self.indexPathHeightCache.automaticallyInvalidateEnabled) {
        [self.indexPathHeightCache buildCachesAtIndexPathsIfNeeded:indexPaths];
        NSMutableDictionary *mutableIndexSetsToRemove = [NSMutableDictionary dictionary];
        [indexPaths enumerateObjectsUsingBlock:^(NSIndexPath *indexPath, NSUInteger idx, BOOL *stop) {
            NSMutableIndexSet *mutableIndexSet = mutableIndexSetsToRemove[@(indexPath.section)];
            if (!mutableIndexSet) {
                mutableIndexSet = [NSMutableIndexSet indexSet];
                mutableIndexSetsToRemove[@(indexPath.section)] = mutableIndexSet;
            }
            [mutableIndexSet addIndex:indexPath.row];
        }];
        [mutableIndexSetsToRemove enumerateKeysAndObjectsUsingBlock:^(NSNumber *key, NSIndexSet *indexSet, BOOL *stop) {
            [self.indexPathHeightCache enumerateAllOrientationsUsingBlock:^(NSMutableArray *heightsBySection) {
                NSMutableArray *rows = heightsBySection[key.integerValue];
                [rows removeObjectsAtIndexes:indexSet];
            }];
        }];
    }
    [self qmui_deleteRowsAtIndexPaths:indexPaths withRowAnimation:animation];
}

- (void)qmui_reloadRowsAtIndexPaths:(NSArray *)indexPaths withRowAnimation:(UITableViewRowAnimation)animation {
    if (self.indexPathHeightCache.automaticallyInvalidateEnabled) {
        [self.indexPathHeightCache buildCachesAtIndexPathsIfNeeded:indexPaths];
        [indexPaths enumerateObjectsUsingBlock:^(NSIndexPath *indexPath, NSUInteger idx, BOOL *stop) {
            [self.indexPathHeightCache enumerateAllOrientationsUsingBlock:^(NSMutableArray *heightsBySection) {
                NSMutableArray *rows = heightsBySection[indexPath.section];
                rows[indexPath.row] = @-1;
            }];
        }];
    }
    [self qmui_reloadRowsAtIndexPaths:indexPaths withRowAnimation:animation];
}

- (void)qmui_moveRowAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath *)destinationIndexPath {
    if (self.indexPathHeightCache.automaticallyInvalidateEnabled) {
        [self.indexPathHeightCache buildCachesAtIndexPathsIfNeeded:@[sourceIndexPath, destinationIndexPath]];
        [self.indexPathHeightCache enumerateAllOrientationsUsingBlock:^(NSMutableArray *heightsBySection) {
            if (heightsBySection.count > 0 && heightsBySection.count > sourceIndexPath.section && heightsBySection.count > destinationIndexPath.section) {
                NSMutableArray *sourceRows = heightsBySection[sourceIndexPath.section];
                NSMutableArray *destinationRows = heightsBySection[destinationIndexPath.section];
                NSNumber *sourceValue = sourceRows[sourceIndexPath.row];
                NSNumber *destinationValue = destinationRows[destinationIndexPath.row];
                sourceRows[sourceIndexPath.row] = destinationValue;
                destinationRows[destinationIndexPath.row] = sourceValue;
            }
        }];
    }
    [self qmui_moveRowAtIndexPath:sourceIndexPath toIndexPath:destinationIndexPath];
}

@end

@implementation UITableView (QMUILayoutCell)

- (UITableViewCell *)templateCellForReuseIdentifier:(NSString *)identifier {
    NSAssert(identifier.length > 0, @"Expect a valid identifier - %@", identifier);
    NSMutableDictionary *templateCellsByIdentifiers = objc_getAssociatedObject(self, _cmd);
    if (!templateCellsByIdentifiers) {
        templateCellsByIdentifiers = @{}.mutableCopy;
        objc_setAssociatedObject(self, _cmd, templateCellsByIdentifiers, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    UITableViewCell *templateCell = templateCellsByIdentifiers[identifier];
    if (!templateCell) {
        // 是否有通过dataSource返回的cell
        if ([self.dataSource respondsToSelector:@selector(qmui_tableView:cellWithIdentifier:)] ) {
            id <qmui_UITableViewDataSource>dataSource = (id<qmui_UITableViewDataSource>)self.dataSource;
            templateCell = [dataSource qmui_tableView:self cellWithIdentifier:identifier];
        }
        // 没有的话，则需要通过register来注册一个cell，否则会crash
        if (!templateCell) {
            templateCell = [self dequeueReusableCellWithIdentifier:identifier];
            NSAssert(templateCell != nil, @"Cell must be registered to table view for identifier - %@", identifier);
        }
        templateCell.contentView.translatesAutoresizingMaskIntoConstraints = NO;
        templateCellsByIdentifiers[identifier] = templateCell;
        NSLog(@"layout cell created - %@", identifier);
    }
    return templateCell;
}

- (CGFloat)heightForCellWithIdentifier:(NSString *)identifier configuration:(void (^)(id cell))configuration {
    if (!identifier || CGRectIsEmpty(self.bounds)) {
        return 0;
    }
    UITableViewCell *cell = [self templateCellForReuseIdentifier:identifier];
    [cell prepareForReuse];
    if (configuration) { configuration(cell); }
    CGFloat contentWidth = CGRectGetWidth(self.bounds) - UIEdgeInsetsGetHorizontalValue(self.contentInset);
    CGSize fitSize = CGSizeZero;
    if (cell && contentWidth > 0) {
        SEL selector = @selector(sizeThatFits:);
        BOOL inherited = ![cell isMemberOfClass:[UITableViewCell class]]; // 是否UITableViewCell
        BOOL overrided = [cell.class instanceMethodForSelector:selector] != [UITableViewCell instanceMethodForSelector:selector]; // 是否重写了sizeThatFit:
        if (inherited && !overrided) {
            NSAssert(NO, @"Customized cell must override '-sizeThatFits:' method if not using auto layout.");
        }
        fitSize = [cell sizeThatFits:CGSizeMake(contentWidth, CGFLOAT_MAX)];
    }
    return ceilf(fitSize.height);
}

// 通过indexPath缓存高度
- (CGFloat)heightForCellWithIdentifier:(NSString *)identifier cacheByIndexPath:(NSIndexPath *)indexPath configuration:(void (^)(id cell))configuration {
    if (!identifier || !indexPath || CGRectIsEmpty(self.bounds)) {
        return 0;
    }
    if ([self.indexPathHeightCache existsHeightAtIndexPath:indexPath]) {
        return [self.indexPathHeightCache heightForIndexPath:indexPath];
    }
    CGFloat height = [self heightForCellWithIdentifier:identifier configuration:configuration];
    [self.indexPathHeightCache cacheHeight:height byIndexPath:indexPath];
    return height;
}

// 通过key缓存高度
- (CGFloat)heightForCellWithIdentifier:(NSString *)identifier cacheByKey:(id<NSCopying>)key configuration:(void (^)(id cell))configuration {
    if (!identifier || !key || CGRectIsEmpty(self.bounds)) {
        return 0;
    }
    if ([self.keyedHeightCache existsHeightForKey:key]) {
        return [self.keyedHeightCache heightForKey:key];
    }
    CGFloat height = [self heightForCellWithIdentifier:identifier configuration:configuration];
    [self.keyedHeightCache cacheHeight:height byKey:key];
    return height;
}

@end

