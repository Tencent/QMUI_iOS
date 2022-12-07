/**
 * Tencent is pleased to support the open source community by making QMUI_iOS available.
 * Copyright (C) 2016-2021 THL A29 Limited, a Tencent company. All rights reserved.
 * Licensed under the MIT License (the "License"); you may not use this file except in compliance with the License. You may obtain a copy of the License at
 * http://opensource.org/licenses/MIT
 * Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.
 */

//
//  UIInterface+QMUI.m
//  QMUIKit
//
//  Created by QMUI Team on 2018/12/20.
//

#import "UIInterface+QMUI.h"
#import "QMUICore.h"

@implementation QMUIHelper (QMUI_Interface)

QMUISynthesizeNSIntegerProperty(lastOrientationChangedByHelper, setLastOrientationChangedByHelper)

- (void)handleDeviceOrientationNotification:(NSNotification *)notification {
    // 如果是由 setValue:forKey: 方式修改方向而走到这个 notification 的话，理论上是不需要重置为 Unknown 的，但因为在 UIViewController (QMUI) 那边会再次记录旋转前的值，所以这里就算重置也无所谓
    [QMUIHelper sharedInstance].lastOrientationChangedByHelper = UIDeviceOrientationUnknown;
}

+ (UIDeviceOrientation)deviceOrientationWithInterfaceOrientationMask:(UIInterfaceOrientationMask)mask {
    if (UIDevice.currentDevice.orientation == UIDeviceOrientationUnknown) return UIDeviceOrientationUnknown;
    
    // mask 包含多个方向值，如果要转换的 mask 方向已经包含当前设备方向，则直接返回当前设备方向，以免外面要用这个返回值去做方向旋转时出现不必要的旋转。
    UIInterfaceOrientationMask orientation = 1 << (UIInterfaceOrientation)UIDevice.currentDevice.orientation;
    if (mask & orientation) {
        return UIDevice.currentDevice.orientation;
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

+ (BOOL)interfaceOrientationMask:(UIInterfaceOrientationMask)mask containsDeviceOrientation:(UIDeviceOrientation)deviceOrientation {
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

+ (BOOL)interfaceOrientationMask:(UIInterfaceOrientationMask)mask containsInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return [self interfaceOrientationMask:mask containsDeviceOrientation:(UIDeviceOrientation)interfaceOrientation];
}

+ (CGFloat)angleForTransformWithInterfaceOrientation:(UIInterfaceOrientation)orientation {
    CGFloat angle;
    switch (orientation)
    {
        case UIInterfaceOrientationPortraitUpsideDown:
            angle = M_PI;
            break;
        case UIInterfaceOrientationLandscapeLeft:
            angle = -M_PI_2;
            break;
        case UIInterfaceOrientationLandscapeRight:
            angle = M_PI_2;
            break;
        default:
            angle = 0.0;
            break;
    }
    return angle;
}

+ (CGAffineTransform)transformForCurrentInterfaceOrientation {
    return [QMUIHelper transformWithInterfaceOrientation:UIApplication.sharedApplication.statusBarOrientation];
}

+ (CGAffineTransform)transformWithInterfaceOrientation:(UIInterfaceOrientation)orientation {
    CGFloat angle = [QMUIHelper angleForTransformWithInterfaceOrientation:orientation];
    return CGAffineTransformMakeRotation(angle);
}
@end

@implementation UIViewController (QMUI_Interface)

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        // iOS 16 及以后，系统会在界面切换时自动旋转设备方向，所以不需要以下逻辑。
        if (@available(iOS 16.0, *)) return;

        // 实现 AutomaticallyRotateDeviceOrientation 开关的功能
        OverrideImplementation([UIViewController class], @selector(viewWillAppear:), ^id(__unsafe_unretained Class originClass, SEL originCMD, IMP (^originalIMPProvider)(void)) {
            return ^(UIViewController *selfObject, BOOL animated) {
                
                // call super
                void (*originSelectorIMP)(id, SEL, BOOL);
                originSelectorIMP = (void (*)(id, SEL, BOOL))originalIMPProvider();
                originSelectorIMP(selfObject, originCMD, animated);
                
                if (!AutomaticallyRotateDeviceOrientation) {
                    return;
                }
                
                // 某些情况下的 UIViewController 不具备决定设备方向的权利，具体请看 https://github.com/Tencent/QMUI_iOS/issues/291
                if (![selfObject qmui_shouldForceRotateDeviceOrientation]) {
                    BOOL isRootViewController = [selfObject isViewLoaded] && selfObject.view.window.rootViewController == selfObject;
                    BOOL isChildViewController = [selfObject.tabBarController.viewControllers containsObject:selfObject] || [selfObject.navigationController.viewControllers containsObject:selfObject] || [selfObject.splitViewController.viewControllers containsObject:selfObject];
                    BOOL hasRightsOfRotateDeviceOrientaion = isRootViewController || isChildViewController;
                    if (!hasRightsOfRotateDeviceOrientaion) {
                        return;
                    }
                }
                
                
                UIInterfaceOrientation statusBarOrientation = UIApplication.sharedApplication.statusBarOrientation;
                UIDeviceOrientation lastOrientationChangedByHelper = [QMUIHelper sharedInstance].lastOrientationChangedByHelper;
                BOOL shouldConsiderLastChanged = lastOrientationChangedByHelper != UIDeviceOrientationUnknown;
                UIDeviceOrientation deviceOrientation = [UIDevice currentDevice].orientation;
                
                // 虽然这两者的 unknow 值是相同的，但在启动 App 时可能只有其中一个是 unknown
                if (statusBarOrientation == UIInterfaceOrientationUnknown || deviceOrientation == UIDeviceOrientationUnknown) return;
                
                // 之前没用私有接口修改过，那就按最标准的方式去旋转
                if (!shouldConsiderLastChanged) {
                    // 如果当前设备方向和界面支持的方向不一致，则主动进行旋转
                    UIDeviceOrientation deviceOrientationToRotate = [QMUIHelper interfaceOrientationMask:selfObject.supportedInterfaceOrientations containsDeviceOrientation:deviceOrientation] ? deviceOrientation : [QMUIHelper deviceOrientationWithInterfaceOrientationMask:selfObject.supportedInterfaceOrientations];
                    if ([selfObject qmui_rotateToInterfaceOrientation:(UIInterfaceOrientation)deviceOrientationToRotate]) {
                        [QMUIHelper sharedInstance].lastOrientationChangedByHelper = deviceOrientation;
                    } else {
                        [QMUIHelper sharedInstance].lastOrientationChangedByHelper = UIDeviceOrientationUnknown;
                    }
                    return;
                }
                
                // 用私有接口修改过方向，但下一个界面和当前界面方向不相同，则要把修改前记录下来的那个设备方向考虑进来
                UIDeviceOrientation deviceOrientationToRotate = [QMUIHelper interfaceOrientationMask:selfObject.supportedInterfaceOrientations containsDeviceOrientation:lastOrientationChangedByHelper] ? lastOrientationChangedByHelper : [QMUIHelper deviceOrientationWithInterfaceOrientationMask:selfObject.supportedInterfaceOrientations];
                [selfObject qmui_rotateToInterfaceOrientation:(UIInterfaceOrientation)deviceOrientationToRotate];
            };
        });
    });
}

