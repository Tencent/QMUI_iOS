/**
 * Tencent is pleased to support the open source community by making QMUI_iOS available.
 * Copyright (C) 2016-2021 THL A29 Limited, a Tencent company. All rights reserved.
 * Licensed under the MIT License (the "License"); you may not use this file except in compliance with the License. You may obtain a copy of the License at
 * http://opensource.org/licenses/MIT
 * Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.
 */

//
//  QMUITextField.m
//  qmui
//
//  Created by QMUI Team on 16-11-03
//

#import "QMUITextField.h"
#import "QMUICore.h"
#import "NSString+QMUI.h"
#import "UITextField+QMUI.h"
#import "QMUIMultipleDelegates.h"

// 私有的类，专用于实现 QMUITextFieldDelegate，避免 self.delegate = self 的写法（以前是 QMUITextField 自己实现了 delegate）
@interface _QMUITextFieldDelegator : NSObject <QMUITextFieldDelegate, UIScrollViewDelegate>

@property(nonatomic, weak) QMUITextField *textField;
- (void)handleTextChangeEvent:(QMUITextField *)textField;
@end

@interface QMUITextField ()

@property(nonatomic, strong) _QMUITextFieldDelegator *delegator;
@end

@implementation QMUITextField

@dynamic delegate;

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self didInitialize];
        if (QMUICMIActivated) {
            UIColor *textColor = TextFieldTextColor;
            if (textColor) {
                self.textColor = textColor;
            }
            
            self.tintColor = TextFieldTintColor;
        }
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
        [self didInitialize];
    }
    return self;
}

- (void)didInitialize {
    self.qmui_multipleDelegatesEnabled = YES;
    self.delegator = [[_QMUITextFieldDelegator alloc] init];
    self.delegator.textField = self;
    self.delegate = self.delegator;
    [self addTarget:self.delegator action:@selector(handleTextChangeEvent:) forControlEvents:UIControlEventEditingChanged];
    
    self.shouldResponseToProgrammaticallyTextChanges = YES;
    self.maximumTextLength = NSUIntegerMax;
    
    if (QMUICMIActivated) {
        self.placeholderColor = UIColorPlaceholder;
        self.textInsets = TextFieldTextInsets;
    }
}

- (void)dealloc {
    self.delegate = nil;
}

#pragma mark - Placeholder

- (void)setPlaceholderColor:(UIColor *)placeholderColor {
    _placeholderColor = placeholderColor;
    if (self.placeholder) {
        [self updateAttributedPlaceholderIfNeeded];
    }
}

- (void)setPlaceholder:(NSString *)placeholder {
    [super setPlaceholder:placeholder];
    if (self.placeholderColor) {
        [self updateAttributedPlaceholderIfNeeded];
    }
}

- (void)updateAttributedPlaceholderIfNeeded {
    self.attributedPlaceholder = [[NSAttributedString alloc] initWithString:self.placeholder attributes:@{NSForegroundColorAttributeName: self.placeholderColor}];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    // 以下代码修复系统的 UITextField 在 iOS 10 下的 bug：https://github.com/Tencent/QMUI_iOS/issues/64
    UIScrollView *scrollView = self.subviews.firstObject;
    if (![scrollView isKindOfClass:[UIScrollView class]]) {
        return;
    }
    
    // 默认 delegate 是为 nil 的，所以我们才利用 delegate 修复这 个 bug，如果哪一天 delegate 不为 nil，就先不处理了。
    if (scrollView.delegate) {
        return;
    }
    
    scrollView.delegate = self.delegator;
}

- (void)setText:(NSString *)text {
    NSString *textBeforeChange = self.text;
    [super setText:text];
    
    if (self.shouldResponseToProgrammaticallyTextChanges && ![textBeforeChange isEqualToString:text]) {
        [self fireTextDidChangeEventForTextField:self];
    }
}

- (void)setAttributedText:(NSAttributedString *)attributedText {
    NSAttributedString *textBeforeChange = self.attributedText;
    [super setAttributedText:attributedText];
    if (self.shouldResponseToProgrammaticallyTextChanges && ![textBeforeChange isEqualToAttributedString:attributedText]) {
        [self fireTextDidChangeEventForTextField:self];
    }
}

