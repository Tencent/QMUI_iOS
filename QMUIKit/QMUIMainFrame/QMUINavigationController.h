/**
 * Tencent is pleased to support the open source community by making QMUI_iOS available.
 * Copyright (C) 2016-2021 THL A29 Limited, a Tencent company. All rights reserved.
 * Licensed under the MIT License (the "License"); you may not use this file except in compliance with the License. You may obtain a copy of the License at
 * http://opensource.org/licenses/MIT
 * Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.
 */

//
//  QMUINavigationController.h
//  qmui
//
//  Created by QMUI Team on 14-6-24.
//

#import <UIKit/UIKit.h>


@interface QMUINavigationController : UINavigationController

@end

@interface QMUINavigationController (UISubclassingHooks)

/**
 *  每个界面Controller在即将展示的时候被调用，在`UINavigationController`的方法`navigationController:willShowViewController:animated:`中会自动被调用，同时因为如果把一个界面dismiss后回来此时并不会调用`navigationController:willShowViewController`，所以需要在`viewWillAppear`里面也会调用一次。
 */
- (void)willShowViewController:(nonnull UIViewController *)viewController animated:(BOOL)animated NS_REQUIRES_SUPER;

/**
 *  同上
 */
- (void)didShowViewController:(nonnull UIViewController *)viewController animated:(BOOL)animated NS_REQUIRES_SUPER;

@end


/// 与 QMUINavigationController push/pop 相关的一些方法
@protocol QMUINavigationControllerTransitionDelegate <NSObject>

@optional

/**
 *  当前界面正处于手势返回的过程中，可自行通过 gestureRecognizer.state 来区分手势返回的各个阶段。手势返回有多个阶段（手势返回开始、拖拽过程中、松手并成功返回、松手但不切换界面），不同阶段的 viewController 的状态可能不一样。
 *  @param navigationController 当前正在手势返回的 QMUINavigationController，由于某些阶段下无法通过 vc.navigationController 获取到 nav 的引用，所以直接传一个参数
 *  @param gestureRecognizer 手势对象
 *  @param viewControllerWillDisappear 手势返回中顶部的那个 vc
 *  @param viewControllerWillAppear 手势返回中背后的那个 vc
 */
- (void)navigationController:(nonnull QMUINavigationController *)navigationController
poppingByInteractiveGestureRecognizer:(nullable UIScreenEdgePanGestureRecognizer *)gestureRecognizer
 viewControllerWillDisappear:(nullable UIViewController *)viewControllerWillDisappear
    viewControllerWillAppear:(nullable UIViewController *)viewControllerWillAppear DEPRECATED_MSG_ATTRIBUTE("不便于判断手势返回是否成功，请使用 navigationController:poppingByInteractiveGestureRecognizer:isCancelled:viewControllerWillDisappear:viewControllerWillAppear: 代替");

/**
 *  当前界面正处于手势返回的过程中，可自行通过 gestureRecognizer.state 来区分手势返回的各个阶段。手势返回有多个阶段（手势返回开始、拖拽过程中、松手并成功返回、松手但不切换界面），不同阶段的 viewController 的状态可能不一样。
 *  @param navigationController 当前正在手势返回的 QMUINavigationController，请勿通过 vc.navigationController 获取 UINavigationController 的引用，而应该用本参数。因为某些手势阶段，vc.navigationController 得到的是 nil。
 *  @param gestureRecognizer 手势对象
 *  @param isCancelled 表示当前手势返回是否取消，只有在松手后这个参数的值才有意义
 *  @param viewControllerWillDisappear 手势返回中顶部的那个 vc，松手时如果成功手势返回，则该参数表示被 pop 的界面，如果手势返回取消，则该参数表示背后的界面。
 *  @param viewControllerWillAppear 手势返回中背后的那个 vc，松手时如果成功手势返回，则该参数表示背后的界面，如果手势返回取消，则该参数表示当前顶部的界面。
 */
- (void)navigationController:(nonnull QMUINavigationController *)navigationController
poppingByInteractiveGestureRecognizer:(nullable UIScreenEdgePanGestureRecognizer *)gestureRecognizer
                 isCancelled:(BOOL)isCancelled
 viewControllerWillDisappear:(nullable UIViewController *)viewControllerWillDisappear
    viewControllerWillAppear:(nullable UIViewController *)viewControllerWillAppear;

/**
 *  在 self.navigationController 进行以下 4 个操作前，相应的 viewController 的 willPopInNavigationControllerWithAnimated: 方法会被调用：
 *  1. popViewControllerAnimated:
 *  2. popToViewController:animated:
 *  3. popToRootViewControllerAnimated:
 *  4. setViewControllers:animated:
 *
 *  此时 self 仍存在于 self.navigationController.viewControllers 堆栈内。
 *
 *  在 ARC 环境下，viewController 可能被放在 autorelease 池中，因此 viewController 被pop后不一定立即被销毁，所以一些对实时性要求很高的内存管理逻辑可以写在这里（而不是写在dealloc内）
 *
 *  @warning 不要尝试将 willPopInNavigationControllerWithAnimated: 视为点击返回按钮的回调，因为导致 viewController 被 pop 的情况不止点击返回按钮这一途径。系统的返回按钮是无法添加回调的，只能使用自定义的返回按钮。
 */
- (void)willPopInNavigationControllerWithAnimated:(BOOL)animated;

