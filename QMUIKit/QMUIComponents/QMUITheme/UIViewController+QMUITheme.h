/**
 * Tencent is pleased to support the open source community by making QMUI_iOS available.
 * Copyright (C) 2016-2020 THL A29 Limited, a Tencent company. All rights reserved.
 * Licensed under the MIT License (the "License"); you may not use this file except in compliance with the License. You may obtain a copy of the License at
 * http://opensource.org/licenses/MIT
 * Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.
 */
//
//  UIViewController+QMUITheme.h
//  QMUIKit
//
//  Created by MoLice on 2019/6/26.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class QMUIThemeManager;

@interface UIViewController (QMUITheme)

/**
 当主题变化时这个方法会被调用
 @param manager 当前的主题管理对象
 @param identifier 当前主题的标志，可自行修改参数类型为目标类型
 @param theme 当前主题对象，可自行修改参数类型为目标类型
 */
- (void)qmui_themeDidChangeByManager:(QMUIThemeManager *)manager identifier:(__kindof NSObject<NSCopying> *)identifier theme:(__kindof NSObject *)theme NS_REQUIRES_SUPER;
@end

NS_ASSUME_NONNULL_END