- (void)fireTextDidChangeEventForTextField:(QMUITextField *)textField {
    [textField sendActionsForControlEvents:UIControlEventEditingChanged];
    [[NSNotificationCenter defaultCenter] postNotificationName:UITextFieldTextDidChangeNotification object:textField];
}

- (NSUInteger)lengthWithString:(NSString *)string {
    return self.shouldCountingNonASCIICharacterAsTwo ? string.qmui_lengthWhenCountingNonASCIICharacterAsTwo : string.length;
}

#pragma mark - Positioning Overrides

- (CGRect)textRectForBounds:(CGRect)bounds {
    bounds = CGRectInsetEdges(bounds, self.textInsets);
    CGRect resultRect = [super textRectForBounds:bounds];
    return resultRect;
}

- (CGRect)editingRectForBounds:(CGRect)bounds {
    bounds = CGRectInsetEdges(bounds, self.textInsets);
    return [super editingRectForBounds:bounds];
}

- (CGRect)clearButtonRectForBounds:(CGRect)bounds {
    CGRect result = [super clearButtonRectForBounds:bounds];
    result = CGRectOffset(result, self.clearButtonPositionAdjustment.horizontal, self.clearButtonPositionAdjustment.vertical);
    return result;
}

#pragma mark - <UIResponderStandardEditActions>

- (BOOL)canPerformAction:(SEL)action withSender:(id)sender {
    BOOL superReturnValue = [super canPerformAction:action withSender:sender];
    if (action == @selector(paste:) && self.canPerformPasteActionBlock) {
        return self.canPerformPasteActionBlock(sender, superReturnValue);
    }
    return superReturnValue;
}

- (void)paste:(id)sender {
    BOOL shouldCallSuper = YES;
    if (self.pasteBlock) {
        shouldCallSuper = self.pasteBlock(sender);
    }
    if (shouldCallSuper) {
        [super paste:sender];
    }
}


@end

@implementation _QMUITextFieldDelegator

#pragma mark - <QMUITextFieldDelegate>

- (BOOL)textField:(QMUITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    if (textField.maximumTextLength < NSUIntegerMax) {
        
        // 如果是中文输入法正在输入拼音的过程中（markedTextRange 不为 nil），是不应该限制字数的（例如输入“huang”这5个字符，其实只是为了输入“黄”这一个字符），所以在 shouldChange 这里不会限制，而是放在 didChange 那里限制。
        if (textField.markedTextRange) {
            return YES;
        }
        
        if (NSMaxRange(range) > textField.text.length) {
            // 如果 range 越界了，继续返回 YES 会造成 crash
            // https://github.com/Tencent/QMUI_iOS/issues/377
            // https://github.com/Tencent/QMUI_iOS/issues/1170
            // 这里的做法是本次返回 NO，并将越界的 range 缩减到没有越界的范围，再手动做该范围的替换。
            range = NSMakeRange(range.location, range.length - (NSMaxRange(range) - textField.text.length));
            if (range.length > 0) {
                UITextRange *textRange = [self.textField qmui_convertUITextRangeFromNSRange:range];
                [self.textField replaceRange:textRange withText:string];
            }
            return NO;
        }
        
        if (!string.length && range.length > 0) {
            // 允许删除，这段必须放在上面 #377、#1170 的逻辑后面
            return YES;
        }
        
        NSUInteger rangeLength = textField.shouldCountingNonASCIICharacterAsTwo ? [textField.text substringWithRange:range].qmui_lengthWhenCountingNonASCIICharacterAsTwo : range.length;
        if ([textField lengthWithString:textField.text] - rangeLength + [textField lengthWithString:string] > textField.maximumTextLength) {
            // 将要插入的文字裁剪成这么长，就可以让它插入了
            NSInteger substringLength = textField.maximumTextLength - [textField lengthWithString:textField.text] + rangeLength;
            if (substringLength > 0 && [textField lengthWithString:string] > substringLength) {
                NSString *allowedText = [string qmui_substringAvoidBreakingUpCharacterSequencesWithRange:NSMakeRange(0, substringLength) lessValue:YES countingNonASCIICharacterAsTwo:textField.shouldCountingNonASCIICharacterAsTwo];
                if ([textField lengthWithString:allowedText] <= substringLength) {
                    BOOL shouldChange = YES;
                    if ([textField.delegate respondsToSelector:@selector(textField:shouldChangeCharactersInRange:replacementString:originalValue:)]) {
                        shouldChange = [textField.delegate textField:textField shouldChangeCharactersInRange:range replacementString:allowedText originalValue:shouldChange];
                    }
                    if (!shouldChange) {
                        return NO;
                    }
                    textField.text = [textField.text stringByReplacingCharactersInRange:range withString:allowedText];
                    // 通过代码 setText: 修改的文字，默认光标位置会在插入的文字开头，通常这不符合预期，因此这里将光标定位到插入的那段字符串的末尾
                    // 注意由于粘贴后系统也会在下一个 runloop 去修改光标位置，所以我们这里也要 dispatch 到下一个 runloop 才能生效，否则会被系统的覆盖
                    // https://github.com/Tencent/QMUI_iOS/issues/1282
                    dispatch_async(dispatch_get_main_queue(), ^{
                        textField.qmui_selectedRange = NSMakeRange(range.location + allowedText.length, 0);
                    });
                    
                    if (!textField.shouldResponseToProgrammaticallyTextChanges) {
                        [textField fireTextDidChangeEventForTextField:textField];
                    }
                }
            }
            
            if ([textField.delegate respondsToSelector:@selector(textField:didPreventTextChangeInRange:replacementString:)]) {
                [textField.delegate textField:textField didPreventTextChangeInRange:range replacementString:string];
            }
            return NO;
        }
    }
    
    if ([textField.delegate respondsToSelector:@selector(textField:shouldChangeCharactersInRange:replacementString:originalValue:)]) {
        BOOL delegateValue = [textField.delegate textField:textField shouldChangeCharactersInRange:range replacementString:string originalValue:YES];
        return delegateValue;
    }
    
    return YES;
}

