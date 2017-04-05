//
//  QMUIConfigurationTemplate.m
//  qmui
//
//  Created by QQMail on 15/3/29.
//  Copyright (c) 2015年 QMUI Team. All rights reserved.
//

#import "QMUIConfigurationTemplate.h"
#import <QMUIKit/QMUIKit.h>

@implementation QMUIConfigurationTemplate

+ (void)setupConfigurationTemplate {
    
    // === 初始化默认值 === //
    
    [QMUICMI initDefaultConfiguration];
    
    
    // === 修改配置值 === //
    
    #pragma mark - Global Color
    
    //- QMUICMI.clearColor = [UIColor colorWithRed:1 green:1 blue:1 alpha:0];       // UIColorClear : 透明色
    //- QMUICMI.whiteColor = [UIColor colorWithRed:1 green:1 blue:1 alpha:1];       // UIColorWhite : 白色（不用 [UIColor whiteColor] 是希望保持颜色空间为 RGB）
    //- QMUICMI.blackColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:1];       // UIColorBlack : 黑色（不用 [UIColor blackColor] 是希望保持颜色空间为 RGB）
    //- QMUICMI.grayColor = UIColorMake(179, 179, 179);                             // UIColorGray  : 最常用的灰色
    //- QMUICMI.grayDarkenColor = UIColorMake(163, 163, 163);                       // UIColorGrayDarken : 深一点的灰色
    //- QMUICMI.grayLightenColor = UIColorMake(198, 198, 198);                      // UIColorGrayLighten : 浅一点的灰色
    //- QMUICMI.redColor = UIColorMake(227, 40, 40);                                // UIColorRed : 红色
    //- QMUICMI.greenColor = UIColorMake(79, 214, 79);                              // UIColorGreen : 绿色
    //- QMUICMI.blueColor = UIColorMake(43, 133, 208);                              // UIColorBlue : 蓝色
    //- QMUICMI.yellowColor = UIColorMake(255, 252, 233);                           // UIColorYellow : 黄色
    
    //- QMUICMI.linkColor = UIColorMake(56, 116, 171);                              // UIColorLink : 文字链接颜色
    //- QMUICMI.disabledColor = UIColorGray;                                        // UIColorDisabled : 全局 disabled 的颜色，一般用于 UIControl 等控件
    //- QMUICMI.backgroundColor = UIColorMake(246, 246, 246);                       // UIColorForBackground : 界面背景色，默认用于 QMUICommonViewController.view 的背景色
    //- QMUICMI.maskDarkColor = UIColorMakeWithRGBA(0, 0, 0, .35f);                 // UIColorMask : 深色的背景遮罩，默认用于 QMAlertController、QMUIDialogViewController 等弹出控件的遮罩
    //- QMUICMI.maskLightColor = UIColorMakeWithRGBA(255, 255, 255, .5f);           // UIColorMaskWhite : 浅色的背景遮罩，QMUIKit 里默认没用到，只是占个位
    //- QMUICMI.separatorColor = UIColorMake(200, 199, 204);                        // UIColorSeparator : 全局默认的分割线颜色，默认用于列表分隔线颜色、UIView (QMUI_Border) 分隔线颜色
    //- QMUICMI.separatorDashedColor = UIColorMake(17, 17, 17);                     // UIColorSeparatorDashed : 全局默认的虚线分隔线的颜色，默认 QMUIKit 暂时没用到
    //- QMUICMI.placeholderColor = UIColorMake(187, 187, 187);                      // UIColorPlaceholder，全局的输入框的 placeholder 颜色，默认用于 QMUITextField、QMUITextView，不影响系统 UIKit 的输入框
    
    // UIColorTestRed/UIColorTestGreen/UIColorTestBlue  =  测试用的颜色
    //- QMUICMI.testColorRed = UIColorMakeWithRGBA(255, 0, 0, .3);
    //- QMUICMI.testColorGreen = UIColorMakeWithRGBA(0, 255, 0, .3);
    //- QMUICMI.testColorBlue = UIColorMakeWithRGBA(0, 0, 255, .3);
    
    
    #pragma mark - UIControl
    
    //- QMUICMI.controlHighlightedAlpha = 0.5f;                                                 // UIControlHighlightedAlpha : UIControl 系列控件在 highlighted 时的 alpha，默认用于 QMUIButton、 QMUINavigationTitleView
    //- QMUICMI.controlDisabledAlpha = 0.5f;                                                    // UIControlDisabledAlpha : UIControl 系列控件在 disabled 时的 alpha，默认用于 QMUIButton
    
    #pragma mark - UIButton
    //- QMUICMI.buttonHighlightedAlpha = UIControlHighlightedAlpha;                             // ButtonHighlightedAlpha : QMUIButton 在 highlighted 时的 alpha，不影响系统的 UIButton
    //- QMUICMI.buttonDisabledAlpha = UIControlDisabledAlpha;                                   // ButtonDisabledAlpha : QMUIButton 在 disabled 时的 alpha，不影响系统的 UIButton
    //- QMUICMI.buttonTintColor = UIColorBlue;                                                  // ButtonTintColor : QMUIButton 默认的 tintColor，不影响系统的 UIButton
    
    //- QMUICMI.ghostButtonColorBlue = UIColorBlue;                                             // GhostButtonColorBlue : QMUIGhostButtonColorBlue 的颜色
    //- QMUICMI.ghostButtonColorRed = UIColorRed;                                               // GhostButtonColorRed : QMUIGhostButtonColorRed 的颜色
    //- QMUICMI.ghostButtonColorGreen = UIColorGreen;                                           // GhostButtonColorGreen : QMUIGhostButtonColorGreen 的颜色
    //- QMUICMI.ghostButtonColorGray = UIColorGray;                                             // GhostButtonColorGray : QMUIGhostButtonColorGray 的颜色
    //- QMUICMI.ghostButtonColorWhite = UIColorWhite;                                           // GhostButtonColorWhite : QMUIGhostButtonColorWhite 的颜色
    
    //- QMUICMI.fillButtonColorBlue = UIColorBlue;                                             // FillButtonColorBlue : QMUIFillButtonColorBlue 的颜色
    //- QMUICMI.fillButtonColorRed = UIColorRed;                                               // FillButtonColorRed : QMUIFillButtonColorRed 的颜色
    //- QMUICMI.fillButtonColorGreen = UIColorGreen;                                           // FillButtonColorGreen : QMUIFillButtonColorGreen 的颜色
    //- QMUICMI.fillButtonColorGray = UIColorGray;                                             // FillButtonColorGray : QMUIFillButtonColorGray 的颜色
    //- QMUICMI.fillButtonColorWhite = UIColorWhite;                                           // FillButtonColorWhite : QMUIFillButtonColorWhite 的颜色
    
    
    #pragma mark - TextField & TextView
    //- QMUICMI.textFieldTintColor = UIColorBlue;                                               // TextFieldTintColor : QMUITextField、QMUITextView 的 tintColor，不影响 UIKit 的输入框
    //- QMUICMI.textFieldTextInsets = UIEdgeInsetsMake(0, 7, 0, 7);                             // TextFieldTextInsets : QMUITextField 的内边距，不影响 UITextField
    
    #pragma mark - NavigationBar
    
    //- QMUICMI.navBarHighlightedAlpha = 0.2f;                                          // NavBarHighlightedAlpha : QMUINavigationButton 在 highlighted 时的 alpha
    //- QMUICMI.navBarDisabledAlpha = 0.2f;                                             // NavBarDisabledAlpha : QMUINavigationButton 在 disabled 时的 alpha
    //- QMUICMI.navBarButtonFont = UIFontMake(17);                                      // NavBarButtonFont : QMUINavigationButton 的字体
    //- QMUICMI.navBarButtonFontBold = UIFontBoldMake(17);                              // NavBarButtonFontBold : QMUINavigationButtonTypeBold 的字体
    //- QMUICMI.navBarBackgroundImage = nil;                                            // NavBarBackgroundImage : UINavigationBar 的背景图
    //- QMUICMI.navBarShadowImage = nil;                                                // NavBarShadowImage : UINavigationBar.shadowImage，也即导航栏底部那条分隔线
    //- QMUICMI.navBarBarTintColor = nil;                                               // NavBarBarTintColor : UINavigationBar.barTintColor，也即背景色
    //- QMUICMI.navBarTintColor = UIColorBlack;                                         // NavBarTintColor : UINavigationBar 的 tintColor，也即导航栏上面的按钮颜色
    //- QMUICMI.navBarTitleColor = NavBarTintColor;                                     // NavBarTitleColor : UINavigationBar 的标题颜色，以及 QMUINavigationTitleView 的默认文字颜色
    //- QMUICMI.navBarTitleFont = UIFontBoldMake(17);                                   // NavBarTitleFont : UINavigationBar 的标题字体，以及 QMUINavigationTitleView 的默认字体
    //- QMUICMI.navBarBackButtonTitlePositionAdjustment = UIOffsetZero;                 // NavBarBarBackButtonTitlePositionAdjustment : 导航栏返回按钮的文字偏移
    //- QMUICMI.navBarBackIndicatorImage = [UIImage qmui_imageWithShape:QMUIImageShapeNavBack size:CGSizeMake(12, 20) tintColor:NavBarTintColor];    // NavBarBackIndicatorImage : 导航栏的返回按钮的图片
    //- QMUICMI.navBarCloseButtonImage = [UIImage qmui_imageWithShape:QMUIImageShapeNavClose size:CGSizeMake(16, 16) tintColor:NavBarTintColor];     // NavBarCloseButtonImage : QMUINavigationButton 用到的 × 的按钮图片
    
    //- QMUICMI.navBarLoadingMarginRight = 3;                                           // NavBarLoadingMarginRight : QMUINavigationTitleView 里左边 loading 的右边距
    //- QMUICMI.navBarAccessoryViewMarginLeft = 5;                                      // NavBarAccessoryViewMarginLeft : QMUINavigationTitleView 里右边 accessoryView 的左边距
    //- QMUICMI.navBarActivityIndicatorViewStyle = UIActivityIndicatorViewStyleGray;    // NavBarActivityIndicatorViewStyle : QMUINavigationTitleView 里左边 loading 的主题
    //- QMUICMI.navBarAccessoryViewTypeDisclosureIndicatorImage = [UIImage qmui_imageWithShape:QMUIImageShapeTriangle size:CGSizeMake(8, 5) tintColor:UIColorWhite];     // NavBarAccessoryViewTypeDisclosureIndicatorImage : QMUINavigationTitleView 右边箭头的图片
    
    #pragma mark - TabBar
    
    //- QMUICMI.tabBarBackgroundImage = nil;                                            // TabBarBackgroundImage : UITabBar 的背景图
    //- QMUICMI.tabBarBarTintColor = nil;                                               // TabBarBarTintColor : UITabBar 的 barTintColor
    //- QMUICMI.tabBarShadowImageColor = nil;                                           // TabBarShadowImageColor : UITabBar 的 shadowImage 的颜色，会自动创建一张 1px 高的图片
    //- QMUICMI.tabBarTintColor = UIColorMake(22, 147, 229);                            // TabBarTintColor : UITabBar 的 tintColor
    //- QMUICMI.tabBarItemTitleColor = UIColorMake(119, 119, 119);                      // TabBarItemTitleColor : 未选中的 UITabBarItem 的标题颜色
    //- QMUICMI.tabBarItemTitleColorSelected = TabBarTintColor;                         // TabBarItemTitleColorSelected : 选中的 UITabBarItem 的标题颜色
    
    #pragma mark - Toolbar
    
    //- QMUICMI.toolBarHighlightedAlpha = 0.4f;                                                                         // ToolBarHighlightedAlpha : QMUIToolbarButton 在 highlighted 状态下的 alpha
    //- QMUICMI.toolBarDisabledAlpha = 0.4f;                                                                            // ToolBarDisabledAlpha : QMUIToolbarButton 在 disabled 状态下的 alpha
    //- QMUICMI.toolBarTintColor = UIColorBlue;                                                                         // ToolBarTintColor : UIToolbar 的 tintColor，以及 QMUIToolbarButton normal 状态下的文字颜色
    //- QMUICMI.toolBarTintColorHighlighted = [ToolBarTintColor colorWithAlphaComponent:ToolBarHighlightedAlpha];       // ToolBarTintColorHighlighted : QMUIToolbarButton 在 highlighted 状态下的文字颜色
    //- QMUICMI.toolBarTintColorDisabled = [ToolBarTintColor colorWithAlphaComponent:ToolBarDisabledAlpha];             // ToolBarTintColorDisabled : QMUIToolbarButton 在 disabled 状态下的文字颜色
    //- QMUICMI.toolBarBackgroundImage = nil;                                                                           // ToolBarBackgroundImage : UIToolbar 的背景图
    //- QMUICMI.toolBarBarTintColor = nil;                                                                              // ToolBarBarTintColor : UIToolbar 的 tintColor
    //- QMUICMI.toolBarShadowImageColor = UIColorMake(178, 178, 178);                                                   // ToolBarShadowImageColor : UIToolbar 的 shadowImage 的颜色，会自动创建一张 1px 高的图片
    //- QMUICMI.toolBarButtonFont = UIFontMake(17);                                                                     // ToolBarButtonFont : QMUIToolbarButton 的字体
    
    #pragma mark - SearchBar
    
    //- QMUICMI.searchBarTextFieldBackground = UIColorWhite;                            // SearchBarTextFieldBackground : QMUISearchBar 里的文本框的背景颜色
    //- QMUICMI.searchBarTextFieldBorderColor = UIColorMake(205, 208, 210);             // SearchBarTextFieldBorderColor : QMUISearchBar 里的文本框的边框颜色
    //- QMUICMI.searchBarBottomBorderColor = UIColorMake(205, 208, 210);                // SearchBarBottomBorderColor : QMUISearchBar 底部分隔线颜色
    //- QMUICMI.searchBarBarTintColor = UIColorMake(247, 247, 247);                     // SearchBarBarTintColor : QMUISearchBar 的 barTintColor，也即背景色
    //- QMUICMI.searchBarTintColor = UIColorBlue;                                       // SearchBarTintColor : QMUISearchBar 的 tintColor，也即上面的操作控件的主题色
    //- QMUICMI.searchBarTextColor = UIColorBlack;                                      // SearchBarTextColor : QMUISearchBar 里的文本框的文字颜色
    //- QMUICMI.searchBarPlaceholderColor = UIColorPlaceholder;                         // SearchBarPlaceholderColor : QMUISearchBar 里的文本框的 placeholder 颜色
    //- QMUICMI.searchBarSearchIconImage = nil;                                         // SearchBarSearchIconImage : QMUISearchBar 里的放大镜 icon
    //- QMUICMI.searchBarClearIconImage = nil;                                          // SearchBarClearIconImage : QMUISearchBar 里的文本框输入文字时右边的清空按钮的图片
    //- QMUICMI.searchBarTextFieldCornerRadius = 2.0;                                   // SearchBarTextFieldCornerRadius : QMUISearchBar 里的文本框的圆角大小
    
    #pragma mark - TableView / TableViewCell
    
    //- QMUICMI.tableViewBackgroundColor = UIColorWhite;                                    // TableViewBackgroundColor : Plain 类型的 QMUITableView 的背景色颜色
    //- QMUICMI.tableViewGroupedBackgroundColor = UIColorForBackground;                     // TableViewGroupedBackgroundColor : Grouped 类型的 QMUITableView 的背景色
    //- QMUICMI.tableSectionIndexColor = UIColorGrayDarken;                                 // TableSectionIndexColor : 列表右边的字母索引条的文字颜色
    //- QMUICMI.tableSectionIndexBackgroundColor = UIColorClear;                            // TableSectionIndexBackgroundColor : 列表右边的字母索引条的背景色
    //- QMUICMI.tableSectionIndexTrackingBackgroundColor = UIColorClear;                    // TableSectionIndexTrackingBackgroundColor : 列表右边的字母索引条在选中时的背景色
    //- QMUICMI.tableViewSeparatorColor = UIColorSeparator;                                 // TableViewSeparatorColor : 列表的分隔线颜色
    
    //- QMUICMI.tableViewCellNormalHeight = 44;                                             // TableViewCellNormalHeight : 列表默认的 cell 高度
    //- QMUICMI.tableViewCellTitleLabelColor = UIColorBlack;                                // TableViewCellTitleLabelColor : QMUITableViewCell 的 textLabel 的文字颜色
    //- QMUICMI.tableViewCellDetailLabelColor = UIColorGray;                                // TableViewCellDetailLabelColor : QMUITableViewCell 的 detailTextLabel 的文字颜色
    //- QMUICMI.tableViewCellContentDefaultPaddingLeft = 15;                                // TableViewCellContentDefaultPaddingLeft : QMUITableViewCell 的左边距
    //- QMUICMI.tableViewCellContentDefaultPaddingRight = 10;                               // TableViewCellContentDefaultPaddingRight : QMUITableViewCell 的右边距（最右截止到 accessoryView 的左边）
    //- QMUICMI.tableViewCellBackgroundColor = UIColorWhite;                                // TableViewCellBackgroundColor : QMUITableViewCell 的背景色
    //- QMUICMI.tableViewCellSelectedBackgroundColor = UIColorMake(232, 232, 232);          // TableViewCellSelectedBackgroundColor : QMUITableViewCell 点击时的背景色
    //- QMUICMI.tableViewCellWarningBackgroundColor = UIColorYellow;                        // TableViewCellWarningBackgroundColor : QMUITableViewCell 用于表示警告时的背景色，备用
    //- QMUICMI.tableViewCellDisclosureIndicatorImage = [UIImage qmui_imageWithShape:QMUIImageShapeDisclosureIndicator size:CGSizeMake(8, 13) tintColor:UIColorMakeWithRGBA(0, 0, 0, .2)];       // TableViewCellDisclosureIndicatorImage : QMUITableViewCell 当 accessoryType 为 UITableViewCellAccessoryDisclosureIndicator 时的箭头的图片
    //- QMUICMI.tableViewCellCheckmarkImage = [UIImage qmui_imageWithShape:QMUIImageShapeCheckmark size:CGSizeMake(15, 12) tintColor:UIColorBlue];     // TableViewCellCheckmarkImage : QMUITableViewCell 当 accessoryType 为 UITableViewCellAccessoryCheckmark 时的打钩的图片
    
    //- QMUICMI.tableViewSectionHeaderBackgroundColor = UIColorMake(244, 244, 244);                         // TableViewSectionHeaderBackgroundColor : Plain 类型的 QMUITableView sectionHeader 的背景色
    //- QMUICMI.tableViewSectionFooterBackgroundColor = UIColorMake(244, 244, 244);                         // TableViewSectionFooterBackgroundColor : Plain 类型的 QMUITableView sectionFooter 的背景色
    //- QMUICMI.tableViewSectionHeaderFont = UIFontBoldMake(12);                                            // TableViewSectionHeaderFont : Plain 类型的 QMUITableView sectionHeader 里的文字字体
    //- QMUICMI.tableViewSectionFooterFont = UIFontBoldMake(12);                                            // TableViewSectionFooterFont : Plain 类型的 QMUITableView sectionFooter 里的文字字体
    //- QMUICMI.tableViewSectionHeaderTextColor = UIColorGrayDarken;                                        // TableViewSectionHeaderTextColor : Plain 类型的 QMUITableView sectionHeader 里的文字颜色
    //- QMUICMI.tableViewSectionFooterTextColor = UIColorGray;                                              // TableViewSectionFooterTextColor : Plain 类型的 QMUITableView sectionFooter 里的文字颜色
    //- QMUICMI.tableViewSectionHeaderHeight = 20;                                                          // TableViewSectionHeaderHeight : Plain 类型的 QMUITableView sectionHeader 的默认高度
    //- QMUICMI.tableViewSectionFooterHeight = 0;                                                           // TableViewSectionFooterHeight : Plain 类型的 QMUITableView sectionFooter 的默认高度
    //- QMUICMI.tableViewSectionHeaderContentInset = UIEdgeInsetsMake(4, 15, 4, 15);                        // TableViewSectionHeaderContentInset : Plain 类型的 QMUITableView sectionHeader 里的内容的 padding
    //- QMUICMI.tableViewSectionFooterContentInset = UIEdgeInsetsMake(4, 15, 4, 15);                        // TableViewSectionFooterContentInset : Plain 类型的 QMUITableView sectionFooter 里的内容的 padding
    
    //- QMUICMI.tableViewGroupedSectionHeaderFont = UIFontMake(12);                                         // TableViewGroupedSectionHeaderFont : Grouped 类型的 QMUITableView sectionHeader 里的文字字体
    //- QMUICMI.tableViewGroupedSectionFooterFont = UIFontMake(12);                                         // TableViewGroupedSectionFooterFont : Grouped 类型的 QMUITableView sectionFooter 里的文字字体
    //- QMUICMI.tableViewGroupedSectionHeaderTextColor = UIColorGrayDarken;                                 // TableViewGroupedSectionHeaderTextColor : Grouped 类型的 QMUITableView sectionHeader 里的文字颜色
    //- QMUICMI.tableViewGroupedSectionFooterTextColor = UIColorGray;                                       // TableViewGroupedSectionFooterTextColor : Grouped 类型的 QMUITableView sectionFooter 里的文字颜色
    //- QMUICMI.tableViewGroupedSectionHeaderHeight = 15;                                                   // TableViewGroupedSectionHeaderHeight : Grouped 类型的 QMUITableView sectionHeader 的默认高度
    //- QMUICMI.tableViewGroupedSectionFooterHeight = 1;                                                    // TableViewGroupedSectionFooterHeight : Grouped 类型的 QMUITableView sectionFooter 的默认高度
    //- QMUICMI.tableViewGroupedSectionHeaderContentInset = UIEdgeInsetsMake(16, 15, 8, 15);                // TableViewGroupedSectionHeaderContentInset : Grouped 类型的 QMUITableView sectionHeader 里的内容的 padding
    //- QMUICMI.tableViewGroupedSectionFooterContentInset = UIEdgeInsetsMake(8, 15, 2, 15);                 // TableViewGroupedSectionFooterContentInset : Grouped 类型的 QMUITableView sectionFooter 里的内容的 padding
    
    #pragma mark - UIWindowLevel
    //- QMUICMI.windowLevelQMUIAlertView = UIWindowLevelAlert - 4.0;                    // UIWindowLevelQMUIAlertView : QMUIModalPresentationViewController、QMUIPopupContainerView 里使用的 UIWindow 的 windowLevel
    //- QMUICMI.windowLevelQMUIImagePreviewView = UIWindowLevelStatusBar + 1.0;         // UIWindowLevelQMUIImagePreviewView : QMUIImagePreviewViewController 里使用的 UIWindow 的 windowLevel
    
    #pragma mark - Others
    
    //- QMUICMI.supportedOrientationMask = UIInterfaceOrientationMaskPortrait;  // SupportedOrientationMask : 默认支持的横竖屏方向
    //- QMUICMI.statusbarStyleLightInitially = NO;          // StatusbarStyleLightInitially : 默认的状态栏内容是否使用白色，默认为 NO，也即黑色
    //- QMUICMI.needsBackBarButtonItemTitle = NO;           // NeedsBackBarButtonItemTitle : 全局是否需要返回按钮的 title，不需要则只显示一个返回image
    //- QMUICMI.hidesBottomBarWhenPushedInitially = YES;    // HidesBottomBarWhenPushedInitially : QMUICommonViewController.hidesBottomBarWhenPushed 的初始值，默认为YES
}

@end
