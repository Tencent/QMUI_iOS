//
//  QMUIModalPresentationViewController.m
//  qmui
//
//  Created by MoLice on 16/7/6.
//  Copyright © 2016年 QMUI Team. All rights reserved.
//

#import "QMUIModalPresentationViewController.h"
#import "QMUICommonDefines.h"
#import "QMUIConfiguration.h"
#import "QMUIHelper.h"

@interface UIViewController ()

@property(nonatomic, weak, readwrite) QMUIModalPresentationViewController *modalPresentedViewController;
@end

@implementation QMUIModalPresentationViewController (UIAppearance)

static QMUIModalPresentationViewController *appearance;
+ (instancetype)appearance {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        [self initDefaultAppearance];
    });
    return appearance;
}

+ (void)initDefaultAppearance {
    if (!appearance) {
        appearance = [[self alloc] init];
    }
    appearance.animationStyle = QMUIModalPresentationAnimationStyleFade;
    appearance.contentViewMargins = UIEdgeInsetsMake(20, 20, 20, 20);
    appearance.maximumContentViewWidth = ([QMUIHelper screenSizeFor47Inch].width - UIEdgeInsetsGetHorizontalValue(appearance.contentViewMargins));
}

+ (void)initialize {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        [self appearance];
    });
}

@end

@interface QMUIModalPresentationViewController ()

@property(nonatomic, strong) QMUIModalPresentationWindow *containerWindow;
@property(nonatomic, weak) UIWindow *previousKeyWindow;

@property(nonatomic, assign) BOOL appearAnimated;
@property(nonatomic, copy) void (^appearCompletionBlock)(BOOL finished);

@property(nonatomic, assign) BOOL disappearAnimated;
@property(nonatomic, copy) void (^disappearCompletionBlock)(BOOL finished);

/// 标志是否已经走过一次viewWillAppear了，用于hideInView的情况
@property(nonatomic, assign) BOOL hasAlreadyViewWillDisappear;

@property(nonatomic, strong) UITapGestureRecognizer *dimmingViewTapGestureRecognizer;
@property(nonatomic, assign) CGFloat keyboardHeight;
@end

@implementation QMUIModalPresentationViewController

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        [self didInitialized];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
        [self didInitialized];
    }
    return self;
}

- (void)didInitialized {
    if (appearance) {
        self.animationStyle = appearance.animationStyle;
        self.contentViewMargins = appearance.contentViewMargins;
        self.maximumContentViewWidth = appearance.maximumContentViewWidth;
        self.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
        self.modalPresentationStyle = UIModalPresentationCustom;
        self.supportedOrientationMask = SupportedOrientationMask;
    }
    
    [self initDefaultDimmingViewWithoutAddToView];
}

- (void)dealloc {
    self.containerWindow = nil;
}

