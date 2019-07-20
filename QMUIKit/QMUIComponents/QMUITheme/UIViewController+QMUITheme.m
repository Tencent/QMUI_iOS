//
//  UIViewController+QMUITheme.m
//  QMUIKit
//
//  Created by MoLice on 2019/6/26.
//  Copyright © 2019 QMUI Team. All rights reserved.
//

#import "UIViewController+QMUITheme.h"

@implementation UIViewController (QMUITheme)

- (void)qmui_themeDidChangeByManager:(QMUIThemeManager *)manager identifier:(__kindof NSObject<NSCopying> *)identifier theme:(__kindof NSObject *)theme {
    [self.childViewControllers enumerateObjectsUsingBlock:^(__kindof UIViewController * _Nonnull childViewController, NSUInteger idx, BOOL * _Nonnull stop) {
        [childViewController qmui_themeDidChangeByManager:manager identifier:identifier theme:theme];
    }];
}

@end
