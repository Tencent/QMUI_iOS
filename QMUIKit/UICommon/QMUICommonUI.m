//
//  QMUICommonUI.m
//  qmui
//
//  Created by QQMail on 14-6-23.
//  Copyright (c) 2014年 QMUI Team. All rights reserved.
//

#import "QMUICommonUI.h"
#import "QMUICommonDefines.h"
#import "QMUIConfiguration.h"
#import "QMUITabBarViewController.h"
#import "QMUIHelper.h"
#import "QMUIButton.h"
#import "UIImage+QMUI.h"

@implementation QMUICommonUI

+ (void)renderGlobalAppearances {
    
    // QMUIButton
    [QMUINavigationButton renderNavigationButtonAppearanceStyle];
    [QMUIToolbarButton renderToolbarButtonAppearanceStyle];

    // UINavigationBar
    UINavigationBar *navigationBarAppearance = [UINavigationBar appearance];
    [navigationBarAppearance setBarTintColor:NavBarBarTintColor];
    [navigationBarAppearance setBackgroundImage:NavBarBackgroundImage forBarMetrics:UIBarMetricsDefault];
    [navigationBarAppearance setShadowImage:NavBarShadowImage];
    
    // UIToolBar
    UIToolbar *toolBarAppearance = [UIToolbar appearance];
    [toolBarAppearance setBarTintColor:ToolBarBarTintColor];
    [toolBarAppearance setBackgroundImage:ToolBarBackgroundImage forToolbarPosition:UIBarPositionAny barMetrics:UIBarMetricsDefault];
    [toolBarAppearance setShadowImage:[UIImage imageWithColor:ToolBarShadowImageColor size:CGSizeMake(1, PixelOne) cornerRadius:0] forToolbarPosition:UIBarPositionAny];
    
    // UITabBar
    UITabBar *tabBarAppearance = [UITabBar appearance];
    [tabBarAppearance setBarTintColor:TabBarBarTintColor];
    [tabBarAppearance setBackgroundImage:TabBarBackgroundImage];
    [tabBarAppearance setShadowImage:[UIImage imageWithColor:TabBarShadowImageColor size:CGSizeMake(1, PixelOne) cornerRadius:0]];
    
    
    // UITabBarItem
    UITabBarItem *tabBarItemAppearance = [UITabBarItem appearanceWhenContainedIn:[QMUITabBarViewController class], nil];
    [tabBarItemAppearance setTitleTextAttributes:@{NSForegroundColorAttributeName:TabBarItemTitleColor} forState:UIControlStateNormal];
    [tabBarItemAppearance setTitleTextAttributes:@{NSForegroundColorAttributeName:TabBarItemTitleColorSelected} forState:UIControlStateSelected];

    
}

@end
