//
//  UIViewController+QMUI.m
//  qmui
//
//  Created by QMUI Team on 16/1/12.
//  Copyright © 2016年 QMUI Team. All rights reserved.
//

#import "UIViewController+QMUI.h"
#import "UINavigationController+QMUI.h"
#import "QMUICore.h"
#import "NSObject+QMUI.h"
#import "QMUILog.h"

NSString *const QMUITabBarStyleChangedNotification = @"QMUITabBarStyleChangedNotification";

@interface UIViewController ()

@property(nonatomic, assign) BOOL qmui_isViewDidAppear;
@property(nonatomic, strong) UINavigationBar *transitionNavigationBar;// by molice 对应 UIViewController (NavigationBarTransition) 里的 transitionNavigationBar，为了让这个属性在这里可以被访问到，有点 hack，具体请查看 https://github.com/QMUI/QMUI_iOS/issues/268
@end

@implementation UIViewController (QMUI)

void qmui_loadViewIfNeeded (id current_self, SEL current_cmd) {
    // 主动调用 self.view，从而触发 loadView，以模拟 iOS 9.0 以下的系统 loadViewIfNeeded 行为
    [((UIViewController *)current_self) view];
}

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        // 为 description 增加更丰富的信息
        ExchangeImplementations([UIViewController class], @selector(description), @selector(qmui_description));
        
        // 兼容 iOS 9.0 以下的版本对 loadViewIfNeeded 方法的调用
        if (![[UIViewController class] instancesRespondToSelector:@selector(loadViewIfNeeded)]) {
            Class metaclass = [UIViewController class];
            class_addMethod(metaclass, @selector(loadViewIfNeeded), (IMP)qmui_loadViewIfNeeded, "v@:");
        }
        
        // 修复 iOS 11 scrollView 无法自动适配不透明的 tabBar，导致底部 inset 错误的问题
        // https://github.com/QMUI/QMUI_iOS/issues/218
        if (@available(iOS 11, *)) {
            ExchangeImplementations([UIViewController class], @selector(initWithNibName:bundle:), @selector(qmui_initWithNibName:bundle:));
        }
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

- (instancetype)qmui_initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    [self qmui_initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    BOOL isContainerViewController = [self isKindOfClass:[UINavigationController class]] || [self isKindOfClass:[UITabBarController class]] || [self isKindOfClass:[UISplitViewController class]];
    if (!isContainerViewController) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(adjustsAdditionalSafeAreaInsetsForOpaqueTabBarWithNotification:) name:QMUITabBarStyleChangedNotification object:nil];
    }
    return self;
}

- (void)adjustsAdditionalSafeAreaInsetsForOpaqueTabBarWithNotification:(NSNotification *)notification {
    if (@available(iOS 11, *)) {
        
        BOOL isCurrentTabBar = self.tabBarController && self.navigationController && self.navigationController.qmui_rootViewController == self && self.navigationController.parentViewController == self.tabBarController && (notification ? notification.object == self.tabBarController.tabBar : YES);
        if (!isCurrentTabBar) {
            return;
        }
        
        UITabBar *tabBar = self.tabBarController.tabBar;
        
        // 这串判断条件来源于这个 issue：https://github.com/QMUI/QMUI_iOS/issues/218
        BOOL isOpaqueBarAndCanExtendedLayout = !tabBar.translucent && self.extendedLayoutIncludesOpaqueBars;
        if (!isOpaqueBarAndCanExtendedLayout) {
            return;
        }
        
        BOOL tabBarHidden = tabBar.hidden;
        
        // 这里直接用 CGRectGetHeight(tabBar.frame) 来计算理论上不准确，但因为系统有这个 bug（https://github.com/QMUI/QMUI_iOS/issues/217），所以暂时用 CGRectGetHeight(tabBar.frame) 来代替
        CGFloat correctSafeAreaInsetsBottom = tabBarHidden ? tabBar.safeAreaInsets.bottom : CGRectGetHeight(tabBar.frame);
        CGFloat additionalSafeAreaInsetsBottom = correctSafeAreaInsetsBottom - tabBar.safeAreaInsets.bottom;
        self.additionalSafeAreaInsets = UIEdgeInsetsSetBottom(self.additionalSafeAreaInsets, additionalSafeAreaInsetsBottom);
    }
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
    
    if ([self qmui_isViewLoadedAndVisible]) {
        return self;
    } else {
        QMUILog(@"UIViewController (QMUI)", @"qmui_visibleViewControllerIfExist:，找不到可见的viewController。self = %@, self.view = %@, self.view.window = %@", self, [self isViewLoaded] ? self.view : nil, [self isViewLoaded] ? self.view.window : nil);
        return nil;
    }
}

