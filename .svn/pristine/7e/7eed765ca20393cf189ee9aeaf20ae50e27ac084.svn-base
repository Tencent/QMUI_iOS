//
//  QMUIOrderedDictionary.m
//  qmui
//
//  Created by MoLice on 16/7/21.
//  Copyright © 2016年 QMUI Team. All rights reserved.
//

#import "QMUIOrderedDictionary.h"

@interface QMUIOrderedDictionary ()

@property(nonatomic, strong) NSMutableArray *mutableAllKeys;
@property(nonatomic, strong) NSMutableArray *mutableAllValues;
@property(nonatomic, strong) NSMutableDictionary *mutableDictionary;
@end

@implementation QMUIOrderedDictionary

- (instancetype)initWithKeysAndObjects:(id)firstKey, ... {
    if (self = [super init]) {
        self.mutableAllKeys = [[NSMutableArray alloc] init];
        self.mutableAllValues = [[NSMutableArray alloc] init];
        
        if (firstKey) {
            [self.mutableAllKeys addObject:firstKey];
            
            va_list argumentList;
            va_start(argumentList, firstKey);
            id argument;
            NSInteger i = 1;
            while ((argument = va_arg(argumentList, id))) {
                if (i % 2 == 0) {
                    [self.mutableAllKeys addObject:argument];
                } else {
                    [self.mutableAllValues addObject:argument];
                }
                i++;
            }
            va_end(argumentList);
            
            self.mutableDictionary = [[NSMutableDictionary alloc] initWithObjects:self.mutableAllValues forKeys:self.mutableAllKeys];
        }
    }
    return self;
}

- (NSUInteger)count {
    return self.mutableDictionary.count;
}

- (NSArray *)allKeys {
    return self.mutableAllKeys;
}

- (instancetype)objectForKey:(id)key {
    return [self.mutableDictionary objectForKey:key];
}

- (NSString *)description {
    return [NSString stringWithFormat:@"%@, %@", [super description], self.mutableDictionary];
}

@end
