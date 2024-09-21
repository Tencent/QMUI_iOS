/**
 * Tencent is pleased to support the open source community by making QMUI_iOS available.
 * Copyright (C) 2016-2021 THL A29 Limited, a Tencent company. All rights reserved.
 * Licensed under the MIT License (the "License"); you may not use this file except in compliance with the License. You may obtain a copy of the License at
 * http://opensource.org/licenses/MIT
 * Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.
 */

//
//  QMUISearchController.m
//  Test
//
//  Created by QMUI Team on 16/5/25.
//

#import "QMUISearchController.h"
#import "QMUICore.h"
#import "QMUISearchBar.h"
#import "QMUICommonTableViewController.h"
#import "QMUIEmptyView.h"
#import "UISearchBar+QMUI.h"
#import "UITableView+QMUI.h"
#import "NSString+QMUI.h"
#import "NSObject+QMUI.h"
#import "UIView+QMUI.h"
#import "UIViewController+QMUI.h"
#import "UISearchController+QMUI.h"
#import "UIGestureRecognizer+QMUI.h"

BeginIgnoreDeprecatedWarning

@class QMUISearchResultsTableViewController;

@protocol QMUISearchResultsTableViewControllerDelegate <NSObject>

- (void)didLoadTableViewInSearchResultsTableViewController:(QMUISearchResultsTableViewController *)viewController;
@end

@interface QMUISearchResultsTableViewController : QMUICommonTableViewController

@property(nonatomic,weak) id<QMUISearchResultsTableViewControllerDelegate> delegate;
@end

@implementation QMUISearchResultsTableViewController

- (void)initTableView {
    [super initTableView];
    
    // UISearchController.searchBar 作为 UITableView.tableHeaderView 时，进入搜索状态，搜索结果列表顶部有一大片空白
    // 不要让系统自适应了，否则在搜索结果（navigationBar 隐藏）push 进入下一级界面（navigationBar 显示）过程中系统自动调整的 contentInset 会跳来跳去
    // https://github.com/Tencent/QMUI_iOS/issues/1473
    self.tableView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    
    self.tableView.keyboardDismissMode = UIScrollViewKeyboardDismissModeOnDrag;
    if ([self.delegate respondsToSelector:@selector(didLoadTableViewInSearchResultsTableViewController:)]) {
        [self.delegate didLoadTableViewInSearchResultsTableViewController:self];
    }
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    if ([self.delegate isKindOfClass:QMUISearchController.class]) {
        QMUISearchController *searchController = (QMUISearchController *)self.delegate;
        if (searchController.emptyViewShowing) {
            [searchController layoutEmptyView];
        }
    }
}

@end

@interface QMUISearchController () <QMUISearchResultsTableViewControllerDelegate, UIGestureRecognizerDelegate>
@property(nonatomic, strong) UIView *snapshotView;
@property(nonatomic, strong) UIView *snapshotMaskView;
@property(nonatomic, assign) BOOL dismissBySwipe;
@property(nonatomic, assign) BOOL hasSetShowsCancelButton;
@end

@implementation QMUISearchController

- (instancetype)initWithContentsViewController:(UIViewController *)viewController resultsViewController:(__kindof UIViewController *)resultsViewController {
    if (self = [super initWithNibName:nil bundle:nil]) {
        // 将 definesPresentationContext 置为 YES 有两个作用：
        // 1、保证从搜索结果界面进入子界面后，顶部的searchBar不会依然停留在navigationBar上
        // 2、使搜索结果界面的tableView的contentInset.top正确适配searchBar
        viewController.definesPresentationContext = YES;
        [QMUISearchController fixDefinesPresentationContextBug];
        
        _searchController = [[UISearchController alloc] initWithSearchResultsController:resultsViewController];
        self.searchController.obscuresBackgroundDuringPresentation = YES;// iOS 15 开始该默认值为 NO 了，为了保持与旧版本一致的表现，这里改默认值
        self.searchController.searchResultsUpdater = self;
        self.searchController.delegate = self;
        _searchBar = self.searchController.searchBar;
        if (CGRectIsEmpty(self.searchBar.frame)) {
            // iOS8 下 searchBar.frame 默认是 CGRectZero，不 sizeToFit 就看不到了
            [self.searchBar sizeToFit];
        }
        [self.searchBar qmui_styledAsQMUISearchBar];
        
        self.hidesNavigationBarDuringPresentation = YES;
    }
    return self;
}

