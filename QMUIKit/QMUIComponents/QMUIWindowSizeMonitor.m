/**
 * Tencent is pleased to support the open source community by making QMUI_iOS available.
 * Copyright (C) 2016-2021 THL A29 Limited, a Tencent company. All rights reserved.
 * Licensed under the MIT License (the "License"); you may not use this file except in compliance with the License. You may obtain a copy of the License at
 * http://opensource.org/licenses/MIT
 * Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.
 */
//
//  QMUIWindowSizeMonitor.m
//  qmuidemo
//
//  Created by ziezheng on 2019/5/27.
//

#import "QMUIWindowSizeMonitor.h"
#import "QMUICore.h"
#import "NSPointerArray+QMUI.h"

@interface NSObject (QMUIWindowSizeMonitor_Private)

@property(nonatomic, readonly) NSMutableArray <QMUIWindowSizeObserverHandler> *qwsm_windowSizeChangeHandlers;

@end

@interface UIResponder (QMUIWindowSizeMonitor_Private)

@property(nonatomic, weak) UIWindow *qwsm_previousWindow;

@end


@interface UIWindow (QMUIWindowSizeMonitor_Private)

@property(nonatomic, assign) CGSize qwsm_previousSize;
@property(nonatomic, readonly) NSPointerArray *qwsm_sizeObservers;
@property(nonatomic, readonly) NSPointerArray *qwsm_canReceiveWindowDidTransitionToSizeResponders;

- (void)qwsm_addSizeObserver:(NSObject *)observer;

@end



@implementation NSObject (QMUIWindowSizeMonitor)

- (void)qmui_addSizeObserverForMainWindow:(QMUIWindowSizeObserverHandler)handler {
    [self qmui_addSizeObserverForWindow:UIApplication.sharedApplication.delegate.window handler:handler];
}

- (void)qmui_addSizeObserverForWindow:(UIWindow *)window handler:(QMUIWindowSizeObserverHandler)handler {
    NSAssert(window != nil, @"window is nil!");
    
    struct Block_literal {
        void *isa;
        int flags;
        int reserved;
        void (*__FuncPtr)(void *, ...);
    };
    
    void * blockFuncPtr = ((__bridge struct Block_literal *)handler)->__FuncPtr;
    for (QMUIWindowSizeObserverHandler handler in self.qwsm_windowSizeChangeHandlers) {
        // 由于利用 block 的 __FuncPtr 指针来判断同一个实现的 block 过滤掉，防止重复添加监听
        if (((__bridge struct Block_literal *)handler)->__FuncPtr == blockFuncPtr) {
            return;
        }
    }
    
    [self.qwsm_windowSizeChangeHandlers addObject:handler];
    [window qwsm_addSizeObserver:self];
}

- (NSMutableArray<QMUIWindowSizeObserverHandler> *)qwsm_windowSizeChangeHandlers {
    NSMutableArray *_handlers = objc_getAssociatedObject(self, _cmd);
    if (!_handlers) {
        _handlers = [NSMutableArray array];
        objc_setAssociatedObject(self, _cmd, _handlers, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    return _handlers;
}

@end

@implementation UIWindow (QMUIWindowSizeMonitor)

QMUISynthesizeCGSizeProperty(qwsm_previousSize, setQwsm_previousSize)

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        void (^notifyNewSizeBlock)(UIWindow *, CGRect) = ^(UIWindow *selfObject, CGRect firstArgv) {
            CGSize newSize = selfObject.bounds.size;
            if (!CGSizeEqualToSize(newSize, selfObject.qwsm_previousSize)) {
                if (!CGSizeEqualToSize(selfObject.qwsm_previousSize, CGSizeZero)) {
                    [selfObject qwsm_notifyWithNewSize:newSize];
                }
                selfObject.qwsm_previousSize = selfObject.bounds.size;
            }
        };
        
        ExtendImplementationOfVoidMethodWithSingleArgument([UIWindow class], @selector(setFrame:), CGRect, notifyNewSizeBlock);
        
        ExtendImplementationOfVoidMethodWithSingleArgument([UIWindow class], @selector(setBounds:), CGRect, notifyNewSizeBlock);
        
        OverrideImplementation([UIView class], @selector(willMoveToWindow:), ^id(__unsafe_unretained Class originClass, SEL originCMD, IMP (^originalIMPProvider)(void)) {
            return ^void(UIView *selfObject, UIWindow *newWindow) {
                
                void (*originSelectorIMP)(id, SEL, UIWindow *);
                originSelectorIMP = (void (*)(id, SEL, UIWindow *))originalIMPProvider();
                originSelectorIMP(selfObject, originCMD, newWindow);
                
                if (newWindow) {
                    if ([selfObject respondsToSelector:@selector(windowDidTransitionToSize:)]) {
                        [newWindow qwsm_addDidTransitionToSizeMethodReceiver:selfObject];
                    }
                    UIResponder *nextResponder = [selfObject nextResponder];
                    if ([nextResponder isKindOfClass:[UIViewController class]] && [nextResponder respondsToSelector:@selector(windowDidTransitionToSize:)]) {
                        [newWindow qwsm_addDidTransitionToSizeMethodReceiver:nextResponder];
                    }
                }
                
            };
        });
    });
}


