/*****
 * Tencent is pleased to support the open source community by making QMUI_iOS available.
 * Copyright (C) 2016-2019 THL A29 Limited, a Tencent company. All rights reserved.
 * Licensed under the MIT License (the "License"); you may not use this file except in compliance with the License. You may obtain a copy of the License at
 * http://opensource.org/licenses/MIT
 * Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.
 *****/
//
//  UITextInputTraits+QMUI.m
//  QMUIKit
//
//  Created by MoLice on 2019/O/16.
//

#import "UITextInputTraits+QMUI.h"
#import "QMUICore.h"

@implementation NSObject (QMUITextInput)

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        static NSArray<Class> *inputClasses = nil;
        if (!inputClasses) inputClasses = @[UITextField.class, UITextView.class, UISearchBar.class];
        [inputClasses enumerateObjectsUsingBlock:^(Class  _Nonnull inputClass, NSUInteger idx, BOOL * _Nonnull stop) {
            
            ExtendImplementationOfNonVoidMethodWithSingleArgument(inputClass, @selector(initWithFrame:), CGRect, UIView<UITextInputTraits> *, ^UIView<UITextInputTraits> *(UIView<UITextInputTraits> *selfObject, CGRect firstArgv, UIView<UITextInputTraits> *originReturnValue) {
                if (QMUICMIActivated) selfObject.keyboardAppearance = KeyboardAppearance;
                return originReturnValue;
            });
            
            // 当输入框聚焦并显示了键盘的情况下，keyboardAppearance 发生变化了，立即刷新键盘的外观
            OverrideImplementation(inputClass, @selector(setKeyboardAppearance:), ^id(__unsafe_unretained Class originClass, SEL originCMD, IMP (^originalIMPProvider)(void)) {
                return ^(UIView<UITextInputTraits> *selfObject, UIKeyboardAppearance keyboardAppearance) {
                    
                    // 这个标志位不需要考虑 isFristResponder，因为 reloadInputViews 内部会自行处理
                    BOOL shouldUpdateImmediately = selfObject.keyboardAppearance != keyboardAppearance;
                    
                    // call super
                    void (*originSelectorIMP)(id, SEL, UIKeyboardAppearance);
                    originSelectorIMP = (void (*)(id, SEL, UIKeyboardAppearance))originalIMPProvider();
                    originSelectorIMP(selfObject, originCMD, keyboardAppearance);
                    
                    if (shouldUpdateImmediately) {
                        [selfObject reloadInputViews];
                    }
                };
            });
        }];
    });
}

@end
