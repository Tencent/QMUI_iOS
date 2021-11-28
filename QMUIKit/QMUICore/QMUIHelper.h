/**
 * Tencent is pleased to support the open source community by making QMUI_iOS available.
 * Copyright (C) 2016-2021 THL A29 Limited, a Tencent company. All rights reserved.
 * Licensed under the MIT License (the "License"); you may not use this file except in compliance with the License. You may obtain a copy of the License at
 * http://opensource.org/licenses/MIT
 * Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.
 */

//
//  QMUIHelper.h
//  qmui
//
//  Created by QMUI Team on 14/10/25.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "QMUICommonDefines.h"

NS_ASSUME_NONNULL_BEGIN

// TODO: molice 等废弃 qmui_badgeCenterOffset 系列接口后再删除
extern const CGPoint QMUIBadgeInvalidateOffset;

@interface QMUIHelper : NSObject

+ (instancetype)sharedInstance;

/**
 用一个 identifier 标记某一段 block，使其对应该 identifier 只会被运行一次
 @param block 要执行的一段逻辑
 @param identifier 唯一的标记，建议在 identifier 里添加当前这段业务的特有名称，例如用于 swizzle 的可以加“swizzled”前缀，以避免与其他业务共用同一个 identifier 引发 bug
 */
+ (BOOL)executeBlock:(void (NS_NOESCAPE ^)(void))block oncePerIdentifier:(NSString *)identifier;

/**
 将 UIViewContentMode 转为对应的 CALayerContentsGravity
 */
+ (CALayerContentsGravity)layerContentsGravityWithContentMode:(UIViewContentMode)contentMode;
@end

@interface QMUIHelper (Bundle)

/// 获取 QMUIKit.framework Images.xcassets 内的图片资源
/// @param name 图片名
+ (nullable UIImage *)imageWithName:(NSString *)name;

@end

@interface QMUIHelper (SystemVersion)
+ (NSInteger)numbericOSVersion;
+ (NSComparisonResult)compareSystemVersion:(nonnull NSString *)currentVersion toVersion:(nonnull NSString *)targetVersion;
+ (BOOL)isCurrentSystemAtLeastVersion:(nonnull NSString *)targetVersion;
+ (BOOL)isCurrentSystemLowerThanVersion:(nonnull NSString *)targetVersion;
@end

@interface QMUIHelper (DynamicType)

/// 返回当前 contentSize 的 level，这个值可以在设置里面的“字体大小”查看，辅助功能里面有个“更大字体”可以设置更大的字体，不过这里我们这个接口将更大字体都做了统一，都返回“字体大小”里面最大值。
/// Returns the level of contentSize
/// The value can be set in Settings - Display & Brightness - Text Size as well as in General - Accessibility - Larger Text
/// This method returns the value set by user or the maximum value in Text Size, whichever is smaller
+ (nonnull NSNumber *)preferredContentSizeLevel;

/// 设置当前 cell 的高度，heights 是有七个数值的数组，对于不支持的iOS版本，则选择中间的值返回。
/// Sets height of the cell; Heights consist of 7 numberic values; Returns the middle value on legacy iOS versions.
+ (CGFloat)heightForDynamicTypeCell:(nonnull NSArray *)heights;
@end


@interface QMUIHelper (Keyboard)

/**
 * 判断当前 App 里的键盘是否升起，默认为 NO
 * Returns the visibility of the keybord. Default value is NO.
 */
+ (BOOL)isKeyboardVisible;

/**
 * 记录上一次键盘显示时的高度（基于整个 App 所在的 window 的坐标系），注意使用前用 `isKeyboardVisible` 判断键盘是否显示，因为即便是键盘被隐藏的情况下，调用 `lastKeyboardHeightInApplicationWindowWhenVisible` 也会得到高度值。
 */
+ (CGFloat)lastKeyboardHeightInApplicationWindowWhenVisible;

/**
 * 获取当前键盘frame相关
 * @warning 注意iOS8以下的系统在横屏时得到的rect，宽度和高度相反了，所以不建议直接通过这个方法获取高度，而是使用<code>keyboardHeightWithNotification:inView:</code>，因为在后者的实现里会将键盘的rect转换坐标系，转换过程就会处理横竖屏旋转问题。
 */
+ (CGRect)keyboardRectWithNotification:(nullable NSNotification *)notification;

/// 获取当前键盘的高度，注意高度可能为0（例如第三方键盘会发出两次notification，其中第一次的高度就为0）
+ (CGFloat)keyboardHeightWithNotification:(nullable NSNotification *)notification;

