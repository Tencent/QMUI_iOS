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
 *  3. 默认情况下配置表里的所有赋值都被注释，表示使用 QMUI 的默认值，你可以把你想修改的表达式取消注释，并改为想要的值即可。
 *  4. 注意如果修改了属性 A，则请搜索整个文件里所有用到 A 的地方，把那个地方的注释也打开，否则使用的是 A 在 QMUI 里的默认值，而不是你修改后的值。
 *  5. 更新 QMUIKit 的版本时，请留意 Release Log 里是否有提醒更新配置表，请尽量保持自己项目里的配置表与 QMUIKit 里的配置表一致，避免遗漏新的属性。
 */
@interface QMUIConfigurationTemplate : NSObject

+ (void)setupConfigurationTemplate;

@end
