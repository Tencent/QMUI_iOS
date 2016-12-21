//
//  QMUICellHeightCache.h
//  qmui
//
//  Created by zhoonchen on 15/12/23.
//  Copyright © 2015年 QMUI Team. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface QMUICellHeightCache : NSObject

@end

/**
 *  通过业务定义的一个 key 来缓存 cell 的高度，需搭配 UITableView 或 UICollectionView 使用。
 */
@interface QMUICellHeightKeyCache : NSObject

- (BOOL)existsHeightForKey:(id<NSCopying>)key;
- (void)cacheHeight:(CGFloat)height byKey:(id<NSCopying>)key;
- (CGFloat)heightForKey:(id<NSCopying>)key;

// 使cache失效，多用在data更新之后
- (void)invalidateHeightForKey:(id<NSCopying>)key;
- (void)invalidateAllHeightCache;

@end

/**
 *  通过 NSIndexPath 来缓存 cell 的高度，需搭配 UITableView 或 UICollectionView 使用。
 */
@interface QMUICellHeightIndexPathCache : NSObject

@property (nonatomic, assign) BOOL automaticallyInvalidateEnabled;

- (BOOL)existsHeightAtIndexPath:(NSIndexPath *)indexPath;
- (void)cacheHeight:(CGFloat)height byIndexPath:(NSIndexPath *)indexPath;
- (CGFloat)heightForIndexPath:(NSIndexPath *)indexPath;

// 使cache失效，多用在data更新之后
- (void)invalidateHeightAtIndexPath:(NSIndexPath *)indexPath;
- (void)invalidateAllHeightCache;

// 给 tableview 和 collectionview 调用的方法
- (void)enumerateAllOrientationsUsingBlock:(void (^)(NSMutableArray *heightsBySection))block;
- (void)buildSectionsIfNeeded:(NSInteger)targetSection;
- (void)buildCachesAtIndexPathsIfNeeded:(NSArray *)indexPaths;

@end
