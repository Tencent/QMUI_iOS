//
//  UIViewController+QMUI.h
//  qmui
//
//  Created by QQMail on 16/1/12.
//  Copyright © 2016年 QMUI Team. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIViewController (QMUI)

/** 获取和自身处于同一个UINavigationController里的上一个UIViewController */
@property(nonatomic, weak, readonly) UIViewController *qmui_previousViewController;

/** 获取上一个UIViewController的title，可用于设置自定义返回按钮的文字 */
@property(nonatomic, copy, readonly) NSString *qmui_previousViewControllerTitle;

/**
 *  获取当前controller里的最高层可见viewController（可见的意思是还会判断self.view.window是否存在）
 *
 *  @see 如果要获取当前App里的可见viewController，请使用<i>[QMUIHelper visibleViewController]</i>
 *
 *  @return 当前controller里的最高层可见viewController
 */
- (UIViewController *)qmui_visibleViewControllerIfExist;

/** 当前controller是否被present，否则为push */
- (BOOL)qmui_isTransitioningTypePresented;

/** 是否响应 QMUINavigationControllerDelegate */
- (BOOL)qmui_respondQMUINavigationControllerDelegate;

/**
 *  是否应该响应一些UI相关的通知，例如 UIKeyboardNotification、UIMenuControllerNotification等，因为有可能当前界面已经被切走了（push到其他界面），但仍可能收到通知，所以在响应通知之前都应该做一下这个判断
 */
- (BOOL)qmui_isViewLoadedAndVisible;

@end

@interface UIViewController (Runtime)

/**
 *  判断当前类是否有重写某个指定的 UIViewController 的方法
 *  @param selector 要判断的方法
 *  @return YES 表示当前类重写了指定的方法，NO 表示没有重写，使用的是 UIViewController 默认的实现
 */
- (BOOL)qmui_hasOverrideUIKitMethod:(SEL)selector;
@end
