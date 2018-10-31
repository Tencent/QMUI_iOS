//
//  UINavigationBar+QMUI.m
//  QMUIKit
//
//  Created by MoLice on 2018/O/8.
//  Copyright © 2018 QMUI Team. All rights reserved.
//

#import "UINavigationBar+QMUI.h"

@implementation UINavigationBar (QMUI)

- (UIView *)qmui_backgroundView {
    return [self valueForKey:@"_backgroundView"];
}

- (__kindof UIView *)qmui_backgroundContentView {
    if (@available(iOS 10, *)) {
        UIImageView *imageView = [self.qmui_backgroundView valueForKey:@"_backgroundImageView"];
        UIVisualEffectView *visualEffectView = [self.qmui_backgroundView valueForKey:@"_backgroundEffectView"];
        UIView *customView = [self.qmui_backgroundView valueForKey:@"_customBackgroundView"];
        UIView *result = customView && customView.superview ? customView : (imageView && imageView.superview ? imageView : visualEffectView);
        return result;
    } else {
        UIView *backdrop = [self.qmui_backgroundView valueForKey:@"_adaptiveBackdrop"];
        UIView *result = backdrop && backdrop.superview ? backdrop : self.qmui_backgroundView;
        return result;
    }
}

- (UIImageView *)qmui_shadowImageView {
    // UINavigationBar 在 init 完就可以获取到 backgroundView 和 shadowView，无需关心调用时机的问题
    return [self.qmui_backgroundView valueForKey:@"_shadowView"];
}

@end
