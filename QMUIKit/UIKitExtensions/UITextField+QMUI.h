//
//  UITextField+QMUI.h
//  qmui
//
//  Created by zhoonchen on 2017/3/29.
//  Copyright © 2017年 QMUI Team. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@class QMUIKeyboardManager;
@class QMUIKeyboardUserInfo;

@interface UITextField (QMUI)

/// UITextField只有selectedTextRange属性（在<UITextInput>协议里定义），这里拓展了一个方法可以将UITextRange类型的selectedTextRange转换为NSRange类型的selectedRange
@property(nonatomic, assign, readonly) NSRange qmui_selectedRange;

/// 键盘相关block，搭配QMUIKeyboardManager一起使用

@property(nonatomic, strong, readonly) QMUIKeyboardManager *qmui_keyboardManager;

@property(nonatomic, copy) void (^qmui_keyboardWillShowNotificationBlock)(QMUIKeyboardUserInfo *keyboardUserInfo);
@property(nonatomic, copy) void (^qmui_keyboardWillHideNotificationBlock)(QMUIKeyboardUserInfo *keyboardUserInfo);
@property(nonatomic, copy) void (^qmui_keyboardWillChangeFrameNotificationBlock)(QMUIKeyboardUserInfo *keyboardUserInfo);
@property(nonatomic, copy) void (^qmui_keyboardDidShowNotificationBlock)(QMUIKeyboardUserInfo *keyboardUserInfo);
@property(nonatomic, copy) void (^qmui_keyboardDidHideNotificationBlock)(QMUIKeyboardUserInfo *keyboardUserInfo);
@property(nonatomic, copy) void (^qmui_keyboardDidChangeFrameNotificationBlock)(QMUIKeyboardUserInfo *keyboardUserInfo);

@end
