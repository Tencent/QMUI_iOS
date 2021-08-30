/**
 * Tencent is pleased to support the open source community by making QMUI_iOS available.
 * Copyright (C) 2016-2021 THL A29 Limited, a Tencent company. All rights reserved.
 * Licensed under the MIT License (the "License"); you may not use this file except in compliance with the License. You may obtain a copy of the License at
 * http://opensource.org/licenses/MIT
 * Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.
 */
//
//  UIApplication+QMUI.m
//  QMUIKit
//
//  Created by MoLice on 2021/8/30.
//

#import "UIApplication+QMUI.h"
#import "QMUICore.h"

@implementation UIApplication (QMUI)

QMUISynthesizeBOOLProperty(qmui_didFinishLaunching, setQmui_didFinishLaunching)

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        OverrideImplementation(object_getClass(UIApplication.class), @selector(sharedApplication), ^id(__unsafe_unretained Class originClass, SEL originCMD, IMP (^originalIMPProvider)(void)) {
            return ^UIApplication *(UIApplication *selfObject) {
                // call super
                UIApplication * (*originSelectorIMP)(id, SEL);
                originSelectorIMP = (UIApplication * (*)(id, SEL))originalIMPProvider();
                UIApplication * result = originSelectorIMP(selfObject, originCMD);
                
                if (![result qmui_getBoundBOOLForKey:@"QMUIAddedObserver"]) {
                    [NSNotificationCenter.defaultCenter addObserver:result selector:@selector(qmui_handleDidFinishLaunchingNotification:) name:UIApplicationDidFinishLaunchingNotification object:nil];
                    [result qmui_bindBOOL:YES forKey:@"QMUIAddedObserver"];
                }
                
                return result;
            };
        });
    });
}

- (void)qmui_handleDidFinishLaunchingNotification:(NSNotification *)notification {
    self.qmui_didFinishLaunching = YES;
    [NSNotificationCenter.defaultCenter removeObserver:self name:UIApplicationDidFinishLaunchingNotification object:nil];
}

@end
