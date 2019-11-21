/*****
 * Tencent is pleased to support the open source community by making QMUI_iOS available.
 * Copyright (C) 2016-2019 THL A29 Limited, a Tencent company. All rights reserved.
 * Licensed under the MIT License (the "License"); you may not use this file except in compliance with the License. You may obtain a copy of the License at
 * http://opensource.org/licenses/MIT
 * Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.
 *****/
//
//  UIColor+QMUITheme.h
//  QMUIKit
//
//  Created by MoLice on 2019/J/20.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class QMUIThemeManager;

@interface UIColor (QMUITheme)

/**
 生成一个动态的 color 对象，每次使用该颜色时都会动态根据当前的 QMUIThemeManager 主题返回对应的颜色。
 @param provider 当 color 被使用时，这个 provider 会被调用，返回对应当前主题的 color 值。请不要在这个 block 里做耗时操作。
 @return 当前主题下的实际色值，由 provider 返回
 */
+ (UIColor *)qmui_colorWithThemeProvider:(UIColor *(^)(__kindof QMUIThemeManager *manager, __kindof NSObject<NSCopying> * _Nullable identifier, __kindof NSObject * _Nullable theme))provider;

/**
 生成一个动态的 color 对象，每次使用该颜色时都会动态根据当前的 QMUIThemeManager name 和主题返回对应的颜色。
 @param name themeManager 的 name，用于区分不同维度的主题管理器
 @param provider 当 color 被使用时，这个 provider 会被调用，返回对应当前主题的 color 值。请不要在这个 block 里做耗时操作。
 @return 当前主题下的实际色值，由 provider 返回
*/
+ (UIColor *)qmui_colorWithThemeManagerName:(__kindof NSObject<NSCopying> *)name provider:(UIColor *(^)(__kindof QMUIThemeManager *manager, __kindof NSObject<NSCopying> * _Nullable identifier, __kindof NSObject * _Nullable theme))provider;

@end

NS_ASSUME_NONNULL_END
