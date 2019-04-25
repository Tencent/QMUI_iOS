/*****
 * Tencent is pleased to support the open source community by making QMUI_iOS available.
 * Copyright (C) 2016-2019 THL A29 Limited, a Tencent company. All rights reserved.
 * Licensed under the MIT License (the "License"); you may not use this file except in compliance with the License. You may obtain a copy of the License at
 * http://opensource.org/licenses/MIT
 * Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.
 *****/

//
//  UINavigationController+NavigationBarTransition.m
//  qmui
//
//  Created by QMUI Team on 16/2/22.
//

#import "UINavigationController+NavigationBarTransition.h"
#import "QMUINavigationController.h"
#import "QMUICore.h"
#import "UINavigationController+QMUI.h"
#import "UIImage+QMUI.h"
#import "UIViewController+QMUI.h"
#import "UINavigationBar+Transition.h"
#import "QMUICommonViewController.h"
#import "QMUINavigationTitleView.h"
#import "UINavigationBar+QMUI.h"
#import "UIView+QMUI.h"
#import "QMUILog.h"

@interface _QMUITransitionNavigationBar : UINavigationBar

@end

@implementation _QMUITransitionNavigationBar

- (void)layoutSubviews {
    [super layoutSubviews];
    if (@available(iOS 11, *)) {
        // iOS 11 以前，自己 init 的 navigationBar，它的 backgroundView 默认会一直保持与 navigationBar 的高度相等，但 iOS 11 Beta 1-5 里，自己 init 的 navigationBar.backgroundView.height 默认一直是 44，所以才加上这个兼容
        self.qmui_backgroundView.frame = self.bounds;
    }
}

@end

/**
 *  为了响应<b>NavigationBarTransition</b>分类的功能，UIViewController需要做一些相应的支持。
 *  @see UINavigationController+NavigationBarTransition.h
 */
@interface UIViewController (NavigationBarTransition)

/// 用来模仿真的navBar的，在转场过程中存在的一条假navBar
@property(nonatomic, strong) _QMUITransitionNavigationBar *transitionNavigationBar;

/// 是否要把真的navBar隐藏
@property(nonatomic, assign) BOOL prefersNavigationBarBackgroundViewHidden;

/// 原始containerView的背景色
@property(nonatomic, strong) UIColor *originContainerViewBackgroundColor;

/// 添加假的navBar
- (void)addTransitionNavigationBarIfNeeded;

/// .m文件里自己赋值和使用。因为有些特殊情况下viewDidAppear之后，有可能还会调用到viewWillLayoutSubviews，导致原始的navBar隐藏，所以用这个属性做个保护。
@property(nonatomic, assign) BOOL lockTransitionNavigationBar;

@end


@implementation UIViewController (NavigationBarTransition)

