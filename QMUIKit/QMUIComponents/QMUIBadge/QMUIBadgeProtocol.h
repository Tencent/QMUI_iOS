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

NS_ASSUME_NONNULL_BEGIN

@protocol QMUIBadgeProtocol <NSObject>

#pragma mark - Badge

/// 用数字设置未读数，0表示不显示未读数。
/// @note 仅当 qmui_badgeView 为 UILabel 及其子类时才会自动设置到 qmui_badgeView 上。
@property(nonatomic, assign) NSUInteger qmui_badgeInteger;

/// 用字符串设置未读数，nil 表示不显示未读数
/// @note 仅当 qmui_badgeView 为 UILabel 及其子类时才会自动设置到 qmui_badgeView 上。
@property(nonatomic, copy, nullable) NSString *qmui_badgeString;

@property(nonatomic, strong, nullable) UIColor *qmui_badgeBackgroundColor;

/// 未读数的文字颜色
/// @note 仅当 qmui_badgeView 为 UILabel 及其子类时才会自动设置到 qmui_badgeView 上。
@property(nonatomic, strong, nullable) UIColor *qmui_badgeTextColor;

/// 未读数的字体
/// @note 仅当 qmui_badgeView 为 UILabel 及其子类时才会自动设置到 qmui_badgeView 上。
@property(nonatomic, strong, nullable) UIFont *qmui_badgeFont;

/// 未读数字与圆圈之间的 padding，会影响最终 badge 的大小。当只有一位数字时，会取宽/高中最大的值作为最终的宽高，以保证整个 badge 是正圆。
/// /// @note 仅当 qmui_badgeView 为 QMUILabel 及其子类时才会自动设置到 qmui_badgeView 上。
@property(nonatomic, assign) UIEdgeInsets qmui_badgeContentEdgeInsets;

/// 默认 badge 的布局处于 view 右上角（x = view.width, y = -badge height），通过这个属性可以调整 badge 相对于默认原点的偏移，x 正值表示向右，y 正值表示向下。
/// 特别地，对于普通的 UITabBarItem 和 UIBarButtonItem，badge 布局相对于内部的 imageView 而不是按钮本身，如果该 item 使用了 customView 则相对于按钮本身。
@property(nonatomic, assign) CGPoint qmui_badgeOffset;

/// 横屏下使用，其他同 @c qmui_badgeOffset 。
@property(nonatomic, assign) CGPoint qmui_badgeOffsetLandscape;

/// 未读数的 view，默认是 QMUIBadgeLabel，也可设置为自定义的 view。自定义 view 如果是 UILabel 类型则内部会自动为其设置 text、textColor，但如果是其他类型的 view 则需要业务自行处理。
@property(nonatomic, strong, nullable) __kindof UIView *qmui_badgeView;

/// badgeView 布局完成后的回调。因为 badgeView 必定在当前 view 的 layoutSubviews 执行完之后才布局，所以业务很难在自己的 layoutSubviews 里重新调整 badgeView 的布局，所以提供一个 block。
@property(nonatomic, copy, nullable) void (^qmui_badgeViewDidLayoutBlock)(__kindof UIView *aView, __kindof UIView *aBadgeView);


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

/// 未读红点的 view，支持设置为自定义 view。
@property(nonatomic, strong, nullable) __kindof UIView *qmui_updatesIndicatorView;

/// updatesIndicatorView 布局完成后的回调。因为 updatesIndicatorView 必定在当前 view 的 layoutSubviews 执行完之后才布局，所以业务很难在自己的 layoutSubviews 里重新调整 updatesIndicatorView 的布局，所以提供一个 block。
@property(nonatomic, copy, nullable) void (^qmui_updatesIndicatorViewDidLayoutBlock)(__kindof UIView *aView, __kindof UIView *aUpdatesIndicatorView);

@end

NS_ASSUME_NONNULL_END
