/**
 * Tencent is pleased to support the open source community by making QMUI_iOS available.
 * Copyright (C) 2016-2021 THL A29 Limited, a Tencent company. All rights reserved.
 * Licensed under the MIT License (the "License"); you may not use this file except in compliance with the License. You may obtain a copy of the License at
 * http://opensource.org/licenses/MIT
 * Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.
 */

//
//  UIView+QMUI.h
//  qmui
//
//  Created by QMUI Team on 15/7/20.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import "UIView+QMUIBorder.h"

NS_ASSUME_NONNULL_BEGIN

@interface UIView (QMUI)

/**
 相当于 initWithFrame:CGRectMake(0, 0, size.width, size.height)

 @param size 初始化时的 size
 @return 初始化得到的实例
 */
- (instancetype)qmui_initWithSize:(CGSize)size;

/**
 将要设置的 frame 用 CGRectApplyAffineTransformWithAnchorPoint 处理后再设置
 */
@property(nonatomic, assign) CGRect qmui_frameApplyTransform;

/**
 在 iOS 11 及之后的版本，此属性将返回系统已有的 self.safeAreaInsets。在之前的版本此属性返回 UIEdgeInsetsZero
 */
@property(nonatomic, assign, readonly) UIEdgeInsets qmui_safeAreaInsets;

/**
 有修改过 tintColor，则不会再受 superview.tintColor 的影响
 */
@property(nonatomic, assign, readonly) BOOL qmui_tintColorCustomized;

/// 响应区域需要改变的大小，负值表示往外扩大，正值表示往内缩小
@property(nonatomic,assign) UIEdgeInsets qmui_outsideEdge;

/**
 移除当前所有 subviews
 */
- (void)qmui_removeAllSubviews;

/// 同 [UIView convertPoint:toView:]，但支持在分属两个不同 window 的 view 之间进行坐标转换，也支持参数 view 直接传一个 window。
- (CGPoint)qmui_convertPoint:(CGPoint)point toView:(nullable UIView *)view;

/// 同 [UIView convertPoint:fromView:]，但支持在分属两个不同 window 的 view 之间进行坐标转换，也支持参数 view 直接传一个 window。
- (CGPoint)qmui_convertPoint:(CGPoint)point fromView:(nullable UIView *)view;

/// 同 [UIView convertRect:toView:]，但支持在分属两个不同 window 的 view 之间进行坐标转换，也支持参数 view 直接传一个 window。
- (CGRect)qmui_convertRect:(CGRect)rect toView:(nullable UIView *)view;

/// 同 [UIView convertRect:fromView:]，但支持在分属两个不同 window 的 view 之间进行坐标转换，也支持参数 view 直接传一个 window。
- (CGRect)qmui_convertRect:(CGRect)rect fromView:(nullable UIView *)view;

+ (void)qmui_animateWithAnimated:(BOOL)animated duration:(NSTimeInterval)duration delay:(NSTimeInterval)delay options:(UIViewAnimationOptions)options animations:(void (^)(void))animations completion:(void (^ __nullable)(BOOL finished))completion;
+ (void)qmui_animateWithAnimated:(BOOL)animated duration:(NSTimeInterval)duration animations:(void (^ __nullable)(void))animations completion:(void (^ __nullable)(BOOL finished))completion;
+ (void)qmui_animateWithAnimated:(BOOL)animated duration:(NSTimeInterval)duration animations:(void (^ __nullable)(void))animations;
+ (void)qmui_animateWithAnimated:(BOOL)animated duration:(NSTimeInterval)duration delay:(NSTimeInterval)delay usingSpringWithDamping:(CGFloat)dampingRatio initialSpringVelocity:(CGFloat)velocity options:(UIViewAnimationOptions)options animations:(void (^)(void))animations completion:(void (^)(BOOL finished))completion;
@end


@interface UIView (QMUI_Block)

/**
 在 UIView 的 frame 变化前会调用这个 block，变化途径包括 setFrame:、setBounds:、setCenter:、setTransform:，你可以通过返回一个 rect 来达到修改 frame 的目的，最终执行 [super setFrame:] 时会使用这个 block 的返回值（除了 setTransform: 导致的 frame 变化）。
 @param view 当前的 view 本身，方便使用，省去 weak 操作
 @param followingFrame setFrame: 的参数 frame，也即即将被修改为的 rect 值
 @return 将会真正被使用的 frame 值
 @note 仅当 followingFrame 和 self.frame 值不相等时才会被调用
 */
