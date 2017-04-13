//
//  UITextField+QMUI.m
//  qmui
//
//  Created by zhoonchen on 2017/3/29.
//  Copyright © 2017年 QMUI Team. All rights reserved.
//

#import "UITextField+QMUI.h"
#import "QMUICommonDefines.h"
#import "QMUIConfiguration.h"
#import "QMUIKeyboardManager.h"

@interface UITextField () <QMUIKeyboardManagerDelegate>

@end

@implementation UITextField (QMUI)

- (NSRange)qmui_selectedRange {
    NSInteger location = [self offsetFromPosition:self.beginningOfDocument toPosition:self.selectedTextRange.start];
    NSInteger length = [self offsetFromPosition:self.selectedTextRange.start toPosition:self.selectedTextRange.end];
    return NSMakeRange(location, length);
}

- (void)setQmui_keyboardWillShowNotificationBlock:(void (^)(QMUIKeyboardUserInfo *))keyboardWillShowNotificationBlock {
    objc_setAssociatedObject(self, @selector(qmui_keyboardWillShowNotificationBlock), keyboardWillShowNotificationBlock, OBJC_ASSOCIATION_COPY_NONATOMIC);
    if (keyboardWillShowNotificationBlock) {
        [self initKeyboardManagerIfNeeded];
    }
}

- (void (^)(QMUIKeyboardUserInfo *))qmui_keyboardWillShowNotificationBlock {
    return objc_getAssociatedObject(self, _cmd);
}

- (void)setQmui_keyboardDidShowNotificationBlock:(void (^)(QMUIKeyboardUserInfo *))keyboardDidShowNotificationBlock {
    objc_setAssociatedObject(self, @selector(qmui_keyboardDidShowNotificationBlock), keyboardDidShowNotificationBlock, OBJC_ASSOCIATION_COPY_NONATOMIC);
    if (keyboardDidShowNotificationBlock) {
        [self initKeyboardManagerIfNeeded];
    }
}

- (void (^)(QMUIKeyboardUserInfo *))qmui_keyboardDidShowNotificationBlock {
    return objc_getAssociatedObject(self, _cmd);
}

- (void)setQmui_keyboardWillHideNotificationBlock:(void (^)(QMUIKeyboardUserInfo *))keyboardWillHideNotificationBlock {
    objc_setAssociatedObject(self, @selector(qmui_keyboardWillHideNotificationBlock), keyboardWillHideNotificationBlock, OBJC_ASSOCIATION_COPY_NONATOMIC);
    if (keyboardWillHideNotificationBlock) {
        [self initKeyboardManagerIfNeeded];
    }
}

- (void (^)(QMUIKeyboardUserInfo *))qmui_keyboardWillHideNotificationBlock {
    return objc_getAssociatedObject(self, _cmd);
}

- (void)setQmui_keyboardDidHideNotificationBlock:(void (^)(QMUIKeyboardUserInfo *))keyboardDidHideNotificationBlock {
    objc_setAssociatedObject(self, @selector(qmui_keyboardDidHideNotificationBlock), keyboardDidHideNotificationBlock, OBJC_ASSOCIATION_COPY_NONATOMIC);
    if (keyboardDidHideNotificationBlock) {
        [self initKeyboardManagerIfNeeded];
    }
}

- (void (^)(QMUIKeyboardUserInfo *))qmui_keyboardDidHideNotificationBlock {
    return objc_getAssociatedObject(self, _cmd);
}

- (void)setQmui_keyboardWillChangeFrameNotificationBlock:(void (^)(QMUIKeyboardUserInfo *))keyboardWillChangeFrameNotificationBlock {
    objc_setAssociatedObject(self, @selector(qmui_keyboardWillChangeFrameNotificationBlock), keyboardWillChangeFrameNotificationBlock, OBJC_ASSOCIATION_COPY_NONATOMIC);
    if (keyboardWillChangeFrameNotificationBlock) {
        [self initKeyboardManagerIfNeeded];
    }
}

- (void (^)(QMUIKeyboardUserInfo *))qmui_keyboardWillChangeFrameNotificationBlock {
    return objc_getAssociatedObject(self, _cmd);
}

- (void)setQmui_keyboardDidChangeFrameNotificationBlock:(void (^)(QMUIKeyboardUserInfo *))keyboardDidChangeFrameNotificationBlock {
    objc_setAssociatedObject(self, @selector(qmui_keyboardDidChangeFrameNotificationBlock), keyboardDidChangeFrameNotificationBlock, OBJC_ASSOCIATION_COPY_NONATOMIC);
    if (keyboardDidChangeFrameNotificationBlock) {
        [self initKeyboardManagerIfNeeded];
    }
}

- (void (^)(QMUIKeyboardUserInfo *))qmui_keyboardDidChangeFrameNotificationBlock {
    return objc_getAssociatedObject(self, _cmd);
}

- (void)setQmui_keyboardManager:(QMUIKeyboardManager *)keyboardManager {
    objc_setAssociatedObject(self, @selector(qmui_keyboardManager), keyboardManager, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (QMUIKeyboardManager *)qmui_keyboardManager {
    return objc_getAssociatedObject(self, _cmd);
}

- (void)initKeyboardManagerIfNeeded {
    if (!self.qmui_keyboardManager) {
        self.qmui_keyboardManager = [[QMUIKeyboardManager alloc] initWithDelegate:self];
        [self.qmui_keyboardManager addTargetResponder:self];
    }
}

#pragma mark - <QMUIKeyboardManagerDelegate>

- (void)keyboardWillShowWithUserInfo:(QMUIKeyboardUserInfo *)keyboardUserInfo {
    if (self.qmui_keyboardWillShowNotificationBlock) {
        self.qmui_keyboardWillShowNotificationBlock(keyboardUserInfo);
    }
}

- (void)keyboardWillHideWithUserInfo:(QMUIKeyboardUserInfo *)keyboardUserInfo {
    if (self.qmui_keyboardWillHideNotificationBlock) {
        self.qmui_keyboardWillHideNotificationBlock(keyboardUserInfo);
    }
}

- (void)keyboardWillChangeFrameWithUserInfo:(QMUIKeyboardUserInfo *)keyboardUserInfo {
    if (self.qmui_keyboardWillChangeFrameNotificationBlock) {
        self.qmui_keyboardWillChangeFrameNotificationBlock(keyboardUserInfo);
    }
}

- (void)keyboardDidShowWithUserInfo:(QMUIKeyboardUserInfo *)keyboardUserInfo {
    if (self.qmui_keyboardDidShowNotificationBlock) {
        self.qmui_keyboardDidShowNotificationBlock(keyboardUserInfo);
    }
}

- (void)keyboardDidHideWithUserInfo:(QMUIKeyboardUserInfo *)keyboardUserInfo {
    if (self.qmui_keyboardDidHideNotificationBlock) {
        self.qmui_keyboardDidHideNotificationBlock(keyboardUserInfo);
    }
}

- (void)keyboardDidChangeFrameWithUserInfo:(QMUIKeyboardUserInfo *)keyboardUserInfo {
    if (self.qmui_keyboardDidChangeFrameNotificationBlock) {
        self.qmui_keyboardDidChangeFrameNotificationBlock(keyboardUserInfo);
    }
}

@end
