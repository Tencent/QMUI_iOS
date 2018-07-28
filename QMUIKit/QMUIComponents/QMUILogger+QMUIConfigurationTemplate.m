//
//  QMUILogger+QMUIConfigurationTemplate.m
//  QMUIKit
//
//  Created by MoLice on 2018/7/28.
//  Copyright © 2018年 QMUI Team. All rights reserved.
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
