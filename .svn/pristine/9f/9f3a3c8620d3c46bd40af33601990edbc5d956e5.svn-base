//
//  QMUIAlertController.h
//  qmui
//
//  Created by QQMail on 15/7/20.
//  Copyright (c) 2015年 QMUI Team. All rights reserved.
//

#import <UIKit/UIKit.h>

@class QMUIModalPresentationViewController;
@class QMUIButton;

typedef NS_ENUM(NSInteger, QMUIAlertActionStyle) {
    QMUIAlertActionStyleDefault = 0,
    QMUIAlertActionStyleCancel,
    QMUIAlertActionStyleDestructive
};

typedef NS_ENUM(NSInteger, QMUIAlertControllerStyle) {
    QMUIAlertControllerStyleActionSheet = 0,
    QMUIAlertControllerStyleAlert
};

/**
 *  QMUIAlertController的按钮，先初始化一个按钮再加到Controller上面即可
 */
@interface QMUIAlertAction : NSObject

/**
 *  初始化QMUIAlertController的按钮
 *
 *  @param title   按钮标题
 *  @param style   按钮style，跟系统一样，有Default、Cancel、Destructive三种类型
 *  @param handler 处理点击时间的block
 *
 *  @return QMUIAlertController按钮的实例
 */
+ (instancetype)actionWithTitle:(NSString *)title style:(QMUIAlertActionStyle)style handler:(void (^)(QMUIAlertAction *action))handler;

@property(nonatomic, strong, readonly) QMUIButton *button;
@property(nonatomic, copy, readonly) NSString *title;
@property(nonatomic, assign, readonly) QMUIAlertActionStyle style;
@property(nonatomic, assign, getter=isEnabled) BOOL enabled;

@end


@class QMUIAlertController;

@protocol QMUIAlertControllerDelegate <NSObject>

- (void)willShowAlertController:(QMUIAlertController *)alertController;
- (void)willHideAlertController:(QMUIAlertController *)alertController;
- (void)didShowAlertController:(QMUIAlertController *)alertController;
- (void)didHideAlertController:(QMUIAlertController *)alertController;

@end


/**
 *  QMUIAlertController是模仿系统UIAlertController的控件，所以系统有的功能在QMUIAlertController里面基本都有。同时QMUIAlertController还提供了一些扩展功能，例如：它的每个button都是开放处理的，可以对默认的按钮进行二次处理（比如加一个图片）；可以通过appearance在app启动的时候通过本控件支持的属性任意修改整个QMUIAlertController的主题样式。
 */
@interface QMUIAlertController : UIViewController

@property(nonatomic, assign) UIEdgeInsets alertContentMargin UI_APPEARANCE_SELECTOR;
@property(nonatomic, assign) CGFloat alertContentMaximumWidth UI_APPEARANCE_SELECTOR;
@property(nonatomic, strong) UIColor *alertSeperatorColor UI_APPEARANCE_SELECTOR;
@property(nonatomic, strong) NSDictionary<NSString *, id> *alertTitleAttributes UI_APPEARANCE_SELECTOR;
@property(nonatomic, strong) NSDictionary<NSString *, id> *alertMessageAttributes UI_APPEARANCE_SELECTOR;
@property(nonatomic, strong) NSDictionary<NSString *, id> *alertButtonAttributes UI_APPEARANCE_SELECTOR;
@property(nonatomic, strong) NSDictionary<NSString *, id> *alertButtonDisabledAttributes UI_APPEARANCE_SELECTOR;
@property(nonatomic, strong) NSDictionary<NSString *, id> *alertCancelButtonAttributes UI_APPEARANCE_SELECTOR;
@property(nonatomic, strong) NSDictionary<NSString *, id> *alertDestructiveButtonAttributes UI_APPEARANCE_SELECTOR;
@property(nonatomic, assign) CGFloat alertContentCornerRadius UI_APPEARANCE_SELECTOR;
@property(nonatomic, assign) CGFloat alertButtonHeight UI_APPEARANCE_SELECTOR;
@property(nonatomic, strong) UIColor *alertHeaderBackgroundColor UI_APPEARANCE_SELECTOR;
@property(nonatomic, strong) UIColor *alertButtonBackgroundColor UI_APPEARANCE_SELECTOR;
@property(nonatomic, strong) UIColor *alertButtonHighlightBackgroundColor UI_APPEARANCE_SELECTOR;
@property(nonatomic, assign) CGFloat alertTitleMessageSpacing UI_APPEARANCE_SELECTOR;
@property(nonatomic, assign) UIEdgeInsets alertHeaderInsets UI_APPEARANCE_SELECTOR;

