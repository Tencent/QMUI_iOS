/**
 * Tencent is pleased to support the open source community by making QMUI_iOS available.
 * Copyright (C) 2016-2021 THL A29 Limited, a Tencent company. All rights reserved.
 * Licensed under the MIT License (the "License"); you may not use this file except in compliance with the License. You may obtain a copy of the License at
 * http://opensource.org/licenses/MIT
 * Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.
 */

//
//  QMUICellHeightCache.m
//  qmui
//
//  Created by QMUI Team on 15/12/23.
//

#import "QMUICellHeightCache.h"
#import "QMUITableViewProtocols.h"
#import "QMUICore.h"
#import "UIScrollView+QMUI.h"
#import "UITableView+QMUI.h"
#import "UIView+QMUI.h"
#import "NSNumber+QMUI.h"

const CGFloat kQMUICellHeightInvalidCache = -1;

@interface QMUICellHeightCache ()

@property(nonatomic, strong) NSMutableDictionary<id<NSCopying>, NSNumber *> *cachedHeights;
@end

@implementation QMUICellHeightCache

- (instancetype)init {
    self = [super init];
    if (self) {
        self.cachedHeights = [[NSMutableDictionary alloc] init];
    }
    return self;
}

- (BOOL)existsHeightForKey:(id<NSCopying>)key {
    NSNumber *number = self.cachedHeights[key];
    return number && ![number isEqualToNumber:@(kQMUICellHeightInvalidCache)];
}

- (void)cacheHeight:(CGFloat)height byKey:(id<NSCopying>)key {
    self.cachedHeights[key] = @(height);
}

- (CGFloat)heightForKey:(id<NSCopying>)key {
    return self.cachedHeights[key].qmui_CGFloatValue;
}

- (void)invalidateHeightForKey:(id<NSCopying>)key {
    [self.cachedHeights removeObjectForKey:key];
}

- (void)invalidateAllHeightCache {
    [self.cachedHeights removeAllObjects];
}

@end

@interface QMUICellHeightIndexPathCache ()

@property(nonatomic, strong) NSMutableArray<NSMutableArray<NSNumber *> *> *cachedHeights;
@end

@implementation QMUICellHeightIndexPathCache

- (instancetype)init {
    self = [super init];
    if (self) {
        self.automaticallyInvalidateEnabled = YES;
        self.cachedHeights = [[NSMutableArray alloc] init];
    }
    return self;
}

- (BOOL)existsHeightAtIndexPath:(NSIndexPath *)indexPath {
    [self buildCachesAtIndexPathsIfNeeded:@[indexPath]];
    NSNumber *number = self.cachedHeights[indexPath.section][indexPath.row];
    return number && ![number isEqualToNumber:@(kQMUICellHeightInvalidCache)];
}

- (void)cacheHeight:(CGFloat)height byIndexPath:(NSIndexPath *)indexPath {
    [self buildCachesAtIndexPathsIfNeeded:@[indexPath]];
    self.cachedHeights[indexPath.section][indexPath.row] = @(height);
}

- (CGFloat)heightForIndexPath:(NSIndexPath *)indexPath {
    [self buildCachesAtIndexPathsIfNeeded:@[indexPath]];
    return self.cachedHeights[indexPath.section][indexPath.row].qmui_CGFloatValue;
}

- (void)invalidateHeightInSection:(NSInteger)section {
    [self buildSectionsIfNeeded:section];
    [self.cachedHeights[section] removeAllObjects];
}

- (void)invalidateHeightAtIndexPath:(NSIndexPath *)indexPath {
    [self buildCachesAtIndexPathsIfNeeded:@[indexPath]];
    self.cachedHeights[indexPath.section][indexPath.row] = @(kQMUICellHeightInvalidCache);
}

- (void)invalidateAllHeightCache {
    [self.cachedHeights enumerateObjectsUsingBlock:^(NSMutableArray<NSNumber *> * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [obj removeAllObjects];
    }];
}

- (void)buildCachesAtIndexPathsIfNeeded:(NSArray<NSIndexPath *> *)indexPaths {
    [indexPaths enumerateObjectsUsingBlock:^(NSIndexPath *indexPath, NSUInteger idx, BOOL *stop) {
        [self buildSectionsIfNeeded:indexPath.section];
        [self buildRowsIfNeeded:indexPath.row inExistSection:indexPath.section];
    }];
}

- (void)buildSectionsIfNeeded:(NSInteger)targetSection {
    for (NSInteger section = 0; section <= targetSection; ++section) {
        if (section >= self.cachedHeights.count) {
            [self.cachedHeights addObject:[[NSMutableArray alloc] init]];
        }
    }
}

