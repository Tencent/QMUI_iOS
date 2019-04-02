/*****
 * Tencent is pleased to support the open source community by making QMUI_iOS available.
 * Copyright (C) 2016-2019 THL A29 Limited, a Tencent company. All rights reserved.
 * Licensed under the MIT License (the "License"); you may not use this file except in compliance with the License. You may obtain a copy of the License at
 * http://opensource.org/licenses/MIT
 * Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.
 *****/

//
//  UITableViewCell+QMUI.h
//  QMUIKit
//
//  Created by QMUI Team on 2018/7/5.
//

#import <UIKit/UIKit.h>

@interface UITableViewCell (QMUI)

/// setHighlighted:animated: 方法的回调 block
@property(nonatomic, copy) void (^qmui_setHighlightedBlock)(BOOL highlighted, BOOL animated);

/// setSelected:animated: 方法的回调 block
@property(nonatomic, copy) void (^qmui_setSelectedBlock)(BOOL selected, BOOL animated);

/// 获取当前 cell 的 accessoryView，优先级分别是：编辑状态下的 editingAccessoryView -> 编辑状态下的系统自己的 accessoryView -> 普通状态下的自定义 accessoryView -> 普通状态下系统自己的 accessoryView
@property(nonatomic, strong, readonly) __kindof UIView *qmui_accessoryView;

@end
