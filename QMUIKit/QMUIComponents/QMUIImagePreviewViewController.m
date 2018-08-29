//
//  QMUIImagePreviewViewController.m
//  qmui
//
//  Created by MoLice on 2016/11/30.
//  Copyright © 2016年 QMUI Team. All rights reserved.
//

#import "QMUIImagePreviewViewController.h"
#import "QMUICore.h"
#import "CALayer+QMUI.h"
#import "UIView+QMUI.h"

@implementation QMUIImagePreviewViewController (UIAppearance)

+ (void)initialize {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        [self appearance];
    });
}

static QMUIImagePreviewViewController *imagePreviewViewControllerAppearance;
+ (nonnull instancetype)appearance {
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
@property(nonatomic, strong) CALayer *maskLayer;

// 给 window 那边用，先声明，才能使用
- (void)startPreviewByTransformFromRect:(CGRect)fromRect;
@end

BeginIgnoreClangWarning(-Wincomplete-implementation)
@implementation QMUIImagePreviewViewController
EndIgnoreClangWarning

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
    self.imagePreviewView.qmui_frameApplyTransform = self.view.bounds;
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
        
        self.imagePreviewView.collectionView.hidden = NO;
        [self startPreviewByTransformFromRect:self.previewFromRect];
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

- (void)initObjectsForWindowModeIfNeeded {
    if (!self.previewWindow) {
        self.previewWindow = [[UIWindow alloc] init];
        self.previewWindow.windowLevel = UIWindowLevelQMUIImagePreviewView;
        self.previewWindow.backgroundColor = UIColorClear;
    }
    
    if (!self.exitGesture && self.exitGestureEnabled) {
        self.exitGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handleExitPreviewGesture:)];
        [self.previewWindow addGestureRecognizer:self.exitGesture];
    }
    
    if (!self.maskLayer) {
        self.maskLayer = [CALayer layer];
        [self.maskLayer qmui_removeDefaultAnimations];
        self.maskLayer.backgroundColor = [UIColor whiteColor].CGColor;
    }
}

- (void)removeObjectsForWindowMode {
    
    [self.exitGesture removeTarget:self action:@selector(handleExitPreviewGesture:)];
    [self.previewWindow removeGestureRecognizer:self.exitGesture];
    self.exitGesture = nil;
    
    self.previewWindow.hidden = YES;
    self.previewWindow.rootViewController = nil;
    self.previewWindow = nil;
}

BeginIgnoreClangWarning(-Wobjc-protocol-method-implementation)
- (void)startPreviewByTransformFromRect:(CGRect)fromRect {
    QMUIZoomImageView *zoomImageView = [self.imagePreviewView zoomImageViewAtIndex:self.imagePreviewView.currentImageIndex];
    if (!zoomImageView) {
        NSAssert(NO, @"第 %@ 个 zoomImageView 不存在，可能当前还处于非可视区域", @(self.imagePreviewView.currentImageIndex));
    }
    [self transformZoomImageView:zoomImageView withRect:fromRect isStart:YES beforeAnimation:nil animationBlock:^{
        self.view.backgroundColor = self.backgroundColorTemporarily;
    } completion:nil];
}
EndIgnoreClangWarning

- (void)exitPreviewByTransformToRect:(CGRect)toRect {
    QMUIZoomImageView *zoomImageView = self.gestureZoomImageView ?: [self.imagePreviewView zoomImageViewAtIndex:self.imagePreviewView.currentImageIndex];
    [self transformZoomImageView:zoomImageView withRect:toRect isStart:NO beforeAnimation:^{
        if (!self.backgroundColorTemporarily) {
            // 如果是手势触发的 exit，在手势 began 时就已经设置好 backgroundColorTemporarily 了，所以这里只为那种单击或者用代码 exit 的情况
            self.backgroundColorTemporarily = self.view.backgroundColor;
        }
    } animationBlock:^{
        self.view.backgroundColor = UIColorClear;
    } completion:^{
        [self removeObjectsForWindowMode];
        [self resetExitGesture];
    }];
}

