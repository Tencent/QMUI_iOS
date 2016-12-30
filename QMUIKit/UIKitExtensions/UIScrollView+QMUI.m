//
//  UIScrollView+QMUI.m
//  qmui
//
//  Created by ZhoonChen on 15/7/20.
//  Copyright (c) 2015年 QMUI Team. All rights reserved.
//

#import "UIScrollView+QMUI.h"
#import "QMUICommonDefines.h"
#import "QMUIConfiguration.h"

@implementation UIScrollView (QMUI)

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        ReplaceMethod([self class], @selector(description), @selector(qmui_description));
    });
}

- (NSString *)qmui_description {
    return [NSString stringWithFormat:@"%@, contentInset = %@", [self qmui_description], NSStringFromUIEdgeInsets(self.contentInset)];
}

- (BOOL)qmui_alreadyAtTop {
    if (!self.qmui_canScroll) {
        return YES;
    }
    
    if (self.contentOffset.y == -self.contentInset.top) {
        return YES;
    }
    
    return NO;
}

- (BOOL)qmui_alreadyAtBottom {
    if (!self.qmui_canScroll) {
        return YES;
    }
    
    if (self.contentOffset.y == self.contentSize.height + self.contentInset.bottom - CGRectGetHeight(self.bounds)) {
        return YES;
    }
    
    return NO;
}

- (BOOL)qmui_canScroll {
    // 没有高度就不用算了，肯定不可滚动，这里只是做个保护
    if (CGSizeIsEmpty(self.bounds.size)) {
        return NO;
    }
    BOOL canVerticalScroll = self.contentSize.height + UIEdgeInsetsGetVerticalValue(self.contentInset) > CGRectGetHeight(self.bounds);
    BOOL canHorizontalScoll = self.contentSize.width + UIEdgeInsetsGetHorizontalValue(self.contentInset) > CGRectGetWidth(self.bounds);
    return canVerticalScroll || canHorizontalScoll;
}

- (void)qmui_scrollToTopForce:(BOOL)force animated:(BOOL)animated {
    if (force || (!force && [self qmui_canScroll])) {
        [self setContentOffset:CGPointMake(-self.contentInset.left, -self.contentInset.top) animated:animated];
    }
}

- (void)qmui_scrollToTopAnimated:(BOOL)animated {
    [self qmui_scrollToTopForce:NO animated:animated];
}

- (void)qmui_scrollToTop {
    [self qmui_scrollToTopAnimated:NO];
}

- (void)qmui_scrollToBottomAnimated:(BOOL)animated {
    if ([self qmui_canScroll]) {
        [self setContentOffset:CGPointMake(self.contentOffset.x, self.contentSize.height + self.contentInset.bottom - CGRectGetHeight(self.bounds)) animated:animated];
    }
}

- (void)qmui_scrollToBottom {
    [self qmui_scrollToBottomAnimated:NO];
}

- (void)qmui_stopDeceleratingIfNeeded {
    if (self.decelerating) {
        [self setContentOffset:self.contentOffset animated:NO];
    }
}

@end
