//
//  QMUIImagePreviewViewController.m
//  qmui
//
//  Created by MoLice on 2016/11/30.
//  Copyright © 2016年 QMUI Team. All rights reserved.
//

#import "QMUIImagePreviewViewController.h"
#import "QMUIConfiguration.h"
#import "QMUICommonDefines.h"

@implementation QMUIImagePreviewViewController (UIAppearance)

+ (void)initialize {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        [self appearance];
    });
}

static QMUIImagePreviewViewController *imagePreviewViewControllerAppearance;
+ (instancetype)appearance {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (!imagePreviewViewControllerAppearance) {
            imagePreviewViewControllerAppearance = [[QMUIImagePreviewViewController alloc] init];
            imagePreviewViewControllerAppearance.backgroundColor = UIColorBlack;
        }
    });
    return imagePreviewViewControllerAppearance;
}

@end

@interface QMUIImagePreviewViewController ()

@property(nonatomic, strong) UIWindow *previewWindow;
@property(nonatomic, assign) BOOL shouldStartWithFading;
@property(nonatomic, assign) CGRect previewFromRect;
@property(nonatomic, strong) UIImageView *transitionImageView;
@property(nonatomic, strong) UIColor *backgroundColorTemporarily;
@end

@implementation QMUIImagePreviewViewController

@synthesize imagePreviewView = _imagePreviewView;

- (void)didInitialized {
    [super didInitialized];
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    if (imagePreviewViewControllerAppearance) {
        self.backgroundColor = [QMUIImagePreviewViewController appearance].backgroundColor;
    }
}

- (QMUIImagePreviewView *)imagePreviewView {
    [self loadViewIfNeeded];
    return _imagePreviewView;
}

- (void)setBackgroundColor:(UIColor *)backgroundColor {
    _backgroundColor = backgroundColor;
    if ([self isViewLoaded]) {
        self.view.backgroundColor = backgroundColor;
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = self.backgroundColor;
}

- (void)initSubviews {
    [super initSubviews];
    _imagePreviewView = [[QMUIImagePreviewView alloc] initWithFrame:self.view.bounds];
    [self.view addSubview:self.imagePreviewView];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    self.imagePreviewView.frame = self.view.bounds;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self.imagePreviewView.collectionView reloadData];
    
    if (self.previewWindow && !self.shouldStartWithFading) {
        // 为在 viewDidAppear 做动画做准备
        self.imagePreviewView.collectionView.hidden = YES;
    } else {
        self.imagePreviewView.collectionView.hidden = NO;
    }
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    // 配合 QMUIImagePreviewViewController (UIWindow) 使用的
    if (self.previewWindow) {
        
        if (self.shouldStartWithFading) {
            [UIView animateWithDuration:.2 delay:0.0 options:QMUIViewAnimationOptionsCurveOut animations:^{
                self.view.alpha = 1;
            } completion:^(BOOL finished) {
                self.imagePreviewView.collectionView.hidden = NO;
                self.shouldStartWithFading = NO;
            }];
            return;
        }
        
        QMUIZoomImageView *zoomImageView = [self.imagePreviewView zoomImageViewAtIndex:self.imagePreviewView.currentImageIndex];
        if (!zoomImageView) {
            NSAssert(NO, @"第 %@ 个 zoomImageView 不存在，可能当前还处于非可视区域", @(self.imagePreviewView.currentImageIndex));
        }
        CGRect transitionFromRect = self.previewFromRect;
        CGRect transitionToRect = [self.view convertRect:[zoomImageView imageViewRectInZoomImageView] fromView:zoomImageView.superview];
        
        self.transitionImageView.contentMode = zoomImageView.imageView.contentMode;
        self.transitionImageView.image = zoomImageView.imageView.image;
        self.transitionImageView.frame = transitionFromRect;
        [self.view addSubview:self.transitionImageView];
        
        [UIView animateWithDuration:.2 delay:0.0 options:QMUIViewAnimationOptionsCurveOut animations:^{
            self.transitionImageView.frame = transitionToRect;
            self.view.backgroundColor = self.backgroundColorTemporarily;
        } completion:^(BOOL finished) {
            [self.transitionImageView removeFromSuperview];
            self.imagePreviewView.collectionView.hidden = NO;
            self.backgroundColorTemporarily = nil;
        }];
    }
}

