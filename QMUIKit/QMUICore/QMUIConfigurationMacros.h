/*****
 * Tencent is pleased to support the open source community by making QMUI_iOS available.
 * Copyright (C) 2016-2019 THL A29 Limited, a Tencent company. All rights reserved.
 * Licensed under the MIT License (the "License"); you may not use this file except in compliance with the License. You may obtain a copy of the License at
 * http://opensource.org/licenses/MIT
 * Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.
 *****/

//
//  QMUIConfigurationMacros.h
//  qmui
//
//  Created by QMUI Team on 14-7-2.
//

#import "QMUIConfiguration.h"


/**
 *  提供一系列方便书写的宏，以便在代码里读取配置表的各种属性。
 *  @warning 请不要在 + load 方法里调用 QMUIConfigurationTemplate 或 QMUIConfigurationMacros 提供的宏，那个时机太早，可能导致 crash
 *  @waining 维护时，如果需要增加一个宏，则需要定义一个新的 QMUIConfiguration 属性。
 */


// 单例的宏

#define QMUICMI ({[[QMUIConfiguration sharedInstance] applyInitialTemplate];[QMUIConfiguration sharedInstance];})

/// 标志当前项目是否正使用配置表功能
#define QMUICMIActivated            [QMUICMI active]

#pragma mark - Global Color

// 基础颜色
#define UIColorClear                [QMUICMI clearColor]
#define UIColorWhite                [QMUICMI whiteColor]
#define UIColorBlack                [QMUICMI blackColor]
#define UIColorGray                 [QMUICMI grayColor]
#define UIColorGrayDarken           [QMUICMI grayDarkenColor]
#define UIColorGrayLighten          [QMUICMI grayLightenColor]
#define UIColorRed                  [QMUICMI redColor]
#define UIColorGreen                [QMUICMI greenColor]
#define UIColorBlue                 [QMUICMI blueColor]
#define UIColorYellow               [QMUICMI yellowColor]

// 功能颜色
#define UIColorLink                 [QMUICMI linkColor]                       // 全局统一文字链接颜色
#define UIColorDisabled             [QMUICMI disabledColor]                   // 全局统一文字disabled颜色
#define UIColorForBackground        [QMUICMI backgroundColor]                 // 全局统一的背景色
#define UIColorMask                 [QMUICMI maskDarkColor]                   // 全局统一的mask背景色
#define UIColorMaskWhite            [QMUICMI maskLightColor]                  // 全局统一的mask背景色，白色
#define UIColorSeparator            [QMUICMI separatorColor]                  // 全局分隔线颜色
#define UIColorSeparatorDashed      [QMUICMI separatorDashedColor]            // 全局分隔线颜色（虚线）
#define UIColorPlaceholder          [QMUICMI placeholderColor]                // 全局的输入框的placeholder颜色

// 测试用的颜色
#define UIColorTestRed              [QMUICMI testColorRed]
#define UIColorTestGreen            [QMUICMI testColorGreen]
#define UIColorTestBlue             [QMUICMI testColorBlue]

// 可操作的控件
#pragma mark - UIControl

#define UIControlHighlightedAlpha       [QMUICMI controlHighlightedAlpha]          // 一般control的Highlighted透明值
#define UIControlDisabledAlpha          [QMUICMI controlDisabledAlpha]             // 一般control的Disable透明值

// 按钮
#pragma mark - UIButton
#define ButtonHighlightedAlpha          [QMUICMI buttonHighlightedAlpha]           // 按钮Highlighted状态的透明度
#define ButtonDisabledAlpha             [QMUICMI buttonDisabledAlpha]              // 按钮Disabled状态的透明度
#define ButtonTintColor                 [QMUICMI buttonTintColor]                  // 普通按钮的颜色

#define GhostButtonColorBlue            [QMUICMI ghostButtonColorBlue]              // QMUIGhostButtonColorBlue的颜色
#define GhostButtonColorRed             [QMUICMI ghostButtonColorRed]               // QMUIGhostButtonColorRed的颜色
#define GhostButtonColorGreen           [QMUICMI ghostButtonColorGreen]             // QMUIGhostButtonColorGreen的颜色
#define GhostButtonColorGray            [QMUICMI ghostButtonColorGray]              // QMUIGhostButtonColorGray的颜色
#define GhostButtonColorWhite           [QMUICMI ghostButtonColorWhite]             // QMUIGhostButtonColorWhite的颜色

