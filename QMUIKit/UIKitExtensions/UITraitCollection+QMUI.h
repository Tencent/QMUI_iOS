/**
 * Tencent is pleased to support the open source community by making QMUI_iOS available.
 * Copyright (C) 2016-2021 THL A29 Limited, a Tencent company. All rights reserved.
 * Licensed under the MIT License (the "License"); you may not use this file except in compliance with the License. You may obtain a copy of the License at
 * http://opensource.org/licenses/MIT
 * Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.
 */
//
//  UITraitCollection+QMUI.h
//  QMUIKit
//
//  Created by ziezheng on 2019/7/19.
//


#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN


@interface UITraitCollection (QMUI)

/**
 添加一个系统的深色、浅色外观发即将生变化前的监听，可用于需要在外观即将发生改变之前更新状态，例如 QMUIThemeManager 利用其来自动切换主题
 @note 如果在 info.plist 中指定 User Interface Style 值将无法监听。
 */
+ (void)qmui_addUserInterfaceStyleWillChangeObserver:(id)observer selector:(SEL)aSelector API_AVAILABLE(ios(13.0));

@end



NS_ASSUME_NONNULL_END
