/**
 * Tencent is pleased to support the open source community by making QMUI_iOS available.
 * Copyright (C) 2016-2021 THL A29 Limited, a Tencent company. All rights reserved.
 * Licensed under the MIT License (the "License"); you may not use this file except in compliance with the License. You may obtain a copy of the License at
 * http://opensource.org/licenses/MIT
 * Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.
 */
//
//  UISwitch+QMUI.m
//  QMUIKit
//
//  Created by MoLice on 2019/7/12.
//

#import "UISwitch+QMUI.h"
#import "QMUICore.h"

@implementation UISwitch (QMUI)

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        ExtendImplementationOfNonVoidMethodWithSingleArgument([UISwitch class], @selector(initWithFrame:), CGRect, UISwitch *, ^UISwitch *(UISwitch *selfObject, CGRect firstArgv, UISwitch *originReturnValue) {
            if (QMUICMIActivated) {
                if (SwitchTintColor) {
                    selfObject.tintColor = SwitchTintColor;
                }
                if (SwitchOffTintColor) {
                    selfObject.qmui_offTintColor = SwitchOffTintColor;
                }
            }
            return originReturnValue;
        });
        
        // 设置 qmui_offTintColor 的原理是找到 UISwitch 内部的 switchWellView 并改变它的 backgroundColor，而 switchWellView 在某些时机会重新创建 ，因此需要在这些时机之后对 switchWellView 重新设置一次背景颜色：
        if (@available(iOS 13.0, *)) {
            ExtendImplementationOfVoidMethodWithSingleArgument([UISwitch class], @selector(traitCollectionDidChange:), UITraitCollection *, ^(UISwitch *selfObject, UITraitCollection *previousTraitCollection) {
                BOOL interfaceStyleChanged = [previousTraitCollection hasDifferentColorAppearanceComparedToTraitCollection:selfObject.traitCollection];
                if (interfaceStyleChanged) {
                    // 在 iOS 13 切换 Dark/Light Mode 之后，会在重新创建 switchWellView，之所以延迟一个 runloop 是因为这个时机是在晚于 traitCollectionDidChange 的 _traitCollectionDidChangeInternal中进行
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [selfObject qmui_applyOffTintColorIfNeeded];
                    });
                }
            });
        } else {
            // iOS 9 - 12 上调用 setOnTintColor: 或 setTintColor: 之后，会在重新创建 switchWellView
            ExtendImplementationOfVoidMethodWithSingleArgument([UISwitch class], @selector(setTintColor:), UIColor *, ^(UISwitch *selfObject, UIColor *firstArgv) {
                [selfObject qmui_applyOffTintColorIfNeeded];
            });
            ExtendImplementationOfVoidMethodWithSingleArgument([UISwitch class], @selector(setOnTintColor:), UIColor *, ^(UISwitch *selfObject, UIColor *firstArgv) {
                [selfObject qmui_applyOffTintColorIfNeeded];
            });

        }
        
    });
}


static char kAssociatedObjectKey_offTintColor;
static NSString * const kDefaultOffTintColorKey = @"defaultOffTintColorKey";

- (void)setQmui_offTintColor:(UIColor *)qmui_offTintColor {
    UIView *switchWellView = [self valueForKeyPath:@"_visualElement._switchWellView"];
    UIColor *defaultOffTintColor = [switchWellView qmui_getBoundObjectForKey:kDefaultOffTintColorKey];
    if (!defaultOffTintColor) {
        defaultOffTintColor = switchWellView.backgroundColor;
        [switchWellView qmui_bindObject:defaultOffTintColor forKey:kDefaultOffTintColorKey];
    }
    // 当 offTintColor 为 nil 时，恢复默认颜色（和 setOnTintColor 行为保持一致）
    switchWellView.backgroundColor = qmui_offTintColor ? : defaultOffTintColor;
    objc_setAssociatedObject(self, &kAssociatedObjectKey_offTintColor, qmui_offTintColor, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (UIColor *)qmui_offTintColor {
    return objc_getAssociatedObject(self, &kAssociatedObjectKey_offTintColor);
}

- (void)qmui_applyOffTintColorIfNeeded {
    if (self.qmui_offTintColor) {
        self.qmui_offTintColor = self.qmui_offTintColor;
    }
}



@end
