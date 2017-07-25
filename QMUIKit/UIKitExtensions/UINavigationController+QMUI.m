//
//  UINavigationController+QMUI.m
//  qmui
//
//  Created by QQMail on 16/1/12.
//  Copyright © 2016年 QMUI Team. All rights reserved.
//

#import "UINavigationController+QMUI.h"
#import "QMUICore.h"

@interface UINavigationController (BackButtonHandlerProtocol)

// `UINavigationControllerBackButtonHandlerProtocol`的`canPopViewController`功能里面，当 A canPop = NO，B canPop = YES，那么从 B 手势返回到 A，也会触发需求 A 的 `canPopViewController` 方法，这是因为手势返回会去询问`gestureRecognizerShouldBegin:`和`qmui_navigationBar:shouldPopItem:`，而这两个方法里面的 self.topViewController 是不同的对象，所以导致这个问题。所以通过 tmp_topViewController 来记录 self.topViewController 从而保证两个地方的值是相等的。

- (nullable UIViewController *)tmp_topViewController;

@end

@implementation UINavigationController (BackButtonHandlerProtocol)

- (UIViewController *)tmp_topViewController {
    return objc_getAssociatedObject(self, _cmd);
}

- (void)setTmp_topViewController:(UIViewController *)viewController {
    objc_setAssociatedObject(self, @selector(tmp_topViewController), viewController, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

@end


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
    self.interactivePopGestureRecognizer.delegate = (id<UIGestureRecognizerDelegate>)self;
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

- (BOOL)qmui_navigationBar:(UINavigationBar *)navigationBar shouldPopItem:(UINavigationItem *)item {
    
    // 如果nav的vc栈中有两个vc，第一个是root，第二个是second。这是second页面如果点击系统的返回按钮，topViewController获取的栈顶vc是second，而如果是直接代码写的pop操作，则获取的栈顶vc是root。也就是说只要代码写了pop操作，则系统会直接将顶层vc也就是second出栈，然后才回调的，所以这时我们获取到的顶层vc就是root了。然而不管哪种方式，参数中的item都是second的item。
    BOOL isPopedByCoding = item != [self topViewController].navigationItem;
    
    // !isPopedByCoding 要放在前面，这样当 !isPopedByCoding 不满足的时候就不会去询问 canPopViewController 了，可以避免额外调用 canPopViewController 里面的逻辑导致
    BOOL canPopViewController = !isPopedByCoding && [self canPopViewController:self.tmp_topViewController ?: [self topViewController]];
    
    if (canPopViewController || isPopedByCoding) {
        self.tmp_topViewController = nil;
        return [self qmui_navigationBar:navigationBar shouldPopItem:item];
    } else {
        [self resetSubviewsInNavBar:navigationBar];
        self.tmp_topViewController = nil;
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
        self.tmp_topViewController = self.topViewController;
        BOOL canPopViewController = [self canPopViewController:self.tmp_topViewController];
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
            if (self.viewControllers.count > 1 &&
                self.interactivePopGestureRecognizer.enabled &&
                [viewController respondsToSelector:@selector(forceEnableInteractivePopGestureRecognizer)] &&
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
