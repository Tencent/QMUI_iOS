/*****
 * Tencent is pleased to support the open source community by making QMUI_iOS available.
 * Copyright (C) 2016-2019 THL A29 Limited, a Tencent company. All rights reserved.
 * Licensed under the MIT License (the "License"); you may not use this file except in compliance with the License. You may obtain a copy of the License at
 * http://opensource.org/licenses/MIT
 * Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.
 *****/

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
        
        ExtendImplementationOfNonVoidMethodWithSingleArgument([UIWindow class], @selector(initWithFrame:), CGRect, UIWindow *, ^UIWindow *(UIWindow *selfObject, CGRect frame, UIWindow *originReturnValue) {
            selfObject.qmui_capturesStatusBarAppearance = YES;
            return originReturnValue;
        });
        
        OverrideImplementation([UIWindow class], NSSelectorFromString([NSString stringWithFormat:@"_%@%@%@", @"canAffect", @"StatusBar", @"Appearance"]), ^id(__unsafe_unretained Class originClass, SEL originCMD, IMP (^originalIMPProvider)(void)) {
            return ^BOOL(UIWindow *selfObject) {
                // call super
                BOOL (^callSuperBlock)(void) = ^BOOL{
                    BOOL (*originSelectorIMP)(id, SEL);
                    originSelectorIMP = (BOOL (*)(id, SEL))originalIMPProvider();
                    BOOL result = originSelectorIMP(selfObject, originCMD);
                    return result;
                };
                
                // avoid superclass
                if ([selfObject isKindOfClass:originClass]) {
                    if (selfObject.qmui_capturesStatusBarAppearance) {
                        return callSuperBlock();
                    }
                    return NO;
                }
                
                return callSuperBlock();
            };
        });
    });
}

@end
