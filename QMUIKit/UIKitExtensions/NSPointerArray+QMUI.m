//
//  NSPointerArray+QMUI.m
//  QMUIKit
//
//  Created by MoLice on 2018/4/12.
//  Copyright © 2018年 QMUI Team. All rights reserved.
//

#import "NSPointerArray+QMUI.h"
#import "QMUICore.h"
#import <objc/runtime.h>

@implementation NSPointerArray (QMUI)

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        ExchangeImplementations([self class], @selector(description), @selector(qmui_description));
    });
}

- (NSString *)qmui_description {
    NSString *superResult = [self qmui_description];
    NSMutableString *result = [[NSMutableString alloc] initWithString:superResult];
    NSPointerArray *array = [self copy];
    for (NSInteger i = 0; i < array.count; i++) {
        [result appendFormat:@"\npointer[%@] is  %@", @(i), [array pointerAtIndex:i]];
    }
    return result;
}

- (NSUInteger)qmui_indexOfPointer:(nullable void *)pointer {
    if (!pointer) {
        return NSNotFound;
    }
    
    NSPointerArray *array = [self copy];
    for (NSUInteger i = 0; i < array.count; i++) {
        if ([array pointerAtIndex:i] == ((void *)pointer)) {
            return i;
        }
    }
    return NSNotFound;
}

- (BOOL)qmui_containsPointer:(void *)pointer {
    if (!pointer) {
        return NO;
    }
    if ([self qmui_indexOfPointer:pointer] != NSNotFound) {
        return YES;
    }
    return NO;
}

@end
