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

- (navigationBarTransitionWillAppearInjectBlock)willAppearInjectBlock {
    return objc_getAssociatedObject(self, _cmd);
}

- (void)setWillAppearInjectBlock:(navigationBarTransitionWillAppearInjectBlock)willAppearInjectBlock {
    objc_setAssociatedObject(self, @selector(willAppearInjectBlock), willAppearInjectBlock, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (void)NavigationBarTransition_viewWillAppear:(BOOL)animated {
    [self NavigationBarTransition_viewWillAppear:animated];
    
    if (self.willAppearInjectBlock) {
        self.willAppearInjectBlock(self, animated);
    }
}

- (void)NavigationBarTransition_viewDidAppear:(BOOL)animated {
    if (self.transitionNavigationBar) {
        // 回到界面的时候，把假的navBar去掉并且还原老的navBar
        self.navigationController.navigationBar.barTintColor = self.transitionNavigationBar.barTintColor;
        [self.navigationController.navigationBar setBackgroundImage:[self.transitionNavigationBar backgroundImageForBarMetrics:UIBarMetricsDefault] forBarMetrics:UIBarMetricsDefault];
        [self.navigationController.navigationBar setShadowImage:self.transitionNavigationBar.shadowImage];
        [self removeTransitionNavigationBar];
    }
    // 老的navBar显示出来
    self.prefersNavigationBarBackgroundViewHidden = NO;
    self.lockTransitionNavigationBar = YES;
    [self NavigationBarTransition_viewDidAppear:animated];
}

- (void)NavigationBarTransition_viewDidDisappear:(BOOL)animated {
    self.lockTransitionNavigationBar = NO;
    [self NavigationBarTransition_viewDidDisappear:animated];
    if (self.transitionNavigationBar) {
        // 对于被pop导致当前viewController走到viewDidDisappear:的情况，removeTransitionNavigationBar里是无法正确把navigationBar上的observe移除的，因为此时获取不到self.navigationController，所以removeObserve提前到viewWillDisappear里
        [self removeTransitionNavigationBar];
    }
}

- (void)NavigationBarTransition_viewWillLayoutSubviews {
    
    id<UIViewControllerTransitionCoordinator> transitionCoordinator = self.transitionCoordinator;
    UIViewController *fromViewController = [transitionCoordinator viewControllerForKey:UITransitionContextFromViewControllerKey];
    UIViewController *toViewController = [transitionCoordinator viewControllerForKey:UITransitionContextToViewControllerKey];
    
    BOOL isCurrentToViewController = (self == self.navigationController.viewControllers.lastObject && self == toViewController);
    
    if (isCurrentToViewController && !self.lockTransitionNavigationBar) {
        
        BOOL shouldCustomPushNavigationBarTransition = NO;
        BOOL shouldCustomPopNavigationBarTransition = NO;
        
        if (!self.transitionNavigationBar) {
            if (self.navigationController.qmui_isPushingViewController) {
                if ([toViewController canCustomNavigationBarTransitionWhenPushAppearing]) {
                    shouldCustomPushNavigationBarTransition = YES;
                }
                if (!shouldCustomPushNavigationBarTransition && [fromViewController canCustomNavigationBarTransitionWhenPushDisappearing]) {
                    shouldCustomPushNavigationBarTransition = YES;
                }
                if (shouldCustomPushNavigationBarTransition) {
                    [self addTransitionNavigationBarIfNeeded];
                    toViewController.navigationController.navigationBar.transitionNavigationBar = toViewController.transitionNavigationBar;
                    self.prefersNavigationBarBackgroundViewHidden = YES;
                }
            } else if (self.navigationController.qmui_isPoppingViewController) {
                if ([toViewController canCustomNavigationBarTransitionWhenPopAppearing]) {
                    shouldCustomPopNavigationBarTransition = YES;
                }
                if (!shouldCustomPopNavigationBarTransition && [fromViewController canCustomNavigationBarTransitionWhenPopDisappearing]) {
                    shouldCustomPopNavigationBarTransition = YES;
                }
                if (shouldCustomPopNavigationBarTransition) {
                    [self addTransitionNavigationBarIfNeeded];
                    toViewController.navigationController.navigationBar.transitionNavigationBar = toViewController.transitionNavigationBar;
                    self.prefersNavigationBarBackgroundViewHidden = YES;
                }
            }
        }
        if (shouldCustomPushNavigationBarTransition || shouldCustomPopNavigationBarTransition) {
            // 设置假的 navBar 的frame
            [self resizeTransitionNavigationBarFrame];
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
    if (CGSizeEqualToSize(backgroundImage.size, CGSizeZero)) {
        // 保护一下那种没有图片的 UIImage 例如：[UIImage new]，如果没有保护则会出现系统默认的navBar样式，很奇怪。
        // navController 设置自己的 navBar 为 [UIImage new] 却没事
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

- (BOOL)canCustomNavigationBarTransitionIfBarHiddenable {
    if ([self respondCustomNavigationBarTransitionIfBarHiddenable]) {
        UIViewController<QMUINavigationControllerDelegate> *vc = (UIViewController<QMUINavigationControllerDelegate> *)self;
        return  [vc shouldCustomNavigationBarTransitionIfBarHiddenable];
    }
    return NO;
}

-(BOOL)canCustomNavigationBarTransitionWithBarHiddenState {
    if ([self respondCustomNavigationBarTransitionWithBarHiddenState]) {
        UIViewController<QMUINavigationControllerDelegate> *vc = (UIViewController<QMUINavigationControllerDelegate> *)self;
        return  [vc shouldCustomNavigationBarTransitionWithBarHiddenState];
    }
    return NO;
}

static char lockTransitionNavigationBarKey;

- (BOOL)lockTransitionNavigationBar {
    return [objc_getAssociatedObject(self, &lockTransitionNavigationBarKey) boolValue];
}

- (void)setLockTransitionNavigationBar:(BOOL)lockTransitionNavigationBar {
    objc_setAssociatedObject(self, &lockTransitionNavigationBarKey, [[NSNumber alloc] initWithBool:lockTransitionNavigationBar], OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

static char transitionNavigationBarKey;

- (UINavigationBar *)transitionNavigationBar {
    return objc_getAssociatedObject(self, &transitionNavigationBarKey);
}

- (void)setTransitionNavigationBar:(UINavigationBar *)transitionNavigationBar {
    objc_setAssociatedObject(self, &transitionNavigationBarKey, transitionNavigationBar, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

static char prefersNavigationBarBackgroundViewHiddenKey;

- (BOOL)prefersNavigationBarBackgroundViewHidden {
    return [objc_getAssociatedObject(self, &prefersNavigationBarBackgroundViewHiddenKey) boolValue];
}

- (void)setPrefersNavigationBarBackgroundViewHidden:(BOOL)prefersNavigationBarBackgroundViewHidden {
    [[self.navigationController.navigationBar valueForKey:@"_backgroundView"] setHidden:prefersNavigationBarBackgroundViewHidden];
    objc_setAssociatedObject(self, &prefersNavigationBarBackgroundViewHiddenKey, [[NSNumber alloc] initWithBool:prefersNavigationBarBackgroundViewHidden], OBJC_ASSOCIATION_RETAIN_NONATOMIC);
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
            [self resetOriginNavigationBarWithCustomNavigationBar:appearViewController.transitionNavigationBar];
        }
        disappearViewController.prefersNavigationBarBackgroundViewHidden = YES;
    }
}

- (void)resetOriginNavigationBarWithCustomNavigationBar:(UINavigationBar *)navigationBar {
    ///TODO:for molice 保持和addTransitionBar的修改的样式的数量一致
    self.navigationBar.barTintColor = navigationBar.barTintColor;
    [self.navigationBar setBackgroundImage:[navigationBar backgroundImageForBarMetrics:UIBarMetricsDefault] forBarMetrics:UIBarMetricsDefault];
    [self.navigationBar setShadowImage:navigationBar.shadowImage];
}

@end
