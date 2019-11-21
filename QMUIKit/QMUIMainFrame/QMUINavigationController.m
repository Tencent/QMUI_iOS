/*****
 * Tencent is pleased to support the open source community by making QMUI_iOS available.
 * Copyright (C) 2016-2019 THL A29 Limited, a Tencent company. All rights reserved.
 * Licensed under the MIT License (the "License"); you may not use this file except in compliance with the License. You may obtain a copy of the License at
 * http://opensource.org/licenses/MIT
 * Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.
 *****/

//
//  QMUINavigationController.m
//  qmui
//
//  Created by QMUI Team on 14-6-24.
//

#import "QMUINavigationController.h"
#import "QMUICore.h"
#import "QMUINavigationTitleView.h"
#import "QMUICommonViewController.h"
#import "UIViewController+QMUI.h"
#import "UINavigationController+QMUI.h"
#import "QMUILog.h"
#import "QMUIMultipleDelegates.h"
#import "QMUIWeakObjectContainer.h"

@protocol QMUI_viewWillAppearNotifyDelegate <NSObject>

- (void)qmui_viewControllerDidInvokeViewWillAppear:(UIViewController *)viewController;

@end

@interface _QMUINavigationControllerDelegator : NSObject <QMUINavigationControllerDelegate>

@property(nonatomic, weak) QMUINavigationController *navigationController;
@end

@interface QMUINavigationController () <UIGestureRecognizerDelegate, QMUI_viewWillAppearNotifyDelegate>

@property(nonatomic, strong) _QMUINavigationControllerDelegator *delegator;

/// 记录当前是否正在 push/pop 界面的动画过程，如果动画尚未结束，不应该继续 push/pop 其他界面。
/// 在 getter 方法里会根据配置表开关 PreventConcurrentNavigationControllerTransitions 的值来控制这个属性是否生效。
@property(nonatomic, assign) BOOL isViewControllerTransiting;

/// 即将要被pop的controller
@property(nonatomic, weak) UIViewController *viewControllerPopping;

@end

@interface UIViewController (QMUINavigationControllerTransition)

@property(nonatomic, weak) id<QMUI_viewWillAppearNotifyDelegate> qmui_viewWillAppearNotifyDelegate;

@end

@implementation UIViewController (QMUINavigationControllerTransition)

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        ExtendImplementationOfVoidMethodWithSingleArgument([UIViewController class], @selector(viewWillAppear:), BOOL, ^(UIViewController *selfObject, BOOL firstArgv) {
            if ([selfObject.qmui_viewWillAppearNotifyDelegate respondsToSelector:@selector(qmui_viewControllerDidInvokeViewWillAppear:)]) {
                [selfObject.qmui_viewWillAppearNotifyDelegate qmui_viewControllerDidInvokeViewWillAppear:selfObject];
            }
        });
        
        ExtendImplementationOfVoidMethodWithSingleArgument([UIViewController class], @selector(viewDidAppear:), BOOL, ^(UIViewController *selfObject, BOOL firstArgv) {
            if ([selfObject.navigationController.viewControllers containsObject:selfObject] && [selfObject.navigationController isKindOfClass:[QMUINavigationController class]]) {
                ((QMUINavigationController *)selfObject.navigationController).isViewControllerTransiting = NO;
            }
            selfObject.qmui_poppingByInteractivePopGestureRecognizer = NO;
            selfObject.qmui_willAppearByInteractivePopGestureRecognizer = NO;
        });
        
        ExtendImplementationOfVoidMethodWithSingleArgument([UIViewController class], @selector(viewDidDisappear:), BOOL, ^(UIViewController *selfObject, BOOL firstArgv) {
            selfObject.qmui_poppingByInteractivePopGestureRecognizer = NO;
            selfObject.qmui_willAppearByInteractivePopGestureRecognizer = NO;
        });
    });
}

