//
//  QMUICellHeightCache.m
//  qmui
//
//  Created by zhoonchen on 15/12/23.
//  Copyright © 2015年 QMUI Team. All rights reserved.
//

#import "QMUICellHeightCache.h"
#import "QMUITableViewProtocols.h"
#import "QMUICore.h"
#import "UIScrollView+QMUI.h"
#import "UIView+QMUI.h"
#import "NSNumber+QMUI.h"

@implementation QMUICellHeightCache {
    NSMutableDictionary<id<NSCopying>, NSNumber *> *_mutableHeightsByKeyForPortrait;
    NSMutableDictionary<id<NSCopying>, NSNumber *> *_mutableHeightsByKeyForLandscape;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _mutableHeightsByKeyForPortrait = [NSMutableDictionary dictionary];
        _mutableHeightsByKeyForLandscape = [NSMutableDictionary dictionary];
    }
    return self;
}

- (NSMutableDictionary<id<NSCopying>, NSNumber *> *)mutableHeightsByKeyForCurrentOrientation {
    return UIDeviceOrientationIsPortrait([UIDevice currentDevice].orientation) ? _mutableHeightsByKeyForPortrait : _mutableHeightsByKeyForLandscape;
}

- (BOOL)existsHeightForKey:(id<NSCopying>)key {
    NSNumber *number = [self mutableHeightsByKeyForCurrentOrientation][key];
    return number && ![number isEqualToNumber:@-1];
}

- (void)cacheHeight:(CGFloat)height byKey:(id<NSCopying>)key {
    [self mutableHeightsByKeyForCurrentOrientation][key] = @(height);
}

- (CGFloat)heightForKey:(id<NSCopying>)key {
    return [self mutableHeightsByKeyForCurrentOrientation][key].qmui_CGFloatValue;
}

- (void)invalidateHeightForKey:(id<NSCopying>)key {
    [_mutableHeightsByKeyForPortrait removeObjectForKey:key];
    [_mutableHeightsByKeyForLandscape removeObjectForKey:key];
}

- (void)invalidateAllHeightCache {
    [_mutableHeightsByKeyForPortrait removeAllObjects];
    [_mutableHeightsByKeyForLandscape removeAllObjects];
}

- (NSString *)description {
    return [NSString stringWithFormat:@"%@, mutableHeightsByKeyForPortrait = %@, mutableHeightsByKeyForLandscape = %@", [super description], _mutableHeightsByKeyForPortrait, _mutableHeightsByKeyForLandscape];
}

@end

@implementation QMUICellHeightIndexPathCache {
    NSMutableArray<NSMutableArray<NSNumber *> *> *_heightsBySectionForPortrait;
    NSMutableArray<NSMutableArray<NSNumber *> *> *_heightsBySectionForLandscape;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _heightsBySectionForPortrait = [NSMutableArray array];
        _heightsBySectionForLandscape = [NSMutableArray array];
    }
    return self;
}

- (NSMutableArray<NSMutableArray<NSNumber *> *> *)heightsBySectionForCurrentOrientation {
    return UIDeviceOrientationIsPortrait([UIDevice currentDevice].orientation) ? _heightsBySectionForPortrait : _heightsBySectionForLandscape;
}

- (void)enumerateAllOrientationsUsingBlock:(void (^)(NSMutableArray<NSMutableArray<NSNumber *> *> *heightsBySection))block {
    if (block) {
        block(_heightsBySectionForPortrait);
        block(_heightsBySectionForLandscape);
    }
}

- (BOOL)existsHeightAtIndexPath:(NSIndexPath *)indexPath {
    [self buildCachesAtIndexPathsIfNeeded:@[indexPath]];
    NSNumber *number = self.heightsBySectionForCurrentOrientation[indexPath.section][indexPath.row];
    return ![number isEqualToNumber:@-1];
}

- (void)cacheHeight:(CGFloat)height byIndexPath:(NSIndexPath *)indexPath {
    self.automaticallyInvalidateEnabled = YES;
    [self buildCachesAtIndexPathsIfNeeded:@[indexPath]];
    self.heightsBySectionForCurrentOrientation[indexPath.section][indexPath.row] = @(height);
}

