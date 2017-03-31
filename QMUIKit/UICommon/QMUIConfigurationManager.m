//
//  QMUIConfigurationManager.m
//  qmui
//
//  Created by QQMail on 15/3/29.
//  Copyright (c) 2015年 QMUI Team. All rights reserved.
//

#import "QMUIConfigurationManager.h"
#import "QMUICommonDefines.h"
#import "QMUIConfiguration.h"
#import "UIImage+QMUI.h"
#import "QMUIButton.h"
#import "QMUITabBarViewController.h"

@implementation QMUIConfigurationManager

+ (QMUIConfigurationManager *) sharedInstance {
    static dispatch_once_t pred;
    static QMUIConfigurationManager *sharedInstance = nil;
    dispatch_once(&pred, ^{
        sharedInstance = [[QMUIConfigurationManager alloc] init];
    });
    return sharedInstance;
}

- (instancetype)init {
    self = [super init];
    if (self) {
    }
    return self;
}

#pragma mark - 初始化默认值

- (void)initDefaultConfiguration {
    
    #pragma mark - Global Color
    
    self.clearColor = [UIColor colorWithRed:1 green:1 blue:1 alpha:0];
    self.whiteColor = [UIColor colorWithRed:1 green:1 blue:1 alpha:1];
    self.blackColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:1];
    self.grayColor = UIColorMake(179, 179, 179);
    self.grayDarkenColor = UIColorMake(163, 163, 163);
    self.grayLightenColor = UIColorMake(198, 198, 198);
    self.redColor = UIColorMake(227, 40, 40);
    self.greenColor = UIColorMake(79, 214, 79);
    self.blueColor = UIColorMake(43, 133, 208);
    self.yellowColor = UIColorMake(255, 252, 233);

    self.linkColor = UIColorMake(56, 116, 171);
    self.disabledColor = self.grayColor;
    self.backgroundColor = UIColorMake(246, 246, 246);
    self.maskDarkColor = UIColorMakeWithRGBA(0, 0, 0, .35f);
    self.maskLightColor = UIColorMakeWithRGBA(255, 255, 255, .5f);
    self.separatorColor = UIColorMake(200, 199, 204);
    self.separatorDashedColor = UIColorMake(17, 17, 17);
    self.placeholderColor = UIColorMake(187, 187, 187);
    
    self.testColorRed = UIColorMakeWithRGBA(255, 0, 0, .3);
    self.testColorGreen = UIColorMakeWithRGBA(0, 255, 0, .3);
    self.testColorBlue = UIColorMakeWithRGBA(0, 0, 255, .3);
    
    #pragma mark - UIControl
    
    self.controlHighlightedAlpha = 0.5f;
    self.controlDisabledAlpha = 0.5f;
    
    #pragma mark - UIButton
    
    self.buttonHighlightedAlpha = self.controlHighlightedAlpha;
    self.buttonDisabledAlpha = self.controlDisabledAlpha;
    self.buttonTintColor = self.blueColor;
    
    self.ghostButtonColorBlue = self.blueColor;
    self.ghostButtonColorRed = self.redColor;
    self.ghostButtonColorGreen = self.greenColor;
    self.ghostButtonColorGray = self.grayColor;
    self.ghostButtonColorWhite = self.whiteColor;
    
    self.fillButtonColorBlue = self.blueColor;
    self.fillButtonColorRed = self.redColor;
    self.fillButtonColorGreen = self.greenColor;
    self.fillButtonColorGray = self.grayColor;
    self.fillButtonColorWhite = self.whiteColor;
    
    #pragma mark - UITextField & UITextView
    
    self.textFieldTintColor = UIColorBlue;
    self.textFieldTextInsets = UIEdgeInsetsMake(0, 7, 0, 7);
    
    #pragma mark - NavigationBar
    
    self.navBarHighlightedAlpha = 0.2f;
    self.navBarDisabledAlpha = 0.2f;
    self.navBarButtonFont = UIFontMake(17);
    self.navBarButtonFontBold = UIFontBoldMake(17);
    self.navBarBackgroundImage = nil;
    self.navBarShadowImage = nil;
    self.navBarBarTintColor = nil;
    self.navBarTintColor = self.blackColor;
    self.navBarTitleColor = self.navBarTintColor;
    self.navBarTitleFont = UIFontBoldMake(17);
    self.navBarBackButtonTitlePositionAdjustment = UIOffsetZero;
    self.navBarBackIndicatorImage = [UIImage qmui_imageWithShape:QMUIImageShapeNavBack size:CGSizeMake(12, 20) tintColor:self.navBarTintColor];
    self.navBarCloseButtonImage = [UIImage qmui_imageWithShape:QMUIImageShapeNavClose size:CGSizeMake(16, 16) tintColor:self.navBarTintColor];
    
    self.navBarLoadingMarginRight = 3;
    self.navBarAccessoryViewMarginLeft = 5;
    self.navBarActivityIndicatorViewStyle = UIActivityIndicatorViewStyleGray;
    self.navBarAccessoryViewTypeDisclosureIndicatorImage = [[UIImage qmui_imageWithShape:QMUIImageShapeTriangle size:CGSizeMake(8, 5) tintColor:self.whiteColor] qmui_imageWithOrientation:UIImageOrientationDown];
    
    #pragma mark - TabBar
    
    self.tabBarBackgroundImage = nil;
    self.tabBarBarTintColor = nil;
    self.tabBarShadowImageColor = nil;
    self.tabBarTintColor = UIColorMake(22, 147, 229);
    self.tabBarItemTitleColor = UIColorMake(119, 119, 119);
    self.tabBarItemTitleColorSelected = self.tabBarTintColor;
    
    #pragma mark - Toolbar
    
    self.toolBarHighlightedAlpha = 0.4f;
    self.toolBarDisabledAlpha = 0.4f;
    self.toolBarTintColor = self.blueColor;
    self.toolBarTintColorHighlighted = [self.toolBarTintColor colorWithAlphaComponent:self.toolBarHighlightedAlpha];
    self.toolBarTintColorDisabled = [self.toolBarTintColor colorWithAlphaComponent:self.toolBarDisabledAlpha];
    self.toolBarBackgroundImage = nil;
    self.toolBarBarTintColor = nil;
    self.toolBarShadowImageColor = UIColorMake(178, 178, 178);
    self.toolBarButtonFont = UIFontMake(17);
    
    #pragma mark - SearchBar
    
    self.searchBarTextFieldBackground = self.whiteColor;
    self.searchBarTextFieldBorderColor = UIColorMake(205, 208, 210);
    self.searchBarBottomBorderColor = UIColorMake(205, 208, 210);
    self.searchBarBarTintColor = UIColorMake(247, 247, 247);
    self.searchBarTintColor = self.blueColor;
    self.searchBarTextColor = self.blackColor;
    self.searchBarPlaceholderColor = self.placeholderColor;
    self.searchBarSearchIconImage = nil;
    self.searchBarClearIconImage = nil;
    self.searchBarTextFieldCornerRadius = 2.0;
    
    #pragma mark - TableView / TableViewCell
    
    self.tableViewBackgroundColor = self.whiteColor;
    self.tableViewGroupedBackgroundColor = self.backgroundColor;
    self.tableSectionIndexColor = self.grayDarkenColor;
    self.tableSectionIndexBackgroundColor = self.clearColor;
    self.tableSectionIndexTrackingBackgroundColor = self.clearColor;
    self.tableViewSeparatorColor = self.separatorColor;
    
    self.tableViewCellNormalHeight = 44;
    self.tableViewCellTitleLabelColor = self.blackColor;
    self.tableViewCellDetailLabelColor = self.grayColor;
    self.tableViewCellContentDefaultPaddingLeft = 15;
    self.tableViewCellContentDefaultPaddingRight = 10;
    self.tableViewCellBackgroundColor = self.whiteColor;
    self.tableViewCellSelectedBackgroundColor = UIColorMake(232, 232, 232);
    self.tableViewCellWarningBackgroundColor = self.yellowColor;
    self.tableViewCellDisclosureIndicatorImage = [UIImage qmui_imageWithShape:QMUIImageShapeDisclosureIndicator size:CGSizeMake(8, 13) tintColor:UIColorMakeWithRGBA(0, 0, 0, .2)];
    self.tableViewCellCheckmarkImage = [UIImage qmui_imageWithShape:QMUIImageShapeCheckmark size:CGSizeMake(15, 12) tintColor:UIColorBlue];
    
    self.tableViewSectionHeaderBackgroundColor = UIColorMake(244, 244, 244);
    self.tableViewSectionFooterBackgroundColor = UIColorMake(244, 244, 244);
    self.tableViewSectionHeaderFont = UIFontBoldMake(12);
    self.tableViewSectionFooterFont = UIFontBoldMake(12);
    self.tableViewSectionHeaderTextColor = UIColorGrayDarken;
    self.tableViewSectionFooterTextColor = UIColorGray;
    self.tableViewSectionHeaderHeight = 20;
    self.tableViewSectionFooterHeight = 0;
    self.tableViewSectionHeaderContentInset = UIEdgeInsetsMake(4, 15, 4, 15);
    self.tableViewSectionFooterContentInset = UIEdgeInsetsMake(4, 15, 4, 15);
    
    self.tableViewGroupedSectionHeaderFont = UIFontMake(12);
    self.tableViewGroupedSectionFooterFont = UIFontMake(12);
    self.tableViewGroupedSectionHeaderTextColor = UIColorGrayDarken;
    self.tableViewGroupedSectionFooterTextColor = UIColorGray;
    self.tableViewGroupedSectionHeaderHeight = 15;
    self.tableViewGroupedSectionFooterHeight = 1;
    self.tableViewGroupedSectionHeaderContentInset = UIEdgeInsetsMake(16, 15, 8, 15);
    self.tableViewGroupedSectionFooterContentInset = UIEdgeInsetsMake(8, 15, 2, 15);
    
    #pragma mark - UIWindowLevel
    self.windowLevelQMUIAlertView = UIWindowLevelAlert - 4.0;
    self.windowLevelQMUIImagePreviewView = UIWindowLevelStatusBar + 1;
    
    #pragma mark - Others
    
    self.supportedOrientationMask = UIInterfaceOrientationMaskPortrait;
    self.statusbarStyleLightInitially = NO;
    self.needsBackBarButtonItemTitle = NO;
    self.hidesBottomBarWhenPushedInitially = YES;
}

