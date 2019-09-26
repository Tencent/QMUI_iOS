/*****
 * Tencent is pleased to support the open source community by making QMUI_iOS available.
 * Copyright (C) 2016-2019 THL A29 Limited, a Tencent company. All rights reserved.
 * Licensed under the MIT License (the "License"); you may not use this file except in compliance with the License. You may obtain a copy of the License at
 * http://opensource.org/licenses/MIT
 * Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.
 *****/
//
//  UIColor+QMUITheme.m
//  QMUIKit
//
//  Created by MoLice on 2019/J/20.
//

#import "UIColor+QMUITheme.h"
#import "QMUIThemeManager.h"
#import "QMUICore.h"
#import "NSMethodSignature+QMUI.h"
#import "UIColor+QMUI.h"
#import "QMUIThemePrivate.h"
#import "QMUIThemeManagerCenter.h"

@implementation QMUIThemeColor

#pragma mark - Override

- (void)set {
    [self.qmui_rawColor set];
}

- (void)setFill {
    [self.qmui_rawColor setFill];
}

- (void)setStroke {
    [self.qmui_rawColor setStroke];
}

- (BOOL)getWhite:(CGFloat *)white alpha:(CGFloat *)alpha {
    return [self.qmui_rawColor getWhite:white alpha:alpha];
}

- (BOOL)getHue:(CGFloat *)hue saturation:(CGFloat *)saturation brightness:(CGFloat *)brightness alpha:(CGFloat *)alpha {
    return [self.qmui_rawColor getHue:hue saturation:saturation brightness:brightness alpha:alpha];
}

- (BOOL)getRed:(CGFloat *)red green:(CGFloat *)green blue:(CGFloat *)blue alpha:(CGFloat *)alpha {
    return [self.qmui_rawColor getRed:red green:green blue:blue alpha:alpha];
}

- (UIColor *)colorWithAlphaComponent:(CGFloat)alpha {
    return [UIColor qmui_colorWithThemeProvider:^UIColor * _Nonnull(__kindof QMUIThemeManager * _Nonnull manager, __kindof NSObject<NSCopying> * _Nullable identifier, __kindof NSObject * _Nullable theme) {
        return [self.themeProvider(manager, identifier, theme) colorWithAlphaComponent:alpha];
    }];
}

- (CGFloat)alphaComponent {
    return self.qmui_rawColor.qmui_alpha;
}

- (CGColorRef)CGColor {
    CGColorRef colorRef = [UIColor colorWithCGColor:self.qmui_rawColor.CGColor].CGColor;
    [(__bridge id)(colorRef) qmui_bindObject:self forKey:QMUICGColorOriginalColorBindKey];
    return colorRef;
}

- (NSString *)colorSpaceName {
    return [((QMUIThemeColor *)self.qmui_rawColor) colorSpaceName];
}

- (id)copyWithZone:(NSZone *)zone {
    QMUIThemeColor *color = [[self class] allocWithZone:zone];
    color.managerName = self.managerName;
    color.themeProvider = self.themeProvider;
    return color;
}

- (BOOL)isEqual:(id)object {
    return self == object;// 例如在 UIView setTintColor: 时会比较两个 color 是否相等，如果相等，则不会触发 tintColor 的更新。由于 dynamicColor 实际的返回色值随时可能变化，所以即便当前的 qmui_rawColor 值相等，也不应该认为两个 dynamicColor 相等（有可能 themeProvider block 内的逻辑不一致，只是其中的某个条件下 return 的 qmui_rawColor 恰好相同而已），所以这里直接返回 NO。
}

- (NSUInteger)hash {
    return (NSUInteger)self.themeProvider;// 与 UIDynamicProviderColor 相同
}

- (NSString *)description {
    return [NSString stringWithFormat:@"%@, qmui_rawColor = %@", [super description], self.qmui_rawColor];
}

#pragma mark - <QMUIDynamicColorProtocol>

@dynamic qmui_isDynamicColor;

- (UIColor *)qmui_rawColor {
    QMUIThemeManager *manager = [QMUIThemeManagerCenter themeManagerWithName:self.managerName];
    UIColor *color = self.themeProvider(manager, manager.currentThemeIdentifier, manager.currentTheme);
    UIColor *result = color.qmui_rawColor;
    return result;
}


// 注意，QMUIThemeColor 是 UIColor 的直接子类，只有这种关系才能这样直接定义并重写，不能在 UIColor Category 里定义，否则可能污染 UIDynamicColor 里的 _isDynamic 的实现
- (BOOL)_isDynamic {
    return !!self.themeProvider;
}

@end

@implementation UIColor (QMUITheme)

+ (instancetype)qmui_colorWithThemeProvider:(UIColor * _Nonnull (^)(__kindof QMUIThemeManager * _Nonnull, __kindof NSObject<NSCopying> * _Nullable, __kindof NSObject * _Nullable))provider {
    return [UIColor qmui_colorWithThemeManagerName:QMUIThemeManagerNameDefault provider:provider];
}

+ (UIColor *)qmui_colorWithThemeManagerName:(__kindof NSObject<NSCopying> *)name provider:(UIColor * _Nonnull (^)(__kindof QMUIThemeManager * _Nonnull, __kindof NSObject<NSCopying> * _Nullable, __kindof NSObject * _Nullable))provider {
    QMUIThemeColor *color = QMUIThemeColor.new;
    color.managerName = name;
    color.themeProvider = provider;
    return color;
}

@end
