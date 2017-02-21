//
//  UICollectionView+QMUI.m
//  qmui
//
//  Created by ZhoonChen on 15/7/20.
//  Copyright (c) 2015年 QMUI Team. All rights reserved.
//

#import "UICollectionView+QMUI.h"
#import <objc/runtime.h>

@implementation UICollectionView (QMUI)

- (void)qmui_clearsSelection {
    NSArray *selectedItemIndexPaths = [self indexPathsForSelectedItems];
    for (NSIndexPath *indexPath in selectedItemIndexPaths) {
        [self deselectItemAtIndexPath:indexPath animated:YES];
    }
}

- (void)qmui_reloadDataKeepingSelection {
    NSArray *selectedIndexPaths = [self indexPathsForSelectedItems];
    [self reloadData];
    for (NSIndexPath *indexPath in selectedIndexPaths) {
        [self selectItemAtIndexPath:indexPath animated:NO scrollPosition:UICollectionViewScrollPositionNone];
    }
}

/// 递归找到view在哪个cell里，不存在则返回nil
- (UICollectionViewCell *)parentCellForView:(UIView *)view {
    if (!view.superview) {
        return nil;
    }
    
    if ([view.superview isKindOfClass:[UICollectionViewCell class]]) {
        return (UICollectionViewCell *)view.superview;
    }
    
    return [self parentCellForView:view.superview];
}

- (NSIndexPath *)qmui_indexPathForItemAtView:(id)sender {
    if (sender && [sender isKindOfClass:[UIView class]]) {
        UIView *view = (UIView *)sender;
        UICollectionViewCell *parentCell = [self parentCellForView:view];
        if (parentCell) {
            return [self indexPathForCell:parentCell];
        }
    }
    
    return nil;
}

- (BOOL)qmui_itemVisibleAtIndexPath:(NSIndexPath *)indexPath {
    NSArray *visibleItemIndexPaths = self.indexPathsForVisibleItems;
    for (NSIndexPath *visibleIndexPath in visibleItemIndexPaths) {
        if ([indexPath isEqual:visibleIndexPath]) {
            return YES;
        }
    }
    return NO;
}

- (NSIndexPath *)qmui_indexPathForFirstVisibleCell {
    NSArray *visibleIndexPaths = [self indexPathsForVisibleItems];
    if (!visibleIndexPaths || visibleIndexPaths.count <= 0) {
        return nil;
    }
    NSIndexPath *minimumIndexPath = nil;
    for (NSIndexPath *indexPath in visibleIndexPaths) {
        if (!minimumIndexPath) {
            minimumIndexPath = indexPath;
            continue;
        }
        
        if (indexPath.section < minimumIndexPath.section) {
            minimumIndexPath = indexPath;
            continue;
        }
        
        if (indexPath.item < minimumIndexPath.item) {
            minimumIndexPath = indexPath;
            continue;
        }
    }
    return minimumIndexPath;
}

@end

/// ====================== 计算动态cell高度相关 =======================

@implementation UICollectionView (QMUIKeyedHeightCache)

- (QMUICellHeightKeyCache *)qmui_keyedHeightCache {
    QMUICellHeightKeyCache *cache = objc_getAssociatedObject(self, _cmd);
    if (!cache) {
        cache = [[QMUICellHeightKeyCache alloc] init];
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
        Method originalMethod = class_getInstanceMethod(self, originalSelector);
        Method swizzledMethod = class_getInstanceMethod(self, swizzledSelector);
        method_exchangeImplementations(originalMethod, swizzledMethod);
    }
}

- (void)qmui_reloadData {
    if (self.qmui_indexPathHeightCache.automaticallyInvalidateEnabled) {
        [self.qmui_indexPathHeightCache enumerateAllOrientationsUsingBlock:^(NSMutableArray *heightsBySection) {
            [heightsBySection removeAllObjects];
        }];
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
    NSLog(@"layout cell created - %@", identifier);
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
        SEL selector = @selector(sizeThatFits:);
        BOOL inherited = ![cell isMemberOfClass:[UICollectionViewCell class]];
        BOOL overrided = [cell.class instanceMethodForSelector:selector] != [UICollectionViewCell instanceMethodForSelector:selector];
        if (inherited && !overrided) {
            NSAssert(NO, @"Customized cell must override '-sizeThatFits:' method if not using auto layout.");
        }
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
