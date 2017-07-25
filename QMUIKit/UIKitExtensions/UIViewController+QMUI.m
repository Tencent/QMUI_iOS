//
//  UIViewController+QMUI.m
//  qmui
//
//  Created by QQMail on 16/1/12.
//  Copyright © 2016年 QMUI Team. All rights reserved.
//

#import "UIViewController+QMUI.h"
#import "QMUINavigationController.h"
#import "UINavigationController+QMUI.h"
#import <objc/runtime.h>
#import "QMUICore.h"
#import "NSObject+QMUI.h"

@implementation UIViewController (QMUI)

void qmui_loadViewIfNeeded (id current_self, SEL current_cmd) {
    // 主动调用 self.view，从而触发 loadView，以模拟 iOS 9.0 以下的系统 loadViewIfNeeded 行为
    QMUILog(@"%@", ((UIViewController *)current_self).view);
}

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        // 为 description 增加更丰富的信息
        ReplaceMethod([UIViewController class], @selector(description), @selector(qmui_description));
        
        // 兼容 iOS 9.0 以下的版本对 loadViewIfNeeded 方法的调用
        if (![[UIViewController class] instancesRespondToSelector:@selector(loadViewIfNeeded)]) {
            Class metaclass = [self class];
            BOOL success = class_addMethod(metaclass, @selector(loadViewIfNeeded), (IMP)qmui_loadViewIfNeeded, "v@:");
            QMUILog(@"%@ %s, success = %@", NSStringFromClass([self class]), __func__, StringFromBOOL(success));
        }
        
        // 实现 AutomaticallyRotateDeviceOrientation 开关的功能
        ReplaceMethod([UIViewController class], @selector(viewWillAppear:), @selector(qmui_viewWillAppear:));
    });
}

- (NSString *)qmui_description {
    NSString *result = [NSString stringWithFormat:@"%@\nsuperclass:\t\t\t\t%@\ntitle:\t\t\t\t\t%@\nview:\t\t\t\t\t%@", [self qmui_description], NSStringFromClass(self.superclass), self.title, [self isViewLoaded] ? self.view : nil];
    
    if ([self isKindOfClass:[UINavigationController class]]) {
        
        UINavigationController *navController = (UINavigationController *)self;
        NSString *navDescription = [NSString stringWithFormat:@"\nviewControllers(%@):\t\t%@\ntopViewController:\t\t%@\nvisibleViewController:\t%@", @(navController.viewControllers.count), [self descriptionWithViewControllers:navController.viewControllers], [navController.topViewController qmui_description], [navController.visibleViewController qmui_description]];
        result = [result stringByAppendingString:navDescription];
        
    } else if ([self isKindOfClass:[UITabBarController class]]) {
        
        UITabBarController *tabBarController = (UITabBarController *)self;
        NSString *tabBarDescription = [NSString stringWithFormat:@"\nviewControllers(%@):\t\t%@\nselectedViewController(%@):\t%@", @(tabBarController.viewControllers.count), [self descriptionWithViewControllers:tabBarController.viewControllers], @(tabBarController.selectedIndex), [tabBarController.selectedViewController qmui_description]];
        result = [result stringByAppendingString:tabBarDescription];
        
    }
    return result;
}

- (NSString *)descriptionWithViewControllers:(NSArray<UIViewController *> *)viewControllers {
    NSMutableString *string = [[NSMutableString alloc] init];
    [string appendString:@"(\n"];
    for (NSInteger i = 0, l = viewControllers.count; i < l; i++) {
        [string appendFormat:@"\t\t\t\t\t\t\t[%@]%@%@\n", @(i), [viewControllers[i] qmui_description], i < l - 1 ? @"," : @""];
    }
    [string appendString:@"\t\t\t\t\t\t)"];
    return [string copy];
}

- (void)qmui_viewWillAppear:(BOOL)animated {
    [self qmui_viewWillAppear:animated];
    if (!AutomaticallyRotateDeviceOrientation) {
        return;
    }
    
    UIInterfaceOrientation statusBarOrientation = [[UIApplication sharedApplication] statusBarOrientation];
    UIDeviceOrientation deviceOrientationBeforeChangingByHelper = [QMUIHelper sharedInstance].orientationBeforeChangingByHelper;
    BOOL shouldConsiderBeforeChanging = deviceOrientationBeforeChangingByHelper != UIDeviceOrientationUnknown;
    UIDeviceOrientation deviceOrientation = [UIDevice currentDevice].orientation;
    
    // 虽然这两者的 unknow 值是相同的，但在启动 App 时可能只有其中一个是 unknown
    if (statusBarOrientation == UIInterfaceOrientationUnknown || deviceOrientation == UIDeviceOrientationUnknown) return;
    
    // 如果当前设备方向和界面支持的方向不一致，则主动进行旋转
    UIDeviceOrientation deviceOrientationToRotate = [self interfaceOrientationMask:self.supportedInterfaceOrientations containsDeviceOrientation:deviceOrientation] ? deviceOrientation : [self deviceOrientationWithInterfaceOrientationMask:self.supportedInterfaceOrientations];
    
    // 之前没用私有接口修改过，拿就按最标准的方式去旋转
    if (!shouldConsiderBeforeChanging) {
        if ([QMUIHelper rotateToDeviceOrientation:deviceOrientationToRotate]) {
            [QMUIHelper sharedInstance].orientationBeforeChangingByHelper = deviceOrientation;
        } else {
            [QMUIHelper sharedInstance].orientationBeforeChangingByHelper = UIDeviceOrientationUnknown;
        }
        return;
    }
    
    // 用私有接口修改过方向，但下一个界面和当前界面方向不相同，则要把修改前记录下来的那个设备方向考虑进来
    deviceOrientationToRotate = [self interfaceOrientationMask:self.supportedInterfaceOrientations containsDeviceOrientation:deviceOrientationBeforeChangingByHelper] ? deviceOrientationBeforeChangingByHelper : [self deviceOrientationWithInterfaceOrientationMask:self.supportedInterfaceOrientations];
    [QMUIHelper rotateToDeviceOrientation:deviceOrientationToRotate];
}

