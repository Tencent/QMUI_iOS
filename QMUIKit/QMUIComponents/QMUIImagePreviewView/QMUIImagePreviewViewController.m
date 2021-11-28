/**
 * Tencent is pleased to support the open source community by making QMUI_iOS available.
 * Copyright (C) 2016-2021 THL A29 Limited, a Tencent company. All rights reserved.
 * Licensed under the MIT License (the "License"); you may not use this file except in compliance with the License. You may obtain a copy of the License at
 * http://opensource.org/licenses/MIT
 * Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.
 */

//
//  QMUIImagePreviewViewController.m
//  qmui
//
//  Created by QMUI Team on 2016/11/30.
//

#import "QMUIImagePreviewViewController.h"
#import "QMUICore.h"
#import "QMUIImagePreviewViewTransitionAnimator.h"
#import "UIInterface+QMUI.h"
#import "UIView+QMUI.h"
#import "UIViewController+QMUI.h"
#import "QMUIAppearance.h"

const CGFloat QMUIImagePreviewViewControllerCornerRadiusAutomaticDimension = -1;

@implementation QMUIImagePreviewViewController (UIAppearance)

+ (instancetype)appearance {
    return [QMUIAppearance appearanceForClass:self];
}

+ (void)initialize {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        [self initAppearance];
    });
}

+ (void)initAppearance {
    QMUIImagePreviewViewController.appearance.backgroundColor = UIColorBlack;
}

@end

@interface QMUIImagePreviewViewController ()

@property(nonatomic, strong) UIPanGestureRecognizer *dismissingGesture;
@property(nonatomic, assign) CGPoint gestureBeganLocation;
@property(nonatomic, weak) QMUIZoomImageView *gestureZoomImageView;
@property(nonatomic, assign) BOOL canShowPresentingViewControllerWhenGesturing;
@property(nonatomic, assign) BOOL originalStatusBarHidden;
@property(nonatomic, assign) BOOL statusBarHidden;
@end

@implementation QMUIImagePreviewViewController

- (void)didInitialize {
    [super didInitialize];
    
    self.sourceImageCornerRadius = QMUIImagePreviewViewControllerCornerRadiusAutomaticDimension;
    
    _dismissingGestureEnabled = YES;
    
    [self qmui_applyAppearance];
    
    self.qmui_prefersHomeIndicatorAutoHiddenBlock = ^BOOL{
        return YES;
    };

    
    // present style
    self.transitioningAnimator = [[QMUIImagePreviewViewTransitionAnimator alloc] init];
    self.modalPresentationStyle = UIModalPresentationCustom;
    self.modalPresentationCapturesStatusBarAppearance = YES;
    self.transitioningDelegate = self;
}

- (void)setBackgroundColor:(UIColor *)backgroundColor {
    _backgroundColor = backgroundColor;
    if ([self isViewLoaded]) {
        self.view.backgroundColor = backgroundColor;
    }
}

@synthesize imagePreviewView = _imagePreviewView;
- (QMUIImagePreviewView *)imagePreviewView {
    if (!_imagePreviewView) {
        _imagePreviewView = [[QMUIImagePreviewView alloc] initWithFrame:self.isViewLoaded ? self.view.bounds : CGRectZero];
    }
    return _imagePreviewView;
}

- (void)initSubviews {
    [super initSubviews];
    self.view.backgroundColor = self.backgroundColor;
    [self.view addSubview:self.imagePreviewView];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    self.imagePreviewView.qmui_frameApplyTransform = self.view.bounds;
    
    UIViewController *backendViewController = [self visibleViewControllerWithViewController:self.presentingViewController];
    self.canShowPresentingViewControllerWhenGesturing = [QMUIHelper interfaceOrientationMask:backendViewController.supportedInterfaceOrientations containsInterfaceOrientation:UIApplication.sharedApplication.statusBarOrientation];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if (self.qmui_isPresented) {
        [self initObjectsForZoomStyleIfNeeded];
    }
    [self.imagePreviewView.collectionView reloadData];
    [self.imagePreviewView.collectionView layoutIfNeeded];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    if (self.qmui_isPresented) {
        self.statusBarHidden = YES;
    }
    [self setNeedsStatusBarAppearanceUpdate];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    self.statusBarHidden = self.originalStatusBarHidden;
    [self setNeedsStatusBarAppearanceUpdate];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [self removeObjectsForZoomStyle];
    [self resetDismissingGesture];
}

