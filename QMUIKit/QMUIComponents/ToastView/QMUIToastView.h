/**
 * Tencent is pleased to support the open source community by making QMUI_iOS available.
 * Copyright (C) 2016-2020 THL A29 Limited, a Tencent company. All rights reserved.
 * Licensed under the MIT License (the "License"); you may not use this file except in compliance with the License. You may obtain a copy of the License at
 * http://opensource.org/licenses/MIT
 * Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.
 */

//
//  QMUIToastView.h
//  qmui
//
//  Created by QMUI Team on 2016/12/11.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class QMUIToastAnimator;

typedef NS_ENUM(NSInteger, QMUIToastViewPosition) {
    QMUIToastViewPositionTop,
    QMUIToastViewPositionCenter,
    QMUIToastViewPositionBottom
};

/**
 * `QMUIToastView`是一个用来显示toast的控件，其主要结构包括：`backgroundView`、`contentView`，这两个view都是通过外部赋值获取，默认使用`QMUIToastBackgroundView`和`QMUIToastContentView`。
 *
 * 拓展性：`QMUIToastBackgroundView`和`QMUIToastContentView`是QMUI提供的默认的view，这两个view都可以通过appearance来修改样式，如果这两个view满足不了需求，那么也可以通过新建自定义的view来代替这两个view。另外，QMUI也提供了默认的toastAnimator来实现ToastView的显示和隐藏动画，如果需要重新定义一套动画，可以继承`QMUIToastAnimator`并且实现`QMUIToastAnimatorDelegate`中的协议就可以自定义自己的一套动画。
 *
 * 样式自定义：建议通过 tintColor 统一修改整个 toastView 的内容样式。当然你也可以单独修改 contentView.tintColor。默认情况下 QMUIToastView.tintColor = UIColorWhite。
 *
 * 建议使用`QMUIToastView`的时候，再封装一层，具体可以参考`QMUITips`这个类。
 *
 * @see QMUIToastBackgroundView
 * @see QMUIToastContentView
 * @see QMUIToastAnimator
 * @see QMUITips
 */
@interface QMUIToastView : UIView

/**
 * 生成一个ToastView的唯一初始化方法，`view`的bound将会作为ToastView默认frame。
 *
 * @param view ToastView的superView。
 */
- (nonnull instancetype)initWithView:(nonnull UIView *)view NS_DESIGNATED_INITIALIZER;

/**
 * parentView是ToastView初始化的时候传进去的那个view。
 */
@property(nonatomic, weak, readonly) UIView *parentView;

/**
 * 显示ToastView。
 *
 * @param animated 是否需要通过动画显示。
 *
 * @see toastAnimator
 */
- (void)showAnimated:(BOOL)animated;

/**
 * 隐藏ToastView。
 *
 * @param animated 是否需要通过动画隐藏。
 *
 * @see toastAnimator
 */
- (void)hideAnimated:(BOOL)animated;

/**
 * 在`delay`时间后隐藏ToastView。
 *
 * @param animated 是否需要通过动画隐藏。
 * @param delay 多少秒后隐藏。
 *
 * @see toastAnimator
 */
- (void)hideAnimated:(BOOL)animated afterDelay:(NSTimeInterval)delay;

/// @warning 如果使用 [QMUITips showXxx] 系列快捷方法来显示 tips，willShowBlock 将会在 show 之后才被设置，最终并不会被调用。这种场景建议自己在调用 [QMUITips showXxx] 之前执行一段代码，或者不要使用 [QMUITips showXxx] 的方式显示 tips
@property(nullable, nonatomic, copy) void (^willShowBlock)(UIView *showInView, BOOL animated);
@property(nullable, nonatomic, copy) void (^didShowBlock)(UIView *showInView, BOOL animated);
@property(nullable, nonatomic, copy) void (^willHideBlock)(UIView *hideInView, BOOL animated);
@property(nullable, nonatomic, copy) void (^didHideBlock)(UIView *hideInView, BOOL animated);

/**
 * `QMUIToastAnimator`可以让你通过实现一些协议来自定义ToastView显示和隐藏的动画。你可以继承`QMUIToastAnimator`，然后实现`QMUIToastAnimatorDelegate`中的方法，即可实现自定义的动画。如果不赋值，则会使用`QMUIToastAnimator`中的默认动画。
 */
@property(nullable, nonatomic, strong) QMUIToastAnimator *toastAnimator;

/**
 * 决定QMUIToastView的位置，目前有上中下三个位置，默认值是center。
 
 * 如果设置了top或者bottom，那么ToastView的布局规则是：顶部从marginInsets.top开始往下布局(QMUIToastViewPositionTop) 和 底部从marginInsets.bottom开始往上布局(QMUIToastViewPositionBottom)。
 */
@property(nonatomic, assign) QMUIToastViewPosition toastPosition;

/**
 * 是否在ToastView隐藏的时候顺便把它从superView移除，默认为NO。
 */
@property(nonatomic, assign) BOOL removeFromSuperViewWhenHide;


///////////////////


/**
 * 会盖住整个superView，防止手指可以点击到ToastView下面的内容，默认透明。
 */
@property(nonatomic, strong, readonly) UIView *maskView;

/**s
 * 承载Toast内容的UIView，可以自定义并赋值给contentView。如果contentView需要跟随ToastView的tintColor变化而变化，可以重写自定义view的`tintColorDidChange`来实现。默认使用`QMUIToastContentView`实现。
 */
@property(nonatomic, strong) __kindof UIView *contentView;

/**
 * `contentView`下面的黑色背景UIView，默认使用`QMUIToastBackgroundView`实现，可以通过`QMUIToastBackgroundView`的 cornerRadius 和 styleColor 来修改圆角和背景色。
 */
@property(nonatomic, strong) __kindof UIView *backgroundView;


///////////////////


/**
 * 上下左右的偏移值。
 */
@property(nonatomic, assign) CGPoint offset UI_APPEARANCE_SELECTOR;

/**
 *  ToastView 距离 parentView 去除 safeAreaInsets 后的区域的上下左右间距。
 *
 *  例如当 marginInsets.top = 0 且 toastPosition 为 QMUIToastViewPositionTop 时，如果 parentView 是 viewController.view，则 tips 顶边缘将会紧贴 navigationBar 的底边缘。而如果 parentView 是 navigationController.view，则 tips 顶边缘将会紧贴 statusBar 的底边缘。
 */
@property(nonatomic, assign) UIEdgeInsets marginInsets UI_APPEARANCE_SELECTOR;

@end


@interface QMUIToastView (ToastTool)

/**
 * 工具方法。隐藏`view`里面的所有 ToastView
 *
 * @param view 即将隐藏的 ToastView 的 superView，如果 view = nil 则移除所有内存中的 ToastView
 * @param animated 是否需要通过动画隐藏。
 *
 * @return 如果成功隐藏一个 ToastView 则返回 YES，失败则 NO
 */
+ (BOOL)hideAllToastInView:(UIView * _Nullable)view animated:(BOOL)animated;

/**
 * 工具方法。返回`view`里面最顶部的 ToastView
 *
 * @param view ToastView 的 superView
 * @return 返回一个 QMUIToastView 的实例
 */
+ (nullable __kindof UIView *)toastInView:(UIView *)view;

/**
 * 工具方法。返回`view`里面所有的 ToastView
 *
 * @param view ToastView 的 superView
 * @return 包含所有 view 里面的所有 QMUIToastView，如果 view = nil 则返回所有内存中的 ToastView
 */
+ (nullable NSArray <QMUIToastView *> *)allToastInView:(UIView *)view;

@end

NS_ASSUME_NONNULL_END
