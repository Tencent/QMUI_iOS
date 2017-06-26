//
//  QMUINavigationController.m
//  qmui
//
//  Created by QQMail on 14-6-24.
//  Copyright (c) 2014年 QMUI Team. All rights reserved.
//

#import "QMUINavigationController.h"
#import "QMUICore.h"
#import "QMUINavigationTitleView.h"
#import "QMUICommonViewController.h"
#import "QMUIButton.h"
#import "UIViewController+QMUI.h"
#import "UINavigationController+QMUI.h"

@interface QMUINavigationController () <UIGestureRecognizerDelegate>

/// 记录当前是否正在 push/pop 界面的动画过程，如果动画尚未结束，不应该继续 push/pop 其他界面
@property(nonatomic, assign) BOOL isViewControllerTransiting;

/// 即将要被pop的controller
@property(nonatomic, weak) UIViewController *viewControllerPopping;

/**
 *  因为QMUINavigationController把delegate指向了自己来做一些基类要做的事情，所以如果当外面重新指定了delegate，那么就会覆盖原本的delegate。<br/>
 *  为了避免这个问题，并且外面也可以实现实现navigationController的delegate方法，这里使用delegateProxy来保存外面指定的delegate，然后在基类的delegate方法实现里面会去调用delegateProxy的方法实现。
 */
@property(nonatomic, weak) id <UINavigationControllerDelegate> delegateProxy;

@end

@implementation QMUINavigationController

#pragma mark - 生命周期函数 && 基类方法重写

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        [self didInitialized];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
        [self didInitialized];
    }
    return self;
}

- (void)didInitialized {
    // UIView.tintColor 并不支持 UIAppearance 协议，所以不能通过 appearance 来设置，只能在实例里设置
    self.navigationBar.tintColor = NavBarTintColor;
    self.toolbar.tintColor = ToolBarTintColor;
}

- (void)dealloc {
    self.delegate = nil;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    if (!self.delegate) {
        self.delegate = self;
    }
    // 手势允许多次addTarget
    [self.interactivePopGestureRecognizer addTarget:self action:@selector(handleInteractivePopGestureRecognizer:)];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self willShowViewController:self.topViewController];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self didShowViewController:self.topViewController];
}

- (UIViewController *)popViewControllerAnimated:(BOOL)animated {
    // 从横屏界面pop 到竖屏界面，系统会调用两次 popViewController，如果这里加这个 if 判断，会误拦第二次 pop，导致错误
//    if (self.isViewControllerTransiting) {
//        NSAssert(NO, @"isViewControllerTransiting = YES, %s, self.viewControllers = %@", __func__, self.viewControllers);
//        return nil;
//    }
    
    if (self.viewControllers.count < 2) {
        // 只剩 1 个 viewController 或者不存在 viewController 时，调用 popViewControllerAnimated: 后不会有任何变化，所以不需要触发 willPop / didPop
        return [super popViewControllerAnimated:animated];
    }
    
    if (animated) {
        self.isViewControllerTransiting = YES;
    }
    
    UIViewController *viewController = [self topViewController];
    self.viewControllerPopping = viewController;
    if ([viewController respondsToSelector:@selector(willPopInNavigationControllerWithAnimated:)]) {
        [((UIViewController<QMUINavigationControllerDelegate> *)viewController) willPopInNavigationControllerWithAnimated:animated];
    }
    viewController = [super popViewControllerAnimated:animated];
    if ([viewController respondsToSelector:@selector(didPopInNavigationControllerWithAnimated:)]) {
        [((UIViewController<QMUINavigationControllerDelegate> *)viewController) didPopInNavigationControllerWithAnimated:animated];
    }
    return viewController;
}