- (BOOL)shouldAutomaticallyForwardAppearanceMethods {
    // 屏蔽对childViewController的生命周期函数的自动调用，改为手动控制
    return NO;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    if (self.dimmingView && !self.dimmingView.superview) {
        [self.view addSubview:self.dimmingView];
    }
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    
    self.dimmingView.frame = self.view.bounds;
    
    CGRect contentViewFrame = [self contentViewFrameForShowing];
    if (self.layoutBlock) {
        self.layoutBlock(self.view.bounds, self.keyboardHeight, contentViewFrame);
    } else {
        self.contentView.frame = contentViewFrame;
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if (self.containerWindow) {
        // 只有使用showWithAnimated:completion:显示出来的浮层，才需要修改之前就记住的animated的值
        animated = self.appearAnimated;
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleKeyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleKeyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    
    if (self.contentViewController) {
        self.contentViewController.modalPresentedViewController = self;
        [self.contentViewController beginAppearanceTransition:YES animated:animated];
    }
    
    [QMUIHelper dimmedApplicationWindow];
    
    void (^didShownCompletion)(BOOL finished) = ^(BOOL finished) {
        if (self.contentViewController) {
            [self.contentViewController endAppearanceTransition];
        }
        
        _visible = YES;
        
        if (self.appearCompletionBlock) {
            self.appearCompletionBlock(finished);
            self.appearCompletionBlock = nil;
        }
        
        self.appearAnimated = NO;
    };
    
    if (animated) {
        [self.view addSubview:self.contentView];
        [self.view layoutIfNeeded];
        
        CGRect contentViewFrame = [self contentViewFrameForShowing];
        if (self.showingAnimation) {
            // 使用自定义的动画
            if (self.layoutBlock) {
                self.layoutBlock(self.view.bounds, self.keyboardHeight, contentViewFrame);
                contentViewFrame = self.contentView.frame;
            }
            self.showingAnimation(self.dimmingView, self.view.bounds, self.keyboardHeight, contentViewFrame, didShownCompletion);
        } else {
            self.contentView.frame = contentViewFrame;
            [self.contentView setNeedsLayout];
            [self.contentView layoutIfNeeded];
            
            [self showingAnimationWithCompletion:didShownCompletion];
        }
    } else {
        CGRect contentViewFrame = [self contentViewFrameForShowing];
        self.contentView.frame = contentViewFrame;
        [self.view addSubview:self.contentView];
        self.dimmingView.alpha = 1;
        didShownCompletion(YES);
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    if (self.hasAlreadyViewWillDisappear) {
        return;
    }
    
    [super viewWillDisappear:animated];
    if (self.containerWindow) {
        animated = self.disappearAnimated;
    }
    
    if ([self.delegate respondsToSelector:@selector(willHideModalPresentationViewController:)]) {
        [self.delegate willHideModalPresentationViewController:self];
    }
    
    void (^didHiddenCompletion)(BOOL finished) = ^(BOOL finished) {
        
        if (self.containerWindow) {
            // 恢复 keyWindow 之前做一下检查，避免这个问题 https://github.com/QMUI/QMUI_iOS/issues/90
            if ([[UIApplication sharedApplication] keyWindow] == self.containerWindow) {
                [self.previousKeyWindow makeKeyWindow];
            }
            self.containerWindow.hidden = YES;
            self.containerWindow.rootViewController = nil;
            self.previousKeyWindow = nil;
            [self endAppearanceTransition];
        }
        
        if (self.view.superview) {
            // 这句是给addSubview的形式显示的情况下使用，但会触发第二次viewWillDisappear:，所以要搭配self.hasAlreadyViewWillDisappear使用
            [self.view removeFromSuperview];
            self.hasAlreadyViewWillDisappear = NO;
        }
        
        [self.contentView removeFromSuperview];
        self.contentView = nil;
        if (self.contentViewController) {
            [self.contentViewController endAppearanceTransition];
        }
        
        _visible = NO;
        
        if ([self.delegate respondsToSelector:@selector(didHideModalPresentationViewController:)]) {
            [self.delegate didHideModalPresentationViewController:self];
        }
        
        if (self.disappearCompletionBlock) {
            self.disappearCompletionBlock(YES);
            self.disappearCompletionBlock = nil;
        }
        
        if (self.contentViewController) {
            self.contentViewController.modalPresentedViewController = nil;
            self.contentViewController = nil;
        }
        
        self.disappearAnimated = NO;
    };
    
    // 在降下键盘前取消对键盘事件的监听，从而避免键盘影响隐藏浮层的动画
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
    
    [QMUIHelper resetDimmedApplicationWindow];
    [self.view endEditing:YES];
    
    if (self.contentViewController) {
        [self.contentViewController beginAppearanceTransition:NO animated:animated];
    }
    
    if (animated) {
        if (self.hidingAnimation) {
            self.hidingAnimation(self.dimmingView, self.view.bounds, self.keyboardHeight, didHiddenCompletion);
        } else {
            [self hidingAnimationWithCompletion:didHiddenCompletion];
        }
    } else {
        didHiddenCompletion(YES);
    }
}

#pragma mark - Dimming View

- (void)setDimmingView:(UIView *)dimmingView {
    if (![self isViewLoaded]) {
        _dimmingView = dimmingView;
    } else {
        [self.view insertSubview:dimmingView belowSubview:_dimmingView];
        [_dimmingView removeFromSuperview];
        _dimmingView = dimmingView;
        [self.view setNeedsLayout];
    }
    [self addTapGestureRecognizerToDimmingViewIfNeeded];
}

- (void)initDefaultDimmingViewWithoutAddToView {
    if (!self.dimmingView) {
        _dimmingView = [[UIView alloc] init];
        self.dimmingView.backgroundColor = UIColorMask;
        [self addTapGestureRecognizerToDimmingViewIfNeeded];
        if ([self isViewLoaded]) {
            [self.view addSubview:self.dimmingView];
        }
    }
}

// 要考虑用户可能创建了自己的dimmingView，则tap手势也要重新添加上去
- (void)addTapGestureRecognizerToDimmingViewIfNeeded {
    if (!self.dimmingView) {
        return;
    }
    
    if (self.dimmingViewTapGestureRecognizer.view == self.dimmingView) {
        return;
    }
    
    if (!self.dimmingViewTapGestureRecognizer) {
        self.dimmingViewTapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleDimmingViewTapGestureRecognizer:)];
    }
    [self.dimmingView addGestureRecognizer:self.dimmingViewTapGestureRecognizer];
    self.dimmingView.userInteractionEnabled = YES;// UIImageView默认userInteractionEnabled为NO，为了兼容UIImageView，这里必须主动设置为YES
}

- (void)handleDimmingViewTapGestureRecognizer:(UITapGestureRecognizer *)tapGestureRecognizer {
    if (self.modal) {
        return;
    }
    
    if (self.containerWindow) {
        // 认为是以 UIWindow 的形式显示出来
        __weak __typeof(self)weakSelf = self;
        [self hideWithAnimated:YES completion:^(BOOL finished) {
            if (weakSelf.didHideByDimmingViewTappedBlock) {
                weakSelf.didHideByDimmingViewTappedBlock();
            }
        }];
    } else if (self.presentingViewController && self.presentingViewController.presentedViewController == self) {
        // 认为是以 presentViewController 的形式显示出来
        [self dismissViewControllerAnimated:YES completion:^{
            if (self.didHideByDimmingViewTappedBlock) {
                self.didHideByDimmingViewTappedBlock();
            }
        }];
    } else {
        // 认为是 addSubview 的形式显示出来
        __weak __typeof(self)weakSelf = self;
        [self hideInView:self.view.superview animated:YES completion:^(BOOL finished) {
            if (weakSelf.didHideByDimmingViewTappedBlock) {
                weakSelf.didHideByDimmingViewTappedBlock();
            }
        }];
    }
}

#pragma mark - ContentView

- (void)setContentViewController:(UIViewController<QMUIModalPresentationContentViewControllerProtocol> *)contentViewController {
    _contentViewController = contentViewController;
    self.contentView = contentViewController.view;
}

#pragma mark - Showing and Hiding

- (void)showingAnimationWithCompletion:(void (^)(BOOL))completion {
    if (self.animationStyle == QMUIModalPresentationAnimationStyleFade) {
        self.dimmingView.alpha = 0.0;
        self.contentView.alpha = 0.0;
        [UIView animateWithDuration:.2 delay:0.0 options:QMUIViewAnimationOptionsCurveOut animations:^{
            self.dimmingView.alpha = 1.0;
            self.contentView.alpha = 1.0;
        } completion:^(BOOL finished) {
            if (completion) {
                completion(finished);
            }
        }];
        
    } else if (self.animationStyle == QMUIModalPresentationAnimationStylePopup) {
        self.dimmingView.alpha = 0.0;
        self.contentView.transform = CGAffineTransformMakeScale(0, 0);
        [UIView animateWithDuration:.3 delay:0.0 options:QMUIViewAnimationOptionsCurveOut animations:^{
            self.dimmingView.alpha = 1.0;
            self.contentView.transform = CGAffineTransformMakeScale(1, 1);
        } completion:^(BOOL finished) {
            self.contentView.transform = CGAffineTransformIdentity;
            if (completion) {
                completion(finished);
            }
        }];
        
    } else if (self.animationStyle == QMUIModalPresentationAnimationStyleSlide) {
        self.dimmingView.alpha = 0.0;
        self.contentView.transform = CGAffineTransformMakeTranslation(0, CGRectGetHeight(self.view.bounds) - CGRectGetMinY(self.contentView.frame));
        [UIView animateWithDuration:.3 delay:0.0 options:QMUIViewAnimationOptionsCurveOut animations:^{
            self.dimmingView.alpha = 1.0;
            self.contentView.transform = CGAffineTransformIdentity;
        } completion:^(BOOL finished) {
            if (completion) {
                completion(finished);
            }
        }];
    }
}

- (void)showWithAnimated:(BOOL)animated completion:(void (^)(BOOL))completion {
    // makeKeyAndVisible 导致的 viewWillAppear: 必定 animated 是 NO 的，所以这里用额外的变量保存这个 animated 的值
    self.appearAnimated = animated;
    self.appearCompletionBlock = completion;
    self.previousKeyWindow = [UIApplication sharedApplication].keyWindow;
    if (!self.containerWindow) {
        self.containerWindow = [[QMUIModalPresentationWindow alloc] init];
        self.containerWindow.windowLevel = UIWindowLevelQMUIAlertView;
        self.containerWindow.backgroundColor = UIColorClear;// 避免横竖屏旋转时出现黑色
    }
    self.containerWindow.rootViewController = self;
    [self.containerWindow makeKeyAndVisible];
}

- (void)hidingAnimationWithCompletion:(void (^)(BOOL))completion {
    if (self.animationStyle == QMUIModalPresentationAnimationStyleFade) {
        [UIView animateWithDuration:.2 delay:0.0 options:QMUIViewAnimationOptionsCurveOut animations:^{
            self.dimmingView.alpha = 0.0;
            self.contentView.alpha = 0.0;
        } completion:^(BOOL finished) {
            if (completion) {
                completion(finished);
            }
        }];
    } else if (self.animationStyle == QMUIModalPresentationAnimationStylePopup) {
        [UIView animateWithDuration:.3 delay:0.0 options:QMUIViewAnimationOptionsCurveOut animations:^{
            self.dimmingView.alpha = 0.0;
            self.contentView.transform = CGAffineTransformMakeScale(0.0, 0.0);
        } completion:^(BOOL finished) {
            if (completion) {
                self.contentView.transform = CGAffineTransformIdentity;
                completion(finished);
            }
        }];
    } else if (self.animationStyle == QMUIModalPresentationAnimationStyleSlide) {
        [UIView animateWithDuration:.3 delay:0.0 options:UIViewAnimationOptionCurveLinear animations:^{
            self.dimmingView.alpha = 0.0;
            self.contentView.transform = CGAffineTransformMakeTranslation(0, CGRectGetHeight(self.view.bounds) - CGRectGetMinY(self.contentView.frame));
        } completion:^(BOOL finished) {
            if (completion) {
                self.contentView.transform = CGAffineTransformIdentity;
                completion(finished);
            }
        }];
    }
}

- (void)hideWithAnimated:(BOOL)animated completion:(void (^)(BOOL))completion {
    self.disappearAnimated = animated;
    self.disappearCompletionBlock = completion;
    
    BOOL shouldHide = YES;
    if ([self.delegate respondsToSelector:@selector(shouldHideModalPresentationViewController:)]) {
        shouldHide = [self.delegate shouldHideModalPresentationViewController:self];
    }
    if (!shouldHide) {
        return;
    }
    
    // window模式下，通过手动触发viewWillDisappear:来做界面消失的逻辑
    if (self.containerWindow) {
        [self beginAppearanceTransition:NO animated:animated];
    }
}

- (void)showInView:(UIView *)view animated:(BOOL)animated completion:(void (^)(BOOL))completion {
    self.appearCompletionBlock = completion;
    [self loadViewIfNeeded];
    [self beginAppearanceTransition:YES animated:animated];
    [view addSubview:self.view];
    [self endAppearanceTransition];
}

- (void)hideInView:(UIView *)view animated:(BOOL)animated completion:(void (^)(BOOL))completion {
    self.disappearCompletionBlock = completion;
    [self beginAppearanceTransition:NO animated:animated];
    self.hasAlreadyViewWillDisappear = YES;
    [self endAppearanceTransition];
}

- (CGRect)contentViewFrameForShowing {
    CGSize contentViewContainerSize = CGSizeMake(CGRectGetWidth(self.view.bounds) - UIEdgeInsetsGetHorizontalValue(self.contentViewMargins), CGRectGetHeight(self.view.bounds) - self.keyboardHeight - UIEdgeInsetsGetVerticalValue(self.contentViewMargins));
    CGSize contentViewLimitSize = CGSizeMake(fminf(self.maximumContentViewWidth, contentViewContainerSize.width), contentViewContainerSize.height);
    CGSize contentViewSize = CGSizeZero;
    if ([self.contentViewController respondsToSelector:@selector(preferredContentSizeInModalPresentationViewController:limitSize:)]) {
        contentViewSize = [self.contentViewController preferredContentSizeInModalPresentationViewController:self limitSize:contentViewLimitSize];
    } else {
        contentViewSize = [self.contentView sizeThatFits:contentViewLimitSize];
    }
    contentViewSize.width = fminf(contentViewLimitSize.width, contentViewSize.width);
    contentViewSize.height = fminf(contentViewLimitSize.height, contentViewSize.height);
    CGRect contentViewFrame = CGRectMake(CGFloatGetCenter(contentViewContainerSize.width, contentViewSize.width) + self.contentViewMargins.left, CGFloatGetCenter(contentViewContainerSize.height, contentViewSize.height) + self.contentViewMargins.top, contentViewSize.width, contentViewSize.height);
    
    // showingAnimation、hidingAnimation里会通过设置contentView的transform来做动画，所以可能在showing的过程中设置了transform后，系统触发viewDidLayoutSubviews，在viewDidLayoutSubviews里计算的frame又是最终状态的frame，与showing时的transform冲突，导致动画过程中浮层跳动或者位置错误，所以为了保证layout时计算出来的frame与showing/hiding时计算的frame一致，这里给frame应用了transform。但这种处理方法也有局限：如果你在showingAnimation/hidingAnimation里对contentView.frame的更改不是通过修改transform而是直接修改frame来得到结果，那么这里这句CGRectApplyAffineTransform就没用了，viewDidLayoutSubviews里算出来的frame依然会和showingAnimation/hidingAnimation冲突。
    contentViewFrame = CGRectApplyAffineTransform(contentViewFrame, self.contentView.transform);
    return contentViewFrame;
}

#pragma mark - Keyboard

- (void)handleKeyboardWillShow:(NSNotification *)notification {
    CGFloat keyboardHeight = [QMUIHelper keyboardHeightWithNotification:notification inView:self.view];
    if (keyboardHeight > 0) {
        self.keyboardHeight = keyboardHeight;
        [self.view setNeedsLayout];
    }
}

- (void)handleKeyboardWillHide:(NSNotification *)notification {
    self.keyboardHeight = 0;
    [self.view setNeedsLayout];
}

#pragma mark - 屏幕旋转

- (BOOL)shouldAutorotate {
    UIViewController *visibleViewController = [QMUIHelper visibleViewController];
    if (visibleViewController != self && [visibleViewController respondsToSelector:@selector(shouldAutorotate)]) {
        return [visibleViewController shouldAutorotate];
    }
    return YES;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    UIViewController *visibleViewController = [QMUIHelper visibleViewController];
    if (visibleViewController != self && [visibleViewController respondsToSelector:@selector(supportedInterfaceOrientations)]) {
        return [visibleViewController supportedInterfaceOrientations];
    }
    return self.supportedOrientationMask;
}

@end

@implementation QMUIModalPresentationViewController (Manager)

+ (BOOL)isAnyModalPresentationViewControllerVisible {
    for (UIWindow *window in [[UIApplication sharedApplication] windows]) {
        if ([window isKindOfClass:[QMUIModalPresentationWindow class]] && !window.hidden) {
            return YES;
        }
    }
    return NO;
}

+ (BOOL)hideAllVisibleModalPresentationViewControllerIfCan {
    
    BOOL hideAllFinally = YES;
    
    for (UIWindow *window in [[UIApplication sharedApplication] windows]) {
        if (![window isKindOfClass:[QMUIModalPresentationWindow class]]) {
            continue;
        }
        
        // 存在modalViewController，但并没有显示出来，所以不用处理
        if (window.hidden) {
            continue;
        }
        
        // 存在window，但不存在modalViewController，则直接把这个window移除
        if (!window.rootViewController) {
            window.hidden = YES;
            continue;
        }
        
        QMUIModalPresentationViewController *modalViewController = (QMUIModalPresentationViewController *)window.rootViewController;
        BOOL canHide = YES;
        if ([modalViewController.delegate respondsToSelector:@selector(shouldHideModalPresentationViewController:)]) {
            canHide = [modalViewController.delegate shouldHideModalPresentationViewController:modalViewController];
        }
        if (canHide) {
            if ([modalViewController.delegate respondsToSelector:@selector(requestHideAllModalPresentationViewController)]) {
                [modalViewController.delegate requestHideAllModalPresentationViewController];
            } else {
                [modalViewController hideWithAnimated:NO completion:nil];
            }
        } else {
            // 只要有一个modalViewController正在显示但却无法被隐藏，就返回NO
            hideAllFinally = NO;
        }
    }
    
    return hideAllFinally;
}

@end

@implementation QMUIModalPresentationWindow

@end

@implementation UIViewController (QMUIModalPresentationViewController)

static char kAssociatedObjectKey_ModalPresentationViewController;
- (void)setModalPresentedViewController:(QMUIModalPresentationViewController *)modalPresentedViewController {
    objc_setAssociatedObject(self, &kAssociatedObjectKey_ModalPresentationViewController, modalPresentedViewController, OBJC_ASSOCIATION_ASSIGN);
}

- (QMUIModalPresentationViewController *)modalPresentedViewController {
    return (QMUIModalPresentationViewController *)objc_getAssociatedObject(self, &kAssociatedObjectKey_ModalPresentationViewController);
}

@end
