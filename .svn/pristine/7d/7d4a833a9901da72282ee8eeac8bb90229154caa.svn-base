//
//  UINavigationController+NavigationBarTransition.m
//  qmui
//
//  Created by QQMail on 16/2/22.
//  Copyright © 2016年 QMUI Team. All rights reserved.
//

#import "UINavigationController+NavigationBarTransition.h"
#import "QMUINavigationController.h"
#import "QMUICommonDefines.h"
#import "QMUIConfiguration.h"
#import "UINavigationController+QMUI.h"
#import "UIImage+QMUI.h"
#import "UIViewController+QMUI.h"
#import "UINavigationBar+Transition.h"

/**
 *  为了响应<b>NavigationBarTransition</b>分类的功能，UIViewController需要做一些相应的支持。
 *  @see UINavigationController+NavigationBarTransition.h
 */
@interface UIViewController (NavigationBarTransition)

/// 用来模仿真的navBar的，在转场过程中存在的一条假navBar
@property (nonatomic, strong) UINavigationBar *transitionNavigationBar;

/// 是否要把真的navBar隐藏
@property (nonatomic, assign) BOOL prefersNavigationBarBackgroundViewHidden;

/// 原始的clipsToBounds
@property(nonatomic, assign) BOOL originClipsToBounds;

/// 原始containerView的背景色
@property(nonatomic, strong) UIColor *originContainerViewBackgroundColor;

/// 用于插入到fromVC和toVC的block
typedef void (^navigationBarTransitionWillAppearInjectBlock)(UIViewController *viewController, BOOL animated);
@property (nonatomic, copy) navigationBarTransitionWillAppearInjectBlock willAppearInjectBlock;

/// 添加假的navBar
- (void)addTransitionNavigationBarIfNeeded;

/// .m文件里自己赋值和使用。因为有些特殊情况下viewDidAppear之后，有可能还会调用到viewWillLayoutSubviews，导致原始的navBar隐藏，所以用这个属性做个保护。
@property (nonatomic, assign) BOOL lockTransitionNavigationBar;

- (BOOL)respondCustomNavigationBarTransitionWhenPushAppearing;
- (BOOL)respondCustomNavigationBarTransitionWhenPushDisappearing;
- (BOOL)respondCustomNavigationBarTransitionWhenPopAppearing;
- (BOOL)respondCustomNavigationBarTransitionWhenPopDisappearing;
- (BOOL)respondCustomNavigationBarTransitionIfBarHiddenable;
- (BOOL)respondCustomNavigationBarTransitionWithBarHiddenState;

- (BOOL)canCustomNavigationBarTransitionWhenPushAppearing;
- (BOOL)canCustomNavigationBarTransitionWhenPushDisappearing;
- (BOOL)canCustomNavigationBarTransitionWhenPopAppearing;
- (BOOL)canCustomNavigationBarTransitionWhenPopDisappearing;
- (BOOL)canCustomNavigationBarTransitionIfBarHiddenable;
- (BOOL)canCustomNavigationBarTransitionWithBarHiddenState;

@end


@implementation UIViewController (NavigationBarTransition)

#pragma mark - 主流程

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        Class cls = [self class];
        ReplaceMethod(cls, @selector(viewWillLayoutSubviews), @selector(NavigationBarTransition_viewWillLayoutSubviews));
        ReplaceMethod(cls, @selector(viewWillAppear:), @selector(NavigationBarTransition_viewWillAppear:));
        ReplaceMethod(cls, @selector(viewDidAppear:), @selector(NavigationBarTransition_viewDidAppear:));
        ReplaceMethod(cls, @selector(viewDidDisappear:), @selector(NavigationBarTransition_viewDidDisappear:));
    });
}

- (void)NavigationBarTransition_viewWillAppear:(BOOL)animated {
    [self NavigationBarTransition_viewWillAppear:animated];
    if (self.willAppearInjectBlock) {
        self.willAppearInjectBlock(self, animated);
    }
}

