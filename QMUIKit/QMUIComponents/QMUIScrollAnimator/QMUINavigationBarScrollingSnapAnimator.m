//
//  QMUINavigationBarScrollingSnapAnimator.m
//  QMUIKit
//
//  Created by MoLice on 2018/S/30.
//  Copyright © 2018 QMUI Team. All rights reserved.
//

#import "QMUINavigationBarScrollingSnapAnimator.h"
#import "UINavigationBar+QMUI.h"
#import "UIViewController+QMUI.h"
#import "UIScrollView+QMUI.h"

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
            if (!animator.navigationBar) {
                UINavigationBar *navigationBar = [QMUIHelper visibleViewController].navigationController.navigationBar;
                if (navigationBar) {
                    animator.navigationBar = navigationBar;
                }
            }
            if (!animator.navigationBar) {
                NSLog(@"无法自动找到 UINavigationBar，请通过 %@.%@ 手动设置一个", NSStringFromClass(animator.class), NSStringFromSelector(@selector(navigationBar)));
                return;
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
    CGFloat offsetYToStartAnimation = self.offsetYToStartAnimation + (self.adjustsOffsetYWithInsetTopAutomatically ? -scrollView.qmui_contentInset.top : 0);
    return scrollView.contentOffset.y > offsetYToStartAnimation;
}

@end
