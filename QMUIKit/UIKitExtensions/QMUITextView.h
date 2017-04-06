//
//  QMUITextView.h
//  qmui
//
//  Created by QQMail on 14-8-5.
//  Copyright (c) 2014年 QMUI Team. All rights reserved.
//

#import <UIKit/UIKit.h>

@class QMUITextView;

@protocol QMUITextViewDelegate <UITextViewDelegate>

@optional
/**
 *  输入框高度发生变化时的回调，仅当 `autoResizable` 属性为 YES 时才有效。
 *  @note 只有当内容高度与当前输入框的高度不一致时才会调用到这里，所以无需在内部做高度是否变化的判断。
 */
- (void)textView:(QMUITextView *)textView newHeightAfterTextChanged:(CGFloat)height;

/**
 *  用户点击键盘的 return 按钮时的回调（return 按钮本质上是输入换行符“\n”）
 *  @return 返回 YES 表示程序认为当前的点击是为了进行类似“发送”之类的操作，所以最终“\n”并不会被输入到文本框里。返回 NO 表示程序认为当前的点击只是普通的输入，所以会继续询问 textView:shouldChangeTextInRange:replacementText: 方法，根据该方法的返回结果来决定是否要输入这个“\n”。
 *  @see maximumTextLength
 */
- (BOOL)textViewShouldReturn:(QMUITextView *)textView;

/**
 *  配合 `maximumTextLength` 属性使用，在输入文字超过限制时被调用。例如如果你的输入框在按下键盘“Done”按键时做一些发送操作，就可以在这个方法里判断 [replacementText isEqualToString:@"\n"]。
 *  @warning 在 textViewDidChange: 里也会触发文字长度拦截，由于此时 textView 的文字已经改变完，所以无法得知发生改变的文本位置及改变的文本内容，所以此时 range 和 replacementText 这两个参数的值也会比较特殊，具体请看参数讲解。
 *
 *  @param textView 触发的 textView
 *  @param range 要变化的文字的位置，如果在 textViewDidChange: 里，这里的 range 也即文字变化后的 range，所以可能比最大长度要大。
 *  @param replacementText 要变化的文字，如果在 textViewDidChange: 里，这里永远传入 nil。
 */
- (void)textView:(QMUITextView *)textView didPreventTextChangeInRange:(NSRange)range replacementText:(NSString *)replacementText;

@end

/**
 *  自定义 UITextView，提供的特性如下：
 *
 *  1. 支持 placeholder 并支持更改 placeholderColor；若使用了富文本文字，则 placeholder 的样式也会跟随文字的样式（除了 placeholder 颜色）
 *  2. 支持在文字发生变化时计算内容高度并通知 delegate （需打开 autoResizable 属性）。
 *  3. 支持限制输入的文本的最大长度，默认不限制。
 *  4. 修正系统 UITextView 在输入时自然换行的时候，contentOffset 的滚动位置没有考虑 textContainerInset.bottom
 */
@interface QMUITextView : UITextView<QMUITextViewDelegate>

@property(nonatomic, weak) id<QMUITextViewDelegate> delegate;

/**
 *  当通过 `setText:`、`setAttributedText:`等方式修改文字时，是否应该自动触发 `UITextViewDelegate` 里的 `textView:shouldChangeTextInRange:replacementText:`、 `textViewDidChange:` 方法
 *
 *  默认为YES（注意系统的 UITextView 对这种行为默认是 NO）
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

/**
 *   placeholder 的文字
 */
@property(nonatomic, copy) IBInspectable NSString *placeholder;

/**
 *  placeholder 文字的颜色
 */
@property(nonatomic, strong) IBInspectable UIColor *placeholderColor;

/**
 *  placeholder 在默认位置上的偏移（默认位置会自动根据 textContainerInset、contentInset 来调整）
 */
@property(nonatomic, assign) UIEdgeInsets placeholderMargins;

/**
 *  是否支持自动拓展高度，默认为NO
 *  @see textView:newHeightAfterTextChanged:
 */
@property(nonatomic, assign) BOOL autoResizable;

@end
