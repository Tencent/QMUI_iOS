/*****
 * Tencent is pleased to support the open source community by making QMUI_iOS available.
 * Copyright (C) 2016-2019 THL A29 Limited, a Tencent company. All rights reserved.
 * Licensed under the MIT License (the "License"); you may not use this file except in compliance with the License. You may obtain a copy of the License at
 * http://opensource.org/licenses/MIT
 * Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.
 *****/

//
//  QMUIConsole.h
//  QMUIKit
//
//  Created by MoLice on 2019/J/11.
//  Copyright © 2019 QMUI Team. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "QMUIConsoleToolbar.h"
#import "QMUIConsoleViewController.h"
#import "QMUILog+QMUIConsole.h"

NS_ASSUME_NONNULL_BEGIN

/**
 在设备屏幕上显示一个控制台，输出代码里的日志。支持搜索、按 Level/Name 过滤。
 */
@interface QMUIConsole : NSObject

+ (nonnull instancetype)sharedInstance;

/**
 打印日志到控制台

 @param level 级别分类，业务自己规定一套统一的划分方式即可，如果 nil 则默认为 @"Normal"
 @param name 日志的业务分类，例如属于某个控件、某种类型，也是自己规定一套统一的划分方式即可，如果 nil 则默认为 @"Default"
 @param logString 支持 NSString/NSAttributedString/NSObject，如果是 NSString 则默认样式由 [QMUIConsole appearance].textAttributes 控制
 */
+ (void)logWithLevel:(nullable NSString *)level name:(nullable NSString *)name logString:(id)logString;

/**
 相当于 level:@"Normal" name:@"Default" 的 log

 @param logString 支持 NSString/NSAttributedString/NSObject，如果是 NSString 则默认样式由 [QMUIConsole appearance].textAttributes 控制
 */
+ (void)log:(id)logString;

/**
 清空当前控制台内容
 */
+ (void)clear;

/**
 显示控制台。由于 QMUIConsole.showConsoleAutomatically 默认为 YES，所以只要输出 log 就会自动显示控制台，一般无需手动调用 show 方法。
 */
+ (void)show;

/**
 隐藏控制台。
 */
+ (void)hide;

/// 当打印 log 的时候自动让控制台显示出来，默认为 YES
@property(nonatomic, assign) BOOL showConsoleAutomatically;

/// 控制台的背景色
@property(nullable, nonatomic, strong) UIColor *backgroundColor UI_APPEARANCE_SELECTOR;

/// 控制台文本的默认样式
@property(nullable, nonatomic, strong) NSDictionary<NSAttributedStringKey, id> *textAttributes UI_APPEARANCE_SELECTOR;

/// log 里的时间戳的颜色
@property(nullable, nonatomic, strong) NSDictionary<NSAttributedStringKey, id> *timeAttributes UI_APPEARANCE_SELECTOR;

/// 搜索结果高亮的背景色
@property(nullable, nonatomic, strong) UIColor *searchResultHighlightedBackgroundColor UI_APPEARANCE_SELECTOR;
@end

@interface QMUIConsole (UIAppearance)

+ (nonnull instancetype)appearance;

@end

NS_ASSUME_NONNULL_END
