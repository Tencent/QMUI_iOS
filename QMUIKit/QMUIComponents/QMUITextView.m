/**
 * Tencent is pleased to support the open source community by making QMUI_iOS available.
 * Copyright (C) 2016-2021 THL A29 Limited, a Tencent company. All rights reserved.
 * Licensed under the MIT License (the "License"); you may not use this file except in compliance with the License. You may obtain a copy of the License at
 * http://opensource.org/licenses/MIT
 * Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.
 */

//
//  QMUITextView.m
//  qmui
//
//  Created by QMUI Team on 14-8-5.
//
#import "QMUITextView.h"
#import "QMUICore.h"
#import "QMUILabel.h"
#import "NSObject+QMUI.h"
#import "NSString+QMUI.h"
#import "UITextView+QMUI.h"
#import "UIScrollView+QMUI.h"
#import "QMUILog.h"
#import "QMUIMultipleDelegates.h"

/// 系统 textView 默认的字号大小，用于 placeholder 默认的文字大小。实测得到，请勿修改。
const CGFloat kSystemTextViewDefaultFontPointSize = 12.0f;

/// 当系统的 textView.textContainerInset 为 UIEdgeInsetsZero 时，文字与 textView 边缘的间距。实测得到，请勿修改（在输入框font大于13时准确，小于等于12时，y有-1px的偏差）。
const UIEdgeInsets kSystemTextViewFixTextInsets = {0, 5, 0, 5};

// 私有的类，专用于实现 QMUITextViewDelegate，避免 self.delegate = self 的写法（以前是 QMUITextView 自己实现了 delegate）
@interface _QMUITextViewDelegator : NSObject <QMUITextViewDelegate>

@property(nonatomic, weak) QMUITextView *textView;
@end

@interface QMUITextView ()

@property(nonatomic, assign) BOOL debug;
@property(nonatomic, assign) BOOL postInitializationMethodCalled;
@property(nonatomic, strong) _QMUITextViewDelegator *delegator;
@property(nonatomic, assign) BOOL isSettingTextByShouldChange;
@property(nonatomic, assign) BOOL shouldRejectSystemScroll;// 如果在 handleTextChanged: 里主动调整 contentOffset，则为了避免被系统的自动调整覆盖，会利用这个标记去屏蔽系统对 setContentOffset: 的调用

@property(nonatomic, strong) UILabel *placeholderLabel;

@end

@implementation QMUITextView

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
    self.debug = NO;
    
    self.qmui_multipleDelegatesEnabled = YES;
    self.delegator = [[_QMUITextViewDelegator alloc] init];
    self.delegator.textView = self;
    self.delegate = self.delegator;
    
    self.scrollsToTop = NO;
    if (QMUICMIActivated) self.placeholderColor = UIColorPlaceholder;
    self.placeholderMargins = UIEdgeInsetsZero;
    self.maximumHeight = CGFLOAT_MAX;
    self.maximumTextLength = NSUIntegerMax;
    self.shouldResponseToProgrammaticallyTextChanges = YES;
    if (@available(iOS 11, *)) {
        self.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    }
    
    self.placeholderLabel = [[UILabel alloc] init];
    self.placeholderLabel.font = UIFontMake(kSystemTextViewDefaultFontPointSize);
    self.placeholderLabel.textColor = self.placeholderColor;
    self.placeholderLabel.numberOfLines = 0;
    self.placeholderLabel.alpha = 0;
    [self addSubview:self.placeholderLabel];
    
    // 监听用户手工输入引发的文字变化（代码里通过 setText: 修改的不在这个监听范围内）
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleTextChanged:) name:UITextViewTextDidChangeNotification object:nil];
    
    self.postInitializationMethodCalled = YES;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    self.delegate = nil;
}

- (NSString *)description {
    return [NSString stringWithFormat:@"%@; text.length: %@ | %@; markedTextRange: %@", [super description], @(self.text.length), @([self lengthWithString:self.text]), self.markedTextRange];
}

- (BOOL)isCurrentTextDifferentOfText:(NSString *)text {
    NSString *textBeforeChange = self.text;// UITextView 如果文字为空，self.text 永远返回 @"" 而不是 nil（即便你设置为 nil 后立即 get 出来也是）
    if ([textBeforeChange isEqualToString:text] || (textBeforeChange.length == 0 && !text)) {
        return NO;
    }
    return YES;
}

