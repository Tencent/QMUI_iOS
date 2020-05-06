/**
 * Tencent is pleased to support the open source community by making QMUI_iOS available.
 * Copyright (C) 2016-2020 THL A29 Limited, a Tencent company. All rights reserved.
 * Licensed under the MIT License (the "License"); you may not use this file except in compliance with the License. You may obtain a copy of the License at
 * http://opensource.org/licenses/MIT
 * Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.
 */

//
//  QMUIKeyboardManager.h
//  qmui
//
//  Created by QMUI Team on 2017/3/23.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@protocol QMUIKeyboardManagerDelegate;
@class QMUIKeyboardUserInfo;

/// 注意：由于某些Bug（例如 iOS 8 的 iPad 修改切换键盘类型，delegate 回调键盘高度值错误），QMUIKeyboardManager 不再支持 iPad 的浮动键盘了 - 更新于 2017.12.8 ///
/// 注意：QMUI 已经废弃 iOS8 了，所以浮动键盘又可以支持了

/**
 *  `QMUIKeyboardManager` 提供了方便管理键盘事件的方案，使用的场景是需要跟随键盘的显示或者隐藏来更改界面的 UI，例如输入框跟随在键盘的顶部。
 *  由于键盘通知是整个 App 全局的，所以经常会遇到 A 的键盘监听回调里接收到 B 的键盘事件，这样的情况往往不是我们想要的，即使可以通过判断当前的 firstResponder 来区分，但还是不能完美的解决问题或者有时候解决起来非常麻烦。`QMUIKeyboardManager` 通过 `delegateEnabled` 和 `targetResponder` 等属性来方便地控制 firstResponder，从而可以实现某个键盘监听回调方法只响应某个 UIResponder 或者某几个 UIResponder 触发的键盘通知。
 *  使用方式：
 *  1. 使用 initWithDelegate: 方法初始化
 *  2. 通过 addTargetResponder: 的方式将要监听的输入框添加进来
 *  3. 在 delegate 方法里（一般用 keyboardWillChangeFrameWithUserInfo:）处理键盘位置变化时的布局
 *
 *  另外 QMUIKeyboardManager 同时集成在了 UITextField(QMUI) 和 UITextView(QMUI) 里，具体请查看对应文件。
 *  @see UITextField(QMUI)
 *  @see UITextView(QMUI)
 */
@interface QMUIKeyboardManager : NSObject

/**
 *  指定初始化方法，以 delegate 的方式将键盘事件传递给监听者
 */
- (instancetype)initWithDelegate:(id<QMUIKeyboardManagerDelegate>)delegate NS_DESIGNATED_INITIALIZER;

/**
 *  获取当前的 delegate
 */
@property(nonatomic, weak, readonly) id<QMUIKeyboardManagerDelegate> delegate;

/**
 *  是否允许触发delegate的回调，常见的场景例如在 UIViewController viewWillAppear: 里打开，在 viewWillDisappear: 里关闭，从而避免在键盘升起的状态下手势返回时界面布局会跟着键盘往下移动。
 *  默认为 YES。
 */
@property(nonatomic, assign) BOOL delegateEnabled;

/**
 *  是否忽视 `applicationState` 状态的影响。默认为 NO，也即只有 `UIApplicationStateActive` 才会响应通知，如果设置为 YES，则任何 state 都会响应通知。
 */
@property(nonatomic, assign) BOOL ignoreApplicationState;

/**
 *  添加触发键盘事件的 UIResponder，一般是 UITextView 或者 UITextField ，不添加 targetResponder 的话，则默认接受任何 UIResponder 产生的键盘通知。
 *  添加成功将会返回YES，否则返回NO。
 */
- (BOOL)addTargetResponder:(UIResponder *)targetResponder;

/**
 *  获取当前所有的 target UIResponder，若不存在则返回 nil
 */
- (NSArray<UIResponder *> *)allTargetResponders;

/**
 *  移除 targetResponder 跟 keyboardManager 的关系，如果成功会返回 YES
 */
- (BOOL)removeTargetResponder:(UIResponder *)targetResponder;

/**
 *  把键盘的rect转为相对于view的rect。一般用来把键盘的rect转化为相对于当前 self.view 的 rect，然后获取 y 值来布局对应的 view（这里一般不要获取键盘的高度，因为对于iPad的键盘，浮动状态下键盘的高度往往不是我们想要的）。
 *  @param rect 键盘的rect，一般拿 keyboardUserInfo.endFrame
 *  @param view 一个特定的view或者window，如果传入nil则相对有当前的 mainWindow
 */
