/**
 * Tencent is pleased to support the open source community by making QMUI_iOS available.
 * Copyright (C) 2016-2021 THL A29 Limited, a Tencent company. All rights reserved.
 * Licensed under the MIT License (the "License"); you may not use this file except in compliance with the License. You may obtain a copy of the License at
 * http://opensource.org/licenses/MIT
 * Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.
 */

//
//  UINavigationController+QMUI.m
//  qmui
//
//  Created by QMUI Team on 16/1/12.
//

#import "UINavigationController+QMUI.h"
#import "QMUICore.h"
#import "QMUILog.h"
#import "UIViewController+QMUI.h"

@interface _QMUINavigationInteractiveGestureDelegator : NSObject <UIGestureRecognizerDelegate>

@property(nonatomic, weak, readonly) UINavigationController *parentViewController;
- (instancetype)initWithParentViewController:(UINavigationController *)parentViewController;
@end

@interface UINavigationController ()

@property(nonatomic, strong) NSMutableArray<QMUINavigationActionDidChangeBlock> *qmuinc_navigationActionDidChangeBlocks;
@property(nullable, nonatomic, readwrite) UIViewController *qmui_endedTransitionTopViewController;
@property(nullable, nonatomic, weak, readonly) id<UIGestureRecognizerDelegate> qmui_interactivePopGestureRecognizerDelegate;
@property(nullable, nonatomic, strong) _QMUINavigationInteractiveGestureDelegator *qmui_interactiveGestureDelegator;
@end

@implementation UINavigationController (QMUI)