- (NSArray<UIViewController *> *)popToViewController:(UIViewController *)viewController animated:(BOOL)animated {
    // 从横屏界面pop 到竖屏界面，系统会调用两次 popViewController，如果这里加这个 if 判断，会误拦第二次 pop，导致错误
//    if (self.isViewControllerTransiting) {
//        NSAssert(NO, @"isViewControllerTransiting = YES, %s, self.viewControllers = %@", __func__, self.viewControllers);
//        return nil;
//    }
    
    if (!viewController || self.topViewController == viewController) {
        // 当要被 pop 到的 viewController 已经处于最顶层时，调用 super 默认也是什么都不做，所以直接 return 掉
        return [super popToViewController:viewController animated:animated];
    }
    
    if (animated) {
        self.isViewControllerTransiting = YES;
    }
    
    self.viewControllerPopping = self.topViewController;
    
    // will pop
    for (NSInteger i = self.viewControllers.count - 1; i > 0; i--) {
        UIViewController *viewControllerPopping = self.viewControllers[i];
        if (viewControllerPopping == viewController) {
            break;
        }
        
        if ([viewControllerPopping respondsToSelector:@selector(willPopInNavigationControllerWithAnimated:)]) {
            BOOL animatedArgument = i == self.viewControllers.count - 1 ? animated : NO;// 只有当前可视的那个 viewController 的 animated 是跟随参数走的，其他 viewController 由于不可视，不管参数的值为多少，都认为是无动画地 pop
            [((UIViewController<QMUINavigationControllerDelegate> *)viewControllerPopping) willPopInNavigationControllerWithAnimated:animatedArgument];
        }
    }
    
    NSArray<UIViewController *> *poppedViewControllers = [super popToViewController:viewController animated:animated];
    
    // did pop
    for (NSInteger i = poppedViewControllers.count - 1; i >= 0; i--) {
        UIViewController *viewControllerPopped = poppedViewControllers[i];
        if ([viewControllerPopped respondsToSelector:@selector(didPopInNavigationControllerWithAnimated:)]) {
            BOOL animatedArgument = i == poppedViewControllers.count - 1 ? animated : NO;// 只有当前可视的那个 viewController 的 animated 是跟随参数走的，其他 viewController 由于不可视，不管参数的值为多少，都认为是无动画地 pop
            [((UIViewController<QMUINavigationControllerDelegate> *)viewControllerPopped) didPopInNavigationControllerWithAnimated:animatedArgument];
        }
    }
    
    return poppedViewControllers;
}

- (NSArray<UIViewController *> *)popToRootViewControllerAnimated:(BOOL)animated {
    // 从横屏界面pop 到竖屏界面，系统会调用两次 popViewController，如果这里加这个 if 判断，会误拦第二次 pop，导致错误
//    if (self.isViewControllerTransiting) {
//        NSAssert(NO, @"isViewControllerTransiting = YES, %s, self.viewControllers = %@", __func__, self.viewControllers);
//        return nil;
//    }
    
    // 在配合 tabBarItem 使用的情况下，快速重复点击相同 item 可能会重复调用 popToRootViewControllerAnimated:，而此时其实已经处于 rootViewController 了，就没必要继续走后续的流程，否则一些变量会得不到重置。
    if (self.topViewController == self.qmui_rootViewController) {
        return nil;
    }
    
    if (animated) {
        self.isViewControllerTransiting = YES;
    }
    
    self.viewControllerPopping = self.topViewController;
    
    // will pop
    for (NSInteger i = self.viewControllers.count - 1; i > 0; i--) {
        UIViewController *viewControllerPopping = self.viewControllers[i];
        if ([viewControllerPopping respondsToSelector:@selector(willPopInNavigationControllerWithAnimated:)]) {
            BOOL animatedArgument = i == self.viewControllers.count - 1 ? animated : NO;// 只有当前可视的那个 viewController 的 animated 是跟随参数走的，其他 viewController 由于不可视，不管参数的值为多少，都认为是无动画地 pop
            [((UIViewController<QMUINavigationControllerDelegate> *)viewControllerPopping) willPopInNavigationControllerWithAnimated:animatedArgument];
        }
    }
    
    NSArray<UIViewController *> * poppedViewControllers = [super popToRootViewControllerAnimated:animated];
    
    // did pop
    for (NSInteger i = poppedViewControllers.count - 1; i >= 0; i--) {
        UIViewController *viewControllerPopped = poppedViewControllers[i];
        if ([viewControllerPopped respondsToSelector:@selector(didPopInNavigationControllerWithAnimated:)]) {
            BOOL animatedArgument = i == poppedViewControllers.count - 1 ? animated : NO;// 只有当前可视的那个 viewController 的 animated 是跟随参数走的，其他 viewController 由于不可视，不管参数的值为多少，都认为是无动画地 pop
            [((UIViewController<QMUINavigationControllerDelegate> *)viewControllerPopped) didPopInNavigationControllerWithAnimated:animatedArgument];
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
            [((UIViewController<QMUINavigationControllerDelegate> *)obj) willPopInNavigationControllerWithAnimated:animatedArgument];
        }
    }];
    
    [super setViewControllers:viewControllers animated:animated];
    
    // did pop
    [viewControllersPopping enumerateObjectsWithOptions:NSEnumerationReverse usingBlock:^(UIViewController * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj respondsToSelector:@selector(didPopInNavigationControllerWithAnimated:)]) {
            BOOL animatedArgument = obj == topViewController ? animated : NO;// 只有当前可视的那个 viewController 的 animated 是跟随参数走的，其他 viewController 由于不可视，不管参数的值为多少，都认为是无动画地 pop
            [((UIViewController<QMUINavigationControllerDelegate> *)obj) didPopInNavigationControllerWithAnimated:animatedArgument];
        }
    }];
    
    // 操作前后如果 topViewController 没发生变化，则为它调用一个特殊的时机
    if (topViewController == viewControllers.lastObject) {
        if ([topViewController respondsToSelector:@selector(viewControllerKeepingAppearWhenSetViewControllersWithAnimated:)]) {
            [((UIViewController<QMUINavigationControllerDelegate> *)topViewController) viewControllerKeepingAppearWhenSetViewControllersWithAnimated:animated];
        }
    }
}