- (instancetype)initWithContentsViewController:(UIViewController *)viewController resultsTableViewStyle:(UITableViewStyle)resultsTableViewStyle {
    QMUISearchResultsTableViewController *searchResultsViewController = [[QMUISearchResultsTableViewController alloc] initWithStyle:resultsTableViewStyle];
    if (self = [self initWithContentsViewController:viewController resultsViewController:searchResultsViewController]) {
        searchResultsViewController.delegate = self;
    }
    return self;
}

- (instancetype)initWithContentsViewController:(UIViewController *)viewController {
    return [self initWithContentsViewController:viewController resultsTableViewStyle:UITableViewStylePlain];
}

+ (void)fixDefinesPresentationContextBug {
    [QMUIHelper executeBlock:^{
        // 修复当处于搜索状态时被 -[UINavigationController popToRootViewControllerAnimated:] 强制切走界面可能引发内存泄露的问题
        // https://github.com/Tencent/QMUI_iOS/issues/1541
        OverrideImplementation([UIViewController class], @selector(didMoveToParentViewController:), ^id(__unsafe_unretained Class originClass, SEL originCMD, IMP (^originalIMPProvider)(void)) {
            return ^(UIViewController *selfObject, UIViewController *parentViewController) {
                
                // call super
                void (*originSelectorIMP)(id, SEL, UIViewController *);
                originSelectorIMP = (void (*)(id, SEL, UIViewController *))originalIMPProvider();
                originSelectorIMP(selfObject, originCMD, parentViewController);
                
                if (!parentViewController) {
                    if (selfObject.definesPresentationContext && selfObject.presentedViewController.presentingViewController == selfObject && [selfObject.presentedViewController isKindOfClass:UISearchController.class]) {
                        QMUILogWarn(@"QMUISearchController", @"fix #1541, didMoveToParent, %@", selfObject);
                        [selfObject dismissViewControllerAnimated:NO completion:nil];
                    }
                }
            };
        });
    } oncePerIdentifier:@"QMUISearchController presentation"];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // 主动触发 loadView，如果不这么做，那么有可能直到 QMUISearchController 被销毁，这期间 self.searchController 都没有被触发 loadView，然后在 dealloc 时就会报错，提示尝试在释放 self.searchController 时触发了 self.searchController 的 loadView
    [self.searchController loadViewIfNeeded];
}

- (void)setSearchResultsDelegate:(id<QMUISearchControllerDelegate>)searchResultsDelegate {
    _searchResultsDelegate = searchResultsDelegate;
    self.tableView.dataSource = _searchResultsDelegate;
    self.tableView.delegate = _searchResultsDelegate;
}

- (void)setDimmingColor:(UIColor *)dimmingColor {
    _dimmingColor = dimmingColor;
    self.searchController.qmui_dimmingColor = dimmingColor;
}

- (BOOL)isActive {
    return self.searchController.active;
}

- (void)setActive:(BOOL)active {
    [self setActive:active animated:NO];
}

- (void)setActive:(BOOL)active animated:(BOOL)animated {
    if (!animated) {
        [UIView performWithoutAnimation:^{
            self.searchController.active = active;
            // animated:NO 的情况下设置 active:NO，取消按钮无法自动消失（系统 bug），所以这里手动管理
            // 如果是 animated:YES 或者 active:YES 则没这个问题
            // 这里修改了 searchBar.showsCancelButton 属性会让 automaticallyShowsCancelButton 变为 NO，且不能在这时候立马把它改为 YES，否则会立马出现取消按钮，所以改为在下一次 willPresentSearchController: 里重置为系统自动管理。
            if (!active && self.searchController.automaticallyShowsCancelButton) {
                self.searchController.searchBar.showsCancelButton = NO;
                self.hasSetShowsCancelButton = YES;
            }
        }];
    } else {
        self.searchController.active = active;
    }
}

- (UITableView *)tableView {
    if ([self.searchResultsController respondsToSelector:@selector(tableView)]) {
        BeginIgnorePerformSelectorLeaksWarning
        return [self.searchResultsController performSelector:@selector(tableView)];
        EndIgnorePerformSelectorLeaksWarning
    }
    return nil;
}

- (__kindof UIViewController *)searchResultsController {
    return self.searchController.searchResultsController;
}

