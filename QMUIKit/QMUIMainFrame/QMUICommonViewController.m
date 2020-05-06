/**
 * Tencent is pleased to support the open source community by making QMUI_iOS available.
 * Copyright (C) 2016-2020 THL A29 Limited, a Tencent company. All rights reserved.
 * Licensed under the MIT License (the "License"); you may not use this file except in compliance with the License. You may obtain a copy of the License at
 * http://opensource.org/licenses/MIT
 * Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.
 */

//
//  QMUICommonViewController.m
//  qmui
//
//  Created by QMUI Team on 14-6-22.
//

#import "QMUICommonViewController.h"
#import "QMUICore.h"
#import "QMUINavigationTitleView.h"
#import "QMUIEmptyView.h"
#import "NSString+QMUI.h"
#import "NSObject+QMUI.h"
#import "UIViewController+QMUI.h"
#import "UIGestureRecognizer+QMUI.h"
#import "UIView+QMUI.h"

@interface QMUIViewControllerHideKeyboardDelegateObject : NSObject <UIGestureRecognizerDelegate, QMUIKeyboardManagerDelegate>

@property(nonatomic, weak) QMUICommonViewController *viewController;

- (instancetype)initWithViewController:(QMUICommonViewController *)viewController;
@end

@interface QMUICommonViewController () {
    UITapGestureRecognizer *_hideKeyboardTapGestureRecognizer;
    QMUIKeyboardManager *_hideKeyboardManager;
    QMUIViewControllerHideKeyboardDelegateObject *_hideKeyboadDelegateObject;
}

@property(nonatomic,strong,readwrite) QMUINavigationTitleView *titleView;
@end

@implementation QMUICommonViewController

#pragma mark - 生命周期

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        [self didInitialize];
    }
    return self;
}

- (nullable instancetype)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
        [self didInitialize];
    }
    return self;
}

- (void)didInitialize {
    self.titleView = [[QMUINavigationTitleView alloc] init];
    self.titleView.title = self.title;// 从 storyboard 初始化的话，可能带有 self.title 的值
    self.navigationItem.titleView = self.titleView;
    
    // 不管navigationBar的backgroundImage如何设置，都让布局撑到屏幕顶部，方便布局的统一
    self.extendedLayoutIncludesOpaqueBars = YES;
    
    self.supportedOrientationMask = SupportedOrientationMask;
    
    if (QMUICMIActivated) {
        self.hidesBottomBarWhenPushed = HidesBottomBarWhenPushedInitially;
        self.qmui_preferredStatusBarStyleBlock = ^UIStatusBarStyle{
            return StatusbarStyleLightInitially ? UIStatusBarStyleLightContent : UIStatusBarStyleDefault;
        };
    }
    
    if (@available(iOS 11.0, *)) {
        self.qmui_prefersHomeIndicatorAutoHiddenBlock = ^BOOL{
            return NO;
        };
    }

    
    // 动态字体notification
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(contentSizeCategoryDidChanged:) name:UIContentSizeCategoryDidChangeNotification object:nil];
}

- (void)setTitle:(NSString *)title {
    [super setTitle:title];
    self.titleView.title = title;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    if (!self.view.backgroundColor) {
        UIColor *backgroundColor = UIColorForBackground;
        if (backgroundColor) {
            self.view.backgroundColor = backgroundColor;
        }
    }
    
    // 点击空白区域降下键盘 QMUICommonViewController (QMUIKeyboard)
    // 如果子类重写了才初始化这些对象（即便子类 return NO）
    BOOL shouldEnabledKeyboardObject = [self qmui_hasOverrideMethod:@selector(shouldHideKeyboardWhenTouchInView:) ofSuperclass:[QMUICommonViewController class]];
    if (shouldEnabledKeyboardObject) {
        _hideKeyboadDelegateObject = [[QMUIViewControllerHideKeyboardDelegateObject alloc] initWithViewController:self];
        
        _hideKeyboardTapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:nil action:NULL];
        self.hideKeyboardTapGestureRecognizer.delegate = _hideKeyboadDelegateObject;
        self.hideKeyboardTapGestureRecognizer.enabled = NO;
        [self.view addGestureRecognizer:self.hideKeyboardTapGestureRecognizer];
        
        _hideKeyboardManager = [[QMUIKeyboardManager alloc] initWithDelegate:_hideKeyboadDelegateObject];
    }
    
    [self initSubviews];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    // fix iOS 11 and later, shouldHideKeyboardWhenTouchInView: will not work when calling becomeFirstResponder in UINavigationController.rootViewController.viewDidLoad
    // https://github.com/Tencent/QMUI_iOS/issues/495
    if (@available(iOS 11.0, *)) {
        if (self.hideKeyboardManager && [QMUIKeyboardManager isKeyboardVisible]) {
            self.hideKeyboardTapGestureRecognizer.enabled = YES;
        }
    }
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    [self layoutEmptyView];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self setupNavigationItems];
    [self setupToolbarItems];
}

