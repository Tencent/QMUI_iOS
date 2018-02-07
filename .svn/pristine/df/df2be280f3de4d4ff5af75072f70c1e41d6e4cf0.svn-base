//
//  QMUIMoreOperationController.h
//  qmui
//
//  Created by QQMail on 15/1/28.
//  Copyright (c) 2015年 QMUI Team. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "QMUIModalPresentationViewController.h"
#import "QMUIButton.h"

/// 操作面板上item的类型，QMUIMoreOperationItemTypeImportant类型的item会放到第一行的scrollView，QMUIMoreOperationItemTypeNormal类型的item会放到第二行的scrollView。
typedef NS_ENUM(NSInteger, QMUIMoreOperationItemType) {
    QMUIMoreOperationItemTypeImportant, // 将item放在第一行显示
    QMUIMoreOperationItemTypeNormal     // 将item放在第二行显示
};

@class QMUIModalPresentationViewController;
@class QMUIMoreOperationController;
@class QMUIMoreOperationItemView;
@class QMUIButton;

/// 更多操作面板的delegate。
@protocol QMUIMoreOperationDelegate <NSObject>

@optional
/// 即将显示操作面板
- (void)willPresentMoreOperationController:(QMUIMoreOperationController *)moreOperationController;
/// 已经显示操作面板
- (void)didPresentMoreOperationController:(QMUIMoreOperationController *)moreOperationController;
/// 即将降下操作面板，cancelled参数是用来区分是否触发了maskView或者cancelButton按钮降下面板还是手动调用hide方法来降下面板。
- (void)willDismissMoreOperationController:(QMUIMoreOperationController *)moreOperationController cancelled:(BOOL)cancelled;
/// 已经降下操作面板，cancelled参数是用来区分是否触发了maskView或者cancelButton按钮降下面板还是手动调用hide方法来降下面板。
- (void)didDismissMoreOperationController:(QMUIMoreOperationController *)moreOperationController cancelled:(BOOL)cancelled;
/// 点击了操作面板上的一个item，可以通过参数拿到当前item的index和type
- (void)moreOperationController:(QMUIMoreOperationController *)moreOperationController didSelectItemAtIndex:(NSInteger)buttonIndex type:(QMUIMoreOperationItemType)type;
/// 点击了操作面板上的一个item，可以通过参数拿到当前item的tag
- (void)moreOperationController:(QMUIMoreOperationController *)moreOperationController didSelectItemAtTag:(NSInteger)tag;

@end

@interface QMUIMoreOperationItemView : QMUIButton

@property (nonatomic, assign, readonly) QMUIMoreOperationItemType itemType;

@end


/**
 *  更多操作面板。在iOS上是一个比较常见的控件，比如系统的相册分享；或者微信的webview分享都会从底部弹出一个面板。<br/>
 *  这个控件一般分为上下两行，第一行会显示比较重要的操作入口，第二行是一些次要的操作入口。
 *  QMUIMoreOperationController就是这样的一个控件，可以通过QMUIMoreOperationItemType来设置操作入口要放在第一行还是第二行。
 */
@interface QMUIMoreOperationController : UIViewController<QMUIModalPresentationContentViewControllerProtocol>

