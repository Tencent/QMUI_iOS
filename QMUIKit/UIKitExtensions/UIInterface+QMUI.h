/**
 * Tencent is pleased to support the open source community by making QMUI_iOS available.
 * Copyright (C) 2016-2021 THL A29 Limited, a Tencent company. All rights reserved.
 * Licensed under the MIT License (the "License"); you may not use this file except in compliance with the License. You may obtain a copy of the License at
 * http://opensource.org/licenses/MIT
 * Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.
 */

//
//  UIInterface+QMUI.h
//  QMUIKit
//
//  Created by QMUI Team on 2018/12/20.
//

#import <UIKit/UIKit.h>
#import "QMUIHelper.h"

NS_ASSUME_NONNULL_BEGIN

@interface QMUIHelper (QMUI_Interface)

/**
 *  内部使用，记录手动旋转方向前的设备方向，当值不为 UIDeviceOrientationUnknown 时表示设备方向有经过了手动调整。默认值为 UIDeviceOrientationUnknown。
 */
@property(nonatomic, assign) UIDeviceOrientation lastOrientationChangedByHelper;

/// 将一个 UIInterfaceOrientationMask 转换成对应的 UIDeviceOrientation
+ (UIDeviceOrientation)deviceOrientationWithInterfaceOrientationMask:(UIInterfaceOrientationMask)mask;

/// 判断一个 UIInterfaceOrientationMask 是否包含某个给定的 UIDeviceOrientation 方向
+ (BOOL)interfaceOrientationMask:(UIInterfaceOrientationMask)mask containsDeviceOrientation:(UIDeviceOrientation)deviceOrientation;

/// 判断一个 UIInterfaceOrientationMask 是否包含某个给定的 UIInterfaceOrientation 方向
+ (BOOL)interfaceOrientationMask:(UIInterfaceOrientationMask)mask containsInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation;

/// 根据指定的旋转方向计算出对应的旋转角度
+ (CGFloat)angleForTransformWithInterfaceOrientation:(UIInterfaceOrientation)orientation;

/// 根据当前设备的旋转方向计算出对应的CGAffineTransform
+ (CGAffineTransform)transformForCurrentInterfaceOrientation;

/// 根据指定的旋转方向计算出对应的CGAffineTransform
+ (CGAffineTransform)transformWithInterfaceOrientation:(UIInterfaceOrientation)orientation;

/// 给 QMUIHelper instance 通知用
- (void)handleDeviceOrientationNotification:(NSNotification *)notification;

@end

@interface UIViewController (QMUI_Interface)

/**
 尝试将手机旋转为指定方向。请确保传进来的参数属于 -[UIViewController supportedInterfaceOrientations] 返回的范围内，如不在该范围内会旋转失败。
 @return 旋转成功则返回 YES，旋转失败返回 NO。
 @note 请注意与 @c qmui_setNeedsUpdateOfSupportedInterfaceOrientations 的区别：如果你的界面支持N个方向，而你希望保持对这N个方向的支持的情况下把设备方向旋转为这N个方向里的某一个时，应该调用 @c qmui_rotateToInterfaceOrientation: 。如果你的界面支持N个方向，而某些情况下你希望把N换成M并触发设备的方向刷新，则请修改方向后，调用 @c qmui_setNeedsUpdateOfSupportedInterfaceOrientations 。
 */
- (BOOL)qmui_rotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation;

/**
 告知系统当前界面的方向有变化，需要刷新。通常在 -[UIViewController supportedInterfaceOrientations] 的值变化后调用，可无脑取代 iOS 16 的同名系统方法。
 */
- (void)qmui_setNeedsUpdateOfSupportedInterfaceOrientations;

/**
 在配置表 AutomaticallyRotateDeviceOrientation 功能开启的情况下，QMUI 会自动判断当前的 UIViewController 是否具备强制旋转设备方向的权利，而如果 QMUI 判断结果为没权利但你又希望当前的 UIViewController 具备这个权利，则可以重写该方法并返回 YES。
 默认返回 NO，也即交给 QMUI 自动判断。
 @warning 该方法仅在 iOS 15 及以前版本有效，iOS 16 及以后版本交给系统处理，QMUI 不干涉。
 */
- (BOOL)qmui_shouldForceRotateDeviceOrientation;
@end

NS_ASSUME_NONNULL_END
