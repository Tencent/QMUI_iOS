//
//  QMUIButton.h
//  qmui
//
//  Created by MoLice on 14-7-7.
//  Copyright (c) 2014年 QMUI Team. All rights reserved.
//

#import <UIKit/UIKit.h>

/// 控制图片在UIButton里的位置，默认为QMUIButtonImagePositionLeft
typedef enum {
    QMUIButtonImagePositionTop,             // imageView在titleLabel上面
    QMUIButtonImagePositionLeft,            // imageView在titleLabel左边
    QMUIButtonImagePositionBottom,          // imageView在titleLabel下面
    QMUIButtonImagePositionRight,           // imageView在titleLabel右边
} QMUIButtonImagePosition;

typedef enum {
    QMUIGhostButtonColorBlue,
    QMUIGhostButtonColorRed,
    QMUIGhostButtonColorGreen,
    QMUIGhostButtonColorGray,
    QMUIGhostButtonColorWhite,
} QMUIGhostButtonColor;

typedef enum {
    QMUIFillButtonColorBlue,
    QMUIFillButtonColorRed,
    QMUIFillButtonColorGreen,
    QMUIFillButtonColorGray,
    QMUIFillButtonColorWhite,
} QMUIFillButtonColor;

typedef enum {
    QMUINavigationButtonTypeNormal,         // 普通导航栏文字按钮
    QMUINavigationButtonTypeBold,           // 导航栏加粗按钮
    QMUINavigationButtonTypeImage,          // 图标按钮
    QMUINavigationButtonTypeBack,           // 自定义返回按钮(可以同时带有title)
    QMUINavigationButtonTypeClose,          // 自定义关闭按钮(只显示icon不带title)
} QMUINavigationButtonType;

typedef enum {
    QMUIToolbarButtonTypeNormal,            // 普通工具栏按钮
    QMUIToolbarButtonTypeRed,               // 工具栏红色按钮，用于删除等警告性操作
    QMUIToolbarButtonTypeImage,              // 图标类型的按钮
} QMUIToolbarButtonType;

typedef NS_ENUM(NSInteger, QMUINavigationButtonPosition) {
    QMUINavigationButtonPositionNone = -1,  // 不处于navigationBar最左（右）边的按钮，则使用None。用None则不会在alignmentRectInsets里调整位置
    QMUINavigationButtonPositionLeft,       // 用于leftBarButtonItem，如果用于leftBarButtonItems，则只对最左边的item使用，其他item使用QMUINavigationButtonPositionNone
    QMUINavigationButtonPositionRight,      // 用于rightBarButtonItem，如果用于rightBarButtonItems，则只对最右边的item使用，其他item使用QMUINavigationButtonPositionNone
};


/**
 * 提供以下功能：
 * <ol>
 * <li>highlighted、disabled状态均通过改变整个按钮的alpha来表现，无需分别设置不同state下的titleColor、image</li>
 * <li>支持点击时改变背景色颜色（<i>highlightedBackgroundColor</i>）</li>
 * <li>支持点击时改变边框颜色（<i>highlightedBorderColor</i>）</li>
 * <li>支持设置图片在按钮内的位置，无需自行调整imageEdgeInsets（<i>imagePosition</i>）</li>
 * </ol>
 */
@interface QMUIButton : UIButton

/**
 * 让按钮的文字颜色自动跟随tintColor调整（系统默认titleColor是不跟随的）<br/>
 * 默认为NO
 */
@property(nonatomic, assign) IBInspectable BOOL adjustsTitleTintColorAutomatically;

/**
 * 让按钮的图片颜色自动跟随tintColor调整（系统默认image是需要更改renderingMode才可以达到这种效果）<br/>
 * 默认为NO
 */
@property(nonatomic, assign) IBInspectable BOOL adjustsImageTintColorAutomatically;

