//
//  UICollectionView+QMUICellSizeKeyCache.h
//  QMUIKit
//
//  Created by MoLice on 2018/3/14.
//  Copyright © 2018年 QMUI Team. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@class QMUICellSizeKeyCache;

@protocol QMUICellSizeKeyCache_UICollectionViewDelegate <NSObject>

@optional
- (nonnull id<NSCopying>)qmui_collectionView:(nonnull UICollectionView *)collectionView cacheKeyForItemAtIndexPath:(nonnull NSIndexPath *)indexPath;
@end

/// 注意，这个类的功能暂无法使用
@interface UICollectionView (QMUICellSizeKeyCache)

/// 控制是否要自动缓存 cell 的高度，默认为 NO
@property(nonatomic, assign) BOOL qmui_cacheCellSizeByKeyAutomatically;

/// 获取当前的缓存容器。tableView 的宽度和 contentInset 发生变化时，这个数组也会跟着变，但当 tableView 宽度小于 0 时会返回 nil。
@property(nonatomic, weak, readonly, nullable) QMUICellSizeKeyCache *qmui_currentCellSizeKeyCache;

@end
