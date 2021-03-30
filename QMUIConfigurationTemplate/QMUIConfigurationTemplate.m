/**
 * Tencent is pleased to support the open source community by making QMUI_iOS available.
 * Copyright (C) 2016-2021 THL A29 Limited, a Tencent company. All rights reserved.
 * Licensed under the MIT License (the "License"); you may not use this file except in compliance with the License. You may obtain a copy of the License at
 * http://opensource.org/licenses/MIT
 * Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.
 */

//
//  QMUIConfigurationTemplate.m
//  qmui
//
//  Created by QMUI Team on 15/3/29.
//

#import "QMUIConfigurationTemplate.h"
#import <QMUIKit/QMUIKit.h>

@implementation QMUIConfigurationTemplate

#pragma mark - <QMUIConfigurationTemplateProtocol>

- (void)applyConfigurationTemplate {
    
    // === 修改配置值 === //
    
    #pragma mark - Global Color
    
    QMUICMI.clearColor = UIColorMakeWithRGBA(255, 255, 255, 0);                 // UIColorClear : 透明色
    QMUICMI.whiteColor = UIColorMake(255, 255, 255);                            // UIColorWhite : 白色（不用 [UIColor whiteColor] 是希望保持颜色空间为 RGB）
    QMUICMI.blackColor = UIColorMake(0, 0, 0);                                  // UIColorBlack : 黑色（不用 [UIColor blackColor] 是希望保持颜色空间为 RGB）
    QMUICMI.grayColor = UIColorMake(179, 179, 179);                             // UIColorGray  : 最常用的灰色
    QMUICMI.grayDarkenColor = UIColorMake(163, 163, 163);                       // UIColorGrayDarken : 深一点的灰色
    QMUICMI.grayLightenColor = UIColorMake(198, 198, 198);                      // UIColorGrayLighten : 浅一点的灰色
    QMUICMI.redColor = UIColorMake(250, 58, 58);                                // UIColorRed : 红色
    QMUICMI.greenColor = UIColorMake(159, 214, 97);                             // UIColorGreen : 绿色
    QMUICMI.blueColor = UIColorMake(49, 189, 243);                              // UIColorBlue : 蓝色
    QMUICMI.yellowColor = UIColorMake(255, 207, 71);                            // UIColorYellow : 黄色
    
    QMUICMI.linkColor = UIColorMake(56, 116, 171);                              // UIColorLink : 文字链接颜色
    QMUICMI.disabledColor = UIColorGray;                                        // UIColorDisabled : 全局 disabled 的颜色，一般用于 UIControl 等控件
    QMUICMI.backgroundColor = nil;                                              // UIColorForBackground : 界面背景色，默认用于 QMUICommonViewController.view 的背景色
    QMUICMI.maskDarkColor = UIColorMakeWithRGBA(0, 0, 0, .35f);                 // UIColorMask : 深色的背景遮罩，默认用于 QMAlertController、QMUIDialogViewController 等弹出控件的遮罩
    QMUICMI.maskLightColor = UIColorMakeWithRGBA(255, 255, 255, .5f);           // UIColorMaskWhite : 浅色的背景遮罩，QMUIKit 里默认没用到，只是占个位
    QMUICMI.separatorColor = UIColorMake(222, 224, 226);                        // UIColorSeparator : 全局默认的分割线颜色，默认用于列表分隔线颜色、UIView (QMUIBorder) 分隔线颜色
    QMUICMI.separatorDashedColor = UIColorMake(17, 17, 17);                     // UIColorSeparatorDashed : 全局默认的虚线分隔线的颜色，默认 QMUIKit 暂时没用到
    QMUICMI.placeholderColor = UIColorMake(196, 200, 208);                      // UIColorPlaceholder，全局的输入框的 placeholder 颜色，默认用于 QMUITextField、QMUITextView，不影响系统 UIKit 的输入框
    
    // 测试用的颜色
    QMUICMI.testColorRed = UIColorMakeWithRGBA(255, 0, 0, .3);
    QMUICMI.testColorGreen = UIColorMakeWithRGBA(0, 255, 0, .3);
    QMUICMI.testColorBlue = UIColorMakeWithRGBA(0, 0, 255, .3);
    
    
    #pragma mark - UIControl
    
    QMUICMI.controlHighlightedAlpha = 0.5f;                                     // UIControlHighlightedAlpha : UIControl 系列控件在 highlighted 时的 alpha，默认用于 QMUIButton、 QMUINavigationTitleView
    QMUICMI.controlDisabledAlpha = 0.5f;                                        // UIControlDisabledAlpha : UIControl 系列控件在 disabled 时的 alpha，默认用于 QMUIButton
    
    #pragma mark - UIButton
    QMUICMI.buttonHighlightedAlpha = UIControlHighlightedAlpha;                 // ButtonHighlightedAlpha : QMUIButton 在 highlighted 时的 alpha，不影响系统的 UIButton
    QMUICMI.buttonDisabledAlpha = UIControlDisabledAlpha;                       // ButtonDisabledAlpha : QMUIButton 在 disabled 时的 alpha，不影响系统的 UIButton
    QMUICMI.buttonTintColor = UIColorBlue;                                      // ButtonTintColor : QMUIButton 默认的 tintColor，不影响系统的 UIButton
    
    QMUICMI.ghostButtonColorBlue = UIColorBlue;                                 // GhostButtonColorBlue : QMUIGhostButtonColorBlue 的颜色
    QMUICMI.ghostButtonColorRed = UIColorRed;                                   // GhostButtonColorRed : QMUIGhostButtonColorRed 的颜色
    QMUICMI.ghostButtonColorGreen = UIColorGreen;                               // GhostButtonColorGreen : QMUIGhostButtonColorGreen 的颜色
    QMUICMI.ghostButtonColorGray = UIColorGray;                                 // GhostButtonColorGray : QMUIGhostButtonColorGray 的颜色
    QMUICMI.ghostButtonColorWhite = UIColorWhite;                               // GhostButtonColorWhite : QMUIGhostButtonColorWhite 的颜色
    
    QMUICMI.fillButtonColorBlue = UIColorBlue;                                  // FillButtonColorBlue : QMUIFillButtonColorBlue 的颜色
    QMUICMI.fillButtonColorRed = UIColorRed;                                    // FillButtonColorRed : QMUIFillButtonColorRed 的颜色
    QMUICMI.fillButtonColorGreen = UIColorGreen;                                // FillButtonColorGreen : QMUIFillButtonColorGreen 的颜色
    QMUICMI.fillButtonColorGray = UIColorGray;                                  // FillButtonColorGray : QMUIFillButtonColorGray 的颜色
    QMUICMI.fillButtonColorWhite = UIColorWhite;                                // FillButtonColorWhite : QMUIFillButtonColorWhite 的颜色
    
    #pragma mark - TextInput
    QMUICMI.textFieldTextColor = nil;                                           // TextFieldTextColor : QMUITextField、QMUITextView 的 textColor，不影响 UIKit 的输入框
    QMUICMI.textFieldTintColor = nil;                                           // TextFieldTintColor : QMUITextField、QMUITextView 的 tintColor，不影响 UIKit 的输入框
    QMUICMI.textFieldTextInsets = UIEdgeInsetsMake(0, 7, 0, 7);                 // TextFieldTextInsets : QMUITextField 的内边距，不影响 UITextField
    QMUICMI.keyboardAppearance = UIKeyboardAppearanceDefault;                   // KeyboardAppearance : UITextView、UITextField、UISearchBar 的 keyboardAppearance
    
    #pragma mark - UISwitch
    QMUICMI.switchOnTintColor = nil;                                            // SwitchOnTintColor : UISwitch 打开时的背景色（除了圆点外的其他颜色）
    QMUICMI.switchOffTintColor = nil;                                           // SwitchOffTintColor : UISwitch 关闭时的背景色（除了圆点外的其他颜色）
    QMUICMI.switchTintColor = nil;                                              // SwitchTintColor : UISwitch 关闭时的周围边框颜色
    QMUICMI.switchThumbTintColor = nil;                                         // SwitchThumbTintColor : UISwitch 中间的操控圆点的颜色
    
    #pragma mark - NavigationBar
    
    QMUICMI.navBarContainerClasses = nil;                                       // NavBarContainerClasses : NavigationBar 系列开关被用于 UIAppearance 时的生效范围（默认情况下除了用于 UIAppearance 外，还用于实现了 QMUINavigationControllerAppearanceDelegate 的 UIViewController），默认为 nil。当赋值为 nil 或者空数组时等效于 @[UINavigationController.class]，也即对所有 UINavigationBar 生效，包括系统的通讯录（ContactsUI.framework)、打印等。当值不为空时，获取 UINavigationBar 的 appearance 请使用 UINavigationBar.qmui_appearanceConfigured 方法代替系统的 UINavigationBar.appearance。请保证这个配置项先于其他任意 NavBar 配置项执行。
    QMUICMI.navBarHighlightedAlpha = 0.2f;                                      // NavBarHighlightedAlpha : QMUINavigationButton 在 highlighted 时的 alpha
    QMUICMI.navBarDisabledAlpha = 0.2f;                                         // NavBarDisabledAlpha : QMUINavigationButton 在 disabled 时的 alpha
    QMUICMI.navBarButtonFont = nil;                                             // NavBarButtonFont : QMUINavigationButtonTypeNormal 和 UINavigationBar 上的 UIBarButtonItem 的字体
    QMUICMI.navBarButtonFontBold = nil;                                         // NavBarButtonFontBold : QMUINavigationButtonTypeBold 的字体
    QMUICMI.navBarBackgroundImage = nil;                                        // NavBarBackgroundImage : UINavigationBar 的背景图
    QMUICMI.navBarShadowImage = nil;                                            // NavBarShadowImage : UINavigationBar.shadowImage，也即导航栏底部那条分隔线，配合 NavBarShadowImageColor 使用。
    QMUICMI.navBarShadowImageColor = nil;                                       // NavBarShadowImageColor : UINavigationBar.shadowImage 的颜色，如果为 nil，则使用 NavBarShadowImage 的值，如果 NavBarShadowImage 也为 nil，则使用系统默认的分隔线。如果不为 nil，而 NavBarShadowImage 为 nil，则自动创建一张 1px 高的图并将其设置为 NavBarShadowImageColor 的颜色然后设置上去，如果 NavBarShadowImage 不为 nil 且 renderingMode 不为 UIImageRenderingModeAlwaysOriginal，则将 NavBarShadowImage 设置为 NavBarShadowImageColor 的颜色然后设置上去。
    QMUICMI.navBarBarTintColor = nil;                                           // NavBarBarTintColor : UINavigationBar.barTintColor，也即背景色
    QMUICMI.navBarStyle = UIBarStyleDefault;                                    // NavBarStyle : UINavigationBar 的 barStyle
    QMUICMI.navBarTintColor = nil;                                              // NavBarTintColor : NavBarContainerClasses 里的 UINavigationBar 的 tintColor，也即导航栏上面的按钮颜色
    QMUICMI.navBarTitleColor = nil;                                             // NavBarTitleColor : UINavigationBar 的标题颜色，以及 QMUINavigationTitleView 的默认文字颜色
    QMUICMI.navBarTitleFont = nil;                                              // NavBarTitleFont : UINavigationBar 的标题字体，以及 QMUINavigationTitleView 的默认字体
    QMUICMI.navBarLargeTitleColor = nil;                                        // NavBarLargeTitleColor : UINavigationBar 在大标题模式下的标题颜色，仅在 iOS 11 之后才有效
    QMUICMI.navBarLargeTitleFont = nil;                                         // NavBarLargeTitleFont : UINavigationBar 在大标题模式下的标题字体，仅在 iOS 11 之后才有效
    QMUICMI.navBarBackButtonTitlePositionAdjustment = UIOffsetZero;             // NavBarBarBackButtonTitlePositionAdjustment : 导航栏返回按钮的文字偏移
    QMUICMI.sizeNavBarBackIndicatorImageAutomatically = YES;                    // SizeNavBarBackIndicatorImageAutomatically : 是否要自动调整 NavBarBackIndicatorImage 的 size 为 (13, 21)
    QMUICMI.navBarBackIndicatorImage = nil;                                     // NavBarBackIndicatorImage : 导航栏的返回按钮的图片，图片尺寸建议为(13, 21)，否则最终的图片位置无法与系统原生的位置保持一致
    QMUICMI.navBarCloseButtonImage = [UIImage qmui_imageWithShape:QMUIImageShapeNavClose size:CGSizeMake(16, 16) tintColor:NavBarTintColor];     // NavBarCloseButtonImage : QMUINavigationButton 用到的 × 的按钮图片
    
    QMUICMI.navBarLoadingMarginRight = 3;                                       // NavBarLoadingMarginRight : QMUINavigationTitleView 里左边 loading 的右边距
    QMUICMI.navBarAccessoryViewMarginLeft = 5;                                  // NavBarAccessoryViewMarginLeft : QMUINavigationTitleView 里右边 accessoryView 的左边距
    QMUICMI.navBarActivityIndicatorViewStyle = UIActivityIndicatorViewStyleGray;// NavBarActivityIndicatorViewStyle : QMUINavigationTitleView 里左边 loading 的主题
    QMUICMI.navBarAccessoryViewTypeDisclosureIndicatorImage = [[UIImage qmui_imageWithShape:QMUIImageShapeTriangle size:CGSizeMake(8, 5) tintColor:nil] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];     // NavBarAccessoryViewTypeDisclosureIndicatorImage : QMUINavigationTitleView 右边箭头的图片
    
    #pragma mark - TabBar
    
    QMUICMI.tabBarContainerClasses = nil;                                       // TabBarContainerClasses : TabBar 系列开关的生效范围，默认为 nil，当赋值为 nil 或者空数组时等效于 @[UITabBarController.class]，也即对所有 UITabBar 生效。当值不为空时，获取 UITabBar 的 appearance 请使用 UITabBar.qmui_appearanceConfigured 方法代替系统的 UITabBar.appearance。请保证这个配置项先于其他任意 TabBar 配置项执行。
    QMUICMI.tabBarBackgroundImage = nil;                                        // TabBarBackgroundImage : UITabBar 的背景图
    QMUICMI.tabBarBarTintColor = nil;                                           // TabBarBarTintColor : UITabBar 的 barTintColor，如果需要看到磨砂效果则应该提供半透明的色值
    QMUICMI.tabBarShadowImageColor = nil;                                       // TabBarShadowImageColor : UITabBar 的 shadowImage 的颜色，会自动创建一张 1px 高的图片
    QMUICMI.tabBarStyle = UIBarStyleDefault;                                    // TabBarStyle : UITabBar 的 barStyle
    QMUICMI.tabBarItemTitleFont = nil;                                          // TabBarItemTitleFont : UITabBarItem 的标题字体
    QMUICMI.tabBarItemTitleFontSelected = nil;                                  // TabBarItemTitleFontSelected : 选中的 UITabBarItem 的标题字体
    QMUICMI.tabBarItemTitleColor = nil;                                         // TabBarItemTitleColor : 未选中的 UITabBarItem 的标题颜色
    QMUICMI.tabBarItemTitleColorSelected = nil;                                 // TabBarItemTitleColorSelected : 选中的 UITabBarItem 的标题颜色
    QMUICMI.tabBarItemImageColor = nil;                                         // TabBarItemImageColor : UITabBarItem 未选中时的图片颜色
    QMUICMI.tabBarItemImageColorSelected = nil;                                 // TabBarItemImageColorSelected : UITabBarItem 选中时的图片颜色
    
    #pragma mark - Toolbar
    
    QMUICMI.toolBarContainerClasses = nil;                                      // ToolBarContainerClasses : ToolBar 系列开关的生效范围，默认为 nil，当赋值为 nil 或者空数组时等效于 @[UINavigationController.class]，也即对所有 UIToolbar 生效。当值不为空时，获取 UIToolbar 的 appearance 请使用 UIToolbar.qmui_appearanceConfigured 方法代替系统的 UIToolbar.appearance。请保证这个配置项先于其他任意 ToolBar 配置项执行。
    QMUICMI.toolBarHighlightedAlpha = 0.4f;                                     // ToolBarHighlightedAlpha : QMUIToolbarButton 在 highlighted 状态下的 alpha
    QMUICMI.toolBarDisabledAlpha = 0.4f;                                        // ToolBarDisabledAlpha : QMUIToolbarButton 在 disabled 状态下的 alpha
    QMUICMI.toolBarTintColor = nil;                                             // ToolBarTintColor : NavBarContainerClasses 里的 UIToolbar 的 tintColor，以及 QMUIToolbarButton normal 状态下的文字颜色
    QMUICMI.toolBarTintColorHighlighted = [ToolBarTintColor colorWithAlphaComponent:ToolBarHighlightedAlpha];   // ToolBarTintColorHighlighted : QMUIToolbarButton 在 highlighted 状态下的文字颜色
    QMUICMI.toolBarTintColorDisabled = [ToolBarTintColor colorWithAlphaComponent:ToolBarDisabledAlpha];         // ToolBarTintColorDisabled : QMUIToolbarButton 在 disabled 状态下的文字颜色
    QMUICMI.toolBarBackgroundImage = nil;                                       // ToolBarBackgroundImage : NavBarContainerClasses 里的 UIToolbar 的背景图
    QMUICMI.toolBarBarTintColor = nil;                                          // ToolBarBarTintColor : NavBarContainerClasses 里的 UIToolbar 的 tintColor
    QMUICMI.toolBarShadowImageColor = nil;                                      // ToolBarShadowImageColor : NavBarContainerClasses 里的 UIToolbar 的 shadowImage 的颜色，会自动创建一张 1px 高的图片
    QMUICMI.toolBarStyle = UIBarStyleDefault;                                   // ToolBarStyle : NavBarContainerClasses 里的 UIToolbar 的 barStyle
    QMUICMI.toolBarButtonFont = nil;                                            // ToolBarButtonFont : QMUIToolbarButton 的字体
    
    #pragma mark - SearchBar
    
    QMUICMI.searchBarTextFieldBackgroundImage = nil;                            // SearchBarTextFieldBackgroundImage : QMUISearchBar 里的文本框的背景图，图片高度会决定输入框的高度
    QMUICMI.searchBarTextFieldBorderColor = nil;                                // SearchBarTextFieldBorderColor : QMUISearchBar 里的文本框的边框颜色
    QMUICMI.searchBarTextFieldCornerRadius = 2.0;                               // SearchBarTextFieldCornerRadius : QMUISearchBar 里的文本框的圆角大小，-1 表示圆角大小为输入框高度的一半
    QMUICMI.searchBarBackgroundImage = nil;                                     // SearchBarBackgroundImage : 搜索框的背景图，如果需要设置底部分隔线的颜色也请绘制到图片里
    QMUICMI.searchBarTintColor = nil;                                           // SearchBarTintColor : QMUISearchBar 的 tintColor，也即上面的操作控件的主题色
    QMUICMI.searchBarTextColor = nil;                                           // SearchBarTextColor : QMUISearchBar 里的文本框的文字颜色
    QMUICMI.searchBarPlaceholderColor = UIColorPlaceholder;                     // SearchBarPlaceholderColor : QMUISearchBar 里的文本框的 placeholder 颜色
    QMUICMI.searchBarFont = nil;                                                // SearchBarFont : QMUISearchBar 里的文本框的文字字体及 placeholder 的字体
    QMUICMI.searchBarSearchIconImage = nil;                                     // SearchBarSearchIconImage : QMUISearchBar 里的放大镜 icon
    QMUICMI.searchBarClearIconImage = nil;                                      // SearchBarClearIconImage : QMUISearchBar 里的文本框输入文字时右边的清空按钮的图片
    
    #pragma mark - Plain TableView
    
    QMUICMI.tableViewEstimatedHeightEnabled = YES;                              // TableViewEstimatedHeightEnabled : 是否要开启全局 UITableView 的 estimatedRow(Section/Footer)Height
    
    QMUICMI.tableViewBackgroundColor = nil;                                     // TableViewBackgroundColor : Plain 类型的 QMUITableView 的背景色颜色
    QMUICMI.tableSectionIndexColor = nil;                                       // TableSectionIndexColor : 列表右边的字母索引条的文字颜色
    QMUICMI.tableSectionIndexBackgroundColor = nil;                             // TableSectionIndexBackgroundColor : 列表右边的字母索引条的背景色
    QMUICMI.tableSectionIndexTrackingBackgroundColor = nil;                     // TableSectionIndexTrackingBackgroundColor : 列表右边的字母索引条在选中时的背景色
    QMUICMI.tableViewSeparatorColor = UIColorSeparator;                         // TableViewSeparatorColor : 列表的分隔线颜色
    
    QMUICMI.tableViewCellNormalHeight = UITableViewAutomaticDimension;          // TableViewCellNormalHeight : QMUITableView 的默认 cell 高度
    QMUICMI.tableViewCellTitleLabelColor = nil;                                 // TableViewCellTitleLabelColor : QMUITableViewCell 的 textLabel 的文字颜色
    QMUICMI.tableViewCellDetailLabelColor = nil;                                // TableViewCellDetailLabelColor : QMUITableViewCell 的 detailTextLabel 的文字颜色
    QMUICMI.tableViewCellBackgroundColor = nil;                                 // TableViewCellBackgroundColor : QMUITableViewCell 的背景色
    QMUICMI.tableViewCellSelectedBackgroundColor = UIColorMake(238, 239, 241);  // TableViewCellSelectedBackgroundColor : QMUITableViewCell 点击时的背景色
    QMUICMI.tableViewCellWarningBackgroundColor = UIColorYellow;                // TableViewCellWarningBackgroundColor : QMUITableViewCell 用于表示警告时的背景色，备用
    QMUICMI.tableViewCellDisclosureIndicatorImage = nil;                        // TableViewCellDisclosureIndicatorImage : QMUITableViewCell 当 accessoryType 为 UITableViewCellAccessoryDisclosureIndicator 时的箭头的图片
    QMUICMI.tableViewCellCheckmarkImage = nil;                                  // TableViewCellCheckmarkImage : QMUITableViewCell 当 accessoryType 为 UITableViewCellAccessoryCheckmark 时的打钩的图片
    QMUICMI.tableViewCellDetailButtonImage = nil; // TableViewCellDetailButtonImage : QMUITableViewCell 当 accessoryType 为 UITableViewCellAccessoryDetailButton 或 UITableViewCellAccessoryDetailDisclosureButton 时右边的 i 按钮图片
    QMUICMI.tableViewCellSpacingBetweenDetailButtonAndDisclosureIndicator = 12; // TableViewCellSpacingBetweenDetailButtonAndDisclosureIndicator : 列表 cell 右边的 i 按钮和向右箭头之间的间距（仅当两者都使用了自定义图片并且同时显示时才生效）
    
    QMUICMI.tableViewSectionHeaderBackgroundColor = UIColorMake(244, 244, 244);                         // TableViewSectionHeaderBackgroundColor : Plain 类型的 QMUITableView sectionHeader 的背景色
    QMUICMI.tableViewSectionFooterBackgroundColor = UIColorMake(244, 244, 244);                         // TableViewSectionFooterBackgroundColor : Plain 类型的 QMUITableView sectionFooter 的背景色
    QMUICMI.tableViewSectionHeaderFont = UIFontBoldMake(12);                                            // TableViewSectionHeaderFont : Plain 类型的 QMUITableView sectionHeader 里的文字字体
    QMUICMI.tableViewSectionFooterFont = UIFontBoldMake(12);                                            // TableViewSectionFooterFont : Plain 类型的 QMUITableView sectionFooter 里的文字字体
    QMUICMI.tableViewSectionHeaderTextColor = UIColorGrayDarken;                                        // TableViewSectionHeaderTextColor : Plain 类型的 QMUITableView sectionHeader 里的文字颜色
    QMUICMI.tableViewSectionFooterTextColor = UIColorGray;                                              // TableViewSectionFooterTextColor : Plain 类型的 QMUITableView sectionFooter 里的文字颜色
    QMUICMI.tableViewSectionHeaderAccessoryMargins = UIEdgeInsetsMake(0, 15, 0, 0);                     // TableViewSectionHeaderAccessoryMargins : Plain 类型的 QMUITableView sectionHeader accessoryView 的间距
    QMUICMI.tableViewSectionFooterAccessoryMargins = UIEdgeInsetsMake(0, 15, 0, 0);                     // TableViewSectionFooterAccessoryMargins : Plain 类型的 QMUITableView sectionFooter accessoryView 的间距
    QMUICMI.tableViewSectionHeaderContentInset = UIEdgeInsetsMake(4, 15, 4, 15);                        // TableViewSectionHeaderContentInset : Plain 类型的 QMUITableView sectionHeader 里的内容的 padding
    QMUICMI.tableViewSectionFooterContentInset = UIEdgeInsetsMake(4, 15, 4, 15);                        // TableViewSectionFooterContentInset : Plain 类型的 QMUITableView sectionFooter 里的内容的 padding
    
    #pragma mark - Grouped TableView
    QMUICMI.tableViewGroupedBackgroundColor = nil;                                                      // TableViewGroupedBackgroundColor : Grouped 类型的 QMUITableView 的背景色
    QMUICMI.tableViewGroupedSeparatorColor = TableViewSeparatorColor;                                   // TableViewGroupedSeparatorColor : Grouped 类型的 QMUITableView 分隔线颜色
    QMUICMI.tableViewGroupedCellTitleLabelColor = TableViewCellTitleLabelColor;                         // TableViewGroupedCellTitleLabelColor : Grouped 类型的 QMUITableView cell 里的标题颜色
    QMUICMI.tableViewGroupedCellDetailLabelColor = TableViewCellDetailLabelColor;                       // TableViewGroupedCellDetailLabelColor : Grouped 类型的 QMUITableView cell 里的副标题颜色
    QMUICMI.tableViewGroupedCellBackgroundColor = TableViewCellBackgroundColor;                         // TableViewGroupedCellBackgroundColor : Grouped 类型的 QMUITableView cell 背景色
    QMUICMI.tableViewGroupedCellSelectedBackgroundColor = TableViewCellSelectedBackgroundColor;         // TableViewGroupedCellSelectedBackgroundColor : Grouped 类型的 QMUITableView cell 点击时的背景色
    QMUICMI.tableViewGroupedCellWarningBackgroundColor = TableViewCellWarningBackgroundColor;           // tableViewGroupedCellWarningBackgroundColor : Grouped 类型的 QMUITableView cell 在提醒状态下的背景色
    QMUICMI.tableViewGroupedSectionHeaderFont = UIFontMake(12);                                         // TableViewGroupedSectionHeaderFont : Grouped 类型的 QMUITableView sectionHeader 里的文字字体
    QMUICMI.tableViewGroupedSectionFooterFont = UIFontMake(12);                                         // TableViewGroupedSectionFooterFont : Grouped 类型的 QMUITableView sectionFooter 里的文字字体
    QMUICMI.tableViewGroupedSectionHeaderTextColor = UIColorGrayDarken;                                 // TableViewGroupedSectionHeaderTextColor : Grouped 类型的 QMUITableView sectionHeader 里的文字颜色
    QMUICMI.tableViewGroupedSectionFooterTextColor = UIColorGray;                                       // TableViewGroupedSectionFooterTextColor : Grouped 类型的 QMUITableView sectionFooter 里的文字颜色
    QMUICMI.tableViewGroupedSectionHeaderAccessoryMargins = UIEdgeInsetsMake(0, 15, 0, 0);                     // TableViewGroupedSectionHeaderAccessoryMargins : Grouped 类型的 QMUITableView sectionHeader accessoryView 的间距
    QMUICMI.tableViewGroupedSectionFooterAccessoryMargins = UIEdgeInsetsMake(0, 15, 0, 0);                     // TableViewGroupedSectionFooterAccessoryMargins : Grouped 类型的 QMUITableView sectionFooter accessoryView 的间距
    QMUICMI.tableViewGroupedSectionHeaderDefaultHeight = UITableViewAutomaticDimension;                 // TableViewGroupedSectionHeaderDefaultHeight : Grouped 类型的 QMUITableView sectionHeader 的默认高度（也即没使用自定义的 sectionHeaderView 时的高度），注意如果不需要间距，请用 CGFLOAT_MIN
    QMUICMI.tableViewGroupedSectionFooterDefaultHeight = UITableViewAutomaticDimension;                 // TableViewGroupedSectionFooterDefaultHeight : Grouped 类型的 QMUITableView sectionFooter 的默认高度（也即没使用自定义的 sectionFooterView 时的高度），注意如果不需要间距，请用 CGFLOAT_MIN
    QMUICMI.tableViewGroupedSectionHeaderContentInset = UIEdgeInsetsMake(16, 15, 8, 15);                // TableViewGroupedSectionHeaderContentInset : Grouped 类型的 QMUITableView sectionHeader 里的内容的 padding
    QMUICMI.tableViewGroupedSectionFooterContentInset = UIEdgeInsetsMake(8, 15, 2, 15);                 // TableViewGroupedSectionFooterContentInset : Grouped 类型的 QMUITableView sectionFooter 里的内容的 padding
    
    #pragma mark - InsetGrouped TableView
    QMUICMI.tableViewInsetGroupedCornerRadius = 10;                                                     // TableViewInsetGroupedCornerRadius : InsetGrouped 类型的 UITableView 内 cell 的圆角值
    QMUICMI.tableViewInsetGroupedHorizontalInset = PreferredValueForVisualDevice(20, 15);               // TableViewInsetGroupedHorizontalInset: InsetGrouped 类型的 UITableView 内的左右缩进值
    QMUICMI.tableViewInsetGroupedBackgroundColor = TableViewGroupedBackgroundColor;                                                 // TableViewInsetGroupedBackgroundColor : InsetGrouped 类型的 UITableView 的背景色
    QMUICMI.tableViewInsetGroupedSeparatorColor = TableViewGroupedSeparatorColor;                                   // TableViewInsetGroupedSeparatorColor : InsetGrouped 类型的 QMUITableView 分隔线颜色
    QMUICMI.tableViewInsetGroupedCellTitleLabelColor = TableViewGroupedCellTitleLabelColor;                         // TableViewInsetGroupedCellTitleLabelColor : InsetGrouped 类型的 QMUITableView cell 里的标题颜色
    QMUICMI.tableViewInsetGroupedCellDetailLabelColor = TableViewGroupedCellDetailLabelColor;                       // TableViewInsetGroupedCellDetailLabelColor : InsetGrouped 类型的 QMUITableView cell 里的副标题颜色
    QMUICMI.tableViewInsetGroupedCellBackgroundColor = TableViewGroupedCellBackgroundColor;                         // TableViewInsetGroupedCellBackgroundColor : InsetGrouped 类型的 QMUITableView cell 背景色
    QMUICMI.tableViewInsetGroupedCellSelectedBackgroundColor = TableViewGroupedCellSelectedBackgroundColor;         // TableViewInsetGroupedCellSelectedBackgroundColor : InsetGrouped 类型的 QMUITableView cell 点击时的背景色
    QMUICMI.tableViewInsetGroupedCellWarningBackgroundColor = TableViewGroupedCellWarningBackgroundColor;           // TableViewInsetGroupedCellWarningBackgroundColor : InsetGrouped 类型的 QMUITableView cell 在提醒状态下的背景色
    QMUICMI.tableViewInsetGroupedSectionHeaderFont = TableViewGroupedSectionHeaderFont;                                         // TableViewInsetGroupedSectionHeaderFont : InsetGrouped 类型的 QMUITableView sectionHeader 里的文字字体
    QMUICMI.tableViewInsetGroupedSectionFooterFont = TableViewInsetGroupedSectionHeaderFont;                                         // TableViewInsetGroupedSectionFooterFont : InsetGrouped 类型的 QMUITableView sectionFooter 里的文字字体
    QMUICMI.tableViewInsetGroupedSectionHeaderTextColor = TableViewGroupedSectionHeaderTextColor;                                 // TableViewInsetGroupedSectionHeaderTextColor : InsetGrouped 类型的 QMUITableView sectionHeader 里的文字颜色
    QMUICMI.tableViewInsetGroupedSectionFooterTextColor = TableViewInsetGroupedSectionHeaderTextColor;                                       // TableViewInsetGroupedSectionFooterTextColor : InsetGrouped 类型的 QMUITableView sectionFooter 里的文字颜色
    QMUICMI.tableViewInsetGroupedSectionHeaderAccessoryMargins = TableViewGroupedSectionHeaderAccessoryMargins;                     // TableViewInsetGroupedSectionHeaderAccessoryMargins : InsetGrouped 类型的 QMUITableView sectionHeader accessoryView 的间距
    QMUICMI.tableViewInsetGroupedSectionFooterAccessoryMargins = TableViewInsetGroupedSectionHeaderAccessoryMargins;                     // TableViewInsetGroupedSectionFooterAccessoryMargins : InsetGrouped 类型的 QMUITableView sectionFooter accessoryView 的间距
    QMUICMI.tableViewInsetGroupedSectionHeaderDefaultHeight = TableViewGroupedSectionHeaderDefaultHeight;                 // TableViewInsetGroupedSectionHeaderDefaultHeight : InsetGrouped 类型的 QMUITableView sectionHeader 的默认高度（也即没使用自定义的 sectionHeaderView 时的高度），注意如果不需要间距，请用 CGFLOAT_MIN
    QMUICMI.tableViewInsetGroupedSectionFooterDefaultHeight = TableViewGroupedSectionFooterDefaultHeight;                 // TableViewInsetGroupedSectionFooterDefaultHeight : InsetGrouped 类型的 QMUITableView sectionFooter 的默认高度（也即没使用自定义的 sectionFooterView 时的高度），注意如果不需要间距，请用 CGFLOAT_MIN
    QMUICMI.tableViewInsetGroupedSectionHeaderContentInset = TableViewGroupedSectionHeaderContentInset;                // TableViewInsetGroupedSectionHeaderContentInset : InsetGrouped 类型的 QMUITableView sectionHeader 里的内容的 padding
    QMUICMI.tableViewInsetGroupedSectionFooterContentInset = TableViewInsetGroupedSectionHeaderContentInset;                 // TableViewInsetGroupedSectionFooterContentInset : InsetGrouped 类型的 QMUITableView sectionFooter 里的内容的 padding
    
    #pragma mark - UIWindowLevel
    QMUICMI.windowLevelQMUIAlertView = UIWindowLevelAlert - 4.0;                // UIWindowLevelQMUIAlertView : QMUIModalPresentationViewController、QMUIPopupContainerView 里使用的 UIWindow 的 windowLevel
    QMUICMI.windowLevelQMUIConsole = 1;                                         // UIWindowLevelQMUIConsole : QMUIConsole 内部的 UIWindow 的 windowLevel
    
    #pragma mark - QMUILog
    QMUICMI.shouldPrintDefaultLog = YES;                                        // ShouldPrintDefaultLog : 是否允许输出 QMUILogLevelDefault 级别的 log
    QMUICMI.shouldPrintInfoLog = YES;                                           // ShouldPrintInfoLog : 是否允许输出 QMUILogLevelInfo 级别的 log
    QMUICMI.shouldPrintWarnLog = YES;                                           // ShouldPrintInfoLog : 是否允许输出 QMUILogLevelWarn 级别的 log
    
    #pragma mark - QMUIBadge
    
    QMUICMI.badgeBackgroundColor = UIColorRed;                                  // BadgeBackgroundColor : QMUIBadge 上的未读数的背景色
    QMUICMI.badgeTextColor = UIColorWhite;                                      // BadgeTextColor : QMUIBadge 上的未读数的文字颜色
    QMUICMI.badgeFont = UIFontBoldMake(11);                                     // BadgeFont : QMUIBadge 上的未读数的字体
    QMUICMI.badgeContentEdgeInsets = UIEdgeInsetsMake(2, 4, 2, 4);              // BadgeContentEdgeInsets : QMUIBadge 上的未读数与圆圈之间的 padding
    QMUICMI.badgeOffset = CGPointMake(-9, 11);                                  // BadgeOffset : QMUIBadge 上的未读数相对于目标 view 右上角的偏移
    QMUICMI.badgeOffsetLandscape = CGPointMake(-9, 6);                          // BadgeOffsetLandscape : QMUIBadge 上的未读数在横屏下相对于目标 view 右上角的偏移
    BeginIgnoreDeprecatedWarning
    QMUICMI.badgeCenterOffset = CGPointMake(14, -10);                           // BadgeCenterOffset : QMUIBadge 未读数相对于目标 view 中心的偏移
    QMUICMI.badgeCenterOffsetLandscape = CGPointMake(16, -7);                   // BadgeCenterOffsetLandscape : QMUIBadge 未读数在横屏下相对于目标 view 中心的偏移
    EndIgnoreDeprecatedWarning
    
    QMUICMI.updatesIndicatorColor = UIColorRed;                                 // UpdatesIndicatorColor : QMUIBadge 上的未读红点的颜色
    QMUICMI.updatesIndicatorSize = CGSizeMake(7, 7);                            // UpdatesIndicatorSize : QMUIBadge 上的未读红点的大小
    QMUICMI.updatesIndicatorOffset = CGPointMake(4, UpdatesIndicatorSize.height);// UpdatesIndicatorOffset : QMUIBadge 未读红点相对于目标 view 右上角的偏移
    QMUICMI.updatesIndicatorOffsetLandscape = UpdatesIndicatorOffset;           // UpdatesIndicatorOffsetLandscape : QMUIBadge 未读红点在横屏下相对于目标 view 右上角的偏移
    BeginIgnoreDeprecatedWarning
    QMUICMI.updatesIndicatorCenterOffset = CGPointMake(14, -10);                // UpdatesIndicatorCenterOffset : QMUIBadge 未读红点相对于目标 view 中心的偏移
    QMUICMI.updatesIndicatorCenterOffsetLandscape = CGPointMake(14, -10);       // UpdatesIndicatorCenterOffsetLandscape : QMUIBadge 未读红点在横屏下相对于目标 view 中心点的偏移
    EndIgnoreDeprecatedWarning
    
    #pragma mark - Others
    
    QMUICMI.automaticCustomNavigationBarTransitionStyle = NO;                   // AutomaticCustomNavigationBarTransitionStyle : 界面 push/pop 时是否要自动根据两个界面的 barTintColor/backgroundImage/shadowImage 的样式差异来决定是否使用自定义的导航栏效果
    QMUICMI.supportedOrientationMask = UIInterfaceOrientationMaskAll;           // SupportedOrientationMask : 默认支持的横竖屏方向
    QMUICMI.automaticallyRotateDeviceOrientation = NO;                          // AutomaticallyRotateDeviceOrientation : 是否在界面切换或 viewController.supportedOrientationMask 发生变化时自动旋转屏幕
    QMUICMI.statusbarStyleLightInitially = NO;                                  // StatusbarStyleLightInitially : 默认的状态栏内容是否使用白色，默认为 NO，在 iOS 13 下会自动根据是否 Dark Mode 而切换样式，iOS 12 及以前则为黑色。生效范围：处于 QMUITabBarController 或 QMUINavigationController 内的 vc，或者 QMUICommonViewController 及其子类。
    QMUICMI.needsBackBarButtonItemTitle = YES;                                  // NeedsBackBarButtonItemTitle : 全局是否需要返回按钮的 title，不需要则只显示一个返回image
    QMUICMI.hidesBottomBarWhenPushedInitially = NO;                             // HidesBottomBarWhenPushedInitially : QMUICommonViewController.hidesBottomBarWhenPushed 的初始值，默认为 NO，以保持与系统默认值一致，但通常建议改为 YES，因为一般只有 tabBar 首页那几个界面要求为 NO
    QMUICMI.preventConcurrentNavigationControllerTransitions = YES;             // PreventConcurrentNavigationControllerTransitions : 自动保护 QMUINavigationController 在上一次 push/pop 尚未结束的时候就进行下一次 push/pop 的行为，避免产生 crash
    QMUICMI.navigationBarHiddenInitially = NO;                                  // NavigationBarHiddenInitially : QMUINavigationControllerDelegate preferredNavigationBarHidden 的初始值，默认为NO
    QMUICMI.shouldFixTabBarTransitionBugInIPhoneX = NO;                         // ShouldFixTabBarTransitionBugInIPhoneX : 是否需要自动修复 iOS 11 下，iPhone X 的设备在 push 界面时，tabBar 会瞬间往上跳的 bug
    QMUICMI.shouldFixTabBarSafeAreaInsetsBug = NO;                              // ShouldFixTabBarSafeAreaInsetsBug : 是否要对 iOS 11 及以后的版本修复当存在 UITabBar 时，UIScrollView 的 inset.bottom 可能错误的 bug（issue #218 #934），默认为 YES
    QMUICMI.shouldFixSearchBarMaskViewLayoutBug = NO;                           // ShouldFixSearchBarMaskViewLayoutBug : 是否自动修复 UISearchController.searchBar 被当作 tableHeaderView 使用时可能出现的布局 bug(issue #950)
    QMUICMI.shouldPrintQMUIWarnLogToConsole = IS_DEBUG;                         // ShouldPrintQMUIWarnLogToConsole : 是否在出现 QMUILogWarn 时自动把这些 log 以 QMUIConsole 的方式显示到设备屏幕上
    QMUICMI.sendAnalyticsToQMUITeam = YES;                                      // SendAnalyticsToQMUITeam : 是否允许在 DEBUG 模式下上报 Bundle Identifier 和 Display Name 给 QMUI 统计用
    QMUICMI.dynamicPreferredValueForIPad = NO;                                  // DynamicPreferredValueForIPad : 当 iPad 处于 Slide Over 或 Split View 分屏模式下，宏 `PreferredValueForXXX` 是否把 iPad 视为某种屏幕宽度近似的 iPhone 来取值。
    if (@available(iOS 13.0, *)) {
        QMUICMI.ignoreKVCAccessProhibited = NO;                                     // IgnoreKVCAccessProhibited : 是否全局忽略 iOS 13 对 KVC 访问 UIKit 私有属性的限制
        QMUICMI.adjustScrollIndicatorInsetsByContentInsetAdjustment = NO;           // AdjustScrollIndicatorInsetsByContentInsetAdjustment : 当将 UIScrollView.contentInsetAdjustmentBehavior 设为 UIScrollViewContentInsetAdjustmentNever 时，是否自动将 UIScrollView.automaticallyAdjustsScrollIndicatorInsets 设为 NO，以保证原本在 iOS 12 下的代码不用修改就能在 iOS 13 下正常控制滚动条的位置。
    }
}

// QMUI 2.3.0 版本里，配置表新增这个方法，返回 YES 表示在 App 启动时要自动应用这份配置表。仅当你的 App 里存在多份配置表时，才需要把除默认配置表之外的其他配置表的返回值改为 NO。
- (BOOL)shouldApplyTemplateAutomatically {
    return YES;
}

@end