QMUISynthesizeIdStrongProperty(qmuinc_navigationActionDidChangeBlocks, setQmuinc_navigationActionDidChangeBlocks)
QMUISynthesizeIdWeakProperty(qmui_endedTransitionTopViewController, setQmui_endedTransitionTopViewController)
QMUISynthesizeIdWeakProperty(qmui_interactivePopGestureRecognizerDelegate, setQmui_interactivePopGestureRecognizerDelegate)
QMUISynthesizeIdStrongProperty(qmui_interactiveGestureDelegator, setQmui_interactiveGestureDelegator)

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        OverrideImplementation([UINavigationController class], @selector(initWithNibName:bundle:), ^id(__unsafe_unretained Class originClass, SEL originCMD, IMP (^originalIMPProvider)(void)) {
            return ^UINavigationController *(UINavigationController *selfObject, NSString *firstArgv, NSBundle *secondArgv) {
                
                // call super
                UINavigationController *(*originSelectorIMP)(id, SEL, NSString *, NSBundle *);
                originSelectorIMP = (UINavigationController *(*)(id, SEL, NSString *, NSBundle *))originalIMPProvider();
                UINavigationController *result = originSelectorIMP(selfObject, originCMD, firstArgv, secondArgv);
                
                [selfObject qmui_didInitialize];
                
                return result;
            };
        });
        
        OverrideImplementation([UINavigationController class], @selector(initWithCoder:), ^id(__unsafe_unretained Class originClass, SEL originCMD, IMP (^originalIMPProvider)(void)) {
            return ^UINavigationController *(UINavigationController *selfObject, NSCoder *firstArgv) {
                
                // call super
                UINavigationController *(*originSelectorIMP)(id, SEL, NSCoder *);
                originSelectorIMP = (UINavigationController *(*)(id, SEL, NSCoder *))originalIMPProvider();
                UINavigationController *result = originSelectorIMP(selfObject, originCMD, firstArgv);
                
                [selfObject qmui_didInitialize];
                
                return result;
            };
        });
        
        // iOS 12 及以前，initWithNavigationBarClass:toolbarClass:、initWithRootViewController: 会调用 initWithNibName:bundle:，所以这两个方法在 iOS 12 下不需要再次调用 qmui_didInitialize 了。
        if (@available(iOS 13.0, *)) {
            OverrideImplementation([UINavigationController class], @selector(initWithNavigationBarClass:toolbarClass:), ^id(__unsafe_unretained Class originClass, SEL originCMD, IMP (^originalIMPProvider)(void)) {
                return ^UINavigationController *(UINavigationController *selfObject, Class firstArgv, Class secondArgv) {
                    
                    // call super
                    UINavigationController *(*originSelectorIMP)(id, SEL, Class, Class);
                    originSelectorIMP = (UINavigationController *(*)(id, SEL, Class, Class))originalIMPProvider();
                    UINavigationController *result = originSelectorIMP(selfObject, originCMD, firstArgv, secondArgv);
                    
                    [selfObject qmui_didInitialize];
                    
                    return result;
                };
            });
            
            OverrideImplementation([UINavigationController class], @selector(initWithRootViewController:), ^id(__unsafe_unretained Class originClass, SEL originCMD, IMP (^originalIMPProvider)(void)) {
                return ^UINavigationController *(UINavigationController *selfObject, UIViewController *firstArgv) {
                    
                    // call super
                    UINavigationController *(*originSelectorIMP)(id, SEL, UIViewController *);
                    originSelectorIMP = (UINavigationController *(*)(id, SEL, UIViewController *))originalIMPProvider();
                    UINavigationController *result = originSelectorIMP(selfObject, originCMD, firstArgv);
                    
                    [selfObject qmui_didInitialize];
                    
                    return result;
                };
            });
        }
        
        
        ExtendImplementationOfVoidMethodWithoutArguments([UINavigationController class], @selector(viewDidLoad), ^(UINavigationController *selfObject) {
            selfObject.qmui_interactivePopGestureRecognizerDelegate = selfObject.interactivePopGestureRecognizer.delegate;
            selfObject.qmui_interactiveGestureDelegator = [[_QMUINavigationInteractiveGestureDelegator alloc] initWithParentViewController:selfObject];
            selfObject.interactivePopGestureRecognizer.delegate = selfObject.qmui_interactiveGestureDelegator;
            
            // 根据 NavBarContainerClasses 的值来决定是否应用 bar.tintColor
            // tintColor 没有被添加 UI_APPEARANCE_SELECTOR，所以没有采用 UIAppearance 的方式去实现（虽然它实际上是支持的）
            if (QMUICMIActivated) {
                BOOL shouldSetTintColor = NO;
                if (NavBarContainerClasses.count) {
                    for (Class class in NavBarContainerClasses) {
                        if ([selfObject isKindOfClass:class]) {
                            shouldSetTintColor = YES;
                            break;
                        }
                    }
                } else {
                    shouldSetTintColor = YES;
                }
                if (shouldSetTintColor) {
                    selfObject.navigationBar.tintColor = NavBarTintColor;
                }
            }
            if (QMUICMIActivated) {
                BOOL shouldSetTintColor = NO;
                if (ToolBarContainerClasses.count) {
                    for (Class class in ToolBarContainerClasses) {
                        if ([selfObject isKindOfClass:class]) {
                            shouldSetTintColor = YES;
                            break;
                        }
                    }
                } else {
                    shouldSetTintColor = YES;
                }
                if (shouldSetTintColor) {
                    selfObject.toolbar.tintColor = ToolBarTintColor;
                }
            }
        });
        
        OverrideImplementation(NSClassFromString([NSString qmui_stringByConcat:@"_", @"UINavigationBar", @"ContentView", nil]), NSSelectorFromString(@"__backButtonAction:"), ^id(__unsafe_unretained Class originClass, SEL originCMD, IMP (^originalIMPProvider)(void)) {
            return ^(UIView *selfObject, id firstArgv) {
                
                if ([selfObject.superview isKindOfClass:UINavigationBar.class]) {
                    UINavigationBar *bar = (UINavigationBar *)selfObject.superview;
                    if ([bar.delegate isKindOfClass:UINavigationController.class]) {
                        UINavigationController *navController = (UINavigationController *)bar.delegate;
                        BOOL canPopViewController = [navController canPopViewController:navController.topViewController byPopGesture:NO];
                        if (!canPopViewController) return;
                    }
                }
                
                // call super
                void (*originSelectorIMP)(id, SEL, id);
                originSelectorIMP = (void (*)(id, SEL, id))originalIMPProvider();
                originSelectorIMP(selfObject, originCMD, firstArgv);
            };
        });
        
        OverrideImplementation([UINavigationController class], NSSelectorFromString(@"navigationTransitionView:didEndTransition:fromView:toView:"), ^id(__unsafe_unretained Class originClass, SEL originCMD, IMP (^originalIMPProvider)(void)) {
            return ^void(UINavigationController *selfObject, UIView *transitionView, NSInteger transition, UIView *fromView, UIView *toView) {
                
                BOOL (*originSelectorIMP)(id, SEL, UIView *, NSInteger , UIView *, UIView *);
                originSelectorIMP = (BOOL (*)(id, SEL, UIView *, NSInteger , UIView *, UIView *))originalIMPProvider();
                originSelectorIMP(selfObject, originCMD, transitionView, transition, fromView, toView);
                selfObject.qmui_endedTransitionTopViewController = selfObject.topViewController;
            };
        });
        
