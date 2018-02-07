//
//  UINavigationController+QMUI.m
//  qmui
//
//  Created by QQMail on 16/1/12.
//  Copyright © 2016年 QMUI Team. All rights reserved.
//

#import "UINavigationController+QMUI.h"
#import "QMUICommonDefines.h"
#import "QMUIConfiguration.h"
#import "QMUIHelper.h"

@implementation UINavigationController (QMUI)

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        ReplaceMethod([self class], @selector(viewDidLoad), @selector(qmui_viewDidLoad));
        ReplaceMethod([self class], @selector(navigationBar:shouldPopItem:), @selector(qmui_navigationBar:shouldPopItem:));
    });
}

- (nullable UIViewController *)qmui_rootViewController {
    return self.viewControllers.firstObject;
}

static char originGestureDelegateKey;
- (void)qmui_viewDidLoad {
    [self qmui_viewDidLoad];
    objc_setAssociatedObject(self, &originGestureDelegateKey, self.interactivePopGestureRecognizer.delegate, OBJC_ASSOCIATION_ASSIGN);
    QMUILog(@"%@", self.interactivePopGestureRecognizer.delegate);
    self.interactivePopGestureRecognizer.delegate = (id<UIGestureRecognizerDelegate>)self;
}

- (BOOL)qmui_navigationBar:(UINavigationBar *)navigationBar shouldPopItem:(UINavigationItem *)item {
    
    UIViewController *viewController = [self topViewController];
    
    BOOL canPopViewController = YES;
    //item == viewController.navigationItem to fix: 如果前后2个controller都需要hold时的BUG.
    if ((item == viewController.navigationItem) &&
        [viewController respondsToSelector:@selector(shouldHoldBackButtonEvent)] &&
        [viewController shouldHoldBackButtonEvent] &&
        [viewController respondsToSelector:@selector(canPopViewController)]) {
        canPopViewController = [viewController canPopViewController];
    }
    
    // 如果nav的vc栈中有两个vc，第一个是root，第二个是second。这是second页面如果点击系统的返回按钮，topViewController获取的栈顶vc是second，而如果是直接代码写的pop操作，则获取的栈顶vc是root。也就是说只要代码写了pop操作，则系统会直接将顶层vc也就是second出栈，然后才回调的，所以这是我们获取到的顶层vc就是root了。然而不管哪种方式，参数中的item都是second的item。
    // 综上所述，使用item != viewController.navigationItem来判断就是为了解决这个问题。
    if (canPopViewController || item != viewController.navigationItem) {
        return [self qmui_navigationBar:navigationBar shouldPopItem:item];
    } else {
        [self resetSubviewsInNavBar:navigationBar];
    }
    
    return NO;
}

- (void)resetSubviewsInNavBar:(UINavigationBar *)navBar {
    // Workaround for >= iOS7.1. Thanks to @boliva - http://stackoverflow.com/posts/comments/34452906
    for(UIView *subview in [navBar subviews]) {
        if(subview.alpha < 1.0) {
            [UIView animateWithDuration:.25 animations:^{
                subview.alpha = 1.0;
            }];
        }
    }
}

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer {
    if (gestureRecognizer == self.interactivePopGestureRecognizer) {
        UIViewController *viewController = [self topViewController];
        BOOL canPopViewController = YES;
        if ([viewController respondsToSelector:@selector(shouldHoldBackButtonEvent)] && [viewController shouldHoldBackButtonEvent] &&
            [viewController respondsToSelector:@selector(canPopViewController)] && ![viewController canPopViewController]) {
            canPopViewController = NO;
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

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    if (gestureRecognizer == self.interactivePopGestureRecognizer) {
        id<UIGestureRecognizerDelegate>originGestureDelegate = objc_getAssociatedObject(self, &originGestureDelegateKey);
        if ([originGestureDelegate respondsToSelector:@selector(gestureRecognizer:shouldReceiveTouch:)]) {
            // 先判断要不要强制开启手势返回
            UIViewController *viewController = [self topViewController];
            if ([viewController respondsToSelector:@selector(forceEnableInteractivePopGestureRecognizer)] &&
                [viewController forceEnableInteractivePopGestureRecognizer]) {
                return YES;
            }
            // 调用默认的实现
            return [originGestureDelegate gestureRecognizer:gestureRecognizer shouldReceiveTouch:touch];
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