- (void)setLaunchView:(UIView *)launchView {
    _launchView = launchView;
    self.searchController.qmui_launchView = launchView;
}

- (BOOL)hidesNavigationBarDuringPresentation {
    return self.searchController.hidesNavigationBarDuringPresentation;
}

- (void)setHidesNavigationBarDuringPresentation:(BOOL)hidesNavigationBarDuringPresentation {
    self.searchController.hidesNavigationBarDuringPresentation = hidesNavigationBarDuringPresentation;
}

- (void)setQmui_prefersStatusBarHiddenBlock:(BOOL (^)(void))qmui_prefersStatusBarHiddenBlock {
    [super setQmui_prefersStatusBarHiddenBlock:qmui_prefersStatusBarHiddenBlock];
    self.searchController.qmui_prefersStatusBarHiddenBlock = qmui_prefersStatusBarHiddenBlock;
}

- (void)setQmui_preferredStatusBarStyleBlock:(UIStatusBarStyle (^)(void))qmui_preferredStatusBarStyleBlock {
    [super setQmui_preferredStatusBarStyleBlock:qmui_preferredStatusBarStyleBlock];
    self.searchController.qmui_preferredStatusBarStyleBlock = qmui_preferredStatusBarStyleBlock;
}

- (void)handleSwipe:(UIScreenEdgePanGestureRecognizer *)gestureRecognizer {
    if (!self.launchView && (!self.searchController.searchResultsController.viewLoaded || self.searchController.searchResultsController.view.hidden)) return;
    CGFloat snapshotInitialX = -112;
    switch (gestureRecognizer.state) {
        case UIGestureRecognizerStatePossible:
            return;
        case UIGestureRecognizerStateBegan: {
            [self.searchController.view endEditing:YES];
            [self.searchController.view.superview insertSubview:self.snapshotView belowSubview:self.searchController.view];
            self.snapshotView.transform = CGAffineTransformMakeTranslation(snapshotInitialX, 0);
            self.snapshotMaskView.alpha = 1;
            QMUILogInfo(@"QMUISearchController", @"swipeGesture snapshot added to search view");
        }
            return;
        case UIGestureRecognizerStateChanged: {
            CGFloat transition = MIN(MAX(0, [gestureRecognizer translationInView:gestureRecognizer.view].x), CGRectGetWidth(self.searchController.view.superview.bounds));
            self.searchController.view.transform = CGAffineTransformMakeTranslation(transition, 0);
            double percent = transition / CGRectGetWidth(self.searchController.view.superview.bounds);
            self.snapshotView.transform = CGAffineTransformMakeTranslation(snapshotInitialX * (1 - percent), 0);
            self.snapshotMaskView.alpha = 1 - percent;
        }
            return;
        case UIGestureRecognizerStateEnded: {
            CGPoint velocity = [gestureRecognizer velocityInView:gestureRecognizer.view];
            if (CGRectGetMinX(self.searchController.view.frame) > CGRectGetWidth(self.searchController.view.superview.bounds) / 4 && velocity.x > 0) {
                NSTimeInterval duration = 0.2 * (CGRectGetWidth(self.searchController.view.superview.bounds) - CGRectGetMinX(self.searchController.view.frame)) / CGRectGetWidth(self.searchController.view.superview.bounds);
                [UIApplication.sharedApplication beginIgnoringInteractionEvents];
                [UIView animateWithDuration:duration delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
                    self.searchController.view.transform = CGAffineTransformMakeTranslation(CGRectGetWidth(self.searchController.view.superview.bounds), 0);
                    self.snapshotView.transform = CGAffineTransformIdentity;
                    self.snapshotMaskView.alpha = 0;
                } completion:^(BOOL finished) {
                    self.dismissBySwipe = YES;
                    // 盖到最上面，挡住退出搜索过程中可能出现的界面闪烁
                    [self.snapshotView removeFromSuperview];
                    [UIApplication.sharedApplication.delegate.window addSubview:self.snapshotView];
                    QMUILogInfo(@"QMUISearchController", @"swipeGesture snapshot change superview to window");
                    self.active = NO;
                    self.searchController.view.transform = CGAffineTransformIdentity;
                    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.15 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                        [self cleanSnapshotObjects];
                        self.dismissBySwipe = NO;
                        [UIApplication.sharedApplication endIgnoringInteractionEvents];
                    });
                }];
                return;
            }
        }
        default:
            break;
    }
    
    // reset to active:YES
    [UIApplication.sharedApplication beginIgnoringInteractionEvents];
    NSTimeInterval duration = 0.2 * CGRectGetMinX(self.searchController.view.frame) / CGRectGetWidth(self.searchController.view.superview.bounds);
    [UIView animateWithDuration:duration delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        self.searchController.view.transform = CGAffineTransformIdentity;
        self.snapshotView.transform = CGAffineTransformMakeTranslation(snapshotInitialX, 0);
        self.snapshotMaskView.alpha = 1;
    } completion:^(BOOL finished) {
        [UIApplication.sharedApplication endIgnoringInteractionEvents];
        QMUILogInfo(@"QMUISearchController", @"swipeGesture cancelled");
    }];
}

