//
//  NSCharacterSet+QMUI.m
//  QMUIKit
//
//  Created by MoLice on 2018/9/17.
//  Copyright © 2018年 QMUI Team. All rights reserved.
//

#import "NSCharacterSet+QMUI.h"

@implementation NSCharacterSet (QMUI)

+ (NSCharacterSet *)qmui_URLUserInputQueryAllowedCharacterSet {
    NSMutableCharacterSet *set = [NSCharacterSet URLQueryAllowedCharacterSet].mutableCopy;
    [set removeCharactersInString:@"#&="];
    return set.copy;
}

@end