- (BOOL)qmui_isViewLoadedAndVisible {
    return self.isViewLoaded && self.view.window;
}

- (CGFloat)qmui_navigationBarMaxYInViewCoordinator {
    if (!self.isViewLoaded) {
        return 0;
    }
    
    // 这里为什么要把 transitionNavigationBar 考虑进去，请参考 https://github.com/QMUI/QMUI_iOS/issues/268
    UINavigationBar *navigationBar = !self.navigationController.navigationBarHidden && self.navigationController.navigationBar ? self.navigationController.navigationBar : ([self respondsToSelector:@selector(transitionNavigationBar)] && self.transitionNavigationBar ? self.transitionNavigationBar : nil);
    
    if (!navigationBar) {
        return 0;
    }
    
    CGRect navigationBarFrameInView = [self.view convertRect:navigationBar.frame fromView:navigationBar.superview];
    CGRect navigationBarFrame = CGRectIntersection(self.view.bounds, navigationBarFrameInView);
    
    // 两个 rect 如果不存在交集，CGRectIntersection 计算结果可能为非法的 rect，所以这里做个保护
    if (!CGRectIsValidated(navigationBarFrame)) {
        return 0;
    }
    
    CGFloat result = CGRectGetMaxY(navigationBarFrame);
    return result;
}

- (CGFloat)qmui_toolbarSpacingInViewCoordinator {
    if (!self.isViewLoaded) {
        return 0;
    }
    if (!self.navigationController.toolbar || self.navigationController.toolbarHidden) {
        return 0;
    }
    CGRect toolbarFrame = CGRectIntersection(self.view.bounds, [self.view convertRect:self.navigationController.toolbar.frame fromView:self.navigationController.toolbar.superview]);
    
    // 两个 rect 如果不存在交集，CGRectIntersection 计算结果可能为非法的 rect，所以这里做个保护
    if (!CGRectIsValidated(toolbarFrame)) {
        return 0;
    }
    
    CGFloat result = CGRectGetHeight(self.view.bounds) - CGRectGetMinY(toolbarFrame);
    return result;
}

- (CGFloat)qmui_tabBarSpacingInViewCoordinator {
    if (!self.isViewLoaded) {
        return 0;
    }
    if (!self.tabBarController.tabBar || self.tabBarController.tabBar.hidden) {
        return 0;
    }
    CGRect tabBarFrame = CGRectIntersection(self.view.bounds, [self.view convertRect:self.tabBarController.tabBar.frame fromView:self.tabBarController.tabBar.superview]);
    
    // 两个 rect 如果不存在交集，CGRectIntersection 计算结果可能为非法的 rect，所以这里做个保护
    if (!CGRectIsValidated(tabBarFrame)) {
        return 0;
    }
    
    CGFloat result = CGRectGetHeight(self.view.bounds) - CGRectGetMinY(tabBarFrame);
    return result;
}

@end

@implementation UIViewController (Data)

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        ExchangeImplementations(self.class, @selector(viewDidAppear:), @selector(qmui_viewDidAppear:));
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
- (void)setQmui_didAppearAndLoadDataBlock:(void (^)(void))qmui_didAppearAndLoadDataBlock {
    objc_setAssociatedObject(self, &kAssociatedObjectKey_didAppearAndLoadDataBlock, qmui_didAppearAndLoadDataBlock, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (void (^)(void))qmui_didAppearAndLoadDataBlock {
    return (void (^)(void))objc_getAssociatedObject(self, &kAssociatedObjectKey_didAppearAndLoadDataBlock);
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

@implementation UIViewController (RotateDeviceOrientation)

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        // 实现 AutomaticallyRotateDeviceOrientation 开关的功能
        ExchangeImplementations([UIViewController class], @selector(viewWillAppear:), @selector(rotate_viewWillAppear:));
    });
}

