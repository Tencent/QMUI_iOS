/**
 * Tencent is pleased to support the open source community by making QMUI_iOS available.
 * Copyright (C) 2016-2020 THL A29 Limited, a Tencent company. All rights reserved.
 * Licensed under the MIT License (the "License"); you may not use this file except in compliance with the License. You may obtain a copy of the License at
 * http://opensource.org/licenses/MIT
 * Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.
 */

//
//  QMUIImagePreviewViewTransitionAnimator.m
//  QMUIKit
//
//  Created by MoLice on 2018/D/19.
//

#import "QMUIImagePreviewViewTransitionAnimator.h"
#import "QMUICore.h"
#import "CALayer+QMUI.h"

@implementation QMUIImagePreviewViewTransitionAnimator

- (instancetype)init {
    if (self = [super init]) {
        self.duration = .25;
        
        _cornerRadiusMaskLayer = [CALayer layer];
        [self.cornerRadiusMaskLayer qmui_removeDefaultAnimations];
        self.cornerRadiusMaskLayer.backgroundColor = [UIColor whiteColor].CGColor;
        
        self.animationEnteringBlock = ^(__kindof QMUIImagePreviewViewTransitionAnimator * _Nonnull animator, BOOL isPresenting, QMUIImagePreviewViewControllerTransitioningStyle style, CGRect sourceImageRect, QMUIZoomImageView * _Nonnull zoomImageView, id<UIViewControllerContextTransitioning>  _Nullable transitionContext) {
            
            UIView *previewView = animator.imagePreviewViewController.view;
            
            if (style == QMUIImagePreviewViewControllerTransitioningStyleFade) {
                
                previewView.alpha = isPresenting ? 0 : 1;
                
            } else if (style == QMUIImagePreviewViewControllerTransitioningStyleZoom) {
                
                CGRect contentViewFrame = [previewView convertRect:zoomImageView.contentViewRectInZoomImageView fromView:nil];
                CGPoint contentViewCenterInZoomImageView = CGPointGetCenterWithRect(zoomImageView.contentViewRectInZoomImageView);
                if (CGRectIsEmpty(contentViewFrame)) {
                    // 有可能 start preview 时图片还在 loading，此时拿到的 content rect 是 zero，所以做个保护
                    contentViewFrame = [previewView convertRect:zoomImageView.frame fromView:zoomImageView.superview];
                    contentViewCenterInZoomImageView = CGPointGetCenterWithRect(contentViewFrame);
                }
                CGPoint centerInZoomImageView = CGPointGetCenterWithRect(zoomImageView.bounds);// 注意不是 zoomImageView 的 center，而是 zoomImageView 这个容器里的中心点
                CGFloat horizontalRatio = CGRectGetWidth(sourceImageRect) / CGRectGetWidth(contentViewFrame);
                CGFloat verticalRatio = CGRectGetHeight(sourceImageRect) / CGRectGetHeight(contentViewFrame);
                CGFloat finalRatio = MAX(horizontalRatio, verticalRatio);
                
                CGAffineTransform fromTransform = CGAffineTransformIdentity;
                CGAffineTransform toTransform = CGAffineTransformIdentity;
                CGAffineTransform transform = CGAffineTransformIdentity;
                
                // 先缩再移
                transform = CGAffineTransformScale(transform, finalRatio, finalRatio);
                CGPoint contentViewCenterAfterScale = CGPointMake(centerInZoomImageView.x + (contentViewCenterInZoomImageView.x - centerInZoomImageView.x) * finalRatio, centerInZoomImageView.y + (contentViewCenterInZoomImageView.y - centerInZoomImageView.y) * finalRatio);
                CGSize translationAfterScale = CGSizeMake(CGRectGetMidX(sourceImageRect) - contentViewCenterAfterScale.x, CGRectGetMidY(sourceImageRect) - contentViewCenterAfterScale.y);
                transform = CGAffineTransformConcat(transform, CGAffineTransformMakeTranslation(translationAfterScale.width, translationAfterScale.height));
                
                if (isPresenting) {
                    fromTransform = transform;
                } else {
                    toTransform = transform;
                }
                
                CGRect maskFromBounds = zoomImageView.contentView.bounds;
                CGRect maskToBounds = zoomImageView.contentView.bounds;
                CGRect maskBounds = maskFromBounds;
                CGFloat maskHorizontalRatio = CGRectGetWidth(sourceImageRect) / CGRectGetWidth(maskBounds);
                CGFloat maskVerticalRatio = CGRectGetHeight(sourceImageRect) / CGRectGetHeight(maskBounds);
                CGFloat maskFinalRatio = MAX(maskHorizontalRatio, maskVerticalRatio);
                maskBounds = CGRectMakeWithSize(CGSizeMake(CGRectGetWidth(sourceImageRect) / maskFinalRatio, CGRectGetHeight(sourceImageRect) / maskFinalRatio));
                if (isPresenting) {
                    maskFromBounds = maskBounds;
                } else {
                    maskToBounds = maskBounds;
                }
                
                CGFloat cornerRadius = animator.imagePreviewViewController.sourceImageCornerRadius == QMUIImagePreviewViewControllerCornerRadiusAutomaticDimension && animator.imagePreviewViewController.sourceImageView ? animator.imagePreviewViewController.sourceImageView().layer.cornerRadius : MAX(animator.imagePreviewViewController.sourceImageCornerRadius, 0);
                cornerRadius = cornerRadius / maskFinalRatio;
                CGFloat fromCornerRadius = isPresenting ? cornerRadius : 0;
                CGFloat toCornerRadius = isPresenting ? 0 : cornerRadius;
                CABasicAnimation *cornerRadiusAnimation = [CABasicAnimation animationWithKeyPath:@"cornerRadius"];
                cornerRadiusAnimation.fromValue = @(fromCornerRadius);
                cornerRadiusAnimation.toValue = @(toCornerRadius);
                
                CABasicAnimation *boundsAnimation = [CABasicAnimation animationWithKeyPath:@"bounds"];
                boundsAnimation.fromValue = [NSValue valueWithCGRect:CGRectMakeWithSize(maskFromBounds.size)];
                boundsAnimation.toValue = [NSValue valueWithCGRect:CGRectMakeWithSize(maskToBounds.size)];
                
                CAAnimationGroup *maskAnimation = [[CAAnimationGroup alloc] init];
                maskAnimation.duration = animator.duration;
                maskAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
                maskAnimation.fillMode = kCAFillModeForwards;
                maskAnimation.removedOnCompletion = NO;// remove 都交给 UIView Block 的 completion 里做，这里是为了避免 Core Animation 和 UIView Animation Block 时间不一致导致的值变动
                maskAnimation.animations = @[cornerRadiusAnimation, boundsAnimation];
                animator.cornerRadiusMaskLayer.position = CGPointGetCenterWithRect(zoomImageView.contentView.bounds);// 不管怎样，mask 都是居中的
                zoomImageView.contentView.layer.mask = animator.cornerRadiusMaskLayer;
                [animator.cornerRadiusMaskLayer addAnimation:maskAnimation forKey:@"maskAnimation"];
                
                // 动画开始
                zoomImageView.scrollView.clipsToBounds = NO;// 当 contentView 被放大后，如果不去掉 clipToBounds，那么退出预览时，contentView 溢出的那部分内容就看不到
                
                if (isPresenting) {
                    zoomImageView.transform = fromTransform;
                    previewView.backgroundColor = UIColorClear;
                }
                
                // 发现 zoomImageView.transform 用 UIView Animation Block 实现的话，手势拖拽 dismissing 的情况下，松手时会瞬间跳动到某个位置，然后才继续做动画，改为 Core Animation 就没这个问题
                CABasicAnimation *transformAnimation = [CABasicAnimation animationWithKeyPath:@"transform"];
                transformAnimation.toValue = [NSValue valueWithCATransform3D:CATransform3DMakeAffineTransform(toTransform)];
                transformAnimation.duration = animator.duration;
                transformAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
                transformAnimation.fillMode = kCAFillModeForwards;
                transformAnimation.removedOnCompletion = NO;// remove 都交给 UIView Block 的 completion 里做，这里是为了避免 Core Animation 和 UIView Animation Block 时间不一致导致的值变动
                [zoomImageView.layer addAnimation:transformAnimation forKey:@"transformAnimation"];
            };
        };
        
        self.animationBlock = ^(__kindof QMUIImagePreviewViewTransitionAnimator * _Nonnull animator, BOOL isPresenting, QMUIImagePreviewViewControllerTransitioningStyle style, CGRect sourceImageRect, QMUIZoomImageView * _Nonnull zoomImageView, id<UIViewControllerContextTransitioning>  _Nullable transitionContext) {
            if (style == QMUIImagePreviewViewControllerTransitioningStyleFade) {
                animator.imagePreviewViewController.view.alpha = isPresenting ? 1 : 0;
            } else if (style == QMUIImagePreviewViewControllerTransitioningStyleZoom) {
                animator.imagePreviewViewController.view.backgroundColor = isPresenting ? animator.imagePreviewViewController.backgroundColor : UIColorClear;
            }
        };
        
        self.animationCompletionBlock = ^(__kindof QMUIImagePreviewViewTransitionAnimator * _Nonnull animator, BOOL isPresenting, QMUIImagePreviewViewControllerTransitioningStyle style, CGRect sourceImageRect, QMUIZoomImageView * _Nonnull zoomImageView, id<UIViewControllerContextTransitioning>  _Nullable transitionContext) {
            
            // 由于支持 zoom presenting 和 fade dismissing 搭配使用，所以这里不管是哪种 style 都要做相同的清理工作
            
            // for fade
            animator.imagePreviewViewController.view.alpha = 1;
            
            // for zoom
            [animator.cornerRadiusMaskLayer removeAnimationForKey:@"maskAnimation"];
            zoomImageView.scrollView.clipsToBounds = YES;// UIScrollView.clipsToBounds default is YES
            zoomImageView.contentView.layer.mask = nil;
            zoomImageView.transform = CGAffineTransformIdentity;
            [zoomImageView.layer removeAnimationForKey:@"transformAnimation"];
        };
    }
    return self;
}

