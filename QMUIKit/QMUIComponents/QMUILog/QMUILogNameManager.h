/**
 * Tencent is pleased to support the open source community by making QMUI_iOS available.
 * Copyright (C) 2016-2021 THL A29 Limited, a Tencent company. All rights reserved.
 * Licensed under the MIT License (the "License"); you may not use this file except in compliance with the License. You may obtain a copy of the License at
 * http://opensource.org/licenses/MIT
 * Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.
 */

//
//  QMUILogNameManager.h
//  QMUIKit
//
//  Created by QMUI Team on 2018/1/24.
//

#import <Foundation/Foundation.h>

/// 所有 QMUILog 的 name 都会以这个 key 存储到 NSUserDefaults 里（类型为 NSDictionary<NSString *, NSNumber *> *），可通过 dictionaryForKey: 获取到所有的 name 及对应的 enabled 状态。
extern NSString * _Nonnull const QMUILoggerAllNamesKeyInUserDefaults;

/// log.name 的管理器，由它来管理每一个 name 是否可用、以及清理不需要的 name
@interface QMUILogNameManager : NSObject

/// 获取当前所有 logName，key 为 logName 名，value 为 name 的 enabled 状态，可通过 value.boolValue 读取它的值
@property(nullable, nonatomic, copy, readonly) NSDictionary<NSString *, NSNumber *> *allNames;
- (BOOL)containsLogName:(nullable NSString *)logName;
- (void)setEnabled:(BOOL)enabled forLogName:(nullable NSString *)logName;
- (BOOL)enabledForLogName:(nullable NSString *)logName;
- (void)removeLogName:(nullable NSString *)logName;
- (void)removeAllNames;
@end
