//
//  QMUIConfigurationTemplate.m
//  qmui
//
//  Created by QQMail on 15/3/29.
//  Copyright (c) 2015年 QMUI Team. All rights reserved.
//

#import "QMUIConfigurationTemplate.h"

// 如果这里找不到QMUIKit.h，请尝试替换为 #import <QMUIKit/QMUIKit.h>
#import "QMUIKit.h"

// 此文件仅供复制使用，不能加到静态库的Compile Sources里面。

/**
 * 1、在QMUI的UICommon里面把这个文件复制到自己的项目下然后按需要修改（通过修改这个模板的单例来修改宏的值）。
 * 2、无需修改的宏，可以保持注释的状态，避免重新赋相同的值。
 * 3、在main函数里面调用setupConfigurationTemplate来使修改生效。
 * 4、@warning 务必请不要修改默认的顺序，只需修改值即可。
 * 5、@warning 更新QMUI的时候，请留意是否这个模板有更新，有则需要把更新的代码负责到项目模板对应的地方，如果没有及时复制，则会使用QMUI给的默认值。
 * 6、@warning 当修改了某个宏，其他引用了这个宏的修改则不能注释，否则会更新不了新的值。比如：a = b ; c = a ; 如果需改了a = d，则c = a就不能注释了。如果觉得这样太麻烦，那么可以把所有的注释都去掉，这样就不用关心这个问题了。
 */

@implementation QMUIConfigurationTemplate