- (void)handleTextChangeEvent:(QMUITextField *)textField {
    // 1、iOS 10 以下的版本，从中文输入法的候选词里选词输入，是不会走到 textField:shouldChangeCharactersInRange:replacementString: 的，所以要在这里截断文字
    // 2、如果是中文输入法正在输入拼音的过程中（markedTextRange 不为 nil），是不应该限制字数的（例如输入“huang”这5个字符，其实只是为了输入“黄”这一个字符），所以在 shouldChange 那边不会限制，而是放在 didChange 这里限制。
    
    // 系统的三指撤销在文本框达到最大字符长度限制时可能引发 crash
    // https://github.com/Tencent/QMUI_iOS/issues/1168
    if (textField.maximumTextLength < NSUIntegerMax && (textField.undoManager.undoing || textField.undoManager.redoing)) {
        return;
    }
    
    if (!textField.markedTextRange) {
        if ([textField lengthWithString:textField.text] > textField.maximumTextLength) {
            textField.text = [textField.text qmui_substringAvoidBreakingUpCharacterSequencesWithRange:NSMakeRange(0, textField.maximumTextLength) lessValue:YES countingNonASCIICharacterAsTwo:textField.shouldCountingNonASCIICharacterAsTwo];
            
            if ([textField.delegate respondsToSelector:@selector(textField:didPreventTextChangeInRange:replacementString:)]) {
                [textField.delegate textField:textField didPreventTextChangeInRange:textField.qmui_selectedRange replacementString:nil];
            }
        }
    }
}

#pragma mark - <UIScrollViewDelegate>

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    
    // 以下代码修复系统的 UITextField 在 iOS 10 下的 bug：https://github.com/Tencent/QMUI_iOS/issues/64
    
    if (scrollView != self.textField.subviews.firstObject) {
        return;
    }
    
    CGFloat lineHeight = ((NSParagraphStyle *)self.textField.defaultTextAttributes[NSParagraphStyleAttributeName]).minimumLineHeight;
    lineHeight = lineHeight ?: ((UIFont *)self.textField.defaultTextAttributes[NSFontAttributeName]).lineHeight;
    if (scrollView.contentSize.height > ceil(lineHeight) && scrollView.contentOffset.y < 0) {
        scrollView.contentOffset = CGPointMake(scrollView.contentOffset.x, 0);
    }
}

@end
