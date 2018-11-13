//
//  QMUINavigationBarScrollingAnimator.m
//  QMUIKit
//
//  Created by MoLice on 2018/O/16.
//  Copyright © 2018 QMUI Team. All rights reserved.
//

#import "QMUINavigationBarScrollingAnimator.h"
#import "UIViewController+QMUI.h"
#import "UIScrollView+QMUI.h"

@interface QMUINavigationBarScrollingAnimator ()

@property(nonatomic, assign) BOOL progressZeroReached;
@property(nonatomic, assign) BOOL progressOneReached;
@end

@implementation QMUINavigationBarScrollingAnimator

- (instancetype)init {
    self = [super init];
    if (self) {
        
        self.adjustsOffsetYWithInsetTopAutomatically = YES;
        
        self.distanceToStopAnimation = 44;
        
        self.didScrollBlock = ^(QMUINavigationBarScrollingAnimator * _Nonnull animator) {
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
            
            CGFloat progress = animator.progress;
            
            if (!animator.continuous && ((progress <= 0 && animator.progressZeroReached) || (progress >= 1 && animator.progressOneReached))) {
                return;
            }
            animator.progressZeroReached = progress <= 0;
            animator.progressOneReached = progress >= 1;
            
            if (animator.animationBlock) {
                animator.animationBlock(animator, progress);
            } else {
                if (animator.backgroundImageBlock) {
                    UIImage *backgroundImage = animator.backgroundImageBlock(animator, progress);
                    [animator.navigationBar setBackgroundImage:backgroundImage forBarMetrics:UIBarMetricsDefault];
                }
                if (animator.shadowImageBlock) {
                    UIImage *shadowImage = animator.shadowImageBlock(animator, progress);
                    animator.navigationBar.shadowImage = shadowImage;
                }
                if (animator.tintColorBlock) {
                    UIColor *tintColor = animator.tintColorBlock(animator, progress);
                    animator.navigationBar.tintColor = tintColor;
                }
                if (animator.titleViewTintColorBlock) {
                    UIColor *tintColor = animator.titleViewTintColorBlock(animator, progress);
                    animator.navigationBar.topItem.titleView.tintColor = tintColor;// TODO: 对 UIViewController 是否生效？
                }
                if (animator.barTintColorBlock) {
                    animator.barTintColorBlock(animator, progress);
                }
                if (animator.statusbarStyleBlock) {
                    UIStatusBarStyle style = animator.statusbarStyleBlock(animator, progress);
                    if (style >= UIStatusBarStyleLightContent) {
                        [QMUIHelper renderStatusBarStyleLight];
                    } else {
                        [QMUIHelper renderStatusBarStyleDark];
                    }
                }
            }
        };
    }
    return self;
}

- (float)progress {
    UIScrollView *scrollView = self.scrollView;
    CGFloat offsetYToStartAnimation = self.offsetYToStartAnimation + (self.adjustsOffsetYWithInsetTopAutomatically ? -scrollView.qmui_contentInset.top : 0);
    if (scrollView.contentOffset.y < offsetYToStartAnimation) {
        return 0;
    }
    if (scrollView.contentOffset.y > offsetYToStartAnimation + self.distanceToStopAnimation) {
        return 1;
    }
    return (scrollView.contentOffset.y - offsetYToStartAnimation) / self.distanceToStopAnimation;
}

@end
