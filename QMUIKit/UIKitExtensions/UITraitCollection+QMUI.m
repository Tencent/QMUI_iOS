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
#import "UIApplication+QMUI.h"

@implementation UITraitCollection (QMUI)

static NSHashTable *_eventObservers;
static NSString * const kQMUIUserInterfaceStyleWillChangeSelectorsKey = @"qmui_userInterfaceStyleWillChangeObserver";

+ (void)qmui_addUserInterfaceStyleWillChangeObserver:(id)observer selector:(SEL)aSelector {
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

+ (void)_qmui_setUserInterfaceStyleForTraitCollection:(UITraitCollection *)traitCollection {
    static UIUserInterfaceStyle currentUserInterfaceStyle = UIUserInterfaceStyleUnspecified;
    if (currentUserInterfaceStyle == traitCollection.userInterfaceStyle) {
        return;
    }
    currentUserInterfaceStyle = traitCollection.userInterfaceStyle;
    
    [self _qmui_notifyUserInterfaceStyleWillChangeEvents:traitCollection];
}

+ (void)_qmui_overrideTraitCollectionMethodIfNeeded {
    [QMUIHelper executeBlock:^{
        /// https://github.com/Tencent/QMUI_iOS/issues/1634
        if (QMUIHelper.isMac) {
            NSString *willChangeTraitCollection = [NSString qmui_stringByConcat:@"_", @"setDefault", @"TraitCollection:", nil];
            OverrideImplementation([UIScreen class], NSSelectorFromString(willChangeTraitCollection), ^id(__unsafe_unretained Class originClass, SEL originCMD, IMP (^originalIMPProvider)(void)) {
                return ^(UIScreen *selfObject, UITraitCollection *traitCollection) {
                    
                    if (selfObject == UIScreen.mainScreen) {
                        [UITraitCollection _qmui_setUserInterfaceStyleForTraitCollection:traitCollection];
                    }
                    
                    // call super
                    void (*originSelectorIMP)(id, SEL, UITraitCollection *);
                    originSelectorIMP = (void (*)(id, SEL, UITraitCollection *))originalIMPProvider();
                    originSelectorIMP(selfObject, originCMD, traitCollection);
                };
            });
        } else {
            NSString *willChangeTraitCollection = [NSString qmui_stringByConcat:@"_", @"parent", @"WillTransitionTo", @"TraitCollection:", nil];
            OverrideImplementation([UIWindow class], NSSelectorFromString(willChangeTraitCollection), ^id(__unsafe_unretained Class originClass, SEL originCMD, IMP (^originalIMPProvider)(void)) {
                return ^(UIWindow *selfObject, UITraitCollection *traitCollection) {
                    
                    if (selfObject == UIApplication.sharedApplication.qmui_delegateWindow) {
                        [UITraitCollection _qmui_setUserInterfaceStyleForTraitCollection:traitCollection];
                    }
                    
                    // call super
                    void (*originSelectorIMP)(id, SEL, UITraitCollection *);
                    originSelectorIMP = (void (*)(id, SEL, UITraitCollection *))originalIMPProvider();
                    originSelectorIMP(selfObject, originCMD, traitCollection);
                };
            });
        }
    } oncePerIdentifier:@"UITraitCollection addUserInterfaceStyleWillChangeObserver"];
}

@end
