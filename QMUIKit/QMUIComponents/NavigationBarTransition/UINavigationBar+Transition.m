/**
 * Tencent is pleased to support the open source community by making QMUI_iOS available.
 * Copyright (C) 2016-2020 THL A29 Limited, a Tencent company. All rights reserved.
 * Licensed under the MIT License (the "License"); you may not use this file except in compliance with the License. You may obtain a copy of the License at
 * http://opensource.org/licenses/MIT
 * Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.
 */

//
//  QMUINavigationBar+Transition.m
//  qmui
//
//  Created by QMUI Team on 11/25/16.
//

#import "UINavigationBar+Transition.h"
#import "QMUICore.h"

@implementation UINavigationBar (Transition)

QMUISynthesizeIdStrongProperty(transitionNavigationBar, setTransitionNavigationBar)

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        ExtendImplementationOfVoidMethodWithSingleArgument([UINavigationBar class], @selector(setShadowImage:), UIImage *, ^(UINavigationBar *selfObject, UIImage *firstArgv) {
            if (selfObject.transitionNavigationBar) {
                selfObject.transitionNavigationBar.shadowImage = firstArgv;
            }
        });
        
        ExtendImplementationOfVoidMethodWithSingleArgument([UINavigationBar class], @selector(setBarTintColor:), UIColor *, ^(UINavigationBar *selfObject, UIColor *firstArgv) {
            if (selfObject.transitionNavigationBar) {
                selfObject.transitionNavigationBar.barTintColor = firstArgv;
            }
        });
        
        ExtendImplementationOfVoidMethodWithTwoArguments([UINavigationBar class], @selector(setBackgroundImage:forBarMetrics:), UIImage *, UIBarMetrics, ^(UINavigationBar *selfObject, UIImage *backgroundImage, UIBarMetrics barMetrics) {
            if (selfObject.transitionNavigationBar) {
                [selfObject.transitionNavigationBar setBackgroundImage:backgroundImage forBarMetrics:barMetrics];
            }
        });
    });
}

@end
