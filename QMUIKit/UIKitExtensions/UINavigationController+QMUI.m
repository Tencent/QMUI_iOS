/**
 * Tencent is pleased to support the open source community by making QMUI_iOS available.
 * Copyright (C) 2016-2020 THL A29 Limited, a Tencent company. All rights reserved.
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
#import "QMUIWeakObjectContainer.h"

@interface UINavigationController (QMUI_Private)
@property(nullable, nonatomic, readwrite) UIViewController *qmui_endedTransitionTopViewController;
@property(nullable, nonatomic, weak, readonly) id<UIGestureRecognizerDelegate> qmui_interactivePopGestureRecognizerDelegate;
@end

@implementation UINavigationController (QMUI)

QMUISynthesizeIdWeakProperty(qmui_endedTransitionTopViewController, setQmui_endedTransitionTopViewController)
QMUISynthesizeIdWeakProperty(qmui_interactivePopGestureRecognizerDelegate, setQmui_interactivePopGestureRecognizerDelegate)

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        ExtendImplementationOfVoidMethodWithoutArguments([UINavigationController class], @selector(viewDidLoad), ^(UINavigationController *selfObject) {
            selfObject.qmui_interactivePopGestureRecognizerDelegate = selfObject.interactivePopGestureRecognizer.delegate;
            selfObject.interactivePopGestureRecognizer.delegate = (id<UIGestureRecognizerDelegate>)selfObject;
        });
        
        if (@available(iOS 11.0, *)) {
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
        } else {
            OverrideImplementation([UINavigationBar class], NSSelectorFromString(@"_shouldPopForTouchAtPoint:"), ^id(__unsafe_unretained Class originClass, SEL originCMD, IMP (^originalIMPProvider)(void)) {
                return ^BOOL(UINavigationBar *selfObject, CGPoint firstArgv) {

                    // call super
                    BOOL (*originSelectorIMP)(id, SEL, CGPoint);
                    originSelectorIMP = (BOOL (*)(id, SEL, CGPoint))originalIMPProvider();
                    BOOL result = originSelectorIMP(selfObject, originCMD, firstArgv);

                    // 点击 navigationBar 任意地方都会触发这个方法，只有点到返回按钮时 result 才可能是 YES
                    if (result) {
                        if ([selfObject.delegate isKindOfClass:UINavigationController.class]) {
                            UINavigationController *navController = (UINavigationController *)selfObject.delegate;
                            BOOL canPopViewController = [navController canPopViewController:navController.topViewController byPopGesture:NO];
                            if (!canPopViewController) {
                                return NO;
                            }
                        }
                    }

                    return result;
                };
            });
        }
        
        OverrideImplementation([UINavigationController class], NSSelectorFromString(@"navigationTransitionView:didEndTransition:fromView:toView:"), ^id(__unsafe_unretained Class originClass, SEL originCMD, IMP (^originalIMPProvider)(void)) {
            return ^void(UINavigationController *selfObject, UIView *transitionView, NSInteger transition, UIView *fromView, UIView *toView) {
                
               BOOL (*originSelectorIMP)(id, SEL, UIView *, NSInteger , UIView *, UIView *);
               originSelectorIMP = (BOOL (*)(id, SEL, UIView *, NSInteger , UIView *, UIView *))originalIMPProvider();
                originSelectorIMP(selfObject, originCMD, transitionView, transition, fromView, toView);
                selfObject.qmui_endedTransitionTopViewController = selfObject.topViewController;
            };
        });
    });
}

- (BOOL)qmui_isPushing {
    if (self.viewControllers.count >= 2) {
        UIViewController *previousViewController = self.childViewControllers[self.childViewControllers.count - 2];
        if (previousViewController == self.qmui_endedTransitionTopViewController) {
            return YES;
        }
    }
    return NO;
}

- (BOOL)qmui_isPopping {
    return self.qmui_topViewController != self.topViewController;
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
    [QMUIHelper executeAnimationBlock:^{
        [self pushViewController:viewController animated:animated];
    } completionBlock:completion];
}

- (UIViewController *)qmui_popViewControllerAnimated:(BOOL)animated completion:(void (^)(void))completion {
    __block UIViewController *result = nil;
    [QMUIHelper executeAnimationBlock:^{
        result = [self popViewControllerAnimated:animated];
    } completionBlock:completion];
    return result;
}

- (NSArray<UIViewController *> *)qmui_popToViewController:(UIViewController *)viewController animated:(BOOL)animated completion:(void (^)(void))completion {
    __block NSArray<UIViewController *> *result = nil;
    [QMUIHelper executeAnimationBlock:^{
        result = [self popToViewController:viewController animated:animated];
    } completionBlock:completion];
    return result;
}

- (NSArray<UIViewController *> *)qmui_popToRootViewControllerAnimated:(BOOL)animated completion:(void (^)(void))completion {
    __block NSArray<UIViewController *> *result = nil;
    [QMUIHelper executeAnimationBlock:^{
        result = [self popToRootViewControllerAnimated:animated];
    } completionBlock:completion];
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

// iOS 13.4 开始会优先询问该方法，只有返回 YES 后才会继续后续的逻辑
- (BOOL)_gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveEvent:(UIEvent *)event {
    if (gestureRecognizer == self.interactivePopGestureRecognizer) {
        NSObject <UIGestureRecognizerDelegate> *originGestureDelegate = self.qmui_interactivePopGestureRecognizerDelegate;
        if ([originGestureDelegate respondsToSelector:_cmd]) {
            BOOL originalValue = YES;
            [originGestureDelegate qmui_performSelector:_cmd withPrimitiveReturnValue:&originalValue arguments:&gestureRecognizer, &event, nil];
            if (!originalValue && [self shouldForceEnableInteractivePopGestureRecognizer]) {
                return YES;
            }
            return originalValue;
        }
    }
    return YES;
}

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer {
    if (gestureRecognizer == self.interactivePopGestureRecognizer) {
        BOOL canPopViewController = [self canPopViewController:self.topViewController byPopGesture:YES];
        if (canPopViewController) {
            if ([self.qmui_interactivePopGestureRecognizerDelegate respondsToSelector:_cmd]) {
                return [self.qmui_interactivePopGestureRecognizerDelegate gestureRecognizerShouldBegin:gestureRecognizer];
            } else {
                return NO;
            }
        } else {
            return NO;
        }
    }
    return YES;
}

- (BOOL)shouldForceEnableInteractivePopGestureRecognizer {
    UIViewController *viewController = [self topViewController];
    return self.viewControllers.count > 1 && self.interactivePopGestureRecognizer.enabled && [viewController respondsToSelector:@selector(forceEnableInteractivePopGestureRecognizer)] && [viewController forceEnableInteractivePopGestureRecognizer];
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    if (gestureRecognizer == self.interactivePopGestureRecognizer) {
        id<UIGestureRecognizerDelegate>originGestureDelegate = self.qmui_interactivePopGestureRecognizerDelegate;
        if ([originGestureDelegate respondsToSelector:_cmd]) {
            BOOL originalValue = [originGestureDelegate gestureRecognizer:gestureRecognizer shouldReceiveTouch:touch];
            if (!originalValue && [self shouldForceEnableInteractivePopGestureRecognizer]) {
                return YES;
            }
            return originalValue;
        }
    }
    return YES;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    if (gestureRecognizer == self.interactivePopGestureRecognizer) {
        if ([self.qmui_interactivePopGestureRecognizerDelegate respondsToSelector:_cmd]) {
            return [self.qmui_interactivePopGestureRecognizerDelegate gestureRecognizer:gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:otherGestureRecognizer];
        }
    }
    return NO;
}

// 是否要gestureRecognizer检测失败了，才去检测otherGestureRecognizer
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldBeRequiredToFailByGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    if (gestureRecognizer == self.interactivePopGestureRecognizer) {
        // 如果只是实现了上面几个手势的delegate，那么返回的手势和当前界面上的scrollview或者其他存在的手势会冲突，所以如果判断是返回手势，则优先响应返回手势再响应其他手势。
        // 不知道为什么，系统竟然没有实现这个delegate，那么它是怎么处理返回手势和其他手势的优先级的
        return YES;
    }
    return NO;
}

@end


@implementation UIViewController (BackBarButtonSupport)

@end
