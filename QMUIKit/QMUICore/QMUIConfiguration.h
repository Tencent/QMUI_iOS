/**
 * Tencent is pleased to support the open source community by making QMUI_iOS available.
 * Copyright (C) 2016-2020 THL A29 Limited, a Tencent company. All rights reserved.
 * Licensed under the MIT License (the "License"); you may not use this file except in compliance with the License. You may obtain a copy of the License at
 * http://opensource.org/licenses/MIT
 * Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.
 */

//
//  QMUIConfiguration.h
//  qmui
//
//  Created by QMUI Team on 15/3/29.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

/// 所有配置表都应该实现的 protocol
/// All configuration templates should implement this protocal
@protocol QMUIConfigurationTemplateProtocol <NSObject>

@required
/// 应用配置表的设置
/// Applies configurations
- (void)applyConfigurationTemplate;

@optional
/// 当返回 YES 时，启动 App 的时候 QMUIConfiguration 会自动应用这份配置表。但启动 App 时自动应用的配置表最多只允许一份，如果有多份则其他的会被忽略
/// QMUIConfiguration automatically applies this template on launch when set to YES. Since only one copy of configuration template is allowed when the app launches, you'll have to call `applyConfigurationTemplate` manually if you have more than one configuration templates. 
- (BOOL)shouldApplyTemplateAutomatically;

@end

/**
 *  维护项目全局 UI 配置的单例，通过业务项目自己的 QMUIConfigurationTemplate 来为这个单例赋值，而业务代码里则通过 QMUIConfigurationMacros.h 文件里的宏来使用这些值。
 *  A singleton that contains various UI configurations. Use `QMUIConfigurationTemplate` to set values; Use macros in `QMUIConfigurationMacros.h` to get values.
 */
@interface QMUIConfiguration : NSObject

NS_ASSUME_NONNULL_BEGIN

/// 标志当前项目是否有使用配置表功能
@property(nonatomic, assign, readonly) BOOL active;

#pragma mark - Global Color

@property(nonatomic, strong) UIColor            *clearColor;
@property(nonatomic, strong) UIColor            *whiteColor;
@property(nonatomic, strong) UIColor            *blackColor;
@property(nonatomic, strong) UIColor            *grayColor;
@property(nonatomic, strong) UIColor            *grayDarkenColor;
@property(nonatomic, strong) UIColor            *grayLightenColor;
@property(nonatomic, strong) UIColor            *redColor;
@property(nonatomic, strong) UIColor            *greenColor;
@property(nonatomic, strong) UIColor            *blueColor;
@property(nonatomic, strong) UIColor            *yellowColor;

@property(nonatomic, strong) UIColor            *linkColor;
@property(nonatomic, strong) UIColor            *disabledColor;
@property(nonatomic, strong, nullable) UIColor  *backgroundColor;
@property(nonatomic, strong) UIColor            *maskDarkColor;
@property(nonatomic, strong) UIColor            *maskLightColor;
@property(nonatomic, strong) UIColor            *separatorColor;
@property(nonatomic, strong) UIColor            *separatorDashedColor;
@property(nonatomic, strong) UIColor            *placeholderColor;

@property(nonatomic, strong) UIColor            *testColorRed;
@property(nonatomic, strong) UIColor            *testColorGreen;
@property(nonatomic, strong) UIColor            *testColorBlue;

#pragma mark - UIControl

@property(nonatomic, assign) CGFloat            controlHighlightedAlpha;
@property(nonatomic, assign) CGFloat            controlDisabledAlpha;

#pragma mark - UIButton

@property(nonatomic, assign) CGFloat            buttonHighlightedAlpha;
@property(nonatomic, assign) CGFloat            buttonDisabledAlpha;
@property(nonatomic, strong, nullable)  UIColor *buttonTintColor;
@property(nonatomic, strong) UIColor            *ghostButtonColorBlue;
@property(nonatomic, strong) UIColor            *ghostButtonColorRed;
@property(nonatomic, strong) UIColor            *ghostButtonColorGreen;
@property(nonatomic, strong) UIColor            *ghostButtonColorGray;
@property(nonatomic, strong) UIColor            *ghostButtonColorWhite;
@property(nonatomic, strong) UIColor            *fillButtonColorBlue;
@property(nonatomic, strong) UIColor            *fillButtonColorRed;
@property(nonatomic, strong) UIColor            *fillButtonColorGreen;
@property(nonatomic, strong) UIColor            *fillButtonColorGray;
@property(nonatomic, strong) UIColor            *fillButtonColorWhite;