@property(nonatomic, strong) UIColor *contentBackgroundColor UI_APPEARANCE_SELECTOR;
@property(nonatomic, strong) UIColor *contentSeparatorColor UI_APPEARANCE_SELECTOR;
@property(nonatomic, strong) UIColor *cancelButtonBackgroundColor UI_APPEARANCE_SELECTOR;
@property(nonatomic, strong) UIColor *cancelButtonTitleColor UI_APPEARANCE_SELECTOR;
@property(nonatomic, strong) UIColor *cancelButtonSeparatorColor UI_APPEARANCE_SELECTOR;
@property(nonatomic, strong) UIColor *itemBackgroundColor UI_APPEARANCE_SELECTOR;
@property(nonatomic, strong) UIColor *itemTitleColor UI_APPEARANCE_SELECTOR;
@property(nonatomic, strong) UIFont  *itemTitleFont UI_APPEARANCE_SELECTOR;
@property(nonatomic, strong) UIFont  *cancelButtonFont UI_APPEARANCE_SELECTOR;
@property(nonatomic, assign) CGFloat contentEdgeMargin UI_APPEARANCE_SELECTOR;
@property(nonatomic, assign) CGFloat contentMaximumWidth UI_APPEARANCE_SELECTOR;
@property(nonatomic, assign) CGFloat contentCornerRadius UI_APPEARANCE_SELECTOR;
@property(nonatomic, assign) CGFloat itemMarginTop UI_APPEARANCE_SELECTOR;
@property(nonatomic, assign) UIEdgeInsets topScrollViewInsets UI_APPEARANCE_SELECTOR;
@property(nonatomic, assign) UIEdgeInsets bottomScrollViewInsets UI_APPEARANCE_SELECTOR;
@property(nonatomic, assign) CGFloat cancelButtonHeight UI_APPEARANCE_SELECTOR;
@property(nonatomic, assign) CGFloat cancelButtonMarginTop UI_APPEARANCE_SELECTOR;

/// 代理
@property(nonatomic, weak) id<QMUIMoreOperationDelegate> delegate;

/// 获取当前所有的item
@property(nonatomic, copy, readonly) NSArray *items;

/// 获取取消按钮
@property(nonatomic, strong, readonly) QMUIButton *cancelButton;

/// 更多操作面板是否正在显示
@property(nonatomic, assign, getter=isShowing, readonly) BOOL showing;
@property(nonatomic, assign, getter=isAnimating, readonly) BOOL animating;

/// 弹出更多操作面板，一般在init完并且设置好item之后就调用这个接口来显示面板
- (void)showFromBottom;
/// 与showFromBottom相反
- (void)hideToBottom;

/// 下面几个`addItem`方法，是用来往面板里面增加item的
- (NSInteger)addItemWithTitle:(NSString *)title selectedTitle:(NSString *)selectedTitle image:(UIImage *)image selectedImage:(UIImage *)selectedImage type:(QMUIMoreOperationItemType)itemType tag:(NSInteger)tag;
- (NSInteger)addItemWithTitle:(NSString *)title selectedTitle:(NSString *)selectedTitle image:(UIImage *)image selectedImage:(UIImage *)selectedImage type:(QMUIMoreOperationItemType)itemType;
- (NSInteger)addItemWithTitle:(NSString *)title image:(UIImage *)image type:(QMUIMoreOperationItemType)itemType tag:(NSInteger)tag;
- (NSInteger)addItemWithTitle:(NSString *)title image:(UIImage *)image type:(QMUIMoreOperationItemType)itemType;

/// 初始化一个item，并通过下面的`insertItem`来将item插入到面板的某个位置
- (QMUIMoreOperationItemView *)createItemWithTitle:(NSString *)title selectedTitle:(NSString *)selectedTitle image:(UIImage *)image selectedImage:(UIImage *)selectedImage type:(QMUIMoreOperationItemType)itemType tag:(NSInteger)tag;

/// 将通过上面初始化的一个item插入到某个位置
- (BOOL)insertItem:(QMUIMoreOperationItemView *)itemView toIndex:(NSInteger)index;

/// 获取某种类型上的item
- (QMUIMoreOperationItemView *)itemAtIndex:(NSInteger)index type:(QMUIMoreOperationItemType)type;

/// 获取某个tag的item
- (QMUIMoreOperationItemView *)itemAtTag:(NSInteger)tag;

/// 下面两个`setItemHidden`方法可以隐藏某一个item
- (void)setItemHidden:(BOOL)hidden index:(NSInteger)index type:(QMUIMoreOperationItemType)type;
/// 同上
- (void)setItemHidden:(BOOL)hidden tag:(NSInteger)tag;

@end


@interface QMUIMoreOperationController (UIAppearance)

+ (instancetype)appearance;

@end
