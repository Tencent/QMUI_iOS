/**
 * Tencent is pleased to support the open source community by making QMUI_iOS available.
 * Copyright (C) 2016-2021 THL A29 Limited, a Tencent company. All rights reserved.
 * Licensed under the MIT License (the "License"); you may not use this file except in compliance with the License. You may obtain a copy of the License at
 * http://opensource.org/licenses/MIT
 * Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.
 */
//
//  UIVisualEffect+QMUITheme.h
//  QMUIKit
//
//  Created by MoLice on 2019/7/20.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class QMUIThemeManager;

@protocol QMUIDynamicEffectProtocol <NSObject>

@required

/// 获取当前 UIVisualEffect 的标记名称，仅对 QMUIThemeVisualEffect 有效，其他 class 返回 nil。
@property(nonatomic, copy, readonly) NSString *qmui_name;

/// 获取当前 UIVisualEffect 的实际 effect（返回的 effect 必定不是 dynamic image）
@property(nonatomic, strong, readonly) __kindof UIVisualEffect *qmui_rawEffect;

/// 标志当前 UIVisualEffect 对象是否为动态 effect（由 [UIVisualEffect qmui_effectWithThemeProvider:] 创建的 effect
@property(nonatomic, assign, readonly) BOOL qmui_isDynamicEffect;

@end

@interface UIVisualEffect (QMUITheme) <QMUIDynamicEffectProtocol>

/**
 生成一个动态的 UIVisualEffect 对象，每次使用该对象时都会动态根据当前的 QMUIThemeManager 主题返回对应的 effect。
 @param provider 当 UIVisualEffect 被使用时，这个 provider 会被调用，返回对应当前主题的 effect 值。请不要在这个 block 里做耗时操作。
 @return 一个动态的 UIVisualEffect 对象，被使用时才会返回实际的 effect 效果
 */
+ (UIVisualEffect *)qmui_effectWithThemeProvider:(UIVisualEffect *(^)(__kindof QMUIThemeManager *manager, __kindof NSObject<NSCopying> * _Nullable identifier, __kindof NSObject * _Nullable theme))provider;

/**
 生成一个动态的 UIVisualEffect 对象，并以 name 为其标记。每次使用该对象时都会动态根据当前的 QMUIThemeManager  主题返回对应的 effect。
 @param name 动态 UIVisualEffect 的名称，默认为 nil
 @param provider 当 UIVisualEffect 被使用时，这个 provider 会被调用，返回对应当前主题的 effect 值。请不要在这个 block 里做耗时操作。
 @return 一个动态的 UIVisualEffect 对象，被使用时才会返回实际的 effect 效果
*/
+ (UIVisualEffect *)qmui_effectWithName:(NSString * _Nullable)name
                          themeProvider:(UIVisualEffect *(^)(__kindof QMUIThemeManager *manager, __kindof NSObject<NSCopying> * _Nullable identifier, __kindof NSObject * _Nullable theme))provider;


/**
 生成一个动态的 UIVisualEffect 对象。每次使用该对象时都会动态根据当前的 QMUIThemeManager  name 和主题返回对应的 effect。
 @param managerName themeManager 的 name，用于区分不同维度的主题管理器
 @param provider 当 UIVisualEffect 被使用时，这个 provider 会被调用，返回对应当前主题的 effect 值。请不要在这个 block 里做耗时操作。
 @return 一个动态的 UIVisualEffect 对象，被使用时才会返回实际的 effect 效果
*/
+ (UIVisualEffect *)qmui_effectWithThemeManagerName:(__kindof NSObject<NSCopying> *)managerName
                                           provider:(UIVisualEffect *(^)(__kindof QMUIThemeManager *manager, __kindof NSObject<NSCopying> * _Nullable identifier, __kindof NSObject * _Nullable theme))provider;

/**
 生成一个动态的 UIVisualEffect 对象，并以 name 为其标记。每次使用该对象时都会动态根据当前的 QMUIThemeManager  name 和主题返回对应的 effect。
 @param name 动态 UIVisualEffect 的名称，默认为 nil
 @param managerName themeManager 的 name，用于区分不同维度的主题管理器
 @param provider 当 UIVisualEffect 被使用时，这个 provider 会被调用，返回对应当前主题的 effect 值。请不要在这个 block 里做耗时操作。
 @return 一个动态的 UIVisualEffect 对象，被使用时才会返回实际的 effect 效果
*/
+ (UIVisualEffect *)qmui_effectWithName:(NSString * _Nullable)name
                       themeManagerName:(__kindof NSObject<NSCopying> *)managerName
                               provider:(UIVisualEffect *(^)(__kindof QMUIThemeManager *manager, __kindof NSObject<NSCopying> * _Nullable identifier, __kindof NSObject * _Nullable theme))provider;
@end

NS_ASSUME_NONNULL_END