- (void)buildRowsIfNeeded:(NSInteger)targetRow inExistSection:(NSInteger)section {
    NSMutableArray<NSNumber *> *heightsInSection = self.cachedHeights[section];
    for (NSInteger row = 0; row <= targetRow; ++row) {
        if (row >= heightsInSection.count) {
            [heightsInSection addObject:@(kQMUICellHeightInvalidCache)];
        }
    }
}

@end

#pragma mark - UITableView Height Cache

/// ====================== 计算动态cell高度相关 =======================

@interface UITableView ()

/// key 为 tableView 的内容宽度，value 为该宽度下对应的缓存容器，从而保证 tableView 宽度变化时缓存也会跟着刷新
@property(nonatomic, strong) NSMutableDictionary<NSNumber *, QMUICellHeightCache *> *qmuiTableCache_allKeyedHeightCaches;
@property(nonatomic, strong) NSMutableDictionary<NSNumber *, QMUICellHeightIndexPathCache *> *qmuiTableCache_allIndexPathHeightCaches;
@end

@implementation UITableView (QMUIKeyedHeightCache)

QMUISynthesizeIdStrongProperty(qmuiTableCache_allKeyedHeightCaches, setQmuiTableCache_allKeyedHeightCaches)

- (QMUICellHeightCache *)qmui_keyedHeightCache {
    if (!self.qmuiTableCache_allKeyedHeightCaches) {
        self.qmuiTableCache_allKeyedHeightCaches = [[NSMutableDictionary alloc] init];
    }
    CGFloat contentWidth = self.qmui_validContentWidth;
    QMUICellHeightCache *cache = self.qmuiTableCache_allKeyedHeightCaches[@(contentWidth)];
    if (!cache) {
        cache = [[QMUICellHeightCache alloc] init];
        self.qmuiTableCache_allKeyedHeightCaches[@(contentWidth)] = cache;
    }
    return cache;
}

- (void)qmui_invalidateHeightForKey:(id<NSCopying>)aKey {
    [self.qmuiTableCache_allKeyedHeightCaches enumerateKeysAndObjectsUsingBlock:^(NSNumber * _Nonnull key, QMUICellHeightCache * _Nonnull obj, BOOL * _Nonnull stop) {
        [obj invalidateHeightForKey:aKey];
    }];
}

@end

@implementation UITableView (QMUICellHeightIndexPathCache)

QMUISynthesizeIdStrongProperty(qmuiTableCache_allIndexPathHeightCaches, setQmuiTableCache_allIndexPathHeightCaches)
QMUISynthesizeBOOLProperty(qmui_invalidateIndexPathHeightCachedAutomatically, setQmui_invalidateIndexPathHeightCachedAutomatically)

- (QMUICellHeightIndexPathCache *)qmui_indexPathHeightCache {
    if (!self.qmuiTableCache_allIndexPathHeightCaches) {
        self.qmuiTableCache_allIndexPathHeightCaches = [[NSMutableDictionary alloc] init];
    }
    CGFloat contentWidth = self.qmui_validContentWidth;
    QMUICellHeightIndexPathCache *cache = self.qmuiTableCache_allIndexPathHeightCaches[@(contentWidth)];
    if (!cache) {
        cache = [[QMUICellHeightIndexPathCache alloc] init];
        self.qmuiTableCache_allIndexPathHeightCaches[@(contentWidth)] = cache;
    }
    return cache;
}

- (void)qmui_invalidateHeightAtIndexPath:(NSIndexPath *)indexPath {
    [self.qmuiTableCache_allIndexPathHeightCaches enumerateKeysAndObjectsUsingBlock:^(NSNumber * _Nonnull key, QMUICellHeightIndexPathCache * _Nonnull obj, BOOL * _Nonnull stop) {
        [obj invalidateHeightAtIndexPath:indexPath];
    }];
}

@end

@implementation UITableView (QMUIIndexPathHeightCacheInvalidation)

- (void)qmui_reloadDataWithoutInvalidateIndexPathHeightCache {
    [self qmuiTableCache_reloadData];
}

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        SEL selectors[] = {
            @selector(initWithFrame:style:),
            @selector(initWithCoder:),
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
            SEL swizzledSelector = NSSelectorFromString([@"qmuiTableCache_" stringByAppendingString:NSStringFromSelector(originalSelector)]);
            ExchangeImplementations([self class], originalSelector, swizzledSelector);
        }
    });
}

- (instancetype)qmuiTableCache_initWithFrame:(CGRect)frame style:(UITableViewStyle)style {
    [self qmuiTableCache_initWithFrame:frame style:style];
    [self qmuiTableCache_didInitialize];
    return self;
}

- (instancetype)qmuiTableCache_initWithCoder:(NSCoder *)aDecoder {
    [self qmuiTableCache_initWithCoder:aDecoder];
    [self qmuiTableCache_didInitialize];
    return self;
}

