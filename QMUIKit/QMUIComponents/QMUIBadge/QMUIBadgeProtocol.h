/**
 * Tencent is pleased to support the open source community by making QMUI_iOS available.
 * Copyright (C) 2016-2021 THL A29 Limited, a Tencent company. All rights reserved.
 * Licensed under the MIT License (the "License"); you may not use this file except in compliance with the License. You may obtain a copy of the License at
 * http://opensource.org/licenses/MIT
 * Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.
 */

//
//  QMUIBadgeProtocol.h
//  QMUIKit
//
//  Created by MoLice on 2020/5/26.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

// TODO: molice 等废弃 qmui_badgeCenterOffset 系列接口后再删除
#import "QMUICore.h"

NS_ASSUME_NONNULL_BEGIN

@class QMUILabel;

@protocol QMUIBadgeProtocol <NSObject>

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

/// 默认 badge 的布局处于 view 右上角（x = view.width, y = -badge height），通过这个属性可以调整 badge 相对于默认原点的偏移，x 正值表示向右，y 正值表示向下。
/// 特别地，对于普通的 UITabBarItem 和 UIBarButtonItem，badge 布局相对于内部的 imageView 而不是按钮本身，如果该 item 使用了 customView 则相对于按钮本身。
@property(nonatomic, assign) CGPoint qmui_badgeOffset;

/// 横屏下使用，其他同 @c qmui_badgeOffset 。
@property(nonatomic, assign) CGPoint qmui_badgeOffsetLandscape;

/// 在这两个属性被删除之前，如果不主动设置 @c qmui_badgeOffset 和 @c qmui_badgeOffsetLandscape ，则依然使用旧的逻辑，一旦设置过两个新属性，则旧属性会失效。
@property(nonatomic, assign) CGPoint qmui_badgeCenterOffset DEPRECATED_MSG_ATTRIBUTE("QMUIBadge 不再以中心为布局参考点，请改为使用 qmui_badgeOffset");
@property(nonatomic, assign) CGPoint qmui_badgeCenterOffsetLandscape DEPRECATED_MSG_ATTRIBUTE("QMUIBadge 不再以中心为布局参考点，请改为使用 qmui_badgeOffsetLandscape");

@property(nonatomic, strong, readonly, nullable) QMUILabel *qmui_badgeLabel;


#pragma mark - UpdatesIndicator

/// 控制红点的显隐
@property(nonatomic, assign) BOOL qmui_shouldShowUpdatesIndicator;
@property(nonatomic, strong, nullable) UIColor *qmui_updatesIndicatorColor;
@property(nonatomic, assign) CGSize qmui_updatesIndicatorSize;

/// 默认红点的布局处于 view 右上角（x = view.width, y = -badge height），通过这个属性可以调整红点相对于默认原点的偏移，x 正值表示向右，y 正值表示向下。
/// 特别地，对于普通的 UITabBarItem 和 UIBarButtonItem，红点相对于内部的 imageView 布局而不是按钮本身，如果该 item 使用了 customView 则相对于按钮本身。
@property(nonatomic, assign) CGPoint qmui_updatesIndicatorOffset;

/// 横屏下使用，其他同 @c qmui_updatesIndicatorOffset 。
@property(nonatomic, assign) CGPoint qmui_updatesIndicatorOffsetLandscape;

/// 在这两个属性被删除之前，如果不主动设置 @c qmui_updatesIndicatorOffset 和 @c qmui_updatesIndicatorOffsetLandscape ，则依然使用旧的逻辑，一旦设置过两个新属性，则旧属性会失效。
@property(nonatomic, assign) CGPoint qmui_updatesIndicatorCenterOffset DEPRECATED_MSG_ATTRIBUTE("QMUIBadge 不再以中心为布局参考点，请改为使用 qmui_updatesIndicatorOffset");
@property(nonatomic, assign) CGPoint qmui_updatesIndicatorCenterOffsetLandscape DEPRECATED_MSG_ATTRIBUTE("QMUIBadge 不再以中心为布局参考点，请改为使用 qmui_updatesIndicatorOffsetLandscape");

@property(nonatomic, strong, readonly, nullable) UIView *qmui_updatesIndicatorView;

@end

NS_ASSUME_NONNULL_END
