//
//  UIColor+QMUITheme.m
//  QMUIKit
//
//  Created by MoLice on 2019/J/20.
//  Copyright © 2019 QMUI Team. All rights reserved.
//

#import "UIColor+QMUITheme.h"
#import "QMUIThemeManager.h"
#import "QMUICore.h"

@interface QMUIThemeColor : UIColor

@property(nonatomic, copy) UIColor *(^themeProvider)(__kindof QMUIThemeManager * _Nonnull manager, NSObject<NSCopying> * _Nullable identifier, NSObject * _Nullable currentTheme);
@property(nonatomic, weak, readonly) UIColor *rawColor;
@end

@implementation UIColor (QMUITheme)

+ (instancetype)qmui_colorWithThemeProvider:(UIColor * _Nonnull (^)(__kindof QMUIThemeManager * _Nonnull, NSObject<NSCopying> * _Nullable, NSObject * _Nullable))provider {
    QMUIThemeColor *color = QMUIThemeColor.new;
    color.themeProvider = provider;
    return color;
}

@end

@implementation QMUIThemeColor

- (UIColor *)rawColor {
    if (self._isDynamic) {
        QMUIThemeManager *manager = QMUIThemeManager.sharedInstance;
        return self.themeProvider(manager, manager.currentThemeIdentifier, manager.currentTheme);
    }
    return self;
}

#pragma mark - Override

// iOS 13 新增的 UIDynamicColor 里的私有方法，要返回 YES 才能自动响应系统 UIUserInterfaceStyle 的切换
// 注意，要在 UIColor 的直接子类里才能这样定义，不能在 UIColor Category 里定义，否则可能污染 UIDynamicColor : UIColor 里的 _isDynamic 的实现
- (BOOL)_isDynamic {
    return !!self.themeProvider;
}

- (CGColorRef)CGColor {
    return self._isDynamic ? self.rawColor.CGColor : [super CGColor];
}

- (void)set {
    self._isDynamic ? [self.rawColor set] : [super set];
}

- (void)setFill {
    self._isDynamic ? [self.rawColor setFill] : [super setFill];
}

- (void)setStroke {
    self._isDynamic ? [self.rawColor setStroke] : [super setStroke];
}

- (BOOL)isEqual:(id)object {
    UIColor *targetColor = object;
    if ([targetColor isKindOfClass:[QMUIThemeColor class]]) {
        targetColor = ((QMUIThemeColor *)targetColor).rawColor;
        return self._isDynamic ? [self.rawColor isEqual:targetColor] : [super isEqual:targetColor];
    }
    return self._isDynamic ? [self.rawColor isEqual:targetColor] : [super isEqual:targetColor];
}

@end
