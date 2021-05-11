/**
 * Tencent is pleased to support the open source community by making QMUI_iOS available.
 * Copyright (C) 2016-2021 THL A29 Limited, a Tencent company. All rights reserved.
 * Licensed under the MIT License (the "License"); you may not use this file except in compliance with the License. You may obtain a copy of the License at
 * http://opensource.org/licenses/MIT
 * Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.
 */

//
//  QMUILogger.m
//  QMUIKit
//
//  Created by QMUI Team on 2018/1/24.
//

#import "QMUILogger.h"
#import "QMUILogNameManager.h"
#import "QMUILogItem.h"

@implementation QMUILogger

+ (instancetype)sharedInstance {
    static dispatch_once_t onceToken;
    static QMUILogger *instance = nil;
    dispatch_once(&onceToken,^{
        instance = [[super allocWithZone:NULL] init];
    });
    return instance;
}

+ (id)allocWithZone:(struct _NSZone *)zone{
    return [self sharedInstance];
}

- (instancetype)init {
    if (self = [super init]) {
        self.logNameManager = [[QMUILogNameManager alloc] init];
    }
    return self;
}

- (void)printLogWithFile:(const char *)file line:(int)line func:(const char *)func logItem:(QMUILogItem *)logItem {
    // 禁用了某个 name 则直接退出
    if (!logItem.enabled) return;
    
    NSString *fileString = [NSString stringWithFormat:@"%s", file];
    NSString *funcString = [NSString stringWithFormat:@"%s", func];
    NSString *defaultString = [NSString stringWithFormat:@"%@:%@ | %@", funcString, @(line), logItem];
    
    if ([self.delegate respondsToSelector:@selector(printQMUILogWithFile:line:func:logItem:defaultString:)]) {
        [self.delegate printQMUILogWithFile:fileString line:line func:funcString logItem:logItem defaultString:defaultString];
    } else {
//        // iOS 11 之前用替换方法的方式替换了 NSLog，所以这里就不能继续使用 NSLog 了
//        if (IS_DEBUG && IOS_VERSION_NUMBER < 110000) {
//            NSStringEncoding enc = CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingUTF8);
//            puts([defaultString cStringUsingEncoding:enc]);
//        } else {
            NSLog(@"%@", defaultString);
//        }
    }
}

@end
