/**
 * Tencent is pleased to support the open source community by making QMUI_iOS available.
 * Copyright (C) 2016-2020 THL A29 Limited, a Tencent company. All rights reserved.
 * Licensed under the MIT License (the "License"); you may not use this file except in compliance with the License. You may obtain a copy of the License at
 * http://opensource.org/licenses/MIT
 * Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.
 */
//
//  QMUIConsoleViewController.h
//  QMUIKit
//
//  Created by MoLice on 2019/J/11.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "QMUICommonViewController.h"

NS_ASSUME_NONNULL_BEGIN

@class QMUIButton;
@class QMUITextView;
@class QMUIConsoleToolbar;

@interface QMUIConsoleViewController : QMUICommonViewController

@property(nonatomic, strong, readonly) QMUIButton *popoverButton;
@property(nonatomic, strong, readonly) QMUITextView *textView;
@property(nonatomic, strong, readonly) QMUIConsoleToolbar *toolbar;
@property(nonatomic, strong, readonly) NSDateFormatter *dateFormatter;

@property(nonatomic, strong) UIColor *backgroundColor;

- (void)logWithLevel:(nullable NSString *)level name:(nullable NSString *)name logString:(id)logString;
- (void)log:(id)logString;
- (void)clear;
@end

NS_ASSUME_NONNULL_END
