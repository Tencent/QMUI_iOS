/*****
 * Tencent is pleased to support the open source community by making QMUI_iOS available.
 * Copyright (C) 2016-2019 THL A29 Limited, a Tencent company. All rights reserved.
 * Licensed under the MIT License (the "License"); you may not use this file except in compliance with the License. You may obtain a copy of the License at
 * http://opensource.org/licenses/MIT
 * Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.
 *****/

//
//  QMUILabel.m
//  qmui
//
//  Created by QMUI Team on 14-7-3.
//

#import "QMUILabel.h"
#import "QMUICore.h"

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

- (void)drawTextInRect:(CGRect)rect {
    rect = UIEdgeInsetsInsetRect(rect, self.contentEdgeInsets);
    
    // 在某些情况下文字位置错误，因此做了如下保护
    // https://github.com/Tencent/QMUI_iOS/issues/529
    if (self.numberOfLines == 1 && (self.lineBreakMode == NSLineBreakByWordWrapping || self.lineBreakMode == NSLineBreakByCharWrapping)) {
        rect = CGRectSetHeight(rect, CGRectGetHeight(rect) + self.contentEdgeInsets.top * 2);
    }
    
    [super drawTextInRect:rect];
}

- (void)setHighlightedBackgroundColor:(UIColor *)highlightedBackgroundColor {
    _highlightedBackgroundColor = highlightedBackgroundColor;
    
    if (highlightedBackgroundColor) {
        self.originalBackgroundColor = self.backgroundColor;
    }
}

- (void)setHighlighted:(BOOL)highlighted {
    [super setHighlighted:highlighted];
    
    if (self.highlightedBackgroundColor) {
        self.backgroundColor = highlighted ? self.highlightedBackgroundColor : self.originalBackgroundColor;
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
        
        if (!self.highlightedBackgroundColor) {
            self.highlightedBackgroundColor = TableViewCellSelectedBackgroundColor; // 设置个默认值
        }
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
        
        [self setHighlighted:YES];
    } else if (gestureRecognizer.state == UIGestureRecognizerStatePossible) {
        [self setHighlighted:NO];
    }
}

- (void)handleMenuWillHideNotification:(NSNotification *)notification {
    if (!self.canPerformCopyAction) {
        return;
    }
    
    [self setHighlighted:NO];
}

@end
