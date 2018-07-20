//
//  QMUIImagePreviewViewController.m
//  qmui
//
//  Created by MoLice on 2016/11/30.
//  Copyright © 2016年 QMUI Team. All rights reserved.
//

#import "QMUIImagePreviewViewController.h"
#import "QMUICore.h"

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
@property(nonatomic, assign) CGFloat transitionCornerRadius;
@property(nonatomic, strong) UIColor *backgroundColorTemporarily;

@property(nonatomic, assign) BOOL exitGestureEnabled;
@property(nonatomic, copy) void (^customGestureExitBlock)(QMUIImagePreviewViewController *aImagePreviewViewController, QMUIZoomImageView *currentZoomImageView);
@property(nonatomic, strong) UIPanGestureRecognizer *exitGesture;
@property(nonatomic, assign) CGPoint gestureBeganLocation;
@property(nonatomic, weak) QMUIZoomImageView *gestureZoomImageView;
@end

@implementation QMUIImagePreviewViewController

@synthesize imagePreviewView = _imagePreviewView;

- (void)didInitialize {
    [super didInitialize];
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.exitGestureEnabled = YES;
    
    if (imagePreviewViewControllerAppearance) {
        self.backgroundColor = [QMUIImagePreviewViewController appearance].backgroundColor;
    }
}

- (QMUIImagePreviewView *)imagePreviewView {
    BeginIgnoreAvailabilityWarning
    [self loadViewIfNeeded];
    EndIgnoreAvailabilityWarning
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
    self.imagePreviewView.frame = CGRectApplyAffineTransform(self.view.bounds, self.imagePreviewView.transform);
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
        CGRect transitionToRect = [self.view convertRect:[zoomImageView contentViewRectInZoomImageView] fromView:zoomImageView.superview];
        
        if (CGRectIsEmpty(transitionToRect)) {
            // 如果开始做动画的时候业务的 zoomImageView 还在 loading，那么 [zoomImageView contentViewRectInZoomImageView] 得到的为 zero，此时则视为那张图将会撑满屏幕
            CGRect zoomImageViewFrame = [self.view convertRect:zoomImageView.frame fromView:zoomImageView.superview];
            transitionToRect = CGRectMake(0, 0, CGRectGetWidth(zoomImageViewFrame), CGRectGetHeight(transitionFromRect) * CGRectGetWidth(zoomImageViewFrame) / CGRectGetWidth(transitionFromRect));
            transitionToRect = CGRectSetY(transitionToRect, CGFloatGetCenter(CGRectGetHeight(zoomImageViewFrame), CGRectGetHeight(transitionToRect)));
        }
        
        CGFloat horizontalRatio = CGRectGetWidth(transitionFromRect) / CGRectGetWidth(transitionToRect);
        CGFloat verticalRatio = CGRectGetHeight(transitionFromRect) / CGRectGetHeight(transitionToRect);
        CGAffineTransform transform = CGAffineTransformMakeScale(horizontalRatio, verticalRatio);
        transform = CGAffineTransformConcat(transform, CGAffineTransformMakeTranslation(CGRectGetMidX(transitionFromRect) - CGRectGetMidX(transitionToRect), CGRectGetMidY(transitionFromRect) - CGRectGetMidY(transitionToRect)));
        zoomImageView.transform = transform;
        
        zoomImageView.contentView.layer.cornerRadius = self.transitionCornerRadius / verticalRatio;
        zoomImageView.contentView.clipsToBounds = YES;
        self.imagePreviewView.collectionView.hidden = NO;
        
        [UIView animateWithDuration:.25 delay:0.0 options:QMUIViewAnimationOptionsCurveOut animations:^{
            zoomImageView.contentView.layer.cornerRadius = 0;
            zoomImageView.transform = CGAffineTransformIdentity;
            self.view.backgroundColor = self.backgroundColorTemporarily;
        } completion:^(BOOL finished) {
            zoomImageView.contentView.clipsToBounds = NO;
            self.backgroundColorTemporarily = nil;
        }];
    }
}

@end

@implementation QMUIImagePreviewViewController (UIWindow)