- (void)NavigationBarTransition_viewDidAppear:(BOOL)animated {
    if (self.transitionNavigationBar) {
        [UIViewController replaceStyleForNavigationBar:self.transitionNavigationBar withNavigationBar:self.navigationController.navigationBar];
        [self removeTransitionNavigationBar];
        self.lockTransitionNavigationBar = YES;
        
        id <UIViewControllerTransitionCoordinator> transitionCoordinator = self.transitionCoordinator;
        [transitionCoordinator containerView].backgroundColor = self.originContainerViewBackgroundColor;
        self.view.clipsToBounds = self.originClipsToBounds;
    }
    self.prefersNavigationBarBackgroundViewHidden = NO;
    [self NavigationBarTransition_viewDidAppear:animated];
}

- (void)NavigationBarTransition_viewDidDisappear:(BOOL)animated {
    if (self.transitionNavigationBar) {
        [self removeTransitionNavigationBar];
        self.lockTransitionNavigationBar = NO;
        
        self.view.clipsToBounds = self.originClipsToBounds;
    }
    [self NavigationBarTransition_viewDidDisappear:animated];
}

- (void)NavigationBarTransition_viewWillLayoutSubviews {
    
    id <UIViewControllerTransitionCoordinator> transitionCoordinator = self.transitionCoordinator;
    UIViewController *fromViewController = [transitionCoordinator viewControllerForKey:UITransitionContextFromViewControllerKey];
    UIViewController *toViewController = [transitionCoordinator viewControllerForKey:UITransitionContextToViewControllerKey];
    
    BOOL isCurrentToViewController = (self == self.navigationController.viewControllers.lastObject && self == toViewController);
    BOOL isPushingViewContrller = [self.navigationController.viewControllers containsObject:fromViewController];
    
    if (isCurrentToViewController && !self.lockTransitionNavigationBar) {
        
        BOOL shouldCustomNavigationBarTransition = NO;
        
        if (!self.transitionNavigationBar) {
            
            if (isPushingViewContrller) {
                if ([toViewController canCustomNavigationBarTransitionWhenPushAppearing] ||
                    [fromViewController canCustomNavigationBarTransitionWhenPushDisappearing]) {
                    shouldCustomNavigationBarTransition = YES;
                }
            } else {
                if ([toViewController canCustomNavigationBarTransitionWhenPopAppearing] ||
                    [fromViewController canCustomNavigationBarTransitionWhenPopDisappearing]) {
                    shouldCustomNavigationBarTransition = YES;
                }
            }
            
            if (shouldCustomNavigationBarTransition) {
                if (self.navigationController.navigationBar.translucent) {
                    // 如果原生bar是半透明的，需要给containerView加个背景色，否则有可能会看到下面的默认黑色背景色
                    toViewController.originContainerViewBackgroundColor = [transitionCoordinator containerView].backgroundColor;
                    [transitionCoordinator containerView].backgroundColor = [self containerViewBackgroundColor];
                }
                fromViewController.originClipsToBounds = fromViewController.view.clipsToBounds;
                toViewController.originClipsToBounds = toViewController.view.clipsToBounds;
                fromViewController.view.clipsToBounds = NO;
                toViewController.view.clipsToBounds = NO;
                [self addTransitionNavigationBarIfNeeded];
                [self resizeTransitionNavigationBarFrame];
                self.navigationController.navigationBar.transitionNavigationBar = self.transitionNavigationBar;
                self.prefersNavigationBarBackgroundViewHidden = YES;
            }
        }
    }
    
    [self NavigationBarTransition_viewWillLayoutSubviews];
}

- (void)addTransitionNavigationBarIfNeeded {
    
    if (!self.view.window || !self.navigationController.navigationBar) {
        return;
    }
    
    UINavigationBar *originBar = self.navigationController.navigationBar;
    UINavigationBar *customBar = [[UINavigationBar alloc] init];
    
    if (customBar.barStyle != originBar.barStyle) {
        customBar.barStyle = originBar.barStyle;
    }
    if (customBar.translucent != originBar.translucent) {
        customBar.translucent = originBar.translucent;
    }
    if (![customBar.barTintColor isEqual:originBar.barTintColor]) {
        customBar.barTintColor = originBar.barTintColor;
    }
    UIImage *backgroundImage = [originBar backgroundImageForBarMetrics:UIBarMetricsDefault];
    if (backgroundImage && CGSizeEqualToSize(backgroundImage.size, CGSizeZero)) {
        // 假设这里的图片时通过`[UIImage new]`这种形式创建的，那么会navBar会奇怪地显示为系统默认navBar的样式。不知道为什么 navController 设置自己的 navBar 为 [UIImage new] 却没事，所以这里做个保护。
        backgroundImage = [UIImage qmui_imageWithColor:UIColorClear];
    }
    [customBar setBackgroundImage:backgroundImage forBarMetrics:UIBarMetricsDefault];
    [customBar setShadowImage:originBar.shadowImage];
    
    self.transitionNavigationBar = customBar;
    [self resizeTransitionNavigationBarFrame];
    
    if (!self.navigationController.navigationBarHidden) {
        [self.view addSubview:self.transitionNavigationBar];
    }
}