- (void)qmuiTableCache_didInitialize {
    self.qmui_invalidateIndexPathHeightCachedAutomatically = YES;
}

- (void)qmuiTableCache_reloadData {
    if (self.qmui_invalidateIndexPathHeightCachedAutomatically) {
        [self.qmuiTableCache_allIndexPathHeightCaches removeAllObjects];
    }
    [self qmuiTableCache_reloadData];
}

- (void)qmuiTableCache_insertSections:(NSIndexSet *)sections withRowAnimation:(UITableViewRowAnimation)animation {
    if (self.qmui_invalidateIndexPathHeightCachedAutomatically) {
        [sections enumerateIndexesUsingBlock:^(NSUInteger section, BOOL *stop) {
            [self.qmuiTableCache_allIndexPathHeightCaches enumerateKeysAndObjectsUsingBlock:^(NSNumber * _Nonnull key, QMUICellHeightIndexPathCache * _Nonnull obj, BOOL * _Nonnull stop) {
                [obj buildSectionsIfNeeded:section];
                [obj.cachedHeights insertObject:[[NSMutableArray alloc] init] atIndex:section];
            }];
        }];
    }
    [self qmuiTableCache_insertSections:sections withRowAnimation:animation];
}

- (void)qmuiTableCache_deleteSections:(NSIndexSet *)sections withRowAnimation:(UITableViewRowAnimation)animation {
    if (self.qmui_invalidateIndexPathHeightCachedAutomatically) {
        [sections enumerateIndexesUsingBlock:^(NSUInteger section, BOOL *stop) {
            [self.qmuiTableCache_allIndexPathHeightCaches enumerateKeysAndObjectsUsingBlock:^(NSNumber * _Nonnull key, QMUICellHeightIndexPathCache * _Nonnull obj, BOOL * _Nonnull stop) {
                [obj buildSectionsIfNeeded:section];
                [obj.cachedHeights removeObjectAtIndex:section];
            }];
        }];
    }
    [self qmuiTableCache_deleteSections:sections withRowAnimation:animation];
}

- (void)qmuiTableCache_reloadSections:(NSIndexSet *)sections withRowAnimation:(UITableViewRowAnimation)animation {
    if (self.qmui_invalidateIndexPathHeightCachedAutomatically) {
        [sections enumerateIndexesUsingBlock: ^(NSUInteger section, BOOL *stop) {
            [self.qmuiTableCache_allIndexPathHeightCaches enumerateKeysAndObjectsUsingBlock:^(NSNumber * _Nonnull key, QMUICellHeightIndexPathCache * _Nonnull obj, BOOL * _Nonnull stop) {
                [obj buildSectionsIfNeeded:section];
                [obj invalidateHeightInSection:section];
            }];
        }];
    }
    [self qmuiTableCache_reloadSections:sections withRowAnimation:animation];
}

- (void)qmuiTableCache_moveSection:(NSInteger)section toSection:(NSInteger)newSection {
    if (self.qmui_invalidateIndexPathHeightCachedAutomatically) {
        [self.qmuiTableCache_allIndexPathHeightCaches enumerateKeysAndObjectsUsingBlock:^(NSNumber * _Nonnull key, QMUICellHeightIndexPathCache * _Nonnull obj, BOOL * _Nonnull stop) {
            [obj buildSectionsIfNeeded:section];
            [obj buildSectionsIfNeeded:newSection];
            [obj.cachedHeights exchangeObjectAtIndex:section withObjectAtIndex:newSection];
        }];
    }
    [self qmuiTableCache_moveSection:section toSection:newSection];
}

- (void)qmuiTableCache_insertRowsAtIndexPaths:(NSArray<NSIndexPath *> *)indexPaths withRowAnimation:(UITableViewRowAnimation)animation {
    if (self.qmui_invalidateIndexPathHeightCachedAutomatically) {
        [self.qmuiTableCache_allIndexPathHeightCaches enumerateKeysAndObjectsUsingBlock:^(NSNumber * _Nonnull key, QMUICellHeightIndexPathCache * _Nonnull obj, BOOL * _Nonnull stop) {
            [obj buildCachesAtIndexPathsIfNeeded:indexPaths];
            [indexPaths enumerateObjectsUsingBlock:^(NSIndexPath * _Nonnull indexPath, NSUInteger idx, BOOL * _Nonnull stop) {
                NSMutableArray<NSNumber *> *heightsInSection = obj.cachedHeights[indexPath.section];
                [heightsInSection insertObject:@(kQMUICellHeightInvalidCache) atIndex:indexPath.row];
            }];
        }];
    }
    [self qmuiTableCache_insertRowsAtIndexPaths:indexPaths withRowAnimation:animation];
}

