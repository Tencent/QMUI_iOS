//
//  QMUICommonViewController.h
//  qmui
//
//  Created by QQMail on 14-6-22.
//  Copyright (c) 2014年 QMUI Team. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "QMUINavigationController.h"

@class QMUINavigationTitleView;
@class QMUIEmptyView;


/**
 *  可作为项目内所有 `UIViewController` 的基类，提供的功能包括：
 *
 *  1. 自带顶部标题控件 `QMUINavigationTitleView`，支持loading、副标题、下拉菜单，设置标题依然使用系统的 `setTitle:` 方法
 *
 *  2. 自带空界面控件 `QMUIEmptyView`，支持显示loading、空文案、操作按钮
 *
 *  3. 自动在 `dealloc` 时移除所有注册到 `NSNotificationCenter` 里的监听，避免野指针 crash
 *
 *  4. 统一约定的常用接口，例如初始化 subview、设置顶部 `navigationItem`、底部 `toolbarItem`、响应系统的动态字体大小变化、...，从而保证相同类型的代码集中到同一个方法内，避免多人交叉维护时代码分散难以查找
 *
 *  5. 配合 `QMUINavigationController` 使用时，可以得到 `willPopViewController`、`didPopViewController` 这两个时机
 *
 *  @see QMUINavigationTitleView
 *  @see QMUIEmptyView
 */
@interface QMUICommonViewController : UIViewController

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil NS_DESIGNATED_INITIALIZER;
- (instancetype)initWithCoder:(NSCoder *)aDecoder NS_DESIGNATED_INITIALIZER;

/**
 *  初始化时调用的方法，会在两个 NS_DESIGNATED_INITIALIZER 方法中被调用，所以子类如果需要同时支持两个 NS_DESIGNATED_INITIALIZER 方法，则建议把初始化时要做的事情放到这个方法里。否则仅需重写要支持的那个 NS_DESIGNATED_INITIALIZER 方法即可。
 */
- (void)didInitialized NS_REQUIRES_SUPER;

/**
 *  QMUICommonViewController默认都会增加一个QMUINavigationTitleView的titleView，然后重写了setTitle来间接设置titleView的值。所以设置title的时候就跟系统的接口一样：self.title = xxx。
 *
 *  同时，QMUINavigationTitleView提供了更多的功能，具体可以参考QMUINavigationTitleView的文档。<br/>
 *  @see QMUINavigationTitleView
 */
@property(nonatomic,strong,readonly) QMUINavigationTitleView *titleView;

/**
 *  修改当前界面要支持的横竖屏方向，默认为 SupportedOrientationMask
 */
@property(nonatomic, assign) UIInterfaceOrientationMask supportedOrientationMask;

/**
 *  空列表控件，支持显示提示文字、loading、操作按钮
 */
@property(nonatomic,strong) QMUIEmptyView *emptyView;

/// 当前self.emptyView是否显示
@property(nonatomic,assign,readonly,getter = isEmptyViewShowing) BOOL emptyViewShowing;

/**
 *  显示emptyView
 *  emptyView 的以下系列接口可以按需进行重写
 *
 *  @see QMUIEmptyView
 */
- (void)showEmptyView;

/**
 *  显示loading的emptyView
 */
- (void)showEmptyViewWithLoading;

/**
 *  显示带text、detailText、button的emptyView
 */
- (void)showEmptyViewWithText:(NSString *)text
                   detailText:(NSString *)detailText
                  buttonTitle:(NSString *)buttonTitle
                 buttonAction:(SEL)action;

/**
 *  显示带image、text、detailText、button的emptyView
 */
- (void)showEmptyViewWithImage:(UIImage *)image
                          text:(NSString *)text
                    detailText:(NSString *)detailText
                   buttonTitle:(NSString *)buttonTitle
                  buttonAction:(SEL)action;

/**
 *  显示带loading、image、text、detailText、button的emptyView
 */
- (void)showEmptyViewWithLoading:(BOOL)showLoading
                           image:(UIImage *)image
                            text:(NSString *)text
                      detailText:(NSString *)detailText
                     buttonTitle:(NSString *)buttonTitle
                    buttonAction:(SEL)action;

/**
 *  隐藏emptyView
 */
- (void)hideEmptyView;

/**
 *  布局emptyView，如果emptyView没有被初始化或者没被添加到界面上，则直接忽略掉。
 *
 *  如果有特殊的情况，子类可以重写，实现自己的样式
 *
 *  @return YES表示成功进行一次布局，NO表示本次调用并没有进行布局操作（例如emptyView还没被初始化）
 */
- (BOOL)layoutEmptyView;

@end


@interface QMUICommonViewController (QMUISubclassingHooks)

/**
 *  负责初始化和设置controller里面的view，也就是self.view的subView。目的在于分类代码，所以与view初始化的相关代码都写在这里。
 *
 *  @warning initSubviews只负责subviews的init，不负责布局。布局相关的代码应该写在 <b>viewDidLayoutSubviews</b>
 */
- (void)initSubviews NS_REQUIRES_SUPER;

/**
 *  负责设置和更新navigationItem，包括title、leftBarButtonItem、rightBarButtonItem。viewDidLoad里面会自动调用，允许手动调用更新。目的在于分类代码，所有与navigationItem相关的代码都写在这里。在需要修改navigationItem的时候都只调用这个接口。
 *
 *  @param isInEditMode 是否用于编辑模式下
 *  @param animated     是否使用动画呈现
 */
- (void)setNavigationItemsIsInEditMode:(BOOL)isInEditMode animated:(BOOL)animated NS_REQUIRES_SUPER;

/**
 *  负责设置和更新toolbarItem。在viewWillAppear里面自动调用（因为toolbar是navigationController的，是每个界面公用的，所以必须在每个界面的viewWillAppear时更新，不能放在viewDidLoad里），允许手动调用。目的在于分类代码，所有与toolbarItem相关的代码都写在这里。在需要修改toolbarItem的时候都只调用这个接口。
 *
 *  @param isInEditMode 是否用于编辑模式下
 *  @param animated     是否使用动画呈现
 */
- (void)setToolbarItemsIsInEditMode:(BOOL)isInEditMode animated:(BOOL)animated NS_REQUIRES_SUPER;

/**
 *  动态字体的回调函数。
 *
 *  交给子类重写，当系统字体发生变化的时候，会调用这个方法，一些font的设置或者reloadData可以放在里面
 *
 *  @param notification test
 */
- (void)contentSizeCategoryDidChanged:(NSNotification *)notification;

/**
 *  动态字体的回调函数。
 *
 *  交给子类重写。这个方法是在contentSizeCategoryDidChanged:里面被调用的，主要用来设置写在controller里面的view的font
 */
- (void)setUIAfterContentSizeCategoryChanged;

@end


@interface QMUICommonViewController (QMUINavigationController) <QMUINavigationControllerDelegate>

/**
 *  在self.navigationController popViewControllerAnimated:内被调用，此时尚未被pop。一些自身被pop的时候需要做的事情可以写在这里。
 *
 *  在ARC环境下，viewController可能被放在autorelease池中，因此viewController被pop后不一定立即被销毁，所以一些对实时性要求很高的内存管理逻辑可以写在这里（而不是写在dealloc内）
 *
 *  @warning 不要尝试将willPopViewController视为点击返回按钮的回调，因为导致viewController被pop的情况不止点击返回按钮这一途径。系统的返回按钮是无法添加回调的，只能使用自定义的返回按钮。
 */
- (void)willPopViewController;

/** 在self.navigationController popViewControllerAnimated:内被调用，此时self已经不在viewControllers数组内 */
- (void)didPopViewController;

@end
