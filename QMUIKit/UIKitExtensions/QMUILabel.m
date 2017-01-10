//
//  QMUILabel.m
//  qmui
//
//  Created by QQMail on 14-7-3.
//  Copyright (c) 2014年 QMUI Team. All rights reserved.
//

#import "QMUILabel.h"
#import "QMUICommonDefines.h"
#import "QMUIConfiguration.h"

@interface QMUILabel ()

@property(nonatomic, strong) UIColor *tempBackgroundColor;
@property(nonatomic, strong) UILongPressGestureRecognizer *longGestureRecognizer;
@end


@implementation QMUILabel

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (CGSize)sizeThatFits:(CGSize)size {
    size = [super sizeThatFits:CGSizeMake(size.width - UIEdgeInsetsGetHorizontalValue(self.contentEdgeInsets), size.height - UIEdgeInsetsGetVerticalValue(self.contentEdgeInsets))];
    size.width += UIEdgeInsetsGetHorizontalValue(self.contentEdgeInsets);
    size.height += UIEdgeInsetsGetVerticalValue(self.contentEdgeInsets);
    return size;
}

- (void)drawTextInRect:(CGRect)rect {
    return [super drawTextInRect:UIEdgeInsetsInsetRect(rect, self.contentEdgeInsets)];
}

- (void)setHighlightedBackgroundColor:(UIColor *)highlightedBackgroundColor {
    if (highlightedBackgroundColor) {
        self.tempBackgroundColor = self.backgroundColor;
        _highlightedBackgroundColor = highlightedBackgroundColor;
    }
}

- (void)setHighlighted:(BOOL)highlighted {
    [super setHighlighted:highlighted];
    if (self.highlightedBackgroundColor) {
        self.backgroundColor = highlighted ? self.highlightedBackgroundColor : self.tempBackgroundColor;
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
        if (self.text) {
            pasteboard.string = self.text;
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
        UIMenuItem *copyMenuItem = [[UIMenuItem alloc] initWithTitle:@"复制" action:@selector(copyString:)];
        [[UIMenuController sharedMenuController] setMenuItems:@[copyMenuItem]];
        [menuController setTargetRect:self.frame inView:self.superview];
        [menuController setMenuVisible:YES animated:YES];
        
        // 默认背景色
        self.tempBackgroundColor = self.backgroundColor;
        self.backgroundColor = self.highlightedBackgroundColor;
    }
}

- (void)handleMenuWillHideNotification:(NSNotification *)notification {
    if (!self.canPerformCopyAction) {
        return;
    }
    if (self.tempBackgroundColor) {
        self.backgroundColor = self.tempBackgroundColor;
    }
}

@end
