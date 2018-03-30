//
//  QMUILogger.m
//  QMUIKit
//
//  Created by MoLice on 2018/1/24.
//  Copyright © 2018年 QMUI Team. All rights reserved.
//

#import "QMUILogger.h"
#import "QMUILogNameManager.h"
#import "QMUILogItem.h"
#import "QMUICore.h"

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
    
    // 不同级别的 log 可通过配置表的开关来控制是否要输出
    if (logItem.level == QMUILogLevelDefault && !ShouldPrintDefaultLog) return;
    if (logItem.level == QMUILogLevelInfo && !ShouldPrintInfoLog) return;
    if (logItem.level == QMUILogLevelWarn && !ShouldPrintWarnLog) return;
    
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
