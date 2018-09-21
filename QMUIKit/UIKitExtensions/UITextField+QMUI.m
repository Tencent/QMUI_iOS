//
//  UITextField+QMUI.m
//  qmui
//
//  Created by zhoonchen on 2017/3/29.
//  Copyright © 2017年 QMUI Team. All rights reserved.
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
    if (qmui_clearButtonImage) {
        objc_setAssociatedObject(self, &kAssociatedObjectKey_clearButtonImage, qmui_clearButtonImage, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        [self.qmui_clearButton setImage:qmui_clearButtonImage forState:UIControlStateNormal];
    }
}

- (UIImage *)qmui_clearButtonImage {
    return (UIImage *)objc_getAssociatedObject(self, &kAssociatedObjectKey_clearButtonImage);
}

@end
