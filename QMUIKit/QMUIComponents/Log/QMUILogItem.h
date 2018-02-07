//
//  QMUILogItem.h
//  QMUIKit
//
//  Created by MoLice on 2018/1/24.
//  Copyright © 2018年 QMUI Team. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, QMUILogLevel) {
    QMUILogLevelDefault,    // 当使用 QMUILog() 时使用的等级
    QMUILogLevelInfo,       // 当使用 QMUILogInfo() 时使用的等级，比 QMUILogLevelDefault 要轻量，适用于一些无关紧要的信息
    QMUILogLevelWarn        // 当使用 QMUILogWarn() 时使用的等级，最重，适用于一些异常或者严重错误的场景
};

/// 每一条 QMUILog 日志都以 QMUILogItem 的形式包装起来
@interface QMUILogItem : NSObject

/// 日志的等级，可通过 QMUIConfigurationTemplate 配置表控制全局每个 level 是否可用
@property(nonatomic, assign) QMUILogLevel level;

/// 可利用 name 字段为日志分类，QMUILogNameManager 可全局控制某一个 name 是否可用
@property(nullable, nonatomic, copy) NSString *name;

/// 日志的内容
@property(nonnull, nonatomic, copy) NSString *logString;

/// 当前 logItem 对应的 name 是否可用，可通过 QMUILogNameManager 控制，默认为 YES
@property(nonatomic, assign) BOOL enabled;

+ (nonnull instancetype)logItemWithLevel:(QMUILogLevel)level name:(nullable NSString *)name logString:(nonnull NSString *)logString, ... NS_FORMAT_FUNCTION(3, 4);
@end