- (void)qwsm_addSizeObserver:(NSObject *)observer {
    if ([self.qwsm_sizeObservers qmui_containsPointer:(__bridge void *)(observer)]) return;
    [self.qwsm_sizeObservers addPointer:(__bridge void *)(observer)];
}

- (void)qwsm_removeSizeObserver:(NSObject *)observer {
    NSUInteger index = [self.qwsm_sizeObservers qmui_indexOfPointer:(__bridge void *)observer];
    if (index != NSNotFound) {
        [self.qwsm_sizeObservers removePointerAtIndex:index];
    }
}

- (void)qwsm_addDidTransitionToSizeMethodReceiver:(UIResponder *)receiver {
    if ([self.qwsm_canReceiveWindowDidTransitionToSizeResponders qmui_containsPointer:(__bridge void *)(receiver)]) return;
    if (receiver.qwsm_previousWindow && receiver.qwsm_previousWindow != self) {
        [receiver.qwsm_previousWindow qwsm_removeDidTransitionToSizeMethodReceiver:receiver];
    }
    receiver.qwsm_previousWindow = self;
    [self.qwsm_canReceiveWindowDidTransitionToSizeResponders addPointer:(__bridge void *)(receiver)];
}

- (void)qwsm_removeDidTransitionToSizeMethodReceiver:(UIResponder *)receiver {
    NSUInteger index = [self.qwsm_canReceiveWindowDidTransitionToSizeResponders qmui_indexOfPointer:(__bridge void *)(receiver)];
    if (index != NSNotFound) {
        [self.qwsm_canReceiveWindowDidTransitionToSizeResponders removePointerAtIndex:index];
    }
}


- (void)qwsm_notifyWithNewSize:(CGSize)newSize {
    // notify sizeObservers
    for (NSUInteger i = 0, count = self.qwsm_sizeObservers.count; i < count; i++) {
        NSObject *object = [self.qwsm_sizeObservers pointerAtIndex:i];
        for (NSUInteger i = 0, count = object.qwsm_windowSizeChangeHandlers.count; i < count; i++) {
            QMUIWindowSizeObserverHandler handler = object.qwsm_windowSizeChangeHandlers[i];
            handler(newSize);
        }
    }
    // send ‘windowDidTransitionToSize:’ to responders
    for (NSUInteger i = 0, count = self.qwsm_canReceiveWindowDidTransitionToSizeResponders.count; i < count; i++) {
        UIResponder <QMUIWindowSizeMonitorProtocol>*responder = [self.qwsm_canReceiveWindowDidTransitionToSizeResponders pointerAtIndex:i];
        // call superclass automatically
        Method lastMethod = NULL;
        NSMutableArray <NSValue *>*selectorIMPArray = [NSMutableArray array];
        for (Class responderClass = object_getClass(responder); responderClass != [UIResponder class]; responderClass = class_getSuperclass(responderClass)) {
            Method methodOfClass = class_getInstanceMethod(responderClass, @selector(windowDidTransitionToSize:));
            if (methodOfClass == NULL) break;
            if (methodOfClass == lastMethod) continue;
            void (*selectorIMP)(id, SEL, CGSize) = (void (*)(id, SEL, CGSize))method_getImplementation(methodOfClass);
            [selectorIMPArray addObject:[NSValue valueWithPointer:selectorIMP]];
            lastMethod = methodOfClass;
        }
        // call the superclass before calling the subclass
        for (NSInteger i = selectorIMPArray.count - 1; i >= 0; i--) {
            void (*selectorIMP)(id, SEL, CGSize) = selectorIMPArray[i].pointerValue;
            selectorIMP(responder, @selector(windowDidTransitionToSize:), newSize);
        }
    }
}

- (NSPointerArray *)qwsm_sizeObservers {
    NSPointerArray *qwsm_sizeObservers = objc_getAssociatedObject(self, _cmd);
    if (!qwsm_sizeObservers) {
        qwsm_sizeObservers = [NSPointerArray weakObjectsPointerArray];
        objc_setAssociatedObject(self, _cmd, qwsm_sizeObservers, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    return qwsm_sizeObservers;
}

- (NSPointerArray *)qwsm_canReceiveWindowDidTransitionToSizeResponders {
    NSPointerArray *qwsm_responders = objc_getAssociatedObject(self, _cmd);
    if (!qwsm_responders) {
        qwsm_responders = [NSPointerArray weakObjectsPointerArray];
        objc_setAssociatedObject(self, _cmd, qwsm_responders, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    return qwsm_responders;
}

@end

@implementation UIResponder (QMUIWindowSizeMonitor)

QMUISynthesizeIdWeakProperty(qwsm_previousWindow, setQwsm_previousWindow)

@end
