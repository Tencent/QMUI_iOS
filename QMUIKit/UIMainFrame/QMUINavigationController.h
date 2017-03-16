//
//  QMUINavigationController.h
//  qmui
//
//  Created by QQMail on 14-6-24.
//  Copyright (c) 2014年 QMUI Team. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
 *  <b>QMUINavigationControllerDelegate</b><br/>
 *  用来控制navigationController在push或者pop的时候，可以很方便的控制controller之间的<i>status bar</i>, <i>navigationBarBackgroundImage</i>, <i>navigationBarShadowImage</i>, <i>navigationBarTintColor</i> 的切换，从而不用在每个controller的viewWillAppear或者viewWillDisappear里面单独控制
 */
@protocol QMUINavigationControllerDelegate <NSObject>

@required

/// 是否需要将状态栏改为浅色文字，默认为宏StatusbarStyleLightInitially的值
- (BOOL)shouldSetStatusBarStyleLight;

@optional

/// 设置titleView的tintColor
- (nullable UIColor *)titleViewTintColor;

/// 设置导航栏的背景图，默认为NavBarBackgroundImage
- (nullable UIImage *)navigationBarBackgroundImage;

/// 设置导航栏底部的分隔线图片，默认为NavBarShadowImage，必须在navigationBar设置了背景图后才有效
- (nullable UIImage *)navigationBarShadowImage;

/// 设置当前导航栏的UIBarButtonItem的tintColor，默认为NavBarTintColor
- (nullable UIColor *)navigationBarTintColor;

/// 设置系统返回按钮title，如果返回nil则使用系统默认的返回按钮标题
- (nullable NSString *)backBarButtonItemTitleWithPreviousViewController:(nullable UIViewController *)viewController;

/**
 *  设置当前导航栏是否需要使用自定义的 push/pop transition 效果，默认返回NO。<br/>
 *  因为系统的UINavigationController只有一个navBar，所以会导致在切换controller的时候，如果两个controller的navBar状态不一致（包括backgroundImgae、shadowImage、barTintColor等等），就会导致在刚要切换的瞬间，navBar的状态都立马变成下一个controller所设置的样式了，为了解决这种情况，QMUI给出了一个方案，有四个方法可以决定你在转场的时候要不要使用自定义的navBar来模仿真实的navBar。具体方法如下：
 *  @see UINavigationController+NavigationBarTransition.h
 */
- (BOOL)shouldCustomNavigationBarTransitionWhenPushAppearing;

/**
 *  同上
 *  @see UINavigationController+NavigationBarTransition.h
 */
- (BOOL)shouldCustomNavigationBarTransitionWhenPushDisappearing;

/**
 *  同上
 *  @see UINavigationController+NavigationBarTransition.h
 */
- (BOOL)shouldCustomNavigationBarTransitionWhenPopAppearing;

/**
 *  同上
 *  @see UINavigationController+NavigationBarTransition.h
 */
- (BOOL)shouldCustomNavigationBarTransitionWhenPopDisappearing;

/**
 *  自定义navBar效果过程中UINavigationController的containerView的背景色
 *  @see UINavigationController+NavigationBarTransition.h
 */
- (nullable UIColor *)containerViewBackgroundColorWhenTransition;

/**
 *  当前导航栏是否具备全屏（隐藏navBar）的能力，默认返回NO。<br/>
 *  因为默认的全屏状态（隐藏navigationBar）下，手势返回时 toViewController 的 navigationBar 会缺失，需要设置此值用自定义的 pushViewController:animate: 来解决。
 *  @see UINavigationController+NavigationBarTransition.h
 */
- (BOOL)shouldCustomNavigationBarTransitionIfBarHiddenable;

/**
 *  当前导航栏是否处于全屏状态，如果是则返回YES，默认返回NO。<br/>
 *  该属性用于判断如果在 popViewController 的时候如果 toViewController 是处于全屏的则不改变它的状态。
 *  @see UINavigationController+NavigationBarTransition.h
 */
- (BOOL)shouldCustomNavigationBarTransitionWithBarHiddenState;

@end


@interface QMUINavigationController : UINavigationController <UINavigationControllerDelegate>

/**
 *  初始化时调用的方法，会在 initWithNibName:bundle: 和 initWithCoder: 这两个指定的初始化方法中被调用，所以子类如果需要同时支持两个初始化方法，则建议把初始化时要做的事情放到这个方法里。否则仅需重写要支持的那个初始化方法即可。
 */
- (void)didInitialized NS_REQUIRES_SUPER;

@end

@interface QMUINavigationController (UISubclassingHooks)

/**
 *  每个界面Controller在即将展示的时候被调用，在`UINavigationController`的方法`navigationController:willShowViewController:animated:`中会自动被调用，同时因为如果把一个界面dismiss后回来此时并不会调用`navigationController:willShowViewController`，所以需要在`viewWillAppear`里面也会调用一次。
 */
- (void)willShowViewController:(nonnull UIViewController *)viewController NS_REQUIRES_SUPER;

/**
 *  同上
 */
- (void)didShowViewController:(nonnull UIViewController *)viewController NS_REQUIRES_SUPER;

@end
