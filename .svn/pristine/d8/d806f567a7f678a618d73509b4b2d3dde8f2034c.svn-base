//
//  UITextView+QMUI.h
//  qmui
//
//  Created by zhoonchen on 2017/3/29.
//  Copyright © 2017年 QMUI Team. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@class QMUIKeyboardManager;
@class QMUIKeyboardUserInfo;

@interface UITextView (QMUI)

/**
 *  convert UITextRange to NSRange, for example, [self qmui_convertNSRangeFromUITextRange:self.markedTextRange]
 */
- (NSRange)qmui_convertNSRangeFromUITextRange:(UITextRange *)textRange;

/**
 *  设置 text 会让 selectedTextRange 跳到最后一个字符，导致在中间修改文字后光标会跳到末尾，所以设置前要保存一下，设置后恢复过来
 */
- (void)qmui_setTextKeepingSelectedRange:(NSString *)text;

/**
 *  设置 attributedText 会让 selectedTextRange 跳到最后一个字符，导致在中间修改文字后光标会跳到末尾，所以设置前要保存一下，设置后恢复过来
 */
- (void)qmui_setAttributedTextKeepingSelectedRange:(NSAttributedString *)attributedText;

/**
 *  [UITextView scrollRangeToVisible:] 并不会考虑 textContainerInset.bottom，所以使用这个方法来代替
 */
- (void)qmui_scrollCaretVisibleAnimated:(BOOL)animated;

/// 键盘相关block，搭配QMUIKeyboardManager一起使用

@property(nonatomic, copy) void (^qmui_keyboardWillShowNotificationBlock)(QMUIKeyboardUserInfo *keyboardUserInfo);
@property(nonatomic, copy) void (^qmui_keyboardWillHideNotificationBlock)(QMUIKeyboardUserInfo *keyboardUserInfo);
@property(nonatomic, copy) void (^qmui_keyboardWillChangeFrameNotificationBlock)(QMUIKeyboardUserInfo *keyboardUserInfo);
@property(nonatomic, copy) void (^qmui_keyboardDidShowNotificationBlock)(QMUIKeyboardUserInfo *keyboardUserInfo);
@property(nonatomic, copy) void (^qmui_keyboardDidHideNotificationBlock)(QMUIKeyboardUserInfo *keyboardUserInfo);
@property(nonatomic, copy) void (^qmui_keyboardDidChangeFrameNotificationBlock)(QMUIKeyboardUserInfo *keyboardUserInfo);

@property(nonatomic, strong, readonly) QMUIKeyboardManager *qmui_keyboardManager;

@end
