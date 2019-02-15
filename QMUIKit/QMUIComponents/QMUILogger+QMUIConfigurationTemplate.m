/*****
 * Tencent is pleased to support the open source community by making QMUI_iOS available.
 * Copyright (C) 2016-2019 THL A29 Limited, a Tencent company. All rights reserved.
 * Licensed under the MIT License (the "License"); you may not use this file except in compliance with the License. You may obtain a copy of the License at
 * http://opensource.org/licenses/MIT
 * Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.
 *****/

//
//  QMUILogger+QMUIConfigurationTemplate.m
//  QMUIKit
//
//  Created by QMUI Team on 2018/7/28.
//

#import "QMUILogger+QMUIConfigurationTemplate.h"
#import "QMUICore.h"

@implementation QMUILogger (QMUIConfigurationTemplate)

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        ExchangeImplementations([self class], @selector(printLogWithFile:line:func:logItem:), @selector(qmuiconfig_printLogWithFile:line:func:logItem:));
    });
}

- (void)qmuiconfig_printLogWithFile:(nullable const char *)file line:(int)line func:(nonnull const char *)func logItem:(nullable QMUILogItem *)logItem {
    // 不同级别的 log 可通过配置表的开关来控制是否要输出
    if (logItem.level == QMUILogLevelDefault && !ShouldPrintDefaultLog) return;
    if (logItem.level == QMUILogLevelInfo && !ShouldPrintInfoLog) return;
    if (logItem.level == QMUILogLevelWarn && !ShouldPrintWarnLog) return;
    
    [self qmuiconfig_printLogWithFile:file line:line func:func logItem:logItem];
}

@end