- (void)_qmui_setTextForShouldChange:(NSString *)text {
    self.isSettingTextByShouldChange = YES;
    [self setText:text];
    // 对于 shouldResponseToProgrammaticallyTextChanges = YES 的，调用 textViewDidChange: 的工作已经在 self setText: 里做完了，所以这里对 shouldResponseToProgrammaticallyTextChanges = NO 的专门做一次
    if (!self.shouldResponseToProgrammaticallyTextChanges && [self.delegate respondsToSelector:@selector(textViewDidChange:)]) {
        [self.delegate textViewDidChange:self];
    }
    self.isSettingTextByShouldChange = NO;
}

- (void)setAttributedText:(NSAttributedString *)attributedText {
    BOOL textDifferent = [self isCurrentTextDifferentOfText:attributedText.string];
    
    if (!textDifferent) {
        [super setAttributedText:attributedText];
        return;
    }
    
    if (self.shouldResponseToProgrammaticallyTextChanges) {
        if (!self.isSettingTextByShouldChange) {
            BOOL shouldChangeText = YES;
            if ([self.delegate respondsToSelector:@selector(textView:shouldChangeTextInRange:replacementText:)]) {
                NSString *textBeforeChange = self.attributedText.string;
                shouldChangeText = [self.delegate textView:self shouldChangeTextInRange:NSMakeRange(0, textBeforeChange.length) replacementText:attributedText.string];
            }
            
            if (!shouldChangeText) {
                return;
            }
        }
        [super setAttributedText:attributedText];
        if ([self.delegate respondsToSelector:@selector(textViewDidChange:)]) {
            [self.delegate textViewDidChange:self];
        }
    } else {
        [super setAttributedText:attributedText];
    }
    
    [self handleTextChanged:self];
}

- (void)setTypingAttributes:(NSDictionary<NSString *,id> *)typingAttributes {
    [super setTypingAttributes:typingAttributes];
    [self updatePlaceholderStyle];
}

- (void)setFont:(UIFont *)font {
    [super setFont:font];
    [self updatePlaceholderStyle];
}

- (void)setTextColor:(UIColor *)textColor {
    [super setTextColor:textColor];
    [self updatePlaceholderStyle];
}

- (void)setTextAlignment:(NSTextAlignment)textAlignment {
    [super setTextAlignment:textAlignment];
    [self updatePlaceholderStyle];
}

- (void)setTextContainerInset:(UIEdgeInsets)textContainerInset {
    [super setTextContainerInset:textContainerInset];
    if (@available(iOS 11, *)) {
    } else {
        // iOS 11 以下修改 textContainerInset 的时候无法自动触发 layoutSubview，导致 placeholderLabel 无法更新布局
        [self setNeedsLayout];
    }
}


- (void)setPlaceholder:(NSString *)placeholder {
    _placeholder = placeholder;
    self.placeholderLabel.attributedText = [[NSAttributedString alloc] initWithString:_placeholder attributes:self.typingAttributes];
    if (self.placeholderColor) {
        self.placeholderLabel.textColor = self.placeholderColor;
    }
    [self sendSubviewToBack:self.placeholderLabel];
    [self setNeedsLayout];
    [self updatePlaceholderLabelHidden];
}

- (void)setPlaceholderColor:(UIColor *)placeholderColor {
    _placeholderColor = placeholderColor;
    self.placeholderLabel.textColor = _placeholderColor;
}

- (void)updatePlaceholderStyle {
    self.placeholder = self.placeholder;// 触发文字样式的更新
}

- (void)updatePlaceholderLabelHidden {
    if (self.text.length == 0 && self.placeholder.length > 0) {
        self.placeholderLabel.alpha = 1;
    } else {
        self.placeholderLabel.alpha = 0;// 用alpha来让placeholder隐藏，从而尽量避免因为显隐 placeholder 导致 layout
    }
}

