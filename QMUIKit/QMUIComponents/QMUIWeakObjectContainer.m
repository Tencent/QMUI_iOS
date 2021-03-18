/**
 * Tencent is pleased to support the open source community by making QMUI_iOS available.
 * Copyright (C) 2016-2020 THL A29 Limited, a Tencent company. All rights reserved.
 * Licensed under the MIT License (the "License"); you may not use this file except in compliance with the License. You may obtain a copy of the License at
 * http://opensource.org/licenses/MIT
 * Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.
 */

//
//  QMUIWeakObjectContainer.m
//  QMUIKit
//
//  Created by QMUI Team on 2018/7/24.
//

#import "QMUIWeakObjectContainer.h"

// from https://github.com/ibireme/YYKit/blob/master/YYKit/Utility/YYWeakProxy.m

@implementation QMUIWeakObjectContainer

- (instancetype)initWithObject:(id)object {
    _object = object;
    return self;
}

- (instancetype)init {
    return self;
}

+ (instancetype)containerWithObject:(id)object {
    return [[self alloc] initWithObject:object];
}

- (id)forwardingTargetForSelector:(SEL)selector {
    return _object;
}

- (void)forwardInvocation:(NSInvocation *)invocation {
    void *null = NULL;
    [invocation setReturnValue:&null];
}

- (NSMethodSignature *)methodSignatureForSelector:(SEL)selector {
    return [NSObject instanceMethodSignatureForSelector:@selector(init)];
}

- (BOOL)respondsToSelector:(SEL)aSelector {
    return [_object respondsToSelector:aSelector];
}

- (BOOL)isEqual:(id)object {
    return [_object isEqual:object];
}

- (NSUInteger)hash {
    return [_object hash];
}

- (Class)superclass {
    return [_object superclass];
}

- (Class)class {
    return [_object class];
}

- (BOOL)isKindOfClass:(Class)aClass {
    return [_object isKindOfClass:aClass];
}

- (BOOL)isMemberOfClass:(Class)aClass {
    return [_object isMemberOfClass:aClass];
}

- (BOOL)conformsToProtocol:(Protocol *)aProtocol {
    return [_object conformsToProtocol:aProtocol];
}

- (BOOL)isProxy {
    return YES;
}

- (NSString *)description {
    return [_object description];
}

- (NSString *)debugDescription {
    return [_object debugDescription];
}

@end
