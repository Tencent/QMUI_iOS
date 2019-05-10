//
//  NSMethodSignature+QMUI.m
//  QMUIKit
//
//  Created by MoLice on 2019/A/28.
//  Copyright © 2019 QMUI Team. All rights reserved.
//

#import "NSMethodSignature+QMUI.h"
#import "NSObject+QMUI.h"
#import "QMUICore.h"

@implementation NSMethodSignature (QMUI)

- (NSString *)qmui_typeString {
    BeginIgnorePerformSelectorLeaksWarning
    NSString *typeString = [self performSelector:NSSelectorFromString([NSString stringWithFormat:@"_%@String", @"type"])];
    EndIgnorePerformSelectorLeaksWarning
    return typeString;
}

- (const char *)qmui_typeEncoding {
    return self.qmui_typeString.UTF8String;
}

@end
