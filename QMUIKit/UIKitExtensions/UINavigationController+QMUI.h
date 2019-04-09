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

/// 获取<b>rootViewController</b>
- (nullable UIViewController *)qmui_rootViewController;

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
- (BOOL)shouldHoldBackButtonEvent;

/// 是否可以`popViewController`，可以在这个返回里面做一些业务的判断，比如点击返回按钮的时候，如果输入框里面的文本没有满足条件的则可以弹alert并且返回NO
- (BOOL)canPopViewController;

/// 当自定义了`leftBarButtonItem`按钮之后，系统的手势返回就失效了。可以通过`forceEnableInteractivePopGestureRecognizer`来决定要不要把那个手势返回强制加回来。当 interactivePopGestureRecognizer.enabled = NO 或者当前`UINavigationController`堆栈的viewControllers小于2的时候此方法无效。
- (BOOL)forceEnableInteractivePopGestureRecognizer;

@end


/**
 *  @see UINavigationControllerBackButtonHandlerProtocol
 */
@interface UIViewController (BackBarButtonSupport) <UINavigationControllerBackButtonHandlerProtocol>

@end

NS_ASSUME_NONNULL_END