- (void)qmuiTableCache_deleteRowsAtIndexPaths:(NSArray<NSIndexPath *> *)indexPaths withRowAnimation:(UITableViewRowAnimation)animation {
    if (self.qmui_invalidateIndexPathHeightCachedAutomatically) {
        [self.qmuiTableCache_allIndexPathHeightCaches enumerateKeysAndObjectsUsingBlock:^(NSNumber * _Nonnull key, QMUICellHeightIndexPathCache * _Nonnull obj, BOOL * _Nonnull stop) {
            [obj buildCachesAtIndexPathsIfNeeded:indexPaths];
            NSMutableDictionary<NSNumber *, NSMutableIndexSet *> *mutableIndexSetsToRemove = [NSMutableDictionary dictionary];
            [indexPaths enumerateObjectsUsingBlock:^(NSIndexPath *indexPath, NSUInteger idx, BOOL *stop) {
                NSMutableIndexSet *mutableIndexSet = mutableIndexSetsToRemove[@(indexPath.section)];
                if (!mutableIndexSet) {
                    mutableIndexSet = [NSMutableIndexSet indexSet];
                    mutableIndexSetsToRemove[@(indexPath.section)] = mutableIndexSet;
                }
                [mutableIndexSet addIndex:indexPath.row];
            }];
            [mutableIndexSetsToRemove enumerateKeysAndObjectsUsingBlock:^(NSNumber *aKey, NSIndexSet *indexSet, BOOL *stop) {
                NSMutableArray<NSNumber *> *heightsInSection = obj.cachedHeights[aKey.integerValue];
                [heightsInSection removeObjectsAtIndexes:indexSet];
            }];
        }];
    }
    [self qmuiTableCache_deleteRowsAtIndexPaths:indexPaths withRowAnimation:animation];
}

- (void)qmuiTableCache_reloadRowsAtIndexPaths:(NSArray<NSIndexPath *> *)indexPaths withRowAnimation:(UITableViewRowAnimation)animation {
    if (self.qmui_invalidateIndexPathHeightCachedAutomatically) {
        [self.qmuiTableCache_allIndexPathHeightCaches enumerateKeysAndObjectsUsingBlock:^(NSNumber * _Nonnull key, QMUICellHeightIndexPathCache * _Nonnull obj, BOOL * _Nonnull stop) {
            [obj buildCachesAtIndexPathsIfNeeded:indexPaths];
            [indexPaths enumerateObjectsUsingBlock:^(NSIndexPath *indexPath, NSUInteger idx, BOOL *stop) {
                NSMutableArray<NSNumber *> *heightsInSection = obj.cachedHeights[indexPath.section];
                heightsInSection[indexPath.row] = @(kQMUICellHeightInvalidCache);
            }];
        }];
    }
    [self qmuiTableCache_reloadRowsAtIndexPaths:indexPaths withRowAnimation:animation];
}

- (void)qmuiTableCache_moveRowAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath *)destinationIndexPath {
    if (self.qmui_invalidateIndexPathHeightCachedAutomatically) {
        [self.qmuiTableCache_allIndexPathHeightCaches enumerateKeysAndObjectsUsingBlock:^(NSNumber * _Nonnull key, QMUICellHeightIndexPathCache * _Nonnull obj, BOOL * _Nonnull stop) {
            [obj buildCachesAtIndexPathsIfNeeded:@[sourceIndexPath, destinationIndexPath]];
            if (obj.cachedHeights.count > 0 && obj.cachedHeights.count > sourceIndexPath.section && obj.cachedHeights.count > destinationIndexPath.section) {
                NSMutableArray<NSNumber *> *sourceHeightsInSection = obj.cachedHeights[sourceIndexPath.section];
                NSMutableArray<NSNumber *> *destinationHeightsInSection = obj.cachedHeights[destinationIndexPath.section];
                NSNumber *sourceHeight = sourceHeightsInSection[sourceIndexPath.row];
                NSNumber *destinationHeight = destinationHeightsInSection[destinationIndexPath.row];
                sourceHeightsInSection[sourceIndexPath.row] = destinationHeight;
                destinationHeightsInSection[destinationIndexPath.row] = sourceHeight;
            }
        }];
    }
    [self qmuiTableCache_moveRowAtIndexPath:sourceIndexPath toIndexPath:destinationIndexPath];
}

@end

@implementation UITableView (QMUILayoutCell)

- (__kindof UITableViewCell *)templateCellForReuseIdentifier:(NSString *)identifier {
    QMUIAssert(identifier.length > 0, @"QMUICellHeightCache", @"%s 需要一个合法的 identifier", __func__);
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
            QMUIAssert(templateCell != nil, @"QMUICellHeightCache", @"通过 %s %@ 无法得到一个 cell 对象", __func__, identifier);
        }
        templateCell.contentView.translatesAutoresizingMaskIntoConstraints = NO;
        templateCellsByIdentifiers[identifier] = templateCell;
    }
    return templateCell;
}

