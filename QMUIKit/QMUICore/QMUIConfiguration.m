/**
 * Tencent is pleased to support the open source community by making QMUI_iOS available.
 * Copyright (C) 2016-2021 THL A29 Limited, a Tencent company. All rights reserved.
 * Licensed under the MIT License (the "License"); you may not use this file except in compliance with the License. You may obtain a copy of the License at
 * http://opensource.org/licenses/MIT
 * Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.
 */

//
//  QMUIConfiguration.m
//  qmui
//
//  Created by QMUI Team on 15/3/29.
//

#import "QMUIConfiguration.h"
#import "QMUICore.h"
#import "UIImage+QMUI.h"
#import "NSString+QMUI.h"
#import "UIViewController+QMUI.h"
#import "QMUIKit.h"// 为了引入其中定义的 QMUI_VERSION

// 在 iOS 8 - 11 上实际测量得到
// Measured on iOS 8 - 11
const CGSize kUINavigationBarBackIndicatorImageSize = {13, 21};

@interface QMUIConfiguration ()

@property(nonatomic, strong) UINavigationBarAppearance *navigationBarAppearance API_AVAILABLE(ios(15.0));
@property(nonatomic, strong) UIToolbarAppearance *toolBarAppearance API_AVAILABLE(ios(15.0));
@property(nonatomic, strong) UITabBarAppearance *tabBarAppearance API_AVAILABLE(ios(13.0));
@end

@implementation UIViewController (QMUIConfiguration)

- (NSArray <UIViewController *>*)qmui_existingViewControllersOfClasses:(NSArray<Class<UIAppearanceContainer>> *)classes {
    NSMutableSet *viewControllers = [NSMutableSet set];
    if (self.presentedViewController) {
        [viewControllers addObjectsFromArray:[self.presentedViewController qmui_existingViewControllersOfClasses:classes]];
    }
    if ([self isKindOfClass:UINavigationController.class]) {
        [viewControllers addObjectsFromArray:[((UINavigationController *)self).visibleViewController qmui_existingViewControllersOfClasses:classes]];
    } else if ([self isKindOfClass:UITabBarController.class]) {
        [viewControllers addObjectsFromArray:[((UITabBarController *)self).selectedViewController qmui_existingViewControllersOfClasses:classes]];
    } else {
        // 如果不是常见的 container viewController，则直接获取所有 childViewController
        for (UIViewController *child in self.childViewControllers) {
            [viewControllers addObjectsFromArray:[child qmui_existingViewControllersOfClasses:classes]];
        }
    }
    
    for (Class class in classes) {
        if ([self isKindOfClass:class]) {
            [viewControllers addObject:self];
            break;
        }
    }
    return viewControllers.allObjects;
}

@end

@implementation QMUIConfiguration

+ (instancetype)sharedInstance {
    static dispatch_once_t pred;
    static QMUIConfiguration *sharedInstance;
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

static BOOL QMUI_hasAppliedInitialTemplate;
- (void)applyInitialTemplate {
    // XCTest 无法加载配置表，因此没有寻找 classes 的必要
    // https://github.com/Tencent/QMUI_iOS/issues/1312
    if (QMUI_hasAppliedInitialTemplate || IS_XCTEST) {
        return;
    }
    
    // 自动寻找并应用模板
    // Automatically look for templates and apply them
    // @see https://github.com/Tencent/QMUI_iOS/issues/264
    Protocol *protocol = @protocol(QMUIConfigurationTemplateProtocol);
    classref_t *classesref = nil;
    Class *classes = nil;
    int numberOfClasses = qmui_getProjectClassList(&classesref);
    if (numberOfClasses <= 0) {
        numberOfClasses = objc_getClassList(NULL, 0);
        classes = (__unsafe_unretained Class *)malloc(sizeof(Class) * numberOfClasses);
        objc_getClassList(classes, numberOfClasses);
        NSAssert(NO, @"如果你看到这条提示，建议到 GitHub 上提 issue，让我们联系你查看项目的配置表使用情况，否则请注释掉这一行。");
    }
    for (NSInteger i = 0; i < numberOfClasses; i++) {
        Class class = classesref ? (__bridge Class)classesref[i] : classes[i];
        // 这里用 containsString 是考虑到 Swift 里 className 由“项目前缀+class 名”组成，如果用 hasPrefix 就无法判断了
        // Use `containsString` instead of `hasPrefix` because class names in Swift have project prefix prepended
        if ([NSStringFromClass(class) containsString:@"QMUIConfigurationTemplate"] && [class conformsToProtocol:protocol]) {
            if ([class instancesRespondToSelector:@selector(shouldApplyTemplateAutomatically)]) {
                id<QMUIConfigurationTemplateProtocol> template = [[class alloc] init];
                if ([template shouldApplyTemplateAutomatically]) {
                    QMUI_hasAppliedInitialTemplate = YES;
                    _active = YES;// 标志配置表已生效
                    [template applyConfigurationTemplate];
                    // 只应用第一个 shouldApplyTemplateAutomatically 的主题
                    // Only apply the first template returned
                    break;
                }
            }
        }
    }
    
    if (IS_DEBUG && self.sendAnalyticsToQMUITeam) {
        [[NSNotificationCenter defaultCenter] addObserverForName:UIApplicationDidFinishLaunchingNotification object:nil queue:[NSOperationQueue new] usingBlock:^(NSNotification * _Nonnull note) {
            // 这里根据是否能成功获取到 classesref 来统计信息，以供后续确认对 classesref 为 nil 的保护是否真的必要
            [self sendAnalyticsWithQuery:classes ? @"findByObjc=true" : nil];
        }];
    }
    
    if (classes) free(classes);
    
    QMUI_hasAppliedInitialTemplate = YES;
}

- (void)sendAnalyticsWithQuery:(NSString *)query {
    NSString *identifier = [NSBundle mainBundle].bundleIdentifier.qmui_stringByEncodingUserInputQuery;
    NSString *displayName = ((NSString *)([NSBundle mainBundle].infoDictionary[@"CFBundleDisplayName"] ?: [NSBundle mainBundle].infoDictionary[@"CFBundleName"])).qmui_stringByEncodingUserInputQuery;
    NSString *QMUIVersion = QMUI_VERSION.qmui_stringByEncodingUserInputQuery;// 如果不以 framework 方式引入 QMUI 的话，是无法通过 CFBundleShortVersionString 获取到 QMUI 所在的 bundle 的版本号的，所以这里改为用脚本生成的变量来获取
    NSString *queryString = [NSString stringWithFormat:@"appId=%@&appName=%@&version=%@&platform=iOS", identifier, displayName, QMUIVersion];
    if (query.length > 0) queryString = [NSString stringWithFormat:@"%@&%@", queryString, query];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:@"https://qmuiteam.com/analytics/usageReport"]];
    request.HTTPMethod = @"POST";
    request.HTTPBody = [queryString dataUsingEncoding:NSUTF8StringEncoding];
    NSURLSession *session = [NSURLSession sharedSession];
    [[session dataTaskWithRequest:request] resume];
}

#pragma mark - Initialize default values

