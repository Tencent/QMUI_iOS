/**
 * Tencent is pleased to support the open source community by making QMUI_iOS available.
 * Copyright (C) 2016-2021 THL A29 Limited, a Tencent company. All rights reserved.
 * Licensed under the MIT License (the "License"); you may not use this file except in compliance with the License. You may obtain a copy of the License at
 * http://opensource.org/licenses/MIT
 * Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.
 */

//
//  UINavigationController+QMUI.h
//  qmui
//
//  Created by QMUI Team on 16/1/12.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, QMUINavigationAction) {
    QMUINavigationActionUnknow,         // 初始、各种动作的 completed 之后都会立即转入 unknown 状态，此时的 appearing、disappearingViewController 均为 nil
    
    QMUINavigationActionWillPush,       // push 方法被触发，但尚未进行真正的 push 动作
    QMUINavigationActionDidPush,        // 系统的 push 已经执行完，viewControllers 已被刷新
    QMUINavigationActionPushCompleted,  // push 动画结束（如果没有动画，则在 did push 后立即进入 completed）
    
    QMUINavigationActionWillPop,        // pop 方法被触发，但尚未进行真正的 pop 动作
    QMUINavigationActionDidPop,         // 系统的 pop 已经执行完，viewControllers 已被刷新（注意可能有 pop 失败的情况）
    QMUINavigationActionPopCompleted,   // pop 动画结束（如果没有动画，则在 did pop 后立即进入 completed）
    
    QMUINavigationActionWillSet,        // setViewControllers 方法被触发，但尚未进行真正的 set 动作
    QMUINavigationActionDidSet,         // 系统的 setViewControllers 已经执行完，viewControllers 已被刷新
    QMUINavigationActionSetCompleted,   // setViewControllers 动画结束（如果没有动画，则在 did set 后立即进入 completed）
};

typedef void (^QMUINavigationActionDidChangeBlock)(QMUINavigationAction action, BOOL animated, __kindof UINavigationController * _Nullable weakNavigationController,  __kindof UIViewController * _Nullable appearingViewController, NSArray<__kindof UIViewController *> * _Nullable disappearingViewControllers);


@interface UINavigationController (QMUI) <UIGestureRecognizerDelegate>

/**
 NS_DESIGNATED_INITIALIZER 方法被调用时就会调用这个方法，一些 init 时要处理的事情都可以统一放在这里面。
 为什么需要创建这个方法，是因为 UINavigationController 的 NS_DESIGNATED_INITIALIZER 数量太多了有4个，而且 iOS 12 及以前，initWithNavigationBarClass:toolbarClass:、initWithRootViewController: 这2个方法是没被标记为 NS_DESIGNATED_INITIALIZER 的，它们都会调用 initWithNibName:bundle:，但 iOS 13 及以后，这两个方法增加了 NS_DESIGNATED_INITIALIZER 标记。
 由于有 iOS 版本差异，业务也需要做版本判断，才能保证 init 逻辑不会被重复调用，于是 QMUI 直接提供这个方法，省去业务的判断。
 */
- (void)qmui_didInitialize NS_REQUIRES_SUPER;

@property(nonatomic, assign, readonly) QMUINavigationAction qmui_navigationAction;

/**
 添加一个 block 用于监听当前 UINavigationController 的 push/pop/setViewControllers 操作，在即将进行、已经进行、动画已完结等各种状态均会回调。
 block 参数里的 appearingViewController 表示即将显示的界面。
 disappearingViewControllers 表示即将消失的界面，数组形式是因为可能一次性 pop 掉多个（例如 popToRootViewController、setViewControllers），此时只有 disappearingViewControllers.lastObject 可以看到 pop 动画。由于 pop 可能失败，所以 will 动作里的 disappearingViewControllers 最终不一定真的会被移除。
 weakNavigationController 是便于你引用 self 而避免循环引用（因为这个方法会令 self retain 你传进来的 block，而 block 内部如果直接用 self，就会 retain self，产生循环引用，所以这里给一个参数规避这个问题）。
 @note 无法添加一个只监听某个 QMUINavigationAction 的 block，每一个添加的 block 在任何一个 action 变化时都会被调用，需要 block 内部自己区分当前的 action。
 */
- (void)qmui_addNavigationActionDidChangeBlock:(QMUINavigationActionDidChangeBlock)block;

/// 是否在 push 的过程中
@property(nonatomic, readonly) BOOL qmui_isPushing;

/// 是否在 pop 的过程中，包括手势、以及代码触发的 pop
@property(nonatomic, readonly) BOOL qmui_isPopping;

/// 获取顶部的 ViewController，相比于系统的方法，这个方法能获取到 pop 的转场过程中顶部还没有完全消失的 ViewController （请注意：这种情况下，获取到的 topViewController 已经不在栈内）
@property(nullable, nonatomic, readonly) UIViewController *qmui_topViewController;

/// 获取<b>rootViewController</b>
@property(nullable, nonatomic, readonly) UIViewController *qmui_rootViewController;

/// QMUI 会修改 UINavigationController.interactivePopGestureRecognizer.delegate 的值，因此提供一个属性用于获取系统原始的值
@property(nullable, nonatomic, weak, readonly) id<UIGestureRecognizerDelegate> qmui_interactivePopGestureRecognizerDelegate;

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

/**
 * 点击系统返回按钮或者手势返回的时候是否要相应界面返回（手动调用代码pop排除）。支持参数判断是点击系统返回按钮还是通过手势触发
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