- (CGFloat)qmui_heightForCellWithIdentifier:(NSString *)identifier configuration:(void (^)(__kindof UITableViewCell *))configuration {
    CGFloat contentWidth = self.qmui_validContentWidth;
    if (!identifier || contentWidth <= 0) {
        return 0;
    }
    UITableViewCell *cell = [self templateCellForReuseIdentifier:identifier];
    [cell prepareForReuse];
    if (configuration) configuration(cell);
    CGSize fitSize = CGSizeZero;
    if (cell && contentWidth > 0) {
        fitSize = [cell sizeThatFits:CGSizeMake(contentWidth, CGFLOAT_MAX)];
    }
    return flat(fitSize.height);
}

// 通过indexPath缓存高度
- (CGFloat)qmui_heightForCellWithIdentifier:(NSString *)identifier cacheByIndexPath:(NSIndexPath *)indexPath configuration:(void (^)(__kindof UITableViewCell *))configuration {
    if (!identifier || !indexPath || self.qmui_validContentWidth <= 0) {
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
    if (!identifier || !key || self.qmui_validContentWidth <= 0) {
        return 0;
    }
    if ([self.qmui_keyedHeightCache existsHeightForKey:key]) {
        return [self.qmui_keyedHeightCache heightForKey:key];
    }
    CGFloat height = [self qmui_heightForCellWithIdentifier:identifier configuration:configuration];
    [self.qmui_keyedHeightCache cacheHeight:height byKey:key];
    return height;
}

- (void)qmui_invalidateAllHeight {
    [self.qmuiTableCache_allKeyedHeightCaches removeAllObjects];
    [self.qmuiTableCache_allIndexPathHeightCaches removeAllObjects];
}

@end

#pragma mark - UICollectionView Height Cache

/// ====================== 计算动态cell高度相关 =======================

@interface UICollectionView ()

/// key 为 UICollectionView 的内容大小（包裹着 CGSize），value 为该大小下对应的缓存容器，从而保证 UICollectionView 大小变化时缓存也会跟着刷新
@property(nonatomic, strong) NSMutableDictionary<NSValue *, QMUICellHeightCache *> *qmuiCollectionCache_allKeyedHeightCaches;
@property(nonatomic, strong) NSMutableDictionary<NSValue *, QMUICellHeightIndexPathCache *> *qmuiCollectionCache_allIndexPathHeightCaches;
@end

@implementation UICollectionView (QMUIKeyedHeightCache)

QMUISynthesizeIdStrongProperty(qmuiCollectionCache_allKeyedHeightCaches, setQmuiCollectionCache_allKeyedHeightCaches)

- (QMUICellHeightCache *)qmui_keyedHeightCache {
    if (!self.qmuiCollectionCache_allKeyedHeightCaches) {
        self.qmuiCollectionCache_allKeyedHeightCaches = [[NSMutableDictionary alloc] init];
    }
    CGSize collectionViewSize = CGSizeMake(CGRectGetWidth(self.bounds) - UIEdgeInsetsGetHorizontalValue(self.safeAreaInsets), CGRectGetHeight(self.bounds) - UIEdgeInsetsGetVerticalValue(self.safeAreaInsets));
    QMUICellHeightCache *cache = self.qmuiCollectionCache_allKeyedHeightCaches[[NSValue valueWithCGSize:collectionViewSize]];
    if (!cache) {
        cache = [[QMUICellHeightCache alloc] init];
        self.qmuiCollectionCache_allKeyedHeightCaches[[NSValue valueWithCGSize:collectionViewSize]] = cache;
    }
    return cache;
}

- (void)qmui_invalidateHeightForKey:(id<NSCopying>)aKey {
    [self.qmuiCollectionCache_allKeyedHeightCaches enumerateKeysAndObjectsUsingBlock:^(NSValue * _Nonnull key, QMUICellHeightCache * _Nonnull obj, BOOL * _Nonnull stop) {
        [obj invalidateHeightForKey:aKey];
    }];
}

@end

@implementation UICollectionView (QMUICellHeightIndexPathCache)

QMUISynthesizeBOOLProperty(qmui_invalidateIndexPathHeightCachedAutomatically, setQmui_invalidateIndexPathHeightCachedAutomatically)
QMUISynthesizeIdStrongProperty(qmuiCollectionCache_allIndexPathHeightCaches, setQmuiCollectionCache_allIndexPathHeightCaches)

- (QMUICellHeightIndexPathCache *)qmui_indexPathHeightCache {
    if (!self.qmuiCollectionCache_allIndexPathHeightCaches) {
        self.qmuiCollectionCache_allIndexPathHeightCaches = [[NSMutableDictionary alloc] init];
    }
    CGSize collectionViewSize = CGSizeMake(CGRectGetWidth(self.bounds) - UIEdgeInsetsGetHorizontalValue(self.safeAreaInsets), CGRectGetHeight(self.bounds) - UIEdgeInsetsGetVerticalValue(self.safeAreaInsets));
    QMUICellHeightIndexPathCache *cache = self.qmuiCollectionCache_allIndexPathHeightCaches[[NSValue valueWithCGSize:collectionViewSize]];
    if (!cache) {
        cache = [[QMUICellHeightIndexPathCache alloc] init];
        self.qmuiCollectionCache_allIndexPathHeightCaches[[NSValue valueWithCGSize:collectionViewSize]] = cache;
    }
    return cache;
}

- (void)qmui_invalidateHeightAtIndexPath:(NSIndexPath *)indexPath {
    [self.qmuiCollectionCache_allIndexPathHeightCaches enumerateKeysAndObjectsUsingBlock:^(NSValue * _Nonnull key, QMUICellHeightIndexPathCache * _Nonnull obj, BOOL * _Nonnull stop) {
        [obj invalidateHeightAtIndexPath:indexPath];
    }];
}

@end

@implementation UICollectionView (QMUIIndexPathHeightCacheInvalidation)

- (void)qmui_reloadDataWithoutInvalidateIndexPathHeightCache {
    [self qmuiCollectionCache_reloadData];
}

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        SEL selectors[] = {
            @selector(initWithFrame:collectionViewLayout:),
            @selector(initWithCoder:),
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
        for (NSUInteger index = 0; index < sizeof(selectors) / sizeof(SEL); index++) {
            SEL originalSelector = selectors[index];
            SEL swizzledSelector = NSSelectorFromString([@"qmuiCollectionCache_" stringByAppendingString:NSStringFromSelector(originalSelector)]);
            ExchangeImplementations([self class], originalSelector, swizzledSelector);
        }
    });
}

