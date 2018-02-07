//
//  QMUIConfigurationTemplate.h
//
//  Created by QQMail on 15/3/29.
//  Copyright (c) 2015年 QMUI Team. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 *  QMUIConfigurationTemplate 是一份配置表，用于配合 QMUIKit 来管理整个 App 的全局样式，使用方式如下：
 *  1. 在 QMUI 项目代码的文件夹里找到 QMUIConfigurationTemplate 目录，把里面所有文件复制到自己项目里。
 *  2. 在自己项目的 AppDelegate 里 #import "QMUIConfigurationTemplate.h"，然后在 application:didFinishLaunchingWithOptions: 里调用 [QMUIConfigurationTemplate setupConfigurationTemplate]，即可让配置表生效。
 *  3. 更新 QMUIKit 的版本时，请留意 Release Log 里是否有提醒更新配置表，请尽量保持自己项目里的配置表与 QMUIKit 里的配置表一致，避免遗漏新的属性。
 *
 *  @warning 请不要在 + load 方法里调用 QMUIConfigurationTemplate 或 QMUIConfigurationMacros 提供的宏，那个时机太早，可能导致 crash
 */
@interface QMUIConfigurationTemplate : NSObject

+ (void)setupConfigurationTemplate;

@end