- (void)startPreviewFromRectInScreenCoordinate:(CGRect)rect cornerRadius:(CGFloat)cornerRadius {
    self.transitionCornerRadius = cornerRadius;
    [self startPreviewWithFadingAnimation:NO orFromRect:rect];
}

- (void)startPreviewFromRectInScreenCoordinate:(CGRect)rect {
    [self startPreviewFromRectInScreenCoordinate:rect cornerRadius:0];
}

- (void)exitPreviewToRectInScreenCoordinate:(CGRect)rect {
    [self exitPreviewByFadingAnimation:NO orToRect:rect];
    self.transitionCornerRadius = 0;
}

- (void)startPreviewByFadeIn {
    self.transitionCornerRadius = 0;
    [self startPreviewWithFadingAnimation:YES orFromRect:CGRectZero];
}

- (void)exitPreviewByFadeOut {
    [self exitPreviewByFadingAnimation:YES orToRect:CGRectZero];
    self.transitionCornerRadius = 0;
}

#pragma mark - 动画

- (void)initPreviewWindowIfNeeded {
    if (!self.previewWindow) {
        self.previewWindow = [[UIWindow alloc] init];
        self.previewWindow.windowLevel = UIWindowLevelQMUIImagePreviewView;
        self.previewWindow.backgroundColor = UIColorClear;
        
        [self initExitPreviewGestureIfNeeded];
    }
}

- (void)removePreviewWindow {
    [self removeExitPreviewGesture];
    self.previewWindow.hidden = YES;
    self.previewWindow.rootViewController = nil;
    self.previewWindow = nil;
}

- (void)initExitPreviewGestureIfNeeded {
    if (!self.exitGesture && self.exitGestureEnabled) {
        self.exitGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handleExitPreviewGesture:)];
        [self.previewWindow addGestureRecognizer:self.exitGesture];
    }
}

- (void)removeExitPreviewGesture {
    [self.exitGesture removeTarget:self action:@selector(handleExitPreviewGesture:)];
    [self.previewWindow removeGestureRecognizer:self.exitGesture];
    self.exitGesture = nil;
}

- (void)startPreviewWithFadingAnimation:(BOOL)isFading orFromRect:(CGRect)rect {
    self.shouldStartWithFading = isFading;
    
    if (isFading) {
        
        // 为动画做准备，先置为透明
        self.view.alpha = 0;
        
    } else {
        self.previewFromRect = rect;
        
        // 为动画做准备，先置为透明
        self.backgroundColorTemporarily = self.view.backgroundColor;
        self.view.backgroundColor = UIColorClear;
    }
    
    [self initPreviewWindowIfNeeded];
    
    self.previewWindow.rootViewController = self;
    self.previewWindow.hidden = NO;
}

- (void)exitPreviewByFadingAnimation:(BOOL)isFading orToRect:(CGRect)rect {
    
    if (isFading) {
        [UIView animateWithDuration:.25 delay:0.0 options:QMUIViewAnimationOptionsCurveOut animations:^{
            self.view.alpha = 0;
        } completion:^(BOOL finished) {
            [self removePreviewWindow];
            [self resetExitGesture];
            self.view.alpha = 1;
        }];
        return;
    }
    
    QMUIZoomImageView *zoomImageView = [self.imagePreviewView zoomImageViewAtIndex:self.imagePreviewView.currentImageIndex];
    zoomImageView.contentView.clipsToBounds = YES;
    
    CGRect transitionFromRect = [self.view convertRect:[zoomImageView contentViewRectInZoomImageView] fromView:zoomImageView.superview];
    CGRect transitionToRect = rect;
    CGFloat horizontalRatio = CGRectGetWidth(transitionToRect) / CGRectGetWidth(transitionFromRect);
    CGFloat verticalRatio = CGRectGetHeight(transitionToRect) / CGRectGetHeight(transitionFromRect);
    CGAffineTransform transform = CGAffineTransformMakeScale(horizontalRatio, verticalRatio);
    transform = CGAffineTransformConcat(transform, CGAffineTransformMakeTranslation(CGRectGetMidX(transitionToRect) - CGRectGetMidX(transitionFromRect), CGRectGetMidY(transitionToRect) - CGRectGetMidY(transitionFromRect)));
    
    self.backgroundColorTemporarily = self.view.backgroundColor;
    
    [UIView animateWithDuration:.2 delay:0.0 options:QMUIViewAnimationOptionsCurveOut animations:^{
        zoomImageView.transform = transform;
        zoomImageView.contentView.layer.cornerRadius = self.transitionCornerRadius / verticalRatio;
        self.view.backgroundColor = UIColorClear;
    } completion:^(BOOL finished) {
        [self removePreviewWindow];
        zoomImageView.contentView.clipsToBounds = NO;
        zoomImageView.contentView.layer.cornerRadius = 0;
        zoomImageView.transform = CGAffineTransformIdentity;
        self.view.backgroundColor = self.backgroundColorTemporarily;
        self.backgroundColorTemporarily = nil;
        [self resetExitGesture];
    }];
}

