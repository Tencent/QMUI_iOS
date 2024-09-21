/**
 * Tencent is pleased to support the open source community by making QMUI_iOS available.
 * Copyright (C) 2016-2021 THL A29 Limited, a Tencent company. All rights reserved.
 * Licensed under the MIT License (the "License"); you may not use this file except in compliance with the License. You may obtain a copy of the License at
 * http://opensource.org/licenses/MIT
 * Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.
 */
//
//  UIMenuController+QMUI.m
//  QMUIKit
//
//  Created by 陈志宏 on 2019/7/21.
//

#import "UIMenuController+QMUI.h"
#import "QMUICore.h"
#import "NSArray+QMUI.h"

@implementation UIMenuController (QMUI)

static UIWindow *kMenuControllerWindow = nil;

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (@available(iOS 16.0, *)) {
            // iOS 16 开始改为用 UIEditMenuInteraction，以前的做法也无效了，所以用 hook 的方式解决
            // https://github.com/Tencent/QMUI_iOS/issues/1538
            
            // UIEditMenuInteraction
            // - (void)presentEditMenuWithConfiguration:(UIEditMenuConfiguration *)configuration;
            OverrideImplementation([UIEditMenuInteraction class], @selector(presentEditMenuWithConfiguration:), ^id(__unsafe_unretained Class originClass, SEL originCMD, IMP (^originalIMPProvider)(void)) {
                return ^(UIEditMenuInteraction *selfObject, UIEditMenuConfiguration *configuration) {
                    
                    // call super
                    void (*originSelectorIMP)(id, SEL, UIEditMenuConfiguration *);
                    originSelectorIMP = (void (*)(id, SEL, UIEditMenuConfiguration *))originalIMPProvider();
                    originSelectorIMP(selfObject, originCMD, configuration);
                    
                    // 走到 present 的时候 window 可能还没构造，所以这里延迟一下再调用
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [UIMenuController qmuimc_handleMenuWillShow];
                    });
                };
            });
            
            OverrideImplementation([UIEditMenuInteraction class], @selector(dismissMenu), ^id(__unsafe_unretained Class originClass, SEL originCMD, IMP (^originalIMPProvider)(void)) {
                return ^(UIEditMenuInteraction *selfObject) {
                    
                    // call super
                    void (*originSelectorIMP)(id, SEL);
                    originSelectorIMP = (void (*)(id, SEL))originalIMPProvider();
                    originSelectorIMP(selfObject, originCMD);
                    
                    [UIMenuController qmuimc_handleMenuWillHide];
                };
            });
            
        } else if (@available(iOS 13.0, *))  {
            // +[UIMenuController sharedMenuController]
            OverrideImplementation(object_getClass([UIMenuController class]), @selector(sharedMenuController), ^id(__unsafe_unretained Class originClass, SEL originCMD, IMP (^originalIMPProvider)(void)) {
                return ^(UIMenuController *selfObject) {
                    
                    // call super
                    UIMenuController *(*originSelectorIMP)(id, SEL);
                    originSelectorIMP = (UIMenuController *(*)(id, SEL))originalIMPProvider();
                    UIMenuController *menuController = originSelectorIMP(selfObject, originCMD);
                    
                    /// 修复 issue：https://github.com/Tencent/QMUI_iOS/issues/659
                    /// UIMenuController 本身就是单例，这里就不考虑释放了
                    if (![menuController qmui_getBoundBOOLForKey:@"kHasAddedNotification"]) {
                        [menuController qmui_bindBOOL:YES forKey:@"kHasAddedNotification"];
                        [NSNotificationCenter.defaultCenter addObserverForName:UIMenuControllerWillShowMenuNotification object:nil queue:NSOperationQueue.mainQueue usingBlock:^(NSNotification * _Nonnull notification) {
                            [UIMenuController qmuimc_handleMenuWillShow];
                        }];
                        [NSNotificationCenter.defaultCenter addObserverForName:UIMenuControllerWillHideMenuNotification object:nil queue:NSOperationQueue.mainQueue usingBlock:^(NSNotification * _Nonnull notification) {
                            [UIMenuController qmuimc_handleMenuWillHide];
                        }];
                    }
                    
                    return menuController;
                };
            });
        }
    });
}

