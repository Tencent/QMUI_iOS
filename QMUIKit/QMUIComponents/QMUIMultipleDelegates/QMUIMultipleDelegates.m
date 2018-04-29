//
//  QMUIMultipleDelegates.m
//  QMUIKit
//
//  Created by MoLice on 2018/3/27.
//  Copyright © 2018年 QMUI Team. All rights reserved.
//

#import "QMUIMultipleDelegates.h"
#import "NSPointerArray+QMUI.h"

@interface QMUIMultipleDelegates ()

@property(nonatomic, strong) NSPointerArray *delegates;
@end

@implementation QMUIMultipleDelegates

- (instancetype)init {
    self = [super init];
    if (self) {
        self.delegates = [NSPointerArray weakObjectsPointerArray];
    }
    return self;
}

- (void)addDelegate:(id)delegate {
    if (![self.delegates qmui_containsPointer:(__bridge void *)delegate] && delegate != self) {
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

- (NSMethodSignature *)methodSignatureForSelector:(SEL)aSelector {
    NSMethodSignature *result = [super methodSignatureForSelector:aSelector];
    if (result) {
        return result;
    }
    
    NSPointerArray *delegates = [self.delegates copy];
    for (id delegate in delegates) {
        result = [delegate methodSignatureForSelector:aSelector];
        if (result) {
            return result;
        }
    }
    // https://github.com/facebookarchive/AsyncDisplayKit/pull/1562
    // Unfortunately, in order to get this object to work properly, the use of a method which creates an NSMethodSignature
    // from a C string. -methodSignatureForSelector is called when a compiled definition for the selector cannot be found.
    // This is the place where we have to create our own dud NSMethodSignature. This is necessary because if this method
    // returns nil, a selector not found exception is raised. The string argument to -signatureWithObjCTypes: outlines
    // the return type and arguments to the message. To return a dud NSMethodSignature, pretty much any signature will
    // suffice. Since the -forwardInvocation call will do nothing if the delegate does not respond to the selector,
    // the dud NSMethodSignature simply gets us around the exception.
    return [NSMethodSignature signatureWithObjCTypes:"@^v^c"];
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
        if ([delegate respondsToSelector:aSelector]) {
            return YES;
        }
    }
    return NO;
}

- (NSString *)description {
    return [NSString stringWithFormat:@"%@%@", [super description], self.delegates];
}

@end
