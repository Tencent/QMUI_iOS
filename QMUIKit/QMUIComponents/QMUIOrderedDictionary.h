//
//  QMUIOrderedDictionary.h
//  qmui
//
//  Created by MoLice on 16/7/21.
//  Copyright © 2016年 QMUI Team. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

@interface QMUIOrderedDictionary<__covariant KeyType, __covariant ObjectType> : NSObject

- (instancetype)initWithKeysAndObjects:(id)firstKey,...;

@property(readonly) NSUInteger count;
@property(nonatomic, copy, readonly) NSArray<KeyType> *allKeys;

- (void)addObject:(ObjectType)object forKey:(KeyType)key;
- (void)addObjects:(NSArray<ObjectType> *)objects forKeys:(NSArray<KeyType> *)keys;
- (void)insertObject:(ObjectType)object forKey:(KeyType)key atIndex:(NSInteger)index;
- (void)insertObjects:(NSArray<ObjectType> *)objects forKeys:(NSArray<KeyType> *)keys atIndex:(NSInteger)index;
- (void)removeObject:(ObjectType)object forKey:(KeyType)key;
- (void)removeObject:(ObjectType)object atIndex:(NSInteger)index;
- (ObjectType)objectForKey:(KeyType)key;
- (ObjectType)objectAtIndex:(NSInteger)index;

@end
