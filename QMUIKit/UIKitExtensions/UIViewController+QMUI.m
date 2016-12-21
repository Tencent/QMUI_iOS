//
//  UIViewController+QMUI.m
//  qmui
//
//  Created by QQMail on 16/1/12.
//  Copyright © 2016年 QMUI Team. All rights reserved.
//

#import "UIViewController+QMUI.h"
#import "QMUINavigationController.h"

@implementation UIViewController (QMUI)

- (UIViewController *)previousViewController {
    if (self.navigationController.viewControllers && self.navigationController.viewControllers.count > 1 && self.navigationController.topViewController == self) {
        NSUInteger count = self.navigationController.viewControllers.count;
        return (UIViewController *)[self.navigationController.viewControllers objectAtIndex:count - 2];
    }
    return nil;
}

- (NSString *)previousViewControllerTitle {
    UIViewController *previousViewController = [self previousViewController];
    if (previousViewController) {
        return previousViewController.title;
    }
    return nil;
}

- (BOOL)isTransitioningTypePresented {
    if (self.navigationController && [self.navigationController.viewControllers indexOfObject:self] > 0) {
        return NO;
    }
    if (self.presentingViewController) {
        // 单纯一个普通viewController被present（其实即使这个viewcontroller被抱在navController或者tabController里面，这里有也值）
        // 所以大部分情况在这里就返回YES了
        return YES;
    }
    return NO;
}

- (UIViewController *)visibleViewControllerIfExist {
    
    if (self.presentedViewController) {
        return [self.presentedViewController visibleViewControllerIfExist];
    }
    
    if ([self isKindOfClass:[UINavigationController class]]) {
        return [((UINavigationController *)self).topViewController visibleViewControllerIfExist];
    }
    
    if ([self isKindOfClass:[UITabBarController class]]) {
        return [((UITabBarController *)self).selectedViewController visibleViewControllerIfExist];
    }
    
    if ([self isViewLoaded] && self.view.window) {
        return self;
    } else {
        NSLog(@"visibleViewControllerIfExist:，找不到可见的viewController。self = %@, self.view.window = %@", self, self.view.window);
        return nil;
    }
}

- (BOOL)respondQMUINavigationControllerDelegate {
    return [[self class] conformsToProtocol:@protocol(QMUINavigationControllerDelegate)];
}

- (BOOL)isViewLoadedAndVisible {
    return self.isViewLoaded && self.view.window;
}

@end