@property(nonatomic, assign) UIEdgeInsets sheetContentMargin UI_APPEARANCE_SELECTOR;
@property(nonatomic, assign) CGFloat sheetContentMaximumWidth UI_APPEARANCE_SELECTOR;
@property(nonatomic, strong) UIColor *sheetSeperatorColor UI_APPEARANCE_SELECTOR;
@property(nonatomic, strong) NSDictionary<NSString *, id> *sheetTitleAttributes UI_APPEARANCE_SELECTOR;
@property(nonatomic, strong) NSDictionary<NSString *, id> *sheetMessageAttributes UI_APPEARANCE_SELECTOR;
@property(nonatomic, strong) NSDictionary<NSString *, id> *sheetButtonAttributes UI_APPEARANCE_SELECTOR;
@property(nonatomic, strong) NSDictionary<NSString *, id> *sheetButtonDisabledAttributes UI_APPEARANCE_SELECTOR;
@property(nonatomic, strong) NSDictionary<NSString *, id> *sheetCancelButtonAttributes UI_APPEARANCE_SELECTOR;
@property(nonatomic, strong) NSDictionary<NSString *, id> *sheetDestructiveButtonAttributes UI_APPEARANCE_SELECTOR;
@property(nonatomic, assign) CGFloat sheetCancelButtonMarginTop UI_APPEARANCE_SELECTOR;
@property(nonatomic, assign) CGFloat sheetContentCornerRadius UI_APPEARANCE_SELECTOR;
@property(nonatomic, assign) CGFloat sheetButtonHeight UI_APPEARANCE_SELECTOR;
@property(nonatomic, strong) UIColor *sheetHeaderBackgroundColor UI_APPEARANCE_SELECTOR;
@property(nonatomic, strong) UIColor *sheetButtonBackgroundColor UI_APPEARANCE_SELECTOR;
@property(nonatomic, strong) UIColor *sheetButtonHighlightBackgroundColor UI_APPEARANCE_SELECTOR;
@property(nonatomic, assign) CGFloat sheetTitleMessageSpacing UI_APPEARANCE_SELECTOR;
@property(nonatomic, assign) UIEdgeInsets sheetHeaderInsets UI_APPEARANCE_SELECTOR;



/// 默认初始化方法
- (instancetype)initWithTitle:(NSString *)title message:(NSString *)message preferredStyle:(QMUIAlertControllerStyle)preferredStyle;

/// 通过类方法初始化
+ (instancetype)alertControllerWithTitle:(NSString *)title message:(NSString *)message preferredStyle:(QMUIAlertControllerStyle)preferredStyle;

@property(nonatomic,weak) id<QMUIAlertControllerDelegate>delegate;

/// 增加一个按钮
- (void)addAction:(QMUIAlertAction *)action;
/// 增加一个输入框
- (void)addTextFieldWithConfigurationHandler:(void (^)(UITextField *textField))configurationHandler;
/// 增加一个自定义的view作为QMUIAlertController的contentView
- (void)addCustomView:(UIView *)view;

- (void)showWithAnimated:(BOOL)animated;
- (void)hideWithAnimated:(BOOL)animated;

@property(nonatomic, strong, readonly) NSArray *actions;
@property(nonatomic, strong, readonly) NSArray *textFields;
@property(nonatomic, strong, readonly) UIView  *customView;

@property(nonatomic, copy) NSString *title;
@property(nonatomic, copy) NSString *message;
@property(nonatomic, assign, readonly) QMUIAlertControllerStyle preferredStyle;

/// 将QMUIAlert弹起来的工具Controller
@property(nonatomic, strong, readonly) QMUIModalPresentationViewController *modalPresentationViewController;

/**
 *  设置按钮的排序是否要由用户添加的顺序来决定，默认为NO，也即与系统原生UIAlertController一致，QMUIAlertActionStyleDestructive类型的action必定在最后面。
 *
 *  @warning 注意QMUIAlertActionStyleCancel按钮不受这个属性的影响
 */
@property(nonatomic, assign) BOOL orderActionsByAddedOrdered;

/// maskView是否响应点击，alert默认为NO，sheet默认为YES
@property(nonatomic, assign) BOOL shouldRespondMaskViewTouch;

@end


@interface QMUIAlertController (UIAppearance)

+ (instancetype)appearance;

@end


@interface QMUIAlertController (Manager)

/**
 *  可方便地判断是否有alertController正在显示，全局生效
 */
+ (BOOL)isAnyAlertControllerVisible;
@end