#pragma mark - pushViewController:animated:
        OverrideImplementation([UINavigationController class], @selector(pushViewController:animated:), ^id(__unsafe_unretained Class originClass, SEL originCMD, IMP (^originalIMPProvider)(void)) {
            return ^(UINavigationController *selfObject, UIViewController *viewController, BOOL animated) {
                
                if (selfObject.presentedViewController) {
                    QMUILogWarn(NSStringFromClass(originClass), @"push 的时候 UINavigationController 存在一个盖在上面的 presentedViewController，可能导致一些 UINavigationControllerDelegate 不会被调用");
                }
                
                if ([selfObject.viewControllers containsObject:viewController]) {
                    QMUIAssert(NO, @"UINavigationController (QMUI)", @"不允许重复 push 相同的 viewController 实例，会产生 crash。当前 viewController：%@", viewController);
                    return;
                }
                
                // call super
                void (^callSuperBlock)(void) = ^void(void) {
                    void (*originSelectorIMP)(id, SEL, UIViewController *, BOOL);
                    originSelectorIMP = (void (*)(id, SEL, UIViewController *, BOOL))originalIMPProvider();
                    originSelectorIMP(selfObject, originCMD, viewController, animated);
                };
                
                BOOL willPushActually = viewController && ![viewController isKindOfClass:UITabBarController.class] && ![selfObject.viewControllers containsObject:viewController];
                
                if (!willPushActually) {
                    callSuperBlock();
                    return;
                }
                
                UIViewController *appearingViewController = viewController;
                NSArray<UIViewController *> *disappearingViewControllers = selfObject.topViewController ? @[selfObject.topViewController] : nil;
                
                [selfObject setQmui_navigationAction:QMUINavigationActionWillPush animated:animated appearingViewController:appearingViewController disappearingViewControllers:disappearingViewControllers];
                
                callSuperBlock();
                
                [selfObject setQmui_navigationAction:QMUINavigationActionDidPush animated:animated appearingViewController:appearingViewController disappearingViewControllers:disappearingViewControllers];
                
                [selfObject qmui_animateAlongsideTransition:nil completion:^(id<UIViewControllerTransitionCoordinatorContext>  _Nonnull context) {
                    [selfObject setQmui_navigationAction:QMUINavigationActionPushCompleted animated:animated appearingViewController:appearingViewController disappearingViewControllers:disappearingViewControllers];
                    [selfObject setQmui_navigationAction:QMUINavigationActionUnknow animated:animated appearingViewController:nil disappearingViewControllers:nil];
                }];
            };
        });
        
