//
//  QMUIConfigurationMacros.h
//  qmui
//
//  Created by QQMail on 14-7-2.
//  Copyright (c) 2014年 QMUI Team. All rights reserved.
//

#import "QMUIConfiguration.h"


/**
 *  提供一系列方便书写的宏，以便在代码里读取配置表的各种属性。
 *  @warning 请不要在 + load 方法里调用 QMUIConfigurationTemplate 或 QMUIConfigurationMacros 提供的宏，那个时机太早，可能导致 crash
 *  @waining 维护时，如果需要增加一个宏，则需要定义一个新的 QMUIConfiguration 属性。
 */


// 单例的宏

#define QMUICMI [QMUIConfiguration sharedInstance]


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

#define FillButtonColorBlue            [QMUICMI fillButtonColorBlue]              // QMUIFillButtonColorBlue的颜色
#define FillButtonColorRed             [QMUICMI fillButtonColorRed]               // QMUIFillButtonColorRed的颜色
#define FillButtonColorGreen           [QMUICMI fillButtonColorGreen]             // QMUIFillButtonColorGreen的颜色
#define FillButtonColorGray            [QMUICMI fillButtonColorGray]              // QMUIFillButtonColorGray的颜色
#define FillButtonColorWhite           [QMUICMI fillButtonColorWhite]             // QMUIFillButtonColorWhite的颜色

// 输入框
#pragma mark - TextField & TextView
#define TextFieldTintColor              [QMUICMI textFieldTintColor]               // 全局UITextField、UITextView的tintColor
#define TextFieldTextInsets             [QMUICMI textFieldTextInsets]              // QMUITextField的内边距


#pragma mark - NavigationBar

#define NavBarHighlightedAlpha                          [QMUICMI navBarHighlightedAlpha]
#define NavBarDisabledAlpha                             [QMUICMI navBarDisabledAlpha]
#define NavBarButtonFont                                [QMUICMI navBarButtonFont]
#define NavBarButtonFontBold                            [QMUICMI navBarButtonFontBold]
#define NavBarBackgroundImage                           [QMUICMI navBarBackgroundImage]
#define NavBarShadowImage                               [QMUICMI navBarShadowImage]
#define NavBarBarTintColor                              [QMUICMI navBarBarTintColor]
#define NavBarTintColor                                 [QMUICMI navBarTintColor]
#define NavBarTitleColor                                [QMUICMI navBarTitleColor]
#define NavBarTitleFont                                 [QMUICMI navBarTitleFont]
#define NavBarBarBackButtonTitlePositionAdjustment      [QMUICMI navBarBackButtonTitlePositionAdjustment]
#define NavBarBackIndicatorImage                        [QMUICMI navBarBackIndicatorImage]                          // 自定义的返回按钮，尺寸建议与系统的返回按钮尺寸一致（iOS8下实测系统大小是(13, 21)），可提高性能
#define NavBarCloseButtonImage                          [QMUICMI navBarCloseButtonImage]

#define NavBarLoadingMarginRight                        [QMUICMI navBarLoadingMarginRight]                          // titleView里左边的loading的右边距
#define NavBarAccessoryViewMarginLeft                   [QMUICMI navBarAccessoryViewMarginLeft]                     // titleView里的accessoryView的左边距
#define NavBarActivityIndicatorViewStyle                [QMUICMI navBarActivityIndicatorViewStyle]                  // titleView loading 的style
#define NavBarAccessoryViewTypeDisclosureIndicatorImage [QMUICMI navBarAccessoryViewTypeDisclosureIndicatorImage]   // titleView上倒三角的默认图片


#pragma mark - TabBar

#define TabBarBackgroundImage                           [QMUICMI tabBarBackgroundImage]
#define TabBarBarTintColor                              [QMUICMI tabBarBarTintColor]
#define TabBarShadowImageColor                          [QMUICMI tabBarShadowImageColor]
#define TabBarTintColor                                 [QMUICMI tabBarTintColor]
#define TabBarItemTitleColor                            [QMUICMI tabBarItemTitleColor]
#define TabBarItemTitleColorSelected                    [QMUICMI tabBarItemTitleColorSelected]
#define TabBarItemTitleFont                             [QMUICMI tabBarItemTitleFont]


