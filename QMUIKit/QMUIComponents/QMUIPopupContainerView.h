/*****
 * Tencent is pleased to support the open source community by making QMUI_iOS available.
 * Copyright (C) 2016-2019 THL A29 Limited, a Tencent company. All rights reserved.
 * Licensed under the MIT License (the "License"); you may not use this file except in compliance with the License. You may obtain a copy of the License at
 * http://opensource.org/licenses/MIT
 * Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.
 *****/

//
//  QMUIPopupContainerView.h
//  qmui
//
//  Created by QMUI Team on 15/12/17.
//

#import <UIKit/UIKit.h>
#import "UIControl+QMUI.h"

typedef NS_ENUM(NSUInteger, QMUIPopupContainerViewLayoutDirection) {
    QMUIPopupContainerViewLayoutDirectionAbove,
    QMUIPopupContainerViewLayoutDirectionBelow
};

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
 * 3. 通过为 sourceBarItem/sourceView/sourceRect 三者中的一个赋值，来决定浮层布局的位置。
 * 4. 调用 showWithAnimated: 或 showWithAnimated:completion: 显示浮层。
 * 5. 调用 hideWithAnimated: 或 hideWithAnimated:completion: 隐藏浮层。
 *
 * @warning 如果使用方法 2.2，并且没有打开 automaticallyHidesWhenUserTap 属性，则记得在适当的时机（例如 viewWillDisappear:）隐藏浮层。
 *
 * 如果默认功能无法满足需求，可继承它重写一个子类，继承要点：
 * 1. 初始化时要做的事情请放在 didInitialize 里。
 * 2. 所有 subviews 请加到 contentView 上。
 * 3. 通过重写 sizeThatFitsInContentView:，在里面返回当前 subviews 的大小。
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
@property(nonatomic, assign) CGFloat distanceBetweenSource UI_APPEARANCE_SELECTOR;

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

/// 可以是 UINavigationBar、UIToolbar 上的 UIBarButtonItem，或者 UITabBar 上的 UITabBarItem
@property(nonatomic, weak) __kindof UIBarItem *sourceBarItem;

@property(nonatomic, weak) __kindof UIView *sourceView;

/// rect 需要处于 QMUIPopupContainerView 所在的坐标系内，例如如果 popup 使用 addSubview: 的方式添加到界面，则 sourceRect 应该是 superview 坐标系内的；如果 popup 使用 window 的方式展示，则 sourceRect 需要转换为 window 坐标系内。
@property(nonatomic, assign) CGRect sourceRect;

/// 立即刷新当前 popup 的布局，前提是 popup 已经被 show 过。
- (void)updateLayout;

- (void)showWithAnimated:(BOOL)animated;
- (void)showWithAnimated:(BOOL)animated completion:(void (^)(BOOL finished))completion;
- (void)hideWithAnimated:(BOOL)animated;
- (void)hideWithAnimated:(BOOL)animated completion:(void (^)(BOOL finished))completion;
- (BOOL)isShowing;

/**
 *  即将显示时的回调
 *  注：如果需要使用例如 didShowBlock 的时机，请使用 @showWithAnimated:completion: 的 completion 参数来实现。
 *  @argv animated 是否需要动画
 */
@property(nonatomic, copy) void (^willShowBlock)(BOOL animated);

/**
 *  即将隐藏时的回调
 *  @argv hidesByUserTap 用于区分此次隐藏是否因为用户手动点击空白区域导致浮层被隐藏
 *  @argv animated 是否需要动画
 */
@property(nonatomic, copy) void (^willHideBlock)(BOOL hidesByUserTap, BOOL animated);

/**
 *  已经隐藏后的回调
 *  @argv hidesByUserTap 用于区分此次隐藏是否因为用户手动点击空白区域导致浮层被隐藏
 */
@property(nonatomic, copy) void (^didHideBlock)(BOOL hidesByUserTap);

@end

@interface QMUIPopupContainerView (UISubclassingHooks)

/// 子类重写，在初始化时做一些操作
- (void)didInitialize NS_REQUIRES_SUPER;

/**
 子类重写，告诉父类subviews的合适大小

 @param size 浮层里除去 safetyMarginsOfSuperview、arrowSize、contentEdgeInsets 之外后，留给内容的实际大小，计算 subview 大小时均应使用这个参数来计算
 @return 自定义内容实际占据的大小
 */
- (CGSize)sizeThatFitsInContentView:(CGSize)size;
@end
