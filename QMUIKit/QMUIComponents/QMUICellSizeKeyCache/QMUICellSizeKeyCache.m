/**
 * Tencent is pleased to support the open source community by making QMUI_iOS available.
 * Copyright (C) 2016-2020 THL A29 Limited, a Tencent company. All rights reserved.
 * Licensed under the MIT License (the "License"); you may not use this file except in compliance with the License. You may obtain a copy of the License at
 * http://opensource.org/licenses/MIT
 * Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.
 */

//
//  QMUICellSizeKeyCache.m
//  QMUIKit
//
//  Created by QMUI Team on 2018/3/14.
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
