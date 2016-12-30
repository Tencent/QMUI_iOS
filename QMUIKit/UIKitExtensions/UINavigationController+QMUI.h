//
//  UINavigationController+QMUI.h
//  qmui
//
//  Created by QQMail on 16/1/12.
//  Copyright © 2016年 QMUI Team. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface UINavigationController (QMUI) <UIGestureRecognizerDelegate>

/**
 *  当前是否正在 push controller<br/>
 *  @warning 注意这个属性虽然是在分类里面定义的，但是它却是在QMUINavigationController里面赋值的，所以对于没有使用QMUINavigationController的情况，这个属性是不太安全的。
 */
@property(nonatomic, assign) BOOL qmui_isPushingViewController;

/// @warning 2016-07-18 这个属性不安全，暂时别用。在快速返回多个界面的时候，系统只会调用一次popViewControllerAnimated:，导致这个标志位错误。建议使用[self.navigationController.viewControllers containsObject:self]来区分是否在popping
@property(nonatomic, assign) BOOL qmui_isPoppingViewController;

/// 获取<b>rootViewController</b>
- (nullable UIViewController *)qmui_rootViewController;

@end


/**
 *  拦截系统默认返回按钮事件，有时候需要在点击系统返回按钮，或者手势返回的时候想要拦截事件，比如要判断当前界面编辑的的内容是否要保存，或者返回的时候需要做一些额外的逻辑处理等等。
 *
 */
@protocol UINavigationControllerBackButtonHandlerProtocol <NSObject>

@optional

/// 是否需要拦截系统返回按钮的事件，只有当这里返回YES的时候，才会询问方法：`canPopViewController`
- (BOOL)shouldHoldBackButtonEvent;

/// 是否可以`popViewController`，可以在这个返回里面做一些业务的判断，比如点击返回按钮的时候，如果输入框里面的文本没有满足条件的则可以弹alert并且返回NO
- (BOOL)canPopViewController;

/// 当自定义了`leftBarButtonItem`按钮之后，系统的手势返回就失效了。可以通过`forceEnableInteractivePopGestureRecognizer`来决定要不要把那个手势返回强制加回来
- (BOOL)forceEnableInteractivePopGestureRecognizer;

@end


/**
 *  @see UINavigationControllerBackButtonHandlerProtocol
 */
@interface UIViewController (BackBarButtonSupport) <UINavigationControllerBackButtonHandlerProtocol>

@end