- (void)pushViewController:(UIViewController *)viewController animated:(BOOL)animated {
    if (self.isViewControllerTransiting || !viewController) {
        NSAssert(NO, @"%s, isViewControllerTransiting = %@, viewController = %@, self.viewControllers = %@",  __func__, StringFromBOOL(self.isViewControllerTransiting), viewController, self.viewControllers);
        return;
    }
    
    if (animated) {
        self.isViewControllerTransiting = YES;
    }
    
    UIViewController *currentViewController = self.topViewController;
    if (currentViewController) {
        if (!NeedsBackBarButtonItemTitle) {
            currentViewController.navigationItem.backBarButtonItem = [QMUINavigationButton barButtonItemWithType:QMUINavigationButtonTypeNormal title:@"" position:QMUINavigationButtonPositionLeft target:nil action:NULL];
        } else {
            UIViewController<QMUINavigationControllerDelegate> *vc = (UIViewController<QMUINavigationControllerDelegate> *)viewController;
            if ([vc respondsToSelector:@selector(backBarButtonItemTitleWithPreviousViewController:)]) {
                NSString *title = [vc backBarButtonItemTitleWithPreviousViewController:currentViewController];
                currentViewController.navigationItem.backBarButtonItem = [QMUINavigationButton barButtonItemWithType:QMUINavigationButtonTypeNormal title:title position:QMUINavigationButtonPositionLeft target:nil action:NULL];
            }
        }
    }
    [super pushViewController:viewController animated:animated];
}

- (void)setDelegate:(id<UINavigationControllerDelegate>)delegate {
    self.delegateProxy = delegate != self ? delegate : nil;
    [super setDelegate:delegate ? self : nil];
}

// 重写这个方法才能让 viewControllers 对 statusBar 的控制生效
- (UIViewController *)childViewControllerForStatusBarStyle {
    return self.topViewController;
}

#pragma mark - 自定义方法

// 根据当前的viewController，统一处理导航栏底部的分隔线、状态栏的颜色
- (void)renderStyleInNavigationController:(UINavigationController *)navigationController currentViewController:(UIViewController *)viewController {
    if ([[viewController class] conformsToProtocol:@protocol(QMUINavigationControllerDelegate)]) {
        UIViewController<QMUINavigationControllerDelegate> *vc = (UIViewController<QMUINavigationControllerDelegate> *)viewController;
        
        // 控制界面的状态栏颜色
        if ([vc shouldSetStatusBarStyleLight]) {
            if ([[UIApplication sharedApplication] statusBarStyle] < UIStatusBarStyleLightContent) {
                [QMUIHelper renderStatusBarStyleLight];
            }
        } else {
            if ([[UIApplication sharedApplication] statusBarStyle] >= UIStatusBarStyleLightContent) {
                [QMUIHelper renderStatusBarStyleDark];
            }
        }
        
        // 显示/隐藏 导航栏
        if (NavigationBarHiddenStateUsable) {
            QMUINavigationBarHiddenState navigationBarHiddenOption = [vc preferredNavigationBarHiddenState];
            BOOL hidden = NO;
            BOOL animated = YES;
            if (navigationBarHiddenOption == QMUINavigationBarHiddenStateHideWithAnimated || navigationBarHiddenOption == QMUINavigationBarHiddenStateHideWithoutAnimated) {
                hidden = YES;
            }
            if (navigationBarHiddenOption == QMUINavigationBarHiddenStateShowWithoutAnimated || navigationBarHiddenOption == QMUINavigationBarHiddenStateHideWithoutAnimated) {
                animated = NO;
            }
            if (hidden && !vc.navigationController.navigationBarHidden) {
                [vc.navigationController setNavigationBarHidden:YES animated:animated];
            }
            if (!hidden && vc.navigationController.navigationBarHidden) {
                [vc.navigationController setNavigationBarHidden:NO animated:animated];
            }
        }
        
        // 导航栏的背景
        if ([vc respondsToSelector:@selector(navigationBarBackgroundImage)]) {
            UIImage *backgroundImage = [vc navigationBarBackgroundImage];
            [self.navigationBar setBackgroundImage:backgroundImage forBarMetrics:UIBarMetricsDefault];
        } else {
            [self.navigationBar setBackgroundImage:NavBarBackgroundImage forBarMetrics:UIBarMetricsDefault];
        }
        
        // 导航栏底部的分隔线
        if ([vc respondsToSelector:@selector(navigationBarShadowImage)]) {
            UIImage *shadowImage = [vc navigationBarShadowImage];
            [self.navigationBar setShadowImage:shadowImage];
        } else {
            [self.navigationBar setShadowImage:NavBarShadowImage];
        }
        
        // 导航栏上控件的主题色
        if ([vc respondsToSelector:@selector(navigationBarTintColor)]) {
            UIColor *tintColor = [vc navigationBarTintColor];
            self.navigationBar.tintColor = tintColor;
        } else {
            self.navigationBar.tintColor = NavBarTintColor;
        }
        
        // 导航栏title的颜色
        if ([vc isKindOfClass:[QMUICommonViewController class]]) {
            QMUICommonViewController *qmuiVC = (QMUICommonViewController *)vc;
            if ([qmuiVC respondsToSelector:@selector(titleViewTintColor)]) {
                UIColor *tintColor = [qmuiVC titleViewTintColor];
                qmuiVC.titleView.tintColor = tintColor;
            } else {
                qmuiVC.titleView.tintColor = NavBarTitleColor;
            }
        }
    }
}