#pragma mark - popViewControllerAnimated:
        OverrideImplementation([UINavigationController class], @selector(popViewControllerAnimated:), ^id(__unsafe_unretained Class originClass, SEL originCMD, IMP (^originalIMPProvider)(void)) {
            return ^UIViewController *(UINavigationController *selfObject, BOOL animated) {
                
                // call super
                UIViewController *(^callSuperBlock)(void) = ^UIViewController *(void) {
                    UIViewController *(*originSelectorIMP)(id, SEL, BOOL);
                    originSelectorIMP = (UIViewController *(*)(id, SEL, BOOL))originalIMPProvider();
                    UIViewController *result = originSelectorIMP(selfObject, originCMD, animated);
                    return result;
                };
                
                QMUINavigationAction action = selfObject.qmui_navigationAction;
                if (action != QMUINavigationActionUnknow) {
                    QMUILogWarn(@"UINavigationController (QMUI)", @"popViewController 时上一次的转场尚未完成，系统会忽略本次 pop，等上一次转场完成后再重新执行 pop, viewControllers = %@", selfObject.viewControllers);
                }
                BOOL willPopActually = selfObject.viewControllers.count > 1 && action == QMUINavigationActionUnknow;// 系统文档里说 rootViewController 是不能被 pop 的，当只剩下 rootViewController 时当前方法什么事都不会做
                
                if (!willPopActually) {
                    return callSuperBlock();
                }
                
                UIViewController *appearingViewController = selfObject.viewControllers[selfObject.viewControllers.count - 2];
                NSArray<UIViewController *> *disappearingViewControllers = selfObject.viewControllers.lastObject ? @[selfObject.viewControllers.lastObject] : nil;
                
                [selfObject setQmui_navigationAction:QMUINavigationActionWillPop animated:animated appearingViewController:appearingViewController disappearingViewControllers:disappearingViewControllers];
                
                UIViewController *result = callSuperBlock();
                
                // UINavigationController 不可见时 return 值可能为 nil
                // https://github.com/Tencent/QMUI_iOS/issues/1180
                QMUIAssert(result && disappearingViewControllers && disappearingViewControllers.firstObject == result, @"UINavigationController (QMUI)", @"QMUI 认为 popViewController 会成功，但实际上失败了，result = %@, disappearingViewControllers = %@", result, disappearingViewControllers);
                disappearingViewControllers = result ? @[result] : disappearingViewControllers;
                
                [selfObject setQmui_navigationAction:QMUINavigationActionDidPop animated:animated appearingViewController:appearingViewController disappearingViewControllers:disappearingViewControllers];
                
                void (^transitionCompletion)(void) = ^void(void) {
                    [selfObject setQmui_navigationAction:QMUINavigationActionPopCompleted animated:animated appearingViewController:appearingViewController disappearingViewControllers:disappearingViewControllers];
                    [selfObject setQmui_navigationAction:QMUINavigationActionUnknow animated:animated appearingViewController:nil disappearingViewControllers:nil];
                };
                if (!result) {
                    // 如果系统的 pop 没有成功，实际上提交给 animateAlongsideTransition:completion: 的 completion 并不会被执行，所以这里改为手动调用
                    if (transitionCompletion) {
                        transitionCompletion();
                    }
                } else {
                    [selfObject qmui_animateAlongsideTransition:nil completion:^(id<UIViewControllerTransitionCoordinatorContext>  _Nonnull context) {
                        if (transitionCompletion) {
                            transitionCompletion();
                        }
                    }];
                }
                
                return result;
            };
        });
        
