/**
 * Tencent is pleased to support the open source community by making QMUI_iOS available.
 * Copyright (C) 2016-2021 THL A29 Limited, a Tencent company. All rights reserved.
 * Licensed under the MIT License (the "License"); you may not use this file except in compliance with the License. You may obtain a copy of the License at
 * http://opensource.org/licenses/MIT
 * Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.
 */

//
//  QMUICellHeightCache.h
//  qmui
//
//  Created by QMUI Team on 15/12/23.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface QMUICellHeightCache : NSObject

- (BOOL)existsHeightForKey:(id<NSCopying>)key;
- (void)cacheHeight:(CGFloat)height byKey:(id<NSCopying>)key;
- (CGFloat)heightForKey:(id<NSCopying>)key;
- (void)invalidateHeightForKey:(id<NSCopying>)key;
- (void)invalidateAllHeightCache;

@end

@interface QMUICellHeightIndexPathCache : NSObject

@property(nonatomic, assign) BOOL automaticallyInvalidateEnabled;// TODO: 这个要放在 tableView 那边

- (BOOL)existsHeightAtIndexPath:(NSIndexPath *)indexPath;
- (void)cacheHeight:(CGFloat)height byIndexPath:(NSIndexPath *)indexPath;
- (CGFloat)heightForIndexPath:(NSIndexPath *)indexPath;
- (void)invalidateHeightAtIndexPath:(NSIndexPath *)indexPath;
- (void)invalidateAllHeightCache;

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
 *  6. 当某个 cell 的缓存需要主动刷新时，请调用 UITableView 的 qmui_invalidateXxx 系列方法。
 *
 *  这套方式的好处是 tableView 能直接操作 cell 的实例，cell 无需增加额外的专门用于获取 cell 高度的方法。并且这套方式支持基本的高度缓存（可按 key 缓存或按 indexPath 缓存），若使用了缓存，请注意在适当的时机去更新缓存（例如某个 cell 的内容发生变化，可能 cell 的高度也会变化，则需要更新这个 cell 已被缓存起来的高度）。
 *
 *  使用这套方式额外的消耗是每个 identifier 都会生成一个多余的 cell 实例（专用于高度计算），但大部分情况下一个生成一个 cell 实例并不会带来过多的负担，所以一般不用担心这个问题。
 
 *  @note 当 tableView 的宽度发生变化时，缓存会自动刷新，所以无需自己监听横竖屏旋转、viewWillTransitionToSize: 等事件。
 *
 *  @note 注意，如果你的 tableView 可以使用 estimatedRowHeight，则建议使用 UITableView (QMUICellHeightKeyCache) 代替本控件，可节省大量代码。
 *
 *  @see UITableView (QMUICellHeightKeyCache)
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

/// 搭配 QMUICellHeightCache，清除整个列表的所有高度缓存（包括 key 和 indexPath），注意请不要直接使用 self.qmui_keyedHeightCache 或 self.qmui_indexPathHeightCache 的 invalidate 方法，因为一个 UITableView 在不同宽度下会有不同的 QMUICellHeightCache/QMUICellHeightIndexPathCache，直接使用那两个 cache 的 invalidate 方法只能刷新当前的 cache，无法刷新其他宽度下的 cache。
- (void)qmui_invalidateAllHeight;

@end

@interface UITableView (QMUIKeyedHeightCache)

/// 在 UITableView 不同的宽度下会得到不一样的 QMUICellHeightCache 实例，从而保证宽度变化时缓存自动刷新
@property(nonatomic, strong, readonly) QMUICellHeightCache *qmui_keyedHeightCache;

/// 搭配 QMUICellHeightCache，清除指定 key 的高度缓存，注意请不要直接使用 [self.qmui_keyedHeightCache invalidateHeightForKey:]，因为一个 UITableView 在不同宽度下会有不同的 QMUICellHeightCache，直接使用那个 cache 的 invalidate 方法只能刷新当前的 cache，无法刷新其他宽度下的 cache。
- (void)qmui_invalidateHeightForKey:(id<NSCopying>)key;

@end

@interface UITableView (QMUICellHeightIndexPathCache)

/// YES 表示在 reloadData、reloadIndexPath: 等方法被调用时，对应的缓存也会被自动更新，默认为 YES。仅对 indexPath 方式的缓存有效。
@property(nonatomic, assign) BOOL qmui_invalidateIndexPathHeightCachedAutomatically;

/// 在 UICollectionView 不同的大小下会得到不一样的 QMUICellHeightIndexPathCache 实例，从而保证大小变化时缓存自动刷新
@property(nonatomic, strong, readonly) QMUICellHeightIndexPathCache *qmui_indexPathHeightCache;

/// 搭配 QMUICellHeightIndexPathCache，清除指定 indexPath 的高度缓存，注意请不要直接使用 [self.qmui_indexPathHeightCache invalidateHeightAtIndexPath:]，因为一个 UITableView 在不同宽度下会有不同的 QMUICellHeightIndexPathCache，直接使用那个 cache 的 invalidate 方法只能刷新当前的 cache，无法刷新其他宽度下的 cache。
- (void)qmui_invalidateHeightAtIndexPath:(NSIndexPath *)indexPath;

