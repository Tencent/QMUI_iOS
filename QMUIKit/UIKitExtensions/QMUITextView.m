//
//  QMUITextView.m
//  qmui
//
//  Created by QQMail on 14-8-5.
//  Copyright (c) 2014年 QMUI Team. All rights reserved.
//
#import "QMUITextView.h"
#import "QMUICommonDefines.h"
#import "QMUIConfiguration.h"
#import "QMUILabel.h"
#import "NSObject+QMUI.h"
#import "NSString+QMUI.h"
#import "UITextView+QMUI.h"

/// 系统 textView 默认的字号大小，用于 placeholder 默认的文字大小。实测得到，请勿修改。
const CGFloat kSystemTextViewDefaultFontPointSize = 12.0f;

/// 当系统的 textView.textContainerInset 为 UIEdgeInsetsZero 时，文字与 textView 边缘的间距。实测得到，请勿修改（在输入框font大于13时准确，小于等于12时，y有-1px的偏差）。
const UIEdgeInsets kSystemTextViewFixTextInsets = {0, 5, 0, 5};

@interface QMUITextView ()

@property(nonatomic, assign) BOOL debug;
@property(nonatomic, assign) BOOL textChangedBecauseOfPaste; // 标志本次触发对handleTextChange:的调用，是否因为粘贴
@property(nonatomic, assign) BOOL callingSizeThatFitsByAutoResizable; // 标志本次调用 sizeThatFits: 是因为 handleTextChange: 里计算高度导致的

@property(nonatomic, strong) UILabel *placeholderLabel;

@property(nonatomic, weak)   id<QMUITextViewDelegate> originalDelegate;

@end

@implementation QMUITextView

@dynamic delegate;

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self didInitialized];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
        [self didInitialized];
    }
    return self;
}

- (void)didInitialized {
    self.debug = NO;
    self.delegate = self;
    self.scrollsToTop = NO;
    self.tintColor = TextFieldTintColor;
    self.placeholderColor = UIColorPlaceholder;
    self.placeholderMargins = UIEdgeInsetsZero;
    self.autoResizable = NO;
    self.maximumTextLength = NSUIntegerMax;
    self.shouldResponseToProgrammaticallyTextChanges = YES;
    
    self.placeholderLabel = [[UILabel alloc] init];
    self.placeholderLabel.font = UIFontMake(kSystemTextViewDefaultFontPointSize);
    self.placeholderLabel.textColor = self.placeholderColor;
    self.placeholderLabel.numberOfLines = 0;
    self.placeholderLabel.alpha = 0;
    [self addSubview:self.placeholderLabel];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleTextChanged:) name:UITextViewTextDidChangeNotification object:nil];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    self.delegate = nil;
    self.originalDelegate = nil;
}

- (NSString *)description {
    return [NSString stringWithFormat:@"%@; text.length: %@ | %@; markedTextRange: %@", [super description], @(self.text.length), @([self lengthWithString:self.text]), self.markedTextRange];
}

- (void)setText:(NSString *)text {
    NSString *textBeforeChange = self.text;
    BOOL textDifferent = ![textBeforeChange isEqualToString:text];
    
    // 如果前后文字没变化，则什么都不做
    if (!textDifferent) {
        [super setText:text];
        return;
    }
    
    // 前后文字发生变化，则要根据是否主动接管 delegate 来决定是否要询问 delegate
    if (self.shouldResponseToProgrammaticallyTextChanges) {
        BOOL shouldChangeText = YES;
        if ([self.delegate respondsToSelector:@selector(textView:shouldChangeTextInRange:replacementText:)]) {
            shouldChangeText = [self.delegate textView:self shouldChangeTextInRange:NSMakeRange(0, textBeforeChange.length) replacementText:text];
        }
        
        if (!shouldChangeText) {
            // 不应该改变文字，所以连 super 都不调用，直接结束方法
            return;
        }
        
        // 应该改变文字，则调用 super 来改变文字，然后主动调用 textViewDidChange:
        [super setText:text];
        if ([self.delegate respondsToSelector:@selector(textViewDidChange:)]) {
            [self.delegate textViewDidChange:self];
        }
        
        [[NSNotificationCenter defaultCenter] postNotificationName:UITextViewTextDidChangeNotification object:self];
        
    } else {
        [super setText:text];
        
        // 如果不需要主动接管事件，则只要触发内部的监听即可，不用调用 delegate 系列方法
        [self handleTextChanged:self];
    }
}

