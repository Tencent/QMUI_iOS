//
//  QMUIImagePreviewViewController.h
//  qmui
//
//  Created by MoLice on 2016/11/30.
//  Copyright © 2016年 QMUI Team. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "QMUICommonViewController.h"
#import "QMUIImagePreviewView.h"

/**
 *  图片预览控件，主要功能由内部自带的 QMUIImagePreviewView 提供，由于以 viewController 的形式存在，所以适用于那种在单独界面里展示图片，或者需要从某张目标图片的位置以动画的形式放大进入预览界面的场景。
 *
 *  使用方式：
 *
 *  1. 使用 init 方法初始化
 *  2. 添加 imagePreviewView 的 delegate
 *  3. 分两种查看方式：
 *      1. 如果是左右 push 进入新界面查看图片，则直接按普通 UIViewController 的方式 push 即可；
 *      2. 如果需要从指定图片位置以动画的形式放大进入预览，则调用 startPreviewFromRectInScreenCoordinate:，传入一个 rect 即可开始预览，这种模式下会创建一个独立的 UIWindow 用于显示 QMUIImagePreviewViewController，所以可以达到盖住当前界面所有元素（包括顶部状态栏）的效果。特别地，如果使用这种方式，则默认会开启手势拖拽退出预览的功能（如果用 push 的方式，是不支持手势的）
 *
 *  @see QMUIImagePreviewView
 */
@interface QMUIImagePreviewViewController : QMUICommonViewController

@property(nonatomic, strong, readonly) QMUIImagePreviewView *imagePreviewView;
@property(nonatomic, strong) UIColor *backgroundColor UI_APPEARANCE_SELECTOR;
@end

/**
 *  以 UIWindow 的形式来预览图片，优点是能盖住界面上所有元素（包括状态栏），缺点是无法进行 viewController 的界面切换（因为被 UIWindow 盖住了）
 */
@interface QMUIImagePreviewViewController (UIWindow)

/**
 *  从指定 rect 的位置以动画的形式进入预览
 *  @param rect 在当前屏幕坐标系里的 rect，注意传进来的 rect 要做坐标系转换，例如：[view.superview convertRect:view.frame toView:nil]
 *  @param cornerRadius 做打开动画时是否要从某个圆角渐变到 0
 */
- (void)startPreviewFromRectInScreenCoordinate:(CGRect)rect cornerRadius:(CGFloat)cornerRadius;

/**
 *  从指定 rect 的位置以动画的形式进入预览，不考虑圆角
 *  @param rect 在当前屏幕坐标系里的 rect，注意传进来的 rect 要做坐标系转换，例如：[view.superview convertRect:view.frame toView:nil]
 */
- (void)startPreviewFromRectInScreenCoordinate:(CGRect)rect;

/**
 *  将当前图片缩放到指定 rect 的位置，然后退出预览
 *  @param rect 在当前屏幕坐标系里的 rect，注意传进来的 rect 要做坐标系转换，例如：[view.superview convertRect:view.frame toView:nil]
 */
- (void)exitPreviewToRectInScreenCoordinate:(CGRect)rect;

/**
 *  以渐现的方式开始图片预览
 */
- (void)startPreviewByFadeIn;

/**
 *  使用渐隐的动画退出图片预览
 */
- (void)exitPreviewByFadeOut;

/// 是否支持手势拖拽退出预览模式，默认为 YES
@property(nonatomic, assign) BOOL exitGestureEnabled;

/// 当拖拽的手势最终结束时，你可以在这个 block 里手动退出预览模式，否则将会统一用 exitPreviewByFadeOut 方式退出。
@property(nonatomic, copy) void (^customGestureExitBlock)(QMUIImagePreviewViewController *aImagePreviewViewController, QMUIZoomImageView *currentZoomImageView);

/// 自动选择用 exitToRect 还是 exitByFade 的方式退出预览模式
- (void)exitPreviewAutomatically;

@end

@interface QMUIImagePreviewViewController (UIAppearance)

+ (nonnull instancetype)appearance;
@end
