//
//  QMUIConfigurationManager.h
//  qmui
//
//  Created by QQMail on 15/3/29.
//  Copyright (c) 2015年 QMUI Team. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

/**
 *  维护项目全局 UI 配置的单例，通过业务项目自己的 QMUIConfigurationTemplate 来为这个单例赋值，而业务代码里则通过 QMUIConfiguration.h 文件里的宏来使用这些值。
 */
@interface QMUIConfigurationManager : NSObject


#pragma mark - Global Color

@property(nonatomic, strong) UIColor         *clearColor;
@property(nonatomic, strong) UIColor         *whiteColor;
@property(nonatomic, strong) UIColor         *blackColor;
@property(nonatomic, strong) UIColor         *grayColor;
@property(nonatomic, strong) UIColor         *grayDarkenColor;
@property(nonatomic, strong) UIColor         *grayLightenColor;
@property(nonatomic, strong) UIColor         *redColor;
@property(nonatomic, strong) UIColor         *greenColor;
@property(nonatomic, strong) UIColor         *blueColor;
@property(nonatomic, strong) UIColor         *yellowColor;

@property(nonatomic, strong) UIColor         *linkColor;
@property(nonatomic, strong) UIColor         *disabledColor;
@property(nonatomic, strong) UIColor         *backgroundColor;
@property(nonatomic, strong) UIColor         *maskDarkColor;
@property(nonatomic, strong) UIColor         *maskLightColor;
@property(nonatomic, strong) UIColor         *separatorColor;
@property(nonatomic, strong) UIColor         *separatorDashedColor;
@property(nonatomic, strong) UIColor         *placeholderColor;

@property(nonatomic, strong) UIColor         *testColorRed;
@property(nonatomic, strong) UIColor         *testColorGreen;
@property(nonatomic, strong) UIColor         *testColorBlue;

#pragma mark - UIWindowLevel

@property(nonatomic, assign) CGFloat         windowLevelQMUIAlertView;
@property(nonatomic, assign) CGFloat         windowLevelQMUIActionSheet;
@property(nonatomic, assign) CGFloat         windowLevelQMUIMoreOperationController;
@property(nonatomic, assign) CGFloat         windowLevelQMUIImagePreviewView;

#pragma mark - UIControl

@property(nonatomic, assign) CGFloat         controlHighlightedAlpha;
@property(nonatomic, assign) CGFloat         controlDisabledAlpha;

@property(nonatomic, strong) UIColor         *segmentTextTintColor;
@property(nonatomic, strong) UIColor         *segmentTextSelectedTintColor;
@property(nonatomic, strong) UIFont          *segmentFontSize;

#pragma mark - UIButton

@property(nonatomic, assign) CGFloat         buttonHighlightedAlpha;
@property(nonatomic, assign) CGFloat         buttonDisabledAlpha;
@property(nonatomic, strong) UIColor         *buttonTintColor;
@property(nonatomic, strong) UIColor         *ghostButtonColorBlue;
@property(nonatomic, strong) UIColor         *ghostButtonColorRed;
@property(nonatomic, strong) UIColor         *ghostButtonColorGreen;
@property(nonatomic, strong) UIColor         *ghostButtonColorGray;
@property(nonatomic, strong) UIColor         *ghostButtonColorWhite;
@property(nonatomic, strong) UIColor         *fillButtonColorBlue;
@property(nonatomic, strong) UIColor         *fillButtonColorRed;
@property(nonatomic, strong) UIColor         *fillButtonColorGreen;
@property(nonatomic, strong) UIColor         *fillButtonColorGray;
@property(nonatomic, strong) UIColor         *fillButtonColorWhite;


#pragma mark - UITextField & UITextView

@property(nonatomic, strong) UIColor         *textFieldTintColor;
@property(nonatomic, assign) UIEdgeInsets    textFieldTextInsets;

#pragma mark - ActionSheet

