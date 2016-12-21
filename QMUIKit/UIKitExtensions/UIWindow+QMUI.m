//
//  UIWindow+QMUI.m
//  qmui
//
//  Created by MoLice on 16/7/21.
//  Copyright © 2016年 QMUI Team. All rights reserved.
//

#import "UIWindow+QMUI.h"
#import "QMUICommonDefines.h"

@implementation UIWindow (QMUI)

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        ReplaceMethod([self class], @selector(init), @selector(qmui_init));
    });
}

- (instancetype)qmui_init {
    if (IOS_VERSION < 9.0) {
        // iOS 9 以前的版本，UIWindow init时如果不给一个frame，默认是CGRectZero，而iOS 9以后的版本，由于增加了分屏（Split View）功能，你的App可能运行在一个非全屏大小的区域内，所以UIWindow如果调用init方法（而不是initWithFrame:）来初始化，系统会自动为你的window设置一个合适的大小。所以这里对iOS 9以前的版本做适配，默认给一个全屏的frame
        UIWindow *window = [self qmui_init];
        window.frame = [[UIScreen mainScreen] bounds];
        return window;
    }
    
    return [self qmui_init];
}

@end
