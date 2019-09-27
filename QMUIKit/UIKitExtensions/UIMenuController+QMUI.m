/*****
 * Tencent is pleased to support the open source community by making QMUI_iOS available.
 * Copyright (C) 2016-2019 THL A29 Limited, a Tencent company. All rights reserved.
 * Licensed under the MIT License (the "License"); you may not use this file except in compliance with the License. You may obtain a copy of the License at
 * http://opensource.org/licenses/MIT
 * Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.
 *****/
//
//  UIMenuController+QMUI.m
//  QMUIKit
//
//  Created by 陈志宏 on 2019/7/21.
//

#import "UIMenuController+QMUI.h"
#import "QMUICore.h"

@interface UIMenuController ()

@property(nonatomic, assign) NSInteger qmui_originWindowLevel;
@property(nonatomic, assign) BOOL qmui_windowLevelChanged;

@end

@implementation UIMenuController (QMUI)

QMUISynthesizeNSIntegerProperty(qmui_originWindowLevel, setQmui_originWindowLevel);
QMUISynthesizeBOOLProperty(qmui_windowLevelChanged, setQmui_windowLevelChanged);

static UIWindow *kMenuControllerWindow = nil;
static BOOL kHasAddedMenuControllerNotification = NO;

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        OverrideImplementation(object_getClass([UIMenuController class]), @selector(sharedMenuController), ^id(__unsafe_unretained Class originClass, SEL originCMD, IMP (^originalIMPProvider)(void)) {
            return ^(UIMenuController *selfObject) {
                
                // call super
                UIMenuController *(*originSelectorIMP)(id, SEL);
                originSelectorIMP = (UIMenuController *(*)(id, SEL))originalIMPProvider();
                UIMenuController *menuController = originSelectorIMP(selfObject, originCMD);
                
                /// 修复 issue：https://github.com/Tencent/QMUI_iOS/issues/659
                if (@available(iOS 13.0, *)) {
                    if (!kHasAddedMenuControllerNotification) {
                        kHasAddedMenuControllerNotification = YES;
                        [[NSNotificationCenter defaultCenter] addObserver:menuController selector:@selector(handleMenuWillShowNotification:) name:UIMenuControllerWillShowMenuNotification object:nil];
                        [[NSNotificationCenter defaultCenter] addObserver:menuController selector:@selector(handleMenuWillHideNotification:) name:UIMenuControllerWillHideMenuNotification object:nil];
                    }
                }
                
                return menuController;
            };
        });
    });
}

- (void)handleMenuWillShowNotification:(NSNotification *)notification {
    UIWindow *window = [self menuControllerWindow];
    UIWindow *targetWindow = [self windowForFirstResponder];
    if (window && targetWindow && ![QMUIHelper isKeyboardVisible]) {
        QMUILog(NSStringFromClass(self.class), @"show menu - cur window level = %@, origin window level = %@ target window level = %@", @(window.windowLevel), @(self.qmui_originWindowLevel), @(targetWindow.windowLevel));
        self.qmui_windowLevelChanged = YES;
        self.qmui_originWindowLevel = window.windowLevel;
        window.windowLevel = targetWindow.windowLevel + 1;
    }
}

- (void)handleMenuWillHideNotification:(NSNotification *)notification {
    UIWindow *window = [self menuControllerWindow];
    if (window && self.qmui_windowLevelChanged) {
        QMUILog(NSStringFromClass(self.class), @"hide menu - cur window level = %@, origin window level = %@", @(window.windowLevel), @(self.qmui_originWindowLevel));
        window.windowLevel = self.qmui_originWindowLevel;
        self.qmui_originWindowLevel = 0;
        self.qmui_windowLevelChanged = NO;
    }
}

- (UIWindow *)menuControllerWindow {
    if (kMenuControllerWindow && !kMenuControllerWindow.hidden) {
        return kMenuControllerWindow;
    }
    [[UIApplication sharedApplication].windows enumerateObjectsUsingBlock:^(__kindof UIWindow * _Nonnull window, NSUInteger idx, BOOL * _Nonnull stop) {
        NSString *windowString = [NSString stringWithFormat:@"UI%@%@", @"Text", @"EffectsWindow"];
        if ([window isKindOfClass:NSClassFromString(windowString)] && !window.hidden) {
            [window.subviews enumerateObjectsUsingBlock:^(__kindof UIView * _Nonnull subview, NSUInteger idx, BOOL * _Nonnull stop) {
                NSString *targetView = [NSString stringWithFormat:@"UI%@%@", @"Callout", @"Bar"];
                if ([subview isKindOfClass:NSClassFromString(targetView)]) {
                    kMenuControllerWindow = window;
                    *stop = YES;
                }
            }];
        }
    }];
    return kMenuControllerWindow;
}

- (UIWindow *)windowForFirstResponder {
    __block UIWindow *resultWindow = nil;
    [[UIApplication sharedApplication].windows enumerateObjectsUsingBlock:^(__kindof UIWindow * _Nonnull window, NSUInteger idx, BOOL * _Nonnull stop) {
        if (window != [UIApplication sharedApplication].delegate.window) {
            UIResponder *responder = [self findFirstResponderInView:window];
            if (responder) {
                resultWindow = window;
                *stop = YES;
            }
        }
    }];
    return resultWindow;
}

- (UIResponder *)findFirstResponderInView:(UIView *)view {
    if (view.isFirstResponder) {
        return view;
    }
    for (UIView *subView in view.subviews) {
        id responder = [self findFirstResponderInView:subView];
        if (responder) {
            return responder;
        }
    }
    return nil;
}

@end
