/**
 * Tencent is pleased to support the open source community by making QMUI_iOS available.
 * Copyright (C) 2016-2021 THL A29 Limited, a Tencent company. All rights reserved.
 * Licensed under the MIT License (the "License"); you may not use this file except in compliance with the License. You may obtain a copy of the License at
 * http://opensource.org/licenses/MIT
 * Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.
 */

//
//  UIActivityIndicatorView+QMUI.m
//  qmui
//
//  Created by QMUI Team on 15/7/20.
//

#import "UIActivityIndicatorView+QMUI.h"
#import "UIView+QMUI.h"
#import "QMUICore.h"

@interface UIActivityIndicatorView ()
@property(nonatomic, assign) CGSize qmuiai_size;
@end

@implementation UIActivityIndicatorView (QMUI)

QMUISynthesizeCGSizeProperty(qmuiai_size, setQmuiai_size)

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        /**
         系统会在你调用 setFrame: 时把 loading 设置为你希望的 rect，但 sizeToFit 又回去了，所以这里需要通过重写 setFrame: 来记录希望的 size，在 sizeThatFits: 里返回。
         另外内部的 animatingImageView 始终会保持默认大小，所以需要重写 layoutSubviews 让 animatingImageView 可改变尺寸。
         */
        OverrideImplementation([UIActivityIndicatorView class], @selector(setFrame:), ^id(__unsafe_unretained Class originClass, SEL originCMD, IMP (^originalIMPProvider)(void)) {
            return ^(UIActivityIndicatorView *selfObject, CGRect firstArgv) {
                
                // call super
                void (*originSelectorIMP)(id, SEL, CGRect);
                originSelectorIMP = (void (*)(id, SEL, CGRect))originalIMPProvider();
                originSelectorIMP(selfObject, originCMD, firstArgv);
                
                selfObject.qmuiai_size = firstArgv.size;
            };
        });
        
        OverrideImplementation([UIActivityIndicatorView class], @selector(sizeThatFits:), ^id(__unsafe_unretained Class originClass, SEL originCMD, IMP (^originalIMPProvider)(void)) {
            return ^CGSize(UIActivityIndicatorView *selfObject, CGSize firstArgv) {
                if (selfObject.qmuiai_size.width > 0) {
                    return selfObject.qmuiai_size;
                }
                
                // call super
                CGSize (*originSelectorIMP)(id, SEL, CGSize);
                originSelectorIMP = (CGSize (*)(id, SEL, CGSize))originalIMPProvider();
                CGSize result = originSelectorIMP(selfObject, originCMD, firstArgv);
                return result;
            };
        });
        
        OverrideImplementation([UIActivityIndicatorView class], @selector(layoutSubviews), ^id(__unsafe_unretained Class originClass, SEL originCMD, IMP (^originalIMPProvider)(void)) {
            return ^(UIActivityIndicatorView *selfObject) {
                
                // call super
                void (*originSelectorIMP)(id, SEL);
                originSelectorIMP = (void (*)(id, SEL))originalIMPProvider();
                originSelectorIMP(selfObject, originCMD);
                
                if (selfObject.qmuiai_size.width > 0) {
                    selfObject.qmui_animatingView.frame = selfObject.bounds;
                }
            };
        });
    });
}

- (UIImageView *)qmui_animatingView {
    SEL sel = NSSelectorFromString(@"_animatingImageView");
    if ([self respondsToSelector:sel]) {
        BeginIgnorePerformSelectorLeaksWarning
        return [self performSelector:sel];
        EndIgnorePerformSelectorLeaksWarning
    }
    return nil;
}

@end
