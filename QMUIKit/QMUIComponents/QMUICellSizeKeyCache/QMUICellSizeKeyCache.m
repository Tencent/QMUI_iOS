//
//  QMUICellSizeKeyCache.m
//  QMUIKit
//
//  Created by MoLice on 2018/3/14.
//  Copyright © 2018年 QMUI Team. All rights reserved.
//

#import "QMUICellSizeKeyCache.h"

@interface QMUICellSizeKeyCache ()

@property(nonatomic, strong) NSMutableDictionary<id<NSCopying>, NSValue *> *cachedSizes;
@end

@implementation QMUICellSizeKeyCache

- (instancetype)init {
    if (self = [super init]) {
        self.cachedSizes = [NSMutableDictionary dictionary];
    }
    return self;
}

- (BOOL)existsSizeForKey:(id<NSCopying>)key {
    NSValue *sizeValue = self.cachedSizes[key];
    return sizeValue && !CGSizeEqualToSize(sizeValue.CGSizeValue, CGSizeMake(-1, -1));
}

- (void)cacheSize:(CGSize)size forKey:(id<NSCopying>)key {
    self.cachedSizes[key] = @(size);
}

- (CGSize)sizeForKey:(id<NSCopying>)key {
    return self.cachedSizes[key].CGSizeValue;
}

- (void)invalidateSizeForKey:(id<NSCopying>)key {
    [self.cachedSizes removeObjectForKey:key];
}

- (void)invalidateAllSizeCache {
    [self.cachedSizes removeAllObjects];
}

- (NSString *)description {
    return [NSString stringWithFormat:@"%@, cachedSizes = %@", [super description], _cachedSizes];
}

@end
