//
//  QMUISheetPresentationSupports.m
//  QMUIKit
//
//  Created by molice on 2024/2/27.
//  Copyright © 2024 QMUI Team. All rights reserved.
//

#import "QMUISheetPresentationSupports.h"
#import "QMUICore.h"
#import "UIView+QMUI.h"
#import "UIViewController+QMUI.h"
#import "QMUISheetPresentationNavigationBar.h"
#import "QMUIMultipleDelegates.h"

// QMUISheet 模式下升起半屏的导航时，专用于存放第一个 vc 的带半透明背景的容器，由它负责决定业务 vc 的半屏布局
@interface QMUISheetRootContainerViewController : UIViewController<QMUINavigationControllerDelegate, UIViewControllerTransitioningDelegate, UIGestureRecognizerDelegate>
@property(nonatomic, strong, readonly) UIControl *dimmingControl;
@property(nonatomic, strong, readonly) UIView *containerView;
@property(nonatomic, strong, readonly) QMUISheetPresentationNavigationBar *navigationBar;
@property(nonatomic, strong, readonly) UIViewController *rootViewController;

@property(nonatomic, strong) UIPercentDrivenInteractiveTransition *interactiveTransition;
@property(nonatomic, strong) UIScreenEdgePanGestureRecognizer *edgePan;
@property(nonatomic, strong) UIPanGestureRecognizer *pullPan;

@property(nonatomic, assign) BOOL shouldPerformPresentAnimation;
- (void)layout;
@end

@interface QMUISheetRootControllerAnimator : NSObject<UIViewControllerAnimatedTransitioning>
@property(nonatomic, assign) BOOL isPresenting;
@property(nonatomic, weak) QMUISheetRootContainerViewController *containerViewController;
@end

@implementation QMUISheetRootControllerAnimator

- (NSTimeInterval)transitionDuration:(id<UIViewControllerContextTransitioning>)transitionContext {
    return .25;// 在 viewSafeAreaInsetsDidChange 里也有一个 duration，两者保持一致
}

- (void)animateTransition:(id<UIViewControllerContextTransitioning>)transitionContext {
    
    if (self.isPresenting) {
        UIView *containerView = transitionContext.containerView;
        UIView *toView = [transitionContext viewForKey:UITransitionContextToViewKey];// 这个是 UINavigationController.view
        
        // 把 layout 独立一个方法，不直接调用 [self.view setNeedsLayout] 是因为后者的做法会影响业务界面生命周期方法的时序（具体参考上方 animateTransition 的注释）
        // 此时 nav 里的导航栏等 subviews 已经布局好，但 containerRootVc 尚未被添加到 nav 里，所以它的 safeAreaInsets 不准确（为0），所以无法在此刻就计算出一个准确的浮层高度，所以通过标志位的方式延后到 viewSafeAreaInsetsDidChange 里处理
        self.containerViewController.shouldPerformPresentAnimation = YES;
        [containerView addSubview:toView];
        toView.frame = containerView.bounds;
        [transitionContext completeTransition:!transitionContext.transitionWasCancelled];
        return;
    }
    
    [UIView qmui_animateWithAnimated:transitionContext.animated duration:[self transitionDuration:transitionContext] delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        self.containerViewController.dimmingControl.alpha = 0;
        self.containerViewController.containerView.transform = CGAffineTransformMakeTranslation(0, CGRectGetHeight(self.containerViewController.containerView.frame));
    } completion:^(BOOL finished) {
        [transitionContext completeTransition:!transitionContext.transitionWasCancelled];
    }];
}

@end

@implementation QMUISheetRootContainerViewController

- (instancetype)initWithRootViewController:(UIViewController *)rootViewController {
    if (self = [self init]) {
        _rootViewController = rootViewController;
        [self addChildViewController:rootViewController];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    _dimmingControl = [[UIControl alloc] init];
    self.dimmingControl.backgroundColor = self.rootViewController.qmui_sheetPresentation.dimmingColor;
    self.dimmingControl.alpha = 0;
    [self.dimmingControl addTarget:self action:@selector(handleDimmingControlEvent) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.dimmingControl];
    
    _containerView = [[UIView alloc] init];
    self.containerView.layer.cornerRadius = self.rootViewController.qmui_sheetPresentation.cornerRadius;
    self.containerView.layer.maskedCorners = kCALayerMinXMinYCorner|kCALayerMaxXMinYCorner;
    self.containerView.layer.cornerCurve = kCACornerCurveContinuous;
    self.containerView.clipsToBounds = YES;
    [self.view addSubview:self.containerView];
    
    [self.containerView addSubview:self.rootViewController.view];
    
    _navigationBar = [[QMUISheetPresentationNavigationBar alloc] init];
    self.navigationBar.hidden = !self.rootViewController.qmui_sheetPresentation.shouldShowNavigationBar;
    self.navigationBar.navigationItem = self.rootViewController.navigationItem;
    [self.containerView addSubview:self.navigationBar];
    
    [self.rootViewController didMoveToParentViewController:self];
    
    self.edgePan = [[UIScreenEdgePanGestureRecognizer alloc] initWithTarget:self action:@selector(handleEdgePan:)];
    self.edgePan.edges = UIRectEdgeLeft;
    self.edgePan.qmui_multipleDelegatesEnabled = YES;
    self.edgePan.delegate = self;
    [self.view addGestureRecognizer:self.edgePan];
    
    self.pullPan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePullPan:)];
    self.pullPan.qmui_multipleDelegatesEnabled = YES;
    self.pullPan.delegate = self;
    [self.pullPan requireGestureRecognizerToFail:self.edgePan];
    [self.view addGestureRecognizer:self.pullPan];
}