@property(nullable, nonatomic, copy) CGRect (^qmui_frameWillChangeBlock)(__kindof UIView *view, CGRect followingFrame);

/**
 在 UIView 的 frame 变化后会调用这个 block，变化途径包括 setFrame:、setBounds:、setCenter:、setTransform:，可用于监听布局的变化，或者在不方便重写 layoutSubviews 时使用这个 block 代替。
 @param view 当前的 view 本身，方便使用，省去 weak 操作
 @param precedingFrame 修改前的 frame 值
 */
@property(nullable, nonatomic, copy) void (^qmui_frameDidChangeBlock)(__kindof UIView *view, CGRect precedingFrame);

/**
 在 - [UIView layoutSubviews] 调用后就调用的 block
 @param view 当前的 view 本身，方便使用，省去 weak 操作
 */
@property(nullable, nonatomic, copy) void (^qmui_layoutSubviewsBlock)(__kindof UIView *view);

/**
 在 UIView 的 sizeThatFits: 调用后就调用的 block，可返回一个修改后的值来作为原方法的返回值
 @param view 当前的 view 本身，方便使用，省去 weak 操作
 @param size sizeThatFits: 方法被调用时传进来的参数 size
 @param superResult 原本的 sizeThatFits: 方法的返回值
 */
@property(nullable, nonatomic, copy) CGSize (^qmui_sizeThatFitsBlock)(__kindof UIView *view, CGSize size, CGSize superResult);

/**
 当 tintColorDidChange 被调用的时候会调用这个 block，就不用重写方法了
 @param view 当前的 view 本身，方便使用，省去 weak 操作
 */
@property(nullable, nonatomic, copy) void (^qmui_tintColorDidChangeBlock)(__kindof UIView *view);

/**
 当 hitTest:withEvent: 被调用时会调用这个 block，就不用重写方法了
 @param point 事件产生的 point
 @param event 事件
 @param super 的返回结果
 */
@property(nullable, nonatomic, copy) __kindof UIView * (^qmui_hitTestBlock)(CGPoint point, UIEvent *event, __kindof UIView *originalView);

@end

@interface UIView (QMUI_ViewController)

/**
 判断当前的 view 是否属于可视（可视的定义为已存在于 view 层级树里，或者在所处的 UIViewController 的 [viewWillAppear, viewWillDisappear) 生命周期之间）
 */
@property(nonatomic, assign, readonly) BOOL qmui_visible;

/**
 当前的 view 是否是某个 UIViewController.view
 */
@property(nonatomic, assign) BOOL qmui_isControllerRootView;

/**
 获取当前 view 所在的 UIViewController，会递归查找 superview，因此注意使用场景不要有过于频繁的调用
 */
@property(nullable, nonatomic, weak, readonly) __kindof UIViewController *qmui_viewController;
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
 *  方便地将某个 UIView 截图并转成一个 UIImage，注意如果这个 UIView 本身做了 transform，也不会在截图上反映出来，截图始终都是原始 UIView 的截图。
 */
@interface UIView (QMUI_Snapshotting)

- (UIImage *)qmui_snapshotLayerImage;
- (UIImage *)qmui_snapshotImageAfterScreenUpdates:(BOOL)afterScreenUpdates;

@end


/**
 当某个 UIView 在 setFrame: 时高度传这个值，则会自动将 sizeThatFits 算出的高度设置为当前 view 的高度，相当于以下这段代码的简化：
 @code
 // 以前这么写
 CGSize size = [view sizeThatFits:CGSizeMake(width, CGFLOAT_MAX)];
 view.frame = CGRectMake(x, y, width, size.height);
 
 // 现在可以这么写：
 view.frame = CGRectMake(x, y, width, QMUIViewSelfSizingHeight);
 @endcode
 */
extern const CGFloat QMUIViewSelfSizingHeight;

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


@interface UIView (CGAffineTransform)

/// 获取当前 view 的 transform scale x
@property(nonatomic, assign, readonly) CGFloat qmui_scaleX;

/// 获取当前 view 的 transform scale y
@property(nonatomic, assign, readonly) CGFloat qmui_scaleY;

/// 获取当前 view 的 transform translation x
@property(nonatomic, assign, readonly) CGFloat qmui_translationX;

/// 获取当前 view 的 transform translation y
@property(nonatomic, assign, readonly) CGFloat qmui_translationY;

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

NS_ASSUME_NONNULL_END