#define FillButtonColorBlue             [QMUICMI fillButtonColorBlue]              // QMUIFillButtonColorBlue的颜色
#define FillButtonColorRed              [QMUICMI fillButtonColorRed]               // QMUIFillButtonColorRed的颜色
#define FillButtonColorGreen            [QMUICMI fillButtonColorGreen]             // QMUIFillButtonColorGreen的颜色
#define FillButtonColorGray             [QMUICMI fillButtonColorGray]              // QMUIFillButtonColorGray的颜色
#define FillButtonColorWhite            [QMUICMI fillButtonColorWhite]             // QMUIFillButtonColorWhite的颜色

#pragma mark - TextInput
#define TextFieldTintColor              [QMUICMI textFieldTintColor]               // 全局UITextField、UITextView的tintColor
#define TextFieldTextInsets             [QMUICMI textFieldTextInsets]              // QMUITextField的内边距
#define KeyboardAppearance              [QMUICMI keyboardAppearance]

#pragma mark - UISwitch
#define SwitchOnTintColor               [QMUICMI switchOnTintColor]                 // UISwitch 打开时的背景色（除了圆点外的其他颜色）
#define SwitchOffTintColor              [QMUICMI switchOffTintColor]                // UISwitch 关闭时的背景色（除了圆点外的其他颜色）
#define SwitchTintColor                 [QMUICMI switchTintColor]                   // UISwitch 关闭时的周围边框颜色
#define SwitchThumbTintColor            [QMUICMI switchThumbTintColor]              // UISwitch 中间的操控圆点的颜色

#pragma mark - NavigationBar

#define NavBarHighlightedAlpha                          [QMUICMI navBarHighlightedAlpha]
#define NavBarDisabledAlpha                             [QMUICMI navBarDisabledAlpha]
#define NavBarButtonFont                                [QMUICMI navBarButtonFont]
#define NavBarButtonFontBold                            [QMUICMI navBarButtonFontBold]
#define NavBarBackgroundImage                           [QMUICMI navBarBackgroundImage]
#define NavBarShadowImage                               [QMUICMI navBarShadowImage]
#define NavBarShadowImageColor                          [QMUICMI navBarShadowImageColor]
#define NavBarBarTintColor                              [QMUICMI navBarBarTintColor]
#define NavBarStyle                                     [QMUICMI navBarStyle]
#define NavBarTintColor                                 [QMUICMI navBarTintColor]
#define NavBarTitleColor                                [QMUICMI navBarTitleColor]
#define NavBarTitleFont                                 [QMUICMI navBarTitleFont]
#define NavBarLargeTitleColor                           [QMUICMI navBarLargeTitleColor]
#define NavBarLargeTitleFont                            [QMUICMI navBarLargeTitleFont]
#define NavBarBarBackButtonTitlePositionAdjustment      [QMUICMI navBarBackButtonTitlePositionAdjustment]
#define NavBarBackIndicatorImage                        [QMUICMI navBarBackIndicatorImage]
#define SizeNavBarBackIndicatorImageAutomatically       [QMUICMI sizeNavBarBackIndicatorImageAutomatically]
#define NavBarCloseButtonImage                          [QMUICMI navBarCloseButtonImage]

#define NavBarLoadingMarginRight                        [QMUICMI navBarLoadingMarginRight]                          // titleView里左边的loading的右边距
#define NavBarAccessoryViewMarginLeft                   [QMUICMI navBarAccessoryViewMarginLeft]                     // titleView里的accessoryView的左边距
#define NavBarActivityIndicatorViewStyle                [QMUICMI navBarActivityIndicatorViewStyle]                  // titleView loading 的style
#define NavBarAccessoryViewTypeDisclosureIndicatorImage [QMUICMI navBarAccessoryViewTypeDisclosureIndicatorImage]   // titleView上倒三角的默认图片


#pragma mark - TabBar

#define TabBarBackgroundImage                           [QMUICMI tabBarBackgroundImage]
#define TabBarBarTintColor                              [QMUICMI tabBarBarTintColor]
#define TabBarShadowImageColor                          [QMUICMI tabBarShadowImageColor]
#define TabBarStyle                                     [QMUICMI tabBarStyle]
#define TabBarItemTitleFont                             [QMUICMI tabBarItemTitleFont]
#define TabBarItemTitleColor                            [QMUICMI tabBarItemTitleColor]
#define TabBarItemTitleColorSelected                    [QMUICMI tabBarItemTitleColorSelected]
#define TabBarItemImageColor                            [QMUICMI tabBarItemImageColor]
#define TabBarItemImageColorSelected                    [QMUICMI tabBarItemImageColorSelected]

