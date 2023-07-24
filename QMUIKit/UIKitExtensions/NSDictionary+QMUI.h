/**
 * Tencent is pleased to support the open source community by making QMUI_iOS available.
 * Copyright (C) 2016-2021 THL A29 Limited, a Tencent company. All rights reserved.
 * Licensed under the MIT License (the "License"); you may not use this file except in compliance with the License. You may obtain a copy of the License at
 * http://opensource.org/licenses/MIT
 * Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.
 */

//
//  NSDictionary+QMUI.h
//  QMUIKit
//
//  Created by molice on 2023/7/21.
//  Copyright © 2023 QMUI Team. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSDictionary<KeyType, ObjectType> (QMUI)

/**
*  转换字典的元素，将每个 key-value 经过 block 转换为另一个 key-value，如果希望移除该 item，可返回 nil。当所有元素都被移除时，本方法返回空的容器。
 对应 -[NSArray(QMUI) qmui_compactMapWithBlock]，是觉得没必要区分 compact 和非 compact 了。
*/
- (NSDictionary * _Nullable)qmui_mapWithBlock:(NSDictionary * _Nullable (NS_NOESCAPE^)(KeyType key, ObjectType value))block;

/**
 深度转换字典的元素，同 qmui_mapWithBlock:，但区别在于如果 object 是一个 NSDictionary，则它会递归再 map，最终把所有的 key-value 都转换一遍。
 
 @warning 面对嵌套 dictionary 时，本方法的 block 里的参数 value 有可能会传 NSDictionary 类型，但实际上你对其转换后的返回值只有 key 会被使用，value 会被丢弃。
 */
- (NSDictionary * _Nullable)qmui_deepMapWithBlock:(NSDictionary * _Nullable (NS_NOESCAPE^)(KeyType key, ObjectType value))block;

@end

NS_ASSUME_NONNULL_END
