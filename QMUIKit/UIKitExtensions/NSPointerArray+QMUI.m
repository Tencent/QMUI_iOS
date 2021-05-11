/**
 * Tencent is pleased to support the open source community by making QMUI_iOS available.
 * Copyright (C) 2016-2021 THL A29 Limited, a Tencent company. All rights reserved.
 * Licensed under the MIT License (the "License"); you may not use this file except in compliance with the License. You may obtain a copy of the License at
 * http://opensource.org/licenses/MIT
 * Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.
 */

//
//  NSPointerArray+QMUI.m
//  QMUIKit
//
//  Created by QMUI Team on 2018/4/12.
//

#import "NSPointerArray+QMUI.h"
#import "QMUICore.h"

@implementation NSPointerArray (QMUI)

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        ExtendImplementationOfNonVoidMethodWithoutArguments([NSPointerArray class], @selector(description), NSString *, ^NSString *(NSPointerArray *selfObject, NSString *originReturnValue) {
            NSMutableString *result = [[NSMutableString alloc] initWithString:originReturnValue];
            NSPointerArray *array = [selfObject copy];
            for (NSInteger i = 0; i < array.count; i++) {
                ([result appendFormat:@"\npointer[%@] is %@", @(i), [array pointerAtIndex:i]]);
            }
            return result;
        });
    });
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