- (void)createSnapshotObjects {
    if (!self.snapshotMaskView) {
        self.snapshotMaskView = [[UIView alloc] init];
        self.snapshotMaskView.backgroundColor = [UIColor.blackColor colorWithAlphaComponent:.1];
    }
    self.snapshotView = [UIApplication.sharedApplication.delegate.window snapshotViewAfterScreenUpdates:NO];
    self.snapshotMaskView.frame = self.snapshotView.bounds;
    [self.snapshotView addSubview:self.snapshotMaskView];
    if (!self.swipeGestureRecognizer) {
        _swipeGestureRecognizer = [[UIScreenEdgePanGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipe:)];
        self.swipeGestureRecognizer.edges = UIRectEdgeLeft;
        self.swipeGestureRecognizer.delegate = self;
    }
    [UIApplication.sharedApplication.delegate.window addGestureRecognizer:self.swipeGestureRecognizer];
}

- (void)resetSnapshotObjects {
    self.snapshotView.transform = CGAffineTransformIdentity;
    [self.snapshotView removeFromSuperview];
}

- (void)cleanSnapshotObjects {
    [self.snapshotView removeFromSuperview];
    [self.snapshotMaskView removeFromSuperview];
    self.snapshotView = nil;
    [UIApplication.sharedApplication.delegate.window removeGestureRecognizer:self.swipeGestureRecognizer];
    QMUILogInfo(@"QMUISearchController", @"swipeGesture clean all objects");
}

#pragma mark - <UIGestureRecognizerDelegate>

// 由于手势是加在 window 上的，所以任何时候都可能被触发（比如在搜索结果里弹出 toast 或 present 到新的界面），所以这里要做保护，只有在搜索结果肉眼可见的情况下才响应手势
- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer {
    if (gestureRecognizer == self.swipeGestureRecognizer) {
        UIView *targetView = [gestureRecognizer qmui_targetView];
        if (![targetView isDescendantOfView:self.searchController.view]) {
            return NO;
        }
    }
    return YES;
}

#pragma mark - QMUIEmptyView

- (void)showEmptyView {
    // 搜索框文字为空时，界面会显示遮罩，此时不需要显示emptyView了
    // 为什么加这个是因为当搜索框被点击时（进入搜索状态）会触发searchController:updateResultsForSearchString:，里面如果直接根据搜索结果为空来showEmptyView的话，就会导致在遮罩层上有emptyView出现，要么在那边showEmptyView之前判断一下searchBar.text.length，要么在showEmptyView里判断，为了方便，这里选择后者。
    if (self.searchBar.text.length <= 0) {
        return;
    }
    
    [super showEmptyView];
    
    // 格式化样式，以适应当前项目的需求
    self.emptyView.backgroundColor = TableViewBackgroundColor ?: UIColorWhite;
    if ([self.searchResultsDelegate respondsToSelector:@selector(searchController:willShowEmptyView:)]) {
        [self.searchResultsDelegate searchController:self willShowEmptyView:self.emptyView];
    }
    
    if (self.searchController) {
        UIView *superview = self.searchController.searchResultsController.view;
        [superview addSubview:self.emptyView];
    } else {
        QMUIAssert(NO, NSStringFromClass(self.class), @"QMUISearchController 无法为 emptyView 找到合适的 superview");
    }
    
    [self layoutEmptyView];
}

#pragma mark - <QMUISearchResultsTableViewControllerDelegate>

