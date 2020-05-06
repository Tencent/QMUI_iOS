/**
 * Tencent is pleased to support the open source community by making QMUI_iOS available.
 * Copyright (C) 2016-2020 THL A29 Limited, a Tencent company. All rights reserved.
 * Licensed under the MIT License (the "License"); you may not use this file except in compliance with the License. You may obtain a copy of the License at
 * http://opensource.org/licenses/MIT
 * Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.
 */
//
//  QMUIWindowSizeMonitor.h
//  qmuidemo
//
//  Created by ziezheng on 2019/5/27.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@protocol QMUIWindowSizeMonitorProtocol <NSObject>

@optional

/**
 当继承自 UIResponder 的对象，比如 UIView 或 UIViewController 实现了这个方法时，其所属的 window 在大小发生改变后在这个方法回调。
 @note 类似系统的 [-viewWillTransitionToSize:withTransitionCoordinator:]，但是系统这个方法回调时 window 的大小实际上还未发生改变，如果你需要在 window 大小发生之后且在 layout 之前来处理一些逻辑时，可以放到这个方法去实现。
 @note 如果子类和父类同时实现了该方法，则两个方法均会被调用，调用顺序是先父类后子类。
 @param size 所属窗口的新大小
 */

- (void)windowDidTransitionToSize:(CGSize)size;

@end

@interface UIResponder (QMUIWindowSizeMonitor) <QMUIWindowSizeMonitorProtocol>

@end

typedef void (^QMUIWindowSizeObserverHandler)(CGSize newWindowSize);

@interface NSObject (QMUIWindowSizeMonitor)

/**
 为当前对象添加主窗口 (UIApplication Delegate Window)的大小变化的监听，同一对象可重复添加多个监听，当对象销毁时监听自动失效。
 
 @param handler 窗口大小发生改变时的回调
 */
- (void)qmui_addSizeObserverForMainWindow:(QMUIWindowSizeObserverHandler)handler;
/**
 为当前对象添加指定窗口的大小变化监听，同一对象可重复添加多个监听，当对象销毁时监听自动失效。
 
 @param window 要监听的窗口
 @param handler 窗口大小发生改变时的回调
 */
- (void)qmui_addSizeObserverForWindow:(UIWindow *)window handler:(QMUIWindowSizeObserverHandler)handler;

@end

NS_ASSUME_NONNULL_END