- (CGRect)preferredPlaceholderFrameWithSize:(CGSize)size {
    if (self.placeholder.length <= 0) return CGRectZero;
    
    UIEdgeInsets allInsets = self.allInsets;
    UIEdgeInsets labelMargins = UIEdgeInsetsMake(allInsets.top - self.qmui_contentInset.top, allInsets.left - self.qmui_contentInset.left, allInsets.bottom - self.qmui_contentInset.bottom, allInsets.right - self.qmui_contentInset.right);
    CGFloat limitWidth = size.width - UIEdgeInsetsGetHorizontalValue(allInsets);
    CGFloat limitHeight = size.height - UIEdgeInsetsGetVerticalValue(allInsets);
    CGSize labelSize = [self.placeholderLabel sizeThatFits:CGSizeMake(limitWidth, limitHeight)];
    labelSize.width = MIN(limitWidth, labelSize.width);
    labelSize.height = MIN(limitHeight, labelSize.height);
    return CGRectFlatMake(labelMargins.left, labelMargins.top, limitWidth, labelSize.height);
}

- (void)handleTextChanged:(id)sender {
    QMUITextView *textView = nil;
    if ([sender isKindOfClass:[NSNotification class]]) {
        id object = ((NSNotification *)sender).object;
        if (object == self) {
            textView = (QMUITextView *)object;
        }
    } else if ([sender isKindOfClass:[QMUITextView class]]) {
        textView = (QMUITextView *)sender;
    }
    
    if (!textView) return;
    
    // 输入字符的时候，placeholder隐藏
    if (self.placeholder.length > 0) {
        [self updatePlaceholderLabelHidden];
    }
    
    // 系统的三指撤销在文本框达到最大字符长度限制时可能引发 crash
    // https://github.com/Tencent/QMUI_iOS/issues/1168
    if (textView.maximumTextLength < NSUIntegerMax && textView.undoManager.undoing) {
        return;
    }
    
    // 如果输入一长串中文拼音后，选择一个长度超过限制的候选词，在 textView:shouldChangeTextInRange:replacementText: 那边无法拦截，所以交给 handleTextChanged: 这边截断。这种情况会触发多次 handleTextChanged:，其中有一次是超出长度的，没办法，业务注意做好保护。
    if (!textView.markedTextRange && [textView lengthWithString:textView.text] > textView.maximumTextLength) {
        NSString *finalText = [textView.text qmui_substringAvoidBreakingUpCharacterSequencesWithRange:NSMakeRange(0, textView.maximumTextLength) lessValue:YES countingNonASCIICharacterAsTwo:textView.shouldCountingNonASCIICharacterAsTwo];
        NSString *replacementText = [textView.text substringFromIndex:finalText.length];
        textView.text = finalText;
        if ([textView.delegate respondsToSelector:@selector(textView:didPreventTextChangeInRange:replacementText:)]) {
            // 如果是在这里被截断，是无法得知截断前光标所处的位置及要输入的文本的，所以只能将当前的 selectedRange 传过去，而 replacementText 为 nil
            [textView.delegate textView:textView didPreventTextChangeInRange:textView.selectedRange replacementText:replacementText];
        }
    }
    
    if (!textView.editable) {
        return;// 不可编辑的 textView 不会显示光标
    }
    
    // 计算高度
    if ([textView.delegate respondsToSelector:@selector(textView:newHeightAfterTextChanged:)]) {
        
        CGFloat resultHeight = flat([textView sizeThatFits:CGSizeMake(CGRectGetWidth(textView.bounds), CGFLOAT_MAX)].height);
        
        if (textView.debug) QMUILog(NSStringFromClass(textView.class), @"handleTextDidChange, text = %@, resultHeight = %f", textView.text, resultHeight);
        
        
        // 通知delegate去更新textView的高度
        if (resultHeight != flat(CGRectGetHeight(textView.bounds))) {
            [textView.delegate textView:textView newHeightAfterTextChanged:resultHeight];
        }
    }
    
    // textView 尚未被展示到界面上时，此时过早进行光标调整会计算错误
    if (!textView.window) {
        return;
    }
    
    textView.shouldRejectSystemScroll = YES;
    // 用 dispatch 延迟一下，因为在文字发生换行时，系统自己会做一些滚动，我们要延迟一点才能避免被系统的滚动覆盖
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        textView.shouldRejectSystemScroll = NO;
        [textView qmui_scrollCaretVisibleAnimated:NO];
    });
}

