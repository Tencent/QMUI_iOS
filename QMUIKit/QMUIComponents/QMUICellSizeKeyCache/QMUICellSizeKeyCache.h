//
//  QMUICellSizeKeyCache.h
//  QMUIKit
//
//  Created by MoLice on 2018/3/14.
//  Copyright © 2018年 QMUI Team. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

/**
 *  通过业务定义的一个 key 来缓存 cell 的 size，需搭配 UICollectionView 使用，一般不用你自己去 init。
 *  具体使用方式请看 UICollectionView (QMUICellSizeKeyCache) 的注释。
 */
@interface QMUICellSizeKeyCache : NSObject

/// 检查是否存在某个 key 的 size
- (BOOL)existsSizeForKey:(id<NSCopying>)key;

/// 将某个 size 缓存到指定的 key
- (void)cacheSize:(CGSize)size forKey:(id<NSCopying>)key;

/// 获取指定 key 对应的 size，如果该 key 不存在，则返回 0
- (CGSize)sizeForKey:(id<NSCopying>)key;

// 使 cache 失效，多用在 data 更新之后或 UICollectionView 的 size 发生变化的时候，但在 QMUI 里，UICollectionView 的 size 发生变化会自动更新，所以不用处理 size 变化的场景。
- (void)invalidateSizeForKey:(id<NSCopying>)key;
- (void)invalidateAllSizeCache;

@end
