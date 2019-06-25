//
//  UIView+QMUITheme.m
//  QMUIKit
//
//  Created by molicechen(陈沛钞) on 2019/6/21.
//  Copyright © 2019 QMUI Team. All rights reserved.
//

#import "UIView+QMUITheme.h"
#import "QMUICore.h"

@interface UIView ()

@property(nonatomic, strong) UIColor *qmuiTheme_backgroundColor;
@end

@implementation UIView (QMUITheme)

QMUISynthesizeIdStrongProperty(qmuiTheme_backgroundColor, setQmuiTheme_backgroundColor)

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        // iOS 12 及以下的版本，[UIView setBackgroundColor:] 并不会保存传进来的 color，所以要自己用个变量保存起来，不然 QMUIThemeColor 对象就会被丢弃
        if (@available(iOS 13.0, *)) {
        } else {
            ExtendImplementationOfVoidMethodWithSingleArgument([UIView class], @selector(setBackgroundColor:), UIColor *, ^(UIView *selfObject, UIColor *color) {
                selfObject.qmuiTheme_backgroundColor = color;
            });
            ExtendImplementationOfNonVoidMethodWithoutArguments([UIView class], @selector(backgroundColor), UIColor *, ^UIColor *(UIView *selfObject, UIColor *originReturnValue) {
                return selfObject.qmuiTheme_backgroundColor ?: originReturnValue;
            });
        }
    });
}

@end
