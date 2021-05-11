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
@end
