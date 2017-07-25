//
//  QMUIConfiguration.m
//  qmui
//
//  Created by QQMail on 15/3/29.
//  Copyright (c) 2015年 QMUI Team. All rights reserved.
//

#import "QMUIConfiguration.h"
#import "QMUICore.h"
#import "UIImage+QMUI.h"
#import "QMUIButton.h"
#import "NSString+QMUI.h"
#import "QMUITabBarViewController.h"
#import "QMUINavigationController.h"

@implementation QMUIConfiguration

+ (instancetype)sharedInstance {
    static dispatch_once_t pred;
    static QMUIConfiguration *sharedInstance = nil;
    
    // 检查是否有在某些类的 +load 方法里调用 QMUICMI，因为在 [QMUIConfiguration init] 方法里会操作到 UI 的东西，例如 [UINavigationBar appearance] xxx 等，这些操作不能太早（+load 里就太早了）执行，否则会 crash，所以加这个检测
//#ifdef DEBUG
//    BOOL shouldCheckCallStack = NO;
//    if (shouldCheckCallStack) {
//        for (NSString *symbol in [NSThread callStackSymbols]) {
//            if ([symbol qmui_includesString:@" load]"]) {
//                NSAssert(NO, @"不应该在 + load 方法里调用 %s", __func__);
//                return nil;
//            }
//        }
//    }
//#endif
    
    dispatch_once(&pred, ^{
        sharedInstance = [[QMUIConfiguration alloc] init];
    });
    return sharedInstance;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        [self initDefaultConfiguration];
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
    self.redColor = UIColorMake(250, 58, 58);
    self.greenColor = UIColorMake(159, 214, 97);
    self.blueColor = UIColorMake(49, 189, 243);
    self.yellowColor = UIColorMake(255, 207, 71);

    self.linkColor = UIColorMake(56, 116, 171);
    self.disabledColor = self.grayColor;
    self.backgroundColor = nil;
    self.maskDarkColor = UIColorMakeWithRGBA(0, 0, 0, .35f);
    self.maskLightColor = UIColorMakeWithRGBA(255, 255, 255, .5f);
    self.separatorColor = UIColorMake(222, 224, 226);
    self.separatorDashedColor = UIColorMake(17, 17, 17);
    self.placeholderColor = UIColorMake(196, 200, 208);
    
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
    
    self.textFieldTintColor = nil;
    self.textFieldTextInsets = UIEdgeInsetsMake(0, 7, 0, 7);
    
    #pragma mark - NavigationBar
    
    self.navBarHighlightedAlpha = 0.2f;
    self.navBarDisabledAlpha = 0.2f;
    self.navBarButtonFont = nil;
    self.navBarButtonFontBold = nil;
    self.navBarBackgroundImage = nil;
    self.navBarShadowImage = nil;
    self.navBarBarTintColor = nil;
    self.navBarTintColor = nil;
    self.navBarTitleColor = self.blackColor;
    self.navBarTitleFont = nil;
    self.navBarBackButtonTitlePositionAdjustment = UIOffsetZero;
    self.navBarBackIndicatorImage = nil;
    self.navBarCloseButtonImage = [UIImage qmui_imageWithShape:QMUIImageShapeNavClose size:CGSizeMake(16, 16) tintColor:self.navBarTintColor];
    
    self.navBarLoadingMarginRight = 3;
    self.navBarAccessoryViewMarginLeft = 5;
    self.navBarActivityIndicatorViewStyle = UIActivityIndicatorViewStyleGray;
    self.navBarAccessoryViewTypeDisclosureIndicatorImage = [[UIImage qmui_imageWithShape:QMUIImageShapeTriangle size:CGSizeMake(8, 5) tintColor:self.navBarTitleColor] qmui_imageWithOrientation:UIImageOrientationDown];
    
    #pragma mark - TabBar
    
    self.tabBarBackgroundImage = nil;
    self.tabBarBarTintColor = nil;
    self.tabBarShadowImageColor = nil;
    self.tabBarTintColor = nil;
    self.tabBarItemTitleColor = nil;
    self.tabBarItemTitleColorSelected = self.tabBarTintColor;
    self.tabBarItemTitleFont = nil;
    
    #pragma mark - Toolbar
    
    self.toolBarHighlightedAlpha = 0.4f;
    self.toolBarDisabledAlpha = 0.4f;
    self.toolBarTintColor = nil;
    self.toolBarTintColorHighlighted = [self.toolBarTintColor colorWithAlphaComponent:self.toolBarHighlightedAlpha];
    self.toolBarTintColorDisabled = [self.toolBarTintColor colorWithAlphaComponent:self.toolBarDisabledAlpha];
    self.toolBarBackgroundImage = nil;
    self.toolBarBarTintColor = nil;
    self.toolBarShadowImageColor = nil;
    self.toolBarButtonFont = nil;
    
    #pragma mark - SearchBar
    
    self.searchBarTextFieldBackground = nil;
    self.searchBarTextFieldBorderColor = nil;
    self.searchBarBottomBorderColor = nil;
    self.searchBarBarTintColor = nil;
    self.searchBarTintColor = nil;
    self.searchBarTextColor = nil;
    self.searchBarPlaceholderColor = self.placeholderColor;
    self.searchBarFont = nil;
    self.searchBarSearchIconImage = nil;
    self.searchBarClearIconImage = nil;
    self.searchBarTextFieldCornerRadius = 2.0;
    
    #pragma mark - TableView / TableViewCell
    
    self.tableViewBackgroundColor = nil;
    self.tableViewGroupedBackgroundColor = nil;
    self.tableSectionIndexColor = nil;
    self.tableSectionIndexBackgroundColor = nil;
    self.tableSectionIndexTrackingBackgroundColor = nil;
    self.tableViewSeparatorColor = self.separatorColor;
    
    self.tableViewCellNormalHeight = 44;
    self.tableViewCellTitleLabelColor = nil;
    self.tableViewCellDetailLabelColor = nil;
    self.tableViewCellBackgroundColor = self.whiteColor;
    self.tableViewCellSelectedBackgroundColor = UIColorMake(238, 239, 241);
    self.tableViewCellWarningBackgroundColor = self.yellowColor;
    self.tableViewCellDisclosureIndicatorImage = nil;
    self.tableViewCellCheckmarkImage = nil;
    self.tableViewCellDetailButtonImage = nil;
    self.tableViewCellSpacingBetweenDetailButtonAndDisclosureIndicator = 12;
    
    self.tableViewSectionHeaderBackgroundColor = UIColorMake(244, 244, 244);
    self.tableViewSectionFooterBackgroundColor = UIColorMake(244, 244, 244);
    self.tableViewSectionHeaderFont = UIFontBoldMake(12);
    self.tableViewSectionFooterFont = UIFontBoldMake(12);
    self.tableViewSectionHeaderTextColor = self.grayDarkenColor;
    self.tableViewSectionFooterTextColor = self.grayColor;
    self.tableViewSectionHeaderHeight = 20;
    self.tableViewSectionFooterHeight = 0;
    self.tableViewSectionHeaderContentInset = UIEdgeInsetsMake(4, 15, 4, 15);
    self.tableViewSectionFooterContentInset = UIEdgeInsetsMake(4, 15, 4, 15);
    
    self.tableViewGroupedSectionHeaderFont = UIFontMake(12);
    self.tableViewGroupedSectionFooterFont = UIFontMake(12);
    self.tableViewGroupedSectionHeaderTextColor = self.grayDarkenColor;
    self.tableViewGroupedSectionFooterTextColor = self.grayColor;
    self.tableViewGroupedSectionHeaderHeight = 15;
    self.tableViewGroupedSectionFooterHeight = 1;
    self.tableViewGroupedSectionHeaderContentInset = UIEdgeInsetsMake(16, 15, 8, 15);
    self.tableViewGroupedSectionFooterContentInset = UIEdgeInsetsMake(8, 15, 2, 15);
    
    #pragma mark - UIWindowLevel
    self.windowLevelQMUIAlertView = UIWindowLevelAlert - 4.0;
    self.windowLevelQMUIImagePreviewView = UIWindowLevelStatusBar + 1;
    
    #pragma mark - Others
    
    self.supportedOrientationMask = UIInterfaceOrientationMaskPortrait;
    self.automaticallyRotateDeviceOrientation = NO;
    self.statusbarStyleLightInitially = NO;
    self.needsBackBarButtonItemTitle = NO;
    self.hidesBottomBarWhenPushedInitially = NO;
    self.navigationBarHiddenInitially = NO;
}