#pragma mark - 主流程

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        OverrideImplementation([UIViewController class], @selector(viewWillAppear:), ^id(__unsafe_unretained Class originClass, SEL originCMD, IMP (^originalIMPProvider)(void)) {
            return ^(UIViewController *selfObject, BOOL firstArgv) {
                
                // avoid superclass
                if ([selfObject isKindOfClass:originClass]) {
                    // 放在最前面，留一个时机给业务可以覆盖
                    [selfObject renderNavigationStyleInViewController:selfObject animated:firstArgv];
                }
                
                // call super
                void (*originSelectorIMP)(id, SEL, BOOL);
                originSelectorIMP = (void (*)(id, SEL, BOOL))originalIMPProvider();
                originSelectorIMP(selfObject, originCMD, firstArgv);
            };
        });
        
        OverrideImplementation([UIViewController class], @selector(viewDidAppear:), ^id(__unsafe_unretained Class originClass, SEL originCMD, IMP (^originalIMPProvider)(void)) {
            return ^(UIViewController *selfObject, BOOL firstArgv) {
                
                // avoid superclass
                if ([selfObject isKindOfClass:originClass]) {
                    selfObject.lockTransitionNavigationBar = YES;
                    
                    if (selfObject.transitionNavigationBar) {
                        
                        [UIViewController replaceStyleForNavigationBar:selfObject.transitionNavigationBar withNavigationBar:selfObject.navigationController.navigationBar];
                        [selfObject removeTransitionNavigationBar];
                        
                        id <UIViewControllerTransitionCoordinator> transitionCoordinator = selfObject.transitionCoordinator;
                        [transitionCoordinator containerView].backgroundColor = selfObject.originContainerViewBackgroundColor;
                    }
                    
                    if ([selfObject.navigationController.viewControllers containsObject:selfObject]) {
                        // 防止一些 childViewController 走到这里
                        selfObject.prefersNavigationBarBackgroundViewHidden = NO;
                    }
                }
                
                // call super
                void (*originSelectorIMP)(id, SEL, BOOL);
                originSelectorIMP = (void (*)(id, SEL, BOOL))originalIMPProvider();
                originSelectorIMP(selfObject, originCMD, firstArgv);
            };
        });
        
        OverrideImplementation([UIViewController class], @selector(viewDidDisappear:), ^id(__unsafe_unretained Class originClass, SEL originCMD, IMP (^originalIMPProvider)(void)) {
            return ^(UIViewController *selfObject, BOOL firstArgv) {
                
                // avoid superclass
                if ([selfObject isKindOfClass:originClass]) {
                    selfObject.lockTransitionNavigationBar = NO;
                    
                    if (selfObject.transitionNavigationBar) {
                        [selfObject removeTransitionNavigationBar];
                    }
                }
                
                // call super
                void (*originSelectorIMP)(id, SEL, BOOL);
                originSelectorIMP = (void (*)(id, SEL, BOOL))originalIMPProvider();
                originSelectorIMP(selfObject, originCMD, firstArgv);
            };
        });
        
        OverrideImplementation([UIViewController class], @selector(viewWillLayoutSubviews), ^id(__unsafe_unretained Class originClass, SEL originCMD, IMP (^originalIMPProvider)(void)) {
            return ^(UIViewController *selfObject) {
                
                // avoid superclass
                if ([selfObject isKindOfClass:originClass]) {
                    if (![selfObject.navigationController.delegate respondsToSelector:@selector(navigationController:animationControllerForOperation:fromViewController:toViewController:)]) {
                        
                        id<UIViewControllerTransitionCoordinator> transitionCoordinator = selfObject.transitionCoordinator;
                        UIViewController *fromViewController = [transitionCoordinator viewControllerForKey:UITransitionContextFromViewControllerKey];
                        UIViewController *toViewController = [transitionCoordinator viewControllerForKey:UITransitionContextToViewControllerKey];
                        
                        BOOL isCurrentToViewController = (selfObject == selfObject.navigationController.viewControllers.lastObject && selfObject == toViewController);
                        
                        if (isCurrentToViewController && !selfObject.lockTransitionNavigationBar) {
                            
                            BOOL shouldCustomNavigationBarTransition = NO;
                            
                            if (!selfObject.transitionNavigationBar) {
                                
                                if ([selfObject shouldCustomTransitionAutomaticallyWithFirstViewController:fromViewController secondViewController:toViewController]) {
                                    shouldCustomNavigationBarTransition = YES;
                                }
                                
                                if (shouldCustomNavigationBarTransition) {
                                    if (selfObject.navigationController.navigationBar.translucent) {
                                        // 如果原生bar是半透明的，需要给containerView加个背景色，否则有可能会看到下面的默认黑色背景色
                                        toViewController.originContainerViewBackgroundColor = [transitionCoordinator containerView].backgroundColor;
                                        [transitionCoordinator containerView].backgroundColor = [selfObject containerViewBackgroundColor];
                                    }
                                    [selfObject addTransitionNavigationBarIfNeeded];
                                    [selfObject resizeTransitionNavigationBarFrame];
                                    selfObject.navigationController.navigationBar.transitionNavigationBar = selfObject.transitionNavigationBar;
                                    selfObject.prefersNavigationBarBackgroundViewHidden = YES;
                                }
                            }
                        }
                    }
                }
                
                // call super
                void (*originSelectorIMP)(id, SEL);
                originSelectorIMP = (void (*)(id, SEL))originalIMPProvider();
                originSelectorIMP(selfObject, originCMD);
            };
        });
    });
}