#pragma mark - 空列表视图 QMUIEmptyView

@synthesize emptyView = _emptyView;

- (QMUIEmptyView *)emptyView {
    if (!_emptyView && self.isViewLoaded) {
        _emptyView = [[QMUIEmptyView alloc] initWithFrame:self.view.bounds];
    }
    return _emptyView;
}

- (void)showEmptyView {
    [self.view addSubview:self.emptyView];
}

- (void)hideEmptyView {
    [_emptyView removeFromSuperview];
}

- (BOOL)isEmptyViewShowing {
    return _emptyView && _emptyView.superview;
}

- (void)showEmptyViewWithLoading {
    [self showEmptyView];
    [self.emptyView setImage:nil];
    [self.emptyView setLoadingViewHidden:NO];
    [self.emptyView setTextLabelText:nil];
    [self.emptyView setDetailTextLabelText:nil];
    [self.emptyView setActionButtonTitle:nil];
}

- (void)showEmptyViewWithText:(NSString *)text
                   detailText:(NSString *)detailText
                  buttonTitle:(NSString *)buttonTitle
                 buttonAction:(SEL)action {
    [self showEmptyViewWithLoading:NO image:nil text:text detailText:detailText buttonTitle:buttonTitle buttonAction:action];
}

- (void)showEmptyViewWithImage:(UIImage *)image
                          text:(NSString *)text
                    detailText:(NSString *)detailText
                   buttonTitle:(NSString *)buttonTitle
                  buttonAction:(SEL)action {
    [self showEmptyViewWithLoading:NO image:image text:text detailText:detailText buttonTitle:buttonTitle buttonAction:action];
}

- (void)showEmptyViewWithLoading:(BOOL)showLoading
                           image:(UIImage *)image
                            text:(NSString *)text
                      detailText:(NSString *)detailText
                     buttonTitle:(NSString *)buttonTitle
                    buttonAction:(SEL)action {
    [self showEmptyView];
    [self.emptyView setLoadingViewHidden:!showLoading];
    [self.emptyView setImage:image];
    [self.emptyView setTextLabelText:text];
    [self.emptyView setDetailTextLabelText:detailText];
    [self.emptyView setActionButtonTitle:buttonTitle];
    [self.emptyView.actionButton removeTarget:nil action:NULL forControlEvents:UIControlEventAllEvents];
    [self.emptyView.actionButton addTarget:self action:action forControlEvents:UIControlEventTouchUpInside];
}

- (BOOL)layoutEmptyView {
    if (_emptyView) {
        // 由于为self.emptyView设置frame时会调用到self.view，为了避免导致viewDidLoad提前触发，这里需要判断一下self.view是否已经被初始化
        BOOL viewDidLoad = self.emptyView.superview && [self isViewLoaded];
        if (viewDidLoad) {
            CGSize newEmptyViewSize = self.emptyView.superview.bounds.size;
            CGSize oldEmptyViewSize = self.emptyView.frame.size;
            if (!CGSizeEqualToSize(newEmptyViewSize, oldEmptyViewSize)) {
                self.emptyView.qmui_frameApplyTransform = CGRectFlatMake(CGRectGetMinX(self.emptyView.frame), CGRectGetMinY(self.emptyView.frame), newEmptyViewSize.width, newEmptyViewSize.height);
            }
            return YES;
        }
    }
    
    return NO;
}

