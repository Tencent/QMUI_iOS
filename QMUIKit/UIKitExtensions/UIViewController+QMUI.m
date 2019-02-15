/*****
 * Tencent is pleased to support the open source community by making QMUI_iOS available.
 * Copyright (C) 2016-2019 THL A29 Limited, a Tencent company. All rights reserved.
 * Licensed under the MIT License (the "License"); you may not use this file except in compliance with the License. You may obtain a copy of the License at
 * http://opensource.org/licenses/MIT
 * Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.
 *****/

//
//  UIViewController+QMUI.m
//  qmui
//
//  Created by QMUI Team on 16/1/12.
//

#import "UIViewController+QMUI.h"
#import "UINavigationController+QMUI.h"
#import "QMUICore.h"
#import "UIInterface+QMUI.h"
#import "NSObject+QMUI.h"
#import "QMUILog.h"
#import "UIView+QMUI.h"

NSNotificationName const QMUIAppSizeWillChangeNotification = @"QMUIAppSizeWillChangeNotification";
NSString *const QMUIPrecedingAppSizeUserInfoKey = @"QMUIPrecedingAppSizeUserInfoKey";
NSString *const QMUIFollowingAppSizeUserInfoKey = @"QMUIFollowingAppSizeUserInfoKey";

NSString *const QMUITabBarStyleChangedNotification = @"QMUITabBarStyleChangedNotification";

@interface UIViewController ()

@property(nonatomic, strong) UINavigationBar *transitionNavigationBar;// by molice 对应 UIViewController (NavigationBarTransition) 里的 transitionNavigationBar，为了让这个属性在这里可以被访问到，有点 hack，具体请查看 https://github.com/QMUI/QMUI_iOS/issues/268
@end

@implementation UIViewController (QMUI)

QMUISynthesizeIdCopyProperty(qmui_visibleStateDidChangeBlock, setQmui_visibleStateDidChangeBlock)

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        SEL selectors[] = {
            @selector(description),
            
            @selector(viewDidLoad),
            @selector(viewWillAppear:),
            @selector(viewDidAppear:),
            @selector(viewWillDisappear:),
            @selector(viewDidDisappear:),
            
            @selector(viewWillTransitionToSize:withTransitionCoordinator:)
        };
        for (NSUInteger index = 0; index < sizeof(selectors) / sizeof(SEL); index++) {
            SEL originalSelector = selectors[index];
            SEL swizzledSelector = NSSelectorFromString([@"qmuivc_" stringByAppendingString:NSStringFromSelector(originalSelector)]);
            ExchangeImplementations([self class], originalSelector, swizzledSelector);
        }
        
        // 修复 iOS 11 scrollView 无法自动适配不透明的 tabBar，导致底部 inset 错误的问题
        // https://github.com/QMUI/QMUI_iOS/issues/218
        if (@available(iOS 11, *)) {
            ExchangeImplementations([UIViewController class], @selector(initWithNibName:bundle:), @selector(qmuivc_initWithNibName:bundle:));
        }
    });
}

- (NSString *)qmuivc_description {
    NSString *result = [NSString stringWithFormat:@"%@\nsuperclass:\t\t\t\t%@\ntitle:\t\t\t\t\t%@\nview:\t\t\t\t\t%@", [self qmuivc_description], NSStringFromClass(self.superclass), self.title, [self isViewLoaded] ? self.view : nil];
    
    if ([self isKindOfClass:[UINavigationController class]]) {
        
        UINavigationController *navController = (UINavigationController *)self;
        NSString *navDescription = [NSString stringWithFormat:@"\nviewControllers(%@):\t\t%@\ntopViewController:\t\t%@\nvisibleViewController:\t%@", @(navController.viewControllers.count), [self descriptionWithViewControllers:navController.viewControllers], [navController.topViewController qmuivc_description], [navController.visibleViewController qmuivc_description]];
        result = [result stringByAppendingString:navDescription];
        
    } else if ([self isKindOfClass:[UITabBarController class]]) {
        
        UITabBarController *tabBarController = (UITabBarController *)self;
        NSString *tabBarDescription = [NSString stringWithFormat:@"\nviewControllers(%@):\t\t%@\nselectedViewController(%@):\t%@", @(tabBarController.viewControllers.count), [self descriptionWithViewControllers:tabBarController.viewControllers], @(tabBarController.selectedIndex), [tabBarController.selectedViewController qmuivc_description]];
        result = [result stringByAppendingString:tabBarDescription];
        
    }
    return result;
}

- (NSString *)descriptionWithViewControllers:(NSArray<UIViewController *> *)viewControllers {
    NSMutableString *string = [[NSMutableString alloc] init];
    [string appendString:@"(\n"];
    for (NSInteger i = 0, l = viewControllers.count; i < l; i++) {
        [string appendFormat:@"\t\t\t\t\t\t\t[%@]%@%@\n", @(i), [viewControllers[i] qmuivc_description], i < l - 1 ? @"," : @""];
    }
    [string appendString:@"\t\t\t\t\t\t)"];
    return [string copy];
}

