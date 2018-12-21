/*****
 * Tencent is pleased to support the open source community by making QMUI_iOS available.
 * Copyright (C) 2016-2018 THL A29 Limited, a Tencent company. All rights reserved.
 * Licensed under the MIT License (the "License"); you may not use this file except in compliance with the License. You may obtain a copy of the License at
 * http://opensource.org/licenses/MIT
 * Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.
 *****/

//
//  NSObject+QMUI.m
//  qmui
//
//  Created by QMUI Team on 2016/11/1.
//

#import "NSObject+QMUI.h"
#import "QMUIWeakObjectContainer.h"
#import <objc/message.h>

@implementation NSObject (QMUI)

- (BOOL)qmui_hasOverrideMethod:(SEL)selector ofSuperclass:(Class)superclass {
    return [NSObject qmui_hasOverrideMethod:selector forClass:self.class ofSuperclass:superclass];
}

+ (BOOL)qmui_hasOverrideMethod:(SEL)selector forClass:(Class)aClass ofSuperclass:(Class)superclass {
    if (![aClass isSubclassOfClass:superclass]) {
        return NO;
    }
    
    if (![superclass instancesRespondToSelector:selector]) {
        return NO;
    }
    
    Method superclassMethod = class_getInstanceMethod(superclass, selector);
    Method instanceMethod = class_getInstanceMethod(aClass, selector);
    if (!instanceMethod || instanceMethod == superclassMethod) {
        return NO;
    }
    return YES;
}

- (id)qmui_performSelectorToSuperclass:(SEL)aSelector {
    struct objc_super mySuper;
    mySuper.receiver = self;
    mySuper.super_class = class_getSuperclass(object_getClass(self));
    
    id (*objc_superAllocTyped)(struct objc_super *, SEL) = (void *)&objc_msgSendSuper;
    return (*objc_superAllocTyped)(&mySuper, aSelector);
}

- (id)qmui_performSelectorToSuperclass:(SEL)aSelector withObject:(id)object {
    struct objc_super mySuper;
    mySuper.receiver = self;
    mySuper.super_class = class_getSuperclass(object_getClass(self));
    
    id (*objc_superAllocTyped)(struct objc_super *, SEL, ...) = (void *)&objc_msgSendSuper;
    return (*objc_superAllocTyped)(&mySuper, aSelector, object);
}

- (void)qmui_performSelector:(SEL)selector {
    [self qmui_performSelector:selector withReturnValue:NULL arguments:NULL];
}

- (void)qmui_performSelector:(SEL)selector withArguments:(void *)firstArgument, ... {
    [self qmui_performSelector:selector withReturnValue:NULL arguments:firstArgument, NULL];
}

- (void)qmui_performSelector:(SEL)selector withReturnValue:(void *)returnValue {
    [self qmui_performSelector:selector withReturnValue:returnValue arguments:NULL];
}

- (void)qmui_performSelector:(SEL)selector withReturnValue:(void *)returnValue arguments:(void *)firstArgument, ... {
    NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:[self methodSignatureForSelector:selector]];
    [invocation setTarget:self];
    [invocation setSelector:selector];
    
    if (firstArgument) {
        [invocation setArgument:firstArgument atIndex:2];
        
        va_list args;
        va_start(args, firstArgument);
        void *currentArgument;
        NSInteger index = 3;
        while ((currentArgument = va_arg(args, void *))) {
            [invocation setArgument:currentArgument atIndex:index];
            index++;
        }
        va_end(args);
    }
    
    [invocation invoke];
    
    if (returnValue) {
        [invocation getReturnValue:returnValue];
    }
}

- (void)qmui_enumrateIvarsUsingBlock:(void (^)(Ivar ivar, NSString *ivarName))block {
    [NSObject qmui_enumrateIvarsOfClass:self.class includingInherited:NO usingBlock:block];
}

+ (void)qmui_enumrateIvarsOfClass:(Class)aClass includingInherited:(BOOL)includingInherited usingBlock:(void (^)(Ivar, NSString *))block {
    unsigned int outCount = 0;
    Ivar *ivars = class_copyIvarList(aClass, &outCount);
    for (unsigned int i = 0; i < outCount; i ++) {
        Ivar ivar = ivars[i];
        if (block) block(ivar, [NSString stringWithFormat:@"%s", ivar_getName(ivar)]);
    }
    free(ivars);
    
    if (includingInherited) {
        Class superclass = class_getSuperclass(aClass);
        if (superclass) {
            [NSObject qmui_enumrateIvarsOfClass:superclass includingInherited:includingInherited usingBlock:block];
        }
    }
}

- (void)qmui_enumratePropertiesUsingBlock:(void (^)(objc_property_t property, NSString *propertyName))block {
    [NSObject qmui_enumratePropertiesOfClass:self.class includingInherited:NO usingBlock:block];
}

+ (void)qmui_enumratePropertiesOfClass:(Class)aClass includingInherited:(BOOL)includingInherited usingBlock:(void (^)(objc_property_t, NSString *))block {
    unsigned int propertiesCount = 0;
    objc_property_t *properties = class_copyPropertyList(aClass, &propertiesCount);
    
    for (unsigned int i = 0; i < propertiesCount; i++) {
        objc_property_t property = properties[i];
        if (block) block(property, [NSString stringWithFormat:@"%s", property_getName(property)]);
    }
    
    free(properties);
    
    if (includingInherited) {
        Class superclass = class_getSuperclass(aClass);
        if (superclass) {
            [NSObject qmui_enumratePropertiesOfClass:superclass includingInherited:includingInherited usingBlock:block];
        }
    }
}

