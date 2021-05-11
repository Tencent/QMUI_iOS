/**
 * Tencent is pleased to support the open source community by making QMUI_iOS available.
 * Copyright (C) 2016-2021 THL A29 Limited, a Tencent company. All rights reserved.
 * Licensed under the MIT License (the "License"); you may not use this file except in compliance with the License. You may obtain a copy of the License at
 * http://opensource.org/licenses/MIT
 * Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.
 */

//
//  QMUIOrderedDictionary.h
//  qmui
//
//  Created by QMUI Team on 16/7/21.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/**
 一个简单实现的有序的 key-value 容器，通过 initWithKeysAndObjects: 初始化后，用下标访问即可，如 dict[0] 或 dict[key]
 */
@interface QMUIOrderedDictionary<__covariant KeyType, __covariant ObjectType> : NSObject

- (instancetype)initWithKeysAndObjects:(id)firstKey,...;

@property(readonly) NSUInteger count;
@property(nonatomic, copy, readonly) NSArray<KeyType> *allKeys;
@property(nonatomic, copy, readonly) NSArray<ObjectType> *allValues;
- (void)setObject:(ObjectType)object forKey:(KeyType)key;
- (void)addObject:(ObjectType)object forKey:(KeyType)key;
- (void)addObjects:(NSArray<ObjectType> *)objects forKeys:(NSArray<KeyType> *)keys;
- (void)insertObject:(ObjectType)object forKey:(KeyType)key atIndex:(NSInteger)index;
- (void)insertObjects:(NSArray<ObjectType> *)objects forKeys:(NSArray<KeyType> *)keys atIndex:(NSInteger)index;
- (void)removeObject:(ObjectType)object forKey:(KeyType)key;
- (void)removeObject:(ObjectType)object atIndex:(NSInteger)index;
- (nullable ObjectType)objectForKey:(KeyType)key;
- (ObjectType)objectAtIndex:(NSInteger)index;

// 支持下标的方式访问，需要声明以下两个方法
- (nullable ObjectType)objectForKeyedSubscript:(KeyType)key;
- (ObjectType)objectAtIndexedSubscript:(NSUInteger)idx;

@end

NS_ASSUME_NONNULL_END
