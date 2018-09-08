//
//  UITabBarItem+QMUI.m
//  qmui
//
//  Created by ZhoonChen on 15/7/20.
//  Copyright (c) 2015年 QMUI Team. All rights reserved.
//

#import "UITabBarItem+QMUI.h"
#import "QMUICore.h"
#import "UIBarItem+QMUI.h"

@implementation UITabBarItem (QMUI)

- (UIImageView *)qmui_imageView {
    return [self.class qmui_imageViewInTabBarButton:self.qmui_view];
}

+ (nullable UIImageView *)qmui_imageViewInTabBarButton:(UIView *)tabBarButton {
    
    if (!tabBarButton) {
        return nil;
    }
    
    for (UIView *subview in tabBarButton.subviews) {
        // iOS10及以后，imageView都是用UITabBarSwappableImageView实现的，所以遇到这个class就直接拿
        if ([NSStringFromClass([subview class]) isEqualToString:@"UITabBarSwappableImageView"]) {
            return (UIImageView *)subview;
        }
        
        if (IOS_VERSION < 10) {
            // iOS10以前，选中的item的高亮是用UITabBarSelectionIndicatorView实现的，所以要屏蔽掉
            if ([subview isKindOfClass:[UIImageView class]] && ![NSStringFromClass([subview class]) isEqualToString:@"UITabBarSelectionIndicatorView"]) {
                return (UIImageView *)subview;
            }
        }
        
    }
    return nil;
}

static char kAssociatedObjectKey_doubleTapBlock;
- (void)setQmui_doubleTapBlock:(void (^)(UITabBarItem *, NSInteger))qmui_doubleTapBlock {
    objc_setAssociatedObject(self, &kAssociatedObjectKey_doubleTapBlock, qmui_doubleTapBlock, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (void (^)(UITabBarItem *, NSInteger))qmui_doubleTapBlock {
    return (void (^)(UITabBarItem *, NSInteger))objc_getAssociatedObject(self, &kAssociatedObjectKey_doubleTapBlock);
}

@end
