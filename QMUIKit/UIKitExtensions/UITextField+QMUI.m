/**
 * Tencent is pleased to support the open source community by making QMUI_iOS available.
 * Copyright (C) 2016-2021 THL A29 Limited, a Tencent company. All rights reserved.
 * Licensed under the MIT License (the "License"); you may not use this file except in compliance with the License. You may obtain a copy of the License at
 * http://opensource.org/licenses/MIT
 * Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.
 */

//
//  UITextField+QMUI.m
//  qmui
//
//  Created by QMUI Team on 2017/3/29.
//

#import "UITextField+QMUI.h"
#import "NSObject+QMUI.h"
#import "QMUICore.h"
#import "UIImage+QMUI.h"

@implementation UITextField (QMUI)

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        // iOS 13 及以下版本需要重写该方法才能替换
        // - (id) _clearButtonImageForState:(unsigned long)arg1;
        // https://github.com/Tencent/QMUI_iOS/issues/1477
        if (@available(iOS 14.0, *)) {
        } else {
            OverrideImplementation([UITextField class], NSSelectorFromString(@"_clearButtonImageForState:"), ^id(__unsafe_unretained Class originClass, SEL originCMD, IMP (^originalIMPProvider)(void)) {
                return ^UIImage *(UITextField *selfObject, UIControlState firstArgv) {
                    
                    if (selfObject.qmui_clearButtonImage && (firstArgv & UIControlStateNormal) == UIControlStateNormal) {
                        return selfObject.qmui_clearButtonImage;
                    }
                    
                    // call super
                    UIImage *(*originSelectorIMP)(id, SEL, UIControlState);
                    originSelectorIMP = (UIImage *(*)(id, SEL, UIControlState))originalIMPProvider();
                    UIImage *result = originSelectorIMP(selfObject, originCMD, firstArgv);
                    return result;
                };
            });
        }
    });
}

- (void)setQmui_selectedRange:(NSRange)qmui_selectedRange {
    self.selectedTextRange = [self qmui_convertUITextRangeFromNSRange:qmui_selectedRange];
}

- (NSRange)qmui_selectedRange {
    return [self qmui_convertNSRangeFromUITextRange:self.selectedTextRange];
}

- (UIButton *)qmui_clearButton {
    return [self qmui_valueForKey:@"clearButton"];
}

static char kAssociatedObjectKey_clearButtonImage;
- (void)setQmui_clearButtonImage:(UIImage *)qmui_clearButtonImage {
    objc_setAssociatedObject(self, &kAssociatedObjectKey_clearButtonImage, qmui_clearButtonImage, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    if (@available(iOS 14.0, *)) {
        [self.qmui_clearButton setImage:qmui_clearButtonImage forState:UIControlStateNormal];
        // 如果当前 clearButton 正在显示的时候把自定义图片去掉，需要重新 layout 一次才能让系统默认图片显示出来
        if (!qmui_clearButtonImage) {
            [self setNeedsLayout];
        }
    }
}

- (UIImage *)qmui_clearButtonImage {
    return (UIImage *)objc_getAssociatedObject(self, &kAssociatedObjectKey_clearButtonImage);
}

- (NSRange)qmui_convertNSRangeFromUITextRange:(UITextRange *)textRange {
    NSInteger location = [self offsetFromPosition:self.beginningOfDocument toPosition:textRange.start];
    NSInteger length = [self offsetFromPosition:textRange.start toPosition:textRange.end];
    return NSMakeRange(location, length);
}

- (UITextRange *)qmui_convertUITextRangeFromNSRange:(NSRange)range {
    if (range.location == NSNotFound || NSMaxRange(range) > self.text.length) {
        return nil;
    }
    UITextPosition *beginning = self.beginningOfDocument;
    UITextPosition *startPosition = [self positionFromPosition:beginning offset:range.location];
    UITextPosition *endPosition = [self positionFromPosition:beginning offset:NSMaxRange(range)];
    return [self textRangeFromPosition:startPosition toPosition:endPosition];
}

static char kAssociatedObjectKey_respondsToDeleteActionAtLeading;
- (void)setQmui_respondsToDeleteActionAtLeading:(BOOL)respondsToDeleteActionAtLeading {
    objc_setAssociatedObject(self, &kAssociatedObjectKey_respondsToDeleteActionAtLeading, @(respondsToDeleteActionAtLeading), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    [QMUIHelper executeBlock:^{
        OverrideImplementation([UITextField class], @selector(deleteBackward), ^id(__unsafe_unretained Class originClass, SEL originCMD, IMP (^originalIMPProvider)(void)) {
            return ^(UITextField *selfObject) {

                BOOL deletingAtLeading = NSEqualRanges(selfObject.qmui_selectedRange, NSMakeRange(0, 0));
                if (selfObject.qmui_respondsToDeleteActionAtLeading && deletingAtLeading) {
                    QMUILog(@"UITextField (QMUI)", @"光标已在输入框开头的情况下依然按下删除按键。");
                    if ([selfObject.delegate respondsToSelector:@selector(textField:shouldChangeCharactersInRange:replacementString:)]) {
                        [selfObject.delegate textField:selfObject shouldChangeCharactersInRange:NSMakeRange(0, 0) replacementString:@""];
                    }
                }
                
                // call super
                void (*originSelectorIMP)(id, SEL);
                originSelectorIMP = (void (*)(id, SEL))originalIMPProvider();
                originSelectorIMP(selfObject, originCMD);
            };
        });
    } oncePerIdentifier:@"UITextField (QMUI) delete"];
}

- (BOOL)qmui_respondsToDeleteActionAtLeading {
    return [((NSNumber *)objc_getAssociatedObject(self, &kAssociatedObjectKey_respondsToDeleteActionAtLeading)) boolValue];
}

@end