#pragma mark - <UIViewControllerAnimatedTransitioning>

- (void)animateTransition:(nonnull id<UIViewControllerContextTransitioning>)transitionContext {
    if (!self.imagePreviewViewController) {
        return;
    }
    
    UIViewController *fromViewController = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    UIViewController *toViewController = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    BOOL isPresenting = fromViewController.presentedViewController == toViewController;
    UIViewController *presentingViewController = isPresenting ? fromViewController : toViewController;
    BOOL shouldAppearanceTransitionManually = self.imagePreviewViewController.modalPresentationStyle != UIModalPresentationFullScreen;// 触发背后界面的生命周期，从而配合屏幕旋转那边做一些强制旋转的操作
    
    QMUIImagePreviewViewControllerTransitioningStyle style = isPresenting ? self.imagePreviewViewController.presentingStyle : self.imagePreviewViewController.dismissingStyle;
    CGRect sourceImageRect = CGRectZero;
    if (style == QMUIImagePreviewViewControllerTransitioningStyleZoom) {
        if (self.imagePreviewViewController.sourceImageRect) {
            sourceImageRect = [self.imagePreviewViewController.view convertRect:self.imagePreviewViewController.sourceImageRect() fromView:nil];
        } else if (self.imagePreviewViewController.sourceImageView) {
            UIView *sourceImageView = self.imagePreviewViewController.sourceImageView();
            if (sourceImageView) {
                sourceImageRect = [self.imagePreviewViewController.view convertRect:sourceImageView.frame fromView:sourceImageView.superview];
            }
        }
        if (!CGRectEqualToRect(sourceImageRect, CGRectZero) && !CGRectIntersectsRect(sourceImageRect, self.imagePreviewViewController.view.bounds)) {
            sourceImageRect = CGRectZero;
        }
    }
    style = style == QMUIImagePreviewViewControllerTransitioningStyleZoom && CGRectEqualToRect(sourceImageRect, CGRectZero) ? QMUIImagePreviewViewControllerTransitioningStyleFade : style;// zoom 类型一定需要有个非 zero 的 sourceImageRect，否则不知道动画的起点/终点，所以当不存在 sourceImageRect 时强制改为用 fade 动画
    
    UIView *containerView = transitionContext.containerView;
    UIView *fromView = [transitionContext viewForKey:UITransitionContextFromViewKey];
    [fromView setNeedsLayout];
    [fromView layoutIfNeeded];
    UIView *toView = [transitionContext viewForKey:UITransitionContextToViewKey];
    [toView setNeedsLayout];
    [toView layoutIfNeeded];// present 时 toViewController 还没走到 viewDidLayoutSubviews，此时做动画可能得到不正确的布局，所以强制布局一次
    QMUIZoomImageView *zoomImageView = [self.imagePreviewViewController.imagePreviewView zoomImageViewAtIndex:self.imagePreviewViewController.imagePreviewView.currentImageIndex];
    
    toView.frame = containerView.bounds;
    if (isPresenting) {
        [containerView addSubview:toView];
        if (shouldAppearanceTransitionManually) {
            [presentingViewController beginAppearanceTransition:NO animated:YES];
        }
    } else {
        [containerView insertSubview:toView belowSubview:fromView];
        [presentingViewController beginAppearanceTransition:YES animated:YES];
    }
    
    if (self.animationEnteringBlock) {
        self.animationEnteringBlock(self, isPresenting, style, sourceImageRect, zoomImageView, transitionContext);
    }
    
    [UIView animateWithDuration:self.duration delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        if (self.animationBlock) {
            self.animationBlock(self, isPresenting, style, sourceImageRect, zoomImageView, transitionContext);
        }
    } completion:^(BOOL finished) {
        [presentingViewController endAppearanceTransition];
        [transitionContext completeTransition:!transitionContext.transitionWasCancelled];
        if (self.animationCompletionBlock) {
            self.animationCompletionBlock(self, isPresenting, style, sourceImageRect, zoomImageView, transitionContext);
        }
    }];
}

- (NSTimeInterval)transitionDuration:(nullable id<UIViewControllerContextTransitioning>)transitionContext {
    return self.duration;
}

@end
