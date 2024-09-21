//
//  QMUISheetPresentationSupports.h
//  QMUIKit
//
//  Created by molice on 2024/2/27.
//  Copyright © 2024 QMUI Team. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import "QMUINavigationController.h"

NS_ASSUME_NONNULL_BEGIN

@class QMUISheetPresentationNavigationBar;

/// 当某个界面以半屏浮层方式显示时，可通过 vc.qmui_sheetPresentation 获取该界面的半屏浮层配置对象，通过该对象来修改浮层的样式、行为。
/// 业务不应该自己构造一个新实例。
@interface QMUISheetPresentation : NSObject

/// 弹出时背后的遮罩颜色，默认为 UIColorMask（若有使用配置表）或 0.35 alpha 的黑色，可通过设为 nil 来去除遮罩。
@property(nonatomic, strong, nullable) UIColor *dimmingColor;

/// 是否模态弹出，YES 表示点击遮罩无响应，NO 表示点击遮罩自动关闭面板。默认为 NO。当设置为 YES 时也会同时屏蔽 swipe、pull 手势（你可以手动再打开）。
@property(nonatomic, assign) BOOL modal;

/// 是否支持侧滑关闭面板，默认为 YES。
@property(nonatomic, assign) BOOL supportsSwipeToDismiss;

/// 是否支持下拉关闭面板，默认为 YES。
@property(nonatomic, assign) BOOL supportsPullToDismiss;

/// 是否需要显示浮层顶部的仿原生导航栏（可自动显示 vc.title、vc.navigationItem 按钮），默认为 YES。
@property(nonatomic, assign) BOOL shouldShowNavigationBar;

/// 浮层左上角、右上角的圆角值，默认为10。
@property(nonatomic, assign) CGFloat cornerRadius;

/// 计算当前浮层在给定宽高下的内容大小，若希望表达无限制，则使用 CGFLOAT_MAX。
/// 业务不需要考虑 navigationBar、safeAreaInsets，组件会自己加上。
/// 也不需要考虑最大最小值保护，组件会自己处理。
/// 若不设置则使用默认宽高（高度固定200pt）。
@property(nonatomic, copy, nullable) CGSize (^preferredSheetContentSizeBlock)(QMUISheetPresentation *aSheetPresentation, CGSize aContainerSize);

- (instancetype)init NS_UNAVAILABLE;
@end

@interface UIViewController (QMUISheetSupports)

/// 是否以 QMUISheetPresented 方式展示，在 viewDidLoad 及以后的时机都可以使用。
/// @warning qmui_isPresentedInSheet 为 YES 的情况下，qmui_isPresented 为 NO，请注意区分这两者。
@property(nonatomic, assign, readonly) BOOL qmui_isPresentedInSheet;

/// 用于配置当前半屏浮层效果的对象，懒加载，业务如需修改值，直接访问并设置即可。
/// 注意如果当前界面并非使用半屏浮层方式显示，这个属性依然会返回值。
@property(nonatomic, strong, readonly) QMUISheetPresentation *qmui_sheetPresentation;

/// 获取当前浮层里的仿原生导航栏，可对其进行样式、内容等设置，一般在 viewWillAppear: 时进行。
@property(nonatomic, strong, readonly) QMUISheetPresentationNavigationBar *qmui_sheetPresentationNavigationBar;

/// 当前浮层的侧滑手势对象，在 viewWillAppear: 及以后的时机都可以使用，业务可以自行修改 .delegate = xxx，但所有方法均需使用 QMUISheetPresentation.supportsSwipeToDismiss 值来判断当前手势是否有效。
@property(nonatomic, strong, readonly) UIScreenEdgePanGestureRecognizer *qmui_sheetPresentationSwipeGestureRecognizer;

/// 当前浮层的下拉手势对象，在 viewWillAppear: 及以后的时机都可以使用，业务可以自行修改 .delegate = xxx，但所有方法均需使用 QMUISheetPresentation.supportsPullToDismiss 值来判断当前手势是否有效。
@property(nonatomic, strong, readonly) UIPanGestureRecognizer *qmui_sheetPresentationPullGestureRecognizer;

/// 必要时业务可通过该方法主动刷新浮层布局，内部会自动判断当前若正在显示浮层，则以动画形式刷新布局，否则在下一个 runloop 才刷新。
- (void)qmui_invalidateSheetPresentationLayout;
@end

@interface QMUINavigationController (QMUISheetSupports)

/// 将指定界面放到一个导航容器里并以半屏浮层的形式显示出来，浮层的样式、尺寸可通过 rootViewController.qmui_sheetPresentation 来配置。
/// 构造完直接用系统的 present 方法把返回值显示出来即可。
/// rootViewController 内部可用标准的 self.navigationController pushXxx/popXxx 写法来切换界面。
- (instancetype)qmui_initWithSheetRootViewController:(UIViewController *)rootViewController;
@end

NS_ASSUME_NONNULL_END
