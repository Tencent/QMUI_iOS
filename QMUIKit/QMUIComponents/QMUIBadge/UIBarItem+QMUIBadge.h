/**
 * Tencent is pleased to support the open source community by making QMUI_iOS available.
 * Copyright (C) 2016-2021 THL A29 Limited, a Tencent company. All rights reserved.
 * Licensed under the MIT License (the "License"); you may not use this file except in compliance with the License. You may obtain a copy of the License at
 * http://opensource.org/licenses/MIT
 * Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.
 */

//
//  UIBarItem+QMUIBadge.h
//  QMUIKit
//
//  Created by QMUI Team on 2018/6/2.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import "QMUIBadgeProtocol.h"

/**
 *  用于在 UIBarButtonItem（通常用于 UINavigationBar 和 UIToolbar）和 UITabBarItem 上显示未读红点或者未读数，对设置的时机没有要求。
 *  提供的属性请查看 @c QMUIBadgeProtocol ，属性的默认值在 QMUIConfigurationTemplate 配置表里设置，如果不使用配置表，则所有属性的默认值均为 0 或 nil。
 *
 *  @note 系统对 UIBarButtonItem 和 UITabBarItem 在横竖屏下均会有不同的布局，当你使用本控件时建议分别检查横竖屏下的表现是否正确。
 */
@interface UIBarItem (QMUIBadge) <QMUIBadgeProtocol>

@end
