/**
 * Tencent is pleased to support the open source community by making QMUI_iOS available.
 * Copyright (C) 2016-2021 THL A29 Limited, a Tencent company. All rights reserved.
 * Licensed under the MIT License (the "License"); you may not use this file except in compliance with the License. You may obtain a copy of the License at
 * http://opensource.org/licenses/MIT
 * Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.
 */

//
//  UIView+QMUIBadge.h
//  QMUIKit
//
//  Created by MoLice on 2020/5/26.
//

#import <UIKit/UIKit.h>
#import "QMUIBadgeProtocol.h"

NS_ASSUME_NONNULL_BEGIN

/**
 用于在任意 UIView 上显示未读红点或者未读数，提供的属性请查看 @c QMUIBadgeProtocol ，属性的默认值在 QMUIConfigurationTemplate 配置表里设置，如果不使用配置表，则所有属性的默认值均为 0 或 nil。
 
 @note 使用该组件会强制设置 view.clipsToBounds = NO 以避免布局到 view 外部的红点/未读数看不到。
 */
@interface UIView (QMUIBadge) <QMUIBadgeProtocol>

@end

NS_ASSUME_NONNULL_END