#pragma mark - UITextField & UITextView

@property(nonatomic, strong, nullable) UIColor  *textFieldTextColor;
@property(nonatomic, strong, nullable) UIColor  *textFieldTintColor;
@property(nonatomic, assign) UIEdgeInsets       textFieldTextInsets;
@property(nonatomic, assign) UIKeyboardAppearance keyboardAppearance;

#pragma mark - UISwitch
@property(nonatomic, strong, nullable) UIColor  *switchOnTintColor;
@property(nonatomic, strong, nullable) UIColor  *switchOffTintColor;
@property(nonatomic, strong, nullable) UIColor  *switchTintColor;
@property(nonatomic, strong, nullable) UIColor  *switchThumbTintColor;
@property(nonatomic, strong, nullable) UIImage  *switchOnImage;
@property(nonatomic, strong, nullable) UIImage  *switchOffImage;

#pragma mark - NavigationBar

@property(nonatomic, assign) CGFloat            navBarHighlightedAlpha;
@property(nonatomic, assign) CGFloat            navBarDisabledAlpha;
@property(nonatomic, strong, nullable) UIFont   *navBarButtonFont;
@property(nonatomic, strong, nullable) UIFont   *navBarButtonFontBold;
@property(nonatomic, strong, nullable) UIImage  *navBarBackgroundImage;
@property(nonatomic, strong, nullable) UIImage  *navBarShadowImage;
@property(nonatomic, strong, nullable) UIColor  *navBarShadowImageColor;
@property(nonatomic, strong, nullable) UIColor  *navBarBarTintColor;
@property(nonatomic, assign) UIBarStyle         navBarStyle;
@property(nonatomic, strong, nullable) UIColor  *navBarTintColor;
@property(nonatomic, strong, nullable) UIColor  *navBarTitleColor;
@property(nonatomic, strong, nullable) UIFont   *navBarTitleFont;
@property(nonatomic, strong, nullable) UIColor  *navBarLargeTitleColor;
@property(nonatomic, strong, nullable) UIFont   *navBarLargeTitleFont;
@property(nonatomic, assign) UIOffset           navBarBackButtonTitlePositionAdjustment;
@property(nonatomic, assign) BOOL               sizeNavBarBackIndicatorImageAutomatically;
@property(nonatomic, strong, nullable) UIImage  *navBarBackIndicatorImage;
@property(nonatomic, strong) UIImage            *navBarCloseButtonImage;

@property(nonatomic, assign) CGFloat            navBarLoadingMarginRight;
@property(nonatomic, assign) CGFloat            navBarAccessoryViewMarginLeft;
@property(nonatomic, assign) UIActivityIndicatorViewStyle navBarActivityIndicatorViewStyle;
@property(nonatomic, strong) UIImage            *navBarAccessoryViewTypeDisclosureIndicatorImage;

#pragma mark - TabBar

@property(nonatomic, strong, nullable) UIImage  *tabBarBackgroundImage;
@property(nonatomic, strong, nullable) UIColor  *tabBarBarTintColor;
@property(nonatomic, strong, nullable) UIColor  *tabBarShadowImageColor;
@property(nonatomic, assign) UIBarStyle         tabBarStyle;
@property(nonatomic, strong, nullable) UIFont   *tabBarItemTitleFont;
@property(nonatomic, strong, nullable) UIColor  *tabBarItemTitleColor;
@property(nonatomic, strong, nullable) UIColor  *tabBarItemTitleColorSelected;
@property(nonatomic, strong, nullable) UIColor  *tabBarItemImageColor;
@property(nonatomic, strong, nullable) UIColor  *tabBarItemImageColorSelected;

#pragma mark - Toolbar

@property(nonatomic, assign) CGFloat            toolBarHighlightedAlpha;
@property(nonatomic, assign) CGFloat            toolBarDisabledAlpha;
@property(nonatomic, strong, nullable) UIColor  *toolBarTintColor;
@property(nonatomic, strong, nullable) UIColor  *toolBarTintColorHighlighted;
@property(nonatomic, strong, nullable) UIColor  *toolBarTintColorDisabled;
@property(nonatomic, strong, nullable) UIImage  *toolBarBackgroundImage;
@property(nonatomic, strong, nullable) UIColor  *toolBarBarTintColor;
@property(nonatomic, strong, nullable) UIColor  *toolBarShadowImageColor;
@property(nonatomic, assign) UIBarStyle         toolBarStyle;
@property(nonatomic, strong, nullable) UIFont   *toolBarButtonFont;

