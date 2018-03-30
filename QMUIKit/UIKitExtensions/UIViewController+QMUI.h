//
//  UIViewController+QMUI.h
//  qmui
//
//  Created by QMUI Team on 16/1/12.
//  Copyright © 2016年 QMUI Team. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "QMUICore.h"

/**
 *  @warning 在这里兼容了 iOS 9.0 以下的版本对 loadViewIfNeeded 方法的调用
 */
@interface UIViewController (QMUI)

/** 获取和自身处于同一个UINavigationController里的上一个UIViewController */
@property(nullable, nonatomic, weak, readonly) UIViewController *qmui_previousViewController;

/** 获取上一个UIViewController的title，可用于设置自定义返回按钮的文字 */
@property(nullable, nonatomic, copy, readonly) NSString *qmui_previousViewControllerTitle;

/**
 *  获取当前controller里的最高层可见viewController（可见的意思是还会判断self.view.window是否存在）
 *
 *  @see 如果要获取当前App里的可见viewController，请使用 [QMUIHelper visibleViewController]
 *
 *  @return 当前controller里的最高层可见viewController
 */
- (nullable UIViewController *)qmui_visibleViewControllerIfExist;

/**
 *  当前 viewController 是否是被以 present 的方式显示的，是则返回 YES，否则返回 NO
 *  @warning 对于被放在 UINavigationController 里显示的 UIViewController，如果 self 是 self.navigationController 的第一个 viewController，则如果 self.navigationController 是被 present 起来的，那么 self.qmui_isPresented = self.navigationController.qmui_isPresented = YES。利用这个特性，可以方便地给 navigationController 的第一个界面的左上角添加关闭按钮。
 */
- (BOOL)qmui_isPresented;

/**
 *  是否应该响应一些UI相关的通知，例如 UIKeyboardNotification、UIMenuControllerNotification等，因为有可能当前界面已经被切走了（push到其他界面），但仍可能收到通知，所以在响应通知之前都应该做一下这个判断
 */
- (BOOL)qmui_isViewLoadedAndVisible;

/**
 *  UINavigationBar 在 self.view 坐标系里的 maxY，一般用于 self.view.subviews 布局时参考用
 *  @warning 注意由于使用了坐标系转换的计算，所以要求在 self.view.window 存在的情况下使用才可以，因此请勿在 viewDidLoad 内使用，建议在 viewDidLayoutSubviews、viewWillAppear: 里使用。
 *  @warning 如果不存在 UINavigationBar，则返回 0
 */
@property(nonatomic, assign, readonly) CGFloat qmui_navigationBarMaxYInViewCoordinator;

/**
 *  底部 UIToolbar 在 self.view 坐标系里的占位高度，一般用于 self.view.subviews 布局时参考用
 *  @warning 注意由于使用了坐标系转换的计算，所以要求在 self.view.window 存在的情况下使用才可以，因此请勿在 viewDidLoad 内使用，建议在 viewDidLayoutSubviews、viewWillAppear: 里使用。
 *  @warning 如果不存在 UIToolbar，则返回 0
 */
@property(nonatomic, assign, readonly) CGFloat qmui_toolbarSpacingInViewCoordinator;

/**
 *  底部 UITabBar 在 self.view 坐标系里的占位高度，一般用于 self.view.subviews 布局时参考用
 *  @warning 注意由于使用了坐标系转换的计算，所以要求在 self.view.window 存在的情况下使用才可以，因此请勿在 viewDidLoad 内使用，建议在 viewDidLayoutSubviews、viewWillAppear: 里使用。
 *  @warning 如果不存在 UITabBar，则返回 0
 */
@property(nonatomic, assign, readonly) CGFloat qmui_tabBarSpacingInViewCoordinator;

@end

/**
 *  日常业务中经常碰到这样的场景：进入界面后会异步加载数据，当数据加载完并且 viewDidAppear: 后要执行一些操作（例如滚动列表到某一行并高亮它），若数据在 viewDidAppear: 前就已经加载完，也需要等到 viewDidAppear: 时才做那些操作。
 *  当你需要实现这种场景的效果时，可以用以下两个属性，具体请查看属性注释。
 */
@interface UIViewController (Data)

/// 当数据加载完（什么时候算是“加载完”需要通过属性 qmui_dataLoaded 来设置）并且界面已经走过 viewDidAppear: 时，这个 block 会被执行，执行结束后 block 会被清空，以避免重复调用。
@property(nullable, nonatomic, copy) void (^qmui_didAppearAndLoadDataBlock)(void);

/// 请在你的数据加载完成时手动修改这个属性为 YES，如果此时界面已经走过 viewDidAppear:，则 qmui_didAppearAndLoadDataBlock 会被立即执行，如果此时界面尚未走 viewDidAppear:，则等到 viewDidAppear: 时，qmui_didAppearAndLoadDataBlock 就会被自动执行。
@property(nonatomic, assign, getter = isQmui_dataLoaded) BOOL qmui_dataLoaded;

@end

@interface UIViewController (Runtime)

/**
 *  判断当前类是否有重写某个指定的 UIViewController 的方法
 *  @param selector 要判断的方法
 *  @return YES 表示当前类重写了指定的方法，NO 表示没有重写，使用的是 UIViewController 默认的实现
 */
- (BOOL)qmui_hasOverrideUIKitMethod:(_Nonnull SEL)selector;
@end

@interface UIViewController (RotateDeviceOrientation)

/// 在配置表 AutomaticallyRotateDeviceOrientation 功能开启的情况下，QMUI 会自动判断当前的 UIViewController 是否具备强制旋转设备方向的权利，而如果 QMUI 判断结果为没权利但你又希望当前的 UIViewController 具备这个权利，则可以重写该方法并返回 YES。
/// 默认返回 NO，也即交给 QMUI 自动判断。
- (BOOL)qmui_shouldForceRotateDeviceOrientation;
@end

@interface QMUIHelper (ViewController)

/**
 * 获取当前应用里最顶层的可见viewController
 * @warning 注意返回值可能为nil，要做好保护
 */
+ (nullable UIViewController *)visibleViewController;

@end
