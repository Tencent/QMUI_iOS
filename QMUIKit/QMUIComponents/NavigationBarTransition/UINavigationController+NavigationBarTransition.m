/**
 * Tencent is pleased to support the open source community by making QMUI_iOS available.
 * Copyright (C) 2016-2021 THL A29 Limited, a Tencent company. All rights reserved.
 * Licensed under the MIT License (the "License"); you may not use this file except in compliance with the License. You may obtain a copy of the License at
 * http://opensource.org/licenses/MIT
 * Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.
 */

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
#import "QMUINavigationTitleView.h"
#import "UINavigationBar+QMUI.h"
#import "UIView+QMUI.h"
#import "QMUILog.h"

@interface _QMUITransitionNavigationBar : UINavigationBar

@property(nonatomic, weak) UINavigationBar *originalNavigationBar;
@end

@implementation _QMUITransitionNavigationBar

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        // iOS 14 开启 customNavigationBarTransitionKey 的情况下转场效果错误
        // https://github.com/Tencent/QMUI_iOS/issues/1081
        if (@available(iOS 14.0, *)) {
            OverrideImplementation([_QMUITransitionNavigationBar class], NSSelectorFromString([NSString stringWithFormat:@"_%@_%@", @"accessibility", @"navigationController"]), ^id(__unsafe_unretained Class originClass, SEL originCMD, IMP (^originalIMPProvider)(void)) {
                return ^UINavigationController *(_QMUITransitionNavigationBar *selfObject) {
                    if (selfObject.originalNavigationBar) {
                        BeginIgnorePerformSelectorLeaksWarning
                        return [selfObject.originalNavigationBar performSelector:originCMD];
                        EndIgnorePerformSelectorLeaksWarning
                    }
                    
                    // call super
                    UINavigationController *(*originSelectorIMP)(id, SEL);
                    originSelectorIMP = (UINavigationController *(*)(id, SEL))originalIMPProvider();
                    UINavigationController *result = originSelectorIMP(selfObject, originCMD);
                    return result;
                };
            });
        }
    });
}

- (void)setOriginalNavigationBar:(UINavigationBar *)originBar {
    _originalNavigationBar = originBar;
    
    if (self.barStyle != originBar.barStyle) {
        self.barStyle = originBar.barStyle;
    }
    
    if (self.translucent != originBar.translucent) {
        self.translucent = originBar.translucent;
    }
    
    if (![self.barTintColor isEqual:originBar.barTintColor]) {
        self.barTintColor = originBar.barTintColor;
    }
    
    UIImage *backgroundImage = [originBar backgroundImageForBarMetrics:UIBarMetricsDefault];
    if (backgroundImage && backgroundImage.size.width <= 0 && backgroundImage.size.height <= 0) {
        // 假设这里的图片时通过`[UIImage new]`这种形式创建的，那么会navBar会奇怪地显示为系统默认navBar的样式。不知道为什么 navController 设置自己的 navBar 为 [UIImage new] 却没事，所以这里做个保护。
        backgroundImage = [UIImage qmui_imageWithColor:UIColorClear];
    }
    [self setBackgroundImage:backgroundImage forBarMetrics:UIBarMetricsDefault];
    
    self.shadowImage = originBar.shadowImage;
}

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

@end

@interface UILabel (NavigationBarTransition)
@property(nonatomic, strong) UIColor *qmui_specifiedTextColor;
@end

@implementation UILabel (NavigationBarTransition)

QMUISynthesizeIdStrongProperty(qmui_specifiedTextColor, setQmui_specifiedTextColor)

+ (void)load {
    if (@available(iOS 11, *)) ; else return;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        OverrideImplementation(NSClassFromString(@"UIButtonLabel"), @selector(setAttributedText:), ^id(__unsafe_unretained Class originClass, SEL originCMD, IMP (^originalIMPProvider)(void)) {
            return ^(UILabel *selfObject, NSAttributedString *attributedText) {
                
                if (selfObject.qmui_specifiedTextColor) {
                    NSMutableAttributedString *mutableAttributedText = [attributedText isKindOfClass:NSMutableAttributedString.class] ? attributedText : [attributedText mutableCopy];
                    [mutableAttributedText addAttributes:@{ NSForegroundColorAttributeName : selfObject.qmui_specifiedTextColor} range:NSMakeRange(0, mutableAttributedText.length)];
                    attributedText = mutableAttributedText;
                }
                
                void (*originSelectorIMP)(id, SEL, NSAttributedString *);
                originSelectorIMP = (void (*)(id, SEL, NSAttributedString *))originalIMPProvider();
                originSelectorIMP(selfObject, originCMD, attributedText);
            };
        });
    });
}

