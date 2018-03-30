//
//  QMUICellHeightKeyCache.m
//  QMUIKit
//
//  Created by MoLice on 2018/3/14.
//  Copyright © 2018年 QMUI Team. All rights reserved.
//

#import "QMUICellHeightKeyCache.h"
#import "NSNumber+QMUI.h"

@interface QMUICellHeightKeyCache ()

@property(nonatomic, strong) NSMutableDictionary<id<NSCopying>, NSNumber *> *cachedHeights;
@end

@implementation QMUICellHeightKeyCache

- (instancetype)init {
    if (self = [super init]) {
        self.cachedHeights = [NSMutableDictionary dictionary];
    }
    return self;
}

- (BOOL)existsHeightForKey:(id<NSCopying>)key {
    NSNumber *number = self.cachedHeights[key];
    return !!number;// 注意这里“拿 number 是否存在”作为条件，也即意味着高度为0也是合法的，因为 @(0) 也是一个不为 nil 的 NSNumber
}

- (void)cacheHeight:(CGFloat)height forKey:(id<NSCopying>)key {
    self.cachedHeights[key] = @(height);
}

- (CGFloat)heightForKey:(id<NSCopying>)key {
    return self.cachedHeights[key].qmui_CGFloatValue;
}

- (void)invalidateHeightForKey:(id<NSCopying>)key {
    [self.cachedHeights removeObjectForKey:key];
}

- (void)invalidateAllHeightCache {
    [self.cachedHeights removeAllObjects];
}

- (NSString *)description {
    return [NSString stringWithFormat:@"%@, cachedHeights = %@", [super description], _cachedHeights];
}

@end
