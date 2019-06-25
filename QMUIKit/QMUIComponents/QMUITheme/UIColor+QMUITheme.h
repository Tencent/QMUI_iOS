//
//  UIColor+QMUITheme.h
//  QMUIKit
//
//  Created by MoLice on 2019/J/20.
//  Copyright © 2019 QMUI Team. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class QMUIThemeManager;

@interface UIColor (QMUITheme)

+ (UIColor *)qmui_colorWithThemeProvider:(UIColor *(^)(__kindof QMUIThemeManager *manager, NSObject<NSCopying> * _Nullable identifier, NSObject * _Nullable currentTheme))provider;
@end

NS_ASSUME_NONNULL_END