- (void)initDefaultConfiguration {
    
    #pragma mark - Global Color
    
    self.clearColor = UIColorMakeWithRGBA(255, 255, 255, 0);
    self.whiteColor = UIColorMake(255, 255, 255);
    self.blackColor = UIColorMake(0, 0, 0);
    self.grayColor = UIColorMake(179, 179, 179);
    self.grayDarkenColor = UIColorMake(163, 163, 163);
    self.grayLightenColor = UIColorMake(198, 198, 198);
    self.redColor = UIColorMake(250, 58, 58);
    self.greenColor = UIColorMake(159, 214, 97);
    self.blueColor = UIColorMake(49, 189, 243);
    self.yellowColor = UIColorMake(255, 207, 71);

    self.linkColor = UIColorMake(56, 116, 171);
    self.disabledColor = self.grayColor;
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
    
    #pragma mark - UITextField & UITextView
    
    self.textFieldTextInsets = UIEdgeInsetsMake(0, 7, 0, 7);
    
    #pragma mark - NavigationBar
    
    self.navBarHighlightedAlpha = 0.2f;
    self.navBarDisabledAlpha = 0.2f;
    self.sizeNavBarBackIndicatorImageAutomatically = YES;
    self.navBarCloseButtonImage = [UIImage qmui_imageWithShape:QMUIImageShapeNavClose size:CGSizeMake(16, 16) tintColor:self.navBarTintColor];
    
    self.navBarLoadingMarginRight = 3;
    self.navBarAccessoryViewMarginLeft = 5;
    self.navBarActivityIndicatorViewStyle = UIActivityIndicatorViewStyleGray;
    self.navBarAccessoryViewTypeDisclosureIndicatorImage = [[UIImage qmui_imageWithShape:QMUIImageShapeTriangle size:CGSizeMake(8, 5) tintColor:self.navBarTitleColor] qmui_imageWithOrientation:UIImageOrientationDown];
    
    
    #pragma mark - Toolbar
    
    self.toolBarHighlightedAlpha = 0.4f;
    self.toolBarDisabledAlpha = 0.4f;
    
    #pragma mark - SearchBar
    
    self.searchBarPlaceholderColor = self.placeholderColor;
    self.searchBarTextFieldCornerRadius = 2.0;
    
    #pragma mark - TableView / TableViewCell
    
    self.tableViewEstimatedHeightEnabled = YES;
    
    self.tableViewSeparatorColor = self.separatorColor;
    
    self.tableViewCellNormalHeight = UITableViewAutomaticDimension;
    self.tableViewCellSelectedBackgroundColor = UIColorMake(238, 239, 241);
    self.tableViewCellWarningBackgroundColor = self.yellowColor;
    self.tableViewCellSpacingBetweenDetailButtonAndDisclosureIndicator = 12;
    
    self.tableViewSectionHeaderBackgroundColor = UIColorMake(244, 244, 244);
    self.tableViewSectionFooterBackgroundColor = UIColorMake(244, 244, 244);
    self.tableViewSectionHeaderFont = UIFontBoldMake(12);
    self.tableViewSectionFooterFont = UIFontBoldMake(12);
    self.tableViewSectionHeaderTextColor = self.grayDarkenColor;
    self.tableViewSectionFooterTextColor = self.grayColor;
    self.tableViewSectionHeaderAccessoryMargins = UIEdgeInsetsMake(0, 15, 0, 0);
    self.tableViewSectionFooterAccessoryMargins = UIEdgeInsetsMake(0, 15, 0, 0);
    self.tableViewSectionHeaderContentInset = UIEdgeInsetsMake(4, 15, 4, 15);
    self.tableViewSectionFooterContentInset = UIEdgeInsetsMake(4, 15, 4, 15);
    if (@available(iOS 15.0, *)) {
        self.tableViewSectionHeaderTopPadding = UITableViewAutomaticDimension;
    }

    
    self.tableViewGroupedSeparatorColor = self.tableViewSeparatorColor;
    self.tableViewGroupedSectionHeaderFont = UIFontMake(12);
    self.tableViewGroupedSectionFooterFont = UIFontMake(12);
    self.tableViewGroupedSectionHeaderTextColor = self.grayDarkenColor;
    self.tableViewGroupedSectionFooterTextColor = self.grayColor;
    self.tableViewGroupedSectionHeaderAccessoryMargins = UIEdgeInsetsMake(0, 15, 0, 0);
    self.tableViewGroupedSectionFooterAccessoryMargins = UIEdgeInsetsMake(0, 15, 0, 0);
    self.tableViewGroupedSectionHeaderDefaultHeight = UITableViewAutomaticDimension;
    self.tableViewGroupedSectionFooterDefaultHeight = UITableViewAutomaticDimension;
    self.tableViewGroupedSectionHeaderContentInset = UIEdgeInsetsMake(16, 15, 8, 15);
    self.tableViewGroupedSectionFooterContentInset = UIEdgeInsetsMake(8, 15, 2, 15);
    if (@available(iOS 15.0, *)) {
        self.tableViewInsetGroupedSectionHeaderTopPadding = UITableViewAutomaticDimension;
    }
    
    self.tableViewInsetGroupedCornerRadius = 10;
    self.tableViewInsetGroupedHorizontalInset = PreferredValueForVisualDevice(20, 15);
    self.tableViewInsetGroupedSeparatorColor = self.tableViewSeparatorColor;
    self.tableViewInsetGroupedSectionHeaderFont = self.tableViewGroupedSectionHeaderFont;
    self.tableViewInsetGroupedSectionFooterFont = self.tableViewGroupedSectionFooterFont;
    self.tableViewInsetGroupedSectionHeaderTextColor = self.tableViewSectionHeaderTextColor;
    self.tableViewInsetGroupedSectionFooterTextColor = self.tableViewGroupedSectionFooterTextColor;
    self.tableViewInsetGroupedSectionHeaderAccessoryMargins = self.tableViewGroupedSectionHeaderAccessoryMargins;
    self.tableViewInsetGroupedSectionFooterAccessoryMargins = self.tableViewGroupedSectionFooterAccessoryMargins;
    self.tableViewInsetGroupedSectionHeaderDefaultHeight = self.tableViewGroupedSectionHeaderDefaultHeight;
    self.tableViewInsetGroupedSectionFooterDefaultHeight = self.tableViewGroupedSectionFooterDefaultHeight;
    self.tableViewInsetGroupedSectionHeaderContentInset = self.tableViewGroupedSectionHeaderContentInset;
    self.tableViewInsetGroupedSectionFooterContentInset = self.tableViewGroupedSectionFooterContentInset;
    if (@available(iOS 15.0, *)) {
        self.tableViewInsetGroupedSectionHeaderTopPadding = UITableViewAutomaticDimension;
    }
    
    #pragma mark - UIWindowLevel
    self.windowLevelQMUIAlertView = UIWindowLevelAlert - 4.0;
    self.windowLevelQMUIConsole = 1;
    
    #pragma mark - QMUILog
    self.shouldPrintDefaultLog = YES;
    self.shouldPrintInfoLog = YES;
    self.shouldPrintWarnLog = YES;
    self.shouldPrintQMUIWarnLogToConsole = IS_DEBUG;
    
    #pragma mark - QMUIBadge
    self.badgeOffset = QMUIBadgeInvalidateOffset;
    self.badgeOffsetLandscape = QMUIBadgeInvalidateOffset;
    self.updatesIndicatorOffset = QMUIBadgeInvalidateOffset;
    self.updatesIndicatorOffsetLandscape = QMUIBadgeInvalidateOffset;
    
    #pragma mark - Others
    
    self.supportedOrientationMask = UIInterfaceOrientationMaskAll;
    self.needsBackBarButtonItemTitle = YES;
    self.preventConcurrentNavigationControllerTransitions = YES;
    self.shouldFixTabBarSafeAreaInsetsBug = YES;
    self.sendAnalyticsToQMUITeam = YES;
}

#pragma mark - Switch Setter

/// 对 UIAppearance 设置一次 image 属性，在升起第三方键盘时就会执行一次 -[UIImage initWithCoder:]，不管每次设置的是否是相同的对象，因此这里做一次值是否有变化的判断，尽量减少 UIAppearance 的设置。
/// 注意，由于 QMUIConfiguration 里的 property setter 不仅是 retain 值，还起到刷新界面的作用，因此只有 QMUIThemeImage、QMUIThemeColor 等会“在 theme 变化时自动刷新”的对象才能用这个方法，其他类型的数据请自行检查 setter 里的逻辑是否需要在每次都调用。
/// https://github.com/Tencent/QMUI_iOS/issues/1281
+ (void)performAction:(void (NS_NOESCAPE ^)(void))action ifValueChanged:(id)oldValue newValue:(id)newValue {
    if (!action) return;
    BOOL valueChanged = newValue != oldValue;
    if ([newValue isKindOfClass:NSValue.class]
        || [newValue isKindOfClass:UIFont.class]
        || ([newValue isKindOfClass:UIColor.class] && !((UIColor *)newValue).qmui_isQMUIDynamicColor)) {
        valueChanged = ![newValue isEqual:oldValue];
    }
    if (valueChanged) {
        action();
    }
}

- (void)setSwitchOnTintColor:(UIColor *)switchOnTintColor {
    [QMUIConfiguration performAction:^{
        _switchOnTintColor = switchOnTintColor;
        if (QMUIHelper.canUpdateAppearance) {
            [UISwitch appearance].onTintColor = switchOnTintColor;
        }
    } ifValueChanged:_switchOnTintColor newValue:switchOnTintColor];
}

- (void)setSwitchThumbTintColor:(UIColor *)switchThumbTintColor {
    [QMUIConfiguration performAction:^{
        _switchThumbTintColor = switchThumbTintColor;
        if (QMUIHelper.canUpdateAppearance) {
            [UISwitch appearance].thumbTintColor = switchThumbTintColor;
        }
    } ifValueChanged:_switchThumbTintColor newValue:switchThumbTintColor];
}

