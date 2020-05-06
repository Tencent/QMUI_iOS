/**
 * Tencent is pleased to support the open source community by making QMUI_iOS available.
 * Copyright (C) 2016-2020 THL A29 Limited, a Tencent company. All rights reserved.
 * Licensed under the MIT License (the "License"); you may not use this file except in compliance with the License. You may obtain a copy of the License at
 * http://opensource.org/licenses/MIT
 * Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.
 */

//
//  QMUILogItem.m
//  QMUIKit
//
//  Created by QMUI Team on 2018/1/24.
//

#import "QMUILogItem.h"
#import "QMUILogger.h"
#import "QMUILogNameManager.h"

@implementation QMUILogItem

+ (instancetype)logItemWithLevel:(QMUILogLevel)level name:(NSString *)name logString:(NSString *)logString, ... {
    QMUILogItem *logItem = [[QMUILogItem alloc] init];
    logItem.level = level;
    logItem.name = name;
    
    QMUILogNameManager *logNameManager = [QMUILogger sharedInstance].logNameManager;
    if ([logNameManager containsLogName:name]) {
        logItem.enabled = [logNameManager enabledForLogName:name];
    } else {
        [logNameManager setEnabled:YES forLogName:name];
        logItem.enabled = YES;
    }
    
    va_list args;
    va_start(args, logString);
    logItem.logString = [[NSString alloc] initWithFormat:logString arguments:args];
    va_end(args);
    
    return logItem;
}

- (instancetype)init {
    if (self = [super init]) {
        self.enabled = YES;
    }
    return self;
}

- (NSString *)levelDisplayString {
    switch (self.level) {
        case QMUILogLevelInfo:
            return @"QMUILogLevelInfo";
        case QMUILogLevelWarn:
            return @"QMUILogLevelWarn";
        default:
            return @"QMUILogLevelDefault";
    }
}

- (NSString *)description {
    return [NSString stringWithFormat:@"%@ | %@ | %@", self.levelDisplayString, self.name.length > 0 ? self.name : @"Default", self.logString];
}

@end
