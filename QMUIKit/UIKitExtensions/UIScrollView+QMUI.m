/*****
 * Tencent is pleased to support the open source community by making QMUI_iOS available.
 * Copyright (C) 2016-2018 THL A29 Limited, a Tencent company. All rights reserved.
 * Licensed under the MIT License (the "License"); you may not use this file except in compliance with the License. You may obtain a copy of the License at
 * http://opensource.org/licenses/MIT
 * Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.
 *****/
//
//  UIScrollView+QMUI.m
//  qmui
//
//  Created by ZhoonChen on 15/7/20.
//

#import "UIScrollView+QMUI.h"
#import "QMUICore.h"

@implementation UIScrollView (QMUI)

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        ExchangeImplementations([self class], @selector(description), @selector(qmui_description));
    });
}

- (NSString *)qmui_description {
    return [NSString stringWithFormat:@"%@, contentInset = %@", [self qmui_description], NSStringFromUIEdgeInsets(self.contentInset)];
}

- (BOOL)qmui_alreadyAtTop {
    if (((NSInteger)self.contentOffset.y) == -((NSInteger)self.qmui_contentInset.top)) {
        return YES;
    }
    
    return NO;
}

- (BOOL)qmui_alreadyAtBottom {
    if (!self.qmui_canScroll) {
        return YES;
    }
    
    if (((NSInteger)self.contentOffset.y) == ((NSInteger)self.contentSize.height + self.qmui_contentInset.bottom - CGRectGetHeight(self.bounds))) {
        return YES;
    }
    
    return NO;
}

- (UIEdgeInsets)qmui_contentInset {
    if (@available(iOS 11, *)) {
        return self.adjustedContentInset;
    } else {
        return self.contentInset;
    }
}

- (BOOL)qmui_canScroll {
    // 没有高度就不用算了，肯定不可滚动，这里只是做个保护
    if (CGSizeIsEmpty(self.bounds.size)) {
        return NO;
    }
    BOOL canVerticalScroll = self.contentSize.height + UIEdgeInsetsGetVerticalValue(self.qmui_contentInset) > CGRectGetHeight(self.bounds);
    BOOL canHorizontalScoll = self.contentSize.width + UIEdgeInsetsGetHorizontalValue(self.qmui_contentInset) > CGRectGetWidth(self.bounds);
    return canVerticalScroll || canHorizontalScoll;
}

- (void)qmui_scrollToTopForce:(BOOL)force animated:(BOOL)animated {
    if (force || (!force && [self qmui_canScroll])) {
        [self setContentOffset:CGPointMake(-self.qmui_contentInset.left, -self.qmui_contentInset.top) animated:animated];
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
        [self setContentOffset:CGPointMake(self.contentOffset.x, self.contentSize.height + self.qmui_contentInset.bottom - CGRectGetHeight(self.bounds)) animated:animated];
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
