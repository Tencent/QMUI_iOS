/**
 * Tencent is pleased to support the open source community by making QMUI_iOS available.
 * Copyright (C) 2016-2021 THL A29 Limited, a Tencent company. All rights reserved.
 * Licensed under the MIT License (the "License"); you may not use this file except in compliance with the License. You may obtain a copy of the License at
 * http://opensource.org/licenses/MIT
 * Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.
 */

//
//  UIGestureRecognizer+QMUI.h
//  qmui
//
//  Created by QMUI Team on 2017/8/21.
//

#import <UIKit/UIKit.h>

@interface UIGestureRecognizer (QMUI)

/// 获取当前手势直接作用到的 view（注意与 view 属性区分开：view 属性表示手势被添加到哪个 view 上，qmui_targetView 则是 view 属性里的某个 subview）
@property(nullable, nonatomic, weak, readonly) UIView *qmui_targetView;
@end
