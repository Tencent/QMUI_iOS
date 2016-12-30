//
//  UICollectionView+QMUI.h
//  qmui
//
//  Created by ZhoonChen on 15/7/20.
//  Copyright (c) 2015年 QMUI Team. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "QMUICellHeightCache.h"

@interface UICollectionView (QMUI)

/**
 *  清除所有已选中的item的选中状态
 */
- (void)qmui_clearsSelection;

/**
 *  重新`reloadData`，同时保持`reloadData`前item的选中状态
 */
- (void)qmui_reloadDataKeepingSelection;

/**
 *  获取某个view在collectionView内对应的indexPath
 *
 *  例如某个view是某个cell里的subview，在这个view的点击事件回调方法里，就能通过`qmui_indexPathForItemAtView:`获取被点击的view所处的cell的indexPath
 *
 *  @warning 注意返回的indexPath有可能为nil，要做保护。
 */
- (NSIndexPath *)qmui_indexPathForItemAtView:(id)sender;

/**
 *  判断当前 indexPath 的 item 是否为可视的 item
 */
- (BOOL)qmui_itemVisibleAtIndexPath:(NSIndexPath *)indexPath;

/**
 *  获取可视区域内第一个cell的indexPath。
 *
 *  为什么需要这个方法是因为系统的indexPathsForVisibleItems方法返回的数组成员是无序排列的，所以不能直接通过firstObject拿到第一个cell。
 *
 *  @warning 若可视区域为CGRectZero，则返回nil
 */
- (NSIndexPath *)qmui_indexPathForFirstVisibleCell;

@end

/// ====================== 计算动态cell高度相关 =======================

/**
 *  UICollectionView 定义了一套动态计算 cell 高度的方式。
 *  原理类似UITableView，具体请参考UITableView+QMUI。
 */

@interface UICollectionView (QMUIKeyedHeightCache)

@property (nonatomic, strong, readonly) QMUICellHeightKeyCache *qmui_keyedHeightCache;

@end

@interface UICollectionView (QMUICellHeightIndexPathCache)

@property (nonatomic, strong, readonly) QMUICellHeightIndexPathCache *qmui_indexPathHeightCache;

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
