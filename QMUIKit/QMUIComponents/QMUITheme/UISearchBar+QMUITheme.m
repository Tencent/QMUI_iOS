/*****
 * Tencent is pleased to support the open source community by making QMUI_iOS available.
 * Copyright (C) 2016-2019 THL A29 Limited, a Tencent company. All rights reserved.
 * Licensed under the MIT License (the "License"); you may not use this file except in compliance with the License. You may obtain a copy of the License at
 * http://opensource.org/licenses/MIT
 * Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.
 *****/
//
//  UISearchBar+QMUITheme.m
//  QMUIKit
//
//  Created by ziezheng on 2019/9/7.
//

#import "UISearchBar+QMUI.h"
#import "UISearchBar+QMUITheme.h"
#import "QMUIRuntime.h"
#import "UIColor+QMUI.h"
#import "UIView+QMUITheme.h"
#import "UIImage+QMUI.h"

#import "UIImage+QMUITheme.h"
#import "UIColor+QMUI.h"
#import "QMUIThemePrivate.h"

@interface UISearchBar (QMUITheme_Private)

@property(nonatomic, readonly) NSMutableDictionary <NSString * ,NSInvocation *>*qmuiTheme_invocations;

@end


@implementation UISearchBar (QMUITheme)

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{

        OverrideImplementation([UISearchBar class], @selector(setSearchFieldBackgroundImage:forState:), ^id(__unsafe_unretained Class originClass, SEL originCMD, IMP (^originalIMPProvider)(void)) {
            
            NSMethodSignature *methodSignature = [originClass instanceMethodSignatureForSelector:originCMD];
            
            return ^(UISearchBar *selfObject, UIImage *image, UIControlState state) {
                
                void (*originSelectorIMP)(id, SEL, UIImage *, UIControlState);
                originSelectorIMP = (void (*)(id, SEL, UIImage *, UIControlState))originalIMPProvider();
                
                UIImage *previousImage = [selfObject searchFieldBackgroundImageForState:state];
                if (previousImage.qmui_isDynamicImage || image.qmui_isDynamicImage) {
                    // setSearchFieldBackgroundImage:forState: 的内部实现原理:
                    // 执行后将 image 先存起来，在 layout 时会调用 -[UITextFieldBorderView setImage:] 该方法内部有一个判断：
                    // if (UITextFieldBorderView._image == image) return
                    // 由于 QMUIDynamicImage 随时可能发生图片的改变，这里要绕过这个判断：必须先清空一下 image，并马上调用 layoutIfNeeded 触发 -[UITextFieldBorderView setImage:] 使得 UITextFieldBorderView 内部的 image 清空，这样再设置新的才会生效。
                    originSelectorIMP(selfObject, originCMD, UIImage.new, state);
                    [selfObject.qmui_textField setNeedsLayout];
                    [selfObject.qmui_textField layoutIfNeeded];
                }
                originSelectorIMP(selfObject, originCMD, image, state);
                
                NSInvocation *invocation = nil;
                NSString *invocationActionKey = [NSString stringWithFormat:@"%@-%zd", NSStringFromSelector(originCMD), state];
                if (image.qmui_isDynamicImage) {
                    invocation = [NSInvocation invocationWithMethodSignature:methodSignature];
                    [invocation setSelector:originCMD];
                    [invocation setArgument:&image atIndex:2];
                    [invocation setArgument:&state atIndex:3];
                    [invocation retainArguments];
                }
                selfObject.qmuiTheme_invocations[invocationActionKey] = invocation;
            };
        });
        
    });
}

- (void)_qmui_themeDidChangeByManager:(QMUIThemeManager *)manager identifier:(__kindof NSObject<NSCopying> *)identifier theme:(__kindof NSObject *)theme shouldEnumeratorSubviews:(BOOL)shouldEnumeratorSubviews {
    [super _qmui_themeDidChangeByManager:manager identifier:identifier theme:theme shouldEnumeratorSubviews:shouldEnumeratorSubviews];
    [self qmuiTheme_performUpdateInvocations];
}

- (void)qmuiTheme_performUpdateInvocations {
    [[self.qmuiTheme_invocations allValues] enumerateObjectsUsingBlock:^(NSInvocation * _Nonnull invocation, NSUInteger idx, BOOL * _Nonnull stop) {
        [invocation setTarget:self];
        [invocation invoke];
    }];
}


- (NSMutableDictionary *)qmuiTheme_invocations {
    NSMutableDictionary *qmuiTheme_invocations = objc_getAssociatedObject(self, _cmd);
    if (!qmuiTheme_invocations) {
        qmuiTheme_invocations = [NSMutableDictionary dictionary];
        objc_setAssociatedObject(self, _cmd, qmuiTheme_invocations, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    return qmuiTheme_invocations;
}

@end
