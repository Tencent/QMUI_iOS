/**
 * Tencent is pleased to support the open source community by making QMUI_iOS available.
 * Copyright (C) 2016-2021 THL A29 Limited, a Tencent company. All rights reserved.
 * Licensed under the MIT License (the "License"); you may not use this file except in compliance with the License. You may obtain a copy of the License at
 * http://opensource.org/licenses/MIT
 * Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.
 */

//
//  UINavigationItem+QMUI.h
//  qmui
//
//  Created by QMUI Team on 2020/10/28.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UINavigationItem (QMUI)

@property(nonatomic, weak, readonly, nullable) UINavigationBar *qmui_navigationBar;
@property(nonatomic, weak, readonly, nullable) UINavigationController *qmui_navigationController;
@property(nonatomic, weak, readonly, nullable) UIViewController *qmui_viewController;
@property(nonatomic, weak, readonly, nullable) UINavigationItem *qmui_previousItem;
@property(nonatomic, weak, readonly, nullable) UINavigationItem *qmui_nextItem;
@end

NS_ASSUME_NONNULL_END