#pragma mark - Toolbar

#define ToolBarHighlightedAlpha                         [QMUICMI toolBarHighlightedAlpha]
#define ToolBarDisabledAlpha                            [QMUICMI toolBarDisabledAlpha]
#define ToolBarTintColor                                [QMUICMI toolBarTintColor]
#define ToolBarTintColorHighlighted                     [QMUICMI toolBarTintColorHighlighted]
#define ToolBarTintColorDisabled                        [QMUICMI toolBarTintColorDisabled]
#define ToolBarBackgroundImage                          [QMUICMI toolBarBackgroundImage]
#define ToolBarBarTintColor                             [QMUICMI toolBarBarTintColor]
#define ToolBarShadowImageColor                         [QMUICMI toolBarShadowImageColor]
#define ToolBarStyle                                    [QMUICMI toolBarStyle]
#define ToolBarButtonFont                               [QMUICMI toolBarButtonFont]


#pragma mark - SearchBar

#define SearchBarTextFieldBorderColor                   [QMUICMI searchBarTextFieldBorderColor]
#define SearchBarTextFieldBackgroundImage               [QMUICMI searchBarTextFieldBackgroundImage]
#define SearchBarBackgroundImage                        [QMUICMI searchBarBackgroundImage]
#define SearchBarTintColor                              [QMUICMI searchBarTintColor]
#define SearchBarTextColor                              [QMUICMI searchBarTextColor]
#define SearchBarPlaceholderColor                       [QMUICMI searchBarPlaceholderColor]
#define SearchBarFont                                   [QMUICMI searchBarFont]
#define SearchBarSearchIconImage                        [QMUICMI searchBarSearchIconImage]
#define SearchBarClearIconImage                         [QMUICMI searchBarClearIconImage]
#define SearchBarTextFieldCornerRadius                  [QMUICMI searchBarTextFieldCornerRadius]


#pragma mark - TableView / TableViewCell

#define TableViewEstimatedHeightEnabled                 [QMUICMI tableViewEstimatedHeightEnabled]            // 是否要开启全局 UITableView 的 estimatedRow(Section/Footer)Height

#define TableViewBackgroundColor                        [QMUICMI tableViewBackgroundColor]                   // 普通列表的背景色
#define TableSectionIndexColor                          [QMUICMI tableSectionIndexColor]                     // 列表右边索引条的文字颜色
#define TableSectionIndexBackgroundColor                [QMUICMI tableSectionIndexBackgroundColor]           // 列表右边索引条的背景色
#define TableSectionIndexTrackingBackgroundColor        [QMUICMI tableSectionIndexTrackingBackgroundColor]   // 列表右边索引条按下时的背景色
#define TableViewSeparatorColor                         [QMUICMI tableViewSeparatorColor]                    // 列表分隔线颜色
#define TableViewCellBackgroundColor                    [QMUICMI tableViewCellBackgroundColor]               // 列表 cell 的背景色
#define TableViewCellSelectedBackgroundColor            [QMUICMI tableViewCellSelectedBackgroundColor]       // 列表 cell 按下时的背景色
#define TableViewCellWarningBackgroundColor             [QMUICMI tableViewCellWarningBackgroundColor]        // 列表 cell 在提醒状态下的背景色
#define TableViewCellNormalHeight                       [QMUICMI tableViewCellNormalHeight]                  // QMUITableView 的默认 cell 高度

#define TableViewCellDisclosureIndicatorImage           [QMUICMI tableViewCellDisclosureIndicatorImage]      // 列表 cell 右边的箭头图片
#define TableViewCellCheckmarkImage                     [QMUICMI tableViewCellCheckmarkImage]                // 列表 cell 右边的打钩checkmark
#define TableViewCellDetailButtonImage                  [QMUICMI tableViewCellDetailButtonImage]             // 列表 cell 右边的 i 按钮
#define TableViewCellSpacingBetweenDetailButtonAndDisclosureIndicator [QMUICMI tableViewCellSpacingBetweenDetailButtonAndDisclosureIndicator]   // 列表 cell 右边的 i 按钮和向右箭头之间的间距（仅当两者都使用了自定义图片并且同时显示时才生效）