- (void)setNavBarTintColor:(UIColor *)navBarTintColor {
    _navBarTintColor = navBarTintColor;
    [QMUIHelper visibleViewController].navigationController.navigationBar.tintColor = _navBarTintColor;
}

- (void)setNavBarBarTintColor:(UIColor *)navBarBarTintColor {
    _navBarBarTintColor = navBarBarTintColor;
    [UINavigationBar appearance].barTintColor = _navBarBarTintColor;
    [QMUIHelper visibleViewController].navigationController.navigationBar.barTintColor = _navBarBarTintColor;
}

- (void)setNavBarShadowImage:(UIImage *)navBarShadowImage {
    _navBarShadowImage = navBarShadowImage;
    [UINavigationBar appearance].shadowImage = _navBarShadowImage;
    [QMUIHelper visibleViewController].navigationController.navigationBar.shadowImage = _navBarShadowImage;
}

- (void)setNavBarBackgroundImage:(UIImage *)navBarBackgroundImage {
    _navBarBackgroundImage = navBarBackgroundImage;
    [[UINavigationBar appearance] setBackgroundImage:_navBarBackgroundImage forBarMetrics:UIBarMetricsDefault];
    [[QMUIHelper visibleViewController].navigationController.navigationBar setBackgroundImage:_navBarBackgroundImage forBarMetrics:UIBarMetricsDefault];
}

