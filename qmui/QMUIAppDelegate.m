//
//  QMUIAppDelegate.m
//  qmui
//
//  Created by MoLice on 14-6-22.
//  Copyright (c) 2014年 QMUI Team. All rights reserved.
//

#import "QMUIAppDelegate.h"
#import "QMUIViewController.h"
#import "QMUINavigationController.h"

@implementation QMUIAppDelegate

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        // 在QMUI的项目里面启动QMUI的配置，跟外面使用无关。
        [[QMUIConfigurationManager sharedInstance] initDefaultConfiguration];
        
        // 渲染全局样式
        [QMUICommonUI renderGlobalAppearances];
    });
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // statusBar样式初始化
    [QMUIHelper renderStatusBarStyleDark];
    
    // 启动代码
    QMUIViewController *viewController = [[QMUIViewController alloc] init];
    QMUINavigationController *navigationController = [[QMUINavigationController alloc] initWithRootViewController:viewController];
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.rootViewController = navigationController;
    [self.window makeKeyAndVisible];
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