@end

@implementation QMUIImagePreviewViewController (UIWindow)

- (void)startPreviewFromRectInScreen:(CGRect)rect {
    [self startPreviewWithFadingAnimation:NO orFromRect:rect];
}

- (void)endPreviewToRectInScreen:(CGRect)rect {
    [self endPreviewWithFadingAnimation:NO orToRect:rect];
}

- (void)startPreviewFading {
    [self startPreviewWithFadingAnimation:YES orFromRect:CGRectZero];
}

- (void)endPreviewFading {
    [self endPreviewWithFadingAnimation:YES orToRect:CGRectZero];
}

#pragma mark - 动画

- (void)initPreviewWindowIfNeeded {
    if (!self.previewWindow) {
        self.previewWindow = [[UIWindow alloc] init];
        self.previewWindow.windowLevel = UIWindowLevelQMUIImagePreviewView;
        self.previewWindow.backgroundColor = UIColorClear;
    }
}

- (void)removePreviewWindow {
    self.previewWindow.hidden = YES;
    self.previewWindow.rootViewController = nil;
    self.previewWindow = nil;
}

- (void)startPreviewWithFadingAnimation:(BOOL)isFading orFromRect:(CGRect)rect {
    self.shouldStartWithFading = isFading;
    
    if (isFading) {
        
        // 为动画做准备，先置为透明
        self.view.alpha = 0;
        
    } else {
        self.previewFromRect = rect;
        
        if (!self.transitionImageView) {
            self.transitionImageView = [[UIImageView alloc] init];
        }
        
        // 为动画做准备，先置为透明
        self.backgroundColorTemporarily = self.view.backgroundColor;
        self.view.backgroundColor = UIColorClear;
    }
    
    [self initPreviewWindowIfNeeded];
    
    self.previewWindow.rootViewController = self;
    self.previewWindow.hidden = NO;
}

- (void)endPreviewWithFadingAnimation:(BOOL)isFading orToRect:(CGRect)rect {
    
    if (isFading) {
        [UIView animateWithDuration:.2 delay:0.0 options:QMUIViewAnimationOptionsCurveOut animations:^{
            self.view.alpha = 0;
        } completion:^(BOOL finished) {
            [self removePreviewWindow];
            self.view.alpha = 1;
        }];
        return;
    }
    
    QMUIZoomImageView *zoomImageView = [self.imagePreviewView zoomImageViewAtIndex:self.imagePreviewView.currentImageIndex];
    CGRect transitionFromRect = [zoomImageView imageViewRectInZoomImageView];
    CGRect transitionToRect = rect;
    
    self.transitionImageView.image = zoomImageView.image;
    self.transitionImageView.frame = transitionFromRect;
    [self.view addSubview:self.transitionImageView];
    self.imagePreviewView.collectionView.hidden = YES;
    
    self.backgroundColorTemporarily = self.view.backgroundColor;
    
    [UIView animateWithDuration:.2 delay:0.0 options:QMUIViewAnimationOptionsCurveOut animations:^{
        self.transitionImageView.frame = transitionToRect;
        self.view.backgroundColor = UIColorClear;
    } completion:^(BOOL finished) {
        [self removePreviewWindow];
        [self.transitionImageView removeFromSuperview];
        self.imagePreviewView.collectionView.hidden = NO;
        self.view.backgroundColor = self.backgroundColorTemporarily;
        self.backgroundColorTemporarily = nil;
    }];
}

@end
