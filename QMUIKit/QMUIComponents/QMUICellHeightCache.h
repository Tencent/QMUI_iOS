//
//  QMUICellHeightCache.h
//  qmui
//
//  Created by zhoonchen on 15/12/23.
//  Copyright © 2015年 QMUI Team. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

/**
 *  通过业务定义的一个 key 来缓存 cell 的高度，需搭配 UITableView 或 UICollectionView 使用。
 */
@interface QMUICellHeightCache : NSObject

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

@property(nonatomic, assign) BOOL automaticallyInvalidateEnabled;

- (BOOL)existsHeightAtIndexPath:(NSIndexPath *)indexPath;
- (void)cacheHeight:(CGFloat)height byIndexPath:(NSIndexPath *)indexPath;
- (CGFloat)heightForIndexPath:(NSIndexPath *)indexPath;

// 使cache失效，多用在data更新之后
- (void)invalidateHeightAtIndexPath:(NSIndexPath *)indexPath;
- (void)invalidateAllHeightCache;

// 给 tableview 和 collectionview 调用的方法
- (void)enumerateAllOrientationsUsingBlock:(void (^)(NSMutableArray<NSMutableArray<NSNumber *> *> *heightsBySection))block;
- (void)buildSectionsIfNeeded:(NSInteger)targetSection;
- (void)buildCachesAtIndexPathsIfNeeded:(NSArray *)indexPaths;

@end

/// ====================== 动态计算 cell 高度相关 =======================

/**
 *  UITableView 定义了一套动态计算 cell 高度的方式：
 *
 *  其思路是参考开源代码：https://github.com/forkingdog/UITableView-FDTemplateLayoutCell。
 *
 *  1. cell 必须实现 sizeThatFits: 方法，在里面计算自身的高度并返回
 *  2. 初始化一个 QMUITableView，并为其指定一个 QMUITableViewDataSource
 *  3. 实现 qmui_tableView:cellWithIdentifier: 方法，在里面为不同的 identifier 创建不同的 cell 实例
 *  4. 在 tableView:cellForRowAtIndexPath: 里使用 qmui_tableView:cellWithIdentifier: 获取 cell
 *  5. 在 tableView:heightForRowAtIndexPath: 里使用 UITableView (QMUILayoutCell) 提供的几种方法得到 cell 的高度
 *
 *  这套方式的好处是 tableView 能直接操作 cell 的实例，cell 无需增加额外的专门用于获取 cell 高度的方法。并且这套方式支持基本的高度缓存（可按 key 缓存或按 indexPath 缓存），若使用了缓存，请注意在适当的时机去更新缓存（例如某个 cell 的内容发生变化，可能 cell 的高度也会变化，则需要更新这个 cell 已被缓存起来的高度）。
 *
 *  使用这套方式额外的消耗是每个 identifier 都会生成一个多余的 cell 实例（专用于高度计算），但大部分情况下一个生成一个 cell 实例并不会带来过多的负担，所以一般不用担心这个问题。
 */

@interface UITableView (QMUILayoutCell)

/**
 *  通过 qmui_tableView:cellWithIdentifier: 得到 identifier 对应的 cell 实例，并在 configuration 里对 cell 进行渲染后，得到 cell 的高度。
 *  @param  identifier cell 的 identifier
 *  @param  configuration 用于渲染 cell 的block，一般与 tableView:cellForRowAtIndexPath: 里渲染 cell 的代码一样
 */
- (CGFloat)qmui_heightForCellWithIdentifier:(NSString *)identifier configuration:(void (^)(__kindof UITableViewCell *cell))configuration;

/**
 *  通过 qmui_tableView:cellWithIdentifier: 得到 identifier 对应的 cell 实例，并在 configuration 里对 cell 进行渲染后，得到 cell 的高度。
 *
 *  以 indexPath 为单位进行缓存，相同的 indexPath 高度将不会重复计算，若需刷新高度，请参考 QMUICellHeightIndexPathCache
 *
 *  @param  identifier cell 的 identifier
 *  @param  configuration 用于渲染 cell 的block，一般与 tableView:cellForRowAtIndexPath: 里渲染 cell 的代码一样
 */
