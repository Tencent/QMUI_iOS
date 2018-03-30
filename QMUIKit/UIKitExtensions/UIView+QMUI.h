//
//  UIView+QMUI.h
//  qmui
//
//  Created by QMUI Team on 15/7/20.
//  Copyright (c) 2015年 QMUI Team. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIView (QMUI)

/**
 *  相当于 initWithFrame:CGRectMake(0, 0, size.width, size.height)
 */
- (instancetype)qmui_initWithSize:(CGSize)size;

/// 在 iOS 11 及之后的版本，此属性将返回系统已有的 self.safeAreaInsets。在之前的版本此属性返回 UIEdgeInsetsZero
@property(nonatomic, assign, readonly) UIEdgeInsets qmui_safeAreaInsets;

- (void)qmui_removeAllSubviews;

+ (void)qmui_animateWithAnimated:(BOOL)animated duration:(NSTimeInterval)duration delay:(NSTimeInterval)delay options:(UIViewAnimationOptions)options animations:(void (^)(void))animations completion:(void (^ __nullable)(BOOL finished))completion;
+ (void)qmui_animateWithAnimated:(BOOL)animated duration:(NSTimeInterval)duration animations:(void (^ __nullable)(void))animations completion:(void (^)(BOOL finished))completion;
+ (void)qmui_animateWithAnimated:(BOOL)animated duration:(NSTimeInterval)duration animations:(void (^ __nullable)(void))animations;
+ (void)qmui_animateWithAnimated:(BOOL)animated duration:(NSTimeInterval)duration delay:(NSTimeInterval)delay usingSpringWithDamping:(CGFloat)dampingRatio initialSpringVelocity:(CGFloat)velocity options:(UIViewAnimationOptions)options animations:(void (^)(void))animations completion:(void (^)(BOOL finished))completion;
@end

@interface UIView (QMUI_Runtime)

/**
 *  判断当前类是否有重写某个指定的 UIView 的方法
 *  @param selector 要判断的方法
 *  @return YES 表示当前类重写了指定的方法，NO 表示没有重写，使用的是 UIView 默认的实现
 */
- (BOOL)qmui_hasOverrideUIKitMethod:(SEL)selector;
@end


/**
 *  Debug UIView 的时候用，对某个 view 的 subviews 都添加一个半透明的背景色，方面查看 view 的布局情况
 */
@interface UIView (QMUI_Debug)

/// 是否需要添加debug背景色，默认NO
@property(nonatomic, assign) BOOL qmui_shouldShowDebugColor;
/// 是否每个view的背景色随机，如果不随机则统一使用半透明红色，默认NO
@property(nonatomic, assign) BOOL qmui_needsDifferentDebugColor;
/// 标记一个view是否已经被添加了debug背景色，外部一般不使用
@property(nonatomic, assign, readonly) BOOL qmui_hasDebugColor;

@end


typedef NS_OPTIONS(NSUInteger, QMUIBorderViewPosition) {
    QMUIBorderViewPositionNone      = 0,
    QMUIBorderViewPositionTop       = 1 << 0,
    QMUIBorderViewPositionLeft      = 1 << 1,
    QMUIBorderViewPositionBottom    = 1 << 2,
    QMUIBorderViewPositionRight     = 1 << 3
};

/**
 *  UIView (QMUI_Border) 为 UIView 方便地显示某几个方向上的边框。
 *
 *  系统的默认实现里，要为 UIView 加边框一般是通过 view.layer 来实现，view.layer 会给四条边都加上边框，如果你只想为其中某几条加上边框就很麻烦，于是 UIView (QMUI_Border) 提供了 qmui_borderPosition 来解决这个问题。
 *  @warning 注意如果你需要为 UIView 四条边都加上边框，请使用系统默认的 view.layer 来实现，而不要用 UIView (QMUI_Border)，会浪费资源，这也是为什么 QMUIBorderViewPosition 不提供一个 QMUIBorderViewPositionAll 枚举值的原因。
 */
@interface UIView (QMUI_Border)

/// 设置边框类型，支持组合，例如：`borderPosition = QMUIBorderViewPositionTop|QMUIBorderViewPositionBottom`
@property(nonatomic, assign) QMUIBorderViewPosition qmui_borderPosition;

/// 边框的大小，默认为PixelOne
@property(nonatomic, assign) IBInspectable CGFloat qmui_borderWidth;

/// 边框的颜色，默认为UIColorSeparator
@property(nonatomic, strong) IBInspectable UIColor *qmui_borderColor;

/// 虚线 : dashPhase默认是0，且当dashPattern设置了才有效
/// qmui_dashPhase 表示虚线起始的偏移，qmui_dashPattern 可以传一个数组，表示“lineWidth，lineSpacing，lineWidth，lineSpacing...”的顺序，至少传 2 个。
@property(nonatomic, assign) CGFloat qmui_dashPhase;
@property(nonatomic, copy)   NSArray <NSNumber *> *qmui_dashPattern;

/// border的layer
@property(nonatomic, strong, readonly) CAShapeLayer *qmui_borderLayer;

@end

/**
 *  对 view.frame 操作的简便封装，注意 view 与 view 之间互相计算时，需要保证处于同一个坐标系内。
 */
@interface UIView (QMUI_Layout)

/// 等价于 CGRectGetMinY(frame)
@property(nonatomic, assign) CGFloat qmui_top;

/// 等价于 CGRectGetMinX(frame)
@property(nonatomic, assign) CGFloat qmui_left;

/// 等价于 CGRectGetMaxY(frame)
@property(nonatomic, assign) CGFloat qmui_bottom;

/// 等价于 CGRectGetMaxX(frame)
@property(nonatomic, assign) CGFloat qmui_right;

/// 等价于 CGRectGetWidth(frame)
@property(nonatomic, assign) CGFloat qmui_width;

/// 等价于 CGRectGetHeight(frame)
@property(nonatomic, assign) CGFloat qmui_height;

/// 保持其他三个边缘的位置不变的情况下，将顶边缘拓展到某个指定的位置，注意高度会跟随变化。
@property(nonatomic, assign) CGFloat qmui_extendToTop;

/// 保持其他三个边缘的位置不变的情况下，将左边缘拓展到某个指定的位置，注意宽度会跟随变化。
@property(nonatomic, assign) CGFloat qmui_extendToLeft;

/// 保持其他三个边缘的位置不变的情况下，将底边缘拓展到某个指定的位置，注意高度会跟随变化。
@property(nonatomic, assign) CGFloat qmui_extendToBottom;

/// 保持其他三个边缘的位置不变的情况下，将右边缘拓展到某个指定的位置，注意宽度会跟随变化。
@property(nonatomic, assign) CGFloat qmui_extendToRight;

/// 获取当前 view 在 superview 内水平居中时的 left
@property(nonatomic, assign, readonly) CGFloat qmui_leftWhenCenterInSuperview;

/// 获取当前 view 在 superview 内垂直居中时的 top
@property(nonatomic, assign, readonly) CGFloat qmui_topWhenCenterInSuperview;

@end

/**
 *  方便地将某个 UIView 截图并转成一个 UIImage，注意如果这个 UIView 本身做了 transform，也不会在截图上反映出来，截图始终都是原始 UIView 的截图。
 */
@interface UIView (QMUI_Snapshotting)

- (UIImage *)qmui_snapshotLayerImage;
- (UIImage *)qmui_snapshotImageAfterScreenUpdates:(BOOL)afterScreenUpdates;
@end

NS_ASSUME_NONNULL_END