#pragma mark - popToViewController:animated:
        OverrideImplementation([UINavigationController class], @selector(popToViewController:animated:), ^id(__unsafe_unretained Class originClass, SEL originCMD, IMP (^originalIMPProvider)(void)) {
            return ^NSArray<UIViewController *> *(UINavigationController *selfObject, UIViewController *viewController, BOOL animated) {
                
                // call super
                NSArray<UIViewController *> *(^callSuperBlock)(void) = ^NSArray<UIViewController *> *(void) {
                    NSArray<UIViewController *> *(*originSelectorIMP)(id, SEL, UIViewController *, BOOL);
                    originSelectorIMP = (NSArray<UIViewController *> * (*)(id, SEL, UIViewController *, BOOL))originalIMPProvider();
                    NSArray<UIViewController *> *poppedViewControllers = originSelectorIMP(selfObject, originCMD, viewController, animated);
                    return poppedViewControllers;
                };
                
                QMUINavigationAction action = selfObject.qmui_navigationAction;
                if (action != QMUINavigationActionUnknow) {
                    QMUILogWarn(@"UINavigationController (QMUI)", @"popToViewController 时上一次的转场尚未完成，系统会忽略本次 pop，等上一次转场完成后再重新执行 pop, currentViewControllers = %@, viewController = %@", selfObject.viewControllers, viewController);
                }
                BOOL willPopActually = selfObject.viewControllers.count > 1 && [selfObject.viewControllers containsObject:viewController] && selfObject.topViewController != viewController && action == QMUINavigationActionUnknow;// 系统文档里说 rootViewController 是不能被 pop 的，当只剩下 rootViewController 时当前方法什么事都不会做
                
                if (!willPopActually) {
                    return callSuperBlock();
                }
                
                UIViewController *appearingViewController = viewController;
                NSArray<UIViewController *> *disappearingViewControllers = nil;
                NSUInteger index = [selfObject.viewControllers indexOfObject:appearingViewController];
                if (index != NSNotFound) {
                    disappearingViewControllers = [selfObject.viewControllers subarrayWithRange:NSMakeRange(index + 1, selfObject.viewControllers.count - index - 1)];
                }

                [selfObject setQmui_navigationAction:QMUINavigationActionWillPop animated:animated appearingViewController:appearingViewController disappearingViewControllers:disappearingViewControllers];
                
                NSArray<UIViewController *> *result = callSuperBlock();
                
                QMUIAssert(!(selfObject.isViewLoaded && selfObject.view.window) || [result isEqualToArray:disappearingViewControllers], @"UINavigationController (QMUI)", @"QMUI 计算得到的 popToViewController 结果和系统的不一致");
                disappearingViewControllers = result ?: disappearingViewControllers;
                
                [selfObject setQmui_navigationAction:QMUINavigationActionDidPop animated:animated appearingViewController:appearingViewController disappearingViewControllers:disappearingViewControllers];
                
                [selfObject qmui_animateAlongsideTransition:nil completion:^(id<UIViewControllerTransitionCoordinatorContext>  _Nonnull context) {
                    [selfObject setQmui_navigationAction:QMUINavigationActionPopCompleted animated:animated appearingViewController:appearingViewController disappearingViewControllers:disappearingViewControllers];
                    [selfObject setQmui_navigationAction:QMUINavigationActionUnknow animated:animated appearingViewController:nil disappearingViewControllers:nil];
                }];
                
                return result;
            };
        });

#pragma mark - popToRootViewControllerAnimated:
        OverrideImplementation([UINavigationController class], @selector(popToRootViewControllerAnimated:), ^id(__unsafe_unretained Class originClass, SEL originCMD, IMP (^originalIMPProvider)(void)) {
            return ^NSArray<UIViewController *> *(UINavigationController *selfObject, BOOL animated) {
                
                // call super
                NSArray<UIViewController *> *(^callSuperBlock)(void) = ^NSArray<UIViewController *> *(void) {
                    NSArray<UIViewController *> *(*originSelectorIMP)(id, SEL, BOOL);
                    originSelectorIMP = (NSArray<UIViewController *> * (*)(id, SEL, BOOL))originalIMPProvider();
                    NSArray<UIViewController *> *result = originSelectorIMP(selfObject, originCMD, animated);
                    return result;
                };
                
                QMUINavigationAction action = selfObject.qmui_navigationAction;
                if (action != QMUINavigationActionUnknow) {
                    QMUILogWarn(@"UINavigationController (QMUI)", @"popToRootViewController 时上一次的转场尚未完成，系统会忽略本次 pop，等上一次转场完成后再重新执行 pop, viewControllers = %@", selfObject.viewControllers);
                }
                BOOL willPopActually = selfObject.viewControllers.count > 1 && action == QMUINavigationActionUnknow;
                
                if (!willPopActually) {
                    return callSuperBlock();
                }
                
                UIViewController *appearingViewController = selfObject.qmui_rootViewController;
                NSArray<UIViewController *> *disappearingViewControllers = [selfObject.viewControllers subarrayWithRange:NSMakeRange(1, selfObject.viewControllers.count - 1)];
                
                [selfObject setQmui_navigationAction:QMUINavigationActionWillPop animated:animated appearingViewController:appearingViewController disappearingViewControllers:disappearingViewControllers];
                
                NSArray<UIViewController *> *result = callSuperBlock();
                
                // UINavigationController 不可见时 return 值可能为 nil
                // https://github.com/Tencent/QMUI_iOS/issues/1180
                QMUIAssert(!(selfObject.isViewLoaded && selfObject.view.window) || [result isEqualToArray:disappearingViewControllers], @"UINavigationController (QMUI)", @"QMUI 计算得到的 popToRootViewController 结果和系统的不一致");
                disappearingViewControllers = result ?: disappearingViewControllers;
                
                [selfObject setQmui_navigationAction:QMUINavigationActionDidPop animated:animated appearingViewController:appearingViewController disappearingViewControllers:disappearingViewControllers];
                
                [selfObject qmui_animateAlongsideTransition:nil completion:^(id<UIViewControllerTransitionCoordinatorContext>  _Nonnull context) {
                    [selfObject setQmui_navigationAction:QMUINavigationActionPopCompleted animated:animated appearingViewController:appearingViewController disappearingViewControllers:disappearingViewControllers];
                    [selfObject setQmui_navigationAction:QMUINavigationActionUnknow animated:animated appearingViewController:nil disappearingViewControllers:nil];
                }];
                
                return result;
            };
        });