static char kAssociatedObjectKey_visibleState;
- (void)setQmui_visibleState:(QMUIViewControllerVisibleState)qmui_visibleState {
    BOOL valueChanged = self.qmui_visibleState != qmui_visibleState;
    objc_setAssociatedObject(self, &kAssociatedObjectKey_visibleState, @(qmui_visibleState), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    if (valueChanged && self.qmui_visibleStateDidChangeBlock) {
        self.qmui_visibleStateDidChangeBlock(self, qmui_visibleState);
    }
}

- (QMUIViewControllerVisibleState)qmui_visibleState {
    return [((NSNumber *)objc_getAssociatedObject(self, &kAssociatedObjectKey_visibleState)) unsignedIntegerValue];
}

- (void)qmuivc_viewDidLoad {
    [self qmuivc_viewDidLoad];
    self.qmui_visibleState = QMUIViewControllerViewDidLoad;
}

- (void)qmuivc_viewWillAppear:(BOOL)animated {
    [self qmuivc_viewWillAppear:animated];
    self.qmui_visibleState = QMUIViewControllerWillAppear;
}

- (void)qmuivc_viewDidAppear:(BOOL)animated {
    [self qmuivc_viewDidAppear:animated];
    self.qmui_visibleState = QMUIViewControllerDidAppear;
}

- (void)qmuivc_viewWillDisappear:(BOOL)animated {
    [self qmuivc_viewWillDisappear:animated];
    self.qmui_visibleState = QMUIViewControllerWillDisappear;
}

- (void)qmuivc_viewDidDisappear:(BOOL)animated {
    [self qmuivc_viewDidDisappear:animated];
    self.qmui_visibleState = QMUIViewControllerDidDisappear;
}

- (void)qmuivc_viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator {
    if (self == UIApplication.sharedApplication.delegate.window.rootViewController) {
        CGSize originalSize = self.view.frame.size;
        BOOL sizeChanged = !CGSizeEqualToSize(originalSize, size);
        if (sizeChanged) {
            [[NSNotificationCenter defaultCenter] postNotificationName:QMUIAppSizeWillChangeNotification object:nil userInfo:@{QMUIPrecedingAppSizeUserInfoKey: @(originalSize), QMUIFollowingAppSizeUserInfoKey: @(size)}];
        }
    }
    [self qmuivc_viewWillTransitionToSize:size withTransitionCoordinator:coordinator];
}

- (instancetype)qmuivc_initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    [self qmuivc_initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
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
    return self.isViewLoaded && self.view.qmui_visible;
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

- (BOOL)qmui_prefersStatusBarHidden {
    if (self.childViewControllerForStatusBarHidden) {
        return self.childViewControllerForStatusBarHidden.qmui_prefersStatusBarHidden;
    }
    return self.prefersStatusBarHidden;
}

- (UIStatusBarStyle)qmui_preferredStatusBarStyle {
    if (self.childViewControllerForStatusBarStyle) {
        return self.childViewControllerForStatusBarStyle.qmui_preferredStatusBarStyle;
    }
    return self.preferredStatusBarStyle;
}

@end

@implementation UIViewController (Data)

QMUISynthesizeIdCopyProperty(qmui_didAppearAndLoadDataBlock, setQmui_didAppearAndLoadDataBlock)

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        ExchangeImplementations(self.class, @selector(viewDidAppear:), @selector(qmuivcdata_viewDidAppear:));
    });
}

- (void)qmuivcdata_viewDidAppear:(BOOL)animated {
    [self qmuivcdata_viewDidAppear:animated];
    if (self.qmui_didAppearAndLoadDataBlock && self.qmui_dataLoaded) {
        self.qmui_didAppearAndLoadDataBlock();
        self.qmui_didAppearAndLoadDataBlock = nil;
    }
}

static char kAssociatedObjectKey_dataLoaded;
- (void)setQmui_dataLoaded:(BOOL)qmui_dataLoaded {
    objc_setAssociatedObject(self, &kAssociatedObjectKey_dataLoaded, @(qmui_dataLoaded), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    if (self.qmui_didAppearAndLoadDataBlock && qmui_dataLoaded && self.qmui_visibleState >= QMUIViewControllerDidAppear) {
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
    UIDeviceOrientation deviceOrientationToRotate = [QMUIHelper interfaceOrientationMask:self.supportedInterfaceOrientations containsDeviceOrientation:deviceOrientation] ? deviceOrientation : [QMUIHelper deviceOrientationWithInterfaceOrientationMask:self.supportedInterfaceOrientations];
    
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
    deviceOrientationToRotate = [QMUIHelper interfaceOrientationMask:self.supportedInterfaceOrientations containsDeviceOrientation:deviceOrientationBeforeChangingByHelper] ? deviceOrientationBeforeChangingByHelper : [QMUIHelper deviceOrientationWithInterfaceOrientationMask:self.supportedInterfaceOrientations];
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
