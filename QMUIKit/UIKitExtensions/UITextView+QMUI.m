/**
 * Tencent is pleased to support the open source community by making QMUI_iOS available.
 * Copyright (C) 2016-2021 THL A29 Limited, a Tencent company. All rights reserved.
 * Licensed under the MIT License (the "License"); you may not use this file except in compliance with the License. You may obtain a copy of the License at
 * http://opensource.org/licenses/MIT
 * Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.
 */

//
//  UITextView+QMUI.m
//  qmui
//
//  Created by QMUI Team on 2017/3/29.
//

#import "UITextView+QMUI.h"
#import "QMUICore.h"
#import "UIScrollView+QMUI.h"

@implementation UITextView (QMUI)

- (NSRange)qmui_selectedRange {
    return [self qmui_convertNSRangeFromUITextRange:self.selectedTextRange];
}

- (NSRange)qmui_convertNSRangeFromUITextRange:(UITextRange *)textRange {
    NSInteger location = [self offsetFromPosition:self.beginningOfDocument toPosition:textRange.start];
    NSInteger length = [self offsetFromPosition:textRange.start toPosition:textRange.end];
    return NSMakeRange(location, length);
}

- (UITextRange *)qmui_convertUITextRangeFromNSRange:(NSRange)range {
    if (range.location == NSNotFound || NSMaxRange(range) > self.text.length) {
        return nil;
    }
    UITextPosition *beginning = self.beginningOfDocument;
    UITextPosition *startPosition = [self positionFromPosition:beginning offset:range.location];
    UITextPosition *endPosition = [self positionFromPosition:beginning offset:NSMaxRange(range)];
    return [self textRangeFromPosition:startPosition toPosition:endPosition];
}

- (void)qmui_setTextKeepingSelectedRange:(NSString *)text {
    UITextRange *selectedTextRange = self.selectedTextRange;
    self.text = text;
    self.selectedTextRange = selectedTextRange;
}

- (void)qmui_setAttributedTextKeepingSelectedRange:(NSAttributedString *)attributedText {
    UITextRange *selectedTextRange = self.selectedTextRange;
    self.attributedText = attributedText;
    self.selectedTextRange = selectedTextRange;
}

- (void)qmui_scrollRangeToVisible:(NSRange)range {
    if (CGRectIsEmpty(self.bounds)) return;
    
    UITextRange *textRange = [self qmui_convertUITextRangeFromNSRange:range];
    if (!textRange) return;
    
    NSArray<UITextSelectionRect *> *selectionRects = [self selectionRectsForRange:textRange];
    CGRect rect = CGRectZero;
    for (UITextSelectionRect *selectionRect in selectionRects) {
        if (!CGRectIsEmpty(selectionRect.rect)) {
            if (CGRectIsEmpty(rect)) {
                rect = selectionRect.rect;
            } else {
                rect = CGRectUnion(rect, selectionRect.rect);
            }
        }
    }
    if (!CGRectIsEmpty(rect)) {
        rect = [self convertRect:rect fromView:self.textInputView];
        [self _scrollRectToVisible:rect animated:YES];
    }
}

- (void)qmui_scrollCaretVisibleAnimated:(BOOL)animated {
    if (CGRectIsEmpty(self.bounds)) return;
    
    CGRect caretRect = [self caretRectForPosition:self.selectedTextRange.end];
    [self _scrollRectToVisible:caretRect animated:animated];
}

- (void)_scrollRectToVisible:(CGRect)rect animated:(BOOL)animated {
    // scrollEnabled 为 NO 时可能产生不合法的 rect 值 https://github.com/Tencent/QMUI_iOS/issues/205
    if (!CGRectIsValidated(rect)) {
        return;
    }
    
    CGFloat contentOffsetY = self.contentOffset.y;
    
    BOOL canScroll = self.qmui_canScroll;
    if (canScroll) {
        if (CGRectGetMinY(rect) < contentOffsetY + self.textContainerInset.top) {
            // 光标在可视区域上方，往下滚动
            contentOffsetY = CGRectGetMinY(rect) - self.textContainerInset.top - self.adjustedContentInset.top;
        } else if (CGRectGetMaxY(rect) > contentOffsetY + CGRectGetHeight(self.bounds) - self.textContainerInset.bottom - self.adjustedContentInset.bottom) {
            // 光标在可视区域下方，往上滚动
            contentOffsetY = CGRectGetMaxY(rect) - CGRectGetHeight(self.bounds) + self.textContainerInset.bottom + self.adjustedContentInset.bottom;
        } else {
            // 光标在可视区域，不用滚动
        }
        CGFloat contentOffsetWhenScrollToTop = -self.adjustedContentInset.top;
        CGFloat contentOffsetWhenScrollToBottom = self.contentSize.height + self.adjustedContentInset.bottom - CGRectGetHeight(self.bounds);
        contentOffsetY = MAX(MIN(contentOffsetY, contentOffsetWhenScrollToBottom), contentOffsetWhenScrollToTop);
    } else {
        contentOffsetY = -self.adjustedContentInset.top;
    }
    [self setContentOffset:CGPointMake(self.contentOffset.x, contentOffsetY) animated:animated];
}

@end
