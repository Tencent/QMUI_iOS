/**
 * Tencent is pleased to support the open source community by making QMUI_iOS available.
 * Copyright (C) 2016-2021 THL A29 Limited, a Tencent company. All rights reserved.
 * Licensed under the MIT License (the "License"); you may not use this file except in compliance with the License. You may obtain a copy of the License at
 * http://opensource.org/licenses/MIT
 * Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.
 */

//
//  QMUINavigationBarScrollingSnapAnimator.m
//  QMUIKit
//
//  Created by QMUI Team on 2018/S/30.
//

#import "QMUINavigationBarScrollingSnapAnimator.h"
#import "UIViewController+QMUI.h"
#import "UIScrollView+QMUI.h"
#import "UIView+QMUI.h"

@interface QMUINavigationBarScrollingSnapAnimator ()

@property(nonatomic, assign) BOOL alreadyCalledScrollDownAnimation;
@property(nonatomic, assign) BOOL alreadyCalledScrollUpAnimation;
@end

@implementation QMUINavigationBarScrollingSnapAnimator

- (instancetype)init {
    self = [super init];
    if (self) {
        
        self.adjustsOffsetYWithInsetTopAutomatically = YES;
        
        self.didScrollBlock = ^(QMUINavigationBarScrollingSnapAnimator * _Nonnull animator) {
            UINavigationBar *navigationBar = animator.navigationBar;
            if (!navigationBar) {
                navigationBar = animator.scrollView.qmui_viewController.navigationController.navigationBar;
                if (!navigationBar) {
                    NSLog(@"无法自动找到 UINavigationBar，或许此时 scrollView 所在的 viewController 已经不存在于 UINavigationController 里。");
                    return;
                }
            }
            
            if (animator.animationBlock) {
                if (animator.offsetYReached) {
                    if (animator.continuous || !animator.alreadyCalledScrollDownAnimation) {
                        animator.animationBlock(animator, YES);
                        animator.alreadyCalledScrollDownAnimation = YES;
                        animator.alreadyCalledScrollUpAnimation = NO;
                    }
                } else {
                    if (animator.continuous || !animator.alreadyCalledScrollUpAnimation) {
                        animator.animationBlock(animator, NO);
                        animator.alreadyCalledScrollUpAnimation = YES;
                        animator.alreadyCalledScrollDownAnimation = NO;
                    }
                }
            }
        };
    }
    return self;
}

- (BOOL)offsetYReached {
    UIScrollView *scrollView = self.scrollView;
    CGFloat contentOffsetY = flat(scrollView.contentOffset.y);
    CGFloat offsetYToStartAnimation = flat(self.offsetYToStartAnimation + (self.adjustsOffsetYWithInsetTopAutomatically ? -scrollView.adjustedContentInset.top : 0));
    return contentOffsetY > offsetYToStartAnimation;
}

- (void)setOffsetYToStartAnimation:(CGFloat)offsetYToStartAnimation {
    BOOL valueChanged = _offsetYToStartAnimation != offsetYToStartAnimation;
    _offsetYToStartAnimation = offsetYToStartAnimation;
    if (valueChanged) {
        [self resetState];
    }
}

- (void)setScrollView:(__kindof UIScrollView *)scrollView {
    BOOL scrollViewChanged = self.scrollView != scrollView;
    [super setScrollView:scrollView];
    if (scrollViewChanged) {
        [self resetState];
    }
}

- (void)resetState {
    self.alreadyCalledScrollUpAnimation = NO;
    self.alreadyCalledScrollDownAnimation = NO;
    [self updateScroll];
}

@end
