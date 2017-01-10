//
//  QMUITabBarViewController.m
//  qmui
//
//  Created by QQMail on 15/3/29.
//  Copyright (c) 2015年 QMUI Team. All rights reserved.
//

#import "QMUITabBarViewController.h"
#import "QMUIConfiguration.h"

@implementation QMUITabBarViewController

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        [self didInitialized];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
        [self didInitialized];
    }
    return self;
}

- (void)didInitialized {
    // UIView.tintColor 并不支持 UIAppearance 协议，所以不能通过 appearance 来设置，只能在实例里设置
    self.tabBar.tintColor = TabBarTintColor;
}

#pragma mark - 屏幕旋转

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation {
    return [self.selectedViewController respondsToSelector:@selector(shouldAutorotateToInterfaceOrientation:)] ? [self.selectedViewController shouldAutorotateToInterfaceOrientation:toInterfaceOrientation] : toInterfaceOrientation == UIInterfaceOrientationPortrait;
}

- (BOOL)shouldAutorotate {
    return [self.selectedViewController respondsToSelector:@selector(shouldAutorotate)] ? [self.selectedViewController shouldAutorotate] : NO;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return [self.selectedViewController respondsToSelector:@selector(supportedInterfaceOrientations)] ? [self.selectedViewController supportedInterfaceOrientations] : UIInterfaceOrientationMaskPortrait;
}

@end