#pragma mark - Toolbar

#define ToolBarHighlightedAlpha                         [QMUICMI toolBarHighlightedAlpha]
#define ToolBarDisabledAlpha                            [QMUICMI toolBarDisabledAlpha]
#define ToolBarTintColor                                [QMUICMI toolBarTintColor]
#define ToolBarTintColorHighlighted                     [QMUICMI toolBarTintColorHighlighted]
#define ToolBarTintColorDisabled                        [QMUICMI toolBarTintColorDisabled]
#define ToolBarBackgroundImage                          [QMUICMI toolBarBackgroundImage]
#define ToolBarBarTintColor                             [QMUICMI toolBarBarTintColor]
#define ToolBarShadowImageColor                         [QMUICMI toolBarShadowImageColor]
#define ToolBarButtonFont                               [QMUICMI toolBarButtonFont]


#pragma mark - SearchBar

#define SearchBarTextFieldBackground                    [QMUICMI searchBarTextFieldBackground]
#define SearchBarTextFieldBorderColor                   [QMUICMI searchBarTextFieldBorderColor]
#define SearchBarBottomBorderColor                      [QMUICMI searchBarBottomBorderColor]
#define SearchBarBarTintColor                           [QMUICMI searchBarBarTintColor]
#define SearchBarTintColor                              [QMUICMI searchBarTintColor]
#define SearchBarTextColor                              [QMUICMI searchBarTextColor]
#define SearchBarPlaceholderColor                       [QMUICMI searchBarPlaceholderColor]
#define SearchBarFont                                   [QMUICMI searchBarFont]
#define SearchBarSearchIconImage                        [QMUICMI searchBarSearchIconImage]
#define SearchBarClearIconImage                         [QMUICMI searchBarClearIconImage]
#define SearchBarTextFieldCornerRadius                  [QMUICMI searchBarTextFieldCornerRadius]


#pragma mark - TableView / TableViewCell

#define TableViewBackgroundColor                   [QMUICMI tableViewBackgroundColor]                   // 普通列表的背景色
#define TableViewGroupedBackgroundColor            [QMUICMI tableViewGroupedBackgroundColor]            // Grouped类型的列表的背景色
#define TableSectionIndexColor                     [QMUICMI tableSectionIndexColor]                     // 列表右边索引条的文字颜色，iOS6及以后生效
#define TableSectionIndexBackgroundColor           [QMUICMI tableSectionIndexBackgroundColor]           // 列表右边索引条的背景色，iOS7及以后生效
#define TableSectionIndexTrackingBackgroundColor   [QMUICMI tableSectionIndexTrackingBackgroundColor]   // 列表右边索引条按下时的背景色，iOS6及以后生效
#define TableViewSeparatorColor                    [QMUICMI tableViewSeparatorColor]                    // 列表分隔线颜色
#define TableViewCellBackgroundColor               [QMUICMI tableViewCellBackgroundColor]               // 列表 cell 的背景色
#define TableViewCellSelectedBackgroundColor       [QMUICMI tableViewCellSelectedBackgroundColor]       // 列表 cell 按下时的背景色
#define TableViewCellWarningBackgroundColor        [QMUICMI tableViewCellWarningBackgroundColor]        // 列表 cell 在未读状态下的背景色
#define TableViewCellNormalHeight                  [QMUICMI tableViewCellNormalHeight]                  // 默认 cell 的高度

#define TableViewCellDisclosureIndicatorImage      [QMUICMI tableViewCellDisclosureIndicatorImage]      // 列表 cell 右边的箭头图片
#define TableViewCellCheckmarkImage                [QMUICMI tableViewCellCheckmarkImage]                // 列表 cell 右边的打钩checkmark
#define TableViewCellDetailButtonImage             [QMUICMI tableViewCellDetailButtonImage]             // 列表 cell 右边的 i 按钮
#define TableViewCellSpacingBetweenDetailButtonAndDisclosureIndicator [QMUICMI tableViewCellSpacingBetweenDetailButtonAndDisclosureIndicator]   // 列表 cell 右边的 i 按钮和向右箭头之间的间距（仅当两者都使用了自定义图片并且同时显示时才生效）