- (void)rotate_viewWillAppear:(BOOL)animated {
    [self rotate_viewWillAppear:animated];
    if (!AutomaticallyRotateDeviceOrientation) {
        return;
    }
    
    // 某些情况下的 UIViewController 不具备决定设备方向的权利，具体请看 https://github.com/QMUI/QMUI_iOS/issues/291
    if (![self qmui_shouldForceRotateDeviceOrientation]) {
        BOOL isRootViewController = [self isViewLoaded] && self.view.window.rootViewController == self;
        BOOL isChildViewController = [self.tabBarController.viewControllers containsObject:self] || [self.navigationController.viewControllers containsObject:self] || [self.splitViewController.viewControllers containsObject:self];
        BOOL hasRightsOfRotateDeviceOrientaion = isRootViewController || isChildViewController;
        if (!hasRightsOfRotateDeviceOrientaion) {
            return;
        }
    }
    
    
    UIInterfaceOrientation statusBarOrientation = [[UIApplication sharedApplication] statusBarOrientation];
    UIDeviceOrientation deviceOrientationBeforeChangingByHelper = [QMUIHelper sharedInstance].orientationBeforeChangingByHelper;
    BOOL shouldConsiderBeforeChanging = deviceOrientationBeforeChangingByHelper != UIDeviceOrientationUnknown;
    UIDeviceOrientation deviceOrientation = [UIDevice currentDevice].orientation;
    
    // 虽然这两者的 unknow 值是相同的，但在启动 App 时可能只有其中一个是 unknown
    if (statusBarOrientation == UIInterfaceOrientationUnknown || deviceOrientation == UIDeviceOrientationUnknown) return;
    
    // 如果当前设备方向和界面支持的方向不一致，则主动进行旋转
    UIDeviceOrientation deviceOrientationToRotate = [self interfaceOrientationMask:self.supportedInterfaceOrientations containsDeviceOrientation:deviceOrientation] ? deviceOrientation : [self deviceOrientationWithInterfaceOrientationMask:self.supportedInterfaceOrientations];
    
    // 之前没用私有接口修改过，那就按最标准的方式去旋转
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

- (BOOL)qmui_shouldForceRotateDeviceOrientation {
    return NO;
}

@end

@implementation QMUIHelper (ViewController)

+ (nullable UIViewController *)visibleViewController {
    UIViewController *rootViewController = [UIApplication sharedApplication].delegate.window.rootViewController;
    UIViewController *visibleViewController = [rootViewController qmui_visibleViewControllerIfExist];
    return visibleViewController;
}

@end

// 为了 UIViewController 适配 iOS 11 下出现不透明的 tabBar 时底部 inset 错误的问题而创建的 Category
// https://github.com/QMUI/QMUI_iOS/issues/218
@interface UITabBar (NavigationController)

@end

@implementation UITabBar (NavigationController)

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (@available(iOS 11, *)) {
            ExchangeImplementations([self class], @selector(setHidden:), @selector(nav_setHidden:));
            ExchangeImplementations([self class], @selector(setBackgroundImage:), @selector(nav_setBackgroundImage:));
            ExchangeImplementations([self class], @selector(setTranslucent:), @selector(nav_setTranslucent:));
            ExchangeImplementations([self class], @selector(setFrame:), @selector(nav_setFrame:));
        }
    });
}

- (void)nav_setHidden:(BOOL)hidden {
    BOOL shouldNotify = self.hidden != hidden;
    [self nav_setHidden:hidden];
    if (shouldNotify) {
        [[NSNotificationCenter defaultCenter] postNotificationName:QMUITabBarStyleChangedNotification object:self];
    }
}

- (void)nav_setBackgroundImage:(UIImage *)backgroundImage {
    BOOL shouldNotify = ![self.backgroundImage isEqual:backgroundImage];
    [self nav_setBackgroundImage:backgroundImage];
    if (shouldNotify) {
        [[NSNotificationCenter defaultCenter] postNotificationName:QMUITabBarStyleChangedNotification object:self];
    }
}

- (void)nav_setTranslucent:(BOOL)translucent {
    BOOL shouldNotify = self.translucent != translucent;
    [self nav_setTranslucent:translucent];
    if (shouldNotify) {
        [[NSNotificationCenter defaultCenter] postNotificationName:QMUITabBarStyleChangedNotification object:self];
    }
}

- (void)nav_setFrame:(CGRect)frame {
    BOOL shouldNotify = CGRectGetMinY(self.frame) != CGRectGetMinY(frame);
    [self nav_setFrame:frame];
    if (shouldNotify) {
        [[NSNotificationCenter defaultCenter] postNotificationName:QMUITabBarStyleChangedNotification object:self];
    }
}

@end