#pragma mark - setViewControllers:animated:
        OverrideImplementation([UINavigationController class], @selector(setViewControllers:animated:), ^id(__unsafe_unretained Class originClass, SEL originCMD, IMP (^originalIMPProvider)(void)) {
            return ^(UINavigationController *selfObject, NSArray<UIViewController *> *viewControllers, BOOL animated) {
                
                if (viewControllers.count != [NSSet setWithArray:viewControllers].count) {
                    QMUIAssert(NO, @"UINavigationController (QMUI)", @"setViewControllers 数组里不允许出现重复元素：%@", viewControllers);
                    viewControllers = [NSOrderedSet orderedSetWithArray:viewControllers].array;// 这里会保留该 vc 第一次出现的位置不变
                }

                UIViewController *appearingViewController = selfObject.topViewController != viewControllers.lastObject ? viewControllers.lastObject : nil;// setViewControllers 执行前后 topViewController 没有变化，则赋值为 nil，表示没有任何界面有“重新显示”，这个 nil 的值也用于在 QMUINavigationController 里实现 viewControllerKeepingAppearWhenSetViewControllersWithAnimated:
                NSMutableArray<UIViewController *> *disappearingViewControllers = selfObject.viewControllers.mutableCopy;
                [disappearingViewControllers removeObjectsInArray:viewControllers];
                disappearingViewControllers = disappearingViewControllers.count ? disappearingViewControllers : nil;

                [selfObject setQmui_navigationAction:QMUINavigationActionWillSet animated:animated appearingViewController:appearingViewController disappearingViewControllers:disappearingViewControllers];

                // call super
                void (*originSelectorIMP)(id, SEL, NSArray<UIViewController *> *, BOOL);
                originSelectorIMP = (void (*)(id, SEL, NSArray<UIViewController *> *, BOOL))originalIMPProvider();
                originSelectorIMP(selfObject, originCMD, viewControllers, animated);

                [selfObject setQmui_navigationAction:QMUINavigationActionDidSet animated:animated appearingViewController:appearingViewController disappearingViewControllers:disappearingViewControllers];

                [selfObject qmui_animateAlongsideTransition:nil completion:^(id<UIViewControllerTransitionCoordinatorContext>  _Nonnull context) {
                    [selfObject setQmui_navigationAction:QMUINavigationActionSetCompleted animated:animated appearingViewController:appearingViewController disappearingViewControllers:disappearingViewControllers];
                    [selfObject setQmui_navigationAction:QMUINavigationActionUnknow animated:animated appearingViewController:nil disappearingViewControllers:nil];
                }];
            };
        });
    });
}

- (void)qmui_didInitialize {
}

