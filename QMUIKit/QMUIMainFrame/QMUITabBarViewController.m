/*****
 * Tencent is pleased to support the open source community by making QMUI_iOS available.
 * Copyright (C) 2016-2019 THL A29 Limited, a Tencent company. All rights reserved.
 * Licensed under the MIT License (the "License"); you may not use this file except in compliance with the License. You may obtain a copy of the License at
 * http://opensource.org/licenses/MIT
 * Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.
 *****/

//
//  QMUITabBarViewController.m
//  qmui
//
//  Created by QMUI Team on 15/3/29.
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

#pragma mark - StatusBar

- (UIViewController *)childViewControllerForStatusBarHidden {
    return self.selectedViewController;
}

- (UIViewController *)childViewControllerForStatusBarStyle {
    return self.selectedViewController;
}

#pragma mark - 屏幕旋转

- (BOOL)shouldAutorotate {
    return self.presentedViewController ? [self.presentedViewController shouldAutorotate] : ([self.selectedViewController qmui_hasOverrideUIKitMethod:_cmd] ? [self.selectedViewController shouldAutorotate] : YES);
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    
    // fix iOS 9 UIAlertController bug: UIAlertController:supportedInterfaceOrientations was invoked recursively!
    // https://github.com/Tencent/QMUI_iOS/issues/502
    UIViewController *presentedViewController = self.presentedViewController;
    if (IOS_VERSION_NUMBER < 100000 && presentedViewController && [presentedViewController isKindOfClass:UIAlertController.class]) {
        presentedViewController = nil;
    }
    
    return presentedViewController ? [presentedViewController supportedInterfaceOrientations] : ([self.selectedViewController qmui_hasOverrideUIKitMethod:_cmd] ? [self.selectedViewController supportedInterfaceOrientations] : SupportedOrientationMask);
}

#pragma mark - HomeIndicator

- (UIViewController *)childViewControllerForHomeIndicatorAutoHidden {
    return self.selectedViewController;
}

@end