/**
 * 获取当前键盘在屏幕上的可见高度，注意外接键盘（iPad那种）时，[QMUIHelper keyboardRectWithNotification]得到的键盘rect里有一部分是超出屏幕，不可见的，如果直接拿rect的高度来计算就会与意图相悖。
 * @param notification 接收到的键盘事件的UINotification对象
 * @param view 要得到的键盘高度是相对于哪个View的键盘高度，若为nil，则等同于调用[QMUIHelper keyboardHeightWithNotification:]
 * @warning 如果view.window为空（当前View尚不可见），则会使用App默认的UIWindow来做坐标转换，可能会导致一些计算错误
 * @return 键盘在view里的可视高度
 */
+ (CGFloat)keyboardHeightWithNotification:(nullable NSNotification *)notification inView:(nullable UIView *)view;

/// 获取键盘显示/隐藏的动画时长，注意返回值可能为0
+ (NSTimeInterval)keyboardAnimationDurationWithNotification:(nullable NSNotification *)notification;

/// 获取键盘显示/隐藏的动画时间函数
+ (UIViewAnimationCurve)keyboardAnimationCurveWithNotification:(nullable NSNotification *)notification;

/// 获取键盘显示/隐藏的动画时间函数
+ (UIViewAnimationOptions)keyboardAnimationOptionsWithNotification:(nullable NSNotification *)notification;
@end


@interface QMUIHelper (AudioSession)

/**
 *  听筒和扬声器的切换
 *
 *  @param speaker   是否转为扬声器，NO则听筒
 *  @param temporary 决定使用kAudioSessionProperty_OverrideAudioRoute还是kAudioSessionProperty_OverrideCategoryDefaultToSpeaker，两者的区别请查看本组的博客文章:http://km.oa.com/group/gyui/articles/show/235957
 */
+ (void)redirectAudioRouteWithSpeaker:(BOOL)speaker temporary:(BOOL)temporary;

/**
 *  设置category
 *
 *  @param category 使用iOS7的category，iOS6的会自动适配
 */
+ (void)setAudioSessionCategory:(nullable NSString *)category;
@end

@interface QMUIHelper (UIGraphic)

/// 获取一像素的大小
@property(class, nonatomic, readonly) CGFloat pixelOne;

/// 判断size是否超出范围
+ (void)inspectContextSize:(CGSize)size;

/// context是否合法
+ (BOOL)inspectContextIfInvalidated:(CGContextRef)context;
@end


@interface QMUIHelper (Device)

/// 如 iPhone12,5、iPad6,8
/// @NEW_DEVICE_CHECKER
@property(class, nonatomic, readonly) NSString *deviceModel;

/// 如 iPhone 11 Pro Max、iPad Pro (12.9 inch)，如果是模拟器，会在后面带上“ Simulator”字样。
/// @NEW_DEVICE_CHECKER
@property(class, nonatomic, readonly) NSString *deviceName;

@property(class, nonatomic, readonly) BOOL isIPad;
@property(class, nonatomic, readonly) BOOL isIPod;
@property(class, nonatomic, readonly) BOOL isIPhone;
@property(class, nonatomic, readonly) BOOL isSimulator;
@property(class, nonatomic, readonly) BOOL isMac;

/// 带物理凹槽的刘海屏或者使用 Home Indicator 类型的设备
/// @NEW_DEVICE_CHECKER
@property(class, nonatomic, readonly) BOOL isNotchedScreen;

/// 将屏幕分为普通和紧凑两种，这个方法用于判断普通屏幕（也即大屏幕）。
/// @note 注意，这里普通/紧凑的标准是 QMUI 自行制定的，与系统 UITraitCollection.horizontalSizeClass/verticalSizeClass 的值无关。只要是通常意义上的“大屏幕手机”（例如 Plus 系列）都会被视为 Regular Screen。
/// @NEW_DEVICE_CHECKER
@property(class, nonatomic, readonly) BOOL isRegularScreen;

/// iPhone 12 Pro Max
@property(class, nonatomic, readonly) BOOL is67InchScreen;

/// iPhone XS Max / 11 Pro Max
@property(class, nonatomic, readonly) BOOL is65InchScreen;

/// iPhone 12 / 12 Pro
@property(class, nonatomic, readonly) BOOL is61InchScreenAndiPhone12Later;

/// iPhone XR / 11
@property(class, nonatomic, readonly) BOOL is61InchScreen;

/// iPhone X / XS / 11Pro
@property(class, nonatomic, readonly) BOOL is58InchScreen;

/// iPhone 8 Plus
@property(class, nonatomic, readonly) BOOL is55InchScreen;