#pragma mark - NavigationBar Setter

- (UINavigationBarAppearance *)navigationBarAppearance {
    if (!_navigationBarAppearance) {
        _navigationBarAppearance = [[UINavigationBarAppearance alloc] init];
        [_navigationBarAppearance configureWithDefaultBackground];
    }
    return _navigationBarAppearance;
}

- (void)updateNavigationBarBarAppearance {
#ifdef IOS15_SDK_ALLOWED
    if (@available(iOS 15.0, *)) {
        if (QMUIHelper.canUpdateAppearance) {
            UINavigationBar.qmui_appearanceConfigured.standardAppearance = self.navigationBarAppearance;
            if (QMUICMIActivated && NavBarUsesStandardAppearanceOnly) {
                UINavigationBar.qmui_appearanceConfigured.scrollEdgeAppearance = self.navigationBarAppearance;
            }
        }
    }
#endif
}

- (void)setNavBarButtonFont:(UIFont *)navBarButtonFont {
    [QMUIConfiguration performAction:^{
        _navBarButtonFont = navBarButtonFont;
#ifdef IOS15_SDK_ALLOWED
        if (@available(iOS 15.0, *)) {
            NSMutableDictionary<NSAttributedStringKey, id> *titleTextAttributes = self.navigationBarAppearance.buttonAppearance.normal.titleTextAttributes.mutableCopy;
            titleTextAttributes[NSFontAttributeName] = navBarButtonFont;
            self.navigationBarAppearance.buttonAppearance.normal.titleTextAttributes = titleTextAttributes;
            [self updateNavigationBarBarAppearance];
        } else {
#endif
            // by molice 2017-08-04 只要用 appearence 的方式修改 UIBarButtonItem 的 font，就会导致界面切换时 UIBarButtonItem 抖动，系统的问题，所以暂时不修改 appearance。
            // by molice 2018-06-14 iOS 11 观察貌似又没抖动了，先试试看
            
            if (QMUIHelper.canUpdateAppearance) {
                UIBarButtonItem *barButtonItemAppearance = [UIBarButtonItem appearanceWhenContainedInInstancesOfClasses:@[[UINavigationBar class]]];
                NSDictionary<NSAttributedStringKey,id> *attributes = navBarButtonFont ? @{NSFontAttributeName: navBarButtonFont} : nil;
                [barButtonItemAppearance setTitleTextAttributes:attributes forState:UIControlStateNormal];
                [barButtonItemAppearance setTitleTextAttributes:attributes forState:UIControlStateHighlighted];
                [barButtonItemAppearance setTitleTextAttributes:attributes forState:UIControlStateDisabled];
            }
#ifdef IOS15_SDK_ALLOWED
        }
#endif
    } ifValueChanged:_navBarButtonFont newValue:navBarButtonFont];
}

- (void)setNavBarButtonFontBold:(UIFont *)navBarButtonFontBold {
    // iOS 15 以前无法专门对 Done 类型设置样式，所以这里只对 iOS 15 生效
    if (@available(iOS 15.0, *)) {
        [QMUIConfiguration performAction:^{
            _navBarButtonFontBold = navBarButtonFontBold;
#ifdef IOS15_SDK_ALLOWED
            NSMutableDictionary<NSAttributedStringKey, id> *titleTextAttributes = self.navigationBarAppearance.doneButtonAppearance.normal.titleTextAttributes.mutableCopy;
            titleTextAttributes[NSFontAttributeName] = navBarButtonFontBold;
            self.navigationBarAppearance.doneButtonAppearance.normal.titleTextAttributes = titleTextAttributes;
            [self updateNavigationBarBarAppearance];
#endif
        } ifValueChanged:_navBarButtonFontBold newValue:navBarButtonFontBold];
    }
}

- (void)setNavBarTintColor:(UIColor *)navBarTintColor {
    _navBarTintColor = navBarTintColor;
    // tintColor 并没有声明 UI_APPEARANCE_SELECTOR，所以暂不使用 appearance 的方式去修改（虽然 appearance 方式实测是生效的）
    [self.appearanceUpdatingNavigationControllers enumerateObjectsUsingBlock:^(UINavigationController * _Nonnull navigationController,NSUInteger idx, BOOL * _Nonnull stop) {
        if (![navigationController.topViewController respondsToSelector:@selector(qmui_navigationBarTintColor)]) {
            navigationController.navigationBar.tintColor = _navBarTintColor;
        }
    }];
}

- (void)setNavBarBarTintColor:(UIColor *)navBarBarTintColor {
    [QMUIConfiguration performAction:^{
        _navBarBarTintColor = navBarBarTintColor;
        
        // iOS 15 虽然不通过旧 API 设置样式，但 QMUI 里会从 appearance 的旧 API 取值作为默认值，所以这里不做 if iOS 15 的屏蔽。
        if (QMUIHelper.canUpdateAppearance) {
            UINavigationBar.qmui_appearanceConfigured.barTintColor = navBarBarTintColor;
        }
        
#ifdef IOS15_SDK_ALLOWED
        if (@available(iOS 15.0, *)) {
            self.navigationBarAppearance.backgroundColor = navBarBarTintColor;
            [self updateNavigationBarBarAppearance];
        }
#endif
        
        [self.appearanceUpdatingNavigationControllers enumerateObjectsUsingBlock:^(UINavigationController * _Nonnull navigationController,NSUInteger idx, BOOL * _Nonnull stop) {
            if (![navigationController.topViewController respondsToSelector:@selector(qmui_navigationBarBarTintColor)]) {
                navigationController.navigationBar.barTintColor = navBarBarTintColor;
            }
        }];
    } ifValueChanged:_navBarBarTintColor newValue:navBarBarTintColor];
}

- (void)setNavBarShadowImage:(UIImage *)navBarShadowImage {
    [QMUIConfiguration performAction:^{
        _navBarShadowImage = navBarShadowImage;
        
#ifdef IOS15_SDK_ALLOWED
        if (@available(iOS 15.0, *)) {
            self.navigationBarAppearance.shadowImage = navBarShadowImage;
            [self updateNavigationBarBarAppearance];
        }
#endif
        
        // iOS 15 虽然不通过旧 API 设置样式，但 QMUI 里会从 appearance 的旧 API 取值作为默认值，所以这里不做 if iOS 15 的屏蔽。
        [self configureNavBarShadowImage];
        
    } ifValueChanged:_navBarShadowImage newValue:!navBarShadowImage ? _navBarShadowImage : navBarShadowImage];// NavBarShadowImage 特殊一点，因为它在 NavBarShadowImageColor 里又会被赋值，所以这里对常见的组合“image = nil && imageColor = xxx”做特殊处理，避免误以为 valueChanged
}

- (void)setNavBarShadowImageColor:(UIColor *)navBarShadowImageColor {
    [QMUIConfiguration performAction:^{
        _navBarShadowImageColor = navBarShadowImageColor;
        
#ifdef IOS15_SDK_ALLOWED
        if (@available(iOS 15.0, *)) {
            self.navigationBarAppearance.shadowColor = navBarShadowImageColor;
            [self updateNavigationBarBarAppearance];
        }
#endif
        // iOS 15 虽然不通过旧 API 设置样式，但 QMUI 里会从 appearance 的旧 API 取值作为默认值，所以这里不做 if iOS 15 的屏蔽。
        [self configureNavBarShadowImage];
        
    } ifValueChanged:_navBarShadowImageColor newValue:navBarShadowImageColor];
}

- (void)configureNavBarShadowImage {
    UIImage *shadowImage = self.navBarShadowImage;
    if (shadowImage || self.navBarShadowImageColor) {
        if (shadowImage) {
            if (self.navBarShadowImageColor && shadowImage.renderingMode != UIImageRenderingModeAlwaysOriginal) {
                shadowImage = [shadowImage qmui_imageWithTintColor:self.navBarShadowImageColor];
            }
        } else {
            shadowImage = [UIImage qmui_imageWithColor:self.navBarShadowImageColor size:CGSizeMake(4, PixelOne) cornerRadius:0];
        }
        
        // 反向更新 NavBarShadowImage，以保证业务代码直接使用 NavBarShadowImage 宏能得到正确的图片
        _navBarShadowImage = shadowImage;
    }
    
    if (QMUIHelper.canUpdateAppearance) {
        UINavigationBar.qmui_appearanceConfigured.shadowImage = shadowImage;
    }
    
    [self.appearanceUpdatingNavigationControllers enumerateObjectsUsingBlock:^(UINavigationController * _Nonnull navigationController,NSUInteger idx, BOOL * _Nonnull stop) {
        if (![navigationController.topViewController respondsToSelector:@selector(qmui_navigationBarShadowImage)]) {
            navigationController.navigationBar.shadowImage = shadowImage;
        }
    }];
}