static char kAssociatedObjectKey_qmui_viewWillAppearNotifyDelegate;
- (void)setQmui_viewWillAppearNotifyDelegate:(id<QMUI_viewWillAppearNotifyDelegate>)qmui_viewWillAppearNotifyDelegate {
    objc_setAssociatedObject(self, &kAssociatedObjectKey_qmui_viewWillAppearNotifyDelegate, [[QMUIWeakObjectContainer alloc] initWithObject:qmui_viewWillAppearNotifyDelegate], OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (id<QMUI_viewWillAppearNotifyDelegate>)qmui_viewWillAppearNotifyDelegate {
    id weakContainer = objc_getAssociatedObject(self, &kAssociatedObjectKey_qmui_viewWillAppearNotifyDelegate);
    if ([weakContainer isKindOfClass:[QMUIWeakObjectContainer class]]) {
        id notifyDelegate = [weakContainer object];
        return notifyDelegate;
    }
    return nil;
}

@end

@implementation QMUINavigationController

#pragma mark - 生命周期函数 && 基类方法重写

- (instancetype)initWithRootViewController:(UIViewController *)rootViewController {
    if (self = [super initWithRootViewController:rootViewController]) {
        if (@available(iOS 13.0, *)) {
            // -[UINavigationController initWithRootViewController:] 在 iOS 13 以下的版本内部会调用 [self initWithNibName:bundle] 而在 iOS 13 上则是直接调用 [super initWithNibName:bundle] 所以这里需要手动调用一次 [self didInitialize]
            [self didInitialize];
        }
    }
    return self;
}

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        [self didInitialize];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
        [self didInitialize];
    }
    return self;
}

- (void)didInitialize {
    
    self.qmui_multipleDelegatesEnabled = YES;
    self.delegator = [[_QMUINavigationControllerDelegator alloc] init];
    self.delegator.navigationController = self;
    self.delegate = self.delegator;
    
    // UIView.tintColor 并不支持 UIAppearance 协议，所以不能通过 appearance 来设置，只能在实例里设置
    if (QMUICMIActivated) {
        self.navigationBar.tintColor = NavBarTintColor;
        self.toolbar.tintColor = ToolBarTintColor;
    }
}

- (void)dealloc {
    self.delegate = nil;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // 手势允许多次addTarget
    [self.interactivePopGestureRecognizer addTarget:self action:@selector(handleInteractivePopGestureRecognizer:)];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self willShowViewController:self.topViewController animated:animated];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self didShowViewController:self.topViewController animated:animated];
}

- (UIViewController *)popViewControllerAnimated:(BOOL)animated {
    if (self.viewControllers.count < 2) {
        // 只剩 1 个 viewController 或者不存在 viewController 时，调用 popViewControllerAnimated: 后不会有任何变化，所以不需要触发 willPop / didPop
        return [super popViewControllerAnimated:animated];
    }
    
    UIViewController *viewController = [self topViewController];
    self.viewControllerPopping = viewController;

    if (animated) {
        self.viewControllerPopping.qmui_viewWillAppearNotifyDelegate = self;
        
        self.isViewControllerTransiting = YES;
    }
    
    if ([viewController respondsToSelector:@selector(willPopInNavigationControllerWithAnimated:)]) {
        [((UIViewController<QMUINavigationControllerTransitionDelegate> *)viewController) willPopInNavigationControllerWithAnimated:animated];
    }
    
//    QMUILog(@"NavigationItem", @"call popViewControllerAnimated:%@, current viewControllers = %@", StringFromBOOL(animated), self.viewControllers);
    
    viewController = [super popViewControllerAnimated:animated];
    
//    QMUILog(@"NavigationItem", @"pop viewController: %@", viewController);
    
    if ([viewController respondsToSelector:@selector(didPopInNavigationControllerWithAnimated:)]) {
        [((UIViewController<QMUINavigationControllerTransitionDelegate> *)viewController) didPopInNavigationControllerWithAnimated:animated];
    }
    return viewController;
}

- (NSArray<UIViewController *> *)popToViewController:(UIViewController *)viewController animated:(BOOL)animated {
    if (!viewController || self.topViewController == viewController) {
        // 当要被 pop 到的 viewController 已经处于最顶层时，调用 super 默认也是什么都不做，所以直接 return 掉
        return [super popToViewController:viewController animated:animated];
    }
    
    self.viewControllerPopping = self.topViewController;

    if (animated) {
        self.viewControllerPopping.qmui_viewWillAppearNotifyDelegate = self;
        self.isViewControllerTransiting = YES;
    }
    
    // will pop
    for (NSInteger i = self.viewControllers.count - 1; i > 0; i--) {
        UIViewController *viewControllerPopping = self.viewControllers[i];
        if (viewControllerPopping == viewController) {
            break;
        }
        
        if ([viewControllerPopping respondsToSelector:@selector(willPopInNavigationControllerWithAnimated:)]) {
            BOOL animatedArgument = i == self.viewControllers.count - 1 ? animated : NO;// 只有当前可视的那个 viewController 的 animated 是跟随参数走的，其他 viewController 由于不可视，不管参数的值为多少，都认为是无动画地 pop
            [((UIViewController<QMUINavigationControllerTransitionDelegate> *)viewControllerPopping) willPopInNavigationControllerWithAnimated:animatedArgument];
        }
    }
    
    NSArray<UIViewController *> *poppedViewControllers = [super popToViewController:viewController animated:animated];
    
    // did pop
    for (NSInteger i = poppedViewControllers.count - 1; i >= 0; i--) {
        UIViewController *viewControllerPopped = poppedViewControllers[i];
        if ([viewControllerPopped respondsToSelector:@selector(didPopInNavigationControllerWithAnimated:)]) {
            BOOL animatedArgument = i == poppedViewControllers.count - 1 ? animated : NO;// 只有当前可视的那个 viewController 的 animated 是跟随参数走的，其他 viewController 由于不可视，不管参数的值为多少，都认为是无动画地 pop
            [((UIViewController<QMUINavigationControllerTransitionDelegate> *)viewControllerPopped) didPopInNavigationControllerWithAnimated:animatedArgument];
        }
    }
    
    return poppedViewControllers;
}