/// iPhone 12 mini
@property(class, nonatomic, readonly) BOOL is54InchScreen;

/// iPhone 8
@property(class, nonatomic, readonly) BOOL is47InchScreen;

/// iPhone 5
@property(class, nonatomic, readonly) BOOL is40InchScreen;

/// iPhone 4
@property(class, nonatomic, readonly) BOOL is35InchScreen;

@property(class, nonatomic, readonly) CGSize screenSizeFor67Inch;
@property(class, nonatomic, readonly) CGSize screenSizeFor65Inch;
@property(class, nonatomic, readonly) CGSize screenSizeFor61InchAndiPhone12Later;
@property(class, nonatomic, readonly) CGSize screenSizeFor61Inch;
@property(class, nonatomic, readonly) CGSize screenSizeFor58Inch;
@property(class, nonatomic, readonly) CGSize screenSizeFor55Inch;
@property(class, nonatomic, readonly) CGSize screenSizeFor54Inch;
@property(class, nonatomic, readonly) CGSize screenSizeFor47Inch;
@property(class, nonatomic, readonly) CGSize screenSizeFor40Inch;
@property(class, nonatomic, readonly) CGSize screenSizeFor35Inch;

@property(class, nonatomic, readonly) CGFloat preferredLayoutAsSimilarScreenWidthForIPad;

/// 用于获取 isNotchedScreen 设备的 insets，注意对于无 Home 键的新款 iPad 而言，它不一定有物理凹槽，但因为使用了 Home Indicator，所以它的 safeAreaInsets 也是非0。
/// @NEW_DEVICE_CHECKER
@property(class, nonatomic, readonly) UIEdgeInsets safeAreaInsetsForDeviceWithNotch;

/// 判断当前设备是否高性能设备，只会判断一次，以后都直接读取结果，所以没有性能问题
@property(class, nonatomic, readonly) BOOL isHighPerformanceDevice;

/// 系统设置里是否开启了“放大显示-试图-放大”，支持放大模式的 iPhone 设备可在官方文档中查询 https://support.apple.com/zh-cn/guide/iphone/iphd6804774e/ios
/// @NEW_DEVICE_CHECKER
@property(class, nonatomic, readonly) BOOL isZoomedMode;

/**
 在 iPad 分屏模式下可获得实际运行区域的窗口大小，如需适配 iPad 分屏，建议用这个方法来代替 [UIScreen mainScreen].bounds.size
 @return 应用运行的窗口大小
 */
@property(class, nonatomic, readonly) CGSize applicationSize;

@end

@interface QMUIHelper (UIApplication)

/**
 * 把App的主要window置灰，用于浮层弹出时，请注意要在适当时机调用`resetDimmedApplicationWindow`恢复到正常状态
 */
+ (void)dimmedApplicationWindow;

/**
 * 恢复对App的主要window的置灰操作，与`dimmedApplicationWindow`成对调用
 */
+ (void)resetDimmedApplicationWindow;

/**
 * 黑色的 StatusBarStyle，用于亮色背景
 * @note 在 iOS 13 以前  UIStatusBarStyleDefault 状态栏内容的颜色固定是黑色的，而在 iOS 13 UIStatusBarStyleDefault 会根据 user interface style 来决定状态栏的颜色，如果你需要一直黑色可以用 QMUIStatusBarStyleDarkContent 来代替以前 UIStatusBarStyleDefault 的写法
 * @return 在 iOS 13 以上返回 UIStatusBarStyleDarkContent，在 iOS 12 及以下返回 UIStatusBarStyleDefault
*/
@property(class, nonatomic, readonly) UIStatusBarStyle statusBarStyleDarkContent;

/**
 在非 UIApplicationStateActive 的时机去设置 UIAppearance 可能引发第三方输入法 crash，因此提供这个方法判断当前是否可以更新 UIAppearance。
 详情请见 https://github.com/Tencent/QMUI_iOS/issues/1281
 */
@property(class, nonatomic, assign, readonly) BOOL canUpdateAppearance;

@end

@interface QMUIHelper (Animation)

/**
 在 animationBlock 里的操作完成之后会调用 completionBlock，常用于一些不提供 completionBlock 的系统动画操作。

 @param animationBlock 要进行的带动画的操作
 @param completionBlock 操作完成后的回调
 @note 注意 UIScrollView 系列的滚动无法使用这个方法。
 */
+ (void)executeAnimationBlock:(nonnull __attribute__((noescape)) void (^)(void))animationBlock completionBlock:(nullable __attribute__((noescape)) void (^)(void))completionBlock;

@end

NS_ASSUME_NONNULL_END
