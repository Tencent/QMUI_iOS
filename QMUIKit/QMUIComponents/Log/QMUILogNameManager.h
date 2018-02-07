//
//  QMUILogNameManager.h
//  QMUIKit
//
//  Created by MoLice on 2018/1/24.
//  Copyright © 2018年 QMUI Team. All rights reserved.
//

#import <Foundation/Foundation.h>

/// 所有 QMUILog 的 name 都会以这个 key 存储到 NSUserDefaults 里（类型为 NSDictionary<NSString *, NSNumber *> *），可通过 dictionaryForKey: 获取到所有的 name 及对应的 enabled 状态。
extern NSString * _Nonnull const QMUILoggerAllNamesKeyInUserDefaults;

/// log.name 的管理器，由它来管理每一个 name 是否可用、以及清理不需要的 name
@interface QMUILogNameManager : NSObject

/// 获取当前所有 logName，key 为 logName 名，value 为 name 的 enabled 状态，可通过 value.boolValue 读取它的值
@property(nullable, nonatomic, copy, readonly) NSDictionary<NSString *, NSNumber *> *allNames;
- (BOOL)containsLogName:(nullable NSString *)logName;
- (void)setEnabled:(BOOL)enabled forLogName:(nullable NSString *)logName;
- (BOOL)enabledForLogName:(nullable NSString *)logName;
- (void)removeLogName:(nullable NSString *)logName;
- (void)removeAllNames;
@end