- (void)setAttributedText:(NSAttributedString *)attributedText {
    NSString *textBeforeChange = self.attributedText.string;
    BOOL textDifferent = ![textBeforeChange isEqualToString:attributedText.string];
    
    // 如果前后文字没变化，则什么都不做
    if (!textDifferent) {
        [super setAttributedText:attributedText];
        return;
    }
    
    // 前后文字发生变化，则要根据是否主动接管 delegate 来决定是否要询问 delegate
    if (self.shouldResponseToProgrammaticallyTextChanges) {
        BOOL shouldChangeText = YES;
        if ([self.delegate respondsToSelector:@selector(textView:shouldChangeTextInRange:replacementText:)]) {
            shouldChangeText = [self.delegate textView:self shouldChangeTextInRange:NSMakeRange(0, textBeforeChange.length) replacementText:attributedText.string];
        }
        
        if (!shouldChangeText) {
            // 不应该改变文字，所以连 super 都不调用，直接结束方法
            return;
        }
        
        // 应该改变文字，则调用 super 来改变文字，然后主动调用 textViewDidChange:
        [super setAttributedText:attributedText];
        if ([self.delegate respondsToSelector:@selector(textViewDidChange:)]) {
            [self.delegate textViewDidChange:self];
        }
        
        [[NSNotificationCenter defaultCenter] postNotificationName:UITextViewTextDidChangeNotification object:self];
        
    } else {
        [super setAttributedText:attributedText];
        
        // 如果不需要主动接管事件，则只要触发内部的监听即可，不用调用 delegate 系列方法
        [self handleTextChanged:self];
    }
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

- (void)setPlaceholder:(NSString *)placeholder {
    _placeholder = placeholder;
    self.placeholderLabel.attributedText = [[NSAttributedString alloc] initWithString:_placeholder attributes:self.typingAttributes];
    if (self.placeholderColor) {
        self.placeholderLabel.textColor = self.placeholderColor;
    }
    [self sendSubviewToBack:self.placeholderLabel];
}

- (void)setPlaceholderColor:(UIColor *)placeholderColor {
    _placeholderColor = placeholderColor;
    self.placeholderLabel.textColor = _placeholderColor;
}

- (void)updatePlaceholderStyle {
    self.placeholder = self.placeholder;// 触发文字样式的更新
}

- (void)handleTextChanged:(id)sender {
    // 输入字符的时候，placeholder隐藏
    if(self.placeholder.length > 0) {
        [self updatePlaceholderLabelHidden];
    }
    
    QMUITextView *textView = nil;
    
    if ([sender isKindOfClass:[NSNotification class]]) {
        id object = ((NSNotification *)sender).object;
        if (object == self) {
            textView = (QMUITextView *)object;
        }
    } else if ([sender isKindOfClass:[QMUITextView class]]) {
        textView = (QMUITextView *)sender;
    }
    
    if (textView) {
        
        // 计算高度
        if (self.autoResizable) {
            
            // 注意，这里 iOS 8 及以下有兼容问题，请查看文件里的 sizeThatFits:
            self.callingSizeThatFitsByAutoResizable = YES;
            CGFloat resultHeight = [textView sizeThatFits:CGSizeMake(CGRectGetWidth(self.bounds), CGFLOAT_MAX)].height;
            self.callingSizeThatFitsByAutoResizable = NO;
            
            if (self.debug) NSLog(@"handleTextDidChange, text = %@, resultHeight = %f", textView.text, resultHeight);
            
            
            // 通知delegate去更新textView的高度
            if ([textView.originalDelegate respondsToSelector:@selector(textView:newHeightAfterTextChanged:)] && resultHeight != CGRectGetHeight(self.bounds)) {
                [textView.originalDelegate textView:self newHeightAfterTextChanged:resultHeight];
            }
        }
        
        // iOS7的textView在内容可滚动的情况下，最后一行输入时文字会跑到可视区域外，因此要修复一下
        // 由于我们在文字换行的瞬间更改了输入框高度，所以即便内容不可滚动，换行瞬间contentOffset也是错的，所以这里完全接管了对contentOffset的自动调整
        CGRect caretRect = [textView caretRectForPosition:textView.selectedTextRange.end];
        if (self.debug) NSLog(@"调整前，caretRect.maxY = %f, contentOffset.y = %f, bounds.height = %f", CGRectGetMaxY(caretRect), textView.contentOffset.y, CGRectGetHeight(textView.bounds));
        
        CGFloat caretMarginBottom = self.textContainerInset.bottom;
        if (ceil(CGRectGetMaxY(caretRect) + caretMarginBottom) >= textView.contentOffset.y + CGRectGetHeight(textView.bounds)) {
            CGFloat contentOffsetY = MAX(0, CGRectGetMaxY(caretRect) + caretMarginBottom - CGRectGetHeight(textView.bounds));
            if (self.debug) NSLog(@"调整后，contentOffset.y = %f", contentOffsetY);
            
            // 如果是粘贴导致光标掉出可视区域，则用动画去调整它（如果不用动画会不准，因为此时contentSize还是错的）
            // 如果是普通的键入换行导致光标掉出可视区域，则不用动画，否则会跳来跳去，但这会带来的问题就是换行没动画，不优雅😂
            [textView setContentOffset:CGPointMake(textView.contentOffset.x, contentOffsetY) animated:self.textChangedBecauseOfPaste ? YES : NO];
        }
        self.textChangedBecauseOfPaste = NO;
    }
}

- (CGSize)sizeThatFits:(CGSize)size {
    // iOS 8 调用 sizeThatFits: 会导致文字跳动，因此自己计算 https://github.com/QMUI/QMUI_iOS/issues/92
    if (IOS_VERSION < 9.0 && IOS_VERSION >= 8.0 && self.callingSizeThatFitsByAutoResizable) {
        CGFloat contentWidth = size.width - UIEdgeInsetsGetHorizontalValue(self.textContainerInset) - UIEdgeInsetsGetHorizontalValue(self.contentInset);
        CGRect textRect = [self.attributedText boundingRectWithSize:CGSizeMake(contentWidth, CGFLOAT_MAX) options:NSStringDrawingUsesLineFragmentOrigin context:nil];
        CGSize resultSize = CGSizeMake(size.width, CGRectGetHeight(textRect) + UIEdgeInsetsGetVerticalValue(self.textContainerInset) + UIEdgeInsetsGetVerticalValue(self.contentInset));
        resultSize.height = fmin(size.height, resultSize.height);
        return resultSize;
    } else {
        return [super sizeThatFits:size];
    }
}

- (void)layoutSubviews {
    [super layoutSubviews];
    if (self.placeholder.length > 0) {
        UIEdgeInsets labelMargins = UIEdgeInsetsConcat(UIEdgeInsetsConcat(self.textContainerInset, self.placeholderMargins), kSystemTextViewFixTextInsets);
        CGFloat limitWidth = CGRectGetWidth(self.bounds) - UIEdgeInsetsGetHorizontalValue(self.contentInset) - UIEdgeInsetsGetHorizontalValue(labelMargins);
        CGFloat limitHeight = CGRectGetHeight(self.bounds) - UIEdgeInsetsGetVerticalValue(self.contentInset) - UIEdgeInsetsGetVerticalValue(labelMargins);
        CGSize labelSize = [self.placeholderLabel sizeThatFits:CGSizeMake(limitWidth, limitHeight)];
        labelSize.height = fminf(limitHeight, labelSize.height);
        self.placeholderLabel.frame = CGRectFlatMake(labelMargins.left, labelMargins.top, limitWidth, labelSize.height);
    }
}

- (void)drawRect:(CGRect)rect {
    [super drawRect:rect];
    [self updatePlaceholderLabelHidden];
}

- (void)updatePlaceholderLabelHidden {
    if (self.text.length == 0 && self.placeholder.length > 0) {
        self.placeholderLabel.alpha = 1;
    } else {
        self.placeholderLabel.alpha = 0;// 用alpha来让placeholder隐藏，从而尽量避免因为显隐 placeholder 导致 layout
    }
}

- (void)paste:(id)sender {
    self.textChangedBecauseOfPaste = YES;
    [super paste:sender];
}

- (NSUInteger)lengthWithString:(NSString *)string {
    return self.shouldCountingNonASCIICharacterAsTwo ? string.qmui_lengthWhenCountingNonASCIICharacterAsTwo : string.length;
}

#pragma mark - <QMUITextViewDelegate>

- (BOOL)textView:(QMUITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    if (self.debug) NSLog(@"textView.text(%@ | %@) = %@\nmarkedTextRange = %@\nrange = %@\ntext = %@", @(textView.text.length), @(textView.text.qmui_lengthWhenCountingNonASCIICharacterAsTwo), textView.text, textView.markedTextRange, NSStringFromRange(range), text);
    
    if ([text isEqualToString:@"\n"]) {
        if ([self.delegate respondsToSelector:@selector(textViewShouldReturn:)]) {
            BOOL shouldReturn = [self.delegate textViewShouldReturn:self];
            if (shouldReturn) {
                return NO;
            }
        }
    }
    
    if (textView.maximumTextLength < NSUIntegerMax) {
        
        // 如果是中文输入法正在输入拼音的过程中（markedTextRange 不为 nil），是不应该限制字数的（例如输入“huang”这5个字符，其实只是为了输入“黄”这一个字符），所以在 shouldChange 这里不会限制，而是放在 didChange 那里限制。
        BOOL isDeleting = range.length > 0 && text.length <= 0;
        if (isDeleting || textView.markedTextRange) {
            
            if ([textView.originalDelegate respondsToSelector:_cmd]) {
                return [textView.originalDelegate textView:textView shouldChangeTextInRange:range replacementText:text];
            }
            
            return YES;
        }
        
        NSUInteger rangeLength = self.shouldCountingNonASCIICharacterAsTwo ? [textView.text substringWithRange:range].qmui_lengthWhenCountingNonASCIICharacterAsTwo : range.length;
        BOOL textWillOutofMaximumTextLength = [self lengthWithString:textView.text] - rangeLength + [self lengthWithString:text] > textView.maximumTextLength;
        if (textWillOutofMaximumTextLength) {
            // 当输入的文本达到最大长度限制后，此时继续点击 return 按钮（相当于尝试插入“\n”），就会认为总文字长度已经超过最大长度限制，所以此次 return 按钮的点击被拦截，外界无法感知到有这个 return 事件发生，所以这里为这种情况做了特殊保护
            if ([self lengthWithString:textView.text] - rangeLength == textView.maximumTextLength && [text isEqualToString:@"\n"]) {
                if ([textView.originalDelegate respondsToSelector:_cmd]) {
                    // 不管外面 return YES 或 NO，都不允许输入了，否则会超出 maximumTextLength。
                    [textView.originalDelegate textView:textView shouldChangeTextInRange:range replacementText:text];
                    return NO;
                }
            }
            // 将要插入的文字裁剪成多长，就可以让它插入了
            NSInteger substringLength = textView.maximumTextLength - [self lengthWithString:textView.text] + rangeLength;
            
            if (substringLength > 0 && [self lengthWithString:text] > substringLength) {
                NSString *allowedText = [text qmui_substringAvoidBreakingUpCharacterSequencesWithRange:NSMakeRange(0, substringLength) lessValue:YES countingNonASCIICharacterAsTwo:self.shouldCountingNonASCIICharacterAsTwo];
                if ([self lengthWithString:allowedText] <= substringLength) {
                    textView.text = [textView.text stringByReplacingCharactersInRange:range withString:allowedText];
                    textView.selectedRange = NSMakeRange(range.location + substringLength, 0);
                    
                    if (!textView.shouldResponseToProgrammaticallyTextChanges) {
                        [textView.originalDelegate textViewDidChange:textView];
                    }
                }
            }
            
            if ([self.originalDelegate respondsToSelector:@selector(textView:didPreventTextChangeInRange:replacementText:)]) {
                [self.originalDelegate textView:textView didPreventTextChangeInRange:range replacementText:text];
            }
            return NO;
        }
    }
    
    if ([textView.originalDelegate respondsToSelector:_cmd]) {
        return [textView.originalDelegate textView:textView shouldChangeTextInRange:range replacementText:text];
    }
    
    return YES;
}

- (void)textViewDidChange:(QMUITextView *)textView {
    // 1、iOS 10 以下的版本，从中文输入法的候选词里选词输入，是不会走到 textView:shouldChangeTextInRange:replacementText: 的，所以要在这里截断文字
    // 2、如果是中文输入法正在输入拼音的过程中（markedTextRange 不为 nil），是不应该限制字数的（例如输入“huang”这5个字符，其实只是为了输入“黄”这一个字符），所以在 shouldChange 那边不会限制，而是放在 didChange 这里限制。
    if (!textView.markedTextRange) {
        if ([self lengthWithString:textView.text] > textView.maximumTextLength) {
            
            textView.text = [textView.text qmui_substringAvoidBreakingUpCharacterSequencesWithRange:NSMakeRange(0, textView.maximumTextLength) lessValue:YES countingNonASCIICharacterAsTwo:self.shouldCountingNonASCIICharacterAsTwo];
            
            if ([self.originalDelegate respondsToSelector:@selector(textView:didPreventTextChangeInRange:replacementText:)]) {
                // 如果是在这里被截断，是无法得知截断前光标所处的位置及要输入的文本的，所以只能将当前的 selectedRange 传过去，而 replacementText 为 nil
                [self.originalDelegate textView:textView didPreventTextChangeInRange:textView.selectedRange replacementText:nil];
            }
            
            if (textView.shouldResponseToProgrammaticallyTextChanges) {
                return;
            }
        }
    }
    if ([textView.originalDelegate respondsToSelector:_cmd]) {
        [textView.originalDelegate textViewDidChange:textView];
    }
}

#pragma mark - Delegate Proxy

- (void)setDelegate:(id<QMUITextViewDelegate>)delegate {
    self.originalDelegate = delegate != self ? delegate : nil;
    [super setDelegate:delegate ? self : nil];
}

- (NSMethodSignature *)methodSignatureForSelector:(SEL)aSelector {
    NSMethodSignature *a = [super methodSignatureForSelector:aSelector];
    NSMethodSignature *b = [(id)self.originalDelegate methodSignatureForSelector:aSelector];
    NSMethodSignature *result = a ? a : b;
    return result;
}

- (void)forwardInvocation:(NSInvocation *)anInvocation {
    if ([(id)self.originalDelegate respondsToSelector:anInvocation.selector]) {
        [anInvocation invokeWithTarget:(id)self.originalDelegate];
    }
}

- (BOOL)respondsToSelector:(SEL)aSelector {
    BOOL a = [super respondsToSelector:aSelector];
    BOOL c = [self.originalDelegate respondsToSelector:aSelector];
    BOOL result = a || c;
    return result;
}

// 下面这两个方法比较特殊，无法通过 forwardInvocation: 的方式把消息发送给 self.originalDelegate，只会直接被调用，所以只能在 QMUITextView 内部实现这连个方法然后调用 originalDelegate 的对应方法
// 注意，测过 UITextView 默认没有实现任何 UIScrollViewDelegate 方法 from 2016-11-01 in iOS 10.1 by molice

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if ([self.originalDelegate respondsToSelector:_cmd]) {
        [self.originalDelegate scrollViewDidScroll:scrollView];
    }
}

- (void)scrollViewDidZoom:(UIScrollView *)scrollView {
    if ([self.originalDelegate respondsToSelector:_cmd]) {
        [self.originalDelegate scrollViewDidZoom:scrollView];
    }
}

@end
