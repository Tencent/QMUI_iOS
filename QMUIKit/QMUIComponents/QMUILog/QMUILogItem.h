/**
 * Tencent is pleased to support the open source community by making QMUI_iOS available.
 * Copyright (C) 2016-2020 THL A29 Limited, a Tencent company. All rights reserved.
 * Licensed under the MIT License (the "License"); you may not use this file except in compliance with the License. You may obtain a copy of the License at
 * http://opensource.org/licenses/MIT
 * Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.
 */

//
//  QMUILogItem.h
//  QMUIKit
//
//  Created by QMUI Team on 2018/1/24.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, QMUILogLevel) {
    QMUILogLevelDefault,    // 当使用 QMUILog() 时使用的等级
    QMUILogLevelInfo,       // 当使用 QMUILogInfo() 时使用的等级，比 QMUILogLevelDefault 要轻量，适用于一些无关紧要的信息
    QMUILogLevelWarn        // 当使用 QMUILogWarn() 时使用的等级，最重，适用于一些异常或者严重错误的场景
};

/// 每一条 QMUILog 日志都以 QMUILogItem 的形式包装起来
@interface QMUILogItem : NSObject

/// 日志的等级，可通过 QMUIConfigurationTemplate 配置表控制全局每个 level 是否可用
@property(nonatomic, assign) QMUILogLevel level;
@property(nonatomic, copy, readonly) NSString *levelDisplayString;

/// 可利用 name 字段为日志分类，QMUILogNameManager 可全局控制某一个 name 是否可用
@property(nullable, nonatomic, copy) NSString *name;

/// 日志的内容
@property(nonatomic, copy) NSString *logString;

/// 当前 logItem 对应的 name 是否可用，可通过 QMUILogNameManager 控制，默认为 YES
@property(nonatomic, assign) BOOL enabled;

+ (nonnull instancetype)logItemWithLevel:(QMUILogLevel)level name:(nullable NSString *)name logString:(nonnull NSString *)logString, ... NS_FORMAT_FUNCTION(3, 4);
@end

NS_ASSUME_NONNULL_END
