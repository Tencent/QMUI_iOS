//
//  QMUICommonViewController.m
//  qmui
//
//  Created by QQMail on 14-6-22.
//  Copyright (c) 2014年 QMUI Team. All rights reserved.
//

#import "QMUICommonViewController.h"
#import "QMUICommonDefines.h"
#import "QMUIConfiguration.h"
#import "QMUIHelper.h"
#import "QMUINavigationTitleView.h"
#import "QMUIEmptyView.h"
#import "NSString+QMUI.h"

@interface QMUICommonViewController ()

@property(nonatomic,strong,readwrite) QMUINavigationTitleView *titleView;
@end

@implementation QMUICommonViewController

#pragma mark - 生命周期

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
    self.titleView = [[QMUINavigationTitleView alloc] init];
    
    self.hidesBottomBarWhenPushed = HidesBottomBarWhenPushedInitially;
    
    // 不管navigationBar的backgroundImage如何设置，都让布局撑到屏幕顶部，方便布局的统一
    self.extendedLayoutIncludesOpaqueBars = YES;
    
    self.supportedOrientationMask = SupportedOrientationMask;
    
    // 动态字体notification
    if (IS_RESPOND_DYNAMICTYPE) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(contentSizeCategoryDidChanged:) name:UIContentSizeCategoryDidChangeNotification object:nil];
    }
}

- (void)setTitle:(NSString *)title {
    [super setTitle:title];
    self.titleView.title = title;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = UIColorForBackground;
    [self initSubviews];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    [self layoutEmptyView];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self setNavigationItemsIsInEditMode:NO animated:NO];
    [self setToolbarItemsIsInEditMode:NO animated:NO];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


#pragma mark - 空列表视图 QMUIEmptyView

- (void)showEmptyView {
    if (!self.emptyView) {
        self.emptyView = [[QMUIEmptyView alloc] initWithFrame:self.view.bounds];
    }
    [self.view addSubview:self.emptyView];
}

- (void)hideEmptyView {
    [self.emptyView removeFromSuperview];
}

- (BOOL)isEmptyViewShowing {
    return self.emptyView && self.emptyView.superview;
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
    if (self.emptyView) {
        // 由于为self.emptyView设置frame时会调用到self.view，为了避免导致viewDidLoad提前触发，这里需要判断一下self.view是否已经被初始化
        BOOL viewDidLoad = self.emptyView.superview || [self isViewLoaded];
        if (viewDidLoad) {
            CGSize newEmptyViewSize = self.emptyView.superview.bounds.size;
            CGSize oldEmptyViewSize = self.emptyView.frame.size;
            if (!CGSizeEqualToSize(newEmptyViewSize, oldEmptyViewSize)) {
                self.emptyView.frame = CGRectMake(CGRectGetMinX(self.emptyView.frame), CGRectGetMinY(self.emptyView.frame), newEmptyViewSize.width, newEmptyViewSize.height);
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


@implementation QMUICommonViewController (QMUINavigationController)

- (void)willPopViewController {
    // 子类按需实现
}

- (void)didPopViewController {
    // 子类按需实现
}

#pragma mark - <QMUINavigationControllerDelegate>

- (BOOL)shouldSetStatusBarStyleLight {
    return StatusbarStyleLightInitially;
}

@end


@implementation QMUICommonViewController (QMUISubclassingHooks)

- (void)initSubviews {
    // 子类重写
}

- (void)setNavigationItemsIsInEditMode:(BOOL)isInEditMode animated:(BOOL)animated {
    // 子类重写
    if (IOS_VERSION < 8.0 && [NSStringFromClass(self.navigationItem.class) qmui_includesString:@"UISearchBarNavigationItem"]) {
        // iOS 7 下，UISearchDisplayController.displaysSearchBarInNavigationBar 为 YES 时，不允许修改 self.navigationItem
    } else {
        self.navigationItem.titleView = self.titleView;
    }
}

- (void)setToolbarItemsIsInEditMode:(BOOL)isInEditMode animated:(BOOL)animated {
    // 子类重写
}

- (void)contentSizeCategoryDidChanged:(NSNotification *)notification {
    // 子类重写
    [self setUIAfterContentSizeCategoryChanged];
}

- (void)setUIAfterContentSizeCategoryChanged {
    // 子类重写
}

@end
