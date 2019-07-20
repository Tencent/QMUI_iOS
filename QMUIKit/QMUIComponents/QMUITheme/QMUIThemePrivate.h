//
//  QMUIThemePrivate.h
//  QMUIKit
//
//  Created by MoLice on 2019/J/26.
//  Copyright © 2019 QMUI Team. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIView (QMUITheme_Private)

@property(nonatomic, weak) __kindof NSObject<NSCopying> *qmui_currentThemeIdentifier;
@property(nonatomic, weak) __kindof NSObject *qmui_currentTheme;
- (void)setQmui_currentThemeIdentifier:(__kindof NSObject<NSCopying> *)qmui_currentThemeIdentifier enumerateSubviews:(BOOL)enumerateSubviews notify:(BOOL)notify syncTheme:(BOOL)syncTheme;
- (void)setQmui_currentTheme:(__kindof NSObject *)qmui_currentTheme enumerateSubviews:(BOOL)enumerateSubviews notify:(BOOL)notify syncIdentifier:(BOOL)syncIdentifier;
- (void)_qmui_notifyThemeDidChange;

@property(nonatomic, strong) UIColor *qmuiTheme_backgroundColor;

/// 记录当前 view 总共有哪些 property 需要在 theme 变化时重新设置
@property(nonatomic, strong) NSMutableDictionary<NSString *, NSString *> *qmuiTheme_themeColorProperties;

- (BOOL)_qmui_visible;

@end

NS_ASSUME_NONNULL_END