/**
 * 是否自动调整highlighted时的按钮样式，默认为YES。<br/>
 * 当值为YES时，按钮highlighted时会改变自身的alpha属性为<b>ButtonHighlightedAlpha</b>
 */
@property(nonatomic, assign) IBInspectable BOOL adjustsButtonWhenHighlighted;

/**
 * 是否自动调整disabled时的按钮样式，默认为YES。<br/>
 * 当值为YES时，按钮disabled时会改变自身的alpha属性为<b>ButtonDisabledAlpha</b>
 */
@property(nonatomic, assign) IBInspectable BOOL adjustsButtonWhenDisabled;

/**
 * 设置按钮点击时的背景色，默认为nil。
 * @warning 不支持带透明度的背景颜色。当设置<i>highlightedBackgroundColor</i>时，会强制把<i>adjustsButtonWhenHighlighted</i>设为NO，避免两者效果冲突。
 * @see adjustsButtonWhenHighlighted
 */
@property(nonatomic, strong) IBInspectable UIColor *highlightedBackgroundColor;

/**
 * 设置按钮点击时的边框颜色，默认为nil。
 * @warning 当设置<i>highlightedBorderColor</i>时，会强制把<i>adjustsButtonWhenHighlighted</i>设为NO，避免两者效果冲突。
 * @see adjustsButtonWhenHighlighted
 */
@property(nonatomic, strong) IBInspectable UIColor *highlightedBorderColor;

/**
 * 设置按钮里图标和文字的相对位置，默认为QMUIButtonImagePositionLeft<br/>
 * 可配合imageEdgeInsets、titleEdgeInsets、contentHorizontalAlignment、contentVerticalAlignment使用
 */
@property(nonatomic, assign) QMUIButtonImagePosition imagePosition;

@end


/**
 *  `QMUINavigationButton`是用于UINavigationBar的按钮
 */
@interface QMUINavigationButton : UIButton

/**
 *  获取当前按钮的`QMUINavigationButtonType`
 */
@property(nonatomic, assign, readonly) QMUINavigationButtonType type;

/**
 *  设置按钮是否用于UINavigationBar上的UIBarButtonItem。若为YES，则会参照系统的按钮布局去更改QMUINavigationButton的内容布局，若为NO，则内容布局与普通按钮没差别。默认为YES。
 */
@property(nonatomic, assign) BOOL useForBarButtonItem;

/**
 *  导航栏按钮的初始化函数，指定的初始化方法
 *  @param type 按钮类型
 *  @param title 按钮的title
 */
- (instancetype)initWithType:(QMUINavigationButtonType)type title:(NSString *)title;

/**
 *  导航栏按钮的初始化函数
 *  @param type 按钮类型
 */
- (instancetype)initWithType:(QMUINavigationButtonType)type;

/**
 *  导航栏按钮的初始化函数
 *  @param image 按钮的image
 */
- (instancetype)initWithImage:(UIImage *)image;

/** 
 *  创建一个返回按钮的UIBarButtonItem，默认使用没有tintColor的那个接口就好了。如果某些界面需要重新设置navBar的tintColor，则使用有tintColor的那个接口来兼容iOS6。
 */
+ (UIBarButtonItem *)backBarButtonItemWithTarget:(id)target action:(SEL)selector tintColor:(UIColor *)tintColor;
+ (UIBarButtonItem *)backBarButtonItemWithTarget:(id)target action:(SEL)selector;

/**
 *  创建一个关闭按钮的UIBarButtonItem，默认使用没有tintColor的那个接口就好了。如果某些界面需要重新设置navBar的tintColor，则使用有tintColor的那个接口来兼容iOS6。
 */
+ (UIBarButtonItem *)closeBarButtonItemWithTarget:(id)target action:(SEL)selector tintColor:(UIColor *)tintColor;
+ (UIBarButtonItem *)closeBarButtonItemWithTarget:(id)target action:(SEL)selector;