- (void)setPresentingStyle:(QMUIImagePreviewViewControllerTransitioningStyle)presentingStyle {
    _presentingStyle = presentingStyle;
    self.dismissingStyle = presentingStyle;
}

- (void)setTransitioningAnimator:(__kindof QMUIImagePreviewViewTransitionAnimator *)transitioningAnimator {
    _transitioningAnimator = transitioningAnimator;
    transitioningAnimator.imagePreviewViewController = self;
}

- (BOOL)prefersStatusBarHidden {
    if (self.qmui_visibleState < QMUIViewControllerDidAppear || self.qmui_visibleState >= QMUIViewControllerDidDisappear) {
        // 在 present/dismiss 动画过程中，都使用原界面的状态栏显隐状态
        if (self.presentingViewController) {
            BOOL statusBarHidden = NO;
            if (@available(iOS 13.0, *)) {
                statusBarHidden = self.presentingViewController.view.window.windowScene.statusBarManager.statusBarHidden;
            } else {
                statusBarHidden = UIApplication.sharedApplication.statusBarHidden;
            }
            self.originalStatusBarHidden = statusBarHidden;
            return self.originalStatusBarHidden;
        }
        return [super prefersStatusBarHidden];
    }
    return self.statusBarHidden;
}

#pragma mark - 动画

- (void)initObjectsForZoomStyleIfNeeded {
    if (!self.dismissingGesture && self.dismissingGestureEnabled) {
        self.dismissingGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handleDismissingPreviewGesture:)];
        [self.view addGestureRecognizer:self.dismissingGesture];
    }
}

- (void)removeObjectsForZoomStyle {
    [self.dismissingGesture removeTarget:self action:@selector(handleDismissingPreviewGesture:)];
    [self.view removeGestureRecognizer:self.dismissingGesture];
    self.dismissingGesture = nil;
}

