/*****
 * Tencent is pleased to support the open source community by making QMUI_iOS available.
 * Copyright (C) 2016-2019 THL A29 Limited, a Tencent company. All rights reserved.
 * Licensed under the MIT License (the "License"); you may not use this file except in compliance with the License. You may obtain a copy of the License at
 * http://opensource.org/licenses/MIT
 * Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.
 *****/

//
//  UINavigationBar+QMUI.h
//  QMUIKit
//
//  Created by QMUI Team on 2018/O/8.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UINavigationBar (QMUI)

/**
 UINavigationBar 的背景 view，可能显示磨砂、背景图，顶部有一部分溢出到 UINavigationBar 外。
 
 在 iOS 10 及以后是私有的 _UIBarBackground 类。
 
 在 iOS 9 及以前是私有的 _UINavigationBarBackground 类。
 */
@property(nonatomic, strong, readonly) UIView *qmui_backgroundView;

/**
 qmui_backgroundView 内显示实际背景的 view，可能是磨砂或者背景图片。
 
 在 iOS 10 及以后，该 view 为 qmui_backgroundView 的 subview，当显示磨砂时是一个 UIVisualEffectView，当显示背景图时是一个 UIImageView。
 
 在 iOS 9 及以前，如果显示磨砂，该 view 为 qmui_backgroundView 的 subview，是一个 _UIBackdropView，如果显示背景图，则返回 qmui_backgroundView 自身，因为 _UINavigationBarBackground 本身就是一个 UIImageView。
 
 @warning 如果要以 view 的方式去修改 UINavigationBar 的背景，由于不同的 iOS 版本，qmui_shadowImageView 和 qmui_backgroundContentView 的层级关系不同，所以为了效果的统一，建议这种情况下操作 qmui_backgroundView 会好过于操作 qmui_backgroundContentView。
 */
@property(nonatomic, strong, readonly) __kindof UIView *qmui_backgroundContentView;

/**
 qmui_backgroundView 内的 subview，用于显示底部分隔线 shadowImage，注意这个 view 是溢出到 qmui_backgroundView 外的。若 shadowImage 为 [UIImage new]，则这个 view 的高度为 0。
 */
@property(nonatomic, strong, readonly) UIImageView *qmui_shadowImageView;

@end

NS_ASSUME_NONNULL_END
