/**
 * Tencent is pleased to support the open source community by making QMUI_iOS available.
 * Copyright (C) 2016-2020 THL A29 Limited, a Tencent company. All rights reserved.
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
                NSAssert(numberOfArguments <= 1, @"observer 的 selector 参数超过 1 个");
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
            static BOOL _isOverridedMethodProcessing = NO;
            static UIUserInterfaceStyle qmui_lastNotifiedUserInterfaceStyle;
            qmui_lastNotifiedUserInterfaceStyle = [UITraitCollection currentTraitCollection].userInterfaceStyle;
            
            // 重写 -[UIWindow traitCollection] 会引发 Main Thread Checker 警告，从原理上无法解决，再加上系统本身也是如此，所以这里保持重写的逻辑。注意只有使用了 QMUITheme 组件的项目才有这个问题，不使用则不会重写方法。
            // https://github.com/Tencent/QMUI_iOS/issues/1087
            OverrideImplementation([UIWindow class] , @selector(traitCollection), ^id(__unsafe_unretained Class originClass, SEL originCMD, IMP (^originalIMPProvider)(void)) {
                return ^UITraitCollection *(UIWindow *selfObject) {
                    id (*originSelectorIMP)(id, SEL);
                    originSelectorIMP = (id (*)(id, SEL))originalIMPProvider();
                    UITraitCollection *traitCollection = originSelectorIMP(selfObject, originCMD);
                    
                    if (_isOverridedMethodProcessing || !NSThread.isMainThread) {
                        // +[UITraitCollection currentTraitCollection] 会触发 -[UIWindow traitCollection] 造成递归，这里屏蔽一下
                        return traitCollection;
                    }
                    _isOverridedMethodProcessing = YES;
                    
                    BOOL snapshotFinishedOnBackground = traitCollection.userInterfaceLevel == UIUserInterfaceLevelElevated && UIApplication.sharedApplication.applicationState == UIApplicationStateBackground;
                    // 进入后台且完成截图了就不继续去响应 style 变化（实测 iOS 13.0 iPad 进入后台并完成截图后，仍会多次改变 style，但是系统并没有调用界面的相关刷新方法）
                    if (selfObject.windowScene && !snapshotFinishedOnBackground) {
                        NSPointerArray *windows = [[selfObject windowScene] valueForKeyPath:@"_contextBinder._attachedBindables"];
                        // 系统会按照这个数组的顺序去更新 window 的 traitCollection，找出最先响应样式更新的 window
                        UIWindow *firstValidatedWindow = nil;
                        for (NSUInteger i = 0, count = windows.count; i < count; i++) {
                            UIWindow *window = [windows pointerAtIndex:i];
                            // 由于 Keyboard 可以通过 keyboardAppearance 来控制 userInterfaceStyle 的 Dark/Light，不一定和系统一样，这里要过滤掉
                            if ([window isKindOfClass:NSClassFromString(@"UIRemoteKeyboardWindow")] || [window isKindOfClass:NSClassFromString(@"UITextEffectsWindow")]) {
                                continue;
                            }
                            if (window.overrideUserInterfaceStyle != UIUserInterfaceStyleUnspecified) {
                                // 这里需要获取到和系统样式同步的 UserInterfaceStyle（所以指定 overrideUserInterfaceStyle 需要跳过）
                                continue;
                            }
                            firstValidatedWindow = window;
                            break;
                        }
                        if (selfObject == firstValidatedWindow) {
                            if (qmui_lastNotifiedUserInterfaceStyle != traitCollection.userInterfaceStyle) {
                                qmui_lastNotifiedUserInterfaceStyle = traitCollection.userInterfaceStyle;
                                [self _qmui_notifyUserInterfaceStyleWillChangeEvents:traitCollection];
                            }
                        } else if (!firstValidatedWindow) {
                            // 没有 firstValidatedWindow 只能通过创建一个 window 来判断，这里不用 [UITraitCollection currentTraitCollection] 是因为在 becomeFirstResponder 的过程中，[UITraitCollection currentTraitCollection] 会得到错误的结果。
                            static UIWindow *currentTraitCollectionWindow = nil;
                            if (!currentTraitCollectionWindow) {
                                currentTraitCollectionWindow = [[UIWindow alloc] init];
                            }
                            UITraitCollection *currentTraitCollection = [currentTraitCollectionWindow traitCollection];
                            if (qmui_lastNotifiedUserInterfaceStyle != currentTraitCollection.userInterfaceStyle) {
                                qmui_lastNotifiedUserInterfaceStyle = currentTraitCollection.userInterfaceStyle;
                                [self _qmui_notifyUserInterfaceStyleWillChangeEvents:traitCollection];
                            }
                        }
                    }
                    _isOverridedMethodProcessing = NO;
                    return traitCollection;
                    
                };
            });
        } oncePerIdentifier:@"UITraitCollection addUserInterfaceStyleWillChangeObserver"];
    }
}

@end
