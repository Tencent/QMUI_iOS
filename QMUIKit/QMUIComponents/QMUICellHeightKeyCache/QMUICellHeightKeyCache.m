/**
 * Tencent is pleased to support the open source community by making QMUI_iOS available.
 * Copyright (C) 2016-2020 THL A29 Limited, a Tencent company. All rights reserved.
 * Licensed under the MIT License (the "License"); you may not use this file except in compliance with the License. You may obtain a copy of the License at
 * http://opensource.org/licenses/MIT
 * Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.
 */

//
//  QMUICellHeightKeyCache.m
//  QMUIKit
//
//  Created by QMUI Team on 2018/3/14.
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