+ (CGRect)convertKeyboardRect:(CGRect)rect toView:(UIView *)view;

/**
 *  获取键盘到顶部到相对于view底部的距离，这个值在某些情况下会等于endFrame.size.height或者visibleKeyboardHeight，不过在iPad浮动键盘的时候就包括了底部的空隙。所以建议使用这个方法。
 */
+ (CGFloat)distanceFromMinYToBottomInView:(UIView *)view keyboardRect:(CGRect)rect;

/**
 *  根据键盘的动画参数自己构建一个动画，调用者只需要设置view的位置即可
 */
+ (void)animateWithAnimated:(BOOL)animated keyboardUserInfo:(QMUIKeyboardUserInfo *)keyboardUserInfo animations:(void (^)(void))animations completion:(void (^)(BOOL finished))completion;

/**
 *  这个方法特殊处理 iPad Pro 外接键盘的情况。使用外接键盘在完全不显示键盘的时候，不会调用willShow的通知，所以导致一些通过willShow回调来显示targetResponder的场景（例如微信朋友圈的评论输入框）无法把targetResponder正常的显示出来。通过这个方法，你只需要关心你的show和hide的状态就好了，不需要关心是否 iPad Pro 的情况。
 *  @param showBlock 键盘显示回调的block，不能把showBlock理解为系统的show通知，而是你有输入框聚焦了并且期望键盘显示出来。
 *  @param hideBlock 键盘隐藏回调的block，不能把hideBlock理解为系统的hide通知，而是键盘即将消失在界面上并且你期望跟随键盘变化的UI回到默认状态。
 */
+ (void)handleKeyboardNotificationWithUserInfo:(QMUIKeyboardUserInfo *)keyboardUserInfo showBlock:(void (^)(QMUIKeyboardUserInfo *keyboardUserInfo))showBlock hideBlock:(void (^)(QMUIKeyboardUserInfo *keyboardUserInfo))hideBlock;

/**
 *  键盘面板的私有view，可能为nil
 */
+ (UIView *)keyboardView;

/**
 *  键盘面板所在的私有window，可能为nil
 */
+ (UIWindow *)keyboardWindow;

/**
 *  是否有键盘在显示
 */
+ (BOOL)isKeyboardVisible;

/**
 *  当期那键盘相对于屏幕的frame
 */
+ (CGRect)currentKeyboardFrame;

/**
 *  当前键盘高度键盘的可见高度
 */
+ (CGFloat)visibleKeyboardHeight;

@end


@interface QMUIKeyboardUserInfo : NSObject

/**
 *  所在的KeyboardManager
 */
@property(nonatomic, weak, readonly) QMUIKeyboardManager *keyboardManager;

/**
 *  当前键盘的notification
 */
@property(nonatomic, strong, readonly) NSNotification *notification;

/**
 *  notification自带的userInfo
 */
@property(nonatomic, strong, readonly) NSDictionary *originUserInfo;

/**
 *  触发键盘事件的UIResponder，注意这里的 `targetResponder` 不一定是通过 `addTargetResponder:` 添加的 UIResponder，而是当前触发键盘事件的 UIResponder。
 */
@property(nonatomic, weak, readonly) UIResponder *targetResponder;

/**
 *  获取键盘实际宽度
 */
@property(nonatomic, assign, readonly) CGFloat width;

/**
 *  获取键盘的实际高度
 */
@property(nonatomic, assign, readonly) CGFloat height;

/**
 *  获取当前键盘在view上的可见高度，也就是键盘和view重叠的高度。如果view=nil，则直接返回键盘的实际高度。
 */
- (CGFloat)heightInView:(UIView *)view;

/**
 *  获取键盘beginFrame
 */
@property(nonatomic, assign, readonly) CGRect beginFrame;

/**
 *  获取键盘endFrame
 */
@property(nonatomic, assign, readonly) CGRect endFrame;

/**
 *  获取键盘出现动画的duration，对于第三方键盘，这个值有可能为0
 */
@property(nonatomic, assign, readonly) NSTimeInterval animationDuration;

/**
 *  获取键盘动画的Curve参数
 */
@property(nonatomic, assign, readonly) UIViewAnimationCurve animationCurve;

