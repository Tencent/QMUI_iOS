/**
 * Tencent is pleased to support the open source community by making QMUI_iOS available.
 * Copyright (C) 2016-2021 THL A29 Limited, a Tencent company. All rights reserved.
 * Licensed under the MIT License (the "License"); you may not use this file except in compliance with the License. You may obtain a copy of the License at
 * http://opensource.org/licenses/MIT
 * Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.
 */

//
//  QMUIConsole.h
//  QMUIKit
//
//  Created by MoLice on 2019/J/11.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "QMUIConsoleToolbar.h"
#import "QMUIConsoleViewController.h"
#import "QMUILog+QMUIConsole.h"

NS_ASSUME_NONNULL_BEGIN

/**
 在设备屏幕上显示一个控制台，输出代码里的日志。支持搜索、按 Level/Name 过滤。用法：
 
 1. 调用 [QMUIConsole log:...] 直接打印 level 为 "Normal"、name 为 "Default" 的日志。
 2. 调用 [QMUIConsole logWithLevel:name:logString:] 打印详细日志，则在控制台里可以按照 level 和 name 分类筛选显示。
 3. 当屏幕上出现小圆钮时，点击可以打开控制台，小圆钮会移动到控制台右上角，再次点击小圆钮即可收起控制台。
 4. 如果要隐藏小圆钮，长按即可。
 
 @note 默认只在 DEBUG 下才会显示窗口，其他环境下只会打印日志但不会出现控制台界面。可通过 canShow 属性修改这个策略。
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

/// 决定控制台是否能显示出来，当值为 NO 时，即便 +show 方法被调用也不会显示控制台，默认在 DEBUG 下为 YES，其他环境下为 NO。业务项目可自行修改。
/// 这个值为 NO 也不影响日志的打印，只是不会显示出来而已。
@property(nonatomic, assign) BOOL canShow;

/// 当打印 log 的时候自动让控制台显示出来，默认为 YES，为 NO 时则只记录 log，当手动调用 +show 方法时才会出现控制台。
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