- (CGSize)sizeThatFits:(CGSize)size {
    if (size.width <= 0) size.width = CGFLOAT_MAX;
    if (size.height <= 0) size.height = CGFLOAT_MAX;
    CGSize result = CGSizeZero;
    if (self.placeholder.length > 0 && self.text.length <= 0) {
        UIEdgeInsets allInsets = self.allInsets;
        CGRect frame = [self preferredPlaceholderFrameWithSize:size];
        result.width = CGRectGetWidth(frame) + UIEdgeInsetsGetHorizontalValue(allInsets);
        result.height = CGRectGetHeight(frame) + UIEdgeInsetsGetVerticalValue(allInsets);
    } else {
        result = [super sizeThatFits:size];
    }
    result.height = MIN(result.height, self.maximumHeight);
    return result;
}

- (UIEdgeInsets)allInsets {
    return UIEdgeInsetsConcat(UIEdgeInsetsConcat(UIEdgeInsetsConcat(self.textContainerInset, self.placeholderMargins), kSystemTextViewFixTextInsets), self.qmui_contentInset);
}

- (void)setFrame:(CGRect)frame {
    if (self.postInitializationMethodCalled) {
        // 如果没走完 didInitialize，说明 self.maximumHeight 尚未被赋初始值 CGFLOAT_MAX，此时的值为 0，就会导致调用 initWithFrame: 时高度无效，必定被指定为 0
        frame = CGRectSetHeight(frame, MIN(CGRectGetHeight(frame), self.maximumHeight));
    }
    
    // 重写了 UITextView 的 drawRect: 后，对于带小数点的 frame 会导致文本框右边多出一条黑线，原因未明，暂时这样处理
    // https://github.com/Tencent/QMUI_iOS/issues/557
    frame = CGRectFlatted(frame);
    
    [super setFrame:frame];
}

- (void)setBounds:(CGRect)bounds {
    // 重写了 UITextView 的 drawRect: 后，对于带小数点的 frame 会导致文本框右边多出一条黑线，原因未明，暂时这样处理
    // https://github.com/Tencent/QMUI_iOS/issues/557
    bounds = CGRectFlatted(bounds);
    [super setBounds:bounds];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    if (self.placeholder.length > 0) {
        CGRect frame = [self preferredPlaceholderFrameWithSize:self.bounds.size];
        self.placeholderLabel.frame = frame;
    }
}

- (void)drawRect:(CGRect)rect {
    [super drawRect:rect];
    [self updatePlaceholderLabelHidden];
}

- (NSUInteger)lengthWithString:(NSString *)string {
    return self.shouldCountingNonASCIICharacterAsTwo ? string.qmui_lengthWhenCountingNonASCIICharacterAsTwo : string.length;
}

- (void)setContentOffset:(CGPoint)contentOffset animated:(BOOL)animated {
    if (!self.shouldRejectSystemScroll) {
        [super setContentOffset:contentOffset animated:animated];
        if (self.debug) QMUILog(NSStringFromClass(self.class), @"%@, contentOffset.y = %.2f", NSStringFromSelector(_cmd), contentOffset.y);
    } else {
        if (self.debug) QMUILog(NSStringFromClass(self.class), @"被屏蔽的 %@, contentOffset.y = %.2f", NSStringFromSelector(_cmd), contentOffset.y);
    }
}