/** 
 *  创建一个特定type的UIBarButtonItem，默认使用没有tintColor的那个接口就好了。如果某些界面需要重新设置navBar的tintColor，则使用有tintColor的那个接口来兼容iOS6。
 */
+ (UIBarButtonItem *)barButtonItemWithType:(QMUINavigationButtonType)type title:(NSString *)title tintColor:(UIColor *)tintColor position:(QMUINavigationButtonPosition)position target:(id)target action:(SEL)selector;
+ (UIBarButtonItem *)barButtonItemWithType:(QMUINavigationButtonType)type title:(NSString *)title position:(QMUINavigationButtonPosition)position target:(id)target action:(SEL)selector;

/**
 *  以customView的方式用`QMUINavigationButton`创建一个UIBarButtonItem。position、target、selector等参数不需要对button设置，通过参数传进来就可以了。
 *
 *  @warning 没有提供highLihgted和disabled的样式，需要在button自定义。
 */
+ (UIBarButtonItem *)barButtonItemWithNavigationButton:(QMUINavigationButton *)button position:(QMUINavigationButtonPosition)position target:(id)target action:(SEL)selector;

/**
 *  创建一个图标类型的`UIBarButtonItem`
 */
+ (UIBarButtonItem *)barButtonItemWithImage:(UIImage *)image tintColor:(UIColor *)tintColor position:(QMUINavigationButtonPosition)position target:(id)target action:(SEL)selector;
+ (UIBarButtonItem *)barButtonItemWithImage:(UIImage *)image position:(QMUINavigationButtonPosition)position target:(id)target action:(SEL)selector;

/**
 *  对`UINavigationBar`上的`UIBarButton`做统一的样式调整
 */
+ (void)renderNavigationButtonAppearanceStyle;

@end


/**
 *  `QMUIToolbarButton`是用于底部工具栏的按钮
 */
@interface QMUIToolbarButton : UIButton

/// 获取当前按钮的type
@property(nonatomic, assign, readonly) QMUIToolbarButtonType type;

/**
 *  工具栏按钮的初始化函数
 *  @param type  按钮类型
 */
- (instancetype)initWithType:(QMUIToolbarButtonType)type;

/**
 *  工具栏按钮的初始化函数
 *  @param type 按钮类型
 *  @param title 按钮的title
 */
- (instancetype)initWithType:(QMUIToolbarButtonType)type title:(NSString *)title;

/**
 *  工具栏按钮的初始化函数
 *  @param image 按钮的image
 */
- (instancetype)initWithImage:(UIImage *)image;

/// 在原有的QMUIToolbarButton上创建一个UIBarButtonItem
+ (UIBarButtonItem *)barButtonItemWithToolbarButton:(QMUIToolbarButton *)button target:(id)target action:(SEL)selector;

/// 创建一个特定type的UIBarButtonItem
+ (UIBarButtonItem *)barButtonItemWithType:(QMUIToolbarButtonType)type title:(NSString *)title target:(id)target action:(SEL)selector;

/// 创建一个图标类型的UIBarButtonItem
+ (UIBarButtonItem *)barButtonItemWithImage:(UIImage *)image target:(id)target action:(SEL)selector;

/// 对UIToolbar上的UIBarButtonItem做统一的样式调整
+ (void)renderToolbarButtonAppearanceStyle;

@end


/**
 *  支持显示下划线的按钮，可用于需要链接的场景。下划线默认和按钮宽度一样，可通过 `underlineInsets` 调整。
 */
@interface QMUILinkButton : QMUIButton

/// 控制下划线隐藏或显示，默认为NO，也即显示下划线
@property(nonatomic, assign) IBInspectable BOOL underlineHidden;

/// 设置下划线的宽度，默认为 1
@property(nonatomic, assign) IBInspectable CGFloat underlineWidth;

/// 控制下划线颜色，若设置为nil，则使用当前按钮的titleColor的颜色作为下划线的颜色。默认为 nil。
@property(nonatomic, strong) IBInspectable UIColor *underlineColor;

