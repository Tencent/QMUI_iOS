//
//  QMUIPopupContainerView.h
//  qmui
//
//  Created by MoLice on 15/12/17.
//  Copyright © 2015年 QMUI Team. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIControl+QMUI.h"

typedef enum {
    QMUIPopupContainerViewLayoutDirectionAbove,
    QMUIPopupContainerViewLayoutDirectionBelow
} QMUIPopupContainerViewLayoutDirection;

/**
 * 带箭头的小tips浮层，自带 imageView 和 textLabel，可展示简单的图文信息。
 * QMUIPopupContainerView 支持以两种方式显示在界面上：
 * 1. 添加到某个 UIView 上（适合于 viewController 切换时浮层跟着一起切换的场景），这种场景只能手动隐藏浮层。
 * 2. 在 QMUIPopupContainerView 自带的 UIWindow 里显示（适合于用完就消失的场景，不要涉及界面切换），这种场景支持点击空白地方自动隐藏浮层。
 *
 * 使用步骤：
 * 1. 调用 init 方法初始化。
 * 2. 选择一种显示方式：
 * 2.1 如果要添加到某个 UIView 上，则先设置浮层 hidden = YES，然后调用 addSubview: 把浮层添加到目标 UIView 上。
 * 2.2 如果是轻量的场景用完即走，则 init 完浮层即可，无需设置 hidden，也无需调用 addSubview:，在后面第 4 步里会自动把浮层添加到 UIWindow 上显示出来。
 * 3. 在适当的时机（例如 layoutSubviews: 或 viewDidLayoutSubviews:）调用 layoutWithTargetView: 让浮层参考目标 view 布局，或者调用 layoutWithTargetRectInScreenCoordinate: 让浮层参考基于屏幕坐标系里的一个 rect 来布局。
 * 4. 调用 showWithAnimated: 或 showWithAnimated:completion: 显示浮层。
 * 5. 调用 hideWithAnimated: 或 hideWithAnimated:completion: 隐藏浮层。
 *
 * @warning 如果使用方法 2.2，并且没有打开 automaticallyHidesWhenUserTap 属性，则记得在适当的时机（例如 viewWillDisappear:）隐藏浮层。
 *
 * 如果默认功能无法满足需求，可继承它重写一个子类，继承要点：
 * 1. 初始化时要做的事情请放在 didInitialized 里。
 * 2. 所有 subviews 请加到 contentView 上。
 * 3. 通过重写 sizeThatFitsInContentView:，在里面返回当前 subviews 的大小，控件最终会被布局为这个大小。
 * 4. 在 layoutSubviews: 里，所有 subviews 请相对于 contentView 布局。
 */

@interface QMUIPopupContainerView : UIControl {
    CAShapeLayer    *_backgroundLayer;
    CGFloat         _arrowMinX;
}

@property(nonatomic, assign) BOOL debug;

/// 在浮层显示时，点击空白地方是否要自动隐藏浮层，仅在用方法 2 显示时有效。
/// 默认为 NO，也即需要手动调用代码去隐藏浮层。
@property(nonatomic, assign) BOOL automaticallyHidesWhenUserTap;

/// 所有subview都应该添加到contentView上，默认contentView.userInteractionEnabled = NO，需要事件操作时自行打开
@property(nonatomic, strong, readonly) UIView *contentView;

/// 预提供的UIImageView，默认为nil，调用到的时候才初始化
@property(nonatomic, strong, readonly) UIImageView *imageView;

/// 预提供的UILabel，默认为nil，调用到的时候才初始化。默认支持多行。
@property(nonatomic, strong, readonly) UILabel *textLabel;

/// 圆角矩形气泡内的padding（不包括三角箭头），默认是(8, 8, 8, 8)
@property(nonatomic, assign) UIEdgeInsets contentEdgeInsets UI_APPEARANCE_SELECTOR;

/// 调整imageView的位置，默认为UIEdgeInsetsZero。top/left正值表示往下/右方偏移，bottom/right仅在对应位置存在下一个子View时生效（例如只有同时存在imageView和textLabel时，imageEdgeInsets.right才会生效）。
@property(nonatomic, assign) UIEdgeInsets imageEdgeInsets UI_APPEARANCE_SELECTOR;

/// 调整textLabel的位置，默认为UIEdgeInsetsZero。top/left/bottom/right的作用同<i>imageEdgeInsets</i>
@property(nonatomic, assign) UIEdgeInsets textEdgeInsets UI_APPEARANCE_SELECTOR;

/// 三角箭头的大小，默认为 CGSizeMake(18, 9)
@property(nonatomic, assign) CGSize arrowSize UI_APPEARANCE_SELECTOR;