- (void)setNavBarTitleFont:(UIFont *)navBarTitleFont {
    _navBarTitleFont = navBarTitleFont;
    if (self.navBarTitleFont || self.navBarTitleColor) {
        NSMutableDictionary<NSString *, id> *titleTextAttributes = [[NSMutableDictionary alloc] init];
        if (self.navBarTitleFont) {
            [titleTextAttributes setValue:self.navBarTitleFont forKey:NSFontAttributeName];
        }
        if (self.navBarTitleColor) {
            [titleTextAttributes setValue:self.navBarTitleColor forKey:NSForegroundColorAttributeName];
        }
        [UINavigationBar appearance].titleTextAttributes = titleTextAttributes;
        [QMUIHelper visibleViewController].navigationController.navigationBar.titleTextAttributes = titleTextAttributes;
    }
}

- (void)setNavBarTitleColor:(UIColor *)navBarTitleColor {
    _navBarTitleColor = navBarTitleColor;
    if (self.navBarTitleFont || self.navBarTitleColor) {
        NSMutableDictionary<NSString *, id> *titleTextAttributes = [[NSMutableDictionary alloc] init];
        if (self.navBarTitleFont) {
            [titleTextAttributes setValue:self.navBarTitleFont forKey:NSFontAttributeName];
        }
        if (self.navBarTitleColor) {
            [titleTextAttributes setValue:self.navBarTitleColor forKey:NSForegroundColorAttributeName];
        }
        [UINavigationBar appearance].titleTextAttributes = titleTextAttributes;
        [QMUIHelper visibleViewController].navigationController.navigationBar.titleTextAttributes = titleTextAttributes;
    }
}