- (void)setNavBarStyle:(UIBarStyle)navBarStyle {
    [QMUIConfiguration performAction:^{
        _navBarStyle = navBarStyle;
        
        // iOS 15 虽然不通过旧 API 设置样式，但 QMUI 里会从 appearance 的旧 API 取值作为默认值，所以这里不做 if iOS 15 的屏蔽。
        if (QMUIHelper.canUpdateAppearance) {
            UINavigationBar.qmui_appearanceConfigured.barStyle = navBarStyle;
        }
        
#ifdef IOS15_SDK_ALLOWED
        if (@available(iOS 15.0, *)) {
            self.navigationBarAppearance.backgroundEffect = [UIBlurEffect effectWithStyle:navBarStyle == UIBarStyleDefault ? UIBlurEffectStyleSystemChromeMaterialLight : UIBlurEffectStyleSystemChromeMaterialDark];
            [self updateNavigationBarBarAppearance];
        }
#endif
        
        [self.appearanceUpdatingNavigationControllers enumerateObjectsUsingBlock:^(UINavigationController * _Nonnull navigationController,NSUInteger idx, BOOL * _Nonnull stop) {
            if (![navigationController.topViewController respondsToSelector:@selector(qmui_navigationBarStyle)]) {
                navigationController.navigationBar.barStyle = navBarStyle;
            }
        }];
    } ifValueChanged:@(_navBarStyle) newValue:@(navBarStyle)];
}

- (void)setNavBarBackgroundImage:(UIImage *)navBarBackgroundImage {
    [QMUIConfiguration performAction:^{
        _navBarBackgroundImage = navBarBackgroundImage;
        
        // iOS 15 虽然不通过旧 API 设置样式，但 QMUI 里会从 appearance 的旧 API 取值作为默认值，所以这里不做 if iOS 15 的屏蔽。
        if (QMUIHelper.canUpdateAppearance) {
            [UINavigationBar.qmui_appearanceConfigured setBackgroundImage:navBarBackgroundImage forBarMetrics:UIBarMetricsDefault];
        }
        
#ifdef IOS15_SDK_ALLOWED
        if (@available(iOS 15.0, *)) {
            self.navigationBarAppearance.backgroundImage = navBarBackgroundImage;
            [self updateNavigationBarBarAppearance];
        }
#endif
        
        [self.appearanceUpdatingNavigationControllers enumerateObjectsUsingBlock:^(UINavigationController * _Nonnull navigationController,NSUInteger idx, BOOL * _Nonnull stop) {
            if (![navigationController.topViewController respondsToSelector:@selector(qmui_navigationBarBackgroundImage)]) {
                [navigationController.navigationBar setBackgroundImage:navBarBackgroundImage forBarMetrics:UIBarMetricsDefault];
            }
        }];
    } ifValueChanged:_navBarBackgroundImage newValue:navBarBackgroundImage];
}

- (void)setNavBarTitleFont:(UIFont *)navBarTitleFont {
    [QMUIConfiguration performAction:^{
        _navBarTitleFont = navBarTitleFont;
        
#ifdef IOS15_SDK_ALLOWED
        if (@available(iOS 15.0, *)) {
            NSMutableDictionary<NSAttributedStringKey, id> *titleTextAttributes = self.navigationBarAppearance.titleTextAttributes.mutableCopy;
            titleTextAttributes[NSFontAttributeName] = navBarTitleFont;
            self.navigationBarAppearance.titleTextAttributes = titleTextAttributes;
            [self updateNavigationBarBarAppearance];
        }
#endif
        
        // iOS 15 虽然不通过旧 API 设置样式，但 QMUI 里会从 appearance 的旧 API 取值作为默认值，所以这里不做 if iOS 15 的屏蔽。
        [self updateNavigationBarTitleAttributesIfNeeded];
    } ifValueChanged:_navBarTitleFont newValue:navBarTitleFont];
}

- (void)setNavBarTitleColor:(UIColor *)navBarTitleColor {
    [QMUIConfiguration performAction:^{
        _navBarTitleColor = navBarTitleColor;
        
#ifdef IOS15_SDK_ALLOWED
        if (@available(iOS 15.0, *)) {
            NSMutableDictionary<NSAttributedStringKey, id> *titleTextAttributes = self.navigationBarAppearance.titleTextAttributes.mutableCopy;
            titleTextAttributes[NSForegroundColorAttributeName] = navBarTitleColor;
            self.navigationBarAppearance.titleTextAttributes = titleTextAttributes;
            [self updateNavigationBarBarAppearance];
        }
#endif
        
        // iOS 15 虽然不通过旧 API 设置样式，但 QMUI 里会从 appearance 的旧 API 取值作为默认值，所以这里不做 if iOS 15 的屏蔽。
        [self updateNavigationBarTitleAttributesIfNeeded];
    } ifValueChanged:_navBarTitleColor newValue:navBarTitleColor];
}

- (void)updateNavigationBarTitleAttributesIfNeeded {
    NSMutableDictionary<NSAttributedStringKey, id> *titleTextAttributes = UINavigationBar.qmui_appearanceConfigured.titleTextAttributes.mutableCopy;
    if (!titleTextAttributes) {
        titleTextAttributes = [[NSMutableDictionary alloc] init];
    }
    if (self.navBarTitleFont) {
        titleTextAttributes[NSFontAttributeName] = self.navBarTitleFont;
    }
    if (self.navBarTitleColor) {
        titleTextAttributes[NSForegroundColorAttributeName] = self.navBarTitleColor;
    }
    if (QMUIHelper.canUpdateAppearance) {
        UINavigationBar.qmui_appearanceConfigured.titleTextAttributes = titleTextAttributes;
    }
#ifdef IOS15_SDK_ALLOWED
    if (@available(iOS 15.0, *)) {
    } else {
#endif
        [self.appearanceUpdatingNavigationControllers enumerateObjectsUsingBlock:^(UINavigationController * _Nonnull navigationController,NSUInteger idx, BOOL * _Nonnull stop) {
            if (![navigationController.topViewController respondsToSelector:@selector(qmui_titleViewTintColor)]) {
                navigationController.navigationBar.titleTextAttributes = titleTextAttributes;
            }
        }];
#ifdef IOS15_SDK_ALLOWED
    }
#endif
}

- (void)setNavBarLargeTitleFont:(UIFont *)navBarLargeTitleFont {
    [QMUIConfiguration performAction:^{
        _navBarLargeTitleFont = navBarLargeTitleFont;
        
        // iOS 15 虽然不通过旧 API 设置样式，但 QMUI 里会从 appearance 的旧 API 取值作为默认值，所以这里不做 if iOS 15 的屏蔽。
        [self updateNavigationBarLargeTitleTextAttributesIfNeeded];
        
#ifdef IOS15_SDK_ALLOWED
        if (@available(iOS 15.0, *)) {
            NSMutableDictionary<NSAttributedStringKey, id> *largeTitleTextAttributes = self.navigationBarAppearance.largeTitleTextAttributes.mutableCopy;
            largeTitleTextAttributes[NSFontAttributeName] = navBarLargeTitleFont;
            self.navigationBarAppearance.largeTitleTextAttributes = largeTitleTextAttributes;
            [self updateNavigationBarBarAppearance];
        }
#endif
    } ifValueChanged:_navBarLargeTitleFont newValue:navBarLargeTitleFont];
}

- (void)setNavBarLargeTitleColor:(UIColor *)navBarLargeTitleColor {
    [QMUIConfiguration performAction:^{
        _navBarLargeTitleColor = navBarLargeTitleColor;
        
        // iOS 15 虽然不通过旧 API 设置样式，但 QMUI 里会从 appearance 的旧 API 取值作为默认值，所以这里不做 if iOS 15 的屏蔽。
        [self updateNavigationBarLargeTitleTextAttributesIfNeeded];
        
#ifdef IOS15_SDK_ALLOWED
        if (@available(iOS 15.0, *)) {
            NSMutableDictionary<NSAttributedStringKey, id> *largeTitleTextAttributes = self.navigationBarAppearance.largeTitleTextAttributes.mutableCopy;
            largeTitleTextAttributes[NSForegroundColorAttributeName] = navBarLargeTitleColor;
            self.navigationBarAppearance.largeTitleTextAttributes = largeTitleTextAttributes;
            [self updateNavigationBarBarAppearance];
        }
#endif
    } ifValueChanged:_navBarLargeTitleColor newValue:navBarLargeTitleColor];
}

