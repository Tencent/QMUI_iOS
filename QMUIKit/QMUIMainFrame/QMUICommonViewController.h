/**
 * Tencent is pleased to support the open source community by making QMUI_iOS available.
 * Copyright (C) 2016-2020 THL A29 Limited, a Tencent company. All rights reserved.
 * Licensed under the MIT License (the "License"); you may not use this file except in compliance with the License. You may obtain a copy of the License at
 * http://opensource.org/licenses/MIT
 * Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.
 */

//
//  QMUICommonViewController.h
//  qmui
//
//  Created by QMUI Team on 14-6-22.
//

#import <UIKit/UIKit.h>
#import "QMUINavigationController.h"
#import "QMUIKeyboardManager.h"

NS_ASSUME_NONNULL_BEGIN

@class QMUINavigationTitleView;
@class QMUIEmptyView;


/**
 *  可作为项目内所有 `UIViewController` 的基类，提供的功能包括：
 *
 *  1. 自带顶部标题控件 `QMUINavigationTitleView`，支持loading、副标题、下拉菜单，设置标题依然使用系统的 `setTitle:` 方法
 *
 *  2. 自带空界面控件 `QMUIEmptyView`，支持显示loading、空文案、操作按钮
 *
 *  3. 统一约定的常用接口，例如初始化 subview、设置顶部 `navigationItem`、底部 `toolbarItem`、响应系统的动态字体大小变化、...，从而保证相同类型的代码集中到同一个方法内，避免多人交叉维护时代码分散难以查找
 *
 *  4. 配合 `QMUINavigationController` 使用时，可以得到 `willPopInNavigationControllerWithAnimated:`、`didPopInNavigationControllerWithAnimated:` 这两个时机
 *
 *  @see QMUINavigationTitleView
 *  @see QMUIEmptyView
 */
@interface QMUICommonViewController : UIViewController {
    QMUIEmptyView *_emptyView;
}

- (instancetype)initWithNibName:(nullable NSString *)nibNameOrNil bundle:(nullable NSBundle *)nibBundleOrNil NS_DESIGNATED_INITIALIZER;
- (nullable instancetype)initWithCoder:(NSCoder *)aDecoder NS_DESIGNATED_INITIALIZER;

/**
 *  初始化时调用的方法，会在两个 NS_DESIGNATED_INITIALIZER 方法中被调用，所以子类如果需要同时支持两个 NS_DESIGNATED_INITIALIZER 方法，则建议把初始化时要做的事情放到这个方法里。否则仅需重写要支持的那个 NS_DESIGNATED_INITIALIZER 方法即可。
 */
- (void)didInitialize NS_REQUIRES_SUPER;

/**
 *  QMUICommonViewController默认都会增加一个QMUINavigationTitleView的titleView，然后重写了setTitle来间接设置titleView的值。所以设置title的时候就跟系统的接口一样：self.title = xxx。
 *
 *  同时，QMUINavigationTitleView提供了更多的功能，具体可以参考QMUINavigationTitleView的文档。<br/>
 *  @see QMUINavigationTitleView
 */
@property(nullable, nonatomic, strong, readonly) QMUINavigationTitleView *titleView;

/**
 *  修改当前界面要支持的横竖屏方向，默认为 SupportedOrientationMask
 */
@property(nonatomic, assign) UIInterfaceOrientationMask supportedOrientationMask;

/**
 *  空列表控件，支持显示提示文字、loading、操作按钮，该属性懒加载
 */
@property(nullable, nonatomic, strong) QMUIEmptyView *emptyView;

/// 当前self.emptyView是否显示
@property(nonatomic, assign, readonly, getter = isEmptyViewShowing) BOOL emptyViewShowing;

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
- (void)showEmptyViewWithText:(nullable NSString *)text
                   detailText:(nullable NSString *)detailText
                  buttonTitle:(nullable NSString *)buttonTitle
                 buttonAction:(nullable SEL)action;

/**
 *  显示带image、text、detailText、button的emptyView
 */
