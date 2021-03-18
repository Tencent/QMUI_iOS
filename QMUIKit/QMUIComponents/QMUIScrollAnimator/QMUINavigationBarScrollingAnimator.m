/**
 * Tencent is pleased to support the open source community by making QMUI_iOS available.
 * Copyright (C) 2016-2020 THL A29 Limited, a Tencent company. All rights reserved.
 * Licensed under the MIT License (the "License"); you may not use this file except in compliance with the License. You may obtain a copy of the License at
 * http://opensource.org/licenses/MIT
 * Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.
 */

//
//  QMUINavigationBarScrollingAnimator.m
//  QMUIKit
//
//  Created by QMUI Team on 2018/O/16.
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
                    animator.navigationBar.topItem.titleView.tintColor = tintColor;
                }
                if (animator.barTintColorBlock) {
                    animator.barTintColorBlock(animator, progress);
                }
                if (animator.statusbarStyleBlock) {
                    UIStatusBarStyle style = animator.statusbarStyleBlock(animator, progress);
                    // 需在项目的 Info.plist 文件内设置字段 “View controller-based status bar appearance” 的值为 NO 才能生效，如果不设置，或者值为 YES，则请自行通过系统提供的 - preferredStatusBarStyle 方法来实现，statusbarStyleBlock 无效
                    BeginIgnoreDeprecatedWarning
                    if (style >= UIStatusBarStyleLightContent) {
                        [UIApplication.sharedApplication setStatusBarStyle:UIStatusBarStyleLightContent];
                    } else {
                        [UIApplication.sharedApplication setStatusBarStyle:UIStatusBarStyleDefault];
                    }
                    EndIgnoreDeprecatedWarning
                }
            }
        };
    }
    return self;
}

- (float)progress {
    UIScrollView *scrollView = self.scrollView;
    CGFloat contentOffsetY = flat(scrollView.contentOffset.y);
    CGFloat offsetYToStartAnimation = flat(self.offsetYToStartAnimation + (self.adjustsOffsetYWithInsetTopAutomatically ? -scrollView.qmui_contentInset.top : 0));
    if (contentOffsetY < offsetYToStartAnimation) {
        return 0;
    }
    if (contentOffsetY > offsetYToStartAnimation + self.distanceToStopAnimation) {
        return 1;
    }
    return (contentOffsetY - offsetYToStartAnimation) / self.distanceToStopAnimation;
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
    self.progressZeroReached = NO;
    self.progressOneReached = NO;
    [self updateScroll];
}

@end
