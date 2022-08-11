/**
 * Tencent is pleased to support the open source community by making QMUI_iOS available.
 * Copyright (C) 2016-2021 THL A29 Limited, a Tencent company. All rights reserved.
 * Licensed under the MIT License (the "License"); you may not use this file except in compliance with the License. You may obtain a copy of the License at
 * http://opensource.org/licenses/MIT
 * Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.
 */

//
//  QMUILabel.m
//  qmui
//
//  Created by QMUI Team on 14-7-3.
//

#import "QMUILabel.h"
#import "QMUICore.h"
#import "UILabel+QMUI.h"

@interface QMUILabel ()

@property(nonatomic, strong) UIColor *originalBackgroundColor;
@property(nonatomic, strong) UILongPressGestureRecognizer *longGestureRecognizer;
@end


@implementation QMUILabel

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)setContentEdgeInsets:(UIEdgeInsets)contentEdgeInsets {
    _contentEdgeInsets = contentEdgeInsets;
    [self setNeedsDisplay];
}

- (CGSize)sizeThatFits:(CGSize)size {
    size = [super sizeThatFits:CGSizeMake(size.width - UIEdgeInsetsGetHorizontalValue(self.contentEdgeInsets), size.height - UIEdgeInsetsGetVerticalValue(self.contentEdgeInsets))];
    size.width += UIEdgeInsetsGetHorizontalValue(self.contentEdgeInsets);
    size.height += UIEdgeInsetsGetVerticalValue(self.contentEdgeInsets);
    return size;
}

- (CGSize)intrinsicContentSize {
    CGFloat preferredMaxLayoutWidth = self.preferredMaxLayoutWidth;
    if (preferredMaxLayoutWidth <= 0) {
        preferredMaxLayoutWidth = CGFLOAT_MAX;
    }
    return [self sizeThatFits:CGSizeMake(preferredMaxLayoutWidth, CGFLOAT_MAX)];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    if (self.truncatingTailView && self.attributedText.length) {
        [self bringSubviewToFront:self.truncatingTailView];
        
        // 不能通过修改 numberOfLines = 0 再恢复它的值，来计算高度是否折叠了，因为修改它的值会触发 layout，从而陷入死循环，所以这里只能通过 NSAttributedString 来计算内容的实际高度。注意如果 lineBreakMode 为 Tail 的话，NSAttributedString 必定只能计算单行的高度，所以要手动改为非 Tail 的值
        CGSize limitSize = CGSizeMake(CGRectGetWidth(self.bounds) - UIEdgeInsetsGetHorizontalValue(self.contentEdgeInsets), CGFLOAT_MAX);
        NSMutableAttributedString *string = self.attributedText.mutableCopy;
        if (self.numberOfLines != 1 && self.lineBreakMode == NSLineBreakByTruncatingTail) {
            NSParagraphStyle *p = [string attribute:NSParagraphStyleAttributeName atIndex:0 effectiveRange:nil];
            if (p) {
                NSMutableParagraphStyle *mutableP = p.mutableCopy;
                mutableP.lineBreakMode = NSLineBreakByWordWrapping;
                [string addAttribute:NSParagraphStyleAttributeName value:mutableP range:NSMakeRange(0, string.length)];
            }
        }
        CGSize realSize = [string boundingRectWithSize:limitSize options:NSStringDrawingUsesLineFragmentOrigin context:nil].size;
        BOOL shouldShowTruncatingTailView = realSize.height > CGRectGetHeight(self.bounds);
        self.truncatingTailView.hidden = !shouldShowTruncatingTailView;
        if (!self.truncatingTailView.hidden) {
            CGFloat lineHeight = self.qmui_lineHeight;
            [self.truncatingTailView sizeToFit];
            self.truncatingTailView.frame = CGRectMake(CGRectGetWidth(self.bounds) - self.contentEdgeInsets.right - CGRectGetWidth(self.truncatingTailView.frame), CGRectGetHeight(self.bounds) - self.contentEdgeInsets.bottom - lineHeight, CGRectGetWidth(self.truncatingTailView.frame), lineHeight);
        }
    }
}