- (UIDeviceOrientation)deviceOrientationWithInterfaceOrientationMask:(UIInterfaceOrientationMask)mask {
    if ((mask & UIInterfaceOrientationMaskAll) == UIInterfaceOrientationMaskAll) {
        return [UIDevice currentDevice].orientation;
    }
    if ((mask & UIInterfaceOrientationMaskAllButUpsideDown) == UIInterfaceOrientationMaskAllButUpsideDown) {
        return [UIDevice currentDevice].orientation;
    }
    if ((mask & UIInterfaceOrientationMaskPortrait) == UIInterfaceOrientationMaskPortrait) {
        return UIDeviceOrientationPortrait;
    }
    if ((mask & UIInterfaceOrientationMaskLandscape) == UIInterfaceOrientationMaskLandscape) {
        return [UIDevice currentDevice].orientation == UIDeviceOrientationLandscapeLeft ? UIDeviceOrientationLandscapeLeft : UIDeviceOrientationLandscapeRight;
    }
    if ((mask & UIInterfaceOrientationMaskLandscapeLeft) == UIInterfaceOrientationMaskLandscapeLeft) {
        return UIDeviceOrientationLandscapeRight;
    }
    if ((mask & UIInterfaceOrientationMaskLandscapeRight) == UIInterfaceOrientationMaskLandscapeRight) {
        return UIDeviceOrientationLandscapeLeft;
    }
    if ((mask & UIInterfaceOrientationMaskPortraitUpsideDown) == UIInterfaceOrientationMaskPortraitUpsideDown) {
        return UIDeviceOrientationPortraitUpsideDown;
    }
    return [UIDevice currentDevice].orientation;
}

- (BOOL)interfaceOrientationMask:(UIInterfaceOrientationMask)mask containsDeviceOrientation:(UIDeviceOrientation)deviceOrientation {
    if (deviceOrientation == UIDeviceOrientationUnknown) {
        return YES;// YES 表示不用额外处理
    }
    
    if ((mask & UIInterfaceOrientationMaskAll) == UIInterfaceOrientationMaskAll) {
        return YES;
    }
    if ((mask & UIInterfaceOrientationMaskAllButUpsideDown) == UIInterfaceOrientationMaskAllButUpsideDown) {
        return UIInterfaceOrientationPortraitUpsideDown != deviceOrientation;
    }
    if ((mask & UIInterfaceOrientationMaskPortrait) == UIInterfaceOrientationMaskPortrait) {
        return UIInterfaceOrientationPortrait == deviceOrientation;
    }
    if ((mask & UIInterfaceOrientationMaskLandscape) == UIInterfaceOrientationMaskLandscape) {
        return UIInterfaceOrientationLandscapeLeft == deviceOrientation || UIInterfaceOrientationLandscapeRight == deviceOrientation;
    }
    if ((mask & UIInterfaceOrientationMaskLandscapeLeft) == UIInterfaceOrientationMaskLandscapeLeft) {
        return UIInterfaceOrientationLandscapeLeft == deviceOrientation;
    }
    if ((mask & UIInterfaceOrientationMaskLandscapeRight) == UIInterfaceOrientationMaskLandscapeRight) {
        return UIInterfaceOrientationLandscapeRight == deviceOrientation;
    }
    if ((mask & UIInterfaceOrientationMaskPortraitUpsideDown) == UIInterfaceOrientationMaskPortraitUpsideDown) {
        return UIInterfaceOrientationPortraitUpsideDown == deviceOrientation;
    }
    
    return YES;
}

- (UIViewController *)qmui_previousViewController {
    if (self.navigationController.viewControllers && self.navigationController.viewControllers.count > 1 && self.navigationController.topViewController == self) {
        NSUInteger count = self.navigationController.viewControllers.count;
        return (UIViewController *)[self.navigationController.viewControllers objectAtIndex:count - 2];
    }
    return nil;
}

- (NSString *)qmui_previousViewControllerTitle {
    UIViewController *previousViewController = [self qmui_previousViewController];
    if (previousViewController) {
        return previousViewController.title;
    }
    return nil;
}

