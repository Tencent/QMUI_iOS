/*****
 * Tencent is pleased to support the open source community by making QMUI_iOS available.
 * Copyright (C) 2016-2018 THL A29 Limited, a Tencent company. All rights reserved.
 * Licensed under the MIT License (the "License"); you may not use this file except in compliance with the License. You may obtain a copy of the License at
 * http://opensource.org/licenses/MIT
 * Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.
 *****/

//
//  UIBarItem+QMUI.h
//  QMUIKit
//
//  Created by QMUI Team on 2018/4/5.
//

#import <UIKit/UIKit.h>

@interface UIBarItem (QMUI)

/// 获取 UIBarItem（UIBarButtonItem、UITabBarItem） 内部的 view，通常对于 navigationItem 而言，需要在设置了 navigationItem 后并且在 navigationBar 可见时（例如 viewDidAppear: 及之后）获取 UIBarButtonItem.qmui_view 才有值。
/// 对于 UIBarButtonItem 和 UITabBarItem 而言，获取到的 view 均为 UIControl 的私有子类。
@property(nullable, nonatomic, weak, readonly) UIView *qmui_view;
@end