- (void)updateNavigationBarLargeTitleTextAttributesIfNeeded {
    NSMutableDictionary<NSString *, id> *largeTitleTextAttributes = [[NSMutableDictionary alloc] init];
    if (self.navBarLargeTitleFont) {
        largeTitleTextAttributes[NSFontAttributeName] = self.navBarLargeTitleFont;
    }
    if (self.navBarLargeTitleColor) {
        largeTitleTextAttributes[NSForegroundColorAttributeName] = self.navBarLargeTitleColor;
    }
    if (QMUIHelper.canUpdateAppearance) {
        UINavigationBar.qmui_appearanceConfigured.largeTitleTextAttributes = largeTitleTextAttributes;
    }
    
#ifdef IOS15_SDK_ALLOWED
    if (@available(iOS 15.0, *)) {
    } else {
#endif
        [self.appearanceUpdatingNavigationControllers enumerateObjectsUsingBlock:^(UINavigationController * _Nonnull navigationController,NSUInteger idx, BOOL * _Nonnull stop) {
            navigationController.navigationBar.largeTitleTextAttributes = largeTitleTextAttributes;
        }];
#ifdef IOS15_SDK_ALLOWED
    }
#endif
}

- (void)setSizeNavBarBackIndicatorImageAutomatically:(BOOL)sizeNavBarBackIndicatorImageAutomatically {
    _sizeNavBarBackIndicatorImageAutomatically = sizeNavBarBackIndicatorImageAutomatically;
    if (sizeNavBarBackIndicatorImageAutomatically && self.navBarBackIndicatorImage && !CGSizeEqualToSize(self.navBarBackIndicatorImage.size, kUINavigationBarBackIndicatorImageSize)) {
        self.navBarBackIndicatorImage = self.navBarBackIndicatorImage;// 重新设置一次，以触发自动调整大小
    }
}

- (void)setNavBarBackIndicatorImage:(UIImage *)navBarBackIndicatorImage {
    [QMUIConfiguration performAction:^{
        _navBarBackIndicatorImage = navBarBackIndicatorImage;
        
        // 返回按钮的图片frame是和系统默认的返回图片的大小一致的（13, 21），所以用自定义返回箭头时要保证图片大小与系统的箭头大小一样，否则无法对齐
        // Make sure custom back button image is the same size as the system's back button image, i.e. (13, 21), due to the same frame size they share.
        if (navBarBackIndicatorImage && self.sizeNavBarBackIndicatorImageAutomatically) {
            CGSize systemBackIndicatorImageSize = kUINavigationBarBackIndicatorImageSize;
            CGSize customBackIndicatorImageSize = _navBarBackIndicatorImage.size;
            if (!CGSizeEqualToSize(customBackIndicatorImageSize, systemBackIndicatorImageSize)) {
                CGFloat imageExtensionVerticalFloat = CGFloatGetCenter(systemBackIndicatorImageSize.height, customBackIndicatorImageSize.height);
                _navBarBackIndicatorImage = [[_navBarBackIndicatorImage qmui_imageWithSpacingExtensionInsets:UIEdgeInsetsMake(imageExtensionVerticalFloat,
                                                                                                                              0,
                                                                                                                              imageExtensionVerticalFloat,
                                                                                                                              systemBackIndicatorImageSize.width - customBackIndicatorImageSize.width)] imageWithRenderingMode:_navBarBackIndicatorImage.renderingMode];
            }
        }
    
        // iOS 15 虽然不通过旧 API 设置样式，但 QMUI 里会从 appearance 的旧 API 取值作为默认值，所以这里不做 if iOS 15 的屏蔽。
        if (QMUIHelper.canUpdateAppearance) {
            UINavigationBar *navBarAppearance = UINavigationBar.qmui_appearanceConfigured;
            navBarAppearance.backIndicatorImage = _navBarBackIndicatorImage;
            navBarAppearance.backIndicatorTransitionMaskImage = _navBarBackIndicatorImage;
        }
        
#ifdef IOS15_SDK_ALLOWED
        if (@available(iOS 15.0, *)) {
            [self.navigationBarAppearance setBackIndicatorImage:_navBarBackIndicatorImage transitionMaskImage:_navBarBackIndicatorImage];
            [self updateNavigationBarBarAppearance];
        }
#endif
        
        [self.appearanceUpdatingNavigationControllers enumerateObjectsUsingBlock:^(UINavigationController * _Nonnull navigationController,NSUInteger idx, BOOL * _Nonnull stop) {
            navigationController.navigationBar.backIndicatorImage = _navBarBackIndicatorImage;
            navigationController.navigationBar.backIndicatorTransitionMaskImage = _navBarBackIndicatorImage;
        }];
    } ifValueChanged:_navBarBackIndicatorImage newValue:navBarBackIndicatorImage];
}

- (void)setNavBarBackButtonTitlePositionAdjustment:(UIOffset)navBarBackButtonTitlePositionAdjustment {
    [QMUIConfiguration performAction:^{
        _navBarBackButtonTitlePositionAdjustment = navBarBackButtonTitlePositionAdjustment;
        
        // iOS 15 虽然不通过旧 API 设置样式，但 QMUI 里会从 appearance 的旧 API 取值作为默认值，所以这里不做 if iOS 15 的屏蔽。
        if (QMUIHelper.canUpdateAppearance) {
            UIBarButtonItem *backBarButtonItem = [UIBarButtonItem appearance];
            [backBarButtonItem setBackButtonTitlePositionAdjustment:_navBarBackButtonTitlePositionAdjustment forBarMetrics:UIBarMetricsDefault];
        }
        
#ifdef IOS15_SDK_ALLOWED
        if (@available(iOS 15.0, *)) {
            self.navigationBarAppearance.backButtonAppearance.normal.titlePositionAdjustment = navBarBackButtonTitlePositionAdjustment;
            [self updateNavigationBarBarAppearance];
        } else {
#endif
            [self.appearanceUpdatingNavigationControllers enumerateObjectsUsingBlock:^(UINavigationController * _Nonnull navigationController, NSUInteger idx, BOOL * _Nonnull stop) {
                [navigationController.navigationItem.backBarButtonItem setBackButtonTitlePositionAdjustment:_navBarBackButtonTitlePositionAdjustment forBarMetrics:UIBarMetricsDefault];
            }];
#ifdef IOS15_SDK_ALLOWED
        }
#endif
    } ifValueChanged:[NSValue valueWithUIOffset:_navBarBackButtonTitlePositionAdjustment] newValue:[NSValue valueWithUIOffset:navBarBackButtonTitlePositionAdjustment]];
}

#pragma mark - ToolBar Setter

- (UIToolbarAppearance *)toolBarAppearance {
    if (!_toolBarAppearance) {
        _toolBarAppearance = [[UIToolbarAppearance alloc] init];
        [_toolBarAppearance configureWithDefaultBackground];
    }
    return _toolBarAppearance;
}

- (void)updateToolBarBarAppearance {
#ifdef IOS15_SDK_ALLOWED
    if (@available(iOS 15.0, *)) {
        if (QMUIHelper.canUpdateAppearance) {
            UIToolbar.qmui_appearanceConfigured.standardAppearance = self.toolBarAppearance;
            if (QMUICMIActivated && ToolBarUsesStandardAppearanceOnly) {
                UIToolbar.qmui_appearanceConfigured.scrollEdgeAppearance = self.toolBarAppearance;
            }
        }
        [self.appearanceUpdatingToolbarControllers enumerateObjectsUsingBlock:^(UINavigationController * _Nonnull navigationController, NSUInteger idx, BOOL * _Nonnull stop) {
            navigationController.toolbar.standardAppearance = self.toolBarAppearance;
            if (QMUICMIActivated && ToolBarUsesStandardAppearanceOnly) {
                navigationController.toolbar.scrollEdgeAppearance = self.toolBarAppearance;
            }
        }];
    }
#endif
}