- (NSArray<UIViewController *> *)popToRootViewControllerAnimated:(BOOL)animated {
    // 在配合 tabBarItem 使用的情况下，快速重复点击相同 item 可能会重复调用 popToRootViewControllerAnimated:，而此时其实已经处于 rootViewController 了，就没必要继续走后续的流程，否则一些变量会得不到重置。
    if (self.topViewController == self.qmui_rootViewController) {
        return nil;
    }
    
    self.viewControllerPopping = self.topViewController;
    
    if (animated) {
        self.viewControllerPopping.qmui_viewWillAppearNotifyDelegate = self;
        self.isViewControllerTransiting = YES;
    }

    // will pop
    for (NSInteger i = self.viewControllers.count - 1; i > 0; i--) {
        UIViewController *viewControllerPopping = self.viewControllers[i];
        if ([viewControllerPopping respondsToSelector:@selector(willPopInNavigationControllerWithAnimated:)]) {
            BOOL animatedArgument = i == self.viewControllers.count - 1 ? animated : NO;// 只有当前可视的那个 viewController 的 animated 是跟随参数走的，其他 viewController 由于不可视，不管参数的值为多少，都认为是无动画地 pop
            [((UIViewController<QMUINavigationControllerTransitionDelegate> *)viewControllerPopping) willPopInNavigationControllerWithAnimated:animatedArgument];
        }
    }
    
    NSArray<UIViewController *> * poppedViewControllers = [super popToRootViewControllerAnimated:animated];
    
    // did pop
    for (NSInteger i = poppedViewControllers.count - 1; i >= 0; i--) {
        UIViewController *viewControllerPopped = poppedViewControllers[i];
        if ([viewControllerPopped respondsToSelector:@selector(didPopInNavigationControllerWithAnimated:)]) {
            BOOL animatedArgument = i == poppedViewControllers.count - 1 ? animated : NO;// 只有当前可视的那个 viewController 的 animated 是跟随参数走的，其他 viewController 由于不可视，不管参数的值为多少，都认为是无动画地 pop
            [((UIViewController<QMUINavigationControllerTransitionDelegate> *)viewControllerPopped) didPopInNavigationControllerWithAnimated:animatedArgument];
        }
    }
    return poppedViewControllers;
}

- (void)setViewControllers:(NSArray<UIViewController *> *)viewControllers animated:(BOOL)animated {
    UIViewController *topViewController = self.topViewController;
    
    // will pop
    NSMutableArray<UIViewController *> *viewControllersPopping = self.viewControllers.mutableCopy;
    [viewControllersPopping removeObjectsInArray:viewControllers];
    [viewControllersPopping enumerateObjectsWithOptions:NSEnumerationReverse usingBlock:^(UIViewController * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj respondsToSelector:@selector(willPopInNavigationControllerWithAnimated:)]) {
            BOOL animatedArgument = obj == topViewController ? animated : NO;// 只有当前可视的那个 viewController 的 animated 是跟随参数走的，其他 viewController 由于不可视，不管参数的值为多少，都认为是无动画地 pop
            [((UIViewController<QMUINavigationControllerTransitionDelegate> *)obj) willPopInNavigationControllerWithAnimated:animatedArgument];
        }
    }];
    
    [super setViewControllers:viewControllers animated:animated];
    
    // did pop
    [viewControllersPopping enumerateObjectsWithOptions:NSEnumerationReverse usingBlock:^(UIViewController * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj respondsToSelector:@selector(didPopInNavigationControllerWithAnimated:)]) {
            BOOL animatedArgument = obj == topViewController ? animated : NO;// 只有当前可视的那个 viewController 的 animated 是跟随参数走的，其他 viewController 由于不可视，不管参数的值为多少，都认为是无动画地 pop
            [((UIViewController<QMUINavigationControllerTransitionDelegate> *)obj) didPopInNavigationControllerWithAnimated:animatedArgument];
        }
    }];
    
    // 操作前后如果 topViewController 没发生变化，则为它调用一个特殊的时机
    if (topViewController == viewControllers.lastObject) {
        if ([topViewController respondsToSelector:@selector(viewControllerKeepingAppearWhenSetViewControllersWithAnimated:)]) {
            [((UIViewController<QMUINavigationControllerTransitionDelegate> *)topViewController) viewControllerKeepingAppearWhenSetViewControllersWithAnimated:animated];
        }
    }
}