static char kAssociatedObjectKey_navigationAction;
- (void)setQmui_navigationAction:(QMUINavigationAction)qmui_navigationAction
                        animated:(BOOL)animated
         appearingViewController:(UIViewController *)appearingViewController
     disappearingViewControllers:(NSArray<UIViewController *> *)disappearingViewControllers {
    BOOL valueChanged = self.qmui_navigationAction != qmui_navigationAction;
    objc_setAssociatedObject(self, &kAssociatedObjectKey_navigationAction, @(qmui_navigationAction), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    if (valueChanged && self.qmuinc_navigationActionDidChangeBlocks.count) {
        [self.qmuinc_navigationActionDidChangeBlocks enumerateObjectsUsingBlock:^(QMUINavigationActionDidChangeBlock  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            obj(qmui_navigationAction, animated, self, appearingViewController, disappearingViewControllers);
        }];
    }
}

- (QMUINavigationAction)qmui_navigationAction {
    return [((NSNumber *)objc_getAssociatedObject(self, &kAssociatedObjectKey_navigationAction)) unsignedIntegerValue];
}

- (void)qmui_addNavigationActionDidChangeBlock:(QMUINavigationActionDidChangeBlock)block {
    if (!self.qmuinc_navigationActionDidChangeBlocks) {
        self.qmuinc_navigationActionDidChangeBlocks = NSMutableArray.new;
    }
    [self.qmuinc_navigationActionDidChangeBlocks addObject:block];
}

// TODO: molice 改为用 QMUINavigationAction 判断
- (BOOL)qmui_isPushing {
    BOOL isPushing = self.qmui_navigationAction > QMUINavigationActionWillPush && self.qmui_navigationAction <= QMUINavigationActionPushCompleted;
    return isPushing;
}

// TODO: molice 改为用 QMUINavigationAction 判断
- (BOOL)qmui_isPopping {
    BOOL isPopping = self.qmui_navigationAction > QMUINavigationActionWillPop && self.qmui_navigationAction <= QMUINavigationActionPopCompleted;
    return isPopping;
}

- (UIViewController *)qmui_topViewController {
    if (self.qmui_isPushing) {
        return self.topViewController;
    }
    return self.qmui_endedTransitionTopViewController ? self.qmui_endedTransitionTopViewController : self.topViewController;
}

- (nullable UIViewController *)qmui_rootViewController {
    return self.viewControllers.firstObject;
}

- (void)qmui_pushViewController:(UIViewController *)viewController animated:(BOOL)animated completion:(void (^)(void))completion {
    // 要先进行转场操作才能产生 self.transitionCoordinator，然后才能用 qmui_animateAlongsideTransition:completion:，所以不能把转场操作放在 animation block 里。
    [self pushViewController:viewController animated:animated];
    if (completion) {
        [self qmui_animateAlongsideTransition:nil completion:^(id<UIViewControllerTransitionCoordinatorContext>  _Nonnull context) {
            completion();
        }];
    }
}

- (UIViewController *)qmui_popViewControllerAnimated:(BOOL)animated completion:(void (^)(void))completion {
    // 要先进行转场操作才能产生 self.transitionCoordinator，然后才能用 qmui_animateAlongsideTransition:completion:，所以不能把转场操作放在 animation block 里。
    UIViewController *result = [self popViewControllerAnimated:animated];
    if (completion) {
        [self qmui_animateAlongsideTransition:nil completion:^(id<UIViewControllerTransitionCoordinatorContext>  _Nonnull context) {
            completion();
        }];
    }
    return result;
}

- (NSArray<UIViewController *> *)qmui_popToViewController:(UIViewController *)viewController animated:(BOOL)animated completion:(void (^)(void))completion {
    // 要先进行转场操作才能产生 self.transitionCoordinator，然后才能用 qmui_animateAlongsideTransition:completion:，所以不能把转场操作放在 animation block 里。
    NSArray<UIViewController *> *result = [self popToViewController:viewController animated:animated];
    if (completion) {
        [self qmui_animateAlongsideTransition:nil completion:^(id<UIViewControllerTransitionCoordinatorContext>  _Nonnull context) {
            completion();
        }];
    }
    return result;
}

- (NSArray<UIViewController *> *)qmui_popToRootViewControllerAnimated:(BOOL)animated completion:(void (^)(void))completion {
    // 要先进行转场操作才能产生 self.transitionCoordinator，然后才能用 qmui_animateAlongsideTransition:completion:，所以不能把转场操作放在 animation block 里。
    NSArray<UIViewController *> *result = [self popToRootViewControllerAnimated:animated];
    if (completion) {
        [self qmui_animateAlongsideTransition:nil completion:^(id<UIViewControllerTransitionCoordinatorContext>  _Nonnull context) {
            completion();
        }];
    }
    return result;
}

- (BOOL)canPopViewController:(UIViewController *)viewController byPopGesture:(BOOL)byPopGesture {
    BOOL canPopViewController = YES;
    
    if ([viewController respondsToSelector:@selector(shouldPopViewControllerByBackButtonOrPopGesture:)] &&
        [viewController shouldPopViewControllerByBackButtonOrPopGesture:byPopGesture] == NO) {
        canPopViewController = NO;
    }
    
    return canPopViewController;
}

- (BOOL)shouldForceEnableInteractivePopGestureRecognizer {
    UIViewController *viewController = [self topViewController];
    return self.viewControllers.count > 1 && self.interactivePopGestureRecognizer.enabled && [viewController respondsToSelector:@selector(forceEnableInteractivePopGestureRecognizer)] && [viewController forceEnableInteractivePopGestureRecognizer];
}

@end


@implementation _QMUINavigationInteractiveGestureDelegator

- (instancetype)initWithParentViewController:(UINavigationController *)parentViewController {
    if (self = [super init]) {
        _parentViewController = parentViewController;
    }
    return self;
}

#pragma mark - <UIGestureRecognizerDelegate>

// iOS 13.4 开始会优先询问该方法，只有返回 YES 后才会继续后续的逻辑
- (BOOL)_gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveEvent:(UIEvent *)event {
    if (gestureRecognizer == self.parentViewController.interactivePopGestureRecognizer) {
        NSObject <UIGestureRecognizerDelegate> *originGestureDelegate = self.parentViewController.qmui_interactivePopGestureRecognizerDelegate;
        if ([originGestureDelegate respondsToSelector:_cmd]) {
            BOOL originalValue = YES;
            [originGestureDelegate qmui_performSelector:_cmd withPrimitiveReturnValue:&originalValue arguments:&gestureRecognizer, &event, nil];
            if (!originalValue && [self.parentViewController shouldForceEnableInteractivePopGestureRecognizer]) {
                return YES;
            }
            return originalValue;
        }
    }
    return YES;
}

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer {
    if (gestureRecognizer == self.parentViewController.interactivePopGestureRecognizer) {
        BOOL canPopViewController = [self.parentViewController canPopViewController:self.parentViewController.topViewController byPopGesture:YES];
        if (canPopViewController) {
            if ([self.parentViewController.qmui_interactivePopGestureRecognizerDelegate respondsToSelector:_cmd]) {
                BOOL result = [self.parentViewController.qmui_interactivePopGestureRecognizerDelegate gestureRecognizerShouldBegin:gestureRecognizer];
                return result;
            } else {
                return NO;
            }
        } else {
            return NO;
        }
    }
    return YES;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    if (gestureRecognizer == self.parentViewController.interactivePopGestureRecognizer) {
        id<UIGestureRecognizerDelegate>originGestureDelegate = self.parentViewController.qmui_interactivePopGestureRecognizerDelegate;
        if ([originGestureDelegate respondsToSelector:_cmd]) {
            BOOL originalValue = [originGestureDelegate gestureRecognizer:gestureRecognizer shouldReceiveTouch:touch];
            if (!originalValue && [self.parentViewController shouldForceEnableInteractivePopGestureRecognizer]) {
                return YES;
            }
            return originalValue;
        }
    }
    return YES;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    if (gestureRecognizer == self.parentViewController.interactivePopGestureRecognizer) {
        if ([self.parentViewController.qmui_interactivePopGestureRecognizerDelegate respondsToSelector:_cmd]) {
            BOOL result = [self.parentViewController.qmui_interactivePopGestureRecognizerDelegate gestureRecognizer:gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:otherGestureRecognizer];
            return result;
        }
    }
    return NO;
}

// 是否要gestureRecognizer检测失败了，才去检测otherGestureRecognizer
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldBeRequiredToFailByGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    if (gestureRecognizer == self.parentViewController.interactivePopGestureRecognizer) {
        // 如果只是实现了上面几个手势的delegate，那么返回的手势和当前界面上的scrollview或者其他存在的手势会冲突，所以如果判断是返回手势，则优先响应返回手势再响应其他手势。
        // 不知道为什么，系统竟然没有实现这个delegate，那么它是怎么处理返回手势和其他手势的优先级的
        return YES;
    }
    return NO;
}

@end


@implementation UIViewController (BackBarButtonSupport)
@end