- (CGFloat)heightForIndexPath:(NSIndexPath *)indexPath {
    [self buildCachesAtIndexPathsIfNeeded:@[indexPath]];
    return self.heightsBySectionForCurrentOrientation[indexPath.section][indexPath.row].qmui_CGFloatValue;
}

- (void)invalidateHeightAtIndexPath:(NSIndexPath *)indexPath {
    [self buildCachesAtIndexPathsIfNeeded:@[indexPath]];
    [self enumerateAllOrientationsUsingBlock:^(NSMutableArray<NSMutableArray<NSNumber *> *> *heightsBySection) {
        heightsBySection[indexPath.section][indexPath.row] = @-1;
    }];
}

- (void)invalidateAllHeightCache {
    [self enumerateAllOrientationsUsingBlock:^(NSMutableArray<NSMutableArray<NSNumber *> *> *heightsBySection) {
        [heightsBySection removeAllObjects];
    }];
}

- (void)buildCachesAtIndexPathsIfNeeded:(NSArray<NSIndexPath *> *)indexPaths {
    [indexPaths enumerateObjectsUsingBlock:^(NSIndexPath *indexPath, NSUInteger idx, BOOL *stop) {
        [self buildSectionsIfNeeded:indexPath.section];
        [self buildRowsIfNeeded:indexPath.row inExistSection:indexPath.section];
    }];
}

- (void)buildSectionsIfNeeded:(NSInteger)targetSection {
    [self enumerateAllOrientationsUsingBlock:^(NSMutableArray<NSMutableArray<NSNumber *> *> *heightsBySection) {
        for (NSInteger section = 0; section <= targetSection; ++section) {
            if (section >= heightsBySection.count) {
                heightsBySection[section] = [NSMutableArray array];
            }
        }
    }];
}

- (void)buildRowsIfNeeded:(NSInteger)targetRow inExistSection:(NSInteger)section {
    [self enumerateAllOrientationsUsingBlock:^(NSMutableArray<NSMutableArray<NSNumber *> *> *heightsBySection) {
        NSMutableArray *heightsByRow = heightsBySection[section];
        for (NSInteger row = 0; row <= targetRow; ++row) {
            if (row >= heightsByRow.count) {
                heightsByRow[row] = @(-1);
            }
        }
    }];
}

- (NSString *)description {
    return [NSString stringWithFormat:@"%@, heightsBySectionForPortrait = %@, heightsBySectionForLandscape = %@", [super description], _heightsBySectionForPortrait, _heightsBySectionForLandscape];
}

@end

#pragma mark - UITableView Height Cache

/// ====================== 计算动态cell高度相关 =======================

@implementation UITableView (QMUIKeyedHeightCache)

- (QMUICellHeightCache *)qmui_keyedHeightCache {
    QMUICellHeightCache *cache = objc_getAssociatedObject(self, _cmd);
    if (!cache) {
        cache = [[QMUICellHeightCache alloc] init];
        objc_setAssociatedObject(self, _cmd, cache, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    return cache;
}

@end

@implementation UITableView (QMUICellHeightIndexPathCache)

- (QMUICellHeightIndexPathCache *)qmui_indexPathHeightCache {
    QMUICellHeightIndexPathCache *cache = objc_getAssociatedObject(self, _cmd);
    if (!cache) {
        cache = [[QMUICellHeightIndexPathCache alloc] init];
        objc_setAssociatedObject(self, _cmd, cache, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    return cache;
}

@end

@implementation UITableView (QMUIIndexPathHeightCacheInvalidation)

- (void)qmui_reloadDataWithoutInvalidateIndexPathHeightCache {
    [self qmui_reloadData];
}

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
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
            ExchangeImplementations([self class], originalSelector, swizzledSelector);
        }
    });
}

- (void)qmui_reloadData {
    if (self.qmui_indexPathHeightCache.automaticallyInvalidateEnabled) {
        [self.qmui_indexPathHeightCache invalidateAllHeightCache];
    }
    [self qmui_reloadData];
}

- (void)qmui_insertSections:(NSIndexSet *)sections withRowAnimation:(UITableViewRowAnimation)animation {
    if (self.qmui_indexPathHeightCache.automaticallyInvalidateEnabled) {
        [sections enumerateIndexesUsingBlock:^(NSUInteger section, BOOL *stop) {
            [self.qmui_indexPathHeightCache buildSectionsIfNeeded:section];
            [self.qmui_indexPathHeightCache enumerateAllOrientationsUsingBlock:^(NSMutableArray *heightsBySection) {
                [heightsBySection insertObject:[NSMutableArray array] atIndex:section];
            }];
        }];
    }
    [self qmui_insertSections:sections withRowAnimation:animation];
}

