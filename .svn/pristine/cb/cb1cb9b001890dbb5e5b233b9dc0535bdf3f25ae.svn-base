//
//  QMUIToastView.h
//  qmui
//
//  Created by zhoonchen on 2016/12/11.
//  Copyright © 2016年 QMUI Team. All rights reserved.
//

#import <UIKit/UIKit.h>

@class QMUIToastView;
@class QMUIToastAnimator;


/**
 * `QMUIToastViewDelegate`用来实现QMUIToastView显示和隐藏整个生命周期的回调。
 */
@protocol QMUIToastViewDelegate <NSObject>

/**
 * 即将要显示toastView
 */
- (void)toastView:(QMUIToastView *)toastView willShowInView:(UIView *)view;

/**
 * 已经显示toastView
 */
- (void)toastView:(QMUIToastView *)toastView didShowInView:(UIView *)view;

/**
 * 即将要隐藏toastView
 */
- (void)toastView:(QMUIToastView *)toastView willHideInView:(UIView *)view;

/**
 * 已经隐藏toastView
 */
- (void)toastView:(QMUIToastView *)toastView didHideInView:(UIView *)view;

@end


typedef NS_ENUM(NSInteger, QMUIToastViewPosition) {
    QMUIToastViewPositionTop,
    QMUIToastViewPositionCenter,
    QMUIToastViewPositionBottom
};

/**
 * `QMUIToastView`是一个用来显示toast的控件，其主要结构包括：`backgroundView`、`contentView`，这两个view都是通过外部赋值获取，默认使用`QMUIToastBackgroundView`和`QMUIToastContentView`。
 *
 * 拓展性：`QMUIToastBackgroundView`和`QMUIToastContentView`是QMUI提供的默认的view，这两个view都可以通过appearance来修改样式，如果这两个view满足不了需求，那么也可以通过新建自定义的view来代替这两个view。另外，QMUI也提供了默认的toastAnimator来实现ToastView的显示和隐藏动画，如果需要重新定义一套动画，可以继承`QMUIToastAnimator`并且实现`QMUIToastViewAnimatorDelegate`中的协议就可以自定义自己的一套动画。
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
- (instancetype)initWithView:(UIView *)view NS_DESIGNATED_INITIALIZER;

/**
 * parentView是ToastView初始化的时候穿进去的那个view。
 */
@property(nonatomic, weak, readonly) UIView *parentView;

/**
 * delegate
 */
@property(nonatomic, weak) id <QMUIToastViewDelegate> delegate;

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

/**
 * `QMUIToastAnimator`可以让你通过实现一些协议来自定义ToastView显示和隐藏的动画。你可以继承`QMUIToastAnimator`，然后实现`QMUIToastAnimatorDelegate`中的方法，即可实现自定义的动画。如果不赋值，则会使用`QMUIToastAnimator`中的默认动画。
 */
@property(nonatomic, strong) QMUIToastAnimator *toastAnimator;

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

/**
 * `contentView`下面的view，可以设置其：背景色、圆角、size等一些属性。
 */
@property(nonatomic, strong) UIView *backgroundView;

/**
 * 所有类型的Toast都是通过给contentView赋值来实现的，每一个contentView都可以自己定义subview以及subview的样式和layout，最终作为ToastView的contentView来显示。如果contentView需要跟随ToastView的tintColor变化而变化，可以重写`tintColorDidChange`来实现。
 */
@property(nonatomic, strong) UIView *contentView;


///////////////////


/**
 * 上下左右的偏移值。
 */
@property(nonatomic, assign) CGPoint offset UI_APPEARANCE_SELECTOR;

/**
 * ToastView距离上下左右的最小间距。
 */
@property(nonatomic, assign) UIEdgeInsets marginInsets UI_APPEARANCE_SELECTOR;

@end


@interface QMUIToastView (ToastTool)

/**
 * 工具方法。隐藏`view`里面的所有ToastView。
 *
 * @param view 即将隐藏的ToastView的superView。
 * @param animated 是否需要通过动画隐藏。
 *
 * @return 如果成功隐藏一个ToastView则返回YES，失败则NO。
 */
+ (BOOL)hideAllToastInView:(UIView *)view animated:(BOOL)animated;

/**
 * 工具方法。返回`view`里面最顶级的ToastView，如果没有则返回nil。
 *
 * @param view ToastView的superView。
 * @return 返回一个QMUIToastView的实例。
 */
+ (instancetype)toastInView:(UIView *)view;

/**
 * 工具方法。返回`view`里面所有的ToastView，如果没有则返回nil。
 *
 * @param view ToastView的superView。
 * @return 包含所有QMUIToastView的数组。
 */
+ (NSArray <QMUIToastView *> *)allToastInView:(UIView *)view;

@end
