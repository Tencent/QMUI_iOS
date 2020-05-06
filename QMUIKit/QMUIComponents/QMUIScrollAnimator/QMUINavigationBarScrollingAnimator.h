/**
 * Tencent is pleased to support the open source community by making QMUI_iOS available.
 * Copyright (C) 2016-2020 THL A29 Limited, a Tencent company. All rights reserved.
 * Licensed under the MIT License (the "License"); you may not use this file except in compliance with the License. You may obtain a copy of the License at
 * http://opensource.org/licenses/MIT
 * Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.
 */

//
//  QMUINavigationBarScrollingAnimator.h
//  QMUIKit
//
//  Created by QMUI Team on 2018/O/16.
//

#import "QMUIScrollAnimator.h"

NS_ASSUME_NONNULL_BEGIN

/**
 实现通过界面上的 UIScrollView 滚动来控制顶部导航栏外观的类，导航栏外观会跟随滚动距离的变化而变化。
 
 使用方式：
 
 1. 用 init 方法初始化。
 2. 通过 scrollView 属性关联一个 UIScrollView。
 3. 修改 offsetYToStartAnimation 调整动画触发的滚动位置。
 4. 修改 distanceToStopAnimation 调整动画触发后滚动多久到达终点。
 
 @note 注意，由于在同个 UINavigationController 里的所有 viewController 的 navigationBar 都是共享的，所以如果修改了 navigationBar 的样式，需要自行处理界面切换时 navigationBar 的样式恢复。
 @note 注意，为了性能考虑，在 progress 达到 0 后再往上滚，或者 progress 达到 1 后再往下滚，都不会再触发那一系列 animationBlock。
 */
@interface QMUINavigationBarScrollingAnimator : QMUIScrollAnimator

/// 指定要关联的 UINavigationBar，若不指定，会自动寻找当前 App 可视界面上的 navigationBar
@property(nullable, nonatomic, weak) UINavigationBar *navigationBar;

/**
 contentOffset.y 到达哪个值即开始动画，默认为 0
 
 @note 注意，如果 adjustsOffsetYWithInsetTopAutomatically 为 YES，则实际计算时的值为 (-contentInset.top + offsetYToStartAnimation)，这时候 offsetYToStartAnimation = 0 则表示在列表默认的停靠位置往下拉就会触发临界点。
 */
@property(nonatomic, assign) CGFloat offsetYToStartAnimation;

/// 控制从 offsetYToStartAnimation 开始，要滚动多长的距离就打到动画结束的位置，默认为 44
@property(nonatomic, assign) CGFloat distanceToStopAnimation;

/// 传给 offsetYToStartAnimation 的值是否要自动叠加上 -contentInset.top，默认为 YES。
@property(nonatomic, assign) BOOL adjustsOffsetYWithInsetTopAutomatically;

/// 当前滚动位置对应的进度
@property(nonatomic, assign, readonly) float progress;

/**
 如果为 NO，则当 progress 的值不再变化（例如达到 0 后继续往上滚动，或者达到 1 后继续往下滚动）时，就不会再触发动画，从而提升性能。
 
 如果为 YES，则任何时候只要有滚动产生，动画就会被触发，适合运用到类似 Plain Style 的 UITableView 里在滚动时也要适配停靠的 sectionHeader 的场景（因为需要不断计算当前正在停靠的 sectionHeader 是哪一个）。
 
 默认为 NO
 */
@property(nonatomic, assign) BOOL continuous;

/**
 用于控制不同滚动位置下的表现，总的动画 block，如果定义了这个，则滚动时不会再调用后面那几个 block
 @param animator 当前的 animator 对象
 @param progress 当前滚动位置处于 offsetYToStartAnimation 到 (offsetYToStartAnimation + distanceToStopAnimation) 之间的哪个进度
 */
@property(nullable, nonatomic, copy) void (^animationBlock)(QMUINavigationBarScrollingAnimator * _Nonnull animator, float progress);

/**
 返回不同滚动位置下对应的背景图
 @param animator 当前的 animator 对象
 @param progress 当前滚动位置处于 offsetYToStartAnimation 到 (offsetYToStartAnimation + distanceToStopAnimation) 之间的哪个进度
 */
@property(nullable, nonatomic, copy) UIImage * (^backgroundImageBlock)(QMUINavigationBarScrollingAnimator * _Nonnull animator, float progress);

/**
 返回不同滚动位置下对应的导航栏底部分隔线的图片
 @param animator 当前的 animator 对象
 @param progress 当前滚动位置处于 offsetYToStartAnimation 到 (offsetYToStartAnimation + distanceToStopAnimation) 之间的哪个进度
 */
@property(nullable, nonatomic, copy) UIImage * (^shadowImageBlock)(QMUINavigationBarScrollingAnimator * _Nonnull animator, float progress);

/**
 返回不同滚动位置下对应的导航栏的 tintColor
 @param animator 当前的 animator 对象
 @param progress 当前滚动位置处于 offsetYToStartAnimation 到 (offsetYToStartAnimation + distanceToStopAnimation) 之间的哪个进度
 */
@property(nullable, nonatomic, copy) UIColor * (^tintColorBlock)(QMUINavigationBarScrollingAnimator * _Nonnull animator, float progress);

/**
 返回不同滚动位置下对应的导航栏的 titleView tintColor
 @param animator 当前的 animator 对象
 @param progress 当前滚动位置处于 offsetYToStartAnimation 到 (offsetYToStartAnimation + distanceToStopAnimation) 之间的哪个进度
 */
@property(nullable, nonatomic, copy) UIColor * (^titleViewTintColorBlock)(QMUINavigationBarScrollingAnimator * _Nonnull animator, float progress);

/**
 返回不同滚动位置下对应的状态栏样式
 @param animator 当前的 animator 对象
 @param progress 当前滚动位置处于 offsetYToStartAnimation 到 (offsetYToStartAnimation + distanceToStopAnimation) 之间的哪个进度
 @warning 需在项目的 Info.plist 文件内设置字段 “View controller-based status bar appearance” 的值为 NO 才能生效，如果不设置，或者值为 YES，则请自行通过系统提供的 - preferredStatusBarStyle 方法来实现，statusbarStyleBlock 无效
 */
@property(nullable, nonatomic, copy) UIStatusBarStyle (^statusbarStyleBlock)(QMUINavigationBarScrollingAnimator * _Nonnull animator, float progress);

/**
 返回不同滚动位置下对应的导航栏的 barTintColor
 @param animator 当前的 animator 对象
 @param progress 当前滚动位置处于 offsetYToStartAnimation 到 (offsetYToStartAnimation + distanceToStopAnimation) 之间的哪个进度
 */
@property(nonatomic, copy) UIColor * (^barTintColorBlock)(QMUINavigationBarScrollingAnimator * _Nonnull animator, float progress);
@end

NS_ASSUME_NONNULL_END
