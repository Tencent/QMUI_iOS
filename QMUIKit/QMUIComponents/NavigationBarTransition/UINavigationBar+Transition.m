/*****
 * Tencent is pleased to support the open source community by making QMUI_iOS available.
 * Copyright (C) 2016-2019 THL A29 Limited, a Tencent company. All rights reserved.
 * Licensed under the MIT License (the "License"); you may not use this file except in compliance with the License. You may obtain a copy of the License at
 * http://opensource.org/licenses/MIT
 * Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.
 *****/

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
        Class cls = [self class];
        ExchangeImplementations(cls, @selector(setShadowImage:), @selector(NavigationBarTransition_setShadowImage:));
        ExchangeImplementations(cls, @selector(setBarTintColor:), @selector(NavigationBarTransition_setBarTintColor:));
        ExchangeImplementations(cls, @selector(setBackgroundImage:forBarMetrics:), @selector(NavigationBarTransition_setBackgroundImage:forBarMetrics:));
        
    });
}

- (void)NavigationBarTransition_setShadowImage:(UIImage *)image {
    [self NavigationBarTransition_setShadowImage:image];
    if (self.transitionNavigationBar) {
        self.transitionNavigationBar.shadowImage = image;
    }
}


- (void)NavigationBarTransition_setBarTintColor:(UIColor *)tintColor {
    [self NavigationBarTransition_setBarTintColor:tintColor];
    if (self.transitionNavigationBar) {
        self.transitionNavigationBar.barTintColor = self.barTintColor;
    }
}

- (void)NavigationBarTransition_setBackgroundImage:(UIImage *)backgroundImage forBarMetrics:(UIBarMetrics)barMetrics {
    [self NavigationBarTransition_setBackgroundImage:backgroundImage forBarMetrics:barMetrics];
    if (self.transitionNavigationBar) {
        [self.transitionNavigationBar setBackgroundImage:backgroundImage forBarMetrics:barMetrics];
    }
}

@end