- (BOOL)qmui_rotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
#ifdef IOS16_SDK_ALLOWED
    if (@available(iOS 16.0, *)) {
        __block BOOL result = YES;
        UIInterfaceOrientationMask mask = 1 << interfaceOrientation;
        UIWindow *window = self.view.window ?: UIApplication.sharedApplication.delegate.window;
        [window.windowScene requestGeometryUpdateWithPreferences:[[UIWindowSceneGeometryPreferencesIOS alloc] initWithInterfaceOrientations:mask] errorHandler:^(NSError * _Nonnull error) {
            if (error) {
                result = NO;
            }
        }];
        return result;
    }
#endif
    
    if ([UIDevice currentDevice].orientation == (UIDeviceOrientation)interfaceOrientation) {
        [UIViewController attemptRotationToDeviceOrientation];
        return NO;
    }
    [[UIDevice currentDevice] setValue:@(interfaceOrientation) forKey:@"orientation"];
    return YES;
}

- (void)qmui_setNeedsUpdateOfSupportedInterfaceOrientations {
#ifdef IOS16_SDK_ALLOWED
    if (@available(iOS 16.0, *)) {
        [self setNeedsUpdateOfSupportedInterfaceOrientations];
    } else
#endif
    {
        UIDeviceOrientation orientation = [QMUIHelper deviceOrientationWithInterfaceOrientationMask:self.supportedInterfaceOrientations];
        [[UIDevice currentDevice] setValue:@(orientation) forKey:@"orientation"];
    }
}

- (BOOL)qmui_shouldForceRotateDeviceOrientation {
    return NO;
}

@end