- (void)setToolBarTintColor:(UIColor *)toolBarTintColor {
    _toolBarTintColor = toolBarTintColor;
    // tintColor 并没有声明 UI_APPEARANCE_SELECTOR，所以暂不使用 appearance 的方式去修改（虽然 appearance 方式实测是生效的）
    [self.appearanceUpdatingNavigationControllers enumerateObjectsUsingBlock:^(UINavigationController * _Nonnull navigationController, NSUInteger idx, BOOL * _Nonnull stop) {
        navigationController.toolbar.tintColor = _toolBarTintColor;
    }];
}

- (void)setToolBarStyle:(UIBarStyle)toolBarStyle {
    [QMUIConfiguration performAction:^{
        _toolBarStyle = toolBarStyle;
        if (QMUIHelper.canUpdateAppearance) {
            UIToolbar.qmui_appearanceConfigured.barStyle = toolBarStyle;
        }
        
#ifdef IOS15_SDK_ALLOWED
        if (@available(iOS 15.0, *)) {
            self.toolBarAppearance.backgroundEffect = [UIBlurEffect effectWithStyle:toolBarStyle == UIBarStyleDefault ? UIBlurEffectStyleSystemChromeMaterialLight : UIBlurEffectStyleSystemChromeMaterialDark];
            [self updateToolBarBarAppearance];
        } else {
#endif
            [self.appearanceUpdatingToolbarControllers enumerateObjectsUsingBlock:^(UINavigationController * _Nonnull navigationController, NSUInteger idx, BOOL * _Nonnull stop) {
                navigationController.toolbar.barStyle = toolBarStyle;
            }];
#ifdef IOS15_SDK_ALLOWED
        }
#endif
    } ifValueChanged:@(_toolBarStyle) newValue:@(toolBarStyle)];
}

- (void)setToolBarBarTintColor:(UIColor *)toolBarBarTintColor {
    [QMUIConfiguration performAction:^{
        _toolBarBarTintColor = toolBarBarTintColor;
        if (QMUIHelper.canUpdateAppearance) {
            UIToolbar.qmui_appearanceConfigured.barTintColor = _toolBarBarTintColor;
        }
        
#ifdef IOS15_SDK_ALLOWED
        if (@available(iOS 15.0, *)) {
            self.toolBarAppearance.backgroundColor = toolBarBarTintColor;
            [self updateToolBarBarAppearance];
        } else {
#endif
            [self.appearanceUpdatingToolbarControllers enumerateObjectsUsingBlock:^(UINavigationController * _Nonnull navigationController, NSUInteger idx, BOOL * _Nonnull stop) {
                navigationController.toolbar.barTintColor = _toolBarBarTintColor;
            }];
#ifdef IOS15_SDK_ALLOWED
        }
#endif
    } ifValueChanged:_toolBarBarTintColor newValue:toolBarBarTintColor];
}

- (void)setToolBarBackgroundImage:(UIImage *)toolBarBackgroundImage {
    [QMUIConfiguration performAction:^{
        _toolBarBackgroundImage = toolBarBackgroundImage;
        if (QMUIHelper.canUpdateAppearance) {
            [UIToolbar.qmui_appearanceConfigured setBackgroundImage:_toolBarBackgroundImage forToolbarPosition:UIBarPositionAny barMetrics:UIBarMetricsDefault];
        }
        
#ifdef IOS15_SDK_ALLOWED
        if (@available(iOS 15.0, *)) {
            self.toolBarAppearance.backgroundImage = toolBarBackgroundImage;
            [self updateToolBarBarAppearance];
        } else {
#endif
            [self.appearanceUpdatingToolbarControllers enumerateObjectsUsingBlock:^(UINavigationController * _Nonnull navigationController, NSUInteger idx, BOOL * _Nonnull stop) {
                [navigationController.toolbar setBackgroundImage:_toolBarBackgroundImage forToolbarPosition:UIBarPositionAny barMetrics:UIBarMetricsDefault];
            }];
#ifdef IOS15_SDK_ALLOWED
        }
#endif
    } ifValueChanged:_toolBarBackgroundImage newValue:toolBarBackgroundImage];
}

- (void)setToolBarShadowImageColor:(UIColor *)toolBarShadowImageColor {
    [QMUIConfiguration performAction:^{
        _toolBarShadowImageColor = toolBarShadowImageColor;
        UIImage *shadowImage = toolBarShadowImageColor ? [UIImage qmui_imageWithColor:_toolBarShadowImageColor size:CGSizeMake(1, PixelOne) cornerRadius:0] : nil;
        if (QMUIHelper.canUpdateAppearance) {
            [UIToolbar.qmui_appearanceConfigured setShadowImage:shadowImage forToolbarPosition:UIBarPositionAny];
        }
        
#ifdef IOS15_SDK_ALLOWED
        if (@available(iOS 15.0, *)) {
            self.toolBarAppearance.shadowColor = toolBarShadowImageColor;
            [self updateToolBarBarAppearance];
        } else {
#endif
            [self.appearanceUpdatingToolbarControllers enumerateObjectsUsingBlock:^(UINavigationController * _Nonnull navigationController, NSUInteger idx, BOOL * _Nonnull stop) {
                [navigationController.toolbar setShadowImage:shadowImage forToolbarPosition:UIBarPositionAny];
            }];
#ifdef IOS15_SDK_ALLOWED
        }
#endif
    } ifValueChanged:_toolBarShadowImageColor newValue:toolBarShadowImageColor];
}

#pragma mark - TabBar Setter

- (UITabBarAppearance *)tabBarAppearance {
    if (!_tabBarAppearance) {
        _tabBarAppearance = [[UITabBarAppearance alloc] init];
        [_tabBarAppearance configureWithDefaultBackground];
    }
    return _tabBarAppearance;
}

- (void)updateTabBarAppearance {
    if (@available(iOS 13.0, *)) {
        if (QMUIHelper.canUpdateAppearance) {
            UITabBar.qmui_appearanceConfigured.standardAppearance = self.tabBarAppearance;
#ifdef IOS15_SDK_ALLOWED
            if (@available(iOS 15.0, *)) {
                if (QMUICMIActivated && TabBarUsesStandardAppearanceOnly) {
                    UITabBar.qmui_appearanceConfigured.scrollEdgeAppearance = self.tabBarAppearance;
                }
            }
#endif
        }
        [self.appearanceUpdatingTabBarControllers enumerateObjectsUsingBlock:^(UITabBarController * _Nonnull tabBarController, NSUInteger idx, BOOL * _Nonnull stop) {
            tabBarController.tabBar.standardAppearance = self.tabBarAppearance;
#ifdef IOS15_SDK_ALLOWED
            if (@available(iOS 15.0, *)) {
                if (QMUICMIActivated && TabBarUsesStandardAppearanceOnly) {
                    tabBarController.tabBar.scrollEdgeAppearance = self.tabBarAppearance;
                }
            }
#endif
            [tabBarController.tabBar setNeedsLayout];// theme 不跟随系统的情况下切换 Light/Dark，tabBarAppearance.backgroundEffect 虽然值被更新了，但样式被刷新，这里手动触发一下
        }];
    }
}

- (void)setTabBarBarTintColor:(UIColor *)tabBarBarTintColor {
    [QMUIConfiguration performAction:^{
        _tabBarBarTintColor = tabBarBarTintColor;
        
        if (@available(iOS 13.0, *)) {
            self.tabBarAppearance.backgroundColor = tabBarBarTintColor;
            [self updateTabBarAppearance];
        } else {
            if (QMUIHelper.canUpdateAppearance) {
                UITabBar.qmui_appearanceConfigured.barTintColor = _tabBarBarTintColor;
            }
            [self.appearanceUpdatingTabBarControllers enumerateObjectsUsingBlock:^(UITabBarController * _Nonnull tabBarController, NSUInteger idx, BOOL * _Nonnull stop) {
                tabBarController.tabBar.barTintColor = _tabBarBarTintColor;
            }];
        }
    } ifValueChanged:_tabBarBarTintColor newValue:tabBarBarTintColor];
}

- (void)setTabBarStyle:(UIBarStyle)tabBarStyle {
    [QMUIConfiguration performAction:^{
        _tabBarStyle = tabBarStyle;
        if (@available(iOS 13.0, *)) {
            self.tabBarAppearance.backgroundEffect = [UIBlurEffect effectWithStyle:tabBarStyle == UIBarStyleDefault ? UIBlurEffectStyleSystemChromeMaterialLight : UIBlurEffectStyleSystemChromeMaterialDark];
            [self updateTabBarAppearance];
        } else {
            if (QMUIHelper.canUpdateAppearance) {
                UITabBar.qmui_appearanceConfigured.barStyle = tabBarStyle;
            }
            [self.appearanceUpdatingTabBarControllers enumerateObjectsUsingBlock:^(UITabBarController * _Nonnull tabBarController, NSUInteger idx, BOOL * _Nonnull stop) {
                tabBarController.tabBar.barStyle = tabBarStyle;
            }];
        }
    } ifValueChanged:@(_tabBarStyle) newValue:@(tabBarStyle)];
}

