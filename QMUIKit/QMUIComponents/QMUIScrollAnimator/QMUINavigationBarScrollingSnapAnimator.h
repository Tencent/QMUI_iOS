/**
 * Tencent is pleased to support the open source community by making QMUI_iOS available.
 * Copyright (C) 2016-2021 THL A29 Limited, a Tencent company. All rights reserved.
 * Licensed under the MIT License (the "License"); you may not use this file except in compliance with the License. You may obtain a copy of the License at
 * http://opensource.org/licenses/MIT
 * Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.
 */

//
//  QMUINavigationBarScrollingSnapAnimator.h
//  QMUIKit
//
//  Created by QMUI Team on 2018/S/30.
//

#import "QMUIScrollAnimator.h"

NS_ASSUME_NONNULL_BEGIN

/**
 实现通过界面上的 UIScrollView 滚动来控制顶部导航栏外观的类，当滚动到某个位置时，即触发导航栏外观的变化。
 
 使用方式：
 
 1. 用 init 方法初始化。
 2. 通过 scrollView 属性关联一个 UIScrollView。
 3. 修改 offsetYToStartAnimation 调整动画触发的滚动位置。
 
 @note 注意，由于在同个 UINavigationController 里的所有 viewController 的 navigationBar 都是共享的，所以如果修改了 navigationBar 的样式，需要自行处理界面切换时 navigationBar 的样式恢复。
 */
@interface QMUINavigationBarScrollingSnapAnimator : QMUIScrollAnimator

/// 指定要关联的 UINavigationBar，若不指定，会自动寻找当前 App 可视界面上的 navigationBar
@property(nonatomic, weak) UINavigationBar *navigationBar;

/**
 contentOffset.y 到达哪个值即开始动画，默认为 0。
 
 @note 注意，如果 adjustsOffsetYWithInsetTopAutomatically 为 YES，则实际计算时的值为 (-contentInset.top + offsetYToStartAnimation)，这时候 offsetYToStartAnimation = 0 则表示在列表默认的停靠位置往下拉就会触发临界点。
 */
@property(nonatomic, assign) CGFloat offsetYToStartAnimation;

/// 传给 offsetYToStartAnimation 的值是否要自动叠加上 -contentInset.top，默认为 YES。
@property(nonatomic, assign) BOOL adjustsOffsetYWithInsetTopAutomatically;

/**
 当滚动到触发位置时，可在 block 里执行动画
 @param animator 当前的 animator 对象
 @param offsetYReached 是否已经过了临界点（也即 offsetYToStartAnimation）
 */
@property(nonatomic, copy) void (^animationBlock)(QMUINavigationBarScrollingSnapAnimator * _Nonnull animator, BOOL offsetYReached);

/**
 是否已经过了临界点（也即 offsetYToStartAnimation）
 */
@property(nonatomic, assign, readonly) BOOL offsetYReached;

/**
 如果为 NO，则当 offsetYReached 的值不再变化（例如 YES 后继续往下滚动，或者 NO 后继续往上滚动）时，就不会再触发动画，从而提升性能。
 
 如果为 YES，则任何时候只要有滚动产生，动画就会被触发，适合运用到类似 Plain Style 的 UITableView 里在滚动时也要适配停靠的 sectionHeader 的场景（因为需要不断计算当前正在停靠的 sectionHeader 是哪一个）。
 
 默认为 NO
 */
@property(nonatomic, assign) BOOL continuous;

@end

NS_ASSUME_NONNULL_END
