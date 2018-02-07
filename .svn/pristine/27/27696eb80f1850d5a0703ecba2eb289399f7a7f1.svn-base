//
//  NSObject+QMUI.m
//  qmui
//
//  Created by MoLice on 2016/11/1.
//  Copyright © 2016年 QMUI Team. All rights reserved.
//

#import "NSObject+QMUI.h"
#import <objc/message.h>
#import <objc/runtime.h>

@implementation NSObject (QMUI)

- (BOOL)qmui_hasOverrideMethod:(SEL)selector ofSuperclass:(Class)superclass {
    if (![[self class] isSubclassOfClass:superclass]) {
//        NSLog(@"%s, %@ 并非 %@ 的父类", __func__, NSStringFromClass(superclass), NSStringFromClass([self class]));
        return NO;
    }
    
    if (![superclass instancesRespondToSelector:selector]) {
//        NSLog(@"%s, 父类 %@ 自己本来就无法响应 %@ 方法", __func__, NSStringFromClass(superclass), NSStringFromSelector(selector));
        return NO;
    }
    
    Method superclassMethod = class_getInstanceMethod(superclass, selector);
    Method instanceMethod = class_getInstanceMethod([self class], selector);
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

- (void)qmui_enumrateInstanceMethodsUsingBlock:(void (^)(SEL))block {
    [NSObject qmui_enumrateInstanceMethodsOfClass:self.class usingBlock:block];
}

+ (void)qmui_enumrateInstanceMethodsOfClass:(Class)aClass usingBlock:(void (^)(SEL selector))block {
    unsigned int methodCount = 0;
    Method *methods = class_copyMethodList(aClass, &methodCount);
    
    for (unsigned int i = 0; i < methodCount; i++) {
        Method method = methods[i];
        SEL selector = method_getName(method);
        if (block) block(selector);
    }
    
    free(methods);
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