- (void)removeTransitionNavigationBar {
    if (!self.transitionNavigationBar) {
        return;
    }
    [self.transitionNavigationBar removeFromSuperview];
    self.transitionNavigationBar = nil;
}

- (void)resizeTransitionNavigationBarFrame {
    if (!self.view.window) {
        return;
    }
    UIView *backgroundView = [self.navigationController.navigationBar valueForKey:@"_backgroundView"];
    CGRect rect = [backgroundView.superview convertRect:backgroundView.frame toView:self.view];
    self.transitionNavigationBar.frame = rect;
}

#pragma mark - 工具方法

+ (void)replaceStyleForNavigationBar:(UINavigationBar *)navbarA withNavigationBar:(UINavigationBar *)navbarB {
    navbarB.barStyle = navbarA.barStyle;
    navbarB.barTintColor = navbarA.barTintColor;
    [navbarB setBackgroundImage:[navbarA backgroundImageForBarMetrics:UIBarMetricsDefault] forBarMetrics:UIBarMetricsDefault];
    [navbarB setShadowImage:navbarA.shadowImage];
}

// 该 viewController 是否实现自定义 navBar 动画的协议

- (BOOL)respondCustomNavigationBarTransitionWhenPushAppearing {
    BOOL respondPushAppearing = NO;
    if ([self qmui_respondQMUINavigationControllerDelegate]) {
        UIViewController<QMUINavigationControllerDelegate> *vc = (UIViewController<QMUINavigationControllerDelegate> *)self;
        if ([vc respondsToSelector:@selector(shouldCustomNavigationBarTransitionWhenPushAppearing)]) {
            respondPushAppearing = YES;
        }
    }
    return respondPushAppearing;
}

- (BOOL)respondCustomNavigationBarTransitionWhenPushDisappearing {
    BOOL respondPushDisappearing = NO;
    if ([self qmui_respondQMUINavigationControllerDelegate]) {
        UIViewController<QMUINavigationControllerDelegate> *vc = (UIViewController<QMUINavigationControllerDelegate> *)self;
        if ([vc respondsToSelector:@selector(shouldCustomNavigationBarTransitionWhenPushDisappearing)]) {
            respondPushDisappearing = YES;
        }
    }
    return respondPushDisappearing;
}

- (BOOL)respondCustomNavigationBarTransitionWhenPopAppearing {
    BOOL respondPopAppearing = NO;
    if ([self qmui_respondQMUINavigationControllerDelegate]) {
        UIViewController<QMUINavigationControllerDelegate> *vc = (UIViewController<QMUINavigationControllerDelegate> *)self;
        if ([vc respondsToSelector:@selector(shouldCustomNavigationBarTransitionWhenPopAppearing)]) {
            respondPopAppearing = YES;
        }
    }
    return respondPopAppearing;
}

- (BOOL)respondCustomNavigationBarTransitionWhenPopDisappearing {
    BOOL respondPopDisappearing = NO;
    if ([self qmui_respondQMUINavigationControllerDelegate]) {
        UIViewController<QMUINavigationControllerDelegate> *vc = (UIViewController<QMUINavigationControllerDelegate> *)self;
        if ([vc respondsToSelector:@selector(shouldCustomNavigationBarTransitionWhenPopDisappearing)]) {
            respondPopDisappearing = YES;
        }
    }
    return respondPopDisappearing;
}

