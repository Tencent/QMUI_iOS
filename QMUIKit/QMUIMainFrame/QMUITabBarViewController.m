//
//  QMUITabBarViewController.m
//  qmui
//
//  Created by QMUI Team on 15/3/29.
//  Copyright (c) 2015年 QMUI Team. All rights reserved.
//

#import "QMUITabBarViewController.h"
#import "QMUICore.h"
#import "UIViewController+QMUI.h"

@implementation QMUITabBarViewController

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        [self didInitialize];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
        [self didInitialize];
    }
    return self;
}

- (void)didInitialize {
    // UIView.tintColor 并不支持 UIAppearance 协议，所以不能通过 appearance 来设置，只能在实例里设置
    if (QMUICMIActivated) {
        self.tabBar.tintColor = TabBarTintColor;
    }
}

#pragma mark - 屏幕旋转

- (BOOL)shouldAutorotate {
    return [self.selectedViewController qmui_hasOverrideUIKitMethod:_cmd] ? [self.selectedViewController shouldAutorotate] : YES;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return [self.selectedViewController qmui_hasOverrideUIKitMethod:_cmd] ? [self.selectedViewController supportedInterfaceOrientations] : SupportedOrientationMask;
}

#pragma mark - HomeIndicator

- (UIViewController *)childViewControllerForHomeIndicatorAutoHidden {
    return self.selectedViewController;
}

- (BOOL)prefersHomeIndicatorAutoHidden {
    return NO;
}

@end