- (void)exitPreviewAutomatically {
    if (self.customGestureExitBlock) {
        self.customGestureExitBlock(self, [self.imagePreviewView zoomImageViewAtIndex:self.imagePreviewView.currentImageIndex]);
    } else {
        [self exitPreviewByFadeOut];
    }
}

- (void)handleExitPreviewGesture:(UIPanGestureRecognizer *)gesture {
    
    if (!self.exitGestureEnabled) return;
    
    switch (gesture.state) {
        case UIGestureRecognizerStateBegan:
            self.gestureBeganLocation = [gesture locationInView:self.previewWindow];
            self.gestureZoomImageView = [self.imagePreviewView zoomImageViewAtIndex:self.imagePreviewView.currentImageIndex];
            break;
            
        case UIGestureRecognizerStateChanged: {
            CGPoint location = [gesture locationInView:self.previewWindow];
            CGFloat horizontalDistance = location.x - self.gestureBeganLocation.x;
            CGFloat verticalDistance = location.y - self.gestureBeganLocation.y;
            CGFloat ratio = 1.0;
            CGFloat alpha = 1.0;
            if (verticalDistance > 0) {
                // 往下拉的话，图片缩小，但图片移动距离与手指移动距离保持一致
                ratio = 1.0 - verticalDistance / CGRectGetHeight(self.previewWindow.bounds) / 2;
                alpha = 1.0 - verticalDistance / CGRectGetHeight(self.previewWindow.bounds) * 1.8;
            } else {
                // 往上拉的话，图片不缩小，但手指越往上移动，图片将会越难被拖走
                CGFloat a = self.gestureBeganLocation.y + 100;// 后面这个加数越大，拖动时会越快达到不怎么拖得动的状态
                CGFloat b = 1 - pow((a - fabs(verticalDistance)) / a, 2);
                CGFloat contentViewHeight = CGRectGetHeight(self.gestureZoomImageView.contentViewRectInZoomImageView);
                CGFloat c = (CGRectGetHeight(self.previewWindow.bounds) - contentViewHeight) / 2;
                verticalDistance = -c * b;
            }
            CGAffineTransform transform = CGAffineTransformMakeScale(ratio, ratio);
            transform = CGAffineTransformConcat(transform, CGAffineTransformMakeTranslation(horizontalDistance, verticalDistance));
            self.gestureZoomImageView.transform = transform;
            self.view.backgroundColor = [self.view.backgroundColor colorWithAlphaComponent:alpha];
        }
            break;
            
        case UIGestureRecognizerStateEnded: {
            CGPoint location = [gesture locationInView:self.previewWindow];
            CGFloat verticalDistance = location.y - self.gestureBeganLocation.y;
            if (verticalDistance > CGRectGetHeight(self.previewWindow.bounds) / 2 / 3) {
                [self exitPreviewAutomatically];
            } else {
                [self cancelExitGesture];
            }
        }
            break;
        default:
            [self cancelExitGesture];
            break;
    }
}

// 手势判定失败，恢复到手势前的状态
- (void)cancelExitGesture {
    [UIView animateWithDuration:.2 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        [self resetExitGesture];
    } completion:NULL];
}

// 清理手势相关的变量
- (void)resetExitGesture {
    self.gestureZoomImageView.transform = CGAffineTransformIdentity;
    self.gestureBeganLocation = CGPointZero;
    self.gestureZoomImageView = nil;
    self.view.backgroundColor = [self.view.backgroundColor colorWithAlphaComponent:1];
}

@end
