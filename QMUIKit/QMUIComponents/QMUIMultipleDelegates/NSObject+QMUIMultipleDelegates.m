//
//  NSObject+MultipleDelegates.m
//  QMUIKit
//
//  Created by MoLice on 2018/3/27.
//  Copyright © 2018年 QMUI Team. All rights reserved.
//

#import "NSObject+QMUIMultipleDelegates.h"
#import "QMUIMultipleDelegates.h"
#import "QMUICore.h"
#import <objc/runtime.h>

@interface NSObject ()

@property(nonatomic, strong) NSMutableDictionary<NSString *, QMUIMultipleDelegates *> *qmuimd_delegates;
@end

@implementation NSObject (QMUIMultipleDelegates)

static NSMutableSet<NSString *> *qmui_methodsReplacedClasses;

static char kAssociatedObjectKey_qmuiMultipleDelegatesEnabled;
- (void)setQmui_multipleDelegatesEnabled:(BOOL)qmui_multipleDelegatesEnabled {
    objc_setAssociatedObject(self, &kAssociatedObjectKey_qmuiMultipleDelegatesEnabled, @(qmui_multipleDelegatesEnabled), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    if (qmui_multipleDelegatesEnabled) {
        if (!self.qmuimd_delegates) {
            self.qmuimd_delegates = [NSMutableDictionary dictionary];
        }
        [self qmui_registerDelegateSelector:@selector(delegate)];
        if ([self isKindOfClass:[UITableView class]] || [self isKindOfClass:[UICollectionView class]]) {
            [self qmui_registerDelegateSelector:@selector(dataSource)];
        }
    }
}

- (BOOL)qmui_multipleDelegatesEnabled {
    return [((NSNumber *)objc_getAssociatedObject(self, &kAssociatedObjectKey_qmuiMultipleDelegatesEnabled)) boolValue];
}

static char kAssociatedObjectKey_qmuiDelegates;
- (void)setQmuimd_delegates:(NSMutableDictionary<NSString *,QMUIMultipleDelegates *> *)qmuimd_delegates {
    objc_setAssociatedObject(self, &kAssociatedObjectKey_qmuiDelegates, qmuimd_delegates, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSMutableDictionary<NSString *,QMUIMultipleDelegates *> *)qmuimd_delegates {
    return (NSMutableDictionary<NSString *,QMUIMultipleDelegates *> *)objc_getAssociatedObject(self, &kAssociatedObjectKey_qmuiDelegates);
}

- (NSDictionary<NSString *,QMUIMultipleDelegates *> *)qmui_delegates {
    return [self.qmuimd_delegates copy];
}

- (void)qmui_registerDelegateSelector:(SEL)getter {
    if (!self.qmui_multipleDelegatesEnabled) {
        return;
    }
    
    Class class = [self class];
    SEL originDelegateSetter = [QMUIHelper setterFromGetter:getter];
    SEL newDelegateSetter = NSSelectorFromString([NSString stringWithFormat:@"qmuimd_%@", NSStringFromSelector(originDelegateSetter)]);
    Method originMethod = class_getInstanceMethod(class, originDelegateSetter);
    if (!originMethod) {
        return;
    }
    
    // 为这个 selector 创建一个 QMUIMultipleDelegates 容器
    NSString *delegateGetterKey = NSStringFromSelector(getter);
    if (!self.qmuimd_delegates[delegateGetterKey]) {
        self.qmuimd_delegates[delegateGetterKey] = [[QMUIMultipleDelegates alloc] init];
    }
    
    // 避免为某个 class 重复替换同一个方法的实现
    if (!qmui_methodsReplacedClasses) {
        qmui_methodsReplacedClasses = [NSMutableSet set];
    }
    NSString *classAndMethodIdentifier = [NSString stringWithFormat:@"%@-%@", NSStringFromClass(class), delegateGetterKey];
    if ([qmui_methodsReplacedClasses containsObject:classAndMethodIdentifier]) {
        return;
    }
    [qmui_methodsReplacedClasses addObject:classAndMethodIdentifier];
    
    void (*originSelectorIMP)(id, SEL, id);
    originSelectorIMP = (void (*)(id, SEL, id))method_getImplementation(originMethod);
    
    BOOL isAddedMethod = class_addMethod(class, newDelegateSetter, imp_implementationWithBlock(^(NSObject *selfObject, id aDelegate){
        
        // 这一段保护的原因请查看 https://github.com/QMUI/QMUI_iOS/issues/292
        if (!selfObject.qmui_multipleDelegatesEnabled || ![selfObject isKindOfClass:class]) {
            originSelectorIMP(selfObject, originDelegateSetter, aDelegate);
            return;
        }
        
        if (!aDelegate) {
            // 对应 setDelegate:nil，表示清理所有的 delegate
            [selfObject.qmuimd_delegates removeObjectForKey:delegateGetterKey];
            originSelectorIMP(selfObject, originDelegateSetter, nil);
            return;
        }
        
        QMUIMultipleDelegates *delegates = selfObject.qmuimd_delegates[delegateGetterKey];
        if (aDelegate != delegates) {// 过滤掉容器自身
            [delegates addDelegate:aDelegate];
        }
        originSelectorIMP(selfObject, originDelegateSetter, delegates);// 不管外面将什么 object 传给 setDelegate:，最终实际上传进去的都是 QMUIMultipleDelegates 容器
    }), method_getTypeEncoding(originMethod));
    if (isAddedMethod) {
        Method newMethod = class_getInstanceMethod(class, newDelegateSetter);
        method_exchangeImplementations(originMethod, newMethod);
    }
}

@end