- (void)handleDismissingPreviewGesture:(UIPanGestureRecognizer *)gesture {
    
    if (!self.dismissingGestureEnabled) return;
    
    switch (gesture.state) {
        case UIGestureRecognizerStateBegan:
            self.gestureBeganLocation = [gesture locationInView:self.view];
            self.gestureZoomImageView = [self.imagePreviewView zoomImageViewAtIndex:self.imagePreviewView.currentImageIndex];
            self.gestureZoomImageView.scrollView.clipsToBounds = NO;// 当 contentView 被放大后，如果不去掉 clipToBounds，那么手势退出预览时，contentView 溢出的那部分内容就看不到
            break;
            
        case UIGestureRecognizerStateChanged: {
            CGPoint location = [gesture locationInView:self.view];
            CGFloat horizontalDistance = location.x - self.gestureBeganLocation.x;
            CGFloat verticalDistance = location.y - self.gestureBeganLocation.y;
            CGFloat ratio = 1.0;
            CGFloat alpha = 1.0;
            if (verticalDistance > 0) {
                // 往下拉的话，图片缩小，但图片移动距离与手指移动距离保持一致
                ratio = 1.0 - verticalDistance / CGRectGetHeight(self.view.bounds) / 2;
                
                // 如果预览大图支持横竖屏而背后的界面只支持竖屏，则在横屏时手势拖拽不要露出背后的界面
                if (self.canShowPresentingViewControllerWhenGesturing) {
                    alpha = 1.0 - verticalDistance / CGRectGetHeight(self.view.bounds) * 1.8;
                }
            } else {
                // 往上拉的话，图片不缩小，但手指越往上移动，图片将会越难被拖走
                CGFloat a = self.gestureBeganLocation.y + 100;// 后面这个加数越大，拖动时会越快达到不怎么拖得动的状态
                CGFloat b = 1 - pow((a - fabs(verticalDistance)) / a, 2);
                CGFloat contentViewHeight = CGRectGetHeight(self.gestureZoomImageView.contentViewRectInZoomImageView);
                CGFloat c = (CGRectGetHeight(self.view.bounds) - contentViewHeight) / 2;
                verticalDistance = -c * b;
            }
            CGAffineTransform transform = CGAffineTransformMakeTranslation(horizontalDistance, verticalDistance);
            transform = CGAffineTransformScale(transform, ratio, ratio);
            self.gestureZoomImageView.transform = transform;
            self.view.backgroundColor = [self.view.backgroundColor colorWithAlphaComponent:alpha];
            BOOL statusBarHidden = alpha >= 1 ? YES : self.originalStatusBarHidden;
            if (statusBarHidden != self.statusBarHidden) {
                self.statusBarHidden = statusBarHidden;
                [self setNeedsStatusBarAppearanceUpdate];
            }
        }
            break;
            
        case UIGestureRecognizerStateEnded: {
            CGPoint location = [gesture locationInView:self.view];
            CGFloat verticalDistance = location.y - self.gestureBeganLocation.y;
            if (verticalDistance > CGRectGetHeight(self.view.bounds) / 2 / 3) {
                
                // 如果背后的界面支持的方向与当前预览大图的界面不一样，则为了避免在 dismiss 后看到背后界面的旋转，这里提前触发背后界面的 viewWillAppear，从而借助 AutomaticallyRotateDeviceOrientation 的功能去提前旋转到正确方向。（备忘，如果不这么处理，标准的触发 viewWillAppear: 的时机是在 animator 的 animateTransition: 时，这里就算重复调用一次也不会导致 viewWillAppear: 多次触发）
                // 这里只能解决手势拖拽的 dismiss，如果是业务代码手动调用 dismiss 则无法兼顾，再看怎么处理。
                if (!self.canShowPresentingViewControllerWhenGesturing) {
                    [self.presentingViewController beginAppearanceTransition:YES animated:YES];
                }
                
                [self dismissViewControllerAnimated:YES completion:nil];
            } else {
                [self cancelDismissingGesture];
            }
        }
            break;
        default:
            [self cancelDismissingGesture];
            break;
    }
}

// 手势判定失败，恢复到手势前的状态
- (void)cancelDismissingGesture {
    self.statusBarHidden = YES;
    [UIView animateWithDuration:.2 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        [self setNeedsStatusBarAppearanceUpdate];
        [self resetDismissingGesture];
    } completion:NULL];
}

// 清理手势相关的变量
- (void)resetDismissingGesture {
    self.gestureZoomImageView.transform = CGAffineTransformIdentity;
    self.gestureBeganLocation = CGPointZero;
    self.gestureZoomImageView = nil;
    self.view.backgroundColor = self.backgroundColor;
}

// 不使用 qmui_visibleViewControllerIfExist 是因为不想考虑 presentedViewController
- (UIViewController *)visibleViewControllerWithViewController:(UIViewController *)viewController {
    if ([viewController isKindOfClass:[UINavigationController class]]) {
        return [self visibleViewControllerWithViewController:((UINavigationController *)viewController).topViewController];
    }
    
    if ([viewController isKindOfClass:[UITabBarController class]]) {
        return [self visibleViewControllerWithViewController:((UITabBarController *)viewController).selectedViewController];
    }
    
    return viewController;
}

#pragma mark - <UIViewControllerTransitioningDelegate>

- (id<UIViewControllerAnimatedTransitioning>)animationControllerForPresentedController:(UIViewController *)presented presentingController:(UIViewController *)presenting sourceController:(UIViewController *)source {
    return self.transitioningAnimator;
}

- (id<UIViewControllerAnimatedTransitioning>)animationControllerForDismissedController:(UIViewController *)dismissed {
    return self.transitioningAnimator;
}

@end