- (void)setContentOffset:(CGPoint)contentOffset {
    if (!self.shouldRejectSystemScroll) {
        [super setContentOffset:contentOffset];
        if (self.debug) QMUILog(NSStringFromClass(self.class), @"%@, contentOffset.y = %.2f", NSStringFromSelector(_cmd), contentOffset.y);
    } else {
        if (self.debug) QMUILog(NSStringFromClass(self.class), @"被屏蔽的 %@, contentOffset.y = %.2f", NSStringFromSelector(_cmd), contentOffset.y);
    }
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

@implementation _QMUITextViewDelegator

#pragma mark - <QMUITextViewDelegate>

- (BOOL)textView:(QMUITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    if (self.textView.debug) QMUILog(NSStringFromClass(self.class), @"textView.text(%@ | %@) = %@\nmarkedTextRange = %@\nrange = %@\ntext = %@", @(textView.text.length), @(textView.text.qmui_lengthWhenCountingNonASCIICharacterAsTwo), textView.text, textView.markedTextRange, NSStringFromRange(range), text);
    
    if ([text isEqualToString:@"\n"]) {
        if ([textView.delegate respondsToSelector:@selector(textViewShouldReturn:)]) {
            BOOL shouldReturn = [textView.delegate textViewShouldReturn:textView];
            if (shouldReturn) {
                return NO;
            }
        }
    }
    
    if (textView.maximumTextLength < NSUIntegerMax) {
        
        // 如果是中文输入法正在输入拼音的过程中（markedTextRange 不为 nil），是不应该限制字数的（例如输入“huang”这5个字符，其实只是为了输入“黄”这一个字符）
        // 注意当点击了候选词后触发的那一次 textView:shouldChangeTextInRange:replacementText:，此时的 marktedTextRange 依然存在，尚未被清除，所以这种情况下的字符长度限制逻辑会交给 handleTextChanged: 那边处理。
        if (textView.markedTextRange) {
            return YES;
        }
        
        if (NSMaxRange(range) > textView.text.length) {
            // 如果 range 越界了，继续返回 YES 会造成 rash
            // https://github.com/Tencent/QMUI_iOS/issues/377
            // https://github.com/Tencent/QMUI_iOS/issues/1170
            // 这里的做法是本次返回 NO，并将越界的 range 缩减到没有越界的范围，再手动做该范围的替换。
            range = NSMakeRange(range.location, range.length - (NSMaxRange(range) - textView.text.length));
            if (range.length > 0) {
                UITextRange *textRange = [self.textView qmui_convertUITextRangeFromNSRange:range];
                [self.textView replaceRange:textRange withText:text];
            }
            return NO;
        }
        
        NSUInteger rangeLength = textView.shouldCountingNonASCIICharacterAsTwo ? [textView.text substringWithRange:range].qmui_lengthWhenCountingNonASCIICharacterAsTwo : range.length;
        BOOL textWillOutofMaximumTextLength = [textView lengthWithString:textView.text] - rangeLength + [textView lengthWithString:text] > textView.maximumTextLength;
        if (textWillOutofMaximumTextLength) {
            // 当输入的文本达到最大长度限制后，此时继续点击 return 按钮（相当于尝试插入“\n”），就会认为总文字长度已经超过最大长度限制，所以此次 return 按钮的点击被拦截，外界无法感知到有这个 return 事件发生，所以这里为这种情况做了特殊保护
            if ([textView lengthWithString:textView.text] - rangeLength == textView.maximumTextLength && [text isEqualToString:@"\n"]) {
                return NO;
            }
            // 将要插入的文字裁剪成多长，就可以让它插入了
            NSInteger substringLength = textView.maximumTextLength - [textView lengthWithString:textView.text] + rangeLength;
            
            if (substringLength > 0 && [textView lengthWithString:text] > substringLength) {
                NSString *allowedText = [text qmui_substringAvoidBreakingUpCharacterSequencesWithRange:NSMakeRange(0, substringLength) lessValue:YES countingNonASCIICharacterAsTwo:textView.shouldCountingNonASCIICharacterAsTwo];
                if ([textView lengthWithString:allowedText] <= substringLength) {
                    [textView _qmui_setTextForShouldChange:[textView.text stringByReplacingCharactersInRange:range withString:allowedText]];
                     
                    // iOS 10 修改 selectedRange 可以让光标立即移动到新位置，但 iOS 11 及以上版本需要延迟一会才可以
                    NSRange finalSelectedRange = NSMakeRange(range.location + substringLength, 0);
                    textView.selectedRange = finalSelectedRange;
                    dispatch_async(dispatch_get_main_queue(), ^{
                        textView.selectedRange = finalSelectedRange;
                    });
                }
            }
            
            if ([textView.delegate respondsToSelector:@selector(textView:didPreventTextChangeInRange:replacementText:)]) {
                [textView.delegate textView:textView didPreventTextChangeInRange:range replacementText:text];
            }
            return NO;
        }
    }
    
    return YES;
}

@end