/// 最大宽度（指整个控件的宽度，而不是contentView部分），默认为CGFLOAT_MAX
@property(nonatomic, assign) CGFloat maximumWidth UI_APPEARANCE_SELECTOR;

/// 最小宽度（指整个控件的宽度，而不是contentView部分），默认为0
@property(nonatomic, assign) CGFloat minimumWidth UI_APPEARANCE_SELECTOR;

/// 最大高度（指整个控件的高度，而不是contentView部分），默认为CGFLOAT_MAX
@property(nonatomic, assign) CGFloat maximumHeight UI_APPEARANCE_SELECTOR;

/// 最小高度（指整个控件的高度，而不是contentView部分），默认为0
@property(nonatomic, assign) CGFloat minimumHeight UI_APPEARANCE_SELECTOR;

/// 计算布局时期望的默认位置，默认为QMUIPopupContainerViewLayoutDirectionAbove，也即在目标的上方
@property(nonatomic, assign) QMUIPopupContainerViewLayoutDirection preferLayoutDirection UI_APPEARANCE_SELECTOR;

/// 最终的布局方向（preferLayoutDirection只是期望的方向，但有可能那个方向已经没有剩余空间可摆放控件了，所以会自动变换）
@property(nonatomic, assign, readonly) QMUIPopupContainerViewLayoutDirection currentLayoutDirection;

/// 最终布局时箭头距离目标边缘的距离，默认为5
@property(nonatomic, assign) CGFloat distanceBetweenTargetRect UI_APPEARANCE_SELECTOR;

/// 最终布局时与父节点的边缘的临界点，默认为(10, 10, 10, 10)
@property(nonatomic, assign) UIEdgeInsets safetyMarginsOfSuperview UI_APPEARANCE_SELECTOR;

@property(nonatomic, strong) UIColor *backgroundColor UI_APPEARANCE_SELECTOR;
@property(nonatomic, strong) UIColor *highlightedBackgroundColor UI_APPEARANCE_SELECTOR;

/// 当使用方法 2 显示并且打开了 automaticallyHidesWhenUserTap 时，可修改背景遮罩的颜色，默认为 UIColorMask，若非使用方法 2，或者没有打开 automaticallyHidesWhenUserTap，则背景遮罩为透明（可视为不存在背景遮罩）
@property(nonatomic, strong) UIColor *maskViewBackgroundColor UI_APPEARANCE_SELECTOR;
@property(nonatomic, strong) UIColor *shadowColor UI_APPEARANCE_SELECTOR;
@property(nonatomic, strong) UIColor *borderColor UI_APPEARANCE_SELECTOR;
@property(nonatomic, assign) CGFloat borderWidth UI_APPEARANCE_SELECTOR;
@property(nonatomic, assign) CGFloat cornerRadius UI_APPEARANCE_SELECTOR;

/**
 *  相对于某个 view 布局（布局后箭头不一定会水平居中）
 *  @param targetView 注意如果这个 targetView 自身的布局发生变化，需要重新调用 layoutWithTargetView:，否则浮层的布局不会自动更新。
 */
- (void)layoutWithTargetView:(UIView *)targetView;

/**
 * 相对于给定的 itemRect 布局（布局后箭头不一定会水平居中）
 * @param targetRect 注意这个 rect 应该是处于屏幕坐标系里的 rect，所以请自行做坐标系转换。
 */
- (void)layoutWithTargetRectInScreenCoordinate:(CGRect)targetRect;

- (void)showWithAnimated:(BOOL)animated;
- (void)showWithAnimated:(BOOL)animated completion:(void (^)(BOOL finished))completion;
- (void)hideWithAnimated:(BOOL)animated;
- (void)hideWithAnimated:(BOOL)animated completion:(void (^)(BOOL finished))completion;
- (BOOL)isShowing;

/**
 *  即将隐藏时的回调
 *  @argv hidesByUserTap 用于区分此次隐藏是否因为用户手动点击空白区域导致浮层被隐藏
 */
@property(nonatomic, copy) void (^willHideBlock)(BOOL hidesByUserTap);

/**
 *  已经隐藏后的回调
 *  @argv hidesByUserTap 用于区分此次隐藏是否因为用户手动点击空白区域导致浮层被隐藏
 */
@property(nonatomic, copy) void (^didHideBlock)(BOOL hidesByUserTap);
@end

@interface QMUIPopupContainerView (UISubclassingHooks)

/// 子类重写，在初始化时做一些操作
- (void)didInitialized NS_REQUIRES_SUPER;

/// 子类重写，告诉父类subviews的合适大小
- (CGSize)sizeThatFitsInContentView:(CGSize)size;
@end
