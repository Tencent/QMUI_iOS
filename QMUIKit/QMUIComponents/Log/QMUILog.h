//
//  QMUILog.h
//  QMUIKit
//
//  Created by MoLice on 2018/1/22.
//  Copyright © 2018年 QMUI Team. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "QMUILogItem.h"
#import "QMUILogNameManager.h"
#import "QMUILogger.h"
#import <stdio.h>

/// 以下是 QMUI 提供的用于代替 NSLog() 的打 log 的方法，可根据 logName、logLevel 两个维度来控制某些 log 是否要被打印，以便在调试时去掉不关注的 log。

#define QMUILog(_name, ...) [[QMUILogger sharedInstance] printLogWithFile:__FILE__ line:__LINE__ func:__FUNCTION__ logItem:[QMUILogItem logItemWithLevel:QMUILogLevelDefault name:_name logString:__VA_ARGS__]]
#define QMUILogInfo(_name, ...) [[QMUILogger sharedInstance] printLogWithFile:__FILE__ line:__LINE__ func:__FUNCTION__ logItem:[QMUILogItem logItemWithLevel:QMUILogLevelInfo name:_name logString:__VA_ARGS__]]
#define QMUILogWarn(_name, ...) [[QMUILogger sharedInstance] printLogWithFile:__FILE__ line:__LINE__ func:__FUNCTION__ logItem:[QMUILogItem logItemWithLevel:QMUILogLevelWarn name:_name logString:__VA_ARGS__]]

//#ifdef DEBUG
//
//// iOS 11 之前用真正的方法替换去实现拦截 NSLog 的功能，iOS 11 之后这种方法失效了，所以只能用宏定义的方式覆盖 NSLog。这也就意味着在 iOS 11 下一些如果某些代码编译时机比 QMUI 早，则这些代码里的 NSLog 是无法被替换为 QMUILog 的
//extern void _NSSetLogCStringFunction(void (*)(const char *string, unsigned length, BOOL withSyslogBanner));
//static void PrintNSLogMessage(const char *string, unsigned length, BOOL withSyslogBanner) {
//    QMUILog(@"NSLog", @"%s", string);
//}
//
//static void HackNSLog(void) __attribute__((constructor));
//static void HackNSLog(void) {
//    _NSSetLogCStringFunction(PrintNSLogMessage);
//}
//
//#define NSLog(...) QMUILog(@"NSLog", __VA_ARGS__)// iOS 11 以后真正生效的是这一句
//#endif
