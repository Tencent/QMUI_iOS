/**
 * Tencent is pleased to support the open source community by making QMUI_iOS available.
 * Copyright (C) 2016-2021 THL A29 Limited, a Tencent company. All rights reserved.
 * Licensed under the MIT License (the "License"); you may not use this file except in compliance with the License. You may obtain a copy of the License at
 * http://opensource.org/licenses/MIT
 * Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.
 */

//
//  UINavigationBar+Transition.h
//  qmui
//
//  Created by QMUI Team on 11/25/16.
//

#import <UIKit/UIKit.h>

@interface UINavigationBar (Transition)

/// 用来模仿真的navBar，配合 UINavigationController+NavigationBarTransition 在转场过程中存在的一条假navBar
@property(nonatomic, weak) UINavigationBar *qmuinb_copyStylesToBar;
@end

@interface _QMUITransitionNavigationBar : UINavigationBar

@property(nonatomic, weak) UIViewController *parentViewController;

// 建立假 bar 到真 bar 的关系，内部会通过 qmuinb_copyStylesToBar 同时设置真 bar 到假 bar 的关系
@property(nonatomic, weak) UINavigationBar *originalNavigationBar;

@property(nonatomic, assign) BOOL shouldPreventAppearance;

// 根据当前的系统导航栏布局，刷新自身在 vc.view 上的布局
- (void)updateLayout;
@end
