/**
 * Tencent is pleased to support the open source community by making QMUI_iOS available.
 * Copyright (C) 2016-2021 THL A29 Limited, a Tencent company. All rights reserved.
 * Licensed under the MIT License (the "License"); you may not use this file except in compliance with the License. You may obtain a copy of the License at
 * http://opensource.org/licenses/MIT
 * Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.
 */

//
//  NSDictionary+QMUI.m
//  QMUIKit
//
//  Created by molice on 2023/7/21.
//  Copyright © 2023 QMUI Team. All rights reserved.
//

#import "NSDictionary+QMUI.h"

@implementation NSDictionary (QMUI)

- (NSDictionary *)qmui_mapWithBlock:(NSDictionary * _Nullable (NS_NOESCAPE^)(id _Nonnull, id _Nonnull))block {
    if (!block) {
        return self;
    }
    
    NSMutableDictionary *temp = NSMutableDictionary.new;
    [self enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
        NSDictionary *mapped = block(key, obj);
        if (!mapped) {
            return;
        }
        id k = mapped.allKeys.firstObject;
        id o = mapped.allValues.firstObject;
        temp[k] = o;
    }];
    return temp.copy;
}

- (NSDictionary *)qmui_deepMapWithBlock:(NSDictionary * _Nullable (NS_NOESCAPE^)(id _Nonnull, id _Nonnull))block {
    if (!block) {
        return self;
    }
    
    NSMutableDictionary *temp = NSMutableDictionary.new;
    [self enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
        if ([obj isKindOfClass:NSDictionary.class]) {
            obj = [obj qmui_deepMapWithBlock:block];
        }
        NSDictionary *mapped = block(key, obj);
        if (!mapped) {
            return;
        }
        id k = mapped.allKeys.firstObject;
        id o = nil;
        if ([obj isKindOfClass:NSDictionary.class]) {
            o = obj;// 返回值 mapped.value 被丢弃了，实际上将 obj 作为 value
        } else {
            o = mapped.allValues.firstObject;
        }
        temp[k] = o;
    }];
    return temp.copy;
}

@end