@property(nonatomic, strong) UIColor         *actionSheetButtonTintColor;
@property(nonatomic, strong) UIColor         *actionSheetButtonBackgroundColor;
@property(nonatomic, strong) UIColor         *actionSheetButtonBackgroundColorHighlighted;
@property(nonatomic, strong) UIFont          *actionSheetButtonFont;
@property(nonatomic, strong) UIFont          *actionSheetButtonFontBold;

#pragma mark - NavigationBar

@property(nonatomic, assign) CGFloat         navBarHighlightedAlpha;
@property(nonatomic, assign) CGFloat         navBarDisabledAlpha;
@property(nonatomic, strong) UIFont          *navBarButtonFont;
@property(nonatomic, strong) UIFont          *navBarButtonFontBold;
@property(nonatomic, strong) UIImage         *navBarBackgroundImage;
@property(nonatomic, strong) UIImage         *navBarShadowImage;
@property(nonatomic, strong) UIColor         *navBarShadowImageColor;
@property(nonatomic, strong) UIColor         *navBarBarTintColor;
@property(nonatomic, strong) UIColor         *navBarTintColor;
@property(nonatomic, strong) UIColor         *navBarTintColorHighlighted;
@property(nonatomic, strong) UIColor         *navBarTintColorDisabled;
@property(nonatomic, strong) UIColor         *navBarTitleColor;
@property(nonatomic, strong) UIFont          *navBarTitleFont;
@property(nonatomic, assign) UIOffset        navBarBackButtonTitlePositionAdjustment;
@property(nonatomic, strong) UIImage         *navBarBackIndicatorImage;
@property(nonatomic, strong) UIImage         *navBarCloseButtonImage;

@property(nonatomic, assign) CGFloat         navBarLoadingMarginRight;
@property(nonatomic, assign) CGFloat         navBarAccessoryViewMarginLeft;
@property(nonatomic, assign) UIActivityIndicatorViewStyle navBarActivityIndicatorViewStyle;
@property(nonatomic, strong) UIImage         *navBarAccessoryViewTypeDisclosureIndicatorImage;

#pragma mark - TabBar

@property(nonatomic, strong) UIImage         *tabBarBackgroundImage;
@property(nonatomic, strong) UIColor         *tabBarBarTintColor;
@property(nonatomic, strong) UIColor         *tabBarShadowImageColor;
@property(nonatomic, strong) UIColor         *tabBarTintColor;
@property(nonatomic, strong) UIColor         *tabBarItemTitleColor;
@property(nonatomic, strong) UIColor         *tabBarItemTitleColorSelected;

#pragma mark - Toolbar

@property(nonatomic, assign) CGFloat         toolBarHighlightedAlpha;
@property(nonatomic, assign) CGFloat         toolBarDisabledAlpha;
@property(nonatomic, strong) UIColor         *toolBarTintColor;
@property(nonatomic, strong) UIColor         *toolBarTintColorHighlighted;
@property(nonatomic, strong) UIColor         *toolBarTintColorDisabled;
@property(nonatomic, strong) UIImage         *toolBarBackgroundImage;
@property(nonatomic, strong) UIColor         *toolBarBarTintColor;
@property(nonatomic, strong) UIColor         *toolBarShadowImageColor;
@property(nonatomic, strong) UIFont          *toolBarButtonFont;

#pragma mark - SearchBar

@property(nonatomic, strong) UIColor         *searchBarTextFieldBackground;
@property(nonatomic, strong) UIColor         *searchBarTextFieldBorderColor;
@property(nonatomic, strong) UIColor         *searchBarBottomBorderColor;
@property(nonatomic, strong) UIColor         *searchBarBarTintColor;
@property(nonatomic, strong) UIColor         *searchBarTintColor;
@property(nonatomic, strong) UIColor         *searchBarTextColor;
@property(nonatomic, strong) UIColor         *searchBarPlaceholderColor;
/// 搜索框放大镜icon的图片，大小必须为13x13pt，否则会失真（系统的限制）
@property(nonatomic, strong) UIImage         *searchBarSearchIconImage;
@property(nonatomic, strong) UIImage         *searchBarClearIconImage;
@property(nonatomic, assign) CGFloat         searchBarTextFieldCornerRadius;

