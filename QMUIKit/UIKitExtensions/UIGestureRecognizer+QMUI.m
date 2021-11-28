/**
 * Tencent is pleased to support the open source community by making QMUI_iOS available.
 * Copyright (C) 2016-2021 THL A29 Limited, a Tencent company. All rights reserved.
 * Licensed under the MIT License (the "License"); you may not use this file except in compliance with the License. You may obtain a copy of the License at
 * http://opensource.org/licenses/MIT
 * Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.
 */

//
//  UIGestureRecognizer+QMUI.m
//  qmui
//
//  Created by QMUI Team on 2017/8/21.
//

#import "UIGestureRecognizer+QMUI.h"
#import "QMUICore.h"

@implementation UIGestureRecognizer (QMUI)

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        OverrideImplementation([UIGestureRecognizer class], @selector(setEnabled:), ^id(__unsafe_unretained Class originClass, SEL originCMD, IMP (^originalIMPProvider)(void)) {
            return ^(UIGestureRecognizer *selfObject, BOOL firstArgv) {
                
                // 检测常见的错误，例如在 viewWillAppear: 里把系统手势返回禁用，会导致从下一个界面手势返回到当前界面的瞬间，手势返回无效，界面处于混乱状态，无法接受任何点击事件
                // _UIParallaxTransitionPanGestureRecognizer
                if ([NSStringFromClass(selfObject.class) containsString:@"_UIParallaxTransition"] && selfObject.enabled && !firstArgv && (selfObject.state == UIGestureRecognizerStateBegan || selfObject.state == UIGestureRecognizerStateChanged)) {
                    QMUIAssert(NO, @"UIGestureRecognizer (QMUI)", @"在手势进行过程中把手势禁用，可能让界面状态出现错乱！");
                }
                
                // call super
                void (*originSelectorIMP)(id, SEL, BOOL);
                originSelectorIMP = (void (*)(id, SEL, BOOL))originalIMPProvider();
                originSelectorIMP(selfObject, originCMD, firstArgv);
            };
        });
    });
}

- (nullable UIView *)qmui_targetView {
    CGPoint location = [self locationInView:self.view];
    UIView *targetView = [self.view hitTest:location withEvent:nil];
    return targetView;
}

@end