- (void)showEmptyViewWithImage:(nullable UIImage *)image
                          text:(nullable NSString *)text
                    detailText:(nullable NSString *)detailText
                   buttonTitle:(nullable NSString *)buttonTitle
                  buttonAction:(nullable SEL)action;

/**
 *  显示带loading、image、text、detailText、button的emptyView
 */
- (void)showEmptyViewWithLoading:(BOOL)showLoading
                           image:(nullable UIImage *)image
                            text:(nullable NSString *)text
                      detailText:(nullable NSString *)detailText
                     buttonTitle:(nullable NSString *)buttonTitle
                    buttonAction:(nullable SEL)action;

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
 *  负责设置和更新navigationItem，包括title、leftBarButtonItem、rightBarButtonItem。viewWillAppear 里面会自动调用，业务也可以在需要的时候自行调用。目的在于分类代码，所有与navigationItem相关的代码都写在这里。在需要修改navigationItem的时候都统一调用这个接口。
 */
- (void)setupNavigationItems NS_REQUIRES_SUPER;

/**
 *  负责设置和更新toolbarItem。在viewWillAppear里面自动调用（因为toolbar是navigationController的，是每个界面公用的，所以必须在每个界面的viewWillAppear时更新，不能放在viewDidLoad里），允许手动调用。目的在于分类代码，所有与toolbarItem相关的代码都写在这里。在需要修改toolbarItem的时候都只调用这个接口。
 */
- (void)setupToolbarItems NS_REQUIRES_SUPER;

/**
 *  动态字体的回调函数。
 *
 *  交给子类重写，当系统字体发生变化的时候，会调用这个方法，一些font的设置或者reloadData可以放在里面
 *
 *  @param notification test
 */
- (void)contentSizeCategoryDidChanged:(NSNotification *)notification;

@end

@interface QMUICommonViewController (QMUINavigationController) <QMUINavigationControllerDelegate>

/**
 从 QMUINavigationControllerAppearanceDelegate 系列接口获取当前界面希望的导航栏样式并设置到导航栏上
 */
- (void)updateNavigationBarAppearance;

@end

/**
 *  为了方便实现“点击空白区域降下键盘”的需求，QMUICommonViewController 内部集成一个 tap 手势对象并添加到 self.view 上，而业务只需要通过重写 -shouldHideKeyboardWhenTouchInView: 方法并根据当前被点击的 view 返回一个 BOOL 来控制键盘的显隐即可。
 *  @note 为了避免不必要的事件拦截，集成的手势 hideKeyboardTapGestureRecognizer：
 *  1. 默认的 enabled = NO。
 *  2. 如果当前 viewController 或其父类（非 QMUICommonViewController 那个层级的父类）没重写 -shouldHideKeyboardWhenTouchInView:，则永远 enabled = NO。
 *  3. 在键盘升起时，并且当前 viewController 重写了 -shouldHideKeyboardWhenTouchInView: 且处于可视状态下，此时手势的 enabled 才会被修改为 YES，并且在键盘消失时置为 NO。
 */
@interface QMUICommonViewController (QMUIKeyboard)

/// 在 viewDidLoad 内初始化，并且 gestureRecognizerShouldBegin: 必定返回 NO。
@property(nullable, nonatomic, strong, readonly) UITapGestureRecognizer *hideKeyboardTapGestureRecognizer;
@property(nullable, nonatomic, strong, readonly) QMUIKeyboardManager *hideKeyboardManager;

/**
 *  当用户点击界面上某个 view 时，如果此时键盘处于升起状态，则可通过重写这个方法并返回一个 YES 来达到“点击空白区域自动降下键盘”的需求。默认返回 NO，也即不处理键盘。
 *  @warning 注意如果被点击的 view 本身消耗了事件（iOS 11 下测试得到这种类型的所有系统的 view 仅有 UIButton 和 UISwitch），则这个方法并不会被触发。
 *  @warning 有可能参数传进去的 view 是某个 subview 的 subview，所以建议用 isDescendantOfView: 来判断是否点到了某个目标 subview
 */
- (BOOL)shouldHideKeyboardWhenTouchInView:(nullable UIView *)view;

@end

NS_ASSUME_NONNULL_END
