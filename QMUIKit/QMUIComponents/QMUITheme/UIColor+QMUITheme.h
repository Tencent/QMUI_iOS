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

/**
 生成一个动态的 color 对象，每次使用该颜色时都会动态根据当前的 QMUIThemeManager 主题返回对应的颜色。
 @param provider 当 color 被使用时，这个 provider 会被调用，返回对应当前主题的 color 值
 @return 当前主题下的实际色值，由 provider 返回
 */
+ (UIColor *)qmui_colorWithThemeProvider:(UIColor *(^)(__kindof QMUIThemeManager *manager, __kindof NSObject<NSCopying> * _Nullable identifier, __kindof NSObject * _Nullable theme))provider;

@end

NS_ASSUME_NONNULL_END
