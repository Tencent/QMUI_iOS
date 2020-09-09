/**
 * Tencent is pleased to support the open source community by making QMUI_iOS available.
 * Copyright (C) 2016-2020 THL A29 Limited, a Tencent company. All rights reserved.
 * Licensed under the MIT License (the "License"); you may not use this file except in compliance with the License. You may obtain a copy of the License at
 * http://opensource.org/licenses/MIT
 * Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.
 */
//
//  UIView+QMUITheme.h
//  QMUIKit
//
//  Created by MoLice on 2019/6/21.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class QMUIThemeManager;

@interface UIView (QMUITheme)

/**
 注册当前 view 里需要在主题变化时被重新设置的 property，当主题变化时，会通过 qmui_themeDidChangeByManager:identifier:theme: 来重新调用一次 self.xxx = xxx，以达到刷新界面的目的。
 @param getters 属性的 getter， 内部会根据命名规则自动转换得到 setter，再通过 performSelector 的形式调用 getter 和 setter
 */
- (void)qmui_registerThemeColorProperties:(NSArray<NSString *> *)getters;

/**
 注销通过 qmui_registerThemeColorProperties: 注册的 property
 @param getters 属性的 getter， 内部会根据命名规则自动转换得到 setter，再通过 performSelector 的形式调用 getter 和 setter
 */
- (void)qmui_unregisterThemeColorProperties:(NSArray<NSString *> *)getters;

/**
 当主题变化时这个方法会被调用，通过 registerThemeColorProperties: 方法注册的属性也会在这里被更新（所以记得要调用 super）。registerThemeColorProperties: 无法满足的需求可以重写这个方法自行实现。
 @param manager 当前的主题管理对象
 @param identifier 当前主题的标志，可自行修改参数类型为目标类型
 @param theme 当前主题对象，可自行修改参数类型为目标类型
 */
- (void)qmui_themeDidChangeByManager:(nullable QMUIThemeManager *)manager identifier:(nullable __kindof NSObject<NSCopying> *)identifier theme:(nullable __kindof NSObject *)theme NS_REQUIRES_SUPER;

@property(nonatomic, copy, nullable) void (^qmui_themeDidChangeBlock)(void);

@end

NS_ASSUME_NONNULL_END
