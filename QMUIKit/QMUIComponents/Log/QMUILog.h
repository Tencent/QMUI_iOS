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

/// 以下是 QMUI 提供的用于代替 NSLog() 的打 log 的方法，可根据 logName、logLevel 两个维度来控制某些 log 是否要被打印，以便在调试时去掉不关注的 log。

#define QMUILog(_name, ...) [[QMUILogger sharedInstance] printLogWithFile:__FILE__ line:__LINE__ func:__FUNCTION__ logItem:[QMUILogItem logItemWithLevel:QMUILogLevelDefault name:_name logString:__VA_ARGS__]]
#define QMUILogInfo(_name, ...) [[QMUILogger sharedInstance] printLogWithFile:__FILE__ line:__LINE__ func:__FUNCTION__ logItem:[QMUILogItem logItemWithLevel:QMUILogLevelInfo name:_name logString:__VA_ARGS__]]
#define QMUILogWarn(_name, ...) [[QMUILogger sharedInstance] printLogWithFile:__FILE__ line:__LINE__ func:__FUNCTION__ logItem:[QMUILogItem logItemWithLevel:QMUILogLevelWarn name:_name logString:__VA_ARGS__]]