- (void)qmui_deleteSections:(NSIndexSet *)sections withRowAnimation:(UITableViewRowAnimation)animation {
    if (self.qmui_indexPathHeightCache.automaticallyInvalidateEnabled) {
        [sections enumerateIndexesUsingBlock:^(NSUInteger section, BOOL *stop) {
            [self.qmui_indexPathHeightCache buildSectionsIfNeeded:section];
            [self.qmui_indexPathHeightCache enumerateAllOrientationsUsingBlock:^(NSMutableArray *heightsBySection) {
                [heightsBySection removeObjectAtIndex:section];
            }];
        }];
    }
    [self qmui_deleteSections:sections withRowAnimation:animation];
}

- (void)qmui_reloadSections:(NSIndexSet *)sections withRowAnimation:(UITableViewRowAnimation)animation {
    if (self.qmui_indexPathHeightCache.automaticallyInvalidateEnabled) {
        [sections enumerateIndexesUsingBlock: ^(NSUInteger section, BOOL *stop) {
            [self.qmui_indexPathHeightCache buildSectionsIfNeeded:section];
            [self.qmui_indexPathHeightCache enumerateAllOrientationsUsingBlock:^(NSMutableArray *heightsBySection) {
                [heightsBySection[section] removeAllObjects];
            }];
        }];
    }
    [self qmui_reloadSections:sections withRowAnimation:animation];
}

- (void)qmui_moveSection:(NSInteger)section toSection:(NSInteger)newSection {
    if (self.qmui_indexPathHeightCache.automaticallyInvalidateEnabled) {
        [self.qmui_indexPathHeightCache buildSectionsIfNeeded:section];
        [self.qmui_indexPathHeightCache buildSectionsIfNeeded:newSection];
        [self.qmui_indexPathHeightCache enumerateAllOrientationsUsingBlock:^(NSMutableArray *heightsBySection) {
            [heightsBySection exchangeObjectAtIndex:section withObjectAtIndex:newSection];
        }];
    }
    [self qmui_moveSection:section toSection:newSection];
}

- (void)qmui_insertRowsAtIndexPaths:(NSArray *)indexPaths withRowAnimation:(UITableViewRowAnimation)animation {
    if (self.qmui_indexPathHeightCache.automaticallyInvalidateEnabled) {
        [self.qmui_indexPathHeightCache buildCachesAtIndexPathsIfNeeded:indexPaths];
        [indexPaths enumerateObjectsUsingBlock:^(NSIndexPath *indexPath, NSUInteger idx, BOOL *stop) {
            [self.qmui_indexPathHeightCache enumerateAllOrientationsUsingBlock:^(NSMutableArray *heightsBySection) {
                NSMutableArray *rows = heightsBySection[indexPath.section];
                [rows insertObject:@-1 atIndex:indexPath.row];
            }];
        }];
    }
    [self qmui_insertRowsAtIndexPaths:indexPaths withRowAnimation:animation];
}

- (void)qmui_deleteRowsAtIndexPaths:(NSArray *)indexPaths withRowAnimation:(UITableViewRowAnimation)animation {
    if (self.qmui_indexPathHeightCache.automaticallyInvalidateEnabled) {
        [self.qmui_indexPathHeightCache buildCachesAtIndexPathsIfNeeded:indexPaths];
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
            [self.qmui_indexPathHeightCache enumerateAllOrientationsUsingBlock:^(NSMutableArray *heightsBySection) {
                NSMutableArray *rows = heightsBySection[key.integerValue];
                [rows removeObjectsAtIndexes:indexSet];
            }];
        }];
    }
    [self qmui_deleteRowsAtIndexPaths:indexPaths withRowAnimation:animation];
}