#define TableViewSectionHeaderBackgroundColor           [QMUICMI tableViewSectionHeaderBackgroundColor]
#define TableViewSectionFooterBackgroundColor           [QMUICMI tableViewSectionFooterBackgroundColor]
#define TableViewSectionHeaderFont                      [QMUICMI tableViewSectionHeaderFont]
#define TableViewSectionFooterFont                      [QMUICMI tableViewSectionFooterFont]
#define TableViewSectionHeaderTextColor                 [QMUICMI tableViewSectionHeaderTextColor]
#define TableViewSectionFooterTextColor                 [QMUICMI tableViewSectionFooterTextColor]
#define TableViewSectionHeaderAccessoryMargins          [QMUICMI tableViewSectionHeaderAccessoryMargins]
#define TableViewSectionFooterAccessoryMargins          [QMUICMI tableViewSectionFooterAccessoryMargins]
#define TableViewSectionHeaderContentInset              [QMUICMI tableViewSectionHeaderContentInset]
#define TableViewSectionFooterContentInset              [QMUICMI tableViewSectionFooterContentInset]

#define TableViewGroupedBackgroundColor                 [QMUICMI tableViewGroupedBackgroundColor]               // Grouped 类型的 QMUITableView 的背景色
#define TableViewGroupedCellTitleLabelColor             [QMUICMI tableViewGroupedCellTitleLabelColor]           // Grouped 类型的列表的 QMUITableViewCell 的标题颜色
#define TableViewGroupedCellDetailLabelColor            [QMUICMI tableViewGroupedCellDetailLabelColor]          // Grouped 类型的列表的 QMUITableViewCell 的副标题颜色
#define TableViewGroupedCellBackgroundColor             [QMUICMI tableViewGroupedCellBackgroundColor]           // Grouped 类型的列表的 QMUITableViewCell 的背景色
#define TableViewGroupedCellSelectedBackgroundColor     [QMUICMI tableViewGroupedCellSelectedBackgroundColor]   // Grouped 类型的列表的 QMUITableViewCell 点击时的背景色
#define TableViewGroupedCellWarningBackgroundColor      [QMUICMI tableViewGroupedCellWarningBackgroundColor]    // Grouped 类型的列表的 QMUITableViewCell 在提醒状态下的背景色
#define TableViewGroupedSectionHeaderFont               [QMUICMI tableViewGroupedSectionHeaderFont]
#define TableViewGroupedSectionFooterFont               [QMUICMI tableViewGroupedSectionFooterFont]
#define TableViewGroupedSectionHeaderTextColor          [QMUICMI tableViewGroupedSectionHeaderTextColor]
#define TableViewGroupedSectionFooterTextColor          [QMUICMI tableViewGroupedSectionFooterTextColor]
#define TableViewGroupedSectionHeaderAccessoryMargins   [QMUICMI tableViewGroupedSectionHeaderAccessoryMargins]
#define TableViewGroupedSectionFooterAccessoryMargins   [QMUICMI tableViewGroupedSectionFooterAccessoryMargins]
#define TableViewGroupedSectionHeaderDefaultHeight      [QMUICMI tableViewGroupedSectionHeaderDefaultHeight]
#define TableViewGroupedSectionFooterDefaultHeight      [QMUICMI tableViewGroupedSectionFooterDefaultHeight]
#define TableViewGroupedSectionHeaderContentInset       [QMUICMI tableViewGroupedSectionHeaderContentInset]
#define TableViewGroupedSectionFooterContentInset       [QMUICMI tableViewGroupedSectionFooterContentInset]

#define TableViewCellTitleLabelColor                    [QMUICMI tableViewCellTitleLabelColor]               // cell的title颜色
#define TableViewCellDetailLabelColor                   [QMUICMI tableViewCellDetailLabelColor]              // cell的detailTitle颜色

#pragma mark - UIWindowLevel
#define UIWindowLevelQMUIAlertView                      [QMUICMI windowLevelQMUIAlertView]

#pragma mark - QMUILog
#define ShouldPrintDefaultLog                           [QMUICMI shouldPrintDefaultLog]
#define ShouldPrintInfoLog                              [QMUICMI shouldPrintInfoLog]
#define ShouldPrintWarnLog                              [QMUICMI shouldPrintWarnLog]

#pragma mark - QMUIBadge
#define BadgeBackgroundColor                            [QMUICMI badgeBackgroundColor]
#define BadgeTextColor                                  [QMUICMI badgeTextColor]
#define BadgeFont                                       [QMUICMI badgeFont]
#define BadgeContentEdgeInsets                          [QMUICMI badgeContentEdgeInsets]
#define BadgeCenterOffset                               [QMUICMI badgeCenterOffset]
#define BadgeCenterOffsetLandscape                      [QMUICMI badgeCenterOffsetLandscape]

