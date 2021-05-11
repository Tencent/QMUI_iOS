/**
 * Tencent is pleased to support the open source community by making QMUI_iOS available.
 * Copyright (C) 2016-2021 THL A29 Limited, a Tencent company. All rights reserved.
 * Licensed under the MIT License (the "License"); you may not use this file except in compliance with the License. You may obtain a copy of the License at
 * http://opensource.org/licenses/MIT
 * Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.
 */
//
//  UITextInputTraits+QMUI.m
//  QMUIKit
//
//  Created by MoLice on 2019/O/16.
//

#import "UITextInputTraits+QMUI.h"
#import "QMUICore.h"

@interface NSObject ()

@property(nonatomic, assign) BOOL qti_didInitialize;
@property(nonatomic, assign) BOOL qti_setKeyboardAppearanceByQMUITheme;
@end

@implementation NSObject (QMUITextInput)

QMUISynthesizeBOOLProperty(qti_didInitialize, setQti_didInitialize)
QMUISynthesizeBOOLProperty(qti_setKeyboardAppearanceByQMUITheme, setQti_setKeyboardAppearanceByQMUITheme)

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        static NSArray<Class> *inputClasses = nil;
        if (!inputClasses) inputClasses = @[UITextField.class, UITextView.class, UISearchBar.class];
        [inputClasses enumerateObjectsUsingBlock:^(Class  _Nonnull inputClass, NSUInteger idx, BOOL * _Nonnull stop) {
            
            ExtendImplementationOfNonVoidMethodWithSingleArgument(inputClass, @selector(initWithFrame:), CGRect, UIView<UITextInputTraits> *, ^UIView<UITextInputTraits> *(UIView<UITextInputTraits> *selfObject, CGRect firstArgv, UIView<UITextInputTraits> *originReturnValue) {
                if ([selfObject isKindOfClass:NSClassFromString(@"TUIEmojiSearchTextField")]) {
                    // https://github.com/Tencent/QMUI_iOS/issues/1042 iOS 14 开始，系统的 emoji 键盘内部有一个搜索框 TUIEmojiSearchTextField，这个搜索框如果在 init 的时候设置 keyboardAppearance 会导致再次创建触发死循环，在这里过滤掉它
                    // 另外它属于 emoji 键盘内部的 TextFied，其 keyboardAppearance 应该由业务的 UITextField、UITextView 驱动，因此 QMUI 也不应该去干预他
                    return originReturnValue;
                }
                if (QMUICMIActivated) selfObject.keyboardAppearance = KeyboardAppearance;
                selfObject.qti_didInitialize = YES;
                return originReturnValue;
            });
            
            ExtendImplementationOfNonVoidMethodWithSingleArgument(inputClass, @selector(initWithCoder:), NSCoder *, UIView<UITextInputTraits> *, ^UIView<UITextInputTraits> *(UIView<UITextInputTraits> *selfObject, NSCoder *aDecoder, UIView<UITextInputTraits> *originReturnValue) {
                selfObject.qti_didInitialize = YES;
                return originReturnValue;
            });
            
            // 当输入框聚焦并显示了键盘的情况下，keyboardAppearance 发生变化了，立即刷新键盘的外观
            OverrideImplementation(inputClass, @selector(setKeyboardAppearance:), ^id(__unsafe_unretained Class originClass, SEL originCMD, IMP (^originalIMPProvider)(void)) {
                return ^(UIView<UITextInputTraits> *selfObject, UIKeyboardAppearance keyboardAppearance) {

                    BOOL valueChanged = selfObject.keyboardAppearance != keyboardAppearance;
                    
                    // call super
                    void (*originSelectorIMP)(id, SEL, UIKeyboardAppearance);
                    originSelectorIMP = (void (*)(id, SEL, UIKeyboardAppearance))originalIMPProvider();
                    originSelectorIMP(selfObject, originCMD, keyboardAppearance);
                    
                    if (selfObject.qti_didInitialize && valueChanged) {
                        // 标志当前输入框希望有与配置表不一样的值，则在 QMUITheme 发生变化时不要替它自动切换
                        if (QMUICMIActivated && !selfObject.qti_setKeyboardAppearanceByQMUITheme) selfObject.qmui_hasCustomizedKeyboardAppearance = YES;
                        
                        // 是否需要立即刷新外观是不需要考虑当前是否为 isFristResponder 的，因为 reloadInputViews 内部会自行处理
                        [selfObject reloadInputViews];
                    }
                };
            });
        }];
    });
}

@end

@implementation NSObject (QMUITextInput_Private)

QMUISynthesizeBOOLProperty(qmui_hasCustomizedKeyboardAppearance, setQmui_hasCustomizedKeyboardAppearance)

static char kAssociatedObjectKey_keyboardAppearance;
- (void)setQmui_keyboardAppearance:(UIKeyboardAppearance)qmui_keyboardAppearance {
    objc_setAssociatedObject(self, &kAssociatedObjectKey_keyboardAppearance, @(qmui_keyboardAppearance), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    self.qti_setKeyboardAppearanceByQMUITheme = YES;
    ((UIView<UITextInputTraits> *)self).keyboardAppearance = qmui_keyboardAppearance;
    self.qti_setKeyboardAppearanceByQMUITheme = NO;
}

- (UIKeyboardAppearance)qmui_keyboardAppearance {
    return [((NSNumber *)objc_getAssociatedObject(self, &kAssociatedObjectKey_keyboardAppearance)) integerValue];
}

@end