- (void)setTabBarBackgroundImage:(UIImage *)tabBarBackgroundImage {
    [QMUIConfiguration performAction:^{
        _tabBarBackgroundImage = tabBarBackgroundImage;
        
        if (@available(iOS 13.0, *)) {
            self.tabBarAppearance.backgroundImage = tabBarBackgroundImage;
            [self updateTabBarAppearance];
        } else {
            if (QMUIHelper.canUpdateAppearance) {
                UITabBar.qmui_appearanceConfigured.backgroundImage = tabBarBackgroundImage;
            }
            [self.appearanceUpdatingTabBarControllers enumerateObjectsUsingBlock:^(UITabBarController * _Nonnull tabBarController, NSUInteger idx, BOOL * _Nonnull stop) {
                tabBarController.tabBar.backgroundImage = tabBarBackgroundImage;
            }];
        }
    } ifValueChanged:_tabBarBackgroundImage newValue:tabBarBackgroundImage];
}

- (void)setTabBarShadowImageColor:(UIColor *)tabBarShadowImageColor {
    [QMUIConfiguration performAction:^{
        _tabBarShadowImageColor = tabBarShadowImageColor;
        
        if (@available(iOS 13.0, *)) {
            self.tabBarAppearance.shadowColor = tabBarShadowImageColor;
            [self updateTabBarAppearance];
        } else {
            UIImage *shadowImage = [UIImage qmui_imageWithColor:_tabBarShadowImageColor size:CGSizeMake(1, PixelOne) cornerRadius:0];
            if (QMUIHelper.canUpdateAppearance) {
                [UITabBar.qmui_appearanceConfigured setShadowImage:shadowImage];
            }
            [self.appearanceUpdatingTabBarControllers enumerateObjectsUsingBlock:^(UITabBarController * _Nonnull tabBarController, NSUInteger idx, BOOL * _Nonnull stop) {
                tabBarController.tabBar.shadowImage = shadowImage;
            }];
        }
    } ifValueChanged:_tabBarShadowImageColor newValue:tabBarShadowImageColor];
}

- (void)setTabBarItemTitleFont:(UIFont *)tabBarItemTitleFont {
    [QMUIConfiguration performAction:^{
        _tabBarItemTitleFont = tabBarItemTitleFont;
        
        if (@available(iOS 13.0, *)) {
            [self.tabBarAppearance qmui_applyItemAppearanceWithBlock:^(UITabBarItemAppearance * _Nonnull itemAppearance) {
                NSMutableDictionary<NSAttributedStringKey, id> *attributes = itemAppearance.normal.titleTextAttributes.mutableCopy;
                attributes[NSFontAttributeName] = tabBarItemTitleFont;
                itemAppearance.normal.titleTextAttributes = attributes.copy;
            }];
            [self updateTabBarAppearance];
        } else {
            NSMutableDictionary<NSString *, id> *textAttributes = [[NSMutableDictionary alloc] initWithDictionary:[UITabBarItem.qmui_appearanceConfigured titleTextAttributesForState:UIControlStateNormal]];
            if (_tabBarItemTitleFont) {
                textAttributes[NSFontAttributeName] = _tabBarItemTitleFont;
            }
            if (QMUIHelper.canUpdateAppearance) {
                [UITabBarItem.qmui_appearanceConfigured setTitleTextAttributes:textAttributes forState:UIControlStateNormal];
            }
            [self.appearanceUpdatingTabBarControllers enumerateObjectsUsingBlock:^(UITabBarController * _Nonnull tabBarController, NSUInteger idx, BOOL * _Nonnull stop) {
                [tabBarController.tabBar.items enumerateObjectsUsingBlock:^(UITabBarItem * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                    [obj setTitleTextAttributes:textAttributes forState:UIControlStateNormal];
                }];
            }];
        }
    } ifValueChanged:_tabBarItemTitleFont newValue:tabBarItemTitleFont];
}

- (void)setTabBarItemTitleFontSelected:(UIFont *)tabBarItemTitleFontSelected {
    [QMUIConfiguration performAction:^{
        _tabBarItemTitleFontSelected = tabBarItemTitleFontSelected;
        
        if (@available(iOS 13.0, *)) {
            [self.tabBarAppearance qmui_applyItemAppearanceWithBlock:^(UITabBarItemAppearance * _Nonnull itemAppearance) {
                NSMutableDictionary<NSAttributedStringKey, id> *attributes = itemAppearance.selected.titleTextAttributes.mutableCopy;
                attributes[NSFontAttributeName] = tabBarItemTitleFontSelected;
                itemAppearance.selected.titleTextAttributes = attributes.copy;
            }];
            [self updateTabBarAppearance];
        } else {
            NSMutableDictionary<NSString *, id> *textAttributes = [[NSMutableDictionary alloc] initWithDictionary:[UITabBarItem.qmui_appearanceConfigured titleTextAttributesForState:UIControlStateSelected]];
            if (tabBarItemTitleFontSelected) {
                textAttributes[NSFontAttributeName] = tabBarItemTitleFontSelected;
            }
            if (QMUIHelper.canUpdateAppearance) {
                [UITabBarItem.qmui_appearanceConfigured setTitleTextAttributes:textAttributes forState:UIControlStateSelected];
            }
            [self.appearanceUpdatingTabBarControllers enumerateObjectsUsingBlock:^(UITabBarController * _Nonnull tabBarController, NSUInteger idx, BOOL * _Nonnull stop) {
                [tabBarController.tabBar.items enumerateObjectsUsingBlock:^(UITabBarItem * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                    [obj setTitleTextAttributes:textAttributes forState:UIControlStateSelected];
                }];
            }];
        }
    } ifValueChanged:_tabBarItemTitleFontSelected newValue:tabBarItemTitleFontSelected];
}

- (void)setTabBarItemTitleColor:(UIColor *)tabBarItemTitleColor {
    [QMUIConfiguration performAction:^{
        _tabBarItemTitleColor = tabBarItemTitleColor;
        
        if (@available(iOS 13.0, *)) {
            [self.tabBarAppearance qmui_applyItemAppearanceWithBlock:^(UITabBarItemAppearance * _Nonnull itemAppearance) {
                NSMutableDictionary<NSAttributedStringKey, id> *attributes = itemAppearance.normal.titleTextAttributes.mutableCopy;
                attributes[NSForegroundColorAttributeName] = tabBarItemTitleColor;
                itemAppearance.normal.titleTextAttributes = attributes.copy;
            }];
            [self updateTabBarAppearance];
        } else {
            NSMutableDictionary<NSString *, id> *textAttributes = [[NSMutableDictionary alloc] initWithDictionary:[UITabBarItem.qmui_appearanceConfigured titleTextAttributesForState:UIControlStateNormal]];
            textAttributes[NSForegroundColorAttributeName] = _tabBarItemTitleColor;
            if (QMUIHelper.canUpdateAppearance) {
                [UITabBarItem.qmui_appearanceConfigured setTitleTextAttributes:textAttributes forState:UIControlStateNormal];
            }
            [self.appearanceUpdatingTabBarControllers enumerateObjectsUsingBlock:^(UITabBarController * _Nonnull tabBarController, NSUInteger idx, BOOL * _Nonnull stop) {
                [tabBarController.tabBar.items enumerateObjectsUsingBlock:^(UITabBarItem * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                    [obj setTitleTextAttributes:textAttributes forState:UIControlStateNormal];
                }];
            }];
        }
    } ifValueChanged:_tabBarItemTitleColor newValue:tabBarItemTitleColor];
}

