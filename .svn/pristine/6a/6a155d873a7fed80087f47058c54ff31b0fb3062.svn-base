//
//  QMUICellHeightCache.m
//  qmui
//
//  Created by zhoonchen on 15/12/23.
//  Copyright © 2015年 QMUI Team. All rights reserved.
//

#import "QMUICellHeightCache.h"

@implementation QMUICellHeightCache

@end

@implementation QMUICellHeightKeyCache {
    NSMutableDictionary *_mutableHeightsByKeyForPortrait;
    NSMutableDictionary *_mutableHeightsByKeyForLandscape;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _mutableHeightsByKeyForPortrait = [NSMutableDictionary dictionary];
        _mutableHeightsByKeyForLandscape = [NSMutableDictionary dictionary];
    }
    return self;
}

- (NSMutableDictionary *)mutableHeightsByKeyForCurrentOrientation {
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
#if CGFLOAT_IS_DOUBLE
    return [[self mutableHeightsByKeyForCurrentOrientation][key] doubleValue];
#else
    return [[self mutableHeightsByKeyForCurrentOrientation][key] floatValue];
#endif
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
    NSMutableArray *_heightsBySectionForPortrait;
    NSMutableArray *_heightsBySectionForLandscape;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _heightsBySectionForPortrait = [NSMutableArray array];
        _heightsBySectionForLandscape = [NSMutableArray array];
    }
    return self;
}

- (NSMutableArray *)heightsBySectionForCurrentOrientation {
    return UIDeviceOrientationIsPortrait([UIDevice currentDevice].orientation) ? _heightsBySectionForPortrait : _heightsBySectionForLandscape;
}

- (void)enumerateAllOrientationsUsingBlock:(void (^)(NSMutableArray *heightsBySection))block {
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
    NSNumber *number = self.heightsBySectionForCurrentOrientation[indexPath.section][indexPath.row];
#if CGFLOAT_IS_DOUBLE
    return number.doubleValue;
#else
    return number.floatValue;
#endif
}

- (void)invalidateHeightAtIndexPath:(NSIndexPath *)indexPath {
    [self buildCachesAtIndexPathsIfNeeded:@[indexPath]];
    [self enumerateAllOrientationsUsingBlock:^(NSMutableArray *heightsBySection) {
        heightsBySection[indexPath.section][indexPath.row] = @-1;
    }];
}

- (void)invalidateAllHeightCache {
    [self enumerateAllOrientationsUsingBlock:^(NSMutableArray *heightsBySection) {
        [heightsBySection removeAllObjects];
    }];
}

- (void)buildCachesAtIndexPathsIfNeeded:(NSArray *)indexPaths {
    [indexPaths enumerateObjectsUsingBlock:^(NSIndexPath *indexPath, NSUInteger idx, BOOL *stop) {
        [self buildSectionsIfNeeded:indexPath.section];
        [self buildRowsIfNeeded:indexPath.row inExistSection:indexPath.section];
    }];
}

- (void)buildSectionsIfNeeded:(NSInteger)targetSection {
    [self enumerateAllOrientationsUsingBlock:^(NSMutableArray *heightsBySection) {
        for (NSInteger section = 0; section <= targetSection; ++section) {
            if (section >= heightsBySection.count) {
                heightsBySection[section] = [NSMutableArray array];
            }
        }
    }];
}

- (void)buildRowsIfNeeded:(NSInteger)targetRow inExistSection:(NSInteger)section {
    [self enumerateAllOrientationsUsingBlock:^(NSMutableArray *heightsBySection) {
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