@end

@implementation QMUIConfigurationManager (UIAppearance)

+ (void)renderGlobalAppearances {
    
    // QMUIButton
    [QMUINavigationButton renderNavigationButtonAppearanceStyle];
    [QMUIToolbarButton renderToolbarButtonAppearanceStyle];
    
    // UINavigationBar
    UINavigationBar *navigationBarAppearance = [UINavigationBar appearance];
    navigationBarAppearance.barTintColor = NavBarBarTintColor;
    navigationBarAppearance.shadowImage = NavBarShadowImage;
    [navigationBarAppearance setBackgroundImage:NavBarBackgroundImage forBarMetrics:UIBarMetricsDefault];
    
    UIFont *navigationBarTitleFont = NavBarTitleFont;
    UIColor *navigationBarTitleColor = NavBarTitleColor;
    if (navigationBarTitleFont || navigationBarTitleColor) {
        NSMutableDictionary<NSString *, id> *titleTextAttributes = [[NSMutableDictionary alloc] init];
        if (navigationBarTitleFont) {
            [titleTextAttributes setValue:navigationBarTitleFont forKey:NSFontAttributeName];
        }
        if (navigationBarTitleColor) {
            [titleTextAttributes setValue:navigationBarTitleColor forKey:NSForegroundColorAttributeName];
        }
        navigationBarAppearance.titleTextAttributes = titleTextAttributes;
    }
    
    // UIToolBar
    UIToolbar *toolBarAppearance = [UIToolbar appearance];
    toolBarAppearance.barTintColor = ToolBarBarTintColor;
    [toolBarAppearance setBackgroundImage:ToolBarBackgroundImage forToolbarPosition:UIBarPositionAny barMetrics:UIBarMetricsDefault];
    
    UIColor *toolbarShadowImageColor = ToolBarShadowImageColor;
    if (toolbarShadowImageColor) {
        [toolBarAppearance setShadowImage:[UIImage qmui_imageWithColor:toolbarShadowImageColor size:CGSizeMake(1, PixelOne) cornerRadius:0] forToolbarPosition:UIBarPositionAny];
    }
    
    // UITabBar
    UITabBar *tabBarAppearance = [UITabBar appearance];
    tabBarAppearance.barTintColor = TabBarBarTintColor;
    tabBarAppearance.backgroundImage = TabBarBackgroundImage;
    UIColor *tabBarShadowImageColor = TabBarShadowImageColor;
    if (tabBarShadowImageColor) {
        [tabBarAppearance setShadowImage:[UIImage qmui_imageWithColor:tabBarShadowImageColor size:CGSizeMake(1, PixelOne) cornerRadius:0]];
    }
    
    // UITabBarItem
    UITabBarItem *tabBarItemAppearance = [UITabBarItem appearance];
    
    UIColor *tabBarItemTitleColor = TabBarItemTitleColor;
    if (tabBarItemTitleColor) {
        [tabBarItemAppearance setTitleTextAttributes:@{NSForegroundColorAttributeName:tabBarItemTitleColor} forState:UIControlStateNormal];
    }
    
    UIColor *tabBarItemTitleColorSelected = TabBarItemTitleColorSelected;
    if (tabBarItemTitleColorSelected) {
        [tabBarItemAppearance setTitleTextAttributes:@{NSForegroundColorAttributeName:tabBarItemTitleColorSelected} forState:UIControlStateSelected];
    }
}

@end
