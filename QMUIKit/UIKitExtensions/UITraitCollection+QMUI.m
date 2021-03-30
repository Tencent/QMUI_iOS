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


#ifdef DEBUG
static id (*directTraitCollectionIMP)(id, SEL) = NULL;
+ (void)load {
    // 以下代码只会在 DEBUG 生效，主要是屏蔽 Main Thread Checker 对 QMUI swizzle traitCollection 的检测
    // iOS 14 首次弹起键盘，UIKit 内部会在在子线程访问 -[UIWindow traitCollection]，该方法一旦被 swizzle，Main Thread Checker 就会误判为业务在子线程主动调用 UIKit 方法从而引发卡顿和警告。 https://github.com/Tencent/QMUI_iOS/issues/1087
    // Main Thread Checker 的原理是在启动的时候替换相关方法的实现为 Main Thread Checker 自身的 trampoline，触发相关方法时会先在 trampoline 中实现线程检测逻辑并告警，所以这里唯一可行的屏蔽方法就是获取原始的 IMP 实现，并直接调用从而绕过 Main Thread Checker, 由于 QMUI 在 +load 到时候已经晚于这个时机，无法获取原始的实现方法，观察发现 -[UIWindow traitCollection] 内部会调用 -[UIWindow _updateWindowTraitsAndNotify:]，因此可以借助该方法回溯到 traitCollection 的真实地址。
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (qmui_exists_dyld_image("libMainThreadChecker.dylib")) {
            OverrideImplementation([UIWindow class] , NSSelectorFromString(@"_updateWindowTraitsAndNotify:"), ^id(__unsafe_unretained Class originClass, SEL originCMD, IMP (^originalIMPProvider)(void)) {
                return ^void(UIWindow *selfObject, BOOL arg1) {
                    if (directTraitCollectionIMP == NULL) {
                        NSArray *address = [NSThread callStackReturnAddresses];
                        Dl_info info;
                        dladdr((void *)[address[1] longLongValue], &info);
                        if (strncmp(info.dli_sname, "-[UIWindow traitCollection]", 27) == 0) {
                            directTraitCollectionIMP = info.dli_saddr;
                        }
                    }
                    id (*originSelectorIMP)(id, SEL, BOOL arg1);
                    originSelectorIMP = (id (*)(id, SEL, BOOL))originalIMPProvider();
                    originSelectorIMP(selfObject, originCMD, arg1);
                };
            });
        }
    });
}
#endif


+ (void)_qmui_overrideTraitCollectionMethodIfNeeded {
    if (@available(iOS 13.0, *)) {
        [QMUIHelper executeBlock:^{
            static BOOL _isOverridedMethodProcessing = NO;
            static UIUserInterfaceStyle qmui_lastNotifiedUserInterfaceStyle;
            qmui_lastNotifiedUserInterfaceStyle = [UITraitCollection currentTraitCollection].userInterfaceStyle;
            OverrideImplementation([UIWindow class] , @selector(traitCollection), ^id(__unsafe_unretained Class originClass, SEL originCMD, IMP (^originalIMPProvider)(void)) {
                return ^UITraitCollection *(UIWindow *selfObject) {
                    id (*originSelectorIMP)(id, SEL);
#ifdef DEBUG
                    originSelectorIMP = directTraitCollectionIMP ? : (id (*)(id, SEL))originalIMPProvider();
#else
                    originSelectorIMP = (id (*)(id, SEL))originalIMPProvider();
#endif
                    UITraitCollection *traitCollection = originSelectorIMP(selfObject, originCMD);
                    if (_isOverridedMethodProcessing || !NSThread.isMainThread) {
                        // 防止业务在接收到通知后，再次触发 traitCollection 造成递归
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
                            // 没有 firstValidatedWindow 有以下方法来拿到当前的外观：
                            // 1、创建一个 window 来判断，但是发现在某些场景下，traitCollection 会被频繁调用，导致短时间内创建大量 window 造成性能下降。
                            // 2、 [UITraitCollection currentTraitCollection] 但是 becomeFirstResponder 的过程中该会得到错误的结果。
                            // 终上，这种情况暂时不处理，因此当全部 window.overrideUserInterfaceStyle 都指定为非 UIUserInterfaceStyleUnspecified 的值，将无法获得当前系统的外观。
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