@end

@implementation UINavigationBar (NavigationBarTransition)

/// 获取 iOS 11之后的系统自带的返回按钮 Label，如果在转场时，会获取到最上面控制器的。
- (UILabel *)qmui_backButtonLabel {
    if (@available(iOS 11, *)) {
        __block UILabel *backButtonLabel = nil;
        [self.qmui_contentView.subviews enumerateObjectsWithOptions:NSEnumerationReverse usingBlock:^(__kindof UIView * _Nonnull subview, NSUInteger idx, BOOL * _Nonnull stop) {
            if ([subview isKindOfClass:NSClassFromString(@"_UIButtonBarButton")]) {
                UIButton *titleButton = [subview valueForKeyPath:@"visualProvider.titleButton"];
                backButtonLabel = titleButton.titleLabel;
                *stop = YES;
            }
        }];
        return backButtonLabel;
    }
    return nil;
}

@end


@implementation UIViewController (NavigationBarTransition)

#pragma mark - 主流程

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
#pragma mark - UINavigationController qmui_didInitialize
        ExtendImplementationOfVoidMethodWithoutArguments([UINavigationController class], @selector(qmui_didInitialize), ^(UINavigationController *selfObject) {
            [selfObject qmui_addNavigationActionDidChangeBlock:^(QMUINavigationAction action, BOOL animated, __kindof UINavigationController * _Nullable weakNavigationController, __kindof UIViewController * _Nullable appearingViewController, NSArray<__kindof UIViewController *> * _Nullable disappearingViewControllers) {
                
                // 左右两个界面都必须存在
                UIViewController *disappearingViewController = disappearingViewControllers.lastObject;
                if (!appearingViewController || !disappearingViewController) {
                    return;
                }
                
                switch (action) {
                    case QMUINavigationActionWillPush: {
                        BOOL shouldCustomNavigationBarTransition =
                        [weakNavigationController shouldCustomTransitionAutomaticallyForOperation:UINavigationControllerOperationPush firstViewController:disappearingViewController secondViewController:appearingViewController];
                        if (shouldCustomNavigationBarTransition) {
                            [disappearingViewController addTransitionNavigationBarIfNeeded];
                            disappearingViewController.prefersNavigationBarBackgroundViewHidden = YES;
                        }
                    }
                        break;
                    case QMUINavigationActionWillPop:
                    case QMUINavigationActionWillSet: {
                        BOOL shouldCustomNavigationBarTransition = [weakNavigationController shouldCustomTransitionAutomaticallyForOperation:UINavigationControllerOperationPop firstViewController:disappearingViewController secondViewController:appearingViewController];
                        if (shouldCustomNavigationBarTransition) {
                            [disappearingViewController addTransitionNavigationBarIfNeeded];
                            if (appearingViewController.transitionNavigationBar) {
                                // 假设从A→B→C，其中A设置了bar的样式，B跟随A所以B里没有设置bar样式的代码，C又把样式改为另一种，此时从C返回B时，由于B没有设置bar的样式的代码，所以bar的样式依然会保留C的，这就错了，所以每次都要手动改回来才保险
                                [UIViewController replaceStyleForNavigationBar:appearingViewController.transitionNavigationBar withNavigationBar:weakNavigationController.navigationBar];
                            }
                            disappearingViewController.prefersNavigationBarBackgroundViewHidden = YES;
                        }
                    }
                        break;
                        
                    case QMUINavigationActionDidPop: {
                        
                        if (@available(iOS 13.0, *)) {
                        } else {
                            // iOS 12 及以下系统，在不使用自定义 titleView 的情况下，在 viewWillAppear 时通过修改 navigationBar.titleTextAttributes 来设置新界面的导航栏标题样式，push 时是生效的，但 pop 时右边界面的样式会覆盖左边界面的样式，所以 pop 时的 titleTextAttributes 改为在 did pop 时处理
                            // 如果用自定义 titleView 则没这种问题，只是为了代码简单，时机的选择不区分是否自定义 title
                            [appearingViewController renderNavigationTitleStyleAnimated:animated];
                            [weakNavigationController qmui_animateAlongsideTransition:nil completion:^(id<UIViewControllerTransitionCoordinatorContext>  _Nonnull context) {
                                // 这里要重新获取 topViewController，因为触发 pop 有两种：1. 普通完整的 pop；2.手势返回又取消。后者在 completion 里拿到的 topViewController 已经不是 completion 外面那个 appearingViewController 了，只有重新获取的 topViewController 才能代表最终可视的那个界面
                                // https://github.com/Tencent/QMUI_iOS/issues/1210
                                [weakNavigationController.topViewController renderNavigationTitleStyleAnimated:animated];
                            }];
                        }
                    }
                        break;
                        
                    default:
                        break;
                }
            }];
        });
        
        OverrideImplementation([UIViewController class], @selector(viewWillAppear:), ^id(__unsafe_unretained Class originClass, SEL originCMD, IMP (^originalIMPProvider)(void)) {
            return ^(UIViewController *selfObject, BOOL firstArgv) {
                
                // 放在最前面，留一个时机给业务可以覆盖
                [selfObject renderNavigationBarStyleAnimated:firstArgv];
                
                // call super
                void (*originSelectorIMP)(id, SEL, BOOL);
                originSelectorIMP = (void (*)(id, SEL, BOOL))originalIMPProvider();
                originSelectorIMP(selfObject, originCMD, firstArgv);
            };
        });
        
        OverrideImplementation([UIViewController class], @selector(viewDidAppear:), ^id(__unsafe_unretained Class originClass, SEL originCMD, IMP (^originalIMPProvider)(void)) {
            return ^(UIViewController *selfObject, BOOL firstArgv) {
                
                [selfObject clearTransitionNavigationBarAndReplaceStyle:YES];
                
                // call super
                void (*originSelectorIMP)(id, SEL, BOOL);
                originSelectorIMP = (void (*)(id, SEL, BOOL))originalIMPProvider();
                originSelectorIMP(selfObject, originCMD, firstArgv);
            };
        });
        
        OverrideImplementation([UIViewController class], @selector(viewDidDisappear:), ^id(__unsafe_unretained Class originClass, SEL originCMD, IMP (^originalIMPProvider)(void)) {
            return ^(UIViewController *selfObject, BOOL firstArgv) {
                
                [selfObject clearTransitionNavigationBarAndReplaceStyle:NO];
                
                // call super
                void (*originSelectorIMP)(id, SEL, BOOL);
                originSelectorIMP = (void (*)(id, SEL, BOOL))originalIMPProvider();
                originSelectorIMP(selfObject, originCMD, firstArgv);
            };
        });
        
        OverrideImplementation([UIViewController class], @selector(viewWillLayoutSubviews), ^id(__unsafe_unretained Class originClass, SEL originCMD, IMP (^originalIMPProvider)(void)) {
            return ^(UIViewController *selfObject) {
                id<UIViewControllerTransitionCoordinator> transitionCoordinator = selfObject.transitionCoordinator;
                UIViewController *fromViewController = [transitionCoordinator viewControllerForKey:UITransitionContextFromViewControllerKey];
                UIViewController *toViewController = [transitionCoordinator viewControllerForKey:UITransitionContextToViewControllerKey];
                
                BOOL isCurrentToViewController = (selfObject == selfObject.navigationController.viewControllers.lastObject && selfObject == toViewController);
                
                if (isCurrentToViewController && (selfObject.qmui_visibleState < QMUIViewControllerDidAppear || selfObject.qmui_visibleState >= QMUIViewControllerDidDisappear)) {
                    
                    BOOL shouldCustomNavigationBarTransition = NO;
                    UINavigationControllerOperation operation = toViewController.navigationController.qmui_isPushing ? UINavigationControllerOperationPush: UINavigationControllerOperationPop;
                    if ([selfObject shouldCustomTransitionAutomaticallyForOperation:operation firstViewController:fromViewController secondViewController:toViewController]) {
                        shouldCustomNavigationBarTransition = YES;
                    }
                    
                    if (shouldCustomNavigationBarTransition) {
                        if (!selfObject.transitionNavigationBar) {
                            UINavigationControllerOperation operation = toViewController.navigationController.qmui_isPushing ? UINavigationControllerOperationPush: UINavigationControllerOperationPop;
                            if ([selfObject shouldCustomTransitionAutomaticallyForOperation:operation firstViewController:fromViewController secondViewController:toViewController]) {
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
                    } else {
                        [fromViewController clearTransitionNavigationBarAndReplaceStyle:NO];
                        [toViewController clearTransitionNavigationBarAndReplaceStyle:NO];
                    }
                }
                // call super
                void (*originSelectorIMP)(id, SEL);
                originSelectorIMP = (void (*)(id, SEL))originalIMPProvider();
                originSelectorIMP(selfObject, originCMD);
            };
        });
        
        // 修复 UISearchController push 到导航栏隐藏的界面时，会强制把导航栏重新显示出来的 bug
        // https://github.com/Tencent/QMUI_iOS/issues/479
        SEL selector = NSSelectorFromString([NSString stringWithFormat:@"_%@%@:", @"navigationController", @"WillShowViewController"]);
        NSAssert([[UISearchController class] instancesRespondToSelector:selector], @"iOS 版本更新导致 UISearchController 无法响应方法 %@", NSStringFromSelector(selector));
        OverrideImplementation([UISearchController class], selector, ^id(__unsafe_unretained Class originClass, SEL originCMD, IMP (^originalIMPProvider)(void)) {
            return ^(UISearchController *selfObject, NSNotification *firstArgv) {
                UIViewController *nextViewController = firstArgv.userInfo[@"UINavigationControllerNextVisibleViewController"];
                if (![nextViewController canCustomNavigationBarTransitionIfBarHiddenable]) {
                    void (*originSelectorIMP)(id, SEL, NSNotification *);
                    originSelectorIMP = (void (*)(id, SEL, NSNotification *))originalIMPProvider();
                    originSelectorIMP(selfObject, originCMD, firstArgv);
                }
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
    customBar.originalNavigationBar = originBar;
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

- (void)clearTransitionNavigationBarAndReplaceStyle:(BOOL)replaceStyle {
    if (self.transitionNavigationBar) {
        if (replaceStyle) {
            [UIViewController replaceStyleForNavigationBar:self.transitionNavigationBar withNavigationBar:self.navigationController.navigationBar];
        }
        [self removeTransitionNavigationBar];
        
        id <UIViewControllerTransitionCoordinator> transitionCoordinator = self.transitionCoordinator;
        if (self.navigationController.navigationBar.translucent && self.originContainerViewBackgroundColor) {
            [transitionCoordinator containerView].backgroundColor = self.originContainerViewBackgroundColor;
        }
    }
    
    // 屏蔽一些 childViewController 触发的场景，只关心堆栈里的
    if ([self.navigationController.viewControllers containsObject:self]) {
        self.prefersNavigationBarBackgroundViewHidden = NO;
    }
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
- (void)renderNavigationBarStyleAnimated:(BOOL)animated {
    
    // 屏蔽不处于 UINavigationController 里的 viewController，以及 custom containerViewController 里的 childViewController
    if (![self.navigationController.viewControllers containsObject:self]) {
        return;
    }
    
    if (![self conformsToProtocol:@protocol(QMUINavigationControllerAppearanceDelegate)]) {
        return;
    }
    
    // 以下用于控制 vc 的外观样式，如果某个方法有实现则用方法的返回值，否则再看配置表对应的值是否有配置，有配置就使用配置表，没配置则什么都不做，维持系统原生样式
    UIViewController<QMUINavigationControllerAppearanceDelegate> *vc = (UIViewController<QMUINavigationControllerAppearanceDelegate> *)self;
    UINavigationController *navigationController = vc.navigationController;
    
    // 显示/隐藏 导航栏
    if ([vc canCustomNavigationBarTransitionIfBarHiddenable]) {
        if ([vc hideNavigationBarWhenTransitioning]) {
            if (!navigationController.isNavigationBarHidden) {
                [navigationController setNavigationBarHidden:YES animated:animated];
            }
        } else {
            if (navigationController.isNavigationBarHidden) {
                [navigationController setNavigationBarHidden:NO animated:animated];
            }
        }
    }
    
    // 导航栏的背景色
    if ([vc respondsToSelector:@selector(navigationBarBarTintColor)]) {
        UIColor *barTintColor = [vc navigationBarBarTintColor];
        navigationController.navigationBar.barTintColor = barTintColor;
    } else if (QMUICMIActivated) {
        navigationController.navigationBar.barTintColor = UINavigationBar.qmui_appearanceConfigured.barTintColor;
    }
    
    // 导航栏的背景
    if ([vc respondsToSelector:@selector(navigationBarBackgroundImage)]) {
        UIImage *backgroundImage = [vc navigationBarBackgroundImage];
        [navigationController.navigationBar setBackgroundImage:backgroundImage forBarMetrics:UIBarMetricsDefault];
    } else if (QMUICMIActivated) {
        [navigationController.navigationBar setBackgroundImage:[UINavigationBar.qmui_appearanceConfigured backgroundImageForBarMetrics:UIBarMetricsDefault] forBarMetrics:UIBarMetricsDefault];
    }
    
    //  导航栏的 style
    if ([vc respondsToSelector:@selector(navigationBarStyle)]) {
        UIBarStyle barStyle = [vc navigationBarStyle];
        navigationController.navigationBar.barStyle = barStyle;
    } else if (QMUICMIActivated) {
        navigationController.navigationBar.barStyle = UINavigationBar.qmui_appearanceConfigured.barStyle;
    }
    
    // 导航栏底部的分隔线
    if ([vc respondsToSelector:@selector(navigationBarShadowImage)]) {
        navigationController.navigationBar.shadowImage = [vc navigationBarShadowImage];
    } else if (QMUICMIActivated) {
        navigationController.navigationBar.shadowImage = NavBarShadowImage;
    }
    
    // 导航栏上控件的主题色
    UIColor *tintColor =
    [vc respondsToSelector:@selector(navigationBarTintColor)] ? [vc navigationBarTintColor] :
                                             QMUICMIActivated ? NavBarTintColor : nil;
    if (tintColor) {
        if (@available(iOS 11, *)) {
            // https://github.com/Tencent/QMUI_iOS/issues/654
            // 改变 navigationBar.tintColor 后会同步改变返回按钮的文字颜色，在 iOS 10及以下，把修改 tintColor 的代码包裹在 animateAlongsideTransition 中能实现转场过渡，而从 iOS 11 开始不生效，现象是：修改了 navigationBar.tintColor 后，返回按钮的文字颜色瞬间变化。
            // 为了实现转场过渡，不要让返回按钮的文字瞬间变化，在转场前锁定 topViewController 所属的 backButtonLabel 颜色，这样在转场过程中改变了 navBar 的 tintColor 不会影响到他。
            if (navigationController.qmui_isPopping) {
                UILabel *backButtonLabel = navigationController.navigationBar.qmui_backButtonLabel;
                if (backButtonLabel) {
                    backButtonLabel.qmui_specifiedTextColor = backButtonLabel.textColor;
                    [vc qmui_animateAlongsideTransition:nil completion:^(id<UIViewControllerTransitionCoordinatorContext>  _Nonnull context) {
                        backButtonLabel.qmui_specifiedTextColor = nil;
                    }];
                }
            }
        }
       
        [vc qmui_animateAlongsideTransition:^(id<UIViewControllerTransitionCoordinatorContext>  _Nonnull context) {
            navigationController.navigationBar.tintColor = tintColor;
        } completion:nil];
    }
    
    // iOS 13 及以上，title 的更新只在 viewWillAppear 这里进行就可以了，但 iOS 12 及以下还要靠 popViewController 那边
    // iOS 12 及以下系统，在不使用自定义 titleView 的情况下，在 viewWillAppear 时通过修改 navigationBar.titleTextAttributes 来设置新界面的导航栏标题样式，push 时是生效的，但 pop 时右边界面的样式会覆盖左边界面的样式，所以 pop 时的 titleTextAttributes 改为在 did pop 时处理
    // 如果用自定义 titleView 则没这种问题，只是为了代码简单，时机的选择不区分是否自定义 title
    BOOL shouldRenderTitle = YES;
    if (@available(iOS 13.0, *)) {
    } else {
        // push/pop 时如果 animated 为 NO，那么走到这里时 push/pop 已经结束了，action 处于 unknown 状态，所以这里要把 unknown 也包含进去
        // https://github.com/Tencent/QMUI_iOS/issues/1190
        shouldRenderTitle = navigationController.qmui_navigationAction >= QMUINavigationActionUnknow && navigationController.qmui_navigationAction <= QMUINavigationActionPushCompleted;
    }
    if (shouldRenderTitle) {
        [vc renderNavigationTitleStyleAnimated:animated];
    }
}

- (void)renderNavigationTitleStyleAnimated:(BOOL)animated {
    
    // 屏蔽不处于 UINavigationController 里的 viewController，以及 custom containerViewController 里的 childViewController
    if (![self.navigationController.viewControllers containsObject:self]) {
        return;
    }
    
    if (![self conformsToProtocol:@protocol(QMUINavigationControllerAppearanceDelegate)]) {
        return;
    }
    
    // 以下用于控制 vc 的外观样式，如果某个方法有实现则用方法的返回值，否则再看配置表对应的值是否有配置，有配置就使用配置表，没配置则什么都不做，维持系统原生样式
    UIViewController<QMUINavigationControllerAppearanceDelegate> *vc = (UIViewController<QMUINavigationControllerAppearanceDelegate> *)self;
    UINavigationController *navigationController = vc.navigationController;
    
    // 导航栏title的颜色
    if ([vc respondsToSelector:@selector(titleViewTintColor)]) {
        UIColor *tintColor = [vc titleViewTintColor];
        if ([vc.navigationItem.titleView isKindOfClass:QMUINavigationTitleView.class]) {
            ((QMUINavigationTitleView *)vc.navigationItem.titleView).tintColor = tintColor;
        } else if (!vc.navigationItem.titleView) {
            NSMutableDictionary<NSAttributedStringKey, id> *titleTextAttributes = (navigationController.navigationBar.titleTextAttributes ?: @{}).mutableCopy;
            titleTextAttributes[NSForegroundColorAttributeName] = tintColor;
            navigationController.navigationBar.titleTextAttributes = titleTextAttributes.copy;
        } else {
            // 设置了自定义的 navigationItem.titleView，则不处理
        }
    } else if (QMUICMIActivated) {
        UIColor *tintColor = NavBarTitleColor;
        if ([vc.navigationItem.titleView isKindOfClass:QMUINavigationTitleView.class]) {
            ((QMUINavigationTitleView *)vc.navigationItem.titleView).tintColor = tintColor;
        } else if (!vc.navigationItem.titleView) {
            NSMutableDictionary<NSAttributedStringKey, id> *titleTextAttributes = (navigationController.navigationBar.titleTextAttributes ?: @{}).mutableCopy;
            titleTextAttributes[NSForegroundColorAttributeName] = tintColor;
            navigationController.navigationBar.titleTextAttributes = titleTextAttributes.copy;
        } else {
            // 设置了自定义的 navigationItem.titleView，则不处理
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

- (BOOL)shouldCustomTransitionAutomaticallyForOperation:(UINavigationControllerOperation)operation firstViewController:(UIViewController *)viewController1 secondViewController:(UIViewController *)viewController2 {
    
    UIViewController<QMUINavigationControllerDelegate> *vc1 = (UIViewController<QMUINavigationControllerDelegate> *)viewController1;
    UIViewController<QMUINavigationControllerDelegate> *vc2 = (UIViewController<QMUINavigationControllerDelegate> *)viewController2;
    
    if (![vc1 conformsToProtocol:@protocol(QMUINavigationControllerDelegate)] || ![vc2 conformsToProtocol:@protocol(QMUINavigationControllerDelegate)]) {
        return NO;// 只处理前后两个界面都是 QMUI 系列的场景
    }
    
    BOOL vc1Clips = vc1.isViewLoaded && vc1.view.clipsToBounds && vc1.qmui_navigationBarMaxYInViewCoordinator < NavigationContentTopConstant;
    BOOL vc2Clips = vc2.isViewLoaded && vc2.view.clipsToBounds && vc2.qmui_navigationBarMaxYInViewCoordinator < NavigationContentTopConstant;
    if (vc1Clips || vc2Clips) {
        QMUILogWarn(@"UINavigationController (NavigationBarTransition)", @"因界面布局原因导致无法优化导航栏动画，vc1 = %@，maxY1 = %.0f, vc2 = %@，maxY2 = %.0f", vc1, vc1.qmui_navigationBarMaxYInViewCoordinator, vc2, vc2.qmui_navigationBarMaxYInViewCoordinator);
        return NO;// 左右两个界面只要其中某个界面无法完整显示 navigationBar，都不进行动画优化
    }
    
    if ([vc1.navigationController.delegate respondsToSelector:@selector(navigationController:animationControllerForOperation:fromViewController:toViewController:)]) {
        // 说明可能有自定义的系统转场动画
        BOOL a = [vc1 respondsToSelector:@selector(shouldCustomizeNavigationBarTransitionIfUsingCustomTransitionForOperation:fromViewController:toViewController:)] ? [vc1 shouldCustomizeNavigationBarTransitionIfUsingCustomTransitionForOperation:operation fromViewController:vc1 toViewController:vc2] : NO;
        BOOL b = [vc2 respondsToSelector:@selector(shouldCustomizeNavigationBarTransitionIfUsingCustomTransitionForOperation:fromViewController:toViewController:)] ? [vc2 shouldCustomizeNavigationBarTransitionIfUsingCustomTransitionForOperation:operation fromViewController:vc1 toViewController:vc2] : NO;
        if (!a && !b) {
            return NO;
        }
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
    

    
    UIImage *bg1 = [vc1 respondsToSelector:@selector(navigationBarBackgroundImage)] ? [vc1 navigationBarBackgroundImage] : [UINavigationBar.qmui_appearanceConfigured backgroundImageForBarMetrics:UIBarMetricsDefault];
    UIImage *bg2 = [vc2 respondsToSelector:@selector(navigationBarBackgroundImage)] ? [vc2 navigationBarBackgroundImage] : [UINavigationBar.qmui_appearanceConfigured backgroundImageForBarMetrics:UIBarMetricsDefault];
    if (bg1 || bg2) {
        if (!bg1 || !bg2) {
            return YES;// 一个有一个没有，则需要自定义
        }
        if (![bg1.qmui_averageColor isEqual:bg2.qmui_averageColor]) {
            return YES;// 目前只能判断图片颜色是否相等了
        }
    }
    
    // 如果存在 backgroundImage，则 barTintColor、barStyle 就算存在也不会被显示出来，所以这里只判断两个 backgroundImage 都不存在的时候
    if (!bg1 && !bg2) {
        UIColor *barTintColor1 = [vc1 respondsToSelector:@selector(navigationBarBarTintColor)] ? [vc1 navigationBarBarTintColor] : UINavigationBar.qmui_appearanceConfigured.barTintColor;
        UIColor *barTintColor2 = [vc2 respondsToSelector:@selector(navigationBarBarTintColor)] ? [vc2 navigationBarBarTintColor] : UINavigationBar.qmui_appearanceConfigured.barTintColor;
        if (barTintColor1 || barTintColor2) {
            if (!barTintColor1 || !barTintColor2) {
                return YES;
            }
            if (![barTintColor1 isEqual:barTintColor2]) {
                return YES;
            }
        }
        
        UIBarStyle barStyle1 = [vc1 respondsToSelector:@selector(navigationBarStyle)] ? [vc1 navigationBarStyle] : UINavigationBar.qmui_appearanceConfigured.barStyle;
        UIBarStyle barStyle2 = [vc2 respondsToSelector:@selector(navigationBarStyle)] ? [vc2 navigationBarStyle] : UINavigationBar.qmui_appearanceConfigured.barStyle;
        if (barStyle1 != barStyle2) {
            return YES;
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
    if ([self conformsToProtocol:@protocol(QMUICustomNavigationBarTransitionDelegate)]) {
        UIViewController<QMUICustomNavigationBarTransitionDelegate> *vc = (UIViewController<QMUICustomNavigationBarTransitionDelegate> *)self;
        if ([vc respondsToSelector:@selector(containerViewBackgroundColorWhenTransitioning)]) {
            return [vc containerViewBackgroundColorWhenTransitioning];
        }
    }
    return self.isViewLoaded && self.view.backgroundColor ? self.view.backgroundColor : UIColorWhite;
}

#pragma mark - Setter / Getter

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