- (CGFloat)qmui_heightForCellWithIdentifier:(NSString *)identifier cacheByIndexPath:(NSIndexPath *)indexPath configuration:(void (^)(__kindof UITableViewCell *cell))configuration;

/**
 *  通过 qmui_tableView:cellWithIdentifier: 得到 identifier 对应的 cell 实例，并在 configuration 里对 cell 进行渲染后，得到 cell 的高度。
 *
 *  以自定义的 key 为单位进行缓存，相同的 key 高度将不会重复计算，若需刷新高度，请参考 QMUICellHeightCache
 *
 *  @param  identifier cell 的 identifier
 *  @param  configuration 用于渲染 cell 的block，一般与 tableView:cellForRowAtIndexPath: 里渲染 cell 的代码一样
 */
- (CGFloat)qmui_heightForCellWithIdentifier:(NSString *)identifier cacheByKey:(id<NSCopying>)key configuration:(void (^)(__kindof UITableViewCell *cell))configuration;

@end

@interface UITableView (QMUIKeyedHeightCache)

@property(nonatomic, strong, readonly) QMUICellHeightCache *qmui_keyedHeightCache;

@end

@interface UITableView (QMUICellHeightIndexPathCache)

@property(nonatomic, strong, readonly) QMUICellHeightIndexPathCache *qmui_indexPathHeightCache;

@end

@interface UITableView (QMUIIndexPathHeightCacheInvalidation)

/// 当需要reloadData的时候，又不想使布局失效，可以调用下面这个方法。例如在底部加载更多。
- (void)qmui_reloadDataWithoutInvalidateIndexPathHeightCache;

@end

/// ====================== 计算动态cell高度相关 =======================

/**
 *  UICollectionView 定义了一套动态计算 cell 高度的方式。
 *  原理类似UITableView，具体请参考UITableView+QMUI。
 */

@interface UICollectionView (QMUIKeyedHeightCache)

@property(nonatomic, strong, readonly) QMUICellHeightCache *qmui_keyedHeightCache;

@end

@interface UICollectionView (QMUICellHeightIndexPathCache)

@property(nonatomic, strong, readonly) QMUICellHeightIndexPathCache *qmui_indexPathHeightCache;

@end

@interface UICollectionView (QMUIIndexPathHeightCacheInvalidation)

/// 当需要reloadData的时候，又不想使布局失效，可以调用下面这个方法。例如，在底部加载更多。
- (void)qmui_reloadDataWithoutInvalidateIndexPathHeightCache;

@end

/// 以下接口可在“sizeForItemAtIndexPath”里面调用来计算高度
/// 通过构建一个cell模拟真正显示的cell，给cell设置真实的数据，然后再调用cell的sizeThatFits:来计算高度
/// 也就是说我们自定义的cell里面需要重写sizeThatFits:并返回正确的值
@interface UICollectionView (QMUILayoutCell)

- (CGFloat)qmui_heightForCellWithIdentifier:(NSString *)identifier cellClass:(Class)cellClass itemWidth:(CGFloat)itemWidth configuration:(void (^)(id cell))configuration;

// 通过indexPath缓存高度
- (CGFloat)qmui_heightForCellWithIdentifier:(NSString *)identifier cellClass:(Class)cellClass itemWidth:(CGFloat)itemWidth cacheByIndexPath:(NSIndexPath *)indexPath configuration:(void (^)(id cell))configuration;

// 通过key缓存高度
- (CGFloat)qmui_heightForCellWithIdentifier:(NSString *)identifier cellClass:(Class)cellClass itemWidth:(CGFloat)itemWidth cacheByKey:(id<NSCopying>)key configuration:(void (^)(id cell))configuration;

@end
