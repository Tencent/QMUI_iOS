/**
 * Tencent is pleased to support the open source community by making QMUI_iOS available.
 * Copyright (C) 2016-2020 THL A29 Limited, a Tencent company. All rights reserved.
 * Licensed under the MIT License (the "License"); you may not use this file except in compliance with the License. You may obtain a copy of the License at
 * http://opensource.org/licenses/MIT
 * Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.
 */
//
//  QMUIThemeManagerCenter.h
//  QMUIKit
//
//  Created by MoLice on 2019/S/4.
//

#import <Foundation/Foundation.h>
#import "QMUIThemeManager.h"

NS_ASSUME_NONNULL_BEGIN

extern NSString *const QMUIThemeManagerNameDefault;

/**
 用于获取 QMUIThemeManager，具体使用请查看 QMUIThemeManager 的注释。
 */
@interface QMUIThemeManagerCenter : NSObject

@property(class, nonatomic, strong, readonly) QMUIThemeManager *defaultThemeManager;
@property(class, nonatomic, copy, readonly) NSArray<QMUIThemeManager *> *themeManagers;
+ (nullable QMUIThemeManager *)themeManagerWithName:(__kindof NSObject<NSCopying> *)name;
@end

NS_ASSUME_NONNULL_END