/**
 *  在 self.navigationController 进行以下 4 个操作后，相应的 viewController 的 didPopInNavigationControllerWithAnimated: 方法会被调用：
 *  1. popViewControllerAnimated:
 *  2. popToViewController:animated:
 *  3. popToRootViewControllerAnimated:
 *  4. setViewControllers:animated:
 *
 *  此时 self.navigationController 仍有值，但 self 已经不在 viewControllers 数组内。
 *
 *  @warning 这个方法被调用并不意味着 self 最终一定会被 pop 掉，例如手势返回被触发时就会调用这个方法，但如果中途取消手势，self 依然会回到 viewControllers 内。
 */
- (void)didPopInNavigationControllerWithAnimated:(BOOL)animated;

/**
 *  当通过 setViewControllers:animated: 来修改 viewController 的堆栈时，如果参数 viewControllers.lastObject 与当前的 self.viewControllers.lastObject 不相同，则意味着会产生界面的切换，这种情况系统会自动调用两个切换的界面的生命周期方法，但如果两者相同，则意味着并不会产生界面切换，此时之前就已经在显示的那个 viewController 的 viewWillAppear:、viewDidAppear: 并不会被调用，那如果用户确实需要在这个时候修改一些界面元素，则找不到一个时机。所以这个方法就是提供这样一个时机给用户修改界面元素。
 */
- (void)viewControllerKeepingAppearWhenSetViewControllersWithAnimated:(BOOL)animated;

@end


/// 与 QMUINavigationController 外观样式相关的方法
@protocol QMUINavigationControllerAppearanceDelegate <NSObject>

@optional

/// 设置 titleView 的 tintColor
- (nullable UIColor *)titleViewTintColor;

/// 设置导航栏的背景图，默认为 NavBarBackgroundImage
- (nullable UIImage *)navigationBarBackgroundImage;

/// 设置导航栏底部的分隔线图片，默认为 NavBarShadowImage，必须在 navigationBar 设置了背景图后才有效（系统限制如此）
- (nullable UIImage *)navigationBarShadowImage;

/// 设置当前导航栏的 barTintColor，默认为 NavBarBarTintColor
- (nullable UIColor *)navigationBarBarTintColor;

/// 设置当前导航栏的 barStyle，默认为 NavBarStyle
- (UIBarStyle)navigationBarStyle;

/// 设置当前导航栏的 UIBarButtonItem 的 tintColor，默认为NavBarTintColor
- (nullable UIColor *)navigationBarTintColor;

/// 设置系统返回按钮title，如果返回nil则使用系统默认的返回按钮标题。当实现了这个方法时，会无视配置表 NeedsBackBarButtonItemTitle 的值
- (nullable NSString *)backBarButtonItemTitleWithPreviousViewController:(nullable UIViewController *)viewController;

@end


/// 与 QMUINavigationController 控制 navigationBar 显隐/动画相关的方法
@protocol QMUICustomNavigationBarTransitionDelegate <NSObject>

@optional

/// 设置每个界面导航栏的显示/隐藏，为了减少对项目的侵入性，默认不开启这个接口的功能，只有当 shouldCustomizeNavigationBarTransitionIfHideable 返回 YES 时才会开启此功能。如果需要全局开启，那么就在 Controller 基类里面返回 YES；如果是老项目并不想全局使用此功能，那么则可以在单独的界面里面开启。
- (BOOL)preferredNavigationBarHidden;

/**
 *  当切换界面时，如果不同界面导航栏的显隐状态不同，可以通过 shouldCustomizeNavigationBarTransitionIfHideable 设置是否需要接管导航栏的显示和隐藏。从而不需要在各自的界面的 viewWillAppear 和 viewWillDisappear 里面去管理导航栏的状态。
 *  @see UINavigationController+NavigationBarTransition.h
 *  @see preferredNavigationBarHidden
 */
- (BOOL)shouldCustomizeNavigationBarTransitionIfHideable;

/**
 *  设置导航栏转场的时候是否需要使用自定义的 push / pop transition 效果。<br/>
 *  如果前后两个界面 controller 返回的 key 不一致，那么则说明需要自定义。<br/>
 *  不实现这个方法，或者实现了但返回 nil，都视为希望使用默认样式。<br/>
 *  @warning 四个老接口 shouldCustomNavigationBarTransitionxxx 已经废弃不建议使用，不过还是会支持，建议都是用新接口
 *  @see UINavigationController+NavigationBarTransition.h
 *  @see 配置表有开关 AutomaticCustomNavigationBarTransitionStyle 支持自动判断样式，无需实现这个方法
 */
- (nullable NSString *)customNavigationBarTransitionKey;

/**
 *  在实现了系统的自定义转场情况下，导航栏转场的时候是否需要使用 QMUI 自定义的 push / pop transition 效果，默认不实现的话则不会使用，只要前后其中一个 vc 实现并返回了 YES 则会使用。
 *  @see UINavigationController+NavigationBarTransition.h
 */
- (BOOL)shouldCustomizeNavigationBarTransitionIfUsingCustomTransitionForOperation:(UINavigationControllerOperation)operation fromViewController:(nullable UIViewController *)fromVC toViewController:(nullable UIViewController *)toVc;

/**
 *  自定义navBar效果过程中UINavigationController的containerView的背景色
 *  @see UINavigationController+NavigationBarTransition.h
 */
- (nullable UIColor *)containerViewBackgroundColorWhenTransitioning;

@end


/**
 *  配合 QMUINavigationController 使用，当 navController 里的 UIViewController 实现了这个协议时，则可得到协议里各个方法的功能。
 *  QMUICommonViewController、QMUICommonTableViewController 默认实现了这个协议，所以子类无需再手动实现一遍。
 */
@protocol QMUINavigationControllerDelegate <UINavigationControllerDelegate, QMUINavigationControllerTransitionDelegate, QMUINavigationControllerAppearanceDelegate, QMUICustomNavigationBarTransitionDelegate>

@end