- (void)setTabBarItemTitleColorSelected:(UIColor *)tabBarItemTitleColorSelected {
    [QMUIConfiguration performAction:^{
        _tabBarItemTitleColorSelected = tabBarItemTitleColorSelected;
        
        if (@available(iOS 13.0, *)) {
            [self.tabBarAppearance qmui_applyItemAppearanceWithBlock:^(UITabBarItemAppearance * _Nonnull itemAppearance) {
                NSMutableDictionary<NSAttributedStringKey, id> *attributes = itemAppearance.selected.titleTextAttributes.mutableCopy;
                attributes[NSForegroundColorAttributeName] = tabBarItemTitleColorSelected;
                itemAppearance.selected.titleTextAttributes = attributes.copy;
            }];
            [self updateTabBarAppearance];
        } else {
            NSMutableDictionary<NSString *, id> *textAttributes = [[NSMutableDictionary alloc] initWithDictionary:[UITabBarItem.qmui_appearanceConfigured titleTextAttributesForState:UIControlStateSelected]];
            textAttributes[NSForegroundColorAttributeName] = _tabBarItemTitleColorSelected;
            if (QMUIHelper.canUpdateAppearance) {
                [UITabBarItem.qmui_appearanceConfigured setTitleTextAttributes:textAttributes forState:UIControlStateSelected];
            }
            [self.appearanceUpdatingTabBarControllers enumerateObjectsUsingBlock:^(UITabBarController * _Nonnull tabBarController, NSUInteger idx, BOOL * _Nonnull stop) {
                [tabBarController.tabBar.items enumerateObjectsUsingBlock:^(UITabBarItem * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                    [obj setTitleTextAttributes:textAttributes forState:UIControlStateSelected];
                }];
            }];
        }
    } ifValueChanged:_tabBarItemTitleColorSelected newValue:tabBarItemTitleColorSelected];
}

- (void)setTabBarItemImageColor:(UIColor *)tabBarItemImageColor {
    [QMUIConfiguration performAction:^{
        _tabBarItemImageColor = tabBarItemImageColor;
        
        if (@available(iOS 13.0, *)) {
            [self.tabBarAppearance qmui_applyItemAppearanceWithBlock:^(UITabBarItemAppearance * _Nonnull itemAppearance) {
                itemAppearance.normal.iconColor = tabBarItemImageColor;
            }];
            [self updateTabBarAppearance];
        } else {
            if (QMUIHelper.canUpdateAppearance) {
                UITabBar.qmui_appearanceConfigured.unselectedItemTintColor = tabBarItemImageColor;
            }
            [self.appearanceUpdatingTabBarControllers enumerateObjectsUsingBlock:^(UITabBarController * _Nonnull tabBarController, NSUInteger idx, BOOL * _Nonnull stop) {
                tabBarController.tabBar.unselectedItemTintColor = tabBarItemImageColor;
            }];
        }
    } ifValueChanged:_tabBarItemImageColor newValue:tabBarItemImageColor];
}

- (void)setTabBarItemImageColorSelected:(UIColor *)tabBarItemImageColorSelected {
    [QMUIConfiguration performAction:^{
        _tabBarItemImageColorSelected = tabBarItemImageColorSelected;
        
        if (@available(iOS 13.0, *)) {
            [self.tabBarAppearance qmui_applyItemAppearanceWithBlock:^(UITabBarItemAppearance * _Nonnull itemAppearance) {
                itemAppearance.selected.iconColor = tabBarItemImageColorSelected;
            }];
            [self updateTabBarAppearance];
        } else {
            // iOS 12 及以下使用 tintColor 实现，但 tintColor 并没有声明 UI_APPEARANCE_SELECTOR，所以暂不使用 appearance 的方式去修改（虽然 appearance 方式实测是生效的）
            //        UITabBar.qmui_appearanceConfigured.tintColor = tabBarItemImageColorSelected;
            [self.appearanceUpdatingTabBarControllers enumerateObjectsUsingBlock:^(UITabBarController * _Nonnull tabBarController, NSUInteger idx, BOOL * _Nonnull stop) {
                tabBarController.tabBar.tintColor = tabBarItemImageColorSelected;
            }];
        }
    } ifValueChanged:_tabBarItemImageColorSelected newValue:tabBarItemImageColorSelected];
}

- (void)setDefaultStatusBarStyle:(UIStatusBarStyle)defaultStatusBarStyle {
    _defaultStatusBarStyle = defaultStatusBarStyle;
    [[QMUIHelper visibleViewController] setNeedsStatusBarAppearanceUpdate];
}

#pragma mark - Appearance Updating Views

// 解决某些场景下更新配置表无法覆盖样式的问题 https://github.com/Tencent/QMUI_iOS/issues/700

- (NSArray <UITabBarController *>*)appearanceUpdatingTabBarControllers {
    NSArray<Class<UIAppearanceContainer>> *classes = nil;
    if (self.tabBarContainerClasses.count > 0) {
        classes = self.tabBarContainerClasses;
    } else {
        classes = @[UITabBarController.class];
    }
    // tabBarContainerClasses 里可能会设置非 UITabBarController 的 class，由于这里只需要关注 UITabBarController 的，所以做一次过滤
    classes = [classes qmui_filterWithBlock:^BOOL(Class<UIAppearanceContainer>  _Nonnull item) {
        return [item.class isSubclassOfClass:UITabBarController.class];
    }];
    return (NSArray <UITabBarController *>*)[self appearanceUpdatingViewControllersOfClasses:classes];
}

- (NSArray <UINavigationController *>*)appearanceUpdatingNavigationControllers {
    NSArray<Class<UIAppearanceContainer>> *classes = nil;
    if (self.navBarContainerClasses.count > 0) {
        classes = self.navBarContainerClasses;
    } else {
        classes = @[UINavigationController.class];
    }
    // navBarContainerClasses 里可能会设置非 UINavigationController 的 class，由于这里只需要关注 UINavigationController 的，所以做一次过滤
    classes = [classes qmui_filterWithBlock:^BOOL(Class<UIAppearanceContainer>  _Nonnull item) {
        return [item.class isSubclassOfClass:UINavigationController.class];
    }];
    return (NSArray <UINavigationController *>*)[self appearanceUpdatingViewControllersOfClasses:classes];
}

- (NSArray <UINavigationController *>*)appearanceUpdatingToolbarControllers {
    NSArray<Class<UIAppearanceContainer>> *classes = nil;
    if (self.toolBarContainerClasses.count > 0) {
        classes = self.toolBarContainerClasses;
    } else {
        classes = @[UINavigationController.class];
    }
    // toolBarContainerClasses 里可能会设置非 UINavigationController 的 class，由于这里只需要关注 UINavigationController 的，所以做一次过滤
    classes = [classes qmui_filterWithBlock:^BOOL(Class<UIAppearanceContainer>  _Nonnull item) {
        return [item.class isSubclassOfClass:UINavigationController.class];
    }];
    return (NSArray <UINavigationController *>*)[self appearanceUpdatingViewControllersOfClasses:classes];
}

- (NSArray <UIViewController *>*)appearanceUpdatingViewControllersOfClasses:(NSArray<Class<UIAppearanceContainer>> *)classes {
    if (!classes.count) return nil;
    NSMutableArray *viewControllers = [NSMutableArray array];
    [UIApplication.sharedApplication.windows enumerateObjectsUsingBlock:^(__kindof UIWindow * _Nonnull window, NSUInteger idx, BOOL * _Nonnull stop) {
        if (window.rootViewController) {
            [viewControllers addObjectsFromArray:[window.rootViewController qmui_existingViewControllersOfClasses:classes]];
        }
    }];
    return viewControllers;
}

@end

@implementation UINavigationBar (QMUIConfiguration)

+ (instancetype)qmui_appearanceConfigured {
    if (QMUICMIActivated && NavBarContainerClasses) {
        return [self appearanceWhenContainedInInstancesOfClasses:NavBarContainerClasses];
    }
    return [self appearance];
}

@end

@implementation UITabBar (QMUIConfiguration)

+ (instancetype)qmui_appearanceConfigured {
    if (QMUICMIActivated && TabBarContainerClasses) {
        return [self appearanceWhenContainedInInstancesOfClasses:TabBarContainerClasses];
    }
    return [self appearance];
}

@end

@implementation UIToolbar (QMUIConfiguration)

+ (instancetype)qmui_appearanceConfigured {
    if (QMUICMIActivated && ToolBarContainerClasses) {
        return [self appearanceWhenContainedInInstancesOfClasses:ToolBarContainerClasses];
    }
    return [self appearance];
}

@end

@implementation UITabBarItem (QMUIConfiguration)

+ (instancetype)qmui_appearanceConfigured {
    if (QMUICMIActivated && TabBarContainerClasses) {
        return [self appearanceWhenContainedInInstancesOfClasses:TabBarContainerClasses];
    }
    return [self appearance];
}

@end