#define UpdatesIndicatorColor                           [QMUICMI updatesIndicatorColor]
#define UpdatesIndicatorSize                            [QMUICMI updatesIndicatorSize]
#define UpdatesIndicatorCenterOffset                    [QMUICMI updatesIndicatorCenterOffset]
#define UpdatesIndicatorCenterOffsetLandscape           [QMUICMI updatesIndicatorCenterOffsetLandscape]

#pragma mark - Others

#define AutomaticCustomNavigationBarTransitionStyle [QMUICMI automaticCustomNavigationBarTransitionStyle] // 界面 push/pop 时是否要自动根据两个界面的 barTintColor/backgroundImage/shadowImage 的样式差异来决定是否使用自定义的导航栏效果
#define SupportedOrientationMask                        [QMUICMI supportedOrientationMask]          // 默认支持的横竖屏方向
#define AutomaticallyRotateDeviceOrientation            [QMUICMI automaticallyRotateDeviceOrientation]  // 是否在界面切换或 viewController.supportedOrientationMask 发生变化时自动旋转屏幕，默认为 NO
#define StatusbarStyleLightInitially                    [QMUICMI statusbarStyleLightInitially]      // 默认的状态栏内容是否使用白色，默认为NO，也即黑色
#define NeedsBackBarButtonItemTitle                     [QMUICMI needsBackBarButtonItemTitle]       // 全局是否需要返回按钮的title，不需要则只显示一个返回image
#define HidesBottomBarWhenPushedInitially               [QMUICMI hidesBottomBarWhenPushedInitially] // QMUICommonViewController.hidesBottomBarWhenPushed 的初始值，默认为 NO，以保持与系统默认值一致，但通常建议改为 YES，因为一般只有 tabBar 首页那几个界面要求为 NO
#define PreventConcurrentNavigationControllerTransitions [QMUICMI preventConcurrentNavigationControllerTransitions] // PreventConcurrentNavigationControllerTransitions : 自动保护 QMUINavigationController 在上一次 push/pop 尚未结束的时候就进行下一次 push/pop 的行为，避免产生 crash
#define NavigationBarHiddenInitially                    [QMUICMI navigationBarHiddenInitially]      // preferredNavigationBarHidden 的初始值，默认为NO
#define ShouldFixTabBarTransitionBugInIPhoneX           [QMUICMI shouldFixTabBarTransitionBugInIPhoneX] // 是否需要自动修复 iOS 11 下，iPhone X 的设备在 push 界面时，tabBar 会瞬间往上跳的 bug
#define ShouldFixTabBarButtonBugForAll                  [QMUICMI shouldFixTabBarButtonBugForAll] // 是否要对 iOS 12.1.2 及以后的版本也修复手势返回时 tabBarButton 布局错误的 bug(issue #410)，默认为 NO
#define ShouldPrintQMUIWarnLogToConsole                 [QMUICMI shouldPrintQMUIWarnLogToConsole] // 是否在出现 QMUILogWarn 时自动把这些 log 以 QMUIConsole 的方式显示到设备屏幕上
#define SendAnalyticsToQMUITeam                         [QMUICMI sendAnalyticsToQMUITeam] // 是否允许在 DEBUG 模式下上报 Bundle Identifier 和 Display Name 给 QMUI 统计用
#define DynamicPreferredValueForIPad                    [QMUICMI dynamicPreferredValueForIPad] // 当 iPad 处于 Slide Over 或 Split View 分屏模式下，宏 `PreferredValueForXXX` 是否把 iPad 视为某种屏幕宽度近似的 iPhone 来取值。
#define IgnoreKVCAccessProhibited                       [QMUICMI ignoreKVCAccessProhibited] // 是否全局忽略 iOS 13 对 KVC 访问 UIKit 私有属性的限制
#define AdjustScrollIndicatorInsetsByContentInsetAdjustment [QMUICMI adjustScrollIndicatorInsetsByContentInsetAdjustment] // 当将 UIScrollView.contentInsetAdjustmentBehavior 设为 UIScrollViewContentInsetAdjustmentNever 时，是否自动将 UIScrollView.automaticallyAdjustsScrollIndicatorInsets 设为 NO，以保证原本在 iOS 12 下的代码不用修改就能在 iOS 13 下正常控制滚动条的位置。

