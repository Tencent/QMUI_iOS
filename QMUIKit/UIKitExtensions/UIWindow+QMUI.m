/**
 * Tencent is pleased to support the open source community by making QMUI_iOS available.
 * Copyright (C) 2016-2021 THL A29 Limited, a Tencent company. All rights reserved.
 * Licensed under the MIT License (the "License"); you may not use this file except in compliance with the License. You may obtain a copy of the License at
 * http://opensource.org/licenses/MIT
 * Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.
 */

//
//  UIWindow+QMUI.m
//  qmui
//
//  Created by QMUI Team on 16/7/21.
//

#import "UIWindow+QMUI.h"
#import "QMUICore.h"

@implementation UIWindow (QMUI)

QMUISynthesizeBOOLProperty(qmui_capturesStatusBarAppearance, setQmui_capturesStatusBarAppearance)

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        // -[UIWindow initWithFrame:]
        ExtendImplementationOfNonVoidMethodWithSingleArgument([UIWindow class], @selector(initWithFrame:), CGRect, UIWindow *, ^UIWindow *(UIWindow *selfObject, CGRect frame, UIWindow *originReturnValue) {
            selfObject.qmui_capturesStatusBarAppearance = YES;
            return originReturnValue;
        });

        // -[UIWindow initWithWindowScene:]
        ExtendImplementationOfNonVoidMethodWithSingleArgument([UIWindow class], @selector(initWithWindowScene:), UIWindowScene *, UIWindow *, ^UIWindow *(UIWindow *selfObject, UIWindowScene *windowScene, UIWindow *originReturnValue) {
            selfObject.qmui_capturesStatusBarAppearance = YES;
            return originReturnValue;
        });
        
        // -[UIWindow _canAffectStatusBarAppearance]
        OverrideImplementation([UIWindow class], NSSelectorFromString([NSString stringWithFormat:@"_%@%@%@", @"canAffect", @"StatusBar", @"Appearance"]), ^id(__unsafe_unretained Class originClass, SEL originCMD, IMP (^originalIMPProvider)(void)) {
            return ^BOOL(UIWindow *selfObject) {
                
                if (selfObject.qmui_capturesStatusBarAppearance) {
                    // call super
                    BOOL (*originSelectorIMP)(id, SEL);
                    originSelectorIMP = (BOOL (*)(id, SEL))originalIMPProvider();
                    BOOL result = originSelectorIMP(selfObject, originCMD);
                    return result;
                }
                
                return NO;
            };
        });
    });
}

static char kAssociatedObjectKey_canBecomeKeyWindow;
- (void)setQmui_canBecomeKeyWindow:(BOOL)qmui_canBecomeKeyWindow {
    [self qmuiw_hookIfNeeded];
    objc_setAssociatedObject(self, &kAssociatedObjectKey_canBecomeKeyWindow, @(qmui_canBecomeKeyWindow), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (BOOL)qmui_canBecomeKeyWindow {
    NSNumber *value = objc_getAssociatedObject(self, &kAssociatedObjectKey_canBecomeKeyWindow);
    if (!value) {
        return YES;
    }
    return value.boolValue;
}

static char kAssociatedObjectKey_canResignKeyWindowBlock;
- (void)setQmui_canResignKeyWindowBlock:(BOOL (^)(UIWindow *, UIWindow *))qmui_canResignKeyWindowBlock {
    [self qmuiw_hookIfNeeded];
    objc_setAssociatedObject(self, &kAssociatedObjectKey_canResignKeyWindowBlock, qmui_canResignKeyWindowBlock, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (BOOL (^)(UIWindow *, UIWindow *))qmui_canResignKeyWindowBlock {
    return (BOOL (^)(UIWindow *, UIWindow *))objc_getAssociatedObject(self, &kAssociatedObjectKey_canResignKeyWindowBlock);
}

- (void)qmuiw_hookIfNeeded {
    [QMUIHelper executeBlock:^{
        // - [UIWindow canBecomeKeyWindow]
        SEL sel1 = @selector(canBecomeKeyWindow);
        // - [UIWindow _canBecomeKeyWindow]
        SEL sel2 = NSSelectorFromString([NSString stringWithFormat:@"_%@", NSStringFromSelector(sel1)]);
        SEL sel = [self respondsToSelector:sel1] ? sel1 : ([self respondsToSelector:sel2] ? sel2 : nil);
        if (sel) {
            OverrideImplementation([UIWindow class], sel, ^id(__unsafe_unretained Class originClass, SEL originCMD, IMP (^originalIMPProvider)(void)) {
                return ^BOOL(UIWindow *selfObject) {
                    // call super
                    BOOL (*originSelectorIMP)(id, SEL);
                    originSelectorIMP = (BOOL (*)(id, SEL))originalIMPProvider();
                    BOOL result = originSelectorIMP(selfObject, originCMD);
                    
                    BOOL hasSet = !!objc_getAssociatedObject(selfObject, &kAssociatedObjectKey_canBecomeKeyWindow);
                    if (hasSet) {
                        result = selfObject.qmui_canBecomeKeyWindow;
                    }
                    
                    BeginIgnoreDeprecatedWarning
                    UIWindow *keyWindow = UIApplication.sharedApplication.keyWindow;
                    if (result && keyWindow && keyWindow != selfObject && keyWindow.qmui_canResignKeyWindowBlock) {
                        result = keyWindow.qmui_canResignKeyWindowBlock(keyWindow, selfObject);
                    }
                    EndIgnoreDeprecatedWarning
                    
                    return result;
                };
            });
        } else {
            QMUIAssert(NO, @"UIWindow (QMUI)", @"%f 不存在方法 -[UIWindow _canBecomeKeyWindow]", IOS_VERSION);
        }
        
        OverrideImplementation([UIWindow class], @selector(resignKeyWindow), ^id(__unsafe_unretained Class originClass, SEL originCMD, IMP (^originalIMPProvider)(void)) {
            return ^(UIWindow *selfObject) {
                
                if (selfObject.isKeyWindow && selfObject.qmui_canResignKeyWindowBlock && !selfObject.qmui_canResignKeyWindowBlock(selfObject, selfObject)) {
                    return;
                }
                
                // call super
                void (*originSelectorIMP)(id, SEL);
                originSelectorIMP = (void (*)(id, SEL))originalIMPProvider();
                originSelectorIMP(selfObject, originCMD);
            };
        });
    } oncePerIdentifier:@"UIWindow (QMUI) keyWindow"];
}

@end
