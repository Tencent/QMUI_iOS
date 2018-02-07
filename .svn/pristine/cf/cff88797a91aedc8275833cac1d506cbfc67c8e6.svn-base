//
//  QMUILogger.h
//  QMUIKit
//
//  Created by MoLice on 2018/1/24.
//  Copyright © 2018年 QMUI Team. All rights reserved.
//

#import <Foundation/Foundation.h>

@class QMUILogNameManager;
@class QMUILogItem;

@protocol QMUILoggerDelegate <NSObject>

@optional

/**
 *  当每一个 enabled 的 QMUILog 被使用时都会走到这里，可以由业务自行决定要如何处理这些 log，如果没实现这个方法，默认用 NSLog() 打印内容
 *  @param file 当前的文件的本地完整路径，可通过 file.lastPathComponent 获取文件名
 *  @param line 当前 log 命令在该文件里的代码行数
 *  @param func 当前 log 命令所在的方法名
 *  @param logItem 当前 log 命令对应的 QMUILogItem，可得知该 log 的 level
 *  @param defaultString QMUI 默认拼好的 log 内容
 */
- (void)printQMUILogWithFile:(nonnull NSString *)file line:(int)line func:(nullable NSString *)func logItem:(nullable QMUILogItem *)logItem defaultString:(nullable NSString *)defaultString;

/**
 *  当某个 logName 的 enabled 发生变化时，通知到 delegate。注意如果是新创建某个 logName 也会走到这里。
 *  @param logName 变化的 logName
 *  @param enabled 变化后的值
 */
- (void)QMUILogName:(nonnull NSString *)logName didChangeEnabled:(BOOL)enabled;

/**
 *  某个 logName 被删除时通知到 delegate
 *  @param logName 被删除的 logName
 */
- (void)QMUILogNameDidRemove:(nonnull NSString *)logName;

@end

@interface QMUILogger : NSObject

@property(nullable, nonatomic, weak) id<QMUILoggerDelegate> delegate;
@property(nonnull, nonatomic, strong) QMUILogNameManager *logNameManager;

+ (nonnull instancetype)sharedInstance;
- (void)printLogWithFile:(nullable const char *)file line:(int)line func:(nonnull const char *)func logItem:(nullable QMUILogItem *)logItem;
@end