- (void)qmui_reloadRowsAtIndexPaths:(NSArray *)indexPaths withRowAnimation:(UITableViewRowAnimation)animation {
    if (self.qmui_indexPathHeightCache.automaticallyInvalidateEnabled) {
        [self.qmui_indexPathHeightCache buildCachesAtIndexPathsIfNeeded:indexPaths];
        [indexPaths enumerateObjectsUsingBlock:^(NSIndexPath *indexPath, NSUInteger idx, BOOL *stop) {
            [self.qmui_indexPathHeightCache enumerateAllOrientationsUsingBlock:^(NSMutableArray *heightsBySection) {
                NSMutableArray *rows = heightsBySection[indexPath.section];
                rows[indexPath.row] = @-1;
            }];
        }];
    }
    [self qmui_reloadRowsAtIndexPaths:indexPaths withRowAnimation:animation];
}

- (void)qmui_moveRowAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath *)destinationIndexPath {
    if (self.qmui_indexPathHeightCache.automaticallyInvalidateEnabled) {
        [self.qmui_indexPathHeightCache buildCachesAtIndexPathsIfNeeded:@[sourceIndexPath, destinationIndexPath]];
        [self.qmui_indexPathHeightCache enumerateAllOrientationsUsingBlock:^(NSMutableArray *heightsBySection) {
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
            id <QMUICellHeightCache_UITableViewDataSource>dataSource = (id<QMUICellHeightCache_UITableViewDataSource>)self.dataSource;
            templateCell = [dataSource qmui_tableView:self cellWithIdentifier:identifier];
        }
        // 没有的话，则需要通过register来注册一个cell，否则会crash
        if (!templateCell) {
            templateCell = [self dequeueReusableCellWithIdentifier:identifier];
            NSAssert(templateCell != nil, @"Cell must be registered to table view for identifier - %@", identifier);
        }
        templateCell.contentView.translatesAutoresizingMaskIntoConstraints = NO;
        templateCellsByIdentifiers[identifier] = templateCell;
    }
    return templateCell;
}

- (CGFloat)qmui_heightForCellWithIdentifier:(NSString *)identifier configuration:(void (^)(__kindof UITableViewCell *))configuration {
    if (!identifier || CGRectIsEmpty(self.bounds)) {
        return 0;
    }
    UITableViewCell *cell = [self templateCellForReuseIdentifier:identifier];
    [cell prepareForReuse];
    if (configuration) { configuration(cell); }
    CGFloat contentWidth = CGRectGetWidth(self.bounds) - UIEdgeInsetsGetHorizontalValue(self.qmui_safeAreaInsets) - UIEdgeInsetsGetHorizontalValue(self.contentInset);
    CGSize fitSize = CGSizeZero;
    if (cell && contentWidth > 0) {
        fitSize = [cell sizeThatFits:CGSizeMake(contentWidth, CGFLOAT_MAX)];
    }
    return ceil(fitSize.height);
}

// 通过indexPath缓存高度
- (CGFloat)qmui_heightForCellWithIdentifier:(NSString *)identifier cacheByIndexPath:(NSIndexPath *)indexPath configuration:(void (^)(__kindof UITableViewCell *))configuration {
    if (!identifier || !indexPath || CGRectIsEmpty(self.bounds)) {
        return 0;
    }
    if ([self.qmui_indexPathHeightCache existsHeightAtIndexPath:indexPath]) {
        return [self.qmui_indexPathHeightCache heightForIndexPath:indexPath];
    }
    CGFloat height = [self qmui_heightForCellWithIdentifier:identifier configuration:configuration];
    [self.qmui_indexPathHeightCache cacheHeight:height byIndexPath:indexPath];
    return height;
}

// 通过key缓存高度
- (CGFloat)qmui_heightForCellWithIdentifier:(NSString *)identifier cacheByKey:(id<NSCopying>)key configuration:(void (^)(__kindof UITableViewCell *))configuration {
    if (!identifier || !key || CGRectIsEmpty(self.bounds)) {
        return 0;
    }
    if ([self.qmui_keyedHeightCache existsHeightForKey:key]) {
        return [self.qmui_keyedHeightCache heightForKey:key];
    }
    CGFloat height = [self qmui_heightForCellWithIdentifier:identifier configuration:configuration];
    [self.qmui_keyedHeightCache cacheHeight:height byKey:key];
    return height;
}

@end

#pragma mark - UICollectionView Height Cache

/// ====================== 计算动态cell高度相关 =======================

@implementation UICollectionView (QMUIKeyedHeightCache)

- (QMUICellHeightCache *)qmui_keyedHeightCache {
    QMUICellHeightCache *cache = objc_getAssociatedObject(self, _cmd);
    if (!cache) {
        cache = [[QMUICellHeightCache alloc] init];
        objc_setAssociatedObject(self, _cmd, cache, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    return cache;
}

@end

@implementation UICollectionView (QMUICellHeightIndexPathCache)

- (QMUICellHeightIndexPathCache *)qmui_indexPathHeightCache {
    QMUICellHeightIndexPathCache *cache = objc_getAssociatedObject(self, _cmd);
    if (!cache) {
        cache = [[QMUICellHeightIndexPathCache alloc] init];
        objc_setAssociatedObject(self, _cmd, cache, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    return cache;
}

@end

@implementation UICollectionView (QMUIIndexPathHeightCacheInvalidation)

- (void)qmui_reloadDataWithoutInvalidateIndexPathHeightCache {
    [self qmui_reloadData];
}

+ (void)load {
    SEL selectors[] = {
        @selector(reloadData),
        @selector(insertSections:),
        @selector(deleteSections:),
        @selector(reloadSections:),
        @selector(moveSection:toSection:),
        @selector(insertItemsAtIndexPaths:),
        @selector(deleteItemsAtIndexPaths:),
        @selector(reloadItemsAtIndexPaths:),
        @selector(moveItemAtIndexPath:toIndexPath:)
    };
    for (NSUInteger index = 0; index < sizeof(selectors) / sizeof(SEL); ++index) {
        SEL originalSelector = selectors[index];
        SEL swizzledSelector = NSSelectorFromString([@"qmui_" stringByAppendingString:NSStringFromSelector(originalSelector)]);
        ExchangeImplementations([self class], originalSelector, swizzledSelector);
    }
}

- (void)qmui_reloadData {
    if (self.qmui_indexPathHeightCache.automaticallyInvalidateEnabled) {
        [self.qmui_indexPathHeightCache invalidateAllHeightCache];
    }
    [self qmui_reloadData];
}

- (void)qmui_insertSections:(NSIndexSet *)sections {
    if (self.qmui_indexPathHeightCache.automaticallyInvalidateEnabled) {
        [sections enumerateIndexesUsingBlock:^(NSUInteger section, BOOL *stop) {
            [self.qmui_indexPathHeightCache buildSectionsIfNeeded:section];
            [self.qmui_indexPathHeightCache enumerateAllOrientationsUsingBlock:^(NSMutableArray *heightsBySection) {
                [heightsBySection insertObject:[NSMutableArray array] atIndex:section];
            }];
        }];
    }
    [self qmui_insertSections:sections];
}

- (void)qmui_deleteSections:(NSIndexSet *)sections {
    if (self.qmui_indexPathHeightCache.automaticallyInvalidateEnabled) {
        [sections enumerateIndexesUsingBlock:^(NSUInteger section, BOOL *stop) {
            [self.qmui_indexPathHeightCache buildSectionsIfNeeded:section];
            [self.qmui_indexPathHeightCache enumerateAllOrientationsUsingBlock:^(NSMutableArray *heightsBySection) {
                [heightsBySection removeObjectAtIndex:section];
            }];
        }];
    }
    [self qmui_deleteSections:sections];
}

- (void)qmui_reloadSections:(NSIndexSet *)sections {
    if (self.qmui_indexPathHeightCache.automaticallyInvalidateEnabled) {
        [sections enumerateIndexesUsingBlock: ^(NSUInteger section, BOOL *stop) {
            [self.qmui_indexPathHeightCache buildSectionsIfNeeded:section];
            [self.qmui_indexPathHeightCache enumerateAllOrientationsUsingBlock:^(NSMutableArray *heightsBySection) {
                [heightsBySection[section] removeAllObjects];
            }];
        }];
    }
    [self qmui_reloadSections:sections];
}

- (void)qmui_moveSection:(NSInteger)section toSection:(NSInteger)newSection {
    if (self.qmui_indexPathHeightCache.automaticallyInvalidateEnabled) {
        [self.qmui_indexPathHeightCache buildSectionsIfNeeded:section];
        [self.qmui_indexPathHeightCache buildSectionsIfNeeded:newSection];
        [self.qmui_indexPathHeightCache enumerateAllOrientationsUsingBlock:^(NSMutableArray *heightsBySection) {
            [heightsBySection exchangeObjectAtIndex:section withObjectAtIndex:newSection];
        }];
    }
    [self qmui_moveSection:section toSection:newSection];
}

- (void)qmui_insertItemsAtIndexPaths:(NSArray *)indexPaths {
    if (self.qmui_indexPathHeightCache.automaticallyInvalidateEnabled) {
        [self.qmui_indexPathHeightCache buildCachesAtIndexPathsIfNeeded:indexPaths];
        [indexPaths enumerateObjectsUsingBlock:^(NSIndexPath *indexPath, NSUInteger idx, BOOL *stop) {
            [self.qmui_indexPathHeightCache enumerateAllOrientationsUsingBlock:^(NSMutableArray *heightsBySection) {
                NSMutableArray *rows = heightsBySection[indexPath.section];
                [rows insertObject:@(-1) atIndex:indexPath.item];
            }];
        }];
    }
    [self qmui_insertItemsAtIndexPaths:indexPaths];
}

- (void)qmui_deleteItemsAtIndexPaths:(NSArray *)indexPaths {
    if (self.qmui_indexPathHeightCache.automaticallyInvalidateEnabled) {
        [self.qmui_indexPathHeightCache buildCachesAtIndexPathsIfNeeded:indexPaths];
        NSMutableDictionary *mutableIndexSetsToRemove = [NSMutableDictionary dictionary];
        [indexPaths enumerateObjectsUsingBlock:^(NSIndexPath *indexPath, NSUInteger idx, BOOL *stop) {
            NSMutableIndexSet *mutableIndexSet = mutableIndexSetsToRemove[@(indexPath.section)];
            if (!mutableIndexSet) {
                mutableIndexSet = [NSMutableIndexSet indexSet];
                mutableIndexSetsToRemove[@(indexPath.section)] = mutableIndexSet;
            }
            [mutableIndexSet addIndex:indexPath.item];
        }];
        [mutableIndexSetsToRemove enumerateKeysAndObjectsUsingBlock:^(NSNumber *key, NSIndexSet *indexSet, BOOL *stop) {
            [self.qmui_indexPathHeightCache enumerateAllOrientationsUsingBlock:^(NSMutableArray *heightsBySection) {
                NSMutableArray *rows = heightsBySection[key.integerValue];
                [rows removeObjectsAtIndexes:indexSet];
            }];
        }];
    }
    [self qmui_deleteItemsAtIndexPaths:indexPaths];
}

- (void)qmui_reloadItemsAtIndexPaths:(NSArray *)indexPaths {
    if (self.qmui_indexPathHeightCache.automaticallyInvalidateEnabled) {
        [self.qmui_indexPathHeightCache buildCachesAtIndexPathsIfNeeded:indexPaths];
        [indexPaths enumerateObjectsUsingBlock:^(NSIndexPath *indexPath, NSUInteger idx, BOOL *stop) {
            [self.qmui_indexPathHeightCache enumerateAllOrientationsUsingBlock:^(NSMutableArray *heightsBySection) {
                NSMutableArray *rows = heightsBySection[indexPath.section];
                rows[indexPath.item] = @(-1);
            }];
        }];
    }
    [self qmui_reloadItemsAtIndexPaths:indexPaths];
}

- (void)qmui_moveItemAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath *)destinationIndexPath {
    if (self.qmui_indexPathHeightCache.automaticallyInvalidateEnabled) {
        [self.qmui_indexPathHeightCache buildCachesAtIndexPathsIfNeeded:@[sourceIndexPath, destinationIndexPath]];
        [self.qmui_indexPathHeightCache enumerateAllOrientationsUsingBlock:^(NSMutableArray *heightsBySection) {
            if (heightsBySection.count > 0 && heightsBySection.count > sourceIndexPath.section && heightsBySection.count > destinationIndexPath.section) {
                NSMutableArray *sourceRows = heightsBySection[sourceIndexPath.section];
                NSMutableArray *destinationRows = heightsBySection[destinationIndexPath.section];
                NSNumber *sourceValue = sourceRows[sourceIndexPath.item];
                NSNumber *destinationValue = destinationRows[destinationIndexPath.item];
                sourceRows[sourceIndexPath.item] = destinationValue;
                destinationRows[destinationIndexPath.item] = sourceValue;
            }
        }];
    }
    [self qmui_moveItemAtIndexPath:sourceIndexPath toIndexPath:destinationIndexPath];
}

@end

@implementation UICollectionView (QMUILayoutCell)

- (UICollectionViewCell *)templateCellForReuseIdentifier:(NSString *)identifier cellClass:(Class)cellClass {
    NSAssert(identifier.length > 0, @"Expect a valid identifier - %@", identifier);
    NSAssert([self.collectionViewLayout isKindOfClass:[UICollectionViewFlowLayout class]], @"only flow layout accept");
    NSAssert([cellClass isSubclassOfClass:[UICollectionViewCell class]], @"must be uicollection view cell");
    NSMutableDictionary *templateCellsByIdentifiers = objc_getAssociatedObject(self, _cmd);
    if (!templateCellsByIdentifiers) {
        templateCellsByIdentifiers = @{}.mutableCopy;
        objc_setAssociatedObject(self, _cmd, templateCellsByIdentifiers, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    UICollectionViewCell *templateCell = templateCellsByIdentifiers[identifier];
    if (!templateCell) {
        // CollecionView 跟 TableView 不太一样，无法通过 dequeueReusableCellWithReuseIdentifier:forIndexPath: 来拿到cell（如果这样做，首先indexPath不知道传什么值，其次是这样做会已知crash，说数组越界），所以只能通过传一个class来通过init方法初始化一个cell，但是也有缓存来复用cell。
        // templateCell = [self dequeueReusableCellWithReuseIdentifier:identifier forIndexPath:[NSIndexPath indexPathForItem:0 inSection:0]];
        templateCell = [[cellClass alloc] initWithFrame:CGRectZero];
        NSAssert(templateCell != nil, @"Cell must be registered to collection view for identifier - %@", identifier);
    }
    templateCell.contentView.translatesAutoresizingMaskIntoConstraints = NO;
    templateCellsByIdentifiers[identifier] = templateCell;
    return templateCell;
}

- (CGFloat)qmui_heightForCellWithIdentifier:(NSString *)identifier cellClass:(Class)cellClass itemWidth:(CGFloat)itemWidth configuration:(void (^)(id cell))configuration {
    if (!identifier || CGRectIsEmpty(self.bounds)) {
        return 0;
    }
    UICollectionViewCell *cell = [self templateCellForReuseIdentifier:identifier cellClass:cellClass];
    [cell prepareForReuse];
    if (configuration) { configuration(cell); }
    CGSize fitSize = CGSizeZero;
    if (cell && itemWidth > 0) {
        fitSize = [cell sizeThatFits:CGSizeMake(itemWidth, CGFLOAT_MAX)];
    }
    return ceil(fitSize.height);
}

// 通过indexPath缓存高度
- (CGFloat)qmui_heightForCellWithIdentifier:(NSString *)identifier cellClass:(Class)cellClass itemWidth:(CGFloat)itemWidth cacheByIndexPath:(NSIndexPath *)indexPath configuration:(void (^)(id cell))configuration {
    if (!identifier || !indexPath || CGRectIsEmpty(self.bounds)) {
        return 0;
    }
    if ([self.qmui_indexPathHeightCache existsHeightAtIndexPath:indexPath]) {
        return [self.qmui_indexPathHeightCache heightForIndexPath:indexPath];
    }
    CGFloat height = [self qmui_heightForCellWithIdentifier:identifier cellClass:cellClass itemWidth:itemWidth configuration:configuration];
    [self.qmui_indexPathHeightCache cacheHeight:height byIndexPath:indexPath];
    return height;
}

// 通过key缓存高度
- (CGFloat)qmui_heightForCellWithIdentifier:(NSString *)identifier cellClass:(Class)cellClass itemWidth:(CGFloat)itemWidth cacheByKey:(id<NSCopying>)key configuration:(void (^)(id cell))configuration {
    if (!identifier || !key || CGRectIsEmpty(self.bounds)) {
        return 0;
    }
    if ([self.qmui_keyedHeightCache existsHeightForKey:key]) {
        return [self.qmui_keyedHeightCache heightForKey:key];
    }
    CGFloat height = [self qmui_heightForCellWithIdentifier:identifier cellClass:cellClass itemWidth:itemWidth configuration:configuration];
    [self.qmui_keyedHeightCache cacheHeight:height byKey:key];
    return height;
}

@end
