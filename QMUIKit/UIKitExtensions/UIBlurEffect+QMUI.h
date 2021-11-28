/**
 * Tencent is pleased to support the open source community by making QMUI_iOS available.
 * Copyright (C) 2016-2021 THL A29 Limited, a Tencent company. All rights reserved.
 * Licensed under the MIT License (the "License"); you may not use this file except in compliance with the License. You may obtain a copy of the License at
 * http://opensource.org/licenses/MIT
 * Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.
 */
//
//  UIBlurEffect+QMUI.h
//  QMUIKit
//
//  Created by MoLice on 2021/N/25.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIBlurEffect (QMUI)

/**
 创建一个指定模糊半径的磨砂效果，注意这种方式创建的磨砂对象的 style 属性是无意义的（可以理解为系统的磨砂有两个维度：style、radius）。
 */
+ (instancetype)qmui_effectWithBlurRadius:(CGFloat)radius;

/**
 获取当前 UIBlurEffect 的 style，前提是该 UIBlurEffect 对象是通过 effectWithStyle: 方式创建的。如果是通过指定 radius 方式创建的，则 qmui_style 会返回一个无意义的值。
 */
@property(nonatomic, assign, readonly) UIBlurEffectStyle qmui_style;

@end

NS_ASSUME_NONNULL_END