+ (void)qmuimc_handleMenuWillShow {
    UIWindow *window = [UIMenuController qmuimc_menuControllerWindow];
    UIWindow *targetWindow = [UIMenuController qmuimc_firstResponderWindowExceptMainWindow];
    if (window && targetWindow && ![QMUIHelper isKeyboardVisible]) {
        QMUILog(@"UIMenuController", @"show menu - cur window level = %@, origin window level = %@ target window level = %@", @(window.windowLevel), @([window qmui_getBoundLongForKey:@"kOriginalWindowLevel"]), @(targetWindow.windowLevel));
        [window qmui_bindLong:window.windowLevel forKey:@"kOriginalWindowLevel"];
        [window qmui_bindBOOL:YES forKey:@"kWindowLevelChanged"];
        window.windowLevel = targetWindow.windowLevel + 1;
    }
}

+ (void)qmuimc_handleMenuWillHide {
    UIWindow *window = [UIMenuController qmuimc_menuControllerWindow];
    if (window && [window qmui_getBoundBOOLForKey:@"kWindowLevelChanged"]) {
        QMUILog(@"UIMenuController", @"hide menu - cur window level = %@, origin window level = %@", @(window.windowLevel), @([window qmui_getBoundLongForKey:@"kOriginalWindowLevel"]));
        window.windowLevel = [window qmui_getBoundLongForKey:@"kOriginalWindowLevel"];
        [window qmui_bindLong:0 forKey:@"kOriginalWindowLevel"];
        [window qmui_bindBOOL:NO forKey:@"kWindowLevelChanged"];
    }
}

+ (UIWindow *)qmuimc_menuControllerWindow {
    if (kMenuControllerWindow && !kMenuControllerWindow.hidden) {
        return kMenuControllerWindow;
    }
    [UIApplication.sharedApplication.windows enumerateObjectsUsingBlock:^(__kindof UIWindow * _Nonnull window, NSUInteger idx, BOOL * _Nonnull stop) {
        NSString *windowString = [NSString stringWithFormat:@"UI%@%@", @"Text", @"EffectsWindow"];
        if ([window isKindOfClass:NSClassFromString(windowString)] && !window.hidden) {
            if (@available(iOS 16.0, *)) {
                UIView *view = [window.subviews qmui_firstMatchWithBlock:^BOOL(__kindof UIView * _Nonnull item) {
                    return [NSStringFromClass(item.class) isEqualToString:[NSString qmui_stringByConcat:@"_", @"UI", @"EditMenu", @"ContainerView", nil]];
                }];
                if (view) {
                    kMenuControllerWindow = window;
                }
            } else {
                [window.subviews enumerateObjectsUsingBlock:^(__kindof UIView * _Nonnull subview, NSUInteger idx, BOOL * _Nonnull stop) {
                    NSString *targetView = [NSString stringWithFormat:@"UI%@%@", @"Callout", @"Bar"];
                    if ([subview isKindOfClass:NSClassFromString(targetView)]) {
                        kMenuControllerWindow = window;
                        *stop = YES;
                    }
                }];
            }
        }
    }];
    return kMenuControllerWindow;
}

+ (UIWindow *)qmuimc_firstResponderWindowExceptMainWindow {
    __block UIWindow *resultWindow = nil;
    [UIApplication.sharedApplication.windows enumerateObjectsUsingBlock:^(__kindof UIWindow * _Nonnull window, NSUInteger idx, BOOL * _Nonnull stop) {
        if (window != UIApplication.sharedApplication.delegate.window) {
            UIResponder *responder = [UIMenuController qmuimc_findFirstResponderInView:window];
            if (responder) {
                resultWindow = window;
                *stop = YES;
            }
        }
    }];
    return resultWindow;
}

+ (UIResponder *)qmuimc_findFirstResponderInView:(UIView *)view {
    if (view.isFirstResponder) {
        return view;
    }
    for (UIView *subView in view.subviews) {
        id responder = [UIMenuController qmuimc_findFirstResponderInView:subView];
        if (responder) {
            return responder;
        }
    }
    return nil;
}

@end