// 接管系统手势返回的回调
- (void)handleInteractivePopGestureRecognizer:(UIScreenEdgePanGestureRecognizer *)gestureRecognizer {
    UIGestureRecognizerState state = gestureRecognizer.state;
    if (state == UIGestureRecognizerStateEnded) {
        if (CGRectGetMinX(self.topViewController.view.superview.frame) < 0) {
            // by molice:只是碰巧发现如果是手势返回取消时，不管在哪个位置取消，self.topViewController.view.superview.frame.orgin.x必定是-124，所以用这个<0的条件来判断
            [self navigationController:self willShowViewController:self.viewControllerPopping animated:YES];
            self.viewControllerPopping = nil;
            self.isViewControllerTransiting = NO;
            QMUILog(@"手势返回放弃了");
        } else {
            QMUILog(@"执行手势返回");
        }
    }
}

#pragma mark - <UINavigationControllerDelegate> 

// 注意如果实现了某一个navigationController的delegate方法，必须同时检查并且调用delegateProxy相对应的方法

- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated {
    [self willShowViewController:viewController];
    if ([self.delegateProxy respondsToSelector:_cmd]) {
        [self.delegateProxy navigationController:navigationController willShowViewController:viewController animated:animated];
    }
}

- (void)navigationController:(UINavigationController *)navigationController didShowViewController:(UIViewController *)viewController animated:(BOOL)animated {
    self.viewControllerPopping = nil;
    self.isViewControllerTransiting = NO;
    [self didShowViewController:viewController];
    if ([self.delegateProxy respondsToSelector:_cmd]) {
        [self.delegateProxy navigationController:navigationController didShowViewController:viewController animated:animated];
    }
}

- (NSMethodSignature *)methodSignatureForSelector:(SEL)aSelector {
    return [super methodSignatureForSelector:aSelector] ?: [(id)self.delegateProxy methodSignatureForSelector:aSelector];
}

- (void)forwardInvocation:(NSInvocation *)anInvocation {
    if ([(id)self.delegateProxy respondsToSelector:anInvocation.selector]) {
        [anInvocation invokeWithTarget:(id)self.delegateProxy];
    }
}

- (BOOL)respondsToSelector:(SEL)aSelector {
    return [super respondsToSelector:aSelector] || ([self shouldRespondDelegeateProxyWithSelector:aSelector] && [self.delegateProxy respondsToSelector:aSelector]);
}

- (BOOL)shouldRespondDelegeateProxyWithSelector:(SEL)aSelctor {
    // 目前仅支持下面两个delegate方法，如果需要增加全局的自定义转场动画，可以额外增加多上面注释的两个方法。
    return [NSStringFromSelector(aSelctor) isEqualToString:@"navigationController:willShowViewController:animated:"] ||
    [NSStringFromSelector(aSelctor) isEqualToString:@"navigationController:didShowViewController:animated:"];
}

#pragma mark - 屏幕旋转

- (BOOL)shouldAutorotate {
    return [self.topViewController qmui_hasOverrideUIKitMethod:_cmd] ? [self.topViewController shouldAutorotate] : YES;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return [self.topViewController qmui_hasOverrideUIKitMethod:_cmd] ? [self.topViewController supportedInterfaceOrientations] : SupportedOrientationMask;
}

@end


@implementation QMUINavigationController (UISubclassingHooks)

- (void)willShowViewController:(UIViewController *)viewController {
    // 子类可以重写
    [self renderStyleInNavigationController:self currentViewController:viewController];
}

- (void)didShowViewController:(UIViewController *)viewController {
    // 子类可以重写
}

@end
