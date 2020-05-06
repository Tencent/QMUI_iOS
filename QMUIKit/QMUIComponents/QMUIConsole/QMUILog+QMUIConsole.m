/**
 * Tencent is pleased to support the open source community by making QMUI_iOS available.
 * Copyright (C) 2016-2020 THL A29 Limited, a Tencent company. All rights reserved.
 * Licensed under the MIT License (the "License"); you may not use this file except in compliance with the License. You may obtain a copy of the License at
 * http://opensource.org/licenses/MIT
 * Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.
 */

//
//  QMUILog+QMUIConsole.m
//  QMUIKit
//
//  Created by MoLice on 2019/J/15.
//

#import "QMUILog+QMUIConsole.h"
#import "QMUIConsole.h"
#import "QMUICore.h"

@implementation QMUILogger (QMUIConsole)

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        OverrideImplementation([QMUILogger class], @selector(printLogWithFile:line:func:logItem:), ^id(__unsafe_unretained Class originClass, SEL originCMD, IMP (^originalIMPProvider)(void)) {
            return ^(QMUILogger *selfObject, const char *file, int line, const char *func, QMUILogItem *logItem) {
                
                // call super
                void (*originSelectorIMP)(id, SEL, const char *, int, const char *, QMUILogItem *);
                originSelectorIMP = (void (*)(id, SEL, const char *, int, const char *, QMUILogItem *))originalIMPProvider();
                originSelectorIMP(selfObject, originCMD, file, line, func, logItem);
                
                if (!QMUICMIActivated || !ShouldPrintQMUIWarnLogToConsole) return;
                if (!logItem.enabled) return;
                if (logItem.level != QMUILogLevelWarn) return;
                
                NSString *funcString = [NSString stringWithFormat:@"%s", func];
                NSString *defaultString = [NSString stringWithFormat:@"%@:%@ | %@", funcString, @(line), logItem];
                [QMUIConsole logWithLevel:logItem.levelDisplayString name:logItem.name logString:defaultString];
            };
        });
    });
}

@end
