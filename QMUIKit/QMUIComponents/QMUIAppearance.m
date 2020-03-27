/*****
 * Tencent is pleased to support the open source community by making QMUI_iOS available.
 * Copyright (C) 2016-2020 THL A29 Limited, a Tencent company. All rights reserved.
 * Licensed under the MIT License (the "License"); you may not use this file except in compliance with the License. You may obtain a copy of the License at
 * http://opensource.org/licenses/MIT
 * Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.
 *****/
//
//  QMUIAppearance.m
//  QMUIKit
//
//  Created by MoLice on 2020/3/25.
//

#import "QMUIAppearance.h"
#import "QMUICore.h"
#import "QMUIWeakObjectContainer.h"

@implementation QMUIAppearance

static NSMutableDictionary *appearances;
+ (id)appearanceForClass:(Class)aClass {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (!appearances) {
            appearances = NSMutableDictionary.new;
        }
    });
    NSString *className = NSStringFromClass(aClass);
    id appearance = appearances[className];
    if (!appearance) {
        BeginIgnorePerformSelectorLeaksWarning
        SEL selector = NSSelectorFromString([NSString stringWithFormat:@"_%@:%@:", @"appearanceForClass", @"withContainerList"]);
        appearance = [NSClassFromString(@"_UIAppearance") performSelector:selector withObject:aClass withObject:nil];
        appearances[className] = appearance;
        EndIgnorePerformSelectorLeaksWarning
    }
    return appearance;
}

@end

BeginIgnoreClangWarning(-Wincomplete-implementation)
@interface NSObject (QMUIAppearance_Private)

+ (instancetype)appearance;
@end

@implementation NSObject (QMUIAppearnace)

- (void)qmui_applyAppearance {
    if ([self.class respondsToSelector:@selector(appearance)]) {
        NSArray<NSInvocation *> *invocations = [self.class.appearance valueForKey:@"_appearanceInvocations"];
        [invocations enumerateObjectsUsingBlock:^(NSInvocation * _Nonnull invocation, NSUInteger idx, BOOL * _Nonnull stop) {
            invocation.target = [QMUIWeakObjectContainer containerWithObject:self];
            [invocation invoke];
        }];
    }
}

@end
EndIgnoreClangWarning
