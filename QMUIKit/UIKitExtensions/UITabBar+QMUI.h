/**
 * Tencent is pleased to support the open source community by making QMUI_iOS available.
 * Copyright (C) 2016-2021 THL A29 Limited, a Tencent company. All rights reserved.
 * Licensed under the MIT License (the "License"); you may not use this file except in compliance with the License. You may obtain a copy of the License at
 * http://opensource.org/licenses/MIT
 * Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.
 */

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
@property(nullable, nonatomic, strong, readonly) UIView *qmui_backgroundView;

/**
 qmui_backgroundView 内的 subview，用于显示顶部分隔线 shadowImage，注意这个 view 是溢出到 qmui_backgroundView 外的。若 shadowImage 为 [UIImage new]，则这个 view 的高度为 0。
 */
@property(nullable, nonatomic, strong, readonly) UIImageView *qmui_shadowImageView;

/**
 获取 tabBar 里面的磨砂背景，具体的 view 层级是 UITabBar → _UIBarBackground → UIVisualEffectView。仅在 tabBar 的样式确定之后系统才会创建。
 */
@property(nullable, nonatomic, strong, readonly) UIVisualEffectView *qmui_effectView;

/**
 允许直接指定 tabBar 具体的磨砂样式（系统的仅在 iOS 13 及以后用 UITabBarAppearance.backgroundEffects 才可以实现）。默认为 nil，如果你没设置过这个属性，那么 nil 的行为就是维持系统的样式，但如果你主动设置过这个属性，那么后续的 nil 则表示把磨砂清空（也即可能出现背景透明的 bar）。
 @note 生效的前提是 backgroundImage、barTintColor 都为空，因为这两者的优先级都比磨砂高。
 */
@property(nullable, nonatomic, strong) UIBlurEffect *qmui_effect;

/**
 当 tabBar 展示磨砂的样式时，可以通过这个属性精准指定磨砂的前景色（可参考 CALayer(QMUI).qmui_foregroundColor），因为系统的某些 UIBlurEffectStyle 会自带前景色，且不可去掉，那种情况下你就无法得到准确的自定义前景色了（即便你试图通过设置半透明的 barTintColor 来达到前景色的效果，那也依然会叠加一层系统自带的半透明前景色）。
 */
@property(nullable, nonatomic, strong) UIColor *qmui_effectForegroundColor;
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
