/*****
 * Tencent is pleased to support the open source community by making QMUI_iOS available.
 * Copyright (C) 2016-2019 THL A29 Limited, a Tencent company. All rights reserved.
 * Licensed under the MIT License (the "License"); you may not use this file except in compliance with the License. You may obtain a copy of the License at
 * http://opensource.org/licenses/MIT
 * Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.
 *****/

//
//  UIBarItem+QMUIBadge.h
//  QMUIKit
//
//  Created by QMUI Team on 2018/6/2.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

@class QMUILabel;

/**
 *  用于在 UIBarButtonItem（通常用于 UINavigationBar 和 UIToolbar）和 UITabBarItem 上显示未读红点或者未读数。对设置的时机没有要求。所有属性在 QMUIConfigurationTemplate 配置表里均提供对应的默认值设置，如果你不使用配置表，则所有属性的默认值均为 0。
 *
 *  @note 系统对 UIBarButtonItem 和 UITabBarItem 在横竖屏下均会有不同的布局，当你使用本控件时建议分别检查横竖屏下的表现是否正确。
 */
@interface UIBarItem (QMUIBadge)


#pragma mark - Badge

/// 用数字设置未读数，0表示不显示未读数
@property(nonatomic, assign) NSUInteger qmui_badgeInteger;

/// 用字符串设置未读数，nil 表示不显示未读数
@property(nonatomic, copy, nullable) NSString *qmui_badgeString;

@property(nonatomic, strong, nullable) UIColor *qmui_badgeBackgroundColor;
@property(nonatomic, strong, nullable) UIColor *qmui_badgeTextColor;
@property(nonatomic, strong, nullable) UIFont *qmui_badgeFont;

/// 未读数字与圆圈之间的 padding，会影响最终 badge 的大小。当只有一位数字时，会取宽/高中最大的值作为最终的宽高，以保证整个 badge 是正圆。
@property(nonatomic, assign) UIEdgeInsets qmui_badgeContentEdgeInsets;

/// 默认 badge 的布局处于 item 正中心，而通过这个属性可以调整 badge 相对于默认原点的偏移，x 正值表示向右，y 正值表示向下。
/// 特别地，对于 UITabBarItem，badge 布局默认处于内部的 imageView 的正中心（而不是 item 的正中心）。
@property(nonatomic, assign) CGPoint qmui_badgeCenterOffset;

/// 默认 badge 的布局处于 item 正中心，而通过这个属性可以调整横屏模式下 badge 相对于默认原点的偏移，x 正值表示向右，y 正值表示向下。
/// 特别地，对于 UITabBarItem，badge 布局默认处于内部的 imageView 的正中心（而不是 item 的正中心）。
@property(nonatomic, assign) CGPoint qmui_badgeCenterOffsetLandscape;

@property(nonatomic, strong, readonly, nullable) QMUILabel *qmui_badgeLabel;


#pragma mark - UpdatesIndicator

/// 控制红点的显隐
@property(nonatomic, assign) BOOL qmui_shouldShowUpdatesIndicator;
@property(nonatomic, strong, nullable) UIColor *qmui_updatesIndicatorColor;
@property(nonatomic, assign) CGSize qmui_updatesIndicatorSize;

/// 默认红点的布局处于 item 正中心，而通过这个属性可以调整红点相对于默认原点的偏移，x 正值表示向右，y 正值表示向下。
/// 特别地，对于 UITabBarItem，红点布局默认处于内部的 imageView 的正中心（而不是 item 的正中心）。
@property(nonatomic, assign) CGPoint qmui_updatesIndicatorCenterOffset;

/// 默认红点的布局处于 item 正中心，而通过这个属性可以调整横屏模式下红点相对于默认原点的偏移，x 正值表示向右，y 正值表示向下。
/// 特别地，对于 UITabBarItem，红点布局默认处于内部的 imageView 的正中心（而不是 item 的正中心）。
@property(nonatomic, assign) CGPoint qmui_updatesIndicatorCenterOffsetLandscape;

@property(nonatomic, strong, readonly, nullable) UIView *qmui_updatesIndicatorView;

@end