- (void)transformZoomImageView:(QMUIZoomImageView *)zoomImageView withRect:(CGRect)rect isStart:(BOOL)isStart beforeAnimation:(void (^)(void))beforeAnimation animationBlock:(void (^)(void))animationBlock completion:(void (^)(void))completion {
    
    // 前期准备
    
    NSTimeInterval duration = .25;
    
    CGRect contentViewFrame = [self.view convertRect:zoomImageView.contentViewRectInZoomImageView fromView:nil];
    CGPoint contentViewCenterInZoomImageView = CGPointGetCenterWithRect(zoomImageView.contentViewRectInZoomImageView);
    if (CGRectIsEmpty(contentViewFrame)) {
        // 有可能 start preview 时图片还在 loading，此时拿到的 content rect 是 zero，所以做个保护
        contentViewFrame = [self.view convertRect:zoomImageView.frame fromView:zoomImageView.superview];
        contentViewCenterInZoomImageView = CGPointGetCenterWithRect(contentViewFrame);
    }
    CGPoint centerInZoomImageView = CGPointGetCenterWithRect(zoomImageView.bounds);// 注意不是 zoomImageView 的 center，而是 zoomImageView 这个容器里的中心点
    CGFloat horizontalRatio = CGRectGetWidth(rect) / CGRectGetWidth(contentViewFrame);
    CGFloat verticalRatio = CGRectGetHeight(rect) / CGRectGetHeight(contentViewFrame);
    CGFloat finalRatio = MAX(horizontalRatio, verticalRatio);
    
    CGAffineTransform fromTransform = CGAffineTransformIdentity;
    CGAffineTransform toTransform = CGAffineTransformIdentity;
    CGAffineTransform transform = CGAffineTransformIdentity;
    
    // 先缩再移
    transform = CGAffineTransformScale(transform, finalRatio, finalRatio);
    CGPoint contentViewCenterAfterScale = CGPointMake(centerInZoomImageView.x + (contentViewCenterInZoomImageView.x - centerInZoomImageView.x) * finalRatio, centerInZoomImageView.y + (contentViewCenterInZoomImageView.y - centerInZoomImageView.y) * finalRatio);
    CGSize translationAfterScale = CGSizeMake(CGRectGetMidX(rect) - contentViewCenterAfterScale.x, CGRectGetMidY(rect) - contentViewCenterAfterScale.y);
    transform = CGAffineTransformConcat(transform, CGAffineTransformMakeTranslation(translationAfterScale.width, translationAfterScale.height));
    
    if (isStart) {
        fromTransform = transform;
    } else {
        toTransform = transform;
    }
    
    CGRect maskFromBounds = zoomImageView.contentView.bounds;
    CGRect maskToBounds = zoomImageView.contentView.bounds;
    CGRect maskBounds = maskFromBounds;
    CGFloat maskHorizontalRatio = CGRectGetWidth(rect) / CGRectGetWidth(maskBounds);
    CGFloat maskVerticalRatio = CGRectGetHeight(rect) / CGRectGetHeight(maskBounds);
    CGFloat maskFinalRatio = MAX(maskHorizontalRatio, maskVerticalRatio);
    maskBounds = CGRectMakeWithSize(CGSizeMake(CGRectGetWidth(rect) / maskFinalRatio, CGRectGetHeight(rect) / maskFinalRatio));
    if (isStart) {
        maskFromBounds = maskBounds;
    } else {
        maskToBounds = maskBounds;
    }

    CGFloat cornerRadius = self.transitionCornerRadius / maskFinalRatio;
    CGFloat fromCornerRadius = isStart ? cornerRadius : 0;
    CGFloat toCornerRadius = isStart ? 0 : cornerRadius;
    CABasicAnimation *cornerRadiusAnimation = [CABasicAnimation animationWithKeyPath:@"cornerRadius"];
    cornerRadiusAnimation.fromValue = @(fromCornerRadius);
    cornerRadiusAnimation.toValue = @(toCornerRadius);

    CABasicAnimation *boundsAnimation = [CABasicAnimation animationWithKeyPath:@"bounds"];
    boundsAnimation.fromValue = [NSValue valueWithCGRect:CGRectMakeWithSize(maskFromBounds.size)];
    boundsAnimation.toValue = [NSValue valueWithCGRect:CGRectMakeWithSize(maskToBounds.size)];

    CAAnimationGroup *maskAnimation = [[CAAnimationGroup alloc] init];
    maskAnimation.duration = duration;
    maskAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
    maskAnimation.fillMode = kCAFillModeForwards;
    maskAnimation.removedOnCompletion = NO;// remove 都交给 UIView Block 的 completion 里做，这里是为了避免 Core Animation 和 UIView Animation Block 时间不一致导致的值变动
    maskAnimation.animations = @[cornerRadiusAnimation, boundsAnimation];
    self.maskLayer.position = CGPointGetCenterWithRect(zoomImageView.contentView.bounds);// 不管怎样，mask 都是居中的
    zoomImageView.contentView.layer.mask = self.maskLayer;
    [self.maskLayer addAnimation:maskAnimation forKey:@"maskAnimation"];
    
    // 动画开始
    zoomImageView.scrollView.clipsToBounds = NO;// 当 contentView 被放大后，如果不去掉 clipToBounds，那么退出预览时，contentView 溢出的那部分内容就看不到
    
    if (isStart) {
        zoomImageView.transform = fromTransform;
    }
    
    if (beforeAnimation) {
        beforeAnimation();
    }
    
    // 发现 zoomImageView.transform 用 UIView Animation Block 实现的话，手势拖拽 exit 的情况下，松手时会瞬间跳动到某个位置，然后才继续做动画，改为 Core Animation 就没这个问题
    CABasicAnimation *transformAnimation = [CABasicAnimation animationWithKeyPath:@"transform"];
    transformAnimation.toValue = [NSValue valueWithCATransform3D:CATransform3DMakeAffineTransform(toTransform)];
    transformAnimation.duration = duration;
    transformAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    transformAnimation.fillMode = kCAFillModeForwards;
    transformAnimation.removedOnCompletion = NO;// remove 都交给 UIView Block 的 completion 里做，这里是为了避免 Core Animation 和 UIView Animation Block 时间不一致导致的值变动
    [zoomImageView.layer addAnimation:transformAnimation forKey:@"transformAnimation"];
    
    [UIView animateWithDuration:duration delay:0.0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        if (animationBlock) {
            animationBlock();
        }
    } completion:^(BOOL finished) {
        if (completion) {
            completion();
        }
        [self.maskLayer removeAnimationForKey:@"maskAnimation"];
        self.backgroundColorTemporarily = nil;
        zoomImageView.scrollView.clipsToBounds = YES;// UIScrollView.clipsToBounds default is YES
        zoomImageView.contentView.layer.mask = nil;
        zoomImageView.transform = CGAffineTransformIdentity;
        [zoomImageView.layer removeAnimationForKey:@"transformAnimation"];
    }];
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
    
    [self initObjectsForWindowModeIfNeeded];
    
    self.previewWindow.rootViewController = self;
    self.previewWindow.hidden = NO;
}