+ (void)setupConfigurationTemplate {
    
    // === 初始化默认值 === //
    
    [QMUICMI initDefaultConfiguration];
    
    
    // === 修改配置值 === //
    
    #pragma mark - Global Color
    
    //- QMUICMI.clearColor = [UIColor colorWithRed:1 green:1 blue:1 alpha:0];                                  // UIColorClear
    //- QMUICMI.whiteColor = [UIColor colorWithRed:1 green:1 blue:1 alpha:1];                                  // UIColorWhite
    //- QMUICMI.blackColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:1];                                  // UIColorBlack
    //- QMUICMI.grayColor = UIColorMake(179, 179, 179);                             // UIColorGray
    //- QMUICMI.grayDarkenColor = UIColorMake(163, 163, 163);                       // UIColorGrayDarken
    //- QMUICMI.grayLightenColor = UIColorMake(198, 198, 198);                      // UIColorGrayLighten
    //- QMUICMI.redColor = UIColorMake(227, 40, 40);                                // UIColorRed
    //- QMUICMI.greenColor = UIColorMake(79, 214, 79);                              // UIColorGreen
    //- QMUICMI.blueColor = UIColorMake(43, 133, 208);                              // UIColorBlue
    //- QMUICMI.yellowColor = UIColorMake(255, 252, 233);                           // UIColorYellow
    
    //- QMUICMI.linkColor = UIColorMake(56, 116, 171);                              // UIColorLink : 文字连接颜色
    //- QMUICMI.disabledColor = UIColorGray;                                        // UIColorDisabled : 全局disabled的颜色
    //- QMUICMI.backgroundColor = UIColorMake(246, 246, 246);                       // UIColorForBackground : 全局背景色，用于viewController的背景色
    //- QMUICMI.maskDarkColor = UIColorMakeWithRGBA(0, 0, 0, .35f);                 // UIColorMask : 深色的mask遮罩
    //- QMUICMI.maskLightColor = UIColorMakeWithRGBA(255, 255, 255, .5f);           // UIColorMaskWhite : 浅色的mask遮罩
    //- QMUICMI.separatorColor = UIColorMake(200, 199, 204);                        // UIColorSeparator : 全局分割线的颜色
    //- QMUICMI.separatorDashedColor = UIColorMake(17, 17, 17);                     // UIColorSeparatorDashed : 虚线的颜色
    //- QMUICMI.placeholderColor = UIColorMake(187, 187, 187);                      // UIColorPlaceholder，全局的输入框的placeholder颜色
    
    // UIColorTestRed/UIColorTestGreen/UIColorTestBlue  =  测试用的颜色
    //- QMUICMI.testColorRed = UIColorMakeWithRGBA(255, 0, 0, .3);
    //- QMUICMI.testColorGreen = UIColorMakeWithRGBA(0, 255, 0, .3);
    //- QMUICMI.testColorBlue = UIColorMakeWithRGBA(0, 0, 255, .3);
    
    
    #pragma mark - UIControl
    
    //- QMUICMI.controlDisabledAlpha = 0.5f;                                                    // UIControlHighlightedAlpha : 全局的highlighted alpha值
    //- QMUICMI.controlDisabledAlpha = 0.5f;                                                    // UIControlDisabledAlpha : 全局的disabled alpha值
    
    //- QMUICMI.segmentTextTintColor = UIColorBlue;                                             // SegmentTextTintColor : segment的tintColor
    //- QMUICMI.segmentTextSelectedTintColor = UIColorWhite;                                    // SegmentTextSelectedTintColor : segment选中态的tintColor
    //- QMUICMI.segmentFontSize = UIFontMake(13);                                               // SegmentFontSize : segment的字体大小
    
    #pragma mark - UIButton
    //- QMUICMI.buttonHighlightedAlpha = UIControlHighlightedAlpha;                             // ButtonHighlightedAlpha : 按钮的highlighted alpha值
    //- QMUICMI.buttonDisabledAlpha = UIControlDisabledAlpha;                                   // ButtonDisabledAlpha : 按钮的disabled alpha值
    //- QMUICMI.buttonTintColor = UIColorBlue;                                                  // ButtonTintColor : 按钮默认的tintColor
    
    //- QMUICMI.ghostButtonColorBlue = UIColorBlue;                                             // GhostButtonColorBlue
    //- QMUICMI.ghostButtonColorRed = UIColorRed;                                               // GhostButtonColorRed
    //- QMUICMI.ghostButtonColorGreen = UIColorGreen;                                           // GhostButtonColorGreen
    //- QMUICMI.ghostButtonColorGray = UIColorGray;                                             // GhostButtonColorGray
    //- QMUICMI.ghostButtonColorWhite = UIColorWhite;                                           // GhostButtonColorWhite
    
    //- QMUICMI.fillButtonColorBlue = UIColorBlue;                                             // FillButtonColorBlue
    //- QMUICMI.fillButtonColorRed = UIColorRed;                                               // FillButtonColorRed
    //- QMUICMI.fillButtonColorGreen = UIColorGreen;                                           // FillButtonColorGreen
    //- QMUICMI.fillButtonColorGray = UIColorGray;                                             // FillButtonColorGray
    //- QMUICMI.fillButtonColorWhite = UIColorWhite;                                           // FillButtonColorWhite
    
    
    #pragma mark - TextField & TextView
    //- QMUICMI.textFieldTintColor = UIColorBlue;                                               // TextFieldTintColor : 全局UITextField、UITextView的tintColor
    //- QMUICMI.textFieldTextInsets = UIEdgeInsetsMake(0, 7, 0, 7);                             // TextFieldTextInsets : QMUITextField的内边距
    
    #pragma mark - ActionSheet
    //- QMUICMI.actionSheetButtonTintColor = UIColorBlue;                                       // ActionSheetButtonTintColor
    //- QMUICMI.actionSheetButtonBackgroundColor = UIColorMake(255, 255, 255);                  // ActionSheetButtonBackgroundColor
    //- QMUICMI.actionSheetButtonBackgroundColorHighlighted = UIColorMake(235, 235, 235);       // ActionSheetButtonBackgroundColorHighlighted
    //- QMUICMI.actionSheetButtonFont = UIFontMake(21);                                         // ActionSheetButtonFont
    //- QMUICMI.actionSheetButtonFontBold = UIFontBoldMake(21);                                 // ActionSheetButtonFontBold
    
    #pragma mark - NavigationBar
    
    //- QMUICMI.navBarHighlightedAlpha = 0.2f;                                          // NavBarHighlightedAlpha
    //- QMUICMI.navBarDisabledAlpha = 0.2f;                                             // NavBarDisabledAlpha
    //- QMUICMI.navBarButtonFont = UIFontMake(17);                                      // NavBarButtonFont
    //- QMUICMI.navBarButtonFontBold = UIFontBoldMake(17);                              // NavBarButtonFontBold
    //- QMUICMI.navBarBackgroundImage = nil;                                            // NavBarBackgroundImage
    //- QMUICMI.navBarShadowImage = nil;                                                // NavBarShadowImage
    //- QMUICMI.navBarBarTintColor = nil;                                               // NavBarBarTintColor
    //- QMUICMI.navBarTintColor = UIColorBlack;                                         // NavBarTintColor
    //- QMUICMI.navBarTintColorHighlighted = [NavBarTintColor colorWithAlphaComponent:NavBarHighlightedAlpha];          // NavBarTintColorHighlighted
    //- QMUICMI.navBarTintColorDisabled = [NavBarTintColor colorWithAlphaComponent:NavBarDisabledAlpha];                // NavBarTintColorDisabled
    //- QMUICMI.navBarTitleColor = NavBarTintColor;                                     // NavBarTitleColor
    //- QMUICMI.navBarTitleFont = UIFontBoldMake(17);                                   // NavBarTitleFont
    //- QMUICMI.navBarBackButtonTitlePositionAdjustment = UIOffsetZero;                 // NavBarBarBackButtonTitlePositionAdjustment
    //- QMUICMI.navBarBackIndicatorImage = [UIImage qmui_imageWithShape:QMUIImageShapeNavBack size:CGSizeMake(12, 20) tintColor:NavBarTintColor];    // NavBarBackIndicatorImage
    //- QMUICMI.navBarCloseButtonImage = [UIImage qmui_imageWithShape:QMUIImageShapeNavClose size:CGSizeMake(16, 16) tintColor:NavBarTintColor];     // NavBarCloseButtonImage
    
    //- QMUICMI.navBarLoadingMarginRight = 3;                                           // NavBarLoadingMarginRight
    //- QMUICMI.navBarAccessoryViewMarginLeft = 5;                                      // NavBarAccessoryViewMarginLeft
    //- QMUICMI.navBarActivityIndicatorViewStyle = UIActivityIndicatorViewStyleGray;    // NavBarActivityIndicatorViewStyle
    //- QMUICMI.navBarAccessoryViewTypeDisclosureIndicatorImage = [UIImage qmui_imageWithShape:QMUIImageShapeTriangle size:CGSizeMake(8, 5) tintColor:UIColorWhite];     // NavBarAccessoryViewTypeDisclosureIndicatorImage
    
    #pragma mark - TabBar
    
    //- QMUICMI.tabBarBackgroundImage = nil;                                                            // TabBarBackgroundImage
    //- QMUICMI.tabBarBarTintColor = nil;    // TabBarBarTintColor
    //- QMUICMI.tabBarShadowImageColor = nil;                                    // TabBarShadowImageColor
    //- QMUICMI.tabBarTintColor = UIColorMake(22, 147, 229);                                            // TabBarTintColor
    //- QMUICMI.tabBarItemTitleColor = UIColorMake(119, 119, 119);                                      // TabBarItemTitleColor
    //- QMUICMI.tabBarItemTitleColorSelected = TabBarTintColor;                                         // TabBarItemTitleColorSelected
    
    #pragma mark - Toolbar
    
    //- QMUICMI.toolBarHighlightedAlpha = 0.4f;                                                                         // ToolBarHighlightedAlpha
    //- QMUICMI.toolBarDisabledAlpha = 0.4f;                                                                            // ToolBarDisabledAlpha
    //- QMUICMI.toolBarTintColor = UIColorBlue;                                                                         // ToolBarTintColor
    //- QMUICMI.toolBarTintColorHighlighted = [ToolBarTintColor colorWithAlphaComponent:ToolBarHighlightedAlpha];       // ToolBarTintColorHighlighted
    //- QMUICMI.toolBarTintColorDisabled = [ToolBarTintColor colorWithAlphaComponent:ToolBarDisabledAlpha];             // ToolBarTintColorDisabled
    //- QMUICMI.toolBarBackgroundImage = nil;                                                                           // ToolBarBackgroundImage
    //- QMUICMI.toolBarBarTintColor = nil;                                                                              // ToolBarBarTintColor
    //- QMUICMI.toolBarShadowImageColor = UIColorMake(178, 178, 178);                                                   // ToolBarShadowImageColor
    //- QMUICMI.toolBarButtonFont = UIFontMake(17);                                                                     // ToolBarButtonFont
    
    #pragma mark - SearchBar
    
    //- QMUICMI.searchBarTextFieldBackground = UIColorWhite;                            // SearchBarTextFieldBackground
    //- QMUICMI.searchBarTextFieldBorderColor = UIColorMake(205, 208, 210);             // SearchBarTextFieldBorderColor
    //- QMUICMI.searchBarBottomBorderColor = UIColorMake(205, 208, 210);                // SearchBarBottomBorderColor
    //- QMUICMI.searchBarBarTintColor = UIColorMake(247, 247, 247);                     // SearchBarBarTintColor
    //- QMUICMI.searchBarTintColor = UIColorBlue;                                       // SearchBarTintColor
    //- QMUICMI.searchBarTextColor = UIColorBlack;                                      // SearchBarTextColor
    //- QMUICMI.searchBarPlaceholderColor = UIColorPlaceholder;                         // SearchBarPlaceholderColor
    //- QMUICMI.searchBarSearchIconImage = nil;                                         // SearchBarSearchIconImage
    //- QMUICMI.searchBarClearIconImage = nil;                                          // SearchBarClearIconImage
    //- QMUICMI.searchBarTextFieldCornerRadius = 2.0;                                   // SearchBarTextFieldCornerRadius
    
    #pragma mark - TableView / TableViewCell
    
    //- QMUICMI.tableViewBackgroundColor = UIColorWhite;                                    // TableViewBackgroundColor
    //- QMUICMI.tableViewGroupedBackgroundColor = UIColorForBackground;                     // TableViewGroupedBackgroundColor
    //- QMUICMI.tableSectionIndexColor = UIColorGrayDarken;                                 // TableSectionIndexColor
    //- QMUICMI.tableSectionIndexBackgroundColor = UIColorClear;                            // TableSectionIndexBackgroundColor
    //- QMUICMI.tableSectionIndexTrackingBackgroundColor = UIColorClear;                    // TableSectionIndexTrackingBackgroundColor
    //- QMUICMI.tableViewSeparatorColor = UIColorSeparator;                                 // TableViewSeparatorColor
    //- QMUICMI.tableViewCellBackgroundColor = UIColorWhite;                                // TableViewCellBackgroundColor
    //- QMUICMI.tableViewCellSelectedBackgroundColor = UIColorMake(232, 232, 232);          // TableViewCellSelectedBackgroundColor
    //- QMUICMI.tableViewCellWarningBackgroundColor = UIColorYellow;                        // TableViewCellWarningBackgroundColor
    //- QMUICMI.tableViewCellNormalHeight = 44;                                             // TableViewCellNormalHeight
    
    //- QMUICMI.tableViewCellDisclosureIndicatorImage = [UIImage qmui_imageWithShape:QMUIImageShapeDisclosureIndicator size:CGSizeMake(8, 13) tintColor:UIColorMakeWithRGBA(0, 0, 0, .2)];       // TableViewCellDisclosureIndicatorImage
    //- QMUICMI.tableViewCellCheckmarkImage = [UIImage qmui_imageWithShape:QMUIImageShapeCheckmark size:CGSizeMake(15, 12) tintColor:UIColorBlue];     // TableViewCellCheckmarkImage
    //- QMUICMI.tableViewSectionHeaderBackgroundColor = UIColorMake(244, 244, 244);                         // TableViewSectionHeaderBackgroundColor
    //- QMUICMI.tableViewSectionFooterBackgroundColor = UIColorMake(244, 244, 244);                         // TableViewSectionFooterBackgroundColor
    //- QMUICMI.tableViewSectionHeaderFont = UIFontBoldMake(12);                                            // TableViewSectionHeaderFont
    //- QMUICMI.tableViewSectionFooterFont = UIFontBoldMake(12);                                            // TableViewSectionFooterFont
    //- QMUICMI.tableViewSectionHeaderTextColor = UIColorGrayDarken;                                        // TableViewSectionHeaderTextColor
    //- QMUICMI.tableViewSectionFooterTextColor = UIColorGray;                                              // TableViewSectionFooterTextColor
    //- QMUICMI.tableViewSectionHeaderHeight = 20;                                                          // TableViewSectionHeaderHeight
    //- QMUICMI.tableViewSectionFooterHeight = 0;                                                           // TableViewSectionFooterHeight
    //- QMUICMI.tableViewSectionHeaderContentInset = UIEdgeInsetsMake(4, 15, 4, 15);                        // TableViewSectionHeaderContentInset
    //- QMUICMI.tableViewSectionFooterContentInset = UIEdgeInsetsMake(4, 15, 4, 15);                        // TableViewSectionHeaderContentInset
    
    //- QMUICMI.tableViewGroupedSectionHeaderFont = UIFontMake(12);                                         // TableViewGroupedSectionHeaderFont
    //- QMUICMI.tableViewGroupedSectionFooterFont = UIFontMake(12);                                         // TableViewGroupedSectionFooterFont
    //- QMUICMI.tableViewGroupedSectionHeaderTextColor = UIColorGrayDarken;                                 // TableViewGroupedSectionHeaderTextColor
    //- QMUICMI.tableViewGroupedSectionFooterTextColor = UIColorGray;                                       // TableViewGroupedSectionFooterTextColor
    //- QMUICMI.tableViewGroupedSectionHeaderHeight = 15;                                                   // TableViewGroupedSectionHeaderHeight
    //- QMUICMI.tableViewGroupedSectionFooterHeight = 1;                                                    // TableViewGroupedSectionFooterHeight
    //- QMUICMI.tableViewGroupedSectionHeaderContentInset = UIEdgeInsetsMake(16, 15, 8, 15);                // TableViewGroupedSectionHeaderContentInset
    //- QMUICMI.tableViewGroupedSectionFooterContentInset = UIEdgeInsetsMake(8, 15, 2, 15);                 // TableViewGroupedSectionFooterContentInset
    
    //- QMUICMI.tableViewCellTitleLabelColor = UIColorBlack;                                                // TableViewCellTitleLabelColor
    //- QMUICMI.tableViewCellDetailLabelColor = UIColorGray;                                                // TableViewCellDetailLabelColor
    //- QMUICMI.tableViewCellContentDefaultPaddingLeft = 15;                                                // TableViewCellContentDefaultPaddingLeft
    //- QMUICMI.tableViewCellContentDefaultPaddingRight = 10;                                               // TableViewCellContentDefaultPaddingRight
    
    #pragma mark - UIWindowLevel
    //- QMUICMI.windowLevelQMUIAlertView = UIWindowLevelAlert - 4.0;                    // UIWindowLevelQMUIAlertView
    //- QMUICMI.windowLevelQMUIActionSheet = UIWindowLevelAlert - 4.0;                  // UIWindowLevelQMUIActionSheet
    //- QMUICMI.windowLevelQMUIMoreOperationController = UIWindowLevelStatusBar + 1.0;  // UIWindowLevelQMUIMoreOperationController
    //- QMUICMI.windowLevelQMUIImagePreviewView = UIWindowLevelStatusBar + 1.0;              // UIWindowLevelQMUIImagePreviewView
    
    #pragma mark - Others
    
    //- QMUICMI.supportedOrientationMask = UIInterfaceOrientationMaskPortrait;  // SupportedOrientationMask : 默认支持的横竖屏方向
    //- QMUICMI.statusbarStyleLightInitially = NO;          // StatusbarStyleLightInitially : 默认的状态栏内容是否使用白色，默认为NO，也即黑色
    //- QMUICMI.needsBackBarButtonItemTitle = NO;           // NeedsBackBarButtonItemTitle : 全局是否需要返回按钮的title，不需要则只显示一个返回image
    //- QMUICMI.hidesBottomBarWhenPushedInitially = YES;    // HidesBottomBarWhenPushedInitially : QMUICommonViewController.hidesBottomBarWhenPushed的初始值，默认为YES
}

@end
