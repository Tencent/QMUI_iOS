/*****
 * Tencent is pleased to support the open source community by making QMUI_iOS available.
 * Copyright (C) 2016-2019 THL A29 Limited, a Tencent company. All rights reserved.
 * Licensed under the MIT License (the "License"); you may not use this file except in compliance with the License. You may obtain a copy of the License at
 * http://opensource.org/licenses/MIT
 * Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.
 *****/

//
//  UITabBar+QMUI.h
//  qmui
//
//  Created by QMUI Team on 2017/2/14.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UITabBar (QMUI)

/**
 UITabBar 的背景 view，可能显示磨砂、背景图，顶部有一部分溢出到 UITabBar 外。
 
 在 iOS 10 及以后是私有的 _UIBarBackground 类。
 
 在 iOS 9 及以前是私有的 _UITabBarBackgroundView 类。
 */
@property(nonatomic, strong, readonly) UIView *qmui_backgroundView;

/**
 qmui_backgroundView 内的 subview，用于显示顶部分隔线 shadowImage，注意这个 view 是溢出到 qmui_backgroundView 外的。若 shadowImage 为 [UIImage new]，则这个 view 的高度为 0。
 */
@property(nonatomic, strong, readonly) UIImageView *qmui_shadowImageView;

@end

#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 130000

UIKIT_EXTERN API_AVAILABLE(ios(13.0), tvos(13.0)) @interface UITabBarAppearance (QMUI)

/**
 同时设置 stackedLayoutAppearance、inlineLayoutAppearance、compactInlineLayoutAppearance 三个状态下的 itemAppearance
 */
- (void)qmui_applyItemAppearanceWithBlock:(void (^)(UITabBarItemAppearance *itemAppearance))block;
@end

#endif

NS_ASSUME_NONNULL_END
