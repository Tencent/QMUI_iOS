/**
 * Tencent is pleased to support the open source community by making QMUI_iOS available.
 * Copyright (C) 2016-2021 THL A29 Limited, a Tencent company. All rights reserved.
 * Licensed under the MIT License (the "License"); you may not use this file except in compliance with the License. You may obtain a copy of the License at
 * http://opensource.org/licenses/MIT
 * Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.
 */
//
//  UITraitCollection+QMUI.m
//  QMUIKit
//
//  Created by ziezheng on 2019/7/19.
//

#import "UITraitCollection+QMUI.h"
#import "QMUICore.h"
#import <dlfcn.h>

@implementation UITraitCollection (QMUI)

static NSHashTable *_eventObservers;
static NSString * const kQMUIUserInterfaceStyleWillChangeSelectorsKey = @"qmui_userInterfaceStyleWillChangeObserver";

+ (void)qmui_addUserInterfaceStyleWillChangeObserver:(id)observer selector:(SEL)aSelector {
    if (@available(iOS 13.0, *)) {
        @synchronized (self) {
            [UITraitCollection _qmui_overrideTraitCollectionMethodIfNeeded];
            if (!_eventObservers) {
                _eventObservers = [NSHashTable weakObjectsHashTable];
            }
            NSMutableSet *selectors = [observer qmui_getBoundObjectForKey:kQMUIUserInterfaceStyleWillChangeSelectorsKey];
            if (!selectors) {
                selectors = [NSMutableSet set];
                [observer qmui_bindObject:selectors forKey:kQMUIUserInterfaceStyleWillChangeSelectorsKey];
            }
            [selectors addObject:NSStringFromSelector(aSelector)];
            [_eventObservers addObject:observer];
        }
    }
}

+ (void)_qmui_notifyUserInterfaceStyleWillChangeEvents:(UITraitCollection *)traitCollection {
    NSHashTable *eventObservers = [_eventObservers copy];
    for (id observer in eventObservers) {
        NSMutableSet *selectors = [observer qmui_getBoundObjectForKey:kQMUIUserInterfaceStyleWillChangeSelectorsKey];
        for (NSString *selectorString in selectors) {
            SEL selector = NSSelectorFromString(selectorString);
            if ([observer respondsToSelector:selector]) {
                NSMethodSignature *methodSignature = [observer methodSignatureForSelector:selector];
                NSUInteger numberOfArguments = [methodSignature numberOfArguments] - 2; // 减去 self cmd 隐形参数剩下的参数数量
                QMUIAssert(numberOfArguments <= 1, @"UITraitCollection (QMUI)", @"observer 的 selector 参数超过 1 个");
                BeginIgnorePerformSelectorLeaksWarning
                if (numberOfArguments == 0) {
                    [observer performSelector:selector];
                } else if (numberOfArguments == 1) {
                    [observer performSelector:selector withObject:traitCollection];
                }
                EndIgnorePerformSelectorLeaksWarning
            }
        }
    }
}

+ (void)_qmui_overrideTraitCollectionMethodIfNeeded {
    if (@available(iOS 13.0, *)) {
        [QMUIHelper executeBlock:^{
            static UIUserInterfaceStyle qmui_lastNotifiedUserInterfaceStyle;
            qmui_lastNotifiedUserInterfaceStyle = [UITraitCollection currentTraitCollection].userInterfaceStyle;
            
            // - (void) _willTransitionToTraitCollection:(id)arg1 withTransitionCoordinator:(id)arg2; (0x7fff24711d49)
            OverrideImplementation([UIWindow class], NSSelectorFromString([NSString qmui_stringByConcat:@"_", @"willTransitionToTraitCollection:", @"withTransitionCoordinator:", nil]), ^id(__unsafe_unretained Class originClass, SEL originCMD, IMP (^originalIMPProvider)(void)) {
                return ^(UIWindow *selfObject, UITraitCollection *traitCollection, id <UIViewControllerTransitionCoordinator> coordinator) {
                    
                    // call super
                    void (*originSelectorIMP)(id, SEL, UITraitCollection *, id <UIViewControllerTransitionCoordinator>);
                    originSelectorIMP = (void (*)(id, SEL, UITraitCollection *, id <UIViewControllerTransitionCoordinator>))originalIMPProvider();
                    originSelectorIMP(selfObject, originCMD, traitCollection, coordinator);
                    
                    BOOL snapshotFinishedOnBackground = traitCollection.userInterfaceLevel == UIUserInterfaceLevelElevated && UIApplication.sharedApplication.applicationState == UIApplicationStateBackground;
                    // 进入后台且完成截图了就不继续去响应 style 变化（实测 iOS 13.0 iPad 进入后台并完成截图后，仍会多次改变 style，但是系统并没有调用界面的相关刷新方法）
                    if (selfObject.windowScene && !snapshotFinishedOnBackground) {
                        UIWindow *firstValidatedWindow = nil;
                        
                        if ([NSStringFromClass(selfObject.class) containsString:@"_UIWindowSceneUserInterfaceStyle"]) { // _UIWindowSceneUserInterfaceStyleAnimationSnapshotWindow
                            firstValidatedWindow = selfObject;
                        } else {
                            // 系统会按照这个数组的顺序去更新 window 的 traitCollection，找出最先响应样式更新的 window
                            NSPointerArray *windows = [[selfObject windowScene] valueForKeyPath:@"_contextBinder._attachedBindables"];
                            for (NSUInteger i = 0, count = windows.count; i < count; i++) {
                                UIWindow *window = [windows pointerAtIndex:i];
                                // 例如用 UIWindow 方式显示的弹窗，在消失后，在 windows 数组里会残留一个 nil 的位置，这里过滤掉，否则会导致 App 从桌面唤醒时无法立即显示正确的 style
                                if (!window) {
                                    continue;;
                                }
                                
                                // 由于 Keyboard 可以通过 keyboardAppearance 来控制 userInterfaceStyle 的 Dark/Light，不一定和系统一样，这里要过滤掉
                                if ([window isKindOfClass:NSClassFromString(@"UIRemoteKeyboardWindow")] || [window isKindOfClass:NSClassFromString(@"UITextEffectsWindow")]) {
                                    continue;
                                }
                                if (window.overrideUserInterfaceStyle != UIUserInterfaceStyleUnspecified) {
                                    // 这里需要获取到和系统样式同步的 UserInterfaceStyle（所以指定 overrideUserInterfaceStyle 需要跳过）
                                    // 所以当全部 window.overrideUserInterfaceStyle 都指定为非 UIUserInterfaceStyleUnspecified 时将无法获得当前系统的外观
                                    continue;
                                }
                                firstValidatedWindow = window;
                                break;
                            }
                        }
                        
                        if (selfObject == firstValidatedWindow) {
                            if (qmui_lastNotifiedUserInterfaceStyle != traitCollection.userInterfaceStyle) {
                                qmui_lastNotifiedUserInterfaceStyle = traitCollection.userInterfaceStyle;
                                [self _qmui_notifyUserInterfaceStyleWillChangeEvents:traitCollection];
                            }
                        }
                    }
                };
            });
        } oncePerIdentifier:@"UITraitCollection addUserInterfaceStyleWillChangeObserver"];
    }
}

@end