@end

@interface UITableView (QMUIIndexPathHeightCacheInvalidation)

/// 当需要 reloadData 的时候，又不想使缓存失效，可以调用下面这个方法。注意，仅在 qmui_invalidateIndexPathHeightCachedAutomatically 为 YES 时才有意义。
- (void)qmui_reloadDataWithoutInvalidateIndexPathHeightCache;

@end

/// ====================== 计算动态cell高度相关 =======================

/**
 *  UICollectionView 定义了一套动态计算 cell 高度的方式。
 *  原理类似 UITableView，具体请参考 UITableView (QMUILayoutCell)。
 */

@interface UICollectionView (QMUIKeyedHeightCache)

/// 在 UICollectionView 不同的大小下会得到不一样的 QMUICellHeightCache 实例，从而保证大小变化时缓存自动刷新
@property(nonatomic, strong, readonly) QMUICellHeightCache *qmui_keyedHeightCache;

/// 搭配 QMUICellHeightCache，清除指定 key 的高度缓存，注意请不要直接使用 [self.qmui_keyedHeightCache invalidateHeightForKey:]，因为一个 UICollectionView 在不同宽度下会有不同的 QMUICellHeightCache，直接使用那个 cache 的 invalidate 方法只能刷新当前的 cache，无法刷新其他宽度下的 cache。
- (void)qmui_invalidateHeightForKey:(id<NSCopying>)key;
@end

@interface UICollectionView (QMUICellHeightIndexPathCache)

/// YES 表示在 reloadData、reloadIndexPath: 等方法被调用时，对应的缓存也会被自动更新，默认为 YES。仅对 indexPath 方式的缓存有效。
@property(nonatomic, assign) BOOL qmui_invalidateIndexPathHeightCachedAutomatically;

/// 在 UICollectionView 不同的大小下会得到不一样的 QMUICellHeightIndexPathCache 实例，从而保证大小变化时缓存自动刷新
@property(nonatomic, strong, readonly) QMUICellHeightIndexPathCache *qmui_indexPathHeightCache;

/// 搭配 QMUICellHeightIndexPathCache，清除指定 indexPath 的高度缓存，注意请不要直接使用 [self.qmui_indexPathHeightCache invalidateHeightAtIndexPath:]，因为一个 UICollectionView 在不同宽度下会有不同的 QMUICellHeightIndexPathCache，直接使用那个 cache 的 invalidate 方法只能刷新当前的 cache，无法刷新其他宽度下的 cache。
- (void)qmui_invalidateHeightAtIndexPath:(NSIndexPath *)indexPath;

@end

@interface UICollectionView (QMUIIndexPathHeightCacheInvalidation)

/// 当需要 reloadData 的时候，又不想使缓存失效，可以调用下面这个方法。注意，仅在 qmui_invalidateIndexPathHeightCachedAutomatically 为 YES 时才有意义。
- (void)qmui_reloadDataWithoutInvalidateIndexPathHeightCache;

@end

/// 以下接口可在“sizeForItemAtIndexPath”里面调用来计算高度
/// 通过构建一个cell模拟真正显示的cell，给cell设置真实的数据，然后再调用cell的sizeThatFits:来计算高度
/// 也就是说我们自定义的cell里面需要重写sizeThatFits:并返回正确的值
@interface UICollectionView (QMUILayoutCell)

- (CGFloat)qmui_heightForCellWithIdentifier:(NSString *)identifier cellClass:(Class)cellClass itemWidth:(CGFloat)itemWidth configuration:(void (^)(__kindof UICollectionViewCell *cell))configuration;

// 通过indexPath缓存高度
- (CGFloat)qmui_heightForCellWithIdentifier:(NSString *)identifier cellClass:(Class)cellClass itemWidth:(CGFloat)itemWidth cacheByIndexPath:(NSIndexPath *)indexPath configuration:(void (^)(__kindof UICollectionViewCell *cell))configuration;

// 通过key缓存高度
- (CGFloat)qmui_heightForCellWithIdentifier:(NSString *)identifier cellClass:(Class)cellClass itemWidth:(CGFloat)itemWidth cacheByKey:(id<NSCopying>)key configuration:(void (^)(__kindof UICollectionViewCell *cell))configuration;

/// 搭配 QMUICellHeightCache，清除整个列表的所有高度缓存（包括 key 和 indexPath），注意请不要直接使用 self.qmui_keyedHeightCache 或 self.qmui_indexPathHeightCache 的 invalidate 方法，因为一个 UICollectionView 在不同宽度下会有不同的 QMUICellHeightCache/QMUICellHeightIndexPathCache，直接使用那两个 cache 的 invalidate 方法只能刷新当前的 cache，无法刷新其他宽度下的 cache。
- (void)qmui_invalidateAllHeight;

@end
