//
//  QMUITextField.h
//  qmui
//
//  Created by MoLice on 16-11-03
//  Copyright (c) 2016年 QMUI Team. All rights reserved.
//

#import <UIKit/UIKit.h>

@class QMUITextField;

@protocol QMUITextFieldDelegate <UITextFieldDelegate>

@optional

/**
 *  配合 `maximumTextLength` 属性使用，在输入文字超过限制时被调用。
 *  @warning 在 UIControlEventEditingChanged 里也会触发文字长度拦截，由于此时 textField 的文字已经改变完，所以无法得知发生改变的文本位置及改变的文本内容，所以此时 range 和 replacementString 这两个参数的值也会比较特殊，具体请看参数讲解。
 *
 *  @param textField 触发的 textField
 *  @param range 要变化的文字的位置，如果在 UIControlEventEditingChanged 里，这里的 range 也即文字变化后的 range，所以可能比最大长度要大。
 *  @param replacementString 要变化的文字，如果在 UIControlEventEditingChanged 里，这里永远传入 nil。
 */
- (void)textField:(QMUITextField *)textField didPreventTextChangeInRange:(NSRange)range replacementString:(NSString *)replacementString;

@end

/**
 *  支持的特性包括：
 *
 *  1. 自定义 placeholderColor。
 *  2. 自定义 UITextField 的文字 padding。
 *  3. 支持限制输入的文字的长度。
 *  4. 修复 iOS 10 之后 UITextField 输入中文超过文本框宽度后再删除，文字往下掉的 bug。
 */
@interface QMUITextField : UITextField

@property(nonatomic, weak) id<QMUITextFieldDelegate> delegate;

/**
 *  修改 placeholder 的颜色，默认是 UIColorPlaceholder。
 */
@property(nonatomic, strong) IBInspectable UIColor *placeholderColor;

/**
 *  文字在输入框内的 padding。如果出现 clearButton，则 textInsets.right 会控制 clearButton 的右边距
 *
 *  默认为 TextFieldTextInsets
 */
@property(nonatomic, assign) UIEdgeInsets textInsets;

/**
 *  当通过 `setText:`、`setAttributedText:`等方式修改文字时，是否应该自动触发 UIControlEventEditingChanged 事件及 UITextFieldTextDidChangeNotification 通知。
 *
 *  默认为YES（注意系统的 UITextField 对这种行为默认是 NO）
 */
@property(nonatomic, assign) IBInspectable BOOL shouldResponseToProgrammaticallyTextChanges;

/**
 *  显示允许输入的最大文字长度，默认为 NSUIntegerMax，也即不限制长度。
 */
@property(nonatomic, assign) IBInspectable NSUInteger maximumTextLength;

/**
 *  在使用 maximumTextLength 功能的时候，是否应该把文字长度按照 [NSString (QMUI) qmui_lengthWhenCountingNonASCIICharacterAsTwo] 的方法来计算。
 *  默认为 NO。
 */
@property(nonatomic, assign) IBInspectable BOOL shouldCountingNonASCIICharacterAsTwo;

@end