- (void)qmui_enumrateInstanceMethodsUsingBlock:(void (^)(Method, SEL))block {
    [NSObject qmui_enumrateInstanceMethodsOfClass:self.class includingInherited:NO usingBlock:block];
}

+ (void)qmui_enumrateInstanceMethodsOfClass:(Class)aClass includingInherited:(BOOL)includingInherited usingBlock:(void (^)(Method, SEL))block {
    unsigned int methodCount = 0;
    Method *methods = class_copyMethodList(aClass, &methodCount);
    
    for (unsigned int i = 0; i < methodCount; i++) {
        Method method = methods[i];
        SEL selector = method_getName(method);
        if (block) block(method, selector);
    }
    
    free(methods);
    
    if (includingInherited) {
        Class superclass = class_getSuperclass(aClass);
        if (superclass) {
            [NSObject qmui_enumrateInstanceMethodsOfClass:superclass includingInherited:includingInherited usingBlock:block];
        }
    }
}

+ (void)qmui_enumerateProtocolMethods:(Protocol *)protocol usingBlock:(void (^)(SEL))block {
    unsigned int methodCount = 0;
    struct objc_method_description *methods = protocol_copyMethodDescriptionList(protocol, NO, YES, &methodCount);
    for (int i = 0; i < methodCount; i++) {
        struct objc_method_description methodDescription = methods[i];
        if (block) {
            block(methodDescription.name);
        }
    }
    free(methods);
}

@end


@implementation NSObject (QMUI_DataBind)

static char kAssociatedObjectKey_QMUIAllBindObjects;
- (NSMutableDictionary<id, id> *)qmui_allBindObjects {
    NSMutableDictionary<id, id> *dict = objc_getAssociatedObject(self, &kAssociatedObjectKey_QMUIAllBindObjects);
    if (!dict) {
        dict = [NSMutableDictionary dictionary];
        objc_setAssociatedObject(self, &kAssociatedObjectKey_QMUIAllBindObjects, dict, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    return dict;
}

- (void)qmui_bindObject:(id)object forKey:(NSString *)key {
    if (!key.length) {
        NSAssert(NO, @"");
        return;
    }
    if (object) {
        [[self qmui_allBindObjects] setObject:object forKey:key];
    } else {
        [[self qmui_allBindObjects] removeObjectForKey:key];
    }
}

- (void)qmui_bindObjectWeakly:(id)object forKey:(NSString *)key {
    if (!key.length) {
        NSAssert(NO, @"");
        return;
    }
    if (object) {
        QMUIWeakObjectContainer *container = [[QMUIWeakObjectContainer alloc] initWithObject:object];
        [self qmui_bindObject:container forKey:key];
    } else {
        [[self qmui_allBindObjects] removeObjectForKey:key];
    }
}

- (id)qmui_getBindObjectForKey:(NSString *)key {
    if (!key.length) {
        NSAssert(NO, @"");
        return nil;
    }
    id storedObj = [[self qmui_allBindObjects] objectForKey:key];
    if ([storedObj isKindOfClass:[QMUIWeakObjectContainer class]]) {
        storedObj = [(QMUIWeakObjectContainer *)storedObj object];
    }
    return storedObj;
}

- (void)qmui_bindDouble:(double)doubleValue forKey:(NSString *)key {
    [self qmui_bindObject:@(doubleValue) forKey:key];
}

- (double)qmui_getBindDoubleForKey:(NSString *)key {
    id object = [self qmui_getBindObjectForKey:key];
    if ([object isKindOfClass:[NSNumber class]]) {
        double doubleValue = [(NSNumber *)object doubleValue];
        return doubleValue;
        
    } else {
        return 0.0;
    }
}

- (void)qmui_bindBOOL:(BOOL)boolValue forKey:(NSString *)key {
    [self qmui_bindObject:@(boolValue) forKey:key];
}

- (BOOL)qmui_getBindBOOLForKey:(NSString *)key {
    id object = [self qmui_getBindObjectForKey:key];
    if ([object isKindOfClass:[NSNumber class]]) {
        BOOL boolValue = [(NSNumber *)object boolValue];
        return boolValue;
        
    } else {
        return NO;
    }
}

- (void)qmui_bindLong:(long)longValue forKey:(NSString *)key {
    [self qmui_bindObject:@(longValue) forKey:key];
}

- (long)qmui_getBindLongForKey:(NSString *)key {
    id object = [self qmui_getBindObjectForKey:key];
    if ([object isKindOfClass:[NSNumber class]]) {
        long longValue = [(NSNumber *)object longValue];
        return longValue;
        
    } else {
        return 0;
    }
}

- (void)qmui_clearBindForKey:(NSString *)key {
    [self qmui_bindObject:nil forKey:key];
}

- (void)qmui_clearAllBind {
    [[self qmui_allBindObjects] removeAllObjects];
}

- (NSArray<NSString *> *)qmui_allBindKeys {
    NSArray<NSString *> *allKeys = [[self qmui_allBindObjects] allKeys];
    return allKeys;
}

@end
