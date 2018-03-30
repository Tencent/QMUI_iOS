//
//  QMUIMultipleDelegates.m
//  QMUIKit
//
//  Created by MoLice on 2018/3/27.
//  Copyright © 2018年 QMUI Team. All rights reserved.
//

#import "QMUIMultipleDelegates.h"

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
    [self.delegates addPointer:(__bridge void *)delegate];
}

- (void)removeDelegate:(id)delegate {
    NSUInteger index = [self indexOfDelegate:delegate];
    if (index != NSNotFound) {
        [self.delegates removePointerAtIndex:index];
    }
}

- (NSUInteger)indexOfDelegate:(id)delegate {
    if (!delegate) {
        return NSNotFound;
    }
    
    for (NSUInteger i = 0; i < self.delegates.count; i++) {
        if ([self.delegates pointerAtIndex:i] == ((__bridge void *)delegate)) {
            return i;
        }
    }
    return NSNotFound;
}

- (NSMethodSignature *)methodSignatureForSelector:(SEL)aSelector {
    NSMethodSignature *result = [super methodSignatureForSelector:aSelector];
    if (result) {
        return result;
    }
    for (id delegate in self.delegates) {
        result = [delegate methodSignatureForSelector:aSelector];
        if (result) {
            return result;
        }
    }
    return nil;
}

- (void)forwardInvocation:(NSInvocation *)anInvocation {
    for (id delegate in self.delegates) {
        if ([delegate respondsToSelector:anInvocation.selector]) {
            [anInvocation invokeWithTarget:delegate];
        }
    }
}

- (BOOL)respondsToSelector:(SEL)aSelector {
    if ([super respondsToSelector:aSelector])
        return YES;
    for (id delegate in self.delegates) {
        if ([delegate respondsToSelector:aSelector]) {
            return YES;
        }
    }
    return NO;
}

- (NSString *)description {
    NSMutableString *delegatesString = [[NSMutableString alloc] init];
    for (id delegate in self.delegates) {
        [delegatesString appendFormat:@", %@", delegate];
    }
    return [NSString stringWithFormat:@"%@%@", [super description], delegatesString.copy];
}

@end

// UIScrollViewDelegate 这两个方法比较特殊，当被调用时，不会经过 forwardInvocation:，所以用 QMUIMultipleDelegates 的实现方式无法对它们进行转发，原因暂时不明，因此以下是临时的解决方法。其他 delegate 是否存在类似这样的方法也未知。
@interface QMUIMultipleDelegates (UIScrollViewDelegate)

@end

@implementation QMUIMultipleDelegates (UIScrollViewDelegate)

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    for (id delegate in self.delegates) {
        if ([delegate respondsToSelector:_cmd]) {
            [delegate scrollViewDidScroll:scrollView];
        }
    }
}

- (void)scrollViewDidZoom:(UIScrollView *)scrollView {
    for (id delegate in self.delegates) {
        if ([delegate respondsToSelector:_cmd]) {
            [delegate scrollViewDidZoom:scrollView];
        }
    }
}

@end