#pragma mark - SearchBar

@property(nonatomic, strong, nullable) UIImage  *searchBarTextFieldBackgroundImage;
@property(nonatomic, strong, nullable) UIColor  *searchBarTextFieldBorderColor;
@property(nonatomic, strong, nullable) UIImage  *searchBarBackgroundImage;
@property(nonatomic, strong, nullable) UIColor  *searchBarTintColor;
@property(nonatomic, strong, nullable) UIColor  *searchBarTextColor;
@property(nonatomic, strong, nullable) UIColor  *searchBarPlaceholderColor;
@property(nonatomic, strong, nullable) UIFont   *searchBarFont;
/// 搜索框放大镜icon的图片，大小必须为14x14pt，否则会失真（系统的限制）
/// The magnifier icon in search bar. Size must be 14 x 14pt to avoid being distorted.
@property(nonatomic, strong, nullable) UIImage  *searchBarSearchIconImage;
@property(nonatomic, strong, nullable) UIImage  *searchBarClearIconImage;
@property(nonatomic, assign) CGFloat            searchBarTextFieldCornerRadius;

#pragma mark - TableView / TableViewCell

@property(nonatomic, assign) BOOL               tableViewEstimatedHeightEnabled;

@property(nonatomic, strong, nullable) UIColor  *tableViewBackgroundColor;
@property(nonatomic, strong, nullable) UIColor  *tableSectionIndexColor;
@property(nonatomic, strong, nullable) UIColor  *tableSectionIndexBackgroundColor;
@property(nonatomic, strong, nullable) UIColor  *tableSectionIndexTrackingBackgroundColor;
@property(nonatomic, strong, nullable) UIColor  *tableViewSeparatorColor;

@property(nonatomic, assign) CGFloat            tableViewCellNormalHeight;
@property(nonatomic, strong, nullable) UIColor  *tableViewCellTitleLabelColor;
@property(nonatomic, strong, nullable) UIColor  *tableViewCellDetailLabelColor;
@property(nonatomic, strong, nullable) UIColor  *tableViewCellBackgroundColor;
@property(nonatomic, strong, nullable) UIColor  *tableViewCellSelectedBackgroundColor;
@property(nonatomic, strong, nullable) UIColor  *tableViewCellWarningBackgroundColor;
@property(nonatomic, strong, nullable) UIImage  *tableViewCellDisclosureIndicatorImage;
@property(nonatomic, strong, nullable) UIImage  *tableViewCellCheckmarkImage;
@property(nonatomic, strong, nullable) UIImage  *tableViewCellDetailButtonImage;
@property(nonatomic, assign) CGFloat tableViewCellSpacingBetweenDetailButtonAndDisclosureIndicator;

@property(nonatomic, strong, nullable) UIColor  *tableViewSectionHeaderBackgroundColor;
@property(nonatomic, strong, nullable) UIColor  *tableViewSectionFooterBackgroundColor;
@property(nonatomic, strong, nullable) UIFont   *tableViewSectionHeaderFont;
@property(nonatomic, strong, nullable) UIFont   *tableViewSectionFooterFont;
@property(nonatomic, strong, nullable) UIColor  *tableViewSectionHeaderTextColor;
@property(nonatomic, strong, nullable) UIColor  *tableViewSectionFooterTextColor;
@property(nonatomic, assign) UIEdgeInsets       tableViewSectionHeaderAccessoryMargins;
@property(nonatomic, assign) UIEdgeInsets       tableViewSectionFooterAccessoryMargins;
@property(nonatomic, assign) UIEdgeInsets       tableViewSectionHeaderContentInset;
@property(nonatomic, assign) UIEdgeInsets       tableViewSectionFooterContentInset;

