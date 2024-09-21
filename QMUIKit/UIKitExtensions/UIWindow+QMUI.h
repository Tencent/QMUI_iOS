/**
 * Tencent is pleased to support the open source community by making QMUI_iOS available.
 * Copyright (C) 2016-2021 THL A29 Limited, a Tencent company. All rights reserved.
 * Licensed under the MIT License (the "License"); you may not use this file except in compliance with the License. You may obtain a copy of the License at
 * http://opensource.org/licenses/MIT
 * Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.
 */

//
//  UIWindow+QMUI.h
//  qmui
//
//  Created by QMUI Team on 16/7/21.
//

#import <UIKit/UIKit.h>

@interface UIWindow (QMUI)

/**
 允许当前 window 接管 statusBar 的样式设置，默认为 YES。
 
 @note 经测试，- [UIViewController prefersStatusBarHidden]、- [UIViewController preferredStatusBarStyle]、- [UIViewController preferredStatusBarUpdateAnimation] 系列方法仅当该 viewController 所在的 UIWindow 符合以下条件时才能生效：
 1. window 处于最顶层，没有其他 window 遮挡
 2. iOS 10 及以后，window.frame 与 mainScreen.bounds 相等（origin、size 都应一模一样）
 因此当我们在某些情况下利用 UIWindow 去实现遮罩、浮层等效果时，会错误地导致原来的 window 内的 viewController 丢失了对 statusBar 的控制权（因为你新加的 window 满足了上文所有条件），为了避免这种情况，可以将你自己的 window.qmui_capturesStatusBarAppearance = NO，这样你的 window 就不会影响原 window 对 statusBar 的控制权。同理，如果你的 window 本身就不需要盖住整个屏幕，那就算你不设置 qmui_capturesStatusBarAppearance 也不会影响原 window 的表现。
 
 @warning 如果你自己创建的 window 不满足以上2点，那么就算 qmui_capturesStatusBarAppearance 为 YES，也无法得到 statusBar 的控制权。
 */
@property(nonatomic, assign) BOOL qmui_capturesStatusBarAppearance;

/**
 1. 支持以 property 形式修改值，但不支持重写 getter 来修改。
 2. 对低于 iOS 15 的系统也支持。
 */
@property(nonatomic, assign) BOOL qmui_canBecomeKeyWindow;

/// 当前 window 因各种原因（例如其他 window 显式调用 makeKey、当前 keyWindow 被隐藏导致系统自动流转 keyWindow、主动向自身调用 resignKeyWindow 等）导致从 keyWindow 转变为非 keyWindow 时会询问这个 block，业务可在这个 block 里干预当前的流转。
/// 实际场景例如，背后 window 正在显示一个带输入框的 webView 网页，输入框聚焦以升起键盘，此时你再新开一个更高 windowLevel 的 window，盖在 webView 上并且 makeKey，就会发现你的 window 依然被键盘挡住，因为 webView 有个特性是如果有输入框聚焦，则 webView 内部会不断地尝试将输入框 becomeFirstResponder 并且让输入框所在的 window makeKey，这就会抢占了我们刚刚手动盖上来的 window 的 key，所以此时就可以给新开的 window 使用本 block，返回 NO，使 webView 无法抢占 keyWindow，从而避免键盘遮挡。
@property(nonatomic, copy) BOOL (^qmui_canResignKeyWindowBlock)(UIWindow *selfObject, UIWindow *windowWillBecomeKey);
@end
