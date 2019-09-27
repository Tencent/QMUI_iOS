/*****
 * Tencent is pleased to support the open source community by making QMUI_iOS available.
 * Copyright (C) 2016-2019 THL A29 Limited, a Tencent company. All rights reserved.
 * Licensed under the MIT License (the "License"); you may not use this file except in compliance with the License. You may obtain a copy of the License at
 * http://opensource.org/licenses/MIT
 * Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.
 *****/

//
//  UINavigationController+QMUI.h
//  qmui
//
//  Created by QMUI Team on 16/1/12.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UINavigationController (QMUI) <UIGestureRecognizerDelegate>

/// 是否在 push 的过程中
@property(nonatomic, readonly) BOOL qmui_isPushing;

/// 是否在 pop 的过程中，包括手势、以及代码触发的 pop
@property(nonatomic, readonly) BOOL qmui_isPopping;

/// 获取顶部的 ViewController，相比于系统的方法，这个方法能获取到 pop 的转场过程中顶部还没有完全消失的 ViewController （请注意：这种情况下，获取到的 topViewController 已经不在栈内）
@property(nullable, nonatomic, readonly) UIViewController *qmui_topViewController;

/// 获取<b>rootViewController</b>
@property(nullable, nonatomic, readonly) UIViewController *qmui_rootViewController;

- (void)qmui_pushViewController:(UIViewController *)viewController animated:(BOOL)animated completion:(void (^_Nullable)(void))completion;
- (UIViewController *)qmui_popViewControllerAnimated:(BOOL)animated completion:(void (^_Nullable)(void))completion;
- (NSArray<UIViewController *> *)qmui_popToViewController:(UIViewController *)viewController animated:(BOOL)animated completion:(void (^_Nullable)(void))completion;
- (NSArray<UIViewController *> *)qmui_popToRootViewControllerAnimated:(BOOL)animated completion:(void (^_Nullable)(void))completion;

@end


/**
 *  拦截系统默认返回按钮事件，有时候需要在点击系统返回按钮，或者手势返回的时候想要拦截事件，比如要判断当前界面编辑的的内容是否要保存，或者返回的时候需要做一些额外的逻辑处理等等。
 *
 */
@protocol UINavigationControllerBackButtonHandlerProtocol <NSObject>

@optional

/// 是否需要拦截系统返回按钮的事件，只有当这里返回YES的时候，才会询问方法：`canPopViewController`
/// @warning 此接口已经被废弃，请使用 `shouldPopViewControllerByBackButtonOrPopGesture`
- (BOOL)shouldHoldBackButtonEvent DEPRECATED_MSG_ATTRIBUTE("从 4.0.0-beta 开始已废弃，请使用 shouldPopViewControllerByBackButtonOrPopGesture 代替");

/// 是否可以`popViewController`，可以在这个返回里面做一些业务的判断，比如点击返回按钮的时候，如果输入框里面的文本没有满足条件的则可以弹 Alert 并且返回 NO
/// @warning 此接口已经被废弃，请使用 `shouldPopViewControllerByBackButtonOrPopGesture`
- (BOOL)canPopViewController DEPRECATED_MSG_ATTRIBUTE("从 4.0.0-beta 开始已废弃，请使用 shouldPopViewControllerByBackButtonOrPopGesture 代替");

/**
 * 点击系统返回按钮或者手势返回的时候是否要相应界面返回（手动调用代码pop排除）。支持参数判断是点击系统返回按钮还是通过手势触发，`shouldHoldBackButtonEvent` 和 `canPopViewController` 即将被废弃，可能会在某个版本删除代码停止支持，请尽快更换新的接口。
 * 一般使用的场景是：可以在这个返回里面做一些业务的判断，比如点击返回按钮的时候，如果输入框里面的文本没有满足条件的则可以弹 Alert 并且返回 NO 来阻止用户退出界面导致不合法的数据或者数据丢失。
 */
- (BOOL)shouldPopViewControllerByBackButtonOrPopGesture:(BOOL)byPopGesture;

/// 当自定义了`leftBarButtonItem`按钮之后，系统的手势返回就失效了。可以通过`forceEnableInteractivePopGestureRecognizer`来决定要不要把那个手势返回强制加回来。当 interactivePopGestureRecognizer.enabled = NO 或者当前`UINavigationController`堆栈的viewControllers小于2的时候此方法无效。
- (BOOL)forceEnableInteractivePopGestureRecognizer;

@end


/**
 *  @see UINavigationControllerBackButtonHandlerProtocol
 */
@interface UIViewController (BackBarButtonSupport) <UINavigationControllerBackButtonHandlerProtocol>

@end

NS_ASSUME_NONNULL_END
