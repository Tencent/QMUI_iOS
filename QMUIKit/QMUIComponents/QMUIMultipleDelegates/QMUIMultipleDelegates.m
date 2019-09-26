/*****
 * Tencent is pleased to support the open source community by making QMUI_iOS available.
 * Copyright (C) 2016-2019 THL A29 Limited, a Tencent company. All rights reserved.
 * Licensed under the MIT License (the "License"); you may not use this file except in compliance with the License. You may obtain a copy of the License at
 * http://opensource.org/licenses/MIT
 * Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.
 *****/

//
//  QMUIMultipleDelegates.m
//  QMUIKit
//
//  Created by QMUI Team on 2018/3/27.
//

#import "QMUIMultipleDelegates.h"
#import "NSPointerArray+QMUI.h"
#import "NSMethodSignature+QMUI.h"
#import <objc/runtime.h>

@interface QMUIMultipleDelegates ()

@property(nonatomic, strong, readwrite) NSPointerArray *delegates;
@end

@implementation QMUIMultipleDelegates

+ (instancetype)weakDelegates {
    QMUIMultipleDelegates *delegates = [[QMUIMultipleDelegates alloc] init];
    delegates.delegates = [NSPointerArray weakObjectsPointerArray];
    return delegates;
}

+ (instancetype)strongDelegates {
    QMUIMultipleDelegates *delegates = [[QMUIMultipleDelegates alloc] init];
    delegates.delegates = [NSPointerArray strongObjectsPointerArray];
    return delegates;
}

- (void)addDelegate:(id)delegate {
    if (![self containsDelegate:delegate] && delegate != self) {
        [self.delegates addPointer:(__bridge void *)delegate];
    }
}

- (BOOL)removeDelegate:(id)delegate {
    NSUInteger index = [self.delegates qmui_indexOfPointer:(__bridge void *)delegate];
    if (index != NSNotFound) {
        [self.delegates removePointerAtIndex:index];
        return YES;
    }
    return NO;
}

- (void)removeAllDelegates {
    for (NSInteger i = self.delegates.count - 1; i >= 0; i--) {
        [self.delegates removePointerAtIndex:i];
    }
}

- (BOOL)containsDelegate:(id)delegate {
    return [self.delegates qmui_containsPointer:(__bridge void *)delegate];
}

- (NSMethodSignature *)methodSignatureForSelector:(SEL)aSelector {
    NSMethodSignature *result = [super methodSignatureForSelector:aSelector];
    if (result) {
        return result;
    }
    
    NSPointerArray *delegates = [self.delegates copy];
    for (id delegate in delegates) {
        result = [delegate methodSignatureForSelector:aSelector];
        if (result && [delegate respondsToSelector:aSelector]) {
            return result;
        }
    }
    
    return NSMethodSignature.qmui_avoidExceptionSignature;
}

- (void)forwardInvocation:(NSInvocation *)anInvocation {
    SEL selector = anInvocation.selector;
    NSPointerArray *delegates = [self.delegates copy];
    for (id delegate in delegates) {
        if ([delegate respondsToSelector:selector]) {
            [anInvocation invokeWithTarget:delegate];
        }
    }
}

- (BOOL)respondsToSelector:(SEL)aSelector {
    if ([super respondsToSelector:aSelector]) {
        return YES;
    }
    
    NSPointerArray *delegates = [self.delegates copy];
    for (id delegate in delegates) {
        if (class_respondsToSelector(self.class, aSelector)) {
            return YES;
        }
        
        // 对 QMUIMultipleDelegates 额外处理的解释在这里：https://github.com/Tencent/QMUI_iOS/issues/357
        BOOL delegateCanRespondToSelector = [delegate isKindOfClass:self.class] ? [delegate respondsToSelector:aSelector] : class_respondsToSelector(((NSObject *)delegate).class, aSelector);
        
        // 判断 qmui_delegatesSelf 是为了解决这个 issue：https://github.com/Tencent/QMUI_iOS/issues/346
        BOOL isDelegateSelf = ((NSObject *)delegate).qmui_delegatesSelf;
        if (delegateCanRespondToSelector && !isDelegateSelf) {
            return YES;
        }
    }
    return NO;
}

#pragma mark - Overrides

- (BOOL)isKindOfClass:(Class)aClass {
    BOOL result = [super isKindOfClass:aClass];
    if (result) return YES;
    
    NSPointerArray *delegates = [self.delegates copy];
    for (id delegate in delegates) {
        if ([delegate isKindOfClass:aClass]) return YES;
    }
    
    return NO;
}

- (BOOL)isMemberOfClass:(Class)aClass {
    BOOL result = [super isMemberOfClass:aClass];
    if (result) return YES;
    
    NSPointerArray *delegates = [self.delegates copy];
    for (id delegate in delegates) {
        if ([delegate isMemberOfClass:aClass]) return YES;
    }
    
    return NO;
}

- (BOOL)conformsToProtocol:(Protocol *)aProtocol {
    BOOL result = [super conformsToProtocol:aProtocol];
    if (result) return YES;
    
    NSPointerArray *delegates = [self.delegates copy];
    for (id delegate in delegates) {
        if ([delegate conformsToProtocol:aProtocol]) return YES;
    }
    
    return NO;
}

- (NSString *)description {
    return [NSString stringWithFormat:@"%@, parentObject is %@, %@", [super description], self.parentObject, self.delegates];
}

@end
