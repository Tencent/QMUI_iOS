//
//  UIViewController+QMUITheme.h
//  QMUIKit
//
//  Created by MoLice on 2019/6/26.
//  Copyright © 2019 QMUI Team. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class QMUIThemeManager;

@interface UIViewController (QMUITheme)

/**
 当主题变化时这个方法会被调用
 @param manager 当前的主题管理对象
 @param identifier 当前主题的标志，可自行修改参数类型为目标类型
 @param theme 当前主题对象，可自行修改参数类型为目标类型
 */
- (void)qmui_themeDidChangeByManager:(QMUIThemeManager *)manager identifier:(__kindof NSObject<NSCopying> *)identifier theme:(__kindof NSObject *)theme NS_REQUIRES_SUPER;
@end

NS_ASSUME_NONNULL_END