- (void)drawTextInRect:(CGRect)rect {
    rect = UIEdgeInsetsInsetRect(rect, self.contentEdgeInsets);
    
    // 在某些情况下文字位置错误，因此做了如下保护
    // https://github.com/Tencent/QMUI_iOS/issues/529
    if (self.numberOfLines == 1 && (self.lineBreakMode == NSLineBreakByWordWrapping || self.lineBreakMode == NSLineBreakByCharWrapping)) {
        rect = CGRectSetHeight(rect, CGRectGetHeight(rect) + self.contentEdgeInsets.top * 2);
    }
    
    [super drawTextInRect:rect];
}

- (void)setHighlighted:(BOOL)highlighted {
    [super setHighlighted:highlighted];
    
    if (self.highlightedBackgroundColor) {
        [super setBackgroundColor:highlighted ? self.highlightedBackgroundColor : self.originalBackgroundColor];
    }
}

- (void)setBackgroundColor:(UIColor *)backgroundColor {
    self.originalBackgroundColor = backgroundColor;
    
    // 在出现 menu 的时候 backgroundColor 被修改，此时也不应该立马显示新的 backgroundColor
    if (self.highlighted && self.highlightedBackgroundColor) {
        return;
    }
    
    [super setBackgroundColor:backgroundColor];
}

// 当 label.highlighted = YES 时 backgroundColor 的 getter 会返回 self.highlightedBackgroundColor，因此如果在 highlighted = YES 时外部刚好执行了 `label.backgroundColor = label.backgroundColor` 就会导致 label 的背景色被错误地设置为高亮时的背景色，所以这里需要重写 getter 返回内部记录的 originalBackgroundColor
- (UIColor *)backgroundColor {
    return self.originalBackgroundColor;
}

#pragma mark - 自定义缩略点点点按钮

- (void)setTruncatingTailView:(__kindof UIView *)truncatingTailView {
    if (_truncatingTailView != truncatingTailView) {
        [_truncatingTailView removeFromSuperview];
        _truncatingTailView = truncatingTailView;
        [self addSubview:_truncatingTailView];
        _truncatingTailView.hidden = YES;
        [self setNeedsLayout];
    }
}

#pragma mark - 长按复制功能

- (void)setCanPerformCopyAction:(BOOL)canPerformCopyAction {
    _canPerformCopyAction = canPerformCopyAction;
    if (_canPerformCopyAction && !self.longGestureRecognizer) {
        self.userInteractionEnabled = YES;
        self.longGestureRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleLongPressGestureRecognizer:)];
        [self addGestureRecognizer:self.longGestureRecognizer];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleMenuWillHideNotification:) name:UIMenuControllerWillHideMenuNotification object:nil];
    } else if (!_canPerformCopyAction && self.longGestureRecognizer) {
        [self removeGestureRecognizer:self.longGestureRecognizer];
        self.longGestureRecognizer = nil;
        self.userInteractionEnabled = NO;
        
        [[NSNotificationCenter defaultCenter] removeObserver:self];
    }
}

- (BOOL)canBecomeFirstResponder {
    return self.canPerformCopyAction;
}

- (BOOL)canPerformAction:(SEL)action withSender:(id)sender {
    if ([self canBecomeFirstResponder]) {
        return action == @selector(copyString:);
    }
    return NO;
}

- (void)copyString:(id)sender {
    if (self.canPerformCopyAction) {
        UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
        NSString *stringToCopy = self.text;
        if (stringToCopy) {
            pasteboard.string = stringToCopy;
            if (self.didCopyBlock) {
                self.didCopyBlock(self, stringToCopy);
            }
        }
    }
}

- (void)handleLongPressGestureRecognizer:(UIGestureRecognizer *)gestureRecognizer {
    if (!self.canPerformCopyAction) {
        return;
    }
    if (gestureRecognizer.state == UIGestureRecognizerStateBegan) {
        [self becomeFirstResponder];
        UIMenuController *menuController = [UIMenuController sharedMenuController];
        UIMenuItem *copyMenuItem = [[UIMenuItem alloc] initWithTitle:self.menuItemTitleForCopyAction ?: @"复制" action:@selector(copyString:)];
        [[UIMenuController sharedMenuController] setMenuItems:@[copyMenuItem]];
        [menuController setTargetRect:self.frame inView:self.superview];
        [menuController setMenuVisible:YES animated:YES];
        
        self.highlighted = YES;
    } else if (gestureRecognizer.state == UIGestureRecognizerStatePossible) {
        self.highlighted = NO;
    }
}

- (void)handleMenuWillHideNotification:(NSNotification *)notification {
    if (!self.canPerformCopyAction) {
        return;
    }
    
    [self setHighlighted:NO];
}

@end
