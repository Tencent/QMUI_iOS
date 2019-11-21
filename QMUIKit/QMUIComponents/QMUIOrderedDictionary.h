/*****
 * Tencent is pleased to support the open source community by making QMUI_iOS available.
 * Copyright (C) 2016-2019 THL A29 Limited, a Tencent company. All rights reserved.
 * Licensed under the MIT License (the "License"); you may not use this file except in compliance with the License. You may obtain a copy of the License at
 * http://opensource.org/licenses/MIT
 * Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.
 *****/

//
//  QMUIOrderedDictionary.h
//  qmui
//
//  Created by QMUI Team on 16/7/21.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

@interface QMUIOrderedDictionary<__covariant KeyType, __covariant ObjectType> : NSObject

- (instancetype)initWithKeysAndObjects:(id)firstKey,...;

@property(readonly) NSUInteger count;
@property(nonatomic, copy, readonly) NSArray<KeyType> *allKeys;

- (void)setObject:(ObjectType)object forKey:(KeyType)key;
- (void)addObject:(ObjectType)object forKey:(KeyType)key;
- (void)addObjects:(NSArray<ObjectType> *)objects forKeys:(NSArray<KeyType> *)keys;
- (void)insertObject:(ObjectType)object forKey:(KeyType)key atIndex:(NSInteger)index;
- (void)insertObjects:(NSArray<ObjectType> *)objects forKeys:(NSArray<KeyType> *)keys atIndex:(NSInteger)index;
- (void)removeObject:(ObjectType)object forKey:(KeyType)key;
- (void)removeObject:(ObjectType)object atIndex:(NSInteger)index;
- (ObjectType)objectForKey:(KeyType)key;
- (ObjectType)objectAtIndex:(NSInteger)index;

@end