- (void)pushViewController:(UIViewController *)viewController animated:(BOOL)animated {
    if (self.isViewControllerTransiting || !viewController) {
        QMUILogWarn(NSStringFromClass(self.class), @"%@, 上一次界面切换的动画尚未结束就试图进行新的 push 操作，为了避免产生 bug，拦截了这次 push。\n%s, isViewControllerTransiting = %@, viewController = %@, self.viewControllers = %@", NSStringFromClass(self.class),  __func__, StringFromBOOL(self.isViewControllerTransiting), viewController, self.viewControllers);
        return;
    }
    
    // 增加一个 presentedViewController 作为判断条件是因为这个 issue：https://github.com/Tencent/QMUI_iOS/issues/261
    if (!self.presentedViewController && animated) {
        self.isViewControllerTransiting = YES;
    }
    
    if (self.presentedViewController) {
        QMUILogWarn(NSStringFromClass(self.class), @"push 的时候 navigationController 存在一个盖在上面的 presentedViewController，可能导致一些 UINavigationControllerDelegate 不会被调用");
    }
    
    UIViewController *currentViewController = self.topViewController;
    if (currentViewController) {
        if (!NeedsBackBarButtonItemTitle) {
            // 会自动从 UIBarButtonItem.title 取值作为下一个界面的返回按钮的文字
            currentViewController.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:NULL];
        } else {
            UIViewController<QMUINavigationControllerAppearanceDelegate> *vc = (UIViewController<QMUINavigationControllerAppearanceDelegate> *)viewController;
            if ([vc respondsToSelector:@selector(backBarButtonItemTitleWithPreviousViewController:)]) {
                NSString *title = [vc backBarButtonItemTitleWithPreviousViewController:currentViewController];
                currentViewController.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:title style:UIBarButtonItemStylePlain target:nil action:NULL];
            }
        }
    }
    
    [super pushViewController:viewController animated:animated];
    
    // 某些情况下 push 操作可能会被系统拦截，实际上该 push 并不生效，这种情况下应当恢复相关标志位，否则会影响后续的 push 操作
    // https://github.com/Tencent/QMUI_iOS/issues/426
    if (![self.viewControllers containsObject:viewController]) {
        self.isViewControllerTransiting = NO;
    }
}

#pragma mark - 自定义方法

- (BOOL)isViewControllerTransiting {
    // 如果配置表里这个开关关闭，则为了使 isViewControllerTransiting 功能失效，强制返回 NO
    if (!PreventConcurrentNavigationControllerTransitions) {
        return NO;
    }
    return _isViewControllerTransiting;
}

