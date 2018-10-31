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
        
        __weak __typeof(self)weakSelf = self;
        
        self.adjustsOffsetYWithInsetTopAutomatically = YES;
        
        self.didScrollBlock = ^(QMUINavigationBarScrollingSnapAnimator * _Nonnull animator) {
            if (!weakSelf.navigationBar) {
                UINavigationBar *navigationBar = [QMUIHelper visibleViewController].navigationController.navigationBar;
                if (navigationBar) {
                    weakSelf.navigationBar = navigationBar;
                }
            }
            if (!weakSelf.navigationBar) {
                NSLog(@"无法自动找到 UINavigationBar，请通过 %@.%@ 手动设置一个", NSStringFromClass(weakSelf.class), NSStringFromSelector(@selector(navigationBar)));
                return;
            }
            
            if (weakSelf.animationBlock) {
                if (weakSelf.offsetYReached) {
                    if (!weakSelf.alreadyCalledScrollDownAnimation) {
                        weakSelf.animationBlock(weakSelf, YES);
                        weakSelf.alreadyCalledScrollDownAnimation = YES;
                        weakSelf.alreadyCalledScrollUpAnimation = NO;
                    }
                } else {
                    if (!weakSelf.alreadyCalledScrollUpAnimation) {
                        weakSelf.animationBlock(weakSelf, NO);
                        weakSelf.alreadyCalledScrollUpAnimation = YES;
                        weakSelf.alreadyCalledScrollDownAnimation = NO;
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