- (void)addTransitionNavigationBarIfNeeded {
    
    if (!self.view.qmui_visible || !self.navigationController.navigationBar) {
        return;
    }
    
    UINavigationBar *originBar = self.navigationController.navigationBar;
    _QMUITransitionNavigationBar *customBar = [[_QMUITransitionNavigationBar alloc] init];
    
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
    if (backgroundImage && backgroundImage.size.width <= 0 && backgroundImage.size.height <= 0) {
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
    
    CGRect viewRect = [self.navigationController.view convertRect:self.view.frame fromView:self.view.superview];
    if (viewRect.origin.y != 0 && self.view.clipsToBounds) {
        QMUILog(@"UINavigationController+NavigationBarTransition", @"⚠️⚠️⚠️注意啦：当前界面 controller.view = %@ 布局并没有从屏幕顶部开始，可能会导致自定义导航栏转场的假 bar 看不到", self);
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
    if (!self.view.qmui_visible) {
        return;
    }
    UIView *backgroundView = self.navigationController.navigationBar.qmui_backgroundView;
    CGRect rect = [backgroundView.superview convertRect:backgroundView.frame toView:self.view];
    self.transitionNavigationBar.frame = rect;
}

#pragma mark - 工具方法

// 根据当前的viewController，统一处理导航栏底部的分隔线、状态栏的颜色
- (void)renderNavigationStyleInViewController:(UIViewController *)viewController animated:(BOOL)animated {
    
    // 屏蔽不处于 UINavigationController 里的 viewController，以及 custom containerViewController 里的 childViewController
    if (![viewController.navigationController.viewControllers containsObject:viewController]) {
        return;
    }
    
    // 以下用于控制 vc 的外观样式，如果某个方法有实现则用方法的返回值，否则再看配置表对应的值是否有配置，有配置就使用配置表，没配置则什么都不做，维持系统原生样式
    if ([viewController conformsToProtocol:@protocol(QMUINavigationControllerAppearanceDelegate)]) {
        UIViewController<QMUINavigationControllerAppearanceDelegate> *vc = (UIViewController<QMUINavigationControllerAppearanceDelegate> *)viewController;
        
        // 控制界面的状态栏颜色
        BeginIgnoreDeprecatedWarning
        if ([vc respondsToSelector:@selector(shouldSetStatusBarStyleLight)] && [vc shouldSetStatusBarStyleLight]) {
            if ([[UIApplication sharedApplication] statusBarStyle] < UIStatusBarStyleLightContent) {
                [QMUIHelper renderStatusBarStyleLight];
            }
        } else {
            if ([[UIApplication sharedApplication] statusBarStyle] >= UIStatusBarStyleLightContent) {
                [QMUIHelper renderStatusBarStyleDark];
            }
        }
        EndIgnoreDeprecatedWarning
        
        // 显示/隐藏 导航栏
        if ([vc canCustomNavigationBarTransitionIfBarHiddenable]) {
            if ([vc hideNavigationBarWhenTransitioning]) {
                if (!viewController.navigationController.isNavigationBarHidden) {
                    [viewController.navigationController setNavigationBarHidden:YES animated:animated];
                }
            } else {
                if (viewController.navigationController.isNavigationBarHidden) {
                    [viewController.navigationController setNavigationBarHidden:NO animated:animated];
                }
            }
        }
        
        // 导航栏的背景色
        if ([vc respondsToSelector:@selector(navigationBarBarTintColor)]) {
            UIColor *barTintColor = [vc navigationBarBarTintColor];
            viewController.navigationController.navigationBar.barTintColor = barTintColor;
        } else if (QMUICMIActivated) {
            viewController.navigationController.navigationBar.barTintColor = NavBarBarTintColor;
        }
        
        // 导航栏的背景
        if ([vc respondsToSelector:@selector(navigationBarBackgroundImage)]) {
            UIImage *backgroundImage = [vc navigationBarBackgroundImage];
            [viewController.navigationController.navigationBar setBackgroundImage:backgroundImage forBarMetrics:UIBarMetricsDefault];
        } else if (QMUICMIActivated) {
            [viewController.navigationController.navigationBar setBackgroundImage:NavBarBackgroundImage forBarMetrics:UIBarMetricsDefault];
        }
        
        // 导航栏底部的分隔线
        if ([vc respondsToSelector:@selector(navigationBarShadowImage)]) {
            UIImage *shadowImage = [vc navigationBarShadowImage];
            [viewController.navigationController.navigationBar setShadowImage:shadowImage];
        } else if (QMUICMIActivated) {
            [viewController.navigationController.navigationBar setShadowImage:NavBarShadowImage];
        }
        
        // 导航栏上控件的主题色
        UIColor *tintColor =
        [vc respondsToSelector:@selector(navigationBarTintColor)] ? [vc navigationBarTintColor] :
                                                 QMUICMIActivated ? NavBarTintColor : nil;
        if (tintColor) {
            // 手势从 B 返回 A 过程中，取消手势，会调用 B 的 viewWillAppear，animateAlongsideTransition 在这种情况下不会生效，所以要用 qmui_poppingByInteractivePopGestureRecognizer 针对这种情况判断。
            BOOL shouldApplyTintColorTransition = (animated && ![vc qmui_poppingByInteractivePopGestureRecognizer]);
            if (shouldApplyTintColorTransition) {
                [viewController.transitionCoordinator animateAlongsideTransition:^ (id <UIViewControllerTransitionCoordinatorContext> context) {
                    viewController.navigationController.navigationBar.tintColor = tintColor;
                } completion:nil];
            } else {
                viewController.navigationController.navigationBar.tintColor = tintColor;
            }
        }
        
        // 导航栏title的颜色
        if ([vc respondsToSelector:@selector(titleViewTintColor)]) {
            UIColor *tintColor = [vc titleViewTintColor];
            if ([vc isKindOfClass:[QMUICommonViewController class]]) {
                ((QMUICommonViewController *)vc).titleView.tintColor = tintColor;
            } else {
                // TODO: molice 对 UIViewController 也支持修改 title 颜色
            }
        } else {
            if (QMUICMIActivated && [vc isKindOfClass:[QMUICommonViewController class]]) {
                ((QMUICommonViewController *)vc).titleView.tintColor = NavBarTitleColor;
            } else {
                // TODO: molice 对 UIViewController 也支持修改 title 颜色
            }
        }
    }
}

+ (void)replaceStyleForNavigationBar:(UINavigationBar *)navbarA withNavigationBar:(UINavigationBar *)navbarB {
    navbarB.barStyle = navbarA.barStyle;
    navbarB.barTintColor = navbarA.barTintColor;
    [navbarB setShadowImage:navbarA.shadowImage];
    [navbarB setBackgroundImage:[navbarA backgroundImageForBarMetrics:UIBarMetricsDefault] forBarMetrics:UIBarMetricsDefault];
}

- (BOOL)respondCustomNavigationBarTransitionIfBarHiddenable {
    BOOL respondIfBarHiddenable = NO;
    
    // 如果当前界面正在搜索，由于 UISearchController 会自动把 navigationBar 移上去，所以这种时候 QMUI 就不应该再去操作 bar 的显隐了
    if ([self.presentedViewController isKindOfClass:[UISearchController class]] && ((UISearchController *)self.presentedViewController).hidesNavigationBarDuringPresentation) {
        return NO;
    }
    
    if ([self conformsToProtocol:@protocol(QMUICustomNavigationBarTransitionDelegate)]) {
        UIViewController<QMUICustomNavigationBarTransitionDelegate> *vc = (UIViewController<QMUICustomNavigationBarTransitionDelegate> *)self;
        if ([vc respondsToSelector:@selector(shouldCustomizeNavigationBarTransitionIfHideable)]) {
            respondIfBarHiddenable = YES;
        }
    }
    return respondIfBarHiddenable;
}

- (BOOL)respondCustomNavigationBarTransitionWithBarHiddenState {
    BOOL respondWithBarHidden = NO;
    if ([self conformsToProtocol:@protocol(QMUICustomNavigationBarTransitionDelegate)]) {
        UIViewController<QMUICustomNavigationBarTransitionDelegate> *vc = (UIViewController<QMUICustomNavigationBarTransitionDelegate> *)self;
        if ([vc respondsToSelector:@selector(preferredNavigationBarHidden)]) {
            respondWithBarHidden = YES;
        }
    }
    return respondWithBarHidden;
}

- (BOOL)canCustomNavigationBarTransitionIfBarHiddenable {
    if ([self respondCustomNavigationBarTransitionIfBarHiddenable]) {
        UIViewController<QMUICustomNavigationBarTransitionDelegate> *vc = (UIViewController<QMUICustomNavigationBarTransitionDelegate> *)self;
        return [vc shouldCustomizeNavigationBarTransitionIfHideable];
    }
    return NO;
}

- (BOOL)hideNavigationBarWhenTransitioning {
    if ([self respondCustomNavigationBarTransitionWithBarHiddenState]) {
        UIViewController<QMUICustomNavigationBarTransitionDelegate> *vc = (UIViewController<QMUICustomNavigationBarTransitionDelegate> *)self;
        BOOL hidden = [vc preferredNavigationBarHidden];
        return hidden;
    }
    return NO;
}

- (BOOL)shouldCustomTransitionAutomaticallyWithFirstViewController:(UIViewController *)viewController1 secondViewController:(UIViewController *)viewController2 {
    
    UIViewController<QMUINavigationControllerDelegate> *vc1 = (UIViewController<QMUINavigationControllerDelegate> *)viewController1;
    UIViewController<QMUINavigationControllerDelegate> *vc2 = (UIViewController<QMUINavigationControllerDelegate> *)viewController2;
    
    if (![vc1 conformsToProtocol:@protocol(QMUINavigationControllerDelegate)] || ![vc2 conformsToProtocol:@protocol(QMUINavigationControllerDelegate)]) {
        return NO;// 只处理前后两个界面都是 QMUI 系列的场景
    }
    
    if ([vc1 respondsToSelector:@selector(customNavigationBarTransitionKey)] || [vc2 respondsToSelector:@selector(customNavigationBarTransitionKey)]) {
        NSString *key1 = [vc1 respondsToSelector:@selector(customNavigationBarTransitionKey)] ? [vc1 customNavigationBarTransitionKey] : nil;
        NSString *key2 = [vc2 respondsToSelector:@selector(customNavigationBarTransitionKey)] ? [vc2 customNavigationBarTransitionKey] : nil;
        BOOL result = (key1 || key2) && ![key1 isEqualToString:key2];
        return result;
    }
    
    if (!AutomaticCustomNavigationBarTransitionStyle) {
        return NO;
    }
    
    UIImage *bg1 = [vc1 respondsToSelector:@selector(navigationBarBackgroundImage)] ? [vc1 navigationBarBackgroundImage] : [[UINavigationBar appearance] backgroundImageForBarMetrics:UIBarMetricsDefault];
    UIImage *bg2 = [vc2 respondsToSelector:@selector(navigationBarBackgroundImage)] ? [vc2 navigationBarBackgroundImage] : [[UINavigationBar appearance] backgroundImageForBarMetrics:UIBarMetricsDefault];
    if (bg1 || bg2) {
        if (!bg1 || !bg2) {
            return YES;// 一个有一个没有，则需要自定义
        }
        if (![bg1.qmui_averageColor isEqual:bg2.qmui_averageColor]) {
            return YES;// 目前只能判断图片颜色是否相等了
        }
    }
    
    // 如果存在 backgroundImage，则 barTintColor 就算存在也不会被显示出来，所以这里只判断两个 backgroundImage 都不存在的时候
    if (!bg1 && !bg2) {
        UIColor *barTintColor1 = [vc1 respondsToSelector:@selector(navigationBarBarTintColor)] ? [vc1 navigationBarBarTintColor] : [UINavigationBar appearance].barTintColor;
        UIColor *barTintColor2 = [vc2 respondsToSelector:@selector(navigationBarBarTintColor)] ? [vc2 navigationBarBarTintColor] : [UINavigationBar appearance].barTintColor;
        if (barTintColor1 || barTintColor2) {
            if (!barTintColor1 || !barTintColor2) {
                return YES;
            }
            if (![barTintColor1 isEqual:barTintColor2]) {
                return YES;
            }
        }
    }
    
    UIImage *shadowImage1 = [vc1 respondsToSelector:@selector(navigationBarShadowImage)] ? [vc1 navigationBarShadowImage] : (vc1.navigationController.navigationBar ? vc1.navigationController.navigationBar.shadowImage : (QMUICMIActivated ? NavBarShadowImage : nil));
    UIImage *shadowImage2 = [vc2 respondsToSelector:@selector(navigationBarShadowImage)] ? [vc2 navigationBarShadowImage] : (vc2.navigationController.navigationBar ? vc2.navigationController.navigationBar.shadowImage : (QMUICMIActivated ? NavBarShadowImage : nil));
    if (shadowImage1 || shadowImage2) {
        if (!shadowImage1 || !shadowImage2) {
            return YES;
        }
        if (![shadowImage1.qmui_averageColor isEqual:shadowImage2.qmui_averageColor]) {
            return YES;
        }
    }
    
    return NO;
}

- (UIColor *)containerViewBackgroundColor {
    UIColor *backgroundColor = UIColorWhite;
    if ([self conformsToProtocol:@protocol(QMUICustomNavigationBarTransitionDelegate)]) {
        UIViewController<QMUICustomNavigationBarTransitionDelegate> *vc = (UIViewController<QMUICustomNavigationBarTransitionDelegate> *)self;
        if ([vc respondsToSelector:@selector(containerViewBackgroundColorWhenTransitioning)]) {
            backgroundColor = [vc containerViewBackgroundColorWhenTransitioning];
        }
    }
    return backgroundColor;
}

#pragma mark - Setter / Getter

QMUISynthesizeBOOLProperty(lockTransitionNavigationBar, setLockTransitionNavigationBar)
QMUISynthesizeIdStrongProperty(transitionNavigationBar, setTransitionNavigationBar)
QMUISynthesizeIdStrongProperty(originContainerViewBackgroundColor, setOriginContainerViewBackgroundColor)

static char kAssociatedObjectKey_backgroundViewHidden;
- (void)setPrefersNavigationBarBackgroundViewHidden:(BOOL)prefersNavigationBarBackgroundViewHidden {
    // 从某个版本开始，发现从有 navBar 的界面返回无 navBar 的界面，backgroundView 会跑出来，发现是被系统重新设置了显示，所以改用其他的方法来隐藏 backgroundView，就是 mask。
    if (prefersNavigationBarBackgroundViewHidden) {
        self.navigationController.navigationBar.qmui_backgroundView.layer.mask = [CALayer layer];
    } else {
        self.navigationController.navigationBar.qmui_backgroundView.layer.mask = nil;
    }
    objc_setAssociatedObject(self, &kAssociatedObjectKey_backgroundViewHidden, @(prefersNavigationBarBackgroundViewHidden), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (BOOL)prefersNavigationBarBackgroundViewHidden {
    return [((NSNumber *)objc_getAssociatedObject(self, &kAssociatedObjectKey_backgroundViewHidden)) boolValue];
}

@end


@implementation UINavigationController (NavigationBarTransition)

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        OverrideImplementation([UINavigationController class], @selector(pushViewController:animated:), ^id(__unsafe_unretained Class originClass, SEL originCMD, IMP (^originalIMPProvider)(void)) {
            return ^(UINavigationController *selfObject, UIViewController *viewController, BOOL animated) {
                
                // call super
                void (^callSuperBlock)(UIViewController *, BOOL) = ^void(UIViewController *aViewController, BOOL aAnimated) {
                    void (*originSelectorIMP)(id, SEL, UIViewController *, BOOL);
                    originSelectorIMP = (void (*)(id, SEL, UIViewController *, BOOL))originalIMPProvider();
                    originSelectorIMP(selfObject, originCMD, aViewController, aAnimated);
                };
                
                // avoid superclass
                if ([selfObject isKindOfClass:originClass]) {
                    if ([selfObject.delegate respondsToSelector:@selector(navigationController:animationControllerForOperation:fromViewController:toViewController:)]) {
                        return callSuperBlock(viewController, animated);
                    }
                    
                    UIViewController *disappearingViewController = selfObject.viewControllers.lastObject;
                    if (!disappearingViewController) {
                        return callSuperBlock(viewController, animated);
                    }
                    
                    BOOL shouldCustomNavigationBarTransition = [selfObject shouldCustomTransitionAutomaticallyWithFirstViewController:disappearingViewController secondViewController:viewController];
                    
                    if (shouldCustomNavigationBarTransition) {
                        [disappearingViewController addTransitionNavigationBarIfNeeded];
                        disappearingViewController.prefersNavigationBarBackgroundViewHidden = YES;
                    }
                }
                callSuperBlock(viewController, animated);
            };
        });
        
        OverrideImplementation([UINavigationController class], @selector(setViewControllers:animated:), ^id(__unsafe_unretained Class originClass, SEL originCMD, IMP (^originalIMPProvider)(void)) {
            return ^(UINavigationController *selfObject, NSArray<UIViewController *> *viewControllers, BOOL animated) {
                
                // call super
                void (^callSuperBlock)(NSArray<UIViewController *>*, BOOL) = ^void(NSArray<UIViewController *> *aViewControllers, BOOL aAnimated) {
                    void (*originSelectorIMP)(id, SEL, NSArray<UIViewController *> *, BOOL);
                    originSelectorIMP = (void (*)(id, SEL, NSArray<UIViewController *> *, BOOL))originalIMPProvider();
                    originSelectorIMP(selfObject, originCMD, aViewControllers, aAnimated);
                };
                
                // avoid superclass
                if ([selfObject isKindOfClass:originClass]) {
                    if (viewControllers.count <= 0 || !animated) {
                        return callSuperBlock(viewControllers, animated);
                    }
                    UIViewController *disappearingViewController = selfObject.viewControllers.lastObject;
                    UIViewController *appearingViewController = viewControllers.lastObject;
                    if (!disappearingViewController) {
                        return callSuperBlock(viewControllers, animated);
                    }
                    [selfObject handlePopViewControllerNavigationBarTransitionWithDisappearViewController:disappearingViewController appearViewController:appearingViewController];
                }
                callSuperBlock(viewControllers, animated);
            };
        });
        
        OverrideImplementation([UINavigationController class], @selector(popViewControllerAnimated:), ^id(__unsafe_unretained Class originClass, SEL originCMD, IMP (^originalIMPProvider)(void)) {
            return ^UIViewController *(UINavigationController *selfObject, BOOL animated) {
                
                // avoid superclass
                if ([selfObject isKindOfClass:originClass]) {
                    UIViewController *disappearingViewController = selfObject.viewControllers.lastObject;
                    UIViewController *appearingViewController = selfObject.viewControllers.count >= 2 ? selfObject.viewControllers[selfObject.viewControllers.count - 2] : nil;
                    if (disappearingViewController && appearingViewController) {
                        [selfObject handlePopViewControllerNavigationBarTransitionWithDisappearViewController:disappearingViewController appearViewController:appearingViewController];
                    }
                }
                
                // call super
                UIViewController *(*originSelectorIMP)(id, SEL, BOOL);
                originSelectorIMP = (UIViewController *(*)(id, SEL, BOOL))originalIMPProvider();
                UIViewController *result = originSelectorIMP(selfObject, originCMD, animated);
                return result;
            };
        });
        
        OverrideImplementation([UINavigationController class], @selector(popToViewController:animated:), ^id(__unsafe_unretained Class originClass, SEL originCMD, IMP (^originalIMPProvider)(void)) {
            return ^NSArray<UIViewController *> *(UINavigationController *selfObject, UIViewController *viewController, BOOL animated) {
                
                // call super
                NSArray<UIViewController *> *(^callSuperBlock)(UIViewController *, BOOL) = ^NSArray<UIViewController *>*(UIViewController *aViewController, BOOL aAnimated) {
                    NSArray<UIViewController *> *(*originSelectorIMP)(id, SEL, UIViewController *, BOOL);
                    originSelectorIMP = (NSArray<UIViewController *> * (*)(id, SEL, UIViewController *, BOOL))originalIMPProvider();
                    NSArray<UIViewController *> *result = originSelectorIMP(selfObject, originCMD, aViewController, aAnimated);
                    return result;
                };
                
                // avoid superclass
                if ([selfObject isKindOfClass:originClass]) {
                    UIViewController *disappearingViewController = selfObject.viewControllers.lastObject;
                    UIViewController *appearingViewController = viewController;
                    NSArray<UIViewController *> *poppedViewControllers = callSuperBlock(viewController, animated);
                    if (poppedViewControllers) {
                        [selfObject handlePopViewControllerNavigationBarTransitionWithDisappearViewController:disappearingViewController appearViewController:appearingViewController];
                    }
                    return poppedViewControllers;
                }
                return callSuperBlock(viewController, animated);
            };
        });
        
        ExtendImplementationOfNonVoidMethodWithSingleArgument([UINavigationController class], @selector(popToRootViewControllerAnimated:), BOOL, NSArray<UIViewController *> *, ^NSArray<UIViewController *> *(UINavigationController *selfObject, BOOL animated, NSArray<UIViewController *> *originReturnValue) {
            if (selfObject.viewControllers.count > 1) {
                UIViewController *disappearingViewController = selfObject.viewControllers.lastObject;
                UIViewController *appearingViewController = selfObject.viewControllers.firstObject;
                if (originReturnValue) {
                    [selfObject handlePopViewControllerNavigationBarTransitionWithDisappearViewController:disappearingViewController appearViewController:appearingViewController];
                }
            }
            return originReturnValue;
        });
    });
}

- (void)handlePopViewControllerNavigationBarTransitionWithDisappearViewController:(UIViewController *)disappearViewController appearViewController:(UIViewController *)appearViewController {
    
    if (![self.delegate respondsToSelector:@selector(navigationController:animationControllerForOperation:fromViewController:toViewController:)]) {
        
        BOOL shouldCustomNavigationBarTransition = [self shouldCustomTransitionAutomaticallyWithFirstViewController:disappearViewController secondViewController:appearViewController];
        
        if (shouldCustomNavigationBarTransition) {
            [disappearViewController addTransitionNavigationBarIfNeeded];
            if (appearViewController.transitionNavigationBar) {
                // 假设从A→B→C，其中A设置了bar的样式，B跟随A所以B里没有设置bar样式的代码，C又把样式改为另一种，此时从C返回B时，由于B没有设置bar的样式的代码，所以bar的样式依然会保留C的，这就错了，所以每次都要手动改回来才保险
                [UIViewController replaceStyleForNavigationBar:appearViewController.transitionNavigationBar withNavigationBar:self.navigationBar];
            }
            disappearViewController.prefersNavigationBarBackgroundViewHidden = YES;
        }
        
    }
}

@end

@interface UISearchController (NavigationBarTransition)

@end

@implementation UISearchController (NavigationBarTransition)

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        // 修复 UISearchController push 到导航栏隐藏的界面时，会强制把导航栏重新显示出来的 bug
        // https://github.com/Tencent/QMUI_iOS/issues/479
        SEL selector = NSSelectorFromString([NSString stringWithFormat:@"_%@%@:", @"navigationController", @"WillShowViewController"]);
        NSAssert([[self class] instancesRespondToSelector:selector], @"iOS 版本更新导致 UISearchController 无法响应方法 %@", NSStringFromSelector(selector));
        OverrideImplementation([self class], selector, ^id(__unsafe_unretained Class originClass, SEL originCMD, IMP (^originalIMPProvider)(void)) {
            return ^(UISearchController *selfObject, NSNotification *firstArgv) {
                UIViewController *nextViewController = firstArgv.userInfo[@"UINavigationControllerNextVisibleViewController"];
                if (![selfObject isKindOfClass:originClass] || ![nextViewController canCustomNavigationBarTransitionIfBarHiddenable]) {
                    void (*originSelectorIMP)(id, SEL, NSNotification *);
                    originSelectorIMP = (void (*)(id, SEL, NSNotification *))originalIMPProvider();
                    originSelectorIMP(selfObject, originCMD, firstArgv);
                }
            };
        });
    });
}

@end
