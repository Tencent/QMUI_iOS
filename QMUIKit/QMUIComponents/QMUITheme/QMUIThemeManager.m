//
//  QMUIThemeManager.m
//  QMUIKit
//
//  Created by MoLice on 2019/J/20.
//  Copyright © 2019 QMUI Team. All rights reserved.
//

#import "QMUIThemeManager.h"
#import "QMUICore.h"

NSString *const QMUIThemeIdentifierLight = @"UIUserInterfaceStyleLight";
NSString *const QMUIThemeIdentifierDark = @"UIUserInterfaceStyleDark";

@interface _QMUIThemeWindow : UIWindow

@end

@implementation _QMUIThemeWindow

@end

@interface QMUIThemeManager ()

@property(nonatomic, strong) _QMUIThemeWindow *traitCollectionWindow;
@end

@implementation QMUIThemeManager

+ (instancetype)sharedInstance {
    static dispatch_once_t onceToken;
    static QMUIThemeManager *instance = nil;
    dispatch_once(&onceToken,^{
        instance = [[super allocWithZone:NULL] init];
        instance->_themes = NSMutableDictionary.new;
        
#ifdef IOS13_SDK_ALLOWED
        if (@available(iOS 13.0, *)) {
            instance.adjustSystemUserInterfaceStyleAutomatically = YES;
            instance.themes[QMUIThemeIdentifierLight] = @(UIUserInterfaceStyleLight);
            instance.themes[QMUIThemeIdentifierDark] = @(UIUserInterfaceStyleDark);
            if (UITraitCollection.currentTraitCollection.userInterfaceStyle == UIUserInterfaceStyleLight) instance.currentThemeIdentifier = QMUIThemeIdentifierLight;
            else if (UITraitCollection.currentTraitCollection.userInterfaceStyle == UIUserInterfaceStyleDark) instance.currentThemeIdentifier = QMUIThemeIdentifierDark;
            
            _QMUIThemeWindow *window = [[_QMUIThemeWindow alloc] initWithFrame:CGRectMake(0, 0, CGFLOAT_MIN, CGFLOAT_MIN)];// 用最小的尺寸避免影响 App 操作
            window.userInteractionEnabled = NO;
            window.hidden = NO;// 要可视并且处于 view 层级树内才能保证 provider block 被及时调用（App 回到后台时、回到前台时）
            __weak __typeof(instance)weakInstance = instance;
            window.backgroundColor = [UIColor colorWithDynamicProvider:^UIColor * _Nonnull(UITraitCollection * _Nonnull trait) {
                if (!weakInstance.adjustSystemUserInterfaceStyleAutomatically)
                    return UIColorClear;
                
                if (trait.userInterfaceStyle == UIUserInterfaceStyleLight && [weakInstance.currentThemeIdentifier isEqual:QMUIThemeIdentifierDark]) {
                    weakInstance.currentThemeIdentifier = QMUIThemeIdentifierLight;
                } else if (trait.userInterfaceStyle == UIUserInterfaceStyleDark && [weakInstance.currentThemeIdentifier isEqual:QMUIThemeIdentifierLight]) {
                    weakInstance.currentThemeIdentifier = QMUIThemeIdentifierDark;
                }
                return UIColorClear;
            }];
            instance.traitCollectionWindow = window;
        }
#endif
    });
    return instance;
}

+ (id)allocWithZone:(struct _NSZone *)zone{
    return [self sharedInstance];
}

- (void)setCurrentTheme:(NSObject *)currentTheme {
    NSAssert([self.themes.allValues containsObject:currentTheme], @"%@ should be added to QMUIThemeManager.themes before it becomes current theme.", currentTheme);
    _currentTheme = currentTheme;
    _currentThemeIdentifier = [self.themes allKeysForObject:currentTheme].firstObject;
}

- (void)setCurrentThemeIdentifier:(NSObject<NSCopying> *)currentThemeIdentifier {
    NSAssert([self.themes.allKeys containsObject:currentThemeIdentifier], @"%@ should be added to QMUIThemeManager.themes before it becomes current theme identifier.", currentThemeIdentifier);
    _currentThemeIdentifier = currentThemeIdentifier;
    _currentTheme = self.themes[currentThemeIdentifier];
}

@end
