//
//  NSMethodSignature+QMUI.m
//  QMUIKit
//
//  Created by MoLice on 2019/A/28.
//  Copyright © 2019 QMUI Team. All rights reserved.
//

#import "NSMethodSignature+QMUI.h"
#import "NSObject+QMUI.h"

@implementation NSMethodSignature (QMUI)

- (NSString *)qmui_typeString {
    NSString *typeString;
    [self qmui_performSelector:NSSelectorFromString([NSString stringWithFormat:@"_%@String", @"type"]) withReturnValue:&typeString];
    return typeString;
}

- (const char *)qmui_typeEncoding {
    return self.qmui_typeString.UTF8String;
}

@end
