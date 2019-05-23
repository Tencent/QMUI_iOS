/*****
 * Tencent is pleased to support the open source community by making QMUI_iOS available.
 * Copyright (C) 2016-2019 THL A29 Limited, a Tencent company. All rights reserved.
 * Licensed under the MIT License (the "License"); you may not use this file except in compliance with the License. You may obtain a copy of the License at
 * http://opensource.org/licenses/MIT
 * Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.
 *****/

//
//  UITextField+QMUI.m
//  qmui
//
//  Created by QMUI Team on 2017/3/29.
//

#import "UITextField+QMUI.h"
#import <objc/runtime.h>

@implementation UITextField (QMUI)

- (NSRange)qmui_selectedRange {
    NSInteger location = [self offsetFromPosition:self.beginningOfDocument toPosition:self.selectedTextRange.start];
    NSInteger length = [self offsetFromPosition:self.selectedTextRange.start toPosition:self.selectedTextRange.end];
    return NSMakeRange(location, length);
}

- (UIButton *)qmui_clearButton {
    return [self valueForKey:@"clearButton"];
}

static char kAssociatedObjectKey_clearButtonImage;
- (void)setQmui_clearButtonImage:(UIImage *)qmui_clearButtonImage {
    objc_setAssociatedObject(self, &kAssociatedObjectKey_clearButtonImage, qmui_clearButtonImage, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    [self.qmui_clearButton setImage:qmui_clearButtonImage forState:UIControlStateNormal];
    
    // 如果当前 clearButton 正在显示的时候把自定义图片去掉，需要重新 layout 一次才能让系统默认图片显示出来
    if (!qmui_clearButtonImage) {
        [self setNeedsLayout];
    }
}

- (UIImage *)qmui_clearButtonImage {
    return (UIImage *)objc_getAssociatedObject(self, &kAssociatedObjectKey_clearButtonImage);
}

@end
