//
//  QMUIDialogViewController.h
//  WeRead
//
//  Created by MoLice on 16/7/8.
//  Copyright © 2016年 QMUI Team. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "QMUICommonViewController.h"
#import "QMUIModalPresentationViewController.h"
#import "QMUITableView.h"

@class QMUIButton;
@class QMUITextField;
@class QMUITableViewCell;

/**
 * 弹窗组件基类，自带`headerView`、`contentView`、`footerView`，并通过`addCancelButtonWithText:block:`、`addSubmitButtonWithText:block:`方法来添加取消、确定按钮。
 * 建议将一个自定义的UIView设置给`contentView`属性，此时弹窗将会自动帮你计算大小并布局。大小取决于你的contentView的sizeThatFits:返回值。
 * 弹窗继承自`QMUICommonViewController`，因此可直接使用self.titleView的功能来实现双行标题，具体请查看`QMUINavigationTitleView`。
 * `QMUIDialogViewController`支持以类似`UIAppearance`的方式来统一设置全局的dialog样式，例如`[QMUIDialogViewController appearance].headerViewHeight = 48;`。
 *
 * @see QMUIDialogSelectionViewController
 * @see QMUIDialogTextFieldViewController
 */
@interface QMUIDialogViewController : QMUICommonViewController<QMUIModalPresentationContentViewControllerProtocol>

@property(nonatomic, assign) CGFloat        cornerRadius UI_APPEARANCE_SELECTOR;
@property(nonatomic, assign) UIEdgeInsets   contentViewMargins UI_APPEARANCE_SELECTOR;
@property(nonatomic, strong) UIColor        *titleTintColor UI_APPEARANCE_SELECTOR;
@property(nonatomic, strong) UIFont         *titleLabelFont UI_APPEARANCE_SELECTOR;
@property(nonatomic, strong) UIColor        *titleLabelTextColor UI_APPEARANCE_SELECTOR;
@property(nonatomic, strong) UIFont         *subTitleLabelFont UI_APPEARANCE_SELECTOR;
@property(nonatomic, strong) UIColor        *subTitleLabelTextColor UI_APPEARANCE_SELECTOR;
@property(nonatomic, strong) UIColor        *headerFooterSeparatorColor UI_APPEARANCE_SELECTOR;
@property(nonatomic, assign) CGFloat        headerViewHeight UI_APPEARANCE_SELECTOR;
@property(nonatomic, strong) UIColor        *headerViewBackgroundColor UI_APPEARANCE_SELECTOR;
@property(nonatomic, assign) CGFloat        footerViewHeight UI_APPEARANCE_SELECTOR;
@property(nonatomic, strong) UIColor        *footerViewBackgroundColor UI_APPEARANCE_SELECTOR;
@property(nonatomic, strong) NSDictionary<NSString *, id> *buttonTitleAttributes UI_APPEARANCE_SELECTOR;
@property(nonatomic, strong) UIColor        *buttonHighlightedBackgroundColor UI_APPEARANCE_SELECTOR;

@property(nonatomic, strong, readonly) UIView *headerView;
@property(nonatomic, strong, readonly) CALayer *headerViewSeparatorLayer;

/// dialog的主体内容部分，默认是一个空的白色UIView，建议设置为自己的UIView
/// dialog会通过询问contentView的sizeThatFits得到当前内容的大小
@property(nonatomic, strong) UIView *contentView;

@property(nonatomic, strong, readonly) UIView *footerView;
@property(nonatomic, strong, readonly) CALayer *footerViewSeparatorLayer;

@property(nonatomic, strong, readonly) QMUIButton *cancelButton;
@property(nonatomic, strong, readonly) QMUIButton *submitButton;
@property(nonatomic, strong, readonly) CALayer *buttonSeparatorLayer;

- (void)addCancelButtonWithText:(NSString *)buttonText block:(void (^)(QMUIDialogViewController *dialogViewController))block;
- (void)addSubmitButtonWithText:(NSString *)buttonText block:(void (^)(QMUIDialogViewController *dialogViewController))block;
- (void)show;
- (void)showWithAnimated:(BOOL)animated completion:(void (^)(BOOL finished))completion;
- (void)hide;
- (void)hideWithAnimated:(BOOL)animated completion:(void (^)(BOOL finished))completion;

@end

@interface QMUIDialogViewController (UIAppearance)

+ (instancetype)appearance;
@end

/// 表示没有选中的item
extern const NSInteger QMUIDialogSelectionViewControllerSelectedItemIndexNone;

/**
 *  支持列表选择的弹窗，通过 `items` 指定要展示的所有选项（暂时只支持`NSString`）。默认使用单选，可通过 `allowsMultipleSelection` 支持多选。
 *  单选模式下，通过 `selectedItemIndex` 可获取当前被选中的选项，也可在初始化完dialog后设置这个属性来达到默认值的效果。
 *  多选模式下，通过 `selectedItemIndexes` 可获取当前被选中的多个选项，可也在初始化完dialog后设置这个属性来达到默认值的效果。
 */
@interface QMUIDialogSelectionViewController : QMUIDialogViewController<QMUITableViewDelegate, QMUITableViewDataSource>

@property(nonatomic, strong, readonly) QMUITableView *tableView;

@property(nonatomic, copy) NSArray<NSString *> *items;

/// 表示单选模式下已选中的item序号，默认为QMUIDialogSelectionViewControllerSelectedItemIndexNone。此属性与 `selectedItemIndexes` 互斥。
@property(nonatomic, assign) NSInteger selectedItemIndex;

/// 表示多选模式下已选中的item序号，默认为nil。此属性与 `selectedItemIndex` 互斥。
@property(nonatomic, strong) NSMutableSet<NSNumber *> *selectedItemIndexes;

/// 控制是否允许多选，默认为NO。
@property(nonatomic, assign) BOOL allowsMultipleSelection;

@property(nonatomic, copy) void (^cellForItemBlock)(QMUIDialogSelectionViewController *dialogViewController, QMUITableViewCell *cell, NSUInteger itemIndex);
@property(nonatomic, copy) CGFloat (^heightForItemBlock)(QMUIDialogSelectionViewController *dialogViewController, NSUInteger itemIndex);
@property(nonatomic, copy) BOOL (^canSelectItemBlock)(QMUIDialogSelectionViewController *dialogViewController, NSUInteger itemIndex);
@property(nonatomic, copy) void (^didSelectItemBlock)(QMUIDialogSelectionViewController *dialogViewController, NSUInteger itemIndex);
@property(nonatomic, copy) void (^didDeselectItemBlock)(QMUIDialogSelectionViewController *dialogViewController, NSUInteger itemIndex);
@end

/**
 * 支持单行文本输入的弹窗，可通过`maximumLength`属性来控制最长可输入的字符，超过则无法继续输入。
 * 可通过`enablesSubmitButtonAutomatically`来自动设置`submitButton.enabled`的状态
 */
@interface QMUIDialogTextFieldViewController : QMUIDialogViewController

@property(nonatomic, strong, readonly) QMUITextField *textField;

/// 是否自动控制提交按钮的enabled状态，默认为YES，则当输入框内容为空时禁用提交按钮
@property(nonatomic, assign) BOOL enablesSubmitButtonAutomatically;

@property(nonatomic, copy) BOOL (^shouldEnableSubmitButtonBlock)(QMUIDialogTextFieldViewController *dialogViewController);

@end