- (BOOL)respondCustomNavigationBarTransitionIfBarHiddenable {
    BOOL respondIfBarHiddenable = NO;
    if ([self qmui_respondQMUINavigationControllerDelegate]) {
        UIViewController<QMUINavigationControllerDelegate> *vc = (UIViewController<QMUINavigationControllerDelegate> *)self;
        if ([vc respondsToSelector:@selector(shouldCustomNavigationBarTransitionIfBarHiddenable)]) {
            respondIfBarHiddenable = YES;
        }
    }
    return respondIfBarHiddenable;
}

- (BOOL)respondCustomNavigationBarTransitionWithBarHiddenState {
    BOOL respondWithBarHiddenState = NO;
    if ([self qmui_respondQMUINavigationControllerDelegate]) {
        UIViewController<QMUINavigationControllerDelegate> *vc = (UIViewController<QMUINavigationControllerDelegate> *)self;
        if ([vc respondsToSelector:@selector(shouldCustomNavigationBarTransitionWithBarHiddenState)]) {
            respondWithBarHiddenState = YES;
        }
    }
    return respondWithBarHiddenState;
}

// 该 viewController 实现自定义 navBar 动画的协议的返回值

- (BOOL)canCustomNavigationBarTransitionWhenPushAppearing {
    if ([self respondCustomNavigationBarTransitionWhenPushAppearing]) {
        UIViewController<QMUINavigationControllerDelegate> *vc = (UIViewController<QMUINavigationControllerDelegate> *)self;
        return  [vc shouldCustomNavigationBarTransitionWhenPushAppearing];
    }
    return NO;
}

- (BOOL)canCustomNavigationBarTransitionWhenPushDisappearing {
    if ([self respondCustomNavigationBarTransitionWhenPushDisappearing]) {
        UIViewController<QMUINavigationControllerDelegate> *vc = (UIViewController<QMUINavigationControllerDelegate> *)self;
        return  [vc shouldCustomNavigationBarTransitionWhenPushDisappearing];
    }
    return NO;
}

- (BOOL)canCustomNavigationBarTransitionWhenPopAppearing {
    if ([self respondCustomNavigationBarTransitionWhenPopAppearing]) {
        UIViewController<QMUINavigationControllerDelegate> *vc = (UIViewController<QMUINavigationControllerDelegate> *)self;
        return  [vc shouldCustomNavigationBarTransitionWhenPopAppearing];
    }
    return NO;
}

- (BOOL)canCustomNavigationBarTransitionWhenPopDisappearing {
    if ([self respondCustomNavigationBarTransitionWhenPopDisappearing]) {
        UIViewController<QMUINavigationControllerDelegate> *vc = (UIViewController<QMUINavigationControllerDelegate> *)self;
        return  [vc shouldCustomNavigationBarTransitionWhenPopDisappearing];
    }
    return NO;
}

- (UIColor *)containerViewBackgroundColor {
    UIColor *backgroundColor = UIColorWhite;
    if ([self qmui_respondQMUINavigationControllerDelegate]) {
        UIViewController<QMUINavigationControllerDelegate> *vc = (UIViewController<QMUINavigationControllerDelegate> *)self;
        if ([vc respondsToSelector:@selector(containerViewBackgroundColorWhenTransition)]) {
            backgroundColor = [vc containerViewBackgroundColorWhenTransition];
        }
    }
    return backgroundColor;
}

- (BOOL)canCustomNavigationBarTransitionIfBarHiddenable {
    if ([self respondCustomNavigationBarTransitionIfBarHiddenable]) {
        UIViewController<QMUINavigationControllerDelegate> *vc = (UIViewController<QMUINavigationControllerDelegate> *)self;
        return  [vc shouldCustomNavigationBarTransitionIfBarHiddenable];
    }
    return NO;
}

- (BOOL)canCustomNavigationBarTransitionWithBarHiddenState {
    if ([self respondCustomNavigationBarTransitionWithBarHiddenState]) {
        UIViewController<QMUINavigationControllerDelegate> *vc = (UIViewController<QMUINavigationControllerDelegate> *)self;
        return  [vc shouldCustomNavigationBarTransitionWithBarHiddenState];
    }
    return NO;
}

#pragma mark - Setter / Getter

- (BOOL)lockTransitionNavigationBar {
    return [objc_getAssociatedObject(self, _cmd) boolValue];
}