- (void)setNavBarBackIndicatorImage:(UIImage *)navBarBackIndicatorImage {
    _navBarBackIndicatorImage = navBarBackIndicatorImage;
    
    if (_navBarBackIndicatorImage) {
        UINavigationBar *navBarAppearance = [UINavigationBar appearance];
        UINavigationBar *navigationBar = [QMUIHelper visibleViewController].navigationController.navigationBar;
        
        // 返回按钮的图片frame是和系统默认的返回图片的大小一致的（13, 21），所以用自定义返回箭头时要保证图片大小与系统的箭头大小一样，否则无法对齐
        CGSize systemBackIndicatorImageSize = CGSizeMake(13, 21); // 在iOS 8-11 上实际测量得到
        CGSize customBackIndicatorImageSize = _navBarBackIndicatorImage.size;
        if (!CGSizeEqualToSize(customBackIndicatorImageSize, systemBackIndicatorImageSize)) {
            CGFloat imageExtensionVerticalFloat = CGFloatGetCenter(systemBackIndicatorImageSize.height, customBackIndicatorImageSize.height);
            _navBarBackIndicatorImage = [_navBarBackIndicatorImage qmui_imageWithSpacingExtensionInsets:UIEdgeInsetsMake(imageExtensionVerticalFloat,
                                                                                                                         0,
                                                                                                                         imageExtensionVerticalFloat,
                                                                                                                         systemBackIndicatorImageSize.width - customBackIndicatorImageSize.width)];
        }
        
        navBarAppearance.backIndicatorImage = _navBarBackIndicatorImage;
        navBarAppearance.backIndicatorTransitionMaskImage = navBarAppearance.backIndicatorImage;
        navigationBar.backIndicatorImage = _navBarBackIndicatorImage;
        navigationBar.backIndicatorTransitionMaskImage = navigationBar.backIndicatorImage;
    }
}

- (void)setNavBarBackButtonTitlePositionAdjustment:(UIOffset)navBarBackButtonTitlePositionAdjustment {
    _navBarBackButtonTitlePositionAdjustment = navBarBackButtonTitlePositionAdjustment;
    
    if (!UIOffsetEqualToOffset(UIOffsetZero, _navBarBackButtonTitlePositionAdjustment)) {
        UIBarButtonItem *backBarButtonItem = [UIBarButtonItem appearance];
        [backBarButtonItem setBackButtonTitlePositionAdjustment:_navBarBackButtonTitlePositionAdjustment forBarMetrics:UIBarMetricsDefault];
        [[QMUIHelper visibleViewController].navigationController.navigationItem.backBarButtonItem setBackButtonTitlePositionAdjustment:_navBarBackButtonTitlePositionAdjustment forBarMetrics:UIBarMetricsDefault];
    }
}

- (void)setToolBarTintColor:(UIColor *)toolBarTintColor {
    _toolBarTintColor = toolBarTintColor;
    [QMUIHelper visibleViewController].navigationController.toolbar.tintColor = _toolBarTintColor;
}

- (void)setToolBarBarTintColor:(UIColor *)toolBarBarTintColor {
    _toolBarBarTintColor = toolBarBarTintColor;
    [UIToolbar appearance].barTintColor = _toolBarBarTintColor;
    [QMUIHelper visibleViewController].navigationController.toolbar.barTintColor = _toolBarBarTintColor;
}

- (void)setToolBarBackgroundImage:(UIImage *)toolBarBackgroundImage {
    _toolBarBackgroundImage = toolBarBackgroundImage;
    [[UIToolbar appearance] setBackgroundImage:_toolBarBackgroundImage forToolbarPosition:UIBarPositionAny barMetrics:UIBarMetricsDefault];
    [[QMUIHelper visibleViewController].navigationController.toolbar setBackgroundImage:_toolBarBackgroundImage forToolbarPosition:UIBarPositionAny barMetrics:UIBarMetricsDefault];
}

- (void)setToolBarShadowImageColor:(UIColor *)toolBarShadowImageColor {
    _toolBarShadowImageColor = toolBarShadowImageColor;
    if (_toolBarShadowImageColor) {
        UIImage *shadowImage = [UIImage qmui_imageWithColor:_toolBarShadowImageColor size:CGSizeMake(1, PixelOne) cornerRadius:0];
        [[UIToolbar appearance] setShadowImage:shadowImage forToolbarPosition:UIBarPositionAny];
        [[QMUIHelper visibleViewController].navigationController.toolbar setShadowImage:shadowImage forToolbarPosition:UIBarPositionAny];
    }
}

