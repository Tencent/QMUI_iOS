//
//  QMUILogItem.m
//  QMUIKit
//
//  Created by MoLice on 2018/1/24.
//  Copyright © 2018年 QMUI Team. All rights reserved.
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
    return [NSString stringWithFormat:@"%@ | %@ | %@", self.levelDisplayString, self.name.length > 0 ? self.name : @"NoName", self.logString];
}

@end