- (void)setLockTransitionNavigationBar:(BOOL)lockTransitionNavigationBar {
    objc_setAssociatedObject(self, @selector(lockTransitionNavigationBar), [[NSNumber alloc] initWithBool:lockTransitionNavigationBar], OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (UINavigationBar *)transitionNavigationBar {
    return objc_getAssociatedObject(self, _cmd);
}

- (void)setTransitionNavigationBar:(UINavigationBar *)transitionNavigationBar {
    objc_setAssociatedObject(self, @selector(transitionNavigationBar), transitionNavigationBar, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (BOOL)prefersNavigationBarBackgroundViewHidden {
    return [objc_getAssociatedObject(self, _cmd) boolValue];
}

- (void)setPrefersNavigationBarBackgroundViewHidden:(BOOL)prefersNavigationBarBackgroundViewHidden {
    [[self.navigationController.navigationBar valueForKey:@"_backgroundView"] setHidden:prefersNavigationBarBackgroundViewHidden];
    objc_setAssociatedObject(self, @selector(prefersNavigationBarBackgroundViewHidden), [[NSNumber alloc] initWithBool:prefersNavigationBarBackgroundViewHidden], OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (navigationBarTransitionWillAppearInjectBlock)willAppearInjectBlock {
    return objc_getAssociatedObject(self, _cmd);
}

- (void)setWillAppearInjectBlock:(navigationBarTransitionWillAppearInjectBlock)willAppearInjectBlock {
    objc_setAssociatedObject(self, @selector(willAppearInjectBlock), willAppearInjectBlock, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (BOOL)originClipsToBounds {
    return [objc_getAssociatedObject(self, _cmd) boolValue];
}

- (void)setOriginClipsToBounds:(BOOL)originClipsToBounds {
    objc_setAssociatedObject(self, @selector(originClipsToBounds), [[NSNumber alloc] initWithBool:originClipsToBounds], OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (UIColor *)originContainerViewBackgroundColor {
    return objc_getAssociatedObject(self, _cmd);
}

- (void)setOriginContainerViewBackgroundColor:(UIColor *)originContainerViewBackgroundColor {
    objc_setAssociatedObject(self, @selector(originContainerViewBackgroundColor), originContainerViewBackgroundColor, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

@end


@implementation UINavigationController (NavigationBarTransition)

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        Class cls = [self class];
        ReplaceMethod(cls, @selector(pushViewController:animated:), @selector(NavigationBarTransition_pushViewController:animated:));
        ReplaceMethod(cls, @selector(popViewControllerAnimated:), @selector(NavigationBarTransition_popViewControllerAnimated:));
        ReplaceMethod(cls, @selector(popToViewController:animated:), @selector(NavigationBarTransition_popToViewController:animated:));
        ReplaceMethod(cls, @selector(popToRootViewControllerAnimated:), @selector(NavigationBarTransition_popToRootViewControllerAnimated:));
    });
}

- (void)NavigationBarTransition_pushViewController:(UIViewController *)viewController animated:(BOOL)animated {
    UIViewController *disappearingViewController = self.viewControllers.lastObject;
    if (!disappearingViewController) {
        return [self NavigationBarTransition_pushViewController:viewController animated:animated];
    }
    
    BOOL shouldCustomNavigationBarTransition = NO;
    if ([disappearingViewController canCustomNavigationBarTransitionWhenPushDisappearing]) {
        shouldCustomNavigationBarTransition = YES;
    }
    if (!shouldCustomNavigationBarTransition && [viewController canCustomNavigationBarTransitionWhenPushAppearing]) {
        shouldCustomNavigationBarTransition = YES;
    }
    if (shouldCustomNavigationBarTransition) {
        [disappearingViewController addTransitionNavigationBarIfNeeded];
        disappearingViewController.prefersNavigationBarBackgroundViewHidden = YES;
    }
    
    // tq：这是为了兼容全屏状态下的效果，如果原来的"页面A"是 disappearingViewController ，将显示的"页面B"是 appearingViewController ，则：
    // 当A或B是允许全屏的vc，那么A和B都需要插入 Block 来等下次 viewWillAppear 改变 NavBar 的状态，以防回退旧的页面 bar 为空。
    if ([viewController canCustomNavigationBarTransitionIfBarHiddenable] || [disappearingViewController canCustomNavigationBarTransitionIfBarHiddenable]) {
        [self setupNavigationBarAppearanceWithViewController:viewController];
    }

    return [self NavigationBarTransition_pushViewController:viewController animated:animated];
}

- (void)setupNavigationBarAppearanceWithViewController:(UIViewController *)viewController{
    __weak typeof(self) weakSelf = self;
    navigationBarTransitionWillAppearInjectBlock block = ^(UIViewController *viewController, BOOL animated) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        
        if (strongSelf) {
            if ([viewController canCustomNavigationBarTransitionWithBarHiddenState]) {
                [strongSelf setNavigationBarHidden:YES animated:animated];
            } else {
                [strongSelf setNavigationBarHidden:NO animated:animated];
            }
        }
    };
    
    if (!viewController.willAppearInjectBlock) {
        viewController.willAppearInjectBlock = block;
    }
    
    // 如果是进入新的vc，需要把旧的 vc 也加上该 block。
    UIViewController *disappearingViewController = self.viewControllers.lastObject;
    if (!disappearingViewController.willAppearInjectBlock) {
        disappearingViewController.willAppearInjectBlock = block;
    }
}

- (UIViewController *)NavigationBarTransition_popViewControllerAnimated:(BOOL)animated {
    UIViewController *disappearingViewController = self.viewControllers.lastObject;
    UIViewController *appearingViewController = self.viewControllers.count >= 2 ? self.viewControllers[self.viewControllers.count - 2] : nil;
    if (!disappearingViewController) {
        return [self NavigationBarTransition_popViewControllerAnimated:animated];
    }
    [self handlePopViewControllerNavigationBarTransitionWithDisappearViewController:disappearingViewController appearViewController:appearingViewController];
    
    return [self NavigationBarTransition_popViewControllerAnimated:animated];
}

- (NSArray<UIViewController *> *)NavigationBarTransition_popToViewController:(UIViewController *)viewController animated:(BOOL)animated {
    UIViewController *disappearingViewController = self.viewControllers.lastObject;
    UIViewController *appearingViewController = viewController;
    if (!disappearingViewController) {
        [self NavigationBarTransition_popToViewController:viewController animated:animated];
    }
    [self handlePopViewControllerNavigationBarTransitionWithDisappearViewController:disappearingViewController appearViewController:appearingViewController];
    return [self NavigationBarTransition_popToViewController:viewController animated:animated];
}

- (NSArray<UIViewController *> *)NavigationBarTransition_popToRootViewControllerAnimated:(BOOL)animated {
    if (self.viewControllers.count > 1) {
        UIViewController *disappearingViewController = self.viewControllers.lastObject;
        UIViewController *appearingViewController = self.viewControllers.firstObject;
        if (!disappearingViewController) {
            [self NavigationBarTransition_popToRootViewControllerAnimated:animated];
        }
        [self handlePopViewControllerNavigationBarTransitionWithDisappearViewController:disappearingViewController appearViewController:appearingViewController];
    }
    return [self NavigationBarTransition_popToRootViewControllerAnimated:animated];
}

- (void)handlePopViewControllerNavigationBarTransitionWithDisappearViewController:(UIViewController *)disappearViewController appearViewController:(UIViewController *)appearViewController {
    BOOL shouldCustomNavigationBarTransition = NO;
    if ([disappearViewController canCustomNavigationBarTransitionWhenPopDisappearing]) {
        shouldCustomNavigationBarTransition = YES;
    }
    if (appearViewController && !shouldCustomNavigationBarTransition && [appearViewController canCustomNavigationBarTransitionWhenPopAppearing]) {
        shouldCustomNavigationBarTransition = YES;
    }
    if (shouldCustomNavigationBarTransition) {
        [disappearViewController addTransitionNavigationBarIfNeeded];
        if (appearViewController.transitionNavigationBar) {
            // 假设从A→B→C，其中A设置了bar的样式，B跟随A所以B里没有设置bar样式的代码，C又把样式改为另一种，此时从C返回B时，由于B没有设置bar的样式的代码，所以bar的样式依然会保留C的，这就错了，所以每次都要手动改回来才保险
            [UIViewController replaceStyleForNavigationBar:appearViewController.transitionNavigationBar withNavigationBar:self.navigationBar];
        }
        disappearViewController.prefersNavigationBarBackgroundViewHidden = YES;
    }
}

@end
