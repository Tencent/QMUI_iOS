/**
 * Tencent is pleased to support the open source community by making QMUI_iOS available.
 * Copyright (C) 2016-2021 THL A29 Limited, a Tencent company. All rights reserved.
 * Licensed under the MIT License (the "License"); you may not use this file except in compliance with the License. You may obtain a copy of the License at
 * http://opensource.org/licenses/MIT
 * Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.
 */

//
//  NSRegularExpression+QMUI.m
//  QMUIKit
//
//  Created by QMUI Team on 2024/2/21.
//

#import "NSRegularExpression+QMUI.h"

@implementation NSRegularExpression (QMUI)

+ (NSRegularExpression *)qmui_cachedRegularExpressionWithPattern:(NSString *)pattern options:(NSRegularExpressionOptions)options {
    if (!pattern.length) return nil;
    
    static NSCache *cache = nil;
    if (!cache) {
        cache = [[NSCache alloc] init];
        cache.name = @"NSRegularExpression (QMUI)";
        cache.countLimit = 100;
    }
    
    NSString *key = [NSString stringWithFormat:@"%@_%@", pattern, @(options)];
    NSRegularExpression *reg = [cache objectForKey:key];
    if (!reg) {
        reg = [NSRegularExpression regularExpressionWithPattern:pattern options:options error:nil];
        if (!reg) return nil;
        [cache setObject:reg forKey:key];
    }
    return reg;
}

+ (NSRegularExpression *)qmui_cachedRegularExpressionWithPattern:(NSString *)pattern {
    return [self qmui_cachedRegularExpressionWithPattern:pattern options:NSRegularExpressionCaseInsensitive];
}

@end