- (instancetype)qmuiCollectionCache_initWithFrame:(CGRect)frame collectionViewLayout:(UICollectionViewLayout *)layout {
    [self qmuiCollectionCache_initWithFrame:frame collectionViewLayout:layout];
    [self qmuiCollectionCache_didInitialize];
    return self;
}

- (instancetype)qmuiCollectionCache_initWithCoder:(NSCoder *)aDecoder {
    [self qmuiCollectionCache_initWithCoder:aDecoder];
    [self qmuiCollectionCache_didInitialize];
    return self;
}

- (void)qmuiCollectionCache_didInitialize {
    self.qmui_invalidateIndexPathHeightCachedAutomatically = YES;
}

- (void)qmuiCollectionCache_reloadData {
    if (self.qmui_invalidateIndexPathHeightCachedAutomatically) {
        [self.qmuiCollectionCache_allIndexPathHeightCaches removeAllObjects];
    }
    [self qmuiCollectionCache_reloadData];
}

- (void)qmuiCollectionCache_insertSections:(NSIndexSet *)sections {
    if (self.qmui_invalidateIndexPathHeightCachedAutomatically) {
        [self.qmuiCollectionCache_allIndexPathHeightCaches enumerateKeysAndObjectsUsingBlock:^(NSValue * _Nonnull key, QMUICellHeightIndexPathCache * _Nonnull obj, BOOL * _Nonnull stop) {
            [sections enumerateIndexesUsingBlock:^(NSUInteger section, BOOL * _Nonnull stop) {
                [obj buildSectionsIfNeeded:section];
                [obj.cachedHeights insertObject:[[NSMutableArray alloc] init] atIndex:section];
            }];
        }];
    }
    [self qmuiCollectionCache_insertSections:sections];
}

- (void)qmuiCollectionCache_deleteSections:(NSIndexSet *)sections {
    if (self.qmui_invalidateIndexPathHeightCachedAutomatically) {
        [self.qmuiCollectionCache_allIndexPathHeightCaches enumerateKeysAndObjectsUsingBlock:^(NSValue * _Nonnull key, QMUICellHeightIndexPathCache * _Nonnull obj, BOOL * _Nonnull stop) {
            [sections enumerateIndexesUsingBlock:^(NSUInteger section, BOOL * _Nonnull stop) {
                [obj buildSectionsIfNeeded:section];
                [obj.cachedHeights removeObjectAtIndex:section];
            }];
        }];
    }
    [self qmuiCollectionCache_deleteSections:sections];
}