- (BOOL)qmui_isPresented {
    UIViewController *viewController = self;
    if (self.navigationController) {
        if (self.navigationController.qmui_rootViewController != self) {
            return NO;
        }
        viewController = self.navigationController;
    }
    BOOL result = viewController.presentingViewController.presentedViewController == viewController;
    return result;
}

- (UIViewController *)qmui_visibleViewControllerIfExist {
    
    if (self.presentedViewController) {
        return [self.presentedViewController qmui_visibleViewControllerIfExist];
    }
    
    if ([self isKindOfClass:[UINavigationController class]]) {
        return [((UINavigationController *)self).visibleViewController qmui_visibleViewControllerIfExist];
    }
    
    if ([self isKindOfClass:[UITabBarController class]]) {
        return [((UITabBarController *)self).selectedViewController qmui_visibleViewControllerIfExist];
    }
    
    if ([self isViewLoaded] && self.view.window) {
        return self;
    } else {
        NSLog(@"qmui_visibleViewControllerIfExist:，找不到可见的viewController。self = %@, self.view.window = %@", self, self.view.window);
        return nil;
    }
}

- (BOOL)qmui_respondQMUINavigationControllerDelegate {
    return [[self class] conformsToProtocol:@protocol(QMUINavigationControllerDelegate)];
}

- (BOOL)qmui_isViewLoadedAndVisible {
    return self.isViewLoaded && self.view.window;
}

@end

@interface UIViewController ()

@property(nonatomic, assign) BOOL qmui_isViewDidAppear;
@end

@implementation UIViewController (Data)

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        ReplaceMethod(self.class, @selector(viewDidAppear:), @selector(qmui_viewDidAppear:));
    });
}

- (void)qmui_viewDidAppear:(BOOL)animated {
    [self qmui_viewDidAppear:animated];
    self.qmui_isViewDidAppear = YES;
    if (self.qmui_didAppearAndLoadDataBlock && self.qmui_isViewDidAppear && self.qmui_dataLoaded) {
        self.qmui_didAppearAndLoadDataBlock();
        self.qmui_didAppearAndLoadDataBlock = nil;
    }
}

static char kAssociatedObjectKey_isViewDidAppear;
- (void)setQmui_isViewDidAppear:(BOOL)qmui_isViewDidAppear {
    objc_setAssociatedObject(self, &kAssociatedObjectKey_isViewDidAppear, @(qmui_isViewDidAppear), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (BOOL)qmui_isViewDidAppear {
    return [((NSNumber *)objc_getAssociatedObject(self, &kAssociatedObjectKey_isViewDidAppear)) boolValue];
}

static char kAssociatedObjectKey_didAppearAndLoadDataBlock;
- (void)setQmui_didAppearAndLoadDataBlock:(void (^)())qmui_didAppearAndLoadDataBlock {
    objc_setAssociatedObject(self, &kAssociatedObjectKey_didAppearAndLoadDataBlock, qmui_didAppearAndLoadDataBlock, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (void (^)())qmui_didAppearAndLoadDataBlock {
    return (void (^)())objc_getAssociatedObject(self, &kAssociatedObjectKey_didAppearAndLoadDataBlock);
}

static char kAssociatedObjectKey_dataLoaded;
- (void)setQmui_dataLoaded:(BOOL)qmui_dataLoaded {
    objc_setAssociatedObject(self, &kAssociatedObjectKey_dataLoaded, @(qmui_dataLoaded), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    if (self.qmui_didAppearAndLoadDataBlock && qmui_dataLoaded && self.qmui_isViewDidAppear) {
        self.qmui_didAppearAndLoadDataBlock();
        self.qmui_didAppearAndLoadDataBlock = nil;
    }
}

- (BOOL)isQmui_dataLoaded {
    return [((NSNumber *)objc_getAssociatedObject(self, &kAssociatedObjectKey_dataLoaded)) boolValue];
}

@end

@implementation UIViewController (Runtime)

- (BOOL)qmui_hasOverrideUIKitMethod:(SEL)selector {
    // 排序依照 Xcode Interface Builder 里的控件排序，但保证子类在父类前面
    NSMutableArray<Class> *viewControllerSuperclasses = [[NSMutableArray alloc] initWithObjects:
                                               [UIImagePickerController class],
                                               [UINavigationController class],
                                               [UITableViewController class],
                                               [UICollectionViewController class],
                                               [UITabBarController class],
                                               [UISplitViewController class],
                                               [UIPageViewController class],
                                               [UIViewController class],
                                               nil];
    
    if (NSClassFromString(@"UIAlertController")) {
        [viewControllerSuperclasses addObject:[UIAlertController class]];
    }
    if (NSClassFromString(@"UISearchController")) {
        [viewControllerSuperclasses addObject:[UISearchController class]];
    }
    for (NSInteger i = 0, l = viewControllerSuperclasses.count; i < l; i++) {
        Class superclass = viewControllerSuperclasses[i];
        if ([self qmui_hasOverrideMethod:selector ofSuperclass:superclass]) {
            return YES;
        }
    }
    return NO;
}

@end