- (UINavigationItem *)navigationItem {
    return self.rootViewController.navigationItem;
}

- (void)viewSafeAreaInsetsDidChange {
    [super viewSafeAreaInsetsDidChange];
    if (!self.shouldPerformPresentAnimation) return;
    
    CGFloat bottom = self.view.safeAreaInsets.bottom;
    if (IS_NOTCHED_SCREEN && bottom <= 0) return;
    
    self.dimmingControl.alpha = 0;
    [self layout];
    self.containerView.transform = CGAffineTransformMakeTranslation(0, CGRectGetHeight(self.containerView.frame));
    [UIView animateWithDuration:.25 delay:0 options:QMUIViewAnimationOptionsCurveOut animations:^{
        self.dimmingControl.alpha = 1;
        self.containerView.transform = CGAffineTransformIdentity;
    } completion:nil];
    
    self.shouldPerformPresentAnimation = NO;
}

// 把 layout 独立一个方法，不直接调用 [self.view setNeedsLayout] 是因为后者的做法会影响业务界面生命周期方法的时序（iOS 17 上验证，iOS 15 顺序一致，但两个 layout 方法会调用多两次）。
// 如果普通 push，时序应该是 viewWillAppear:-viewIsAppearing:-viewWillLayoutSubviews-viewDidLayoutSubviews，而在 viewSafeAreaInsetsDidChange 里做动画前就调用 [self.view setNeedsLayout]，时序会变成 viewWillLayoutSubviews-viewDidLayoutSubviews-viewWillAppear:-viewIsAppearing:，这令业务界面无法用一套代码同时兼容普通 push 模式和 sheet 模式。
- (void)layout {
    self.dimmingControl.frame = self.view.bounds;
    
    CGFloat navigationBarHeight = 0;
    if (!self.navigationBar.hidden) {
        [self.navigationBar sizeToFit];
        navigationBarHeight = CGRectGetHeight(self.navigationBar.frame);
    }
    CGFloat maximumWidth = MIN(QMUIHelper.screenSizeFor67InchAndiPhone14Later.width, CGRectGetWidth(self.view.bounds));
    CGFloat maximumHeight = CGRectGetHeight(self.view.bounds);
    CGSize size = CGSizeZero;
    if (self.rootViewController.qmui_sheetPresentation.preferredSheetContentSizeBlock) {
        size = self.rootViewController.qmui_sheetPresentation.preferredSheetContentSizeBlock(self.rootViewController.qmui_sheetPresentation, CGSizeMake(MIN(maximumWidth, CGRectGetWidth(self.view.bounds)), maximumHeight));
    } else {
        size = CGSizeMake(maximumWidth, 200);// 随便搞个默认值
    }
    if (size.height != CGFLOAT_MAX && !isinf(size.height)) {// 如果业务传过来 CGFLOAT_MAX 则表示它希望撑满高度，此时就不要再进行叠加运算了，否则会因为溢出而产生错误的高度
        size.height = navigationBarHeight + size.height + self.view.safeAreaInsets.bottom;
    }
    CGSize containerSize = CGSizeMake(MIN(maximumWidth, size.width), MIN(maximumHeight, size.height));
    self.containerView.qmui_frameApplyTransform = CGRectMake(CGFloatGetCenter(CGRectGetWidth(self.view.bounds), containerSize.width), CGRectGetHeight(self.view.bounds) - containerSize.height, containerSize.width, containerSize.height);
    if (!self.navigationBar.hidden) {
        self.navigationBar.frame = CGRectMake(0, 0, CGRectGetWidth(self.containerView.bounds), navigationBarHeight);
        [self.navigationBar setNeedsLayout];
    }
    self.rootViewController.view.frame = CGRectMake(0, navigationBarHeight, CGRectGetWidth(self.containerView.bounds), CGRectGetHeight(self.containerView.bounds) - navigationBarHeight);
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    [self layout];
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return self.rootViewController.supportedInterfaceOrientations;
}

