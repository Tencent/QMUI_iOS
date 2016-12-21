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
 * 带箭头的小tips浮层，自带 imageView 和 textLabel，可展示简单的图文信息。<br/>
 *
 * 如果默认功能无法满足需求，请继承它重写一个子类。<br/>
 * 继承要点：<br/>
 * <ol>
 * <li>所有subviews请加到contentView上，相对于contentView布局</li>
 * <li>通过重写sizeThatFitsInContentView:，在里面返回当前subviews的大小，控件会根据这个大小来布局</li>
 * </ol>
 * 使用步骤：<br/>
 * <ol>
 * <li>使用init初始化</li>
 * <li>将控件添加到某个View上（一定要先添加，再layout，因为layout里会使用superview的bounds进行计算）</li>
 * <li>调用layoutWithReferenceItemRectInSuperview:将需要指向的目标的rect传进去，tipsView就会自动计算宽高和x/y，让箭头对准rect的中心点</li>
 * <li>注意传进去的rect必须和tipsView处于同一个坐标系内，必要时记得转换坐标系</li>
 * <li>如果需要显示/消失带有动画，则调用<i>showWithAnimated:</i>、<i>hideWithAnimated:</i>，记得show前先setHidden为YES。</li>
 * </ol>
 */

@interface QMUIPopupContainerView : UIControl {
    CAShapeLayer    *_backgroundLayer;
    CGFloat         _arrowMinX;
}

@property(nonatomic,assign) BOOL debug;

/// 所有subview都应该添加到contentView上，默认contentView.userInteractionEnabled = NO，需要事件操作时自行打开
@property(nonatomic,strong,readonly) UIView *contentView;

/// 预提供的UIImageView，默认为nil，调用到的时候才初始化
@property(nonatomic,strong,readonly) UIImageView *imageView;

/// 预提供的UILabel，默认为nil，调用到的时候才初始化。默认支持多行。
@property(nonatomic,strong,readonly) UILabel *textLabel;

/// 圆角矩形气泡内的padding（不包括三角箭头），默认是(8, 8, 8, 8)
@property(nonatomic,assign) UIEdgeInsets contentEdgeInsets UI_APPEARANCE_SELECTOR;

/// 调整imageView的位置，默认为UIEdgeInsetsZero。top/left正值表示往下/右方偏移，bottom/right仅在对应位置存在下一个子View时生效（例如只有同时存在imageView和textLabel时，imageEdgeInsets.right才会生效）。
@property(nonatomic,assign) UIEdgeInsets imageEdgeInsets UI_APPEARANCE_SELECTOR;

/// 调整textLabel的位置，默认为UIEdgeInsetsZero。top/left/bottom/right的作用同<i>imageEdgeInsets</i>
@property(nonatomic,assign) UIEdgeInsets textEdgeInsets UI_APPEARANCE_SELECTOR;

/// 三角箭头的大小
@property(nonatomic,assign) CGSize arrowSize UI_APPEARANCE_SELECTOR;

/// 最大宽度（指整个控件的宽度，而不是contentView部分），默认为CGFLOAT_MAX
@property(nonatomic,assign) CGFloat maximumWidth UI_APPEARANCE_SELECTOR;

/// 最小宽度（指整个控件的宽度，而不是contentView部分），默认为0
@property(nonatomic,assign) CGFloat minimumWidth UI_APPEARANCE_SELECTOR;

/// 最大高度（指整个控件的高度，而不是contentView部分），默认为CGFLOAT_MAX
@property(nonatomic,assign) CGFloat maximumHeight UI_APPEARANCE_SELECTOR;

/// 最小高度（指整个控件的高度，而不是contentView部分），默认为0
@property(nonatomic,assign) CGFloat minimumHeight UI_APPEARANCE_SELECTOR;

/// 计算布局时期望的默认位置，默认为QMUIPopupContainerViewLayoutDirectionAbove，也即在目标的上方
@property(nonatomic,assign) QMUIPopupContainerViewLayoutDirection preferLayoutDirection UI_APPEARANCE_SELECTOR;

/// 最终的布局方向（preferLayoutDirection只是期望的方向，但有可能那个方向已经没有剩余空间可摆放控件了，所以会自动变换）
@property(nonatomic,assign,readonly) QMUIPopupContainerViewLayoutDirection currentLayoutDirection;

/// 最终布局时箭头距离目标边缘的距离，默认为5
@property(nonatomic,assign) CGFloat distanceBetweenTargetRect UI_APPEARANCE_SELECTOR;

/// 最终布局时与父节点的边缘的临界点，默认为(10, 10, 10, 10)
@property(nonatomic,assign) UIEdgeInsets safetyMarginsOfSuperview UI_APPEARANCE_SELECTOR;

@property(nonatomic,strong) UIColor *backgroundColor UI_APPEARANCE_SELECTOR;
@property(nonatomic,strong) UIColor *highlightedBackgroundColor UI_APPEARANCE_SELECTOR;
@property(nonatomic,strong) UIColor *shadowColor UI_APPEARANCE_SELECTOR;
@property(nonatomic,strong) UIColor *borderColor UI_APPEARANCE_SELECTOR;
@property(nonatomic,assign) CGFloat borderWidth UI_APPEARANCE_SELECTOR;
@property(nonatomic,assign) CGFloat cornerRadius UI_APPEARANCE_SELECTOR;

/// 子类重写，告诉父类subviews的合适大小
- (CGSize)sizeThatFitsInContentView:(CGSize)size;

/**
 * 利用参考的目标itemRect，计算出tips合适的布局位置（箭头并非绝对居中）
 * @param itemRect 参考对齐的UIBarButtonItem的rect（rect是相对于toolbar的坐标系而言）
 */
- (void)layoutWithReferenceItemRectInSuperview:(CGRect)itemRect;

- (void)showWithAnimated:(BOOL)animated;
- (void)showWithAnimated:(BOOL)animated completion:(void (^)(BOOL finished))completion;
- (void)hideWithAnimated:(BOOL)animated;
- (void)hideWithAnimated:(BOOL)animated completion:(void (^)(BOOL finished))completion;
- (BOOL)isShowing;
@end