- (void)didLoadTableViewInSearchResultsTableViewController:(QMUISearchResultsTableViewController *)viewController {
    if ([self.searchResultsDelegate respondsToSelector:@selector(searchController:didLoadSearchResultsTableView:)]) {
        [self.searchResultsDelegate searchController:self didLoadSearchResultsTableView:viewController.tableView];
    }
}

#pragma mark - <UISearchResultsUpdating>

- (void)updateSearchResultsForSearchController:(UISearchController *)searchController {
    // 先触发手势返回再取消，从而让截图添加到屏幕上。然后再点搜索框的×按钮清空列表，此时要保证背后的截图也一起去除
    NSString *text = searchController.searchBar.text;
    if (self.supportsSwipeToDismissSearch && !text.length && !searchController.qmui_alwaysShowSearchResultsController) {
        [self resetSnapshotObjects];
    }
    if ([self.searchResultsDelegate respondsToSelector:@selector(searchController:updateResultsForSearchString:)]) {
        [self.searchResultsDelegate searchController:self updateResultsForSearchString:searchController.searchBar.text];
    }
}

#pragma mark - <UISearchControllerDelegate>

- (void)willPresentSearchController:(UISearchController *)searchController {
    if (self.supportsSwipeToDismissSearch) {
        [self createSnapshotObjects];
        QMUILogInfo(@"QMUISearchController", @"swipeGesture added");
    }
    
    // 走到这里意味着曾经因为 setActive:NO animated:NO 而不得不手动修改 searchBar.showsCancelButton 属性，导致 automaticallyShowsCancelButton 为 NO，系统无法自动显示取消按钮，所以这里在进入搜索前恢复自动管理
    if (self.hasSetShowsCancelButton) {
        self.searchController.automaticallyShowsCancelButton = YES;
        self.hasSetShowsCancelButton = NO;
    }
    
    if (self.searchController.qmui_prefersStatusBarHiddenBlock || self.searchController.qmui_preferredStatusBarStyleBlock) {
        [self.searchController setNeedsStatusBarAppearanceUpdate];
    }
    if ([self.searchResultsDelegate respondsToSelector:@selector(willPresentSearchController:)]) {
        [self.searchResultsDelegate willPresentSearchController:self];
    }
}

- (void)didPresentSearchController:(UISearchController *)searchController {
    if ([self.searchResultsDelegate respondsToSelector:@selector(didPresentSearchController:)]) {
        [self.searchResultsDelegate didPresentSearchController:self];
    }
}

- (void)willDismissSearchController:(UISearchController *)searchController {
    if (self.searchController.qmui_prefersStatusBarHiddenBlock || self.searchController.qmui_preferredStatusBarStyleBlock) {
        [self.searchController setNeedsStatusBarAppearanceUpdate];
    }
    if ([self.searchResultsDelegate respondsToSelector:@selector(willDismissSearchController:)]) {
        [self.searchResultsDelegate willDismissSearchController:self];
    }
    
    // 先手势返回触发各种对象的初始化，然后又取消手势，正常点取消按钮退出搜索，此时就不应该看到背后有截图存在了
    if (!self.dismissBySwipe) {
        [self cleanSnapshotObjects];
    }
}

- (void)didDismissSearchController:(UISearchController *)searchController {
    // 退出搜索必定先隐藏emptyView
    [self hideEmptyView];
    
    if ([self.searchResultsDelegate respondsToSelector:@selector(didDismissSearchController:)]) {
        [self.searchResultsDelegate didDismissSearchController:self];
    }
    
    if (self.supportsSwipeToDismissSearch && !self.dismissBySwipe) {
        [self cleanSnapshotObjects];
    }
}

@end

EndIgnoreDeprecatedWarning

@implementation QMUICommonTableViewController (Search)