- (BOOL)prefersStatusBarHidden {
    return self.rootViewController.prefersStatusBarHidden;
}

- (UIViewController *)childViewControllerForStatusBarStyle {
    return self.rootViewController;
}

- (UIViewController *)childViewControllerForStatusBarHidden {
    return self.rootViewController;
}

- (UIViewController *)childViewControllerForHomeIndicatorAutoHidden {
    return self.rootViewController;
}

- (UIViewController *)qmui_visibleViewControllerIfExist {
    return self.rootViewController;
}

- (void)handleDimmingControlEvent {
    if (!self.rootViewController.qmui_sheetPresentation.modal) {
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

- (void)handleEdgePan:(UIScreenEdgePanGestureRecognizer *)pan {
    CGFloat process = [pan translationInView:pan.view].x / CGRectGetWidth(self.navigationController.view.bounds);
    process = MIN(1.0, MAX(0.0, process));
    switch (pan.state) {
        case UIGestureRecognizerStateBegan:
            self.interactiveTransition = [[UIPercentDrivenInteractiveTransition alloc] init];
            [self dismissViewControllerAnimated:YES completion:nil];
            break;
        case UIGestureRecognizerStateChanged:
            [self.interactiveTransition updateInteractiveTransition:process];
            break;
        case UIGestureRecognizerStateEnded:
        case UIGestureRecognizerStateCancelled: {
            CGPoint velocity = [pan velocityInView:pan.view];
            BOOL shouldFinish = velocity.x >= 0 && ((velocity.x > 800 && process > 0.1) || (velocity.x <= 800 && process > 0.2));
            if (shouldFinish) {
                [self.interactiveTransition finishInteractiveTransition];
            } else {
                [self.interactiveTransition cancelInteractiveTransition];
            }
            self.interactiveTransition = nil;
        }
            break;
        default:
            break;
    }
}

- (void)handlePullPan:(UIPanGestureRecognizer *)pan {
    CGFloat process = [pan translationInView:pan.view].y / CGRectGetHeight(self.containerView.frame);
    process = MIN(1.0, MAX(0.0, process));
    switch (pan.state) {
        case UIGestureRecognizerStateBegan:
            self.interactiveTransition = [[UIPercentDrivenInteractiveTransition alloc] init];
            [self dismissViewControllerAnimated:YES completion:nil];
            break;
        case UIGestureRecognizerStateChanged:
            [self.interactiveTransition updateInteractiveTransition:process];
            break;
        case UIGestureRecognizerStateEnded:
        case UIGestureRecognizerStateCancelled: {
            CGPoint velocity = [pan velocityInView:pan.view];
            BOOL shouldFinish = velocity.y >= 0 && ((velocity.y > 800 && process > 0.1) || (velocity.y <= 800 && process > 0.2));
            if (shouldFinish) {
                [self.interactiveTransition finishInteractiveTransition];
            } else {
                [self.interactiveTransition cancelInteractiveTransition];
            }
            self.interactiveTransition = nil;
        }
            break;
        default:
            break;
    }
}

#pragma mark - <UIGestureRecognizerDelegate>

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer {
    if (gestureRecognizer == self.edgePan && !self.rootViewController.qmui_sheetPresentation.supportsSwipeToDismiss) return NO;
    if (gestureRecognizer == self.pullPan && !self.rootViewController.qmui_sheetPresentation.supportsPullToDismiss) return NO;
    return YES;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    if (gestureRecognizer != self.edgePan && gestureRecognizer != self.pullPan) {
        return YES;
    }
    // navigationBar 上的按钮优先响应点击，不响应手势
    BOOL result = !([touch.view isDescendantOfView:self.navigationBar] && [touch.view isKindOfClass:UIControl.class]);
    return result;
}

#pragma mark - <QMUINavigationControllerDelegate>

- (BOOL)preferredNavigationBarHidden {
    return YES;
}

- (BOOL)shouldCustomizeNavigationBarTransitionIfHideable {
    return YES;
}

#pragma mark - <UIViewControllerTransitioningDelegate>

- (id<UIViewControllerAnimatedTransitioning>)animationControllerForPresentedController:(UIViewController *)presented presentingController:(UIViewController *)presenting sourceController:(UIViewController *)source {
    QMUISheetRootControllerAnimator *animator = [[QMUISheetRootControllerAnimator alloc] init];
    animator.isPresenting = YES;
    animator.containerViewController = self;
    return animator;
}

- (id<UIViewControllerAnimatedTransitioning>)animationControllerForDismissedController:(UIViewController *)dismissed {
    QMUISheetRootControllerAnimator *animator = [[QMUISheetRootControllerAnimator alloc] init];
    animator.containerViewController = self;
    return animator;
}

- (id<UIViewControllerInteractiveTransitioning>)interactionControllerForDismissal:(id<UIViewControllerAnimatedTransitioning>)animator {
    return self.interactiveTransition;
}

@end


@interface QMUISheetPresentation ()

/// 对应 UINavigationController.rootViewController，也即承载浮层的全屏容器
@property(nonatomic, weak, nullable) QMUISheetRootContainerViewController *containerViewController;

/// 对应浮层内正在展示的实际界面
@property(nonatomic, weak, nullable) UIViewController *rootViewController;
@end

@implementation QMUISheetPresentation

- (instancetype)initWithContainerViewController:(QMUISheetRootContainerViewController *)containerViewController {
    if (self = [super init]) {
        _supportsSwipeToDismiss = YES;
        _supportsPullToDismiss = YES;
        _shouldShowNavigationBar = YES;
        _dimmingColor = QMUICMIActivated ? UIColorMask : [UIColor.blackColor colorWithAlphaComponent:.35];
        _cornerRadius = 10;
        
        self.containerViewController = containerViewController;
        self.rootViewController = self.containerViewController.rootViewController;
    }
    return self;
}

- (void)setModal:(BOOL)modal {
    _modal = modal;
    
    // 开启 modal 时关闭手势，业务可手动再打开
    if (modal) {
        self.supportsSwipeToDismiss = NO;
        self.supportsPullToDismiss = NO;
    }
}

- (void)setShouldShowNavigationBar:(BOOL)shouldShowNavigationBar {
    _shouldShowNavigationBar = shouldShowNavigationBar;
    self.containerViewController.navigationBar.hidden = !shouldShowNavigationBar;
    [self.containerViewController.view setNeedsLayout];
}

- (void)setCornerRadius:(CGFloat)cornerRadius {
    _cornerRadius = cornerRadius;
    self.containerViewController.containerView.layer.cornerRadius = cornerRadius;
}

@end

@implementation UIViewController (QMUISheetSupports)

- (BOOL)qmui_isPresentedInSheet {
    return [self.parentViewController isKindOfClass:QMUISheetRootContainerViewController.class];
}

static char kAssociatedObjectKey_QMUISheetPresentation;
- (QMUISheetPresentation *)qmui_sheetPresentation {
    QMUISheetPresentation *result = (QMUISheetPresentation *)objc_getAssociatedObject(self, &kAssociatedObjectKey_QMUISheetPresentation);
    if (!result) {
        result = [[QMUISheetPresentation alloc] initWithContainerViewController:nil];
        objc_setAssociatedObject(self, &kAssociatedObjectKey_QMUISheetPresentation, result, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    return result;
}

- (QMUISheetPresentationNavigationBar *)qmui_sheetPresentationNavigationBar {
    return self.qmui_sheetPresentation.containerViewController.navigationBar;
}

- (UIScreenEdgePanGestureRecognizer *)qmui_sheetPresentationSwipeGestureRecognizer {
    return self.qmui_sheetPresentation.containerViewController.edgePan;
}

- (UIPanGestureRecognizer *)qmui_sheetPresentationPullGestureRecognizer {
    return self.qmui_sheetPresentation.containerViewController.pullPan;
}

- (void)qmui_invalidateSheetPresentationLayout {
    if (self.qmui_sheetPresentation.containerViewController.viewLoaded) {
        [self.qmui_sheetPresentation.containerViewController.view setNeedsLayout];
        if (self.view.window) {
            [UIView animateWithDuration:.25 delay:0 options:QMUIViewAnimationOptionsCurveOut animations:^{
                [self.qmui_sheetPresentation.containerViewController.view layoutIfNeeded];
            } completion:nil];
        }
    }
}

@end

@implementation QMUINavigationController (QMUISheetSupports)

- (instancetype)qmui_initWithSheetRootViewController:(UIViewController *)rootViewController {
    QMUISheetRootContainerViewController *container = [[QMUISheetRootContainerViewController alloc] initWithRootViewController:rootViewController];
    rootViewController.qmui_sheetPresentation.containerViewController = container;
    rootViewController.qmui_sheetPresentation.rootViewController = rootViewController;
    
    __typeof(self)results = [self initWithRootViewController:container];
    results.modalPresentationStyle = UIModalPresentationCustom;
    results.transitioningDelegate = container;
    return results;
}

+ (void)qmuiss_hookViewControllerIfNeeded {
    // TODO: navigationItem 变化时更新 navigationBar
//    [QMUIHelper executeBlock:^{
//    } oncePerIdentifier:@"QMUISheetPresentation"];
}

@end
