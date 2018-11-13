//
//  QMUIScrollAnimator.m
//  QMUIKit
//
//  Created by MoLice on 2018/S/30.
//  Copyright © 2018 QMUI Team. All rights reserved.
//

#import "QMUIScrollAnimator.h"
#import "QMUIMultipleDelegates.h"
#import "UIScrollView+QMUI.h"

@interface QMUIScrollAnimator ()

@property(nonatomic, assign) BOOL scrollViewMultipleDelegatesEnabledBeforeSet;
@property(nonatomic, weak) id<UIScrollViewDelegate> scrollViewDelegateBeforeSet;
@end

@implementation QMUIScrollAnimator

- (instancetype)init {
    if (self = [super init]) {
        self.enabled = YES;
    }
    return self;
}

- (void)setScrollView:(__kindof UIScrollView *)scrollView {
    if (scrollView) {
        self.scrollViewMultipleDelegatesEnabledBeforeSet = scrollView.qmui_multipleDelegatesEnabled;
        self.scrollViewDelegateBeforeSet = scrollView.delegate;
        scrollView.qmui_multipleDelegatesEnabled = YES;
        scrollView.delegate = self;
    } else {
        _scrollView.qmui_multipleDelegatesEnabled = self.scrollViewMultipleDelegatesEnabledBeforeSet;
        if (_scrollView.qmui_multipleDelegatesEnabled) {
            [((QMUIMultipleDelegates *)_scrollView.delegate) removeDelegate:self];
        } else {
            _scrollView.delegate = self.scrollViewDelegateBeforeSet;
        }
    }
    _scrollView = scrollView;
}

- (void)updateScroll {
    [self scrollViewDidScroll:self.scrollView];
}

#pragma mark - <UIScrollViewDelegate>

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (self.enabled && scrollView == self.scrollView && scrollView.window && self.didScrollBlock) {
        self.didScrollBlock(self);
    }
}

@end