- (void)exitPreviewByFadingAnimation:(BOOL)isFading orToRect:(CGRect)rect {
    
    if (isFading) {
        if (!self.backgroundColorTemporarily) {
            // 如果是手势触发的 exit，在手势 began 时就已经设置好 backgroundColorTemporarily 了，所以这里只为那种单击或者用代码 exit 的情况
            self.backgroundColorTemporarily = self.view.backgroundColor;
        }
        [UIView animateWithDuration:.25 delay:0.0 options:QMUIViewAnimationOptionsCurveOut animations:^{
            self.view.alpha = 0;
        } completion:^(BOOL finished) {
            [self removeObjectsForWindowMode];
            [self resetExitGesture];
            self.view.alpha = 1;
        }];
        return;
    }
    
    [self exitPreviewByTransformToRect:rect];
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
            self.gestureZoomImageView.scrollView.clipsToBounds = NO;// 当 contentView 被放大后，如果不去掉 clipToBounds，那么手势退出预览时，contentView 溢出的那部分内容就看不到
            self.backgroundColorTemporarily = self.view.backgroundColor;
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
            CGAffineTransform transform = CGAffineTransformMakeTranslation(horizontalDistance, verticalDistance);
            transform = CGAffineTransformScale(transform, ratio, ratio);
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
    self.view.backgroundColor = self.backgroundColorTemporarily;// 重置回之前的遮罩背景色，因此要求每一种 exit 方式在 exit 之前都要先给 self.backgroundColorTemporarily 赋值
}

@end