#pragma mark - 屏幕旋转

- (BOOL)shouldAutorotate {
    return YES;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return self.supportedOrientationMask;
}

@end

@implementation QMUICommonViewController (QMUISubclassingHooks)

- (void)initSubviews {
    // 子类重写
}

- (void)setupNavigationItems {
    // 子类重写
}

- (void)setupToolbarItems {
    // 子类重写
}

- (void)contentSizeCategoryDidChanged:(NSNotification *)notification {
    // 子类重写
}

@end

@implementation QMUICommonViewController (QMUINavigationController)

- (void)updateNavigationBarAppearance {
    
    UINavigationBar *navigationBar = self.navigationController.navigationBar;
    if (!navigationBar) return;
    
    if ([self respondsToSelector:@selector(navigationBarBackgroundImage)]) {
        [navigationBar setBackgroundImage:[self navigationBarBackgroundImage] forBarMetrics:UIBarMetricsDefault];
    }
    if ([self respondsToSelector:@selector(navigationBarBarTintColor)]) {
        navigationBar.barTintColor = [self navigationBarBarTintColor];
    }
    if ([self respondsToSelector:@selector(navigationBarStyle)]) {
        navigationBar.barStyle = [self navigationBarStyle];
    }
    if ([self respondsToSelector:@selector(navigationBarShadowImage)]) {
        navigationBar.shadowImage = [self navigationBarShadowImage];
    }
    if ([self respondsToSelector:@selector(navigationBarTintColor)]) {
        navigationBar.tintColor = [self navigationBarTintColor];
    }
    if ([self respondsToSelector:@selector(titleViewTintColor)]) {
        self.titleView.tintColor = [self titleViewTintColor];
    }
}

#pragma mark - <QMUINavigationControllerDelegate>

- (BOOL)preferredNavigationBarHidden {
    return NavigationBarHiddenInitially;
}

- (void)viewControllerKeepingAppearWhenSetViewControllersWithAnimated:(BOOL)animated {
    // 通常和 viewWillAppear: 里做的事情保持一致
    [self setupNavigationItems];
    [self setupToolbarItems];
}

@end

@implementation QMUICommonViewController (QMUIKeyboard)

- (UITapGestureRecognizer *)hideKeyboardTapGestureRecognizer {
    return _hideKeyboardTapGestureRecognizer;
}

- (QMUIKeyboardManager *)hideKeyboardManager {
    return _hideKeyboardManager;
}

- (BOOL)shouldHideKeyboardWhenTouchInView:(UIView *)view {
    // 子类重写，默认返回 NO，也即不主动干预键盘的状态
    return NO;
}

@end

@implementation QMUIViewControllerHideKeyboardDelegateObject

- (instancetype)initWithViewController:(QMUICommonViewController *)viewController {
    if (self = [super init]) {
        self.viewController = viewController;
    }
    return self;
}

#pragma mark - <UIGestureRecognizerDelegate>

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer {
    if (gestureRecognizer != self.viewController.hideKeyboardTapGestureRecognizer) {
        return YES;
    }
    
    if (![QMUIKeyboardManager isKeyboardVisible]) {
        return NO;
    }
    
    UIView *targetView = gestureRecognizer.qmui_targetView;
    
    // 点击了本身就是输入框的 view，就不要降下键盘了
    if ([targetView isKindOfClass:[UITextField class]] || [targetView isKindOfClass:[UITextView class]]) {
        return NO;
    }
    
    if ([self.viewController shouldHideKeyboardWhenTouchInView:targetView]) {
        [self.viewController.view endEditing:YES];
    }
    return NO;
}

#pragma mark - <QMUIKeyboardManagerDelegate>

- (void)keyboardWillShowWithUserInfo:(QMUIKeyboardUserInfo *)keyboardUserInfo {
    if (![self.viewController qmui_isViewLoadedAndVisible]) return;
    self.viewController.hideKeyboardTapGestureRecognizer.enabled = YES;
}

- (void)keyboardWillHideWithUserInfo:(QMUIKeyboardUserInfo *)keyboardUserInfo {
    self.viewController.hideKeyboardTapGestureRecognizer.enabled = NO;
}

@end