/// 下划线的位置是基于 titleLabel 的位置来计算的，默认x、width均和titleLabel一致，而可以通过这个属性来调整下划线的偏移值。默认为UIEdgeInsetsZero。
@property(nonatomic, assign) UIEdgeInsets underlineInsets;

@end

/**
 *  用于 `QMUIGhostButton.cornerRadius` 属性，当 `cornerRadius` 为 `QMUIGhostButtonCornerRadiusAdjustsBounds` 时，`QMUIGhostButton` 会在高度变化时自动调整 `cornerRadius`，使其始终保持为高度的 1/2。
 */
extern const CGFloat QMUIGhostButtonCornerRadiusAdjustsBounds;

/**
 *  “幽灵”按钮，也即背景透明、带圆角边框的按钮
 *
 *  可通过 `QMUIGhostButtonColor` 设置几种预设的颜色，也可以用 `ghostColor` 设置自定义颜色。
 *
 *  @warning 默认情况下，`ghostColor` 只会修改文字和边框的颜色，如果需要让 image 也跟随 `ghostColor` 的颜色，则可将 `adjustsImageWithGhostColor` 设为 `YES`
 */
@interface QMUIGhostButton : QMUIButton

@property(nonatomic, strong) IBInspectable UIColor *ghostColor;    // 默认为 GhostButtonColorBlue
@property(nonatomic, assign) CGFloat borderWidth UI_APPEARANCE_SELECTOR;    // 默认为 1pt
@property(nonatomic, assign) CGFloat cornerRadius UI_APPEARANCE_SELECTOR;   // 默认为 QMUIGhostButtonCornerRadiusAdjustsBounds，也即固定保持按钮高度的一半。

/**
 *  控制按钮里面的图片是否也要跟随 `ghostColor` 一起变化，默认为 `NO`
 */
@property(nonatomic, assign) BOOL adjustsImageWithGhostColor UI_APPEARANCE_SELECTOR;

- (instancetype)initWithGhostType:(QMUIGhostButtonColor)ghostType;
- (instancetype)initWithGhostColor:(UIColor *)ghostColor;

@end


/**
 *  用于 `QMUIFillButton.cornerRadius` 属性，当 `cornerRadius` 为 `QMUIFillButtonCornerRadiusAdjustsBounds` 时，`QMUIFillButton` 会在高度变化时自动调整 `cornerRadius`，使其始终保持为高度的 1/2。
 */
extern const CGFloat QMUIFillButtonCornerRadiusAdjustsBounds;

/**
 *  QMUIFillButton
 *  实心填充颜色的按钮，支持预定义的几个色值
 */
@interface QMUIFillButton : QMUIButton

@property(nonatomic, strong) IBInspectable UIColor *fillColor; // 默认为 FillButtonColorBlue
@property(nonatomic, strong) IBInspectable UIColor *titleTextColor; // 默认为 UIColorWhite
@property(nonatomic, assign) CGFloat cornerRadius UI_APPEARANCE_SELECTOR;// 默认为 QMUIFillButtonCornerRadiusAdjustsBounds，也即固定保持按钮高度的一半。

/**
 *  控制按钮里面的图片是否也要跟随 `titleTextColor` 一起变化，默认为 `NO`
 */
@property(nonatomic, assign) BOOL adjustsImageWithTitleTextColor UI_APPEARANCE_SELECTOR;

- (instancetype)initWithFillType:(QMUIFillButtonColor)fillType;
- (instancetype)initWithFillType:(QMUIFillButtonColor)fillType frame:(CGRect)frame;
- (instancetype)initWithFillColor:(UIColor *)fillColor titleTextColor:(UIColor *)textColor;
- (instancetype)initWithFillColor:(UIColor *)fillColor titleTextColor:(UIColor *)textColor frame:(CGRect)frame;

@end

