/*****
 * Tencent is pleased to support the open source community by making QMUI_iOS available.
 * Copyright (C) 2016-2018 THL A29 Limited, a Tencent company. All rights reserved.
 * Licensed under the MIT License (the "License"); you may not use this file except in compliance with the License. You may obtain a copy of the License at
 * http://opensource.org/licenses/MIT
 * Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.
 *****/

//
//  QMUICellHeightKeyCache.h
//  QMUIKit
//
//  Created by QMUI Team on 2018/3/14.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

/**
 *  通过业务定义的一个 key 来缓存 cell 的高度，需搭配 UITableView 使用，一般不用你自己去 init。
 *  具体使用方式请看 UITableView (QMUICellHeightKeyCache) 的注释。
 */
@interface QMUICellHeightKeyCache : NSObject

/// 检查是否存在某个 key 的高度
- (BOOL)existsHeightForKey:(id<NSCopying>)key;

/// 将某个高度缓存到指定的 key
- (void)cacheHeight:(CGFloat)height forKey:(id<NSCopying>)key;

/// 获取指定 key 对应的高度，如果该 key 不存在，则返回 0
- (CGFloat)heightForKey:(id<NSCopying>)key;

// 使 cache 失效，多用在 data 更新之后或 UITableView 的 size 发生变化的时候，但在 QMUI 里，UITableView 的 size 发生变化会自动更新，所以不用处理 size 变化的场景。
- (void)invalidateHeightForKey:(id<NSCopying>)key;
- (void)invalidateAllHeightCache;

@end
