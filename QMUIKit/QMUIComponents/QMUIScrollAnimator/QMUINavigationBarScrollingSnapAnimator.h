//
//  QMUINavigationBarScrollingSnapAnimator.h
//  QMUIKit
//
//  Created by MoLice on 2018/S/30.
//  Copyright © 2018 QMUI Team. All rights reserved.
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

@end

NS_ASSUME_NONNULL_END