- (void)setTabBarTintColor:(UIColor *)tabBarTintColor {
    _tabBarTintColor = tabBarTintColor;
    [QMUIHelper visibleViewController].tabBarController.tabBar.tintColor = _tabBarTintColor;
}

- (void)setTabBarBarTintColor:(UIColor *)tabBarBarTintColor {
    _tabBarBarTintColor = tabBarBarTintColor;
    [UITabBar appearance].barTintColor = _tabBarBarTintColor;
    [QMUIHelper visibleViewController].tabBarController.tabBar.barTintColor = _tabBarBarTintColor;
}

- (void)setTabBarBackgroundImage:(UIImage *)tabBarBackgroundImage {
    _tabBarBackgroundImage = tabBarBackgroundImage;
    [UITabBar appearance].backgroundImage = _tabBarBackgroundImage;
    [QMUIHelper visibleViewController].tabBarController.tabBar.backgroundImage = _tabBarBackgroundImage;
}

- (void)setTabBarShadowImageColor:(UIColor *)tabBarShadowImageColor {
    _tabBarShadowImageColor = tabBarShadowImageColor;
    if (_tabBarShadowImageColor) {
        UIImage *shadowImage = [UIImage qmui_imageWithColor:_tabBarShadowImageColor size:CGSizeMake(1, PixelOne) cornerRadius:0];
        [[UITabBar appearance] setShadowImage:shadowImage];
        [QMUIHelper visibleViewController].tabBarController.tabBar.shadowImage = shadowImage;
    }
}

- (void)setTabBarItemTitleColor:(UIColor *)tabBarItemTitleColor {
    _tabBarItemTitleColor = tabBarItemTitleColor;
    if (_tabBarItemTitleColor) {
        NSMutableDictionary<NSString *, id> *textAttributes = [[NSMutableDictionary alloc] initWithDictionary:[[UITabBarItem appearance] titleTextAttributesForState:UIControlStateNormal]];
        textAttributes[NSForegroundColorAttributeName] = _tabBarItemTitleColor;
        [[UITabBarItem appearance] setTitleTextAttributes:textAttributes forState:UIControlStateNormal];
        [[QMUIHelper visibleViewController].tabBarController.tabBar.items enumerateObjectsUsingBlock:^(UITabBarItem * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            [obj setTitleTextAttributes:textAttributes forState:UIControlStateNormal];
        }];
    }
}

- (void)setTabBarItemTitleFont:(UIFont *)tabBarItemTitleFont {
    _tabBarItemTitleFont = tabBarItemTitleFont;
    if (_tabBarItemTitleFont) {
        NSMutableDictionary<NSString *, id> *textAttributes = [[NSMutableDictionary alloc] initWithDictionary:[[UITabBarItem appearance] titleTextAttributesForState:UIControlStateNormal]];
        textAttributes[NSFontAttributeName] = _tabBarItemTitleFont;
        [[UITabBarItem appearance] setTitleTextAttributes:textAttributes forState:UIControlStateNormal];
        [[QMUIHelper visibleViewController].tabBarController.tabBar.items enumerateObjectsUsingBlock:^(UITabBarItem * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            [obj setTitleTextAttributes:textAttributes forState:UIControlStateNormal];
        }];
    }
}

- (void)setTabBarItemTitleColorSelected:(UIColor *)tabBarItemTitleColorSelected {
    _tabBarItemTitleColorSelected = tabBarItemTitleColorSelected;
    if (_tabBarItemTitleColorSelected) {
        NSMutableDictionary<NSString *, id> *textAttributes = [[NSMutableDictionary alloc] initWithDictionary:[[UITabBarItem appearance] titleTextAttributesForState:UIControlStateSelected]];
        textAttributes[NSForegroundColorAttributeName] = _tabBarItemTitleColorSelected;
        [[UITabBarItem appearance] setTitleTextAttributes:textAttributes forState:UIControlStateSelected];
        [[QMUIHelper visibleViewController].tabBarController.tabBar.items enumerateObjectsUsingBlock:^(UITabBarItem * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            [obj setTitleTextAttributes:textAttributes forState:UIControlStateSelected];
        }];
    }
}

@end
