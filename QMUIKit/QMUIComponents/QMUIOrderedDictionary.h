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

- (ObjectType)objectForKey:(KeyType)key;

@end