/**
 *  获取键盘动画的Options参数
 */
@property(nonatomic, assign, readonly) UIViewAnimationOptions animationOptions;

@end


/**
 *  `QMUIKeyboardManagerDelegate`里面的方法是对应系统键盘通知的回调方法，具体请看delegate名字，`QMUIKeyboardUserInfo`是对系统的userInfo做了一个封装，可以方便的获取userInfo的属性值。
 */
@protocol QMUIKeyboardManagerDelegate <NSObject>

@optional

/**
 *  键盘即将显示
 */
- (void)keyboardWillShowWithUserInfo:(QMUIKeyboardUserInfo *)keyboardUserInfo;

/**
 *  键盘即将隐藏
 */
- (void)keyboardWillHideWithUserInfo:(QMUIKeyboardUserInfo *)keyboardUserInfo;

/**
 *  键盘frame即将发生变化。
 *  这个delegate除了对应系统的willChangeFrame通知外，在iPad下还增加了监听键盘frame变化的KVO来处理浮动键盘，所以调用次数会比系统默认多。需要让界面或者某个view跟随键盘运动，建议在这个通知delegate里面实现，因为willShow和willHide在手机上是准确的，但是在iPad的浮动键盘下是不准确的。另外，如果不需要跟随浮动键盘运动，那么在逻辑代码里面可以通过判断键盘的位置来过滤这种浮动的情况。
 */
- (void)keyboardWillChangeFrameWithUserInfo:(QMUIKeyboardUserInfo *)keyboardUserInfo;

/**
 *  键盘已经显示
 */
- (void)keyboardDidShowWithUserInfo:(QMUIKeyboardUserInfo *)keyboardUserInfo;

/**
 *  键盘已经隐藏
 */
- (void)keyboardDidHideWithUserInfo:(QMUIKeyboardUserInfo *)keyboardUserInfo;

/**
 *  键盘frame已经发生变化。
 */
- (void)keyboardDidChangeFrameWithUserInfo:(QMUIKeyboardUserInfo *)keyboardUserInfo;

@end

@interface UIResponder (KeyboardManager)

/// 持有KeyboardManager对象
@property(nonatomic, strong) QMUIKeyboardManager *qmui_keyboardManager;

@end

@interface UITextField (QMUI_KeyboardManager)

/// 键盘相关block，搭配QMUIKeyboardManager一起使用

@property(nonatomic, copy) void (^qmui_keyboardWillShowNotificationBlock)(QMUIKeyboardUserInfo *keyboardUserInfo);
@property(nonatomic, copy) void (^qmui_keyboardWillHideNotificationBlock)(QMUIKeyboardUserInfo *keyboardUserInfo);
@property(nonatomic, copy) void (^qmui_keyboardWillChangeFrameNotificationBlock)(QMUIKeyboardUserInfo *keyboardUserInfo);
@property(nonatomic, copy) void (^qmui_keyboardDidShowNotificationBlock)(QMUIKeyboardUserInfo *keyboardUserInfo);
@property(nonatomic, copy) void (^qmui_keyboardDidHideNotificationBlock)(QMUIKeyboardUserInfo *keyboardUserInfo);
@property(nonatomic, copy) void (^qmui_keyboardDidChangeFrameNotificationBlock)(QMUIKeyboardUserInfo *keyboardUserInfo);

@end

@interface UITextView (QMUI_KeyboardManager)

/// 键盘相关block，搭配QMUIKeyboardManager一起使用

@property(nonatomic, copy) void (^qmui_keyboardWillShowNotificationBlock)(QMUIKeyboardUserInfo *keyboardUserInfo);
@property(nonatomic, copy) void (^qmui_keyboardWillHideNotificationBlock)(QMUIKeyboardUserInfo *keyboardUserInfo);
@property(nonatomic, copy) void (^qmui_keyboardWillChangeFrameNotificationBlock)(QMUIKeyboardUserInfo *keyboardUserInfo);
@property(nonatomic, copy) void (^qmui_keyboardDidShowNotificationBlock)(QMUIKeyboardUserInfo *keyboardUserInfo);
@property(nonatomic, copy) void (^qmui_keyboardDidHideNotificationBlock)(QMUIKeyboardUserInfo *keyboardUserInfo);
@property(nonatomic, copy) void (^qmui_keyboardDidChangeFrameNotificationBlock)(QMUIKeyboardUserInfo *keyboardUserInfo);

@end