QMUISynthesizeIdStrongProperty(searchController, setSearchController)
QMUISynthesizeIdStrongProperty(searchBar, setSearchBar)

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        ExtendImplementationOfVoidMethodWithoutArguments([QMUICommonTableViewController class], @selector(initSubviews), ^(QMUICommonTableViewController *selfObject) {
            [selfObject initSearchController];
        });
        
        ExtendImplementationOfVoidMethodWithSingleArgument([QMUICommonTableViewController class], @selector(viewWillAppear:), BOOL, ^(QMUICommonTableViewController *selfObject, BOOL firstArgv) {
            if (!selfObject.searchController.tableView.allowsMultipleSelection) {
                [selfObject.searchController.tableView qmui_clearsSelection];
            }
        });
        
        ExtendImplementationOfVoidMethodWithoutArguments([QMUICommonTableViewController class], @selector(showEmptyView), ^(QMUICommonTableViewController *selfObject) {
            if ([selfObject shouldHideSearchBarWhenEmptyViewShowing] && selfObject.tableView.tableHeaderView == selfObject.searchBar) {
                selfObject.tableView.tableHeaderView = nil;
            }
        });
        
        ExtendImplementationOfVoidMethodWithoutArguments([QMUICommonTableViewController class], @selector(hideEmptyView), ^(QMUICommonTableViewController *selfObject) {
            if (selfObject.shouldShowSearchBar && [selfObject shouldHideSearchBarWhenEmptyViewShowing] && selfObject.tableView.tableHeaderView == nil) {
                [selfObject initSearchController];
                // 隐藏 emptyView 后重新设置 tableHeaderView，会导致原先 shouldHideTableHeaderViewInitial 隐藏头部的操作被重置，所以下面的 force 参数要传 YES
                // https://github.com/Tencent/QMUI_iOS/issues/128
                selfObject.tableView.tableHeaderView = selfObject.searchBar;
                [selfObject hideTableHeaderViewInitialIfCanWithAnimated:NO force:YES];
            }
        });
    });
}

static char kAssociatedObjectKey_shouldShowSearchBar;
- (void)setShouldShowSearchBar:(BOOL)shouldShowSearchBar {
    BOOL isValueChanged = self.shouldShowSearchBar != shouldShowSearchBar;
    if (!isValueChanged) {
        return;
    }
    
    objc_setAssociatedObject(self, &kAssociatedObjectKey_shouldShowSearchBar, @(shouldShowSearchBar), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    
    if (shouldShowSearchBar) {
        [self initSearchController];
    } else {
        if (self.searchBar) {
            if (self.tableView.tableHeaderView == self.searchBar) {
                self.tableView.tableHeaderView = nil;
            }
            [self.searchBar removeFromSuperview];
            self.searchBar = nil;
        }
        if (self.searchController) {
            self.searchController.searchResultsDelegate = nil;
            self.searchController = nil;
        }
    }
}

- (BOOL)shouldShowSearchBar {
    return [((NSNumber *)objc_getAssociatedObject(self, &kAssociatedObjectKey_shouldShowSearchBar)) boolValue];
}

- (void)initSearchController {
    if ([self isViewLoaded] && self.shouldShowSearchBar && !self.searchController) {
        self.searchController = [[QMUISearchController alloc] initWithContentsViewController:self resultsTableViewStyle:self.tableView.style];
        self.searchController.searchResultsDelegate = self;
        self.searchController.searchBar.placeholder = @"搜索";
        self.searchController.searchBar.qmui_usedAsTableHeaderView = YES;// 以 tableHeaderView 的方式使用 searchBar 的话，将其置为 YES，以辅助兼容一些系统 bug
        self.tableView.tableHeaderView = self.searchController.searchBar;
        self.searchBar = self.searchController.searchBar;
    }
}

- (BOOL)shouldHideSearchBarWhenEmptyViewShowing {
    return NO;
}

#pragma mark - <QMUISearchControllerDelegate>

- (void)searchController:(QMUISearchController *)searchController updateResultsForSearchString:(NSString *)searchString {
    
}

@end

@implementation UINavigationController (Search)

// 修复当处于搜索状态时被 window.rootViewController = xxx 强制切走界面可能引发内存泄露的问题
// 这种场景会调用 nav 的 dealloc 但不会触发 child 的 didMoveToParentViewController:，所以只能重写 dealloc 处理一遍
// https://github.com/Tencent/QMUI_iOS/issues/1541
- (void)dealloc {
    [self.childViewControllers.copy enumerateObjectsUsingBlock:^(__kindof UIViewController * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (obj.definesPresentationContext && obj.presentedViewController.presentingViewController == obj && [obj.presentedViewController isKindOfClass:UISearchController.class]) {
            QMUILogWarn(@"QMUISearchController", @"fix #1541, dealloc, %@", obj);
            [obj dismissViewControllerAnimated:NO completion:nil];
        }
    }];
}

@end
