/*****
 * Tencent is pleased to support the open source community by making QMUI_iOS available.
 * Copyright (C) 2016-2019 THL A29 Limited, a Tencent company. All rights reserved.
 * Licensed under the MIT License (the "License"); you may not use this file except in compliance with the License. You may obtain a copy of the License at
 * http://opensource.org/licenses/MIT
 * Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.
 *****/

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

@interface UINavigationController (BackButtonHandlerProtocol)

// `UINavigationControllerBackButtonHandlerProtocol`的`canPopViewController`功能里面，当 A canPop = NO，B canPop = YES，那么从 B 手势返回到 A，也会触发 A 的 `canPopViewController` 方法，这是因为手势返回会去询问`gestureRecognizerShouldBegin:`和`qmuinav_navigationBar:shouldPopItem:`，而这两个方法里面的 self.topViewController 是不同的对象，所以导致这个问题。所以通过 tmp_topViewController 来记录 self.topViewController 从而保证两个地方的值是相等的。
// 手势从 B 返回 A，如果 A 没有 navBar，那么`qmuinav_navigationBar:shouldPopItem:`是不会被调用的，所以导致 tmp_topViewController 没有被释放，所以 tmp_topViewController 需要使用 weak 来修饰（https://github.com/Tencent/QMUI_iOS/issues/251）
@property(nonatomic, weak) UIViewController *tmp_topViewController;

@end

@implementation UINavigationController (BackButtonHandlerProtocol)

QMUISynthesizeIdWeakProperty(tmp_topViewController, setTmp_topViewController)

@end


@implementation UINavigationController (QMUI)

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        ExtendImplementationOfVoidMethodWithoutArguments([UINavigationController class], @selector(viewDidLoad), ^(UINavigationController *selfObject) {
            objc_setAssociatedObject(selfObject, &originGestureDelegateKey, selfObject.interactivePopGestureRecognizer.delegate, OBJC_ASSOCIATION_ASSIGN);
            selfObject.interactivePopGestureRecognizer.delegate = (id<UIGestureRecognizerDelegate>)selfObject;
        });
        
        OverrideImplementation([UINavigationController class], @selector(navigationBar:shouldPopItem:), ^id(__unsafe_unretained Class originClass, SEL originCMD, IMP (^originalIMPProvider)(void)) {
            return ^BOOL(UINavigationController *selfObject, UINavigationBar *navigationBar, UINavigationItem *item) {
                
                // call super
                BOOL (^callSuperBlock)(UINavigationController *, UINavigationBar *, UINavigationItem *) = ^BOOL(UINavigationController *aSelfObject, UINavigationBar *aNavigationBar, UINavigationItem *aItem) {
                    BOOL (*originSelectorIMP)(id, SEL, UINavigationBar *, UINavigationItem *);
                    originSelectorIMP = (BOOL (*)(id, SEL, UINavigationBar *, UINavigationItem *))originalIMPProvider();
                    BOOL result = originSelectorIMP(aSelfObject, originCMD, aNavigationBar, aItem);
                    return result;
                };
                
                // avoid superclass
                if (![selfObject isKindOfClass:originClass]) return callSuperBlock(selfObject, navigationBar, item);
                
                // 如果nav的vc栈中有两个vc，第一个是root，第二个是second。这时second页面如果点击系统的返回按钮，topViewController获取的栈顶vc是second，而如果是直接代码写的pop操作，则获取的栈顶vc是root。也就是说只要代码写了pop操作，则系统会直接将顶层vc也就是second出栈，然后才回调的，所以这时我们获取到的顶层vc就是root了。然而不管哪种方式，参数中的item都是second的item。
                BOOL isPopedByCoding = item != [selfObject topViewController].navigationItem;
                
                // !isPopedByCoding 要放在前面，这样当 !isPopedByCoding 不满足的时候就不会去询问 canPopViewController 了，可以避免额外调用 canPopViewController 里面的逻辑
                BOOL canPopViewController = !isPopedByCoding && [selfObject canPopViewController:selfObject.tmp_topViewController ?: [selfObject topViewController]];
                
                if (canPopViewController || isPopedByCoding) {
                    selfObject.tmp_topViewController = nil;
                    BOOL result = callSuperBlock(selfObject, navigationBar, item);
                    return result;
                } else {
                    selfObject.tmp_topViewController = nil;
                    [selfObject resetSubviewsInNavBar:navigationBar];
                }
                
                return NO;
            };
        });
    });
}

static char originGestureDelegateKey;

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

- (BOOL)canPopViewController:(UIViewController *)viewController {
    BOOL canPopViewController = YES;
    
    if ([viewController respondsToSelector:@selector(shouldHoldBackButtonEvent)] &&
        [viewController shouldHoldBackButtonEvent] &&
        [viewController respondsToSelector:@selector(canPopViewController)] &&
        ![viewController canPopViewController]) {
        canPopViewController = NO;
    }
    
    return canPopViewController;
}

- (void)resetSubviewsInNavBar:(UINavigationBar *)navBar {
    if (@available(iOS 11, *)) {
    } else {
        // Workaround for >= iOS7.1. Thanks to @boliva - http://stackoverflow.com/posts/comments/34452906
        [navBar.subviews enumerateObjectsUsingBlock:^(__kindof UIView * _Nonnull subview, NSUInteger idx, BOOL * _Nonnull stop) {
            if (subview.alpha < 1.0) {
                [UIView animateWithDuration:.25 animations:^{
                    subview.alpha = 1.0;
                }];
            }
        }];
    }
}

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer {
    if (gestureRecognizer == self.interactivePopGestureRecognizer) {
        self.tmp_topViewController = self.topViewController;
        BOOL canPopViewController = [self canPopViewController:self.tmp_topViewController];
        if ([self shouldForceEnableInteractivePopGestureRecognizer]) {
            // 如果是强制手势返回，则不会调用 navigationBar:shouldPopItem:（原因未知，不过好像也没什么影响），导致 pop 回去的上一层界面点击系统返回按钮时调用 [self canPopViewController:self.tmp_topViewController] 时里面的 self.tmp_topViewController 是上一个界面的值，所以提前把它设置为 nil
            self.tmp_topViewController = nil;
        }
        if (canPopViewController) {
            id<UIGestureRecognizerDelegate>originGestureDelegate = objc_getAssociatedObject(self, &originGestureDelegateKey);
            if ([originGestureDelegate respondsToSelector:@selector(gestureRecognizerShouldBegin:)]) {
                return [originGestureDelegate gestureRecognizerShouldBegin:gestureRecognizer];
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
        id<UIGestureRecognizerDelegate>originGestureDelegate = objc_getAssociatedObject(self, &originGestureDelegateKey);
        if ([originGestureDelegate respondsToSelector:@selector(gestureRecognizer:shouldReceiveTouch:)]) {
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
        id<UIGestureRecognizerDelegate>originGestureDelegate = objc_getAssociatedObject(self, &originGestureDelegateKey);
        if ([originGestureDelegate respondsToSelector:@selector(gestureRecognizer:shouldRecognizeSimultaneouslyWithGestureRecognizer:)]) {
            return [originGestureDelegate gestureRecognizer:gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:otherGestureRecognizer];
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