#pragma mark - TableView / TableViewCell

@property(nonatomic, strong) UIColor         *tableViewBackgroundColor;
@property(nonatomic, strong) UIColor         *tableViewGroupedBackgroundColor;
@property(nonatomic, strong) UIColor         *tableSectionIndexColor;
@property(nonatomic, strong) UIColor         *tableSectionIndexBackgroundColor;
@property(nonatomic, strong) UIColor         *tableSectionIndexTrackingBackgroundColor;
@property(nonatomic, strong) UIColor         *tableViewSeparatorColor;
@property(nonatomic, strong) UIColor         *tableViewCellBackgroundColor;
@property(nonatomic, strong) UIColor         *tableViewCellSelectedBackgroundColor;
@property(nonatomic, strong) UIColor         *tableViewCellWarningBackgroundColor;
@property(nonatomic, assign) CGFloat         tableViewCellNormalHeight;

@property(nonatomic, strong) UIImage         *tableViewCellDisclosureIndicatorImage;
@property(nonatomic, strong) UIImage         *tableViewCellCheckmarkImage;
@property(nonatomic, strong) UIColor         *tableViewSectionHeaderBackgroundColor;
@property(nonatomic, strong) UIColor         *tableViewSectionFooterBackgroundColor;
@property(nonatomic, strong) UIFont          *tableViewSectionHeaderFont;
@property(nonatomic, strong) UIFont          *tableViewSectionFooterFont;
@property(nonatomic, strong) UIColor         *tableViewSectionHeaderTextColor;
@property(nonatomic, strong) UIColor         *tableViewSectionFooterTextColor;
@property(nonatomic, assign) CGFloat         tableViewSectionHeaderHeight;
@property(nonatomic, assign) CGFloat         tableViewSectionFooterHeight;
@property(nonatomic, assign) UIEdgeInsets    tableViewSectionHeaderContentInset;
@property(nonatomic, assign) UIEdgeInsets    tableViewSectionFooterContentInset;

@property(nonatomic, strong) UIFont          *tableViewGroupedSectionHeaderFont;
@property(nonatomic, strong) UIFont          *tableViewGroupedSectionFooterFont;
@property(nonatomic, strong) UIColor         *tableViewGroupedSectionHeaderTextColor;
@property(nonatomic, strong) UIColor         *tableViewGroupedSectionFooterTextColor;
@property(nonatomic, assign) CGFloat         tableViewGroupedSectionHeaderHeight;
@property(nonatomic, assign) CGFloat         tableViewGroupedSectionFooterHeight;
@property(nonatomic, assign) UIEdgeInsets    tableViewGroupedSectionHeaderContentInset;
@property(nonatomic, assign) UIEdgeInsets    tableViewGroupedSectionFooterContentInset;

@property(nonatomic, strong) UIColor         *tableViewCellTitleLabelColor;
@property(nonatomic, strong) UIColor         *tableViewCellDetailLabelColor;
@property(nonatomic, assign) CGFloat         tableViewCellContentDefaultPaddingLeft;
@property(nonatomic, assign) CGFloat         tableViewCellContentDefaultPaddingRight;

#pragma mark - Others

@property(nonatomic, assign) UIInterfaceOrientationMask supportedOrientationMask;
@property(nonatomic, assign) BOOL            statusbarStyleLightInitially;
@property(nonatomic, assign) BOOL            needsBackBarButtonItemTitle;
@property(nonatomic, assign) BOOL            hidesBottomBarWhenPushedInitially;


/// 单例对象
+ (QMUIConfigurationManager *)sharedInstance;
- (void)initDefaultConfiguration;

@end

@interface QMUIConfigurationManager (UIAppearance)

/**
 * 设置全局 UIAppearance 的代码，一般在 `application:didFinishLaunchingWithOptions:` 里手动调用（在调用 `[QMUIConfigurationTemplate setupConfigurationTemplate]` 之后）
 */
+ (void)renderGlobalAppearances;
@end