#define TableViewSectionHeaderBackgroundColor      [QMUICMI tableViewSectionHeaderBackgroundColor]
#define TableViewSectionFooterBackgroundColor      [QMUICMI tableViewSectionFooterBackgroundColor]
#define TableViewSectionHeaderFont                 [QMUICMI tableViewSectionHeaderFont]
#define TableViewSectionFooterFont                 [QMUICMI tableViewSectionFooterFont]
#define TableViewSectionHeaderTextColor            [QMUICMI tableViewSectionHeaderTextColor]
#define TableViewSectionFooterTextColor            [QMUICMI tableViewSectionFooterTextColor]
#define TableViewSectionHeaderHeight               [QMUICMI tableViewSectionHeaderHeight]               // 列表sectionheader的高度
#define TableViewSectionFooterHeight               [QMUICMI tableViewSectionFooterHeight]               // 列表sectionheader的高度
#define TableViewSectionHeaderContentInset         [QMUICMI tableViewSectionHeaderContentInset]
#define TableViewSectionFooterContentInset         [QMUICMI tableViewSectionFooterContentInset]

#define TableViewGroupedSectionHeaderFont          [QMUICMI tableViewGroupedSectionHeaderFont]
#define TableViewGroupedSectionFooterFont          [QMUICMI tableViewGroupedSectionFooterFont]
#define TableViewGroupedSectionHeaderTextColor     [QMUICMI tableViewGroupedSectionHeaderTextColor]
#define TableViewGroupedSectionFooterTextColor     [QMUICMI tableViewGroupedSectionFooterTextColor]
#define TableViewGroupedSectionHeaderHeight        [QMUICMI tableViewGroupedSectionHeaderHeight]
#define TableViewGroupedSectionFooterHeight        [QMUICMI tableViewGroupedSectionFooterHeight]
#define TableViewGroupedSectionHeaderContentInset  [QMUICMI tableViewGroupedSectionHeaderContentInset]
#define TableViewGroupedSectionFooterContentInset  [QMUICMI tableViewGroupedSectionFooterContentInset]

#define TableViewCellTitleLabelColor               [QMUICMI tableViewCellTitleLabelColor]               //cell的title颜色
#define TableViewCellDetailLabelColor              [QMUICMI tableViewCellDetailLabelColor]              //cell的detailTitle颜色

#pragma mark - UIWindowLevel
#define UIWindowLevelQMUIAlertView                  [QMUICMI windowLevelQMUIAlertView]
#define UIWindowLevelQMUIImagePreviewView           [QMUICMI windowLevelQMUIImagePreviewView]

#pragma mark - Others

#define SupportedOrientationMask                        [QMUICMI supportedOrientationMask]          // 默认支持的横竖屏方向
#define AutomaticallyRotateDeviceOrientation            [QMUICMI automaticallyRotateDeviceOrientation]  // 是否在界面切换或 viewController.supportedOrientationMask 发生变化时自动旋转屏幕，默认为 NO
#define StatusbarStyleLightInitially                    [QMUICMI statusbarStyleLightInitially]      // 默认的状态栏内容是否使用白色，默认为NO，也即黑色
#define NeedsBackBarButtonItemTitle                     [QMUICMI needsBackBarButtonItemTitle]       // 全局是否需要返回按钮的title，不需要则只显示一个返回image
#define HidesBottomBarWhenPushedInitially               [QMUICMI hidesBottomBarWhenPushedInitially] // QMUICommonViewController.hidesBottomBarWhenPushed 的初始值，默认为 NO，以保持与系统默认值一致，但通常建议改为 YES，因为一般只有 tabBar 首页那几个界面要求为 NO
#define NavigationBarHiddenInitially                    [QMUICMI navigationBarHiddenInitially]      // NavigationBarHiddenInitially : preferredNavigationBarHidden 的初始值，默认为NO