// 接管系统手势返回的回调
- (void)handleInteractivePopGestureRecognizer:(UIScreenEdgePanGestureRecognizer *)gestureRecognizer {
    UIGestureRecognizerState state = gestureRecognizer.state;
    
    UIViewController *viewControllerWillDisappear = self.viewControllerPopping;
    UIViewController *viewControllerWillAppear = self.topViewController;
    
    viewControllerWillDisappear.qmui_poppingByInteractivePopGestureRecognizer = YES;
    viewControllerWillDisappear.qmui_willAppearByInteractivePopGestureRecognizer = NO;
    
    viewControllerWillAppear.qmui_poppingByInteractivePopGestureRecognizer = NO;
    viewControllerWillAppear.qmui_willAppearByInteractivePopGestureRecognizer = YES;
    
    if (state == UIGestureRecognizerStateBegan) {
        // UIGestureRecognizerStateBegan 对应 viewWillAppear:，只要在 viewWillAppear: 里的修改都是安全的，但只要过了 viewWillAppear:，后续的修改都是不安全的，所以这里用 dispatch 的方式将标志位的赋值放到 viewWillAppear: 的下一个 Runloop 里
        dispatch_async(dispatch_get_main_queue(), ^{
            viewControllerWillDisappear.qmui_navigationControllerPopGestureRecognizerChanging = YES;
            viewControllerWillAppear.qmui_navigationControllerPopGestureRecognizerChanging = YES;
        });
    } else if (state > UIGestureRecognizerStateChanged) {
        viewControllerWillDisappear.qmui_navigationControllerPopGestureRecognizerChanging = NO;
        viewControllerWillAppear.qmui_navigationControllerPopGestureRecognizerChanging = NO;
    }
    
    if (state == UIGestureRecognizerStateEnded) {
        if (CGRectGetMinX(self.topViewController.view.superview.frame) < 0) {
            // by molice:只是碰巧发现如果是手势返回取消时，不管在哪个位置取消，self.topViewController.view.superview.frame.orgin.x必定是-112，所以用这个<0的条件来判断
            QMUILog(NSStringFromClass(self.class), @"手势返回放弃了");
            viewControllerWillDisappear = self.topViewController;
            viewControllerWillAppear = self.viewControllerPopping;
        } else {
            QMUILog(NSStringFromClass(self.class), @"执行手势返回");
        }
    }
    
    if ([viewControllerWillDisappear respondsToSelector:@selector(navigationController:poppingByInteractiveGestureRecognizer:viewControllerWillDisappear:viewControllerWillAppear:)]) {
        [((UIViewController<QMUINavigationControllerTransitionDelegate> *)viewControllerWillDisappear) navigationController:self poppingByInteractiveGestureRecognizer:gestureRecognizer viewControllerWillDisappear:viewControllerWillDisappear viewControllerWillAppear:viewControllerWillAppear];
    }
    
    if ([viewControllerWillAppear respondsToSelector:@selector(navigationController:poppingByInteractiveGestureRecognizer:viewControllerWillDisappear:viewControllerWillAppear:)]) {
        [((UIViewController<QMUINavigationControllerTransitionDelegate> *)viewControllerWillAppear) navigationController:self poppingByInteractiveGestureRecognizer:gestureRecognizer viewControllerWillDisappear:viewControllerWillDisappear viewControllerWillAppear:viewControllerWillAppear];
    }
}

- (void)qmui_viewControllerDidInvokeViewWillAppear:(UIViewController *)viewController {
    viewController.qmui_viewWillAppearNotifyDelegate = nil;
    [self.delegator navigationController:self willShowViewController:self.viewControllerPopping animated:YES];
    self.viewControllerPopping = nil;
    self.isViewControllerTransiting = NO;
}

#pragma mark - StatusBar

- (UIViewController *)childViewControllerForStatusBarHidden {
    return self.topViewController;
}

- (UIViewController *)childViewControllerForStatusBarStyle {
    return self.topViewController;
}

#pragma mark - 屏幕旋转

- (BOOL)shouldAutorotate {
    return [self.visibleViewController qmui_hasOverrideUIKitMethod:_cmd] ? [self.visibleViewController shouldAutorotate] : YES;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    // fix UIAlertController:supportedInterfaceOrientations was invoked recursively!
    // crash in iOS 9 and show log in iOS 10 and later
    // https://github.com/Tencent/QMUI_iOS/issues/502
    // https://github.com/Tencent/QMUI_iOS/issues/632
    UIViewController *visibleViewController = self.visibleViewController;
    if (!visibleViewController || visibleViewController.isBeingDismissed || [visibleViewController isKindOfClass:UIAlertController.class]) {
        visibleViewController = self.topViewController;
    }
    return [visibleViewController qmui_hasOverrideUIKitMethod:_cmd] ? [visibleViewController supportedInterfaceOrientations] : SupportedOrientationMask;
}

#pragma mark - HomeIndicator

- (UIViewController *)childViewControllerForHomeIndicatorAutoHidden {
    return self.topViewController;
}

@end


@implementation QMUINavigationController (UISubclassingHooks)

- (void)willShowViewController:(UIViewController *)viewController animated:(BOOL)animated {
    // 子类可以重写
}

- (void)didShowViewController:(UIViewController *)viewController animated:(BOOL)animated {
    // 子类可以重写
}

@end

@implementation _QMUINavigationControllerDelegator

#pragma mark - <UINavigationControllerDelegate>

- (void)navigationController:(QMUINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated {
    [navigationController willShowViewController:viewController animated:animated];
}

- (void)navigationController:(QMUINavigationController *)navigationController didShowViewController:(UIViewController *)viewController animated:(BOOL)animated {
    navigationController.viewControllerPopping = nil;
    [navigationController didShowViewController:viewController animated:animated];
}

@end
