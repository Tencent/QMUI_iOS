//
//  UISwitch+QMUI.m
//  QMUIKit
//
//  Created by MoLice on 2019/7/12.
//  Copyright © 2019 QMUI Team. All rights reserved.
//

#import "UISwitch+QMUI.h"
#import "QMUICore.h"

@implementation UISwitch (QMUI)

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        ExtendImplementationOfNonVoidMethodWithSingleArgument([UISwitch class], @selector(initWithFrame:), CGRect, UISwitch *, ^UISwitch *(UISwitch *selfObject, CGRect firstArgv, UISwitch *originReturnValue) {
            if (QMUICMIActivated && SwitchTintColor) {
                selfObject.tintColor = SwitchTintColor;
            }
            return originReturnValue;
        });
    });
}

@end