- (void)qmuiCollectionCache_reloadSections:(NSIndexSet *)sections {
    if (self.qmui_invalidateIndexPathHeightCachedAutomatically) {
        [self.qmuiCollectionCache_allIndexPathHeightCaches enumerateKeysAndObjectsUsingBlock:^(NSValue * _Nonnull key, QMUICellHeightIndexPathCache * _Nonnull obj, BOOL * _Nonnull stop) {
            [sections enumerateIndexesUsingBlock:^(NSUInteger section, BOOL * _Nonnull stop) {
                [obj buildSectionsIfNeeded:section];
                [obj.cachedHeights[section] removeAllObjects];
            }];
        }];
    }
    [self qmuiCollectionCache_reloadSections:sections];
}

- (void)qmuiCollectionCache_moveSection:(NSInteger)section toSection:(NSInteger)newSection {
    if (self.qmui_invalidateIndexPathHeightCachedAutomatically) {
        [self.qmuiCollectionCache_allIndexPathHeightCaches enumerateKeysAndObjectsUsingBlock:^(NSValue * _Nonnull key, QMUICellHeightIndexPathCache * _Nonnull obj, BOOL * _Nonnull stop) {
            [obj buildSectionsIfNeeded:section];
            [obj buildSectionsIfNeeded:newSection];
            [obj.cachedHeights exchangeObjectAtIndex:section withObjectAtIndex:newSection];
        }];
    }
    [self qmuiCollectionCache_moveSection:section toSection:newSection];
}

- (void)qmuiCollectionCache_insertItemsAtIndexPaths:(NSArray<NSIndexPath *> *)indexPaths {
    if (self.qmui_invalidateIndexPathHeightCachedAutomatically) {
        [self.qmuiCollectionCache_allIndexPathHeightCaches enumerateKeysAndObjectsUsingBlock:^(NSValue * _Nonnull key, QMUICellHeightIndexPathCache * _Nonnull obj, BOOL * _Nonnull stop) {
            [obj buildCachesAtIndexPathsIfNeeded:indexPaths];
            [indexPaths enumerateObjectsUsingBlock:^(NSIndexPath *indexPath, NSUInteger idx, BOOL *stop) {
                NSMutableArray<NSNumber *> *heightsInSection = obj.cachedHeights[indexPath.section];
                [heightsInSection insertObject:@(kQMUICellHeightInvalidCache) atIndex:indexPath.item];
            }];
        }];
    }
    [self qmuiCollectionCache_insertItemsAtIndexPaths:indexPaths];
}

- (void)qmuiCollectionCache_deleteItemsAtIndexPaths:(NSArray<NSIndexPath *> *)indexPaths {
    if (self.qmui_invalidateIndexPathHeightCachedAutomatically) {
        [self.qmuiCollectionCache_allIndexPathHeightCaches enumerateKeysAndObjectsUsingBlock:^(NSValue * _Nonnull key, QMUICellHeightIndexPathCache * _Nonnull obj, BOOL * _Nonnull stop) {
            [obj buildCachesAtIndexPathsIfNeeded:indexPaths];
            NSMutableDictionary<NSNumber *, NSMutableIndexSet *> *mutableIndexSetsToRemove = [NSMutableDictionary dictionary];
            [indexPaths enumerateObjectsUsingBlock:^(NSIndexPath *indexPath, NSUInteger idx, BOOL *stop) {
                NSMutableIndexSet *mutableIndexSet = mutableIndexSetsToRemove[@(indexPath.section)];
                if (!mutableIndexSet) {
                    mutableIndexSet = [NSMutableIndexSet indexSet];
                    mutableIndexSetsToRemove[@(indexPath.section)] = mutableIndexSet;
                }
                [mutableIndexSet addIndex:indexPath.item];
            }];
            [mutableIndexSetsToRemove enumerateKeysAndObjectsUsingBlock:^(NSNumber *aKey, NSIndexSet *indexSet, BOOL *stop) {
                NSMutableArray<NSNumber *> *heightsInSection = obj.cachedHeights[aKey.integerValue];
                [heightsInSection removeObjectsAtIndexes:indexSet];
            }];
        }];
    }
    [self qmuiCollectionCache_deleteItemsAtIndexPaths:indexPaths];
}

- (void)qmuiCollectionCache_reloadItemsAtIndexPaths:(NSArray<NSIndexPath *> *)indexPaths {
    if (self.qmui_invalidateIndexPathHeightCachedAutomatically) {
        [self.qmuiCollectionCache_allIndexPathHeightCaches enumerateKeysAndObjectsUsingBlock:^(NSValue * _Nonnull key, QMUICellHeightIndexPathCache * _Nonnull obj, BOOL * _Nonnull stop) {
            [obj buildCachesAtIndexPathsIfNeeded:indexPaths];
            [indexPaths enumerateObjectsUsingBlock:^(NSIndexPath *indexPath, NSUInteger idx, BOOL *stop) {
                NSMutableArray<NSNumber *> *heightsInSection = obj.cachedHeights[indexPath.section];
                heightsInSection[indexPath.item] = @(kQMUICellHeightInvalidCache);
            }];
        }];
    }
    [self qmuiCollectionCache_reloadItemsAtIndexPaths:indexPaths];
}