@property(nonatomic, strong, nullable) UIColor  *tableViewGroupedBackgroundColor;
@property(nonatomic, strong, nullable) UIColor  *tableViewGroupedCellTitleLabelColor;
@property(nonatomic, strong, nullable) UIColor  *tableViewGroupedCellDetailLabelColor;
@property(nonatomic, strong, nullable) UIColor  *tableViewGroupedCellBackgroundColor;
@property(nonatomic, strong, nullable) UIColor  *tableViewGroupedCellSelectedBackgroundColor;
@property(nonatomic, strong, nullable) UIColor  *tableViewGroupedCellWarningBackgroundColor;
@property(nonatomic, strong, nullable) UIFont   *tableViewGroupedSectionHeaderFont;
@property(nonatomic, strong, nullable) UIFont   *tableViewGroupedSectionFooterFont;
@property(nonatomic, strong, nullable) UIColor  *tableViewGroupedSectionHeaderTextColor;
@property(nonatomic, strong, nullable) UIColor  *tableViewGroupedSectionFooterTextColor;
@property(nonatomic, assign) UIEdgeInsets       tableViewGroupedSectionHeaderAccessoryMargins;
@property(nonatomic, assign) UIEdgeInsets       tableViewGroupedSectionFooterAccessoryMargins;
@property(nonatomic, assign) CGFloat            tableViewGroupedSectionHeaderDefaultHeight;
@property(nonatomic, assign) CGFloat            tableViewGroupedSectionFooterDefaultHeight;
@property(nonatomic, assign) UIEdgeInsets       tableViewGroupedSectionHeaderContentInset;
@property(nonatomic, assign) UIEdgeInsets       tableViewGroupedSectionFooterContentInset;

#pragma mark - UIWindowLevel

@property(nonatomic, assign) CGFloat            windowLevelQMUIAlertView;
@property(nonatomic, assign) CGFloat            windowLevelQMUIConsole;

#pragma mark - QMUILog

@property(nonatomic, assign) BOOL               shouldPrintDefaultLog;
@property(nonatomic, assign) BOOL               shouldPrintInfoLog;
@property(nonatomic, assign) BOOL               shouldPrintWarnLog;
@property(nonatomic, assign) BOOL               shouldPrintQMUIWarnLogToConsole;

#pragma mark - QMUIBadge

@property(nonatomic, strong, nullable) UIColor  *badgeBackgroundColor;
@property(nonatomic, strong, nullable) UIColor  *badgeTextColor;
@property(nonatomic, strong, nullable) UIFont   *badgeFont;
@property(nonatomic, assign) UIEdgeInsets       badgeContentEdgeInsets;
@property(nonatomic, assign) CGPoint            badgeCenterOffset;
@property(nonatomic, assign) CGPoint            badgeCenterOffsetLandscape;

@property(nonatomic, strong, nullable) UIColor  *updatesIndicatorColor;
@property(nonatomic, assign) CGSize             updatesIndicatorSize;
@property(nonatomic, assign) CGPoint            updatesIndicatorCenterOffset;
@property(nonatomic, assign) CGPoint            updatesIndicatorCenterOffsetLandscape;

#pragma mark - Others

@property(nonatomic, assign) BOOL               automaticCustomNavigationBarTransitionStyle;
@property(nonatomic, assign) UIInterfaceOrientationMask supportedOrientationMask;
@property(nonatomic, assign) BOOL               automaticallyRotateDeviceOrientation;
@property(nonatomic, assign) BOOL               statusbarStyleLightInitially;
@property(nonatomic, assign) BOOL               needsBackBarButtonItemTitle;
@property(nonatomic, assign) BOOL               hidesBottomBarWhenPushedInitially;
@property(nonatomic, assign) BOOL               preventConcurrentNavigationControllerTransitions;
@property(nonatomic, assign) BOOL               navigationBarHiddenInitially;
@property(nonatomic, assign) BOOL               shouldFixTabBarTransitionBugInIPhoneX;
@property(nonatomic, assign) BOOL               shouldFixTabBarButtonBugForAll;
@property(nonatomic, assign) BOOL               shouldFixTabBarSafeAreaInsetsBug;
@property(nonatomic, assign) BOOL               shouldFixSearchBarMaskViewLayoutBug;
@property(nonatomic, assign) BOOL               sendAnalyticsToQMUITeam;
@property(nonatomic, assign) BOOL               dynamicPreferredValueForIPad;
@property(nonatomic, assign) BOOL               ignoreKVCAccessProhibited API_AVAILABLE(ios(13.0));
@property(nonatomic, assign) BOOL               adjustScrollIndicatorInsetsByContentInsetAdjustment API_AVAILABLE(ios(13.0));

NS_ASSUME_NONNULL_END

/// 单例对象
/// The singleton instance
+ (instancetype _Nullable )sharedInstance;
- (void)applyInitialTemplate;

@end

@interface UITabBarItem (QMUIConfiguration)

- (void)qmui_updateTintColorForiOS12AndEarlier:(nullable UIColor *)tintColor;
@end