- (void)qmuiCollectionCache_moveItemAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath *)destinationIndexPath {
    if (self.qmui_invalidateIndexPathHeightCachedAutomatically) {
        [self.qmuiCollectionCache_allIndexPathHeightCaches enumerateKeysAndObjectsUsingBlock:^(NSValue * _Nonnull key, QMUICellHeightIndexPathCache * _Nonnull obj, BOOL * _Nonnull stop) {
            [obj buildCachesAtIndexPathsIfNeeded:@[sourceIndexPath, destinationIndexPath]];
            if (obj.cachedHeights.count > 0 && obj.cachedHeights.count > sourceIndexPath.section && obj.cachedHeights.count > destinationIndexPath.section) {
                NSMutableArray<NSNumber *> *sourceHeightsInSection = obj.cachedHeights[sourceIndexPath.section];
                NSMutableArray<NSNumber *> *destinationHeightsInSection = obj.cachedHeights[destinationIndexPath.section];
                NSNumber *sourceHeight = sourceHeightsInSection[sourceIndexPath.item];
                NSNumber *destinationHeight = destinationHeightsInSection[destinationIndexPath.item];
                sourceHeightsInSection[sourceIndexPath.item] = destinationHeight;
                destinationHeightsInSection[destinationIndexPath.item] = sourceHeight;
            }
        }];
    }
    [self qmuiCollectionCache_moveItemAtIndexPath:sourceIndexPath toIndexPath:destinationIndexPath];
}

@end

@implementation UICollectionView (QMUILayoutCell)

- (__kindof UICollectionViewCell *)templateCellForReuseIdentifier:(NSString *)identifier cellClass:(Class)cellClass {
    QMUIAssert(identifier.length > 0, @"QMUICellHeightCache", @"%s 需要一个合法的 identifier", __func__);
    QMUIAssert([self.collectionViewLayout isKindOfClass:[UICollectionViewFlowLayout class]], @"QMUICellHeightCache", @"只支持 %@", NSStringFromClass(UICollectionViewFlowLayout.class));
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
        QMUIAssert(templateCell != nil, @"QMUICellHeightCache", @"通过 %s %@ 无法得到一个 cell 对象", __func__, identifier);
    }
    templateCell.contentView.translatesAutoresizingMaskIntoConstraints = NO;
    templateCellsByIdentifiers[identifier] = templateCell;
    return templateCell;
}

- (CGFloat)qmui_heightForCellWithIdentifier:(NSString *)identifier cellClass:(Class)cellClass itemWidth:(CGFloat)itemWidth configuration:(void (^)(__kindof UICollectionViewCell *cell))configuration {
    if (!identifier || CGRectGetWidth(self.bounds) <= 0) {
        return 0;
    }
    UICollectionViewCell *cell = [self templateCellForReuseIdentifier:identifier cellClass:cellClass];
    [cell prepareForReuse];
    if (configuration) configuration(cell);
    CGSize fitSize = CGSizeZero;
    if (cell && itemWidth > 0) {
        fitSize = [cell sizeThatFits:CGSizeMake(itemWidth, CGFLOAT_MAX)];
    }
    return ceil(fitSize.height);
}

// 通过indexPath缓存高度
- (CGFloat)qmui_heightForCellWithIdentifier:(NSString *)identifier cellClass:(Class)cellClass itemWidth:(CGFloat)itemWidth cacheByIndexPath:(NSIndexPath *)indexPath configuration:(void (^)(__kindof UICollectionViewCell *cell))configuration {
    if (!identifier || !indexPath || CGRectGetWidth(self.bounds) <= 0) {
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
- (CGFloat)qmui_heightForCellWithIdentifier:(NSString *)identifier cellClass:(Class)cellClass itemWidth:(CGFloat)itemWidth cacheByKey:(id<NSCopying>)key configuration:(void (^)(__kindof UICollectionViewCell *cell))configuration {
    if (!identifier || !key || CGRectGetWidth(self.bounds) <= 0) {
        return 0;
    }
    if ([self.qmui_keyedHeightCache existsHeightForKey:key]) {
        return [self.qmui_keyedHeightCache heightForKey:key];
    }
    CGFloat height = [self qmui_heightForCellWithIdentifier:identifier cellClass:cellClass itemWidth:itemWidth configuration:configuration];
    [self.qmui_keyedHeightCache cacheHeight:height byKey:key];
    return height;
}

- (void)qmui_invalidateAllHeight {
    [self.qmuiCollectionCache_allKeyedHeightCaches removeAllObjects];
    [self.qmuiCollectionCache_allIndexPathHeightCaches removeAllObjects];
}

@end
