/**
 * Tencent is pleased to support the open source community by making QMUI_iOS available.
 * Copyright (C) 2016-2021 THL A29 Limited, a Tencent company. All rights reserved.
 * Licensed under the MIT License (the "License"); you may not use this file except in compliance with the License. You may obtain a copy of the License at
 * http://opensource.org/licenses/MIT
 * Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.
 */

//
//  UIControl+QMUI.m
//  qmui
//
//  Created by QMUI Team on 15/7/20.
//

#import "UIControl+QMUI.h"
#import "QMUICore.h"

@interface UIControl ()

@property(nonatomic,assign) BOOL qmuictl_canSetHighlighted;
@property(nonatomic,assign) NSInteger qmuictl_touchEndCount;
@end

@implementation UIControl (QMUI)

QMUISynthesizeBOOLProperty(qmuictl_canSetHighlighted, setQmuictl_canSetHighlighted)
QMUISynthesizeNSIntegerProperty(qmuictl_touchEndCount, setQmuictl_touchEndCount)

#pragma mark - Automatically Adjust Touch Highlighted In ScrollView

static char kAssociatedObjectKey_automaticallyAdjustTouchHighlightedInScrollView;
- (void)setQmui_automaticallyAdjustTouchHighlightedInScrollView:(BOOL)qmui_automaticallyAdjustTouchHighlightedInScrollView {
    objc_setAssociatedObject(self, &kAssociatedObjectKey_automaticallyAdjustTouchHighlightedInScrollView, @(qmui_automaticallyAdjustTouchHighlightedInScrollView), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    if (qmui_automaticallyAdjustTouchHighlightedInScrollView) {
        [QMUIHelper executeBlock:^{
            OverrideImplementation([UIControl class], @selector(touchesBegan:withEvent:), ^id(__unsafe_unretained Class originClass, SEL originCMD, IMP (^originalIMPProvider)(void)) {
                return ^(UIControl *selfObject, NSSet *touches, UIEvent *event) {
                    
                    // call super
                    void (^callSuperBlock)(void) = ^{
                        void (*originSelectorIMP)(id, SEL, NSSet *, UIEvent *);
                        originSelectorIMP = (void (*)(id, SEL, NSSet *, UIEvent *))originalIMPProvider();
                        originSelectorIMP(selfObject, originCMD, touches, event);
                    };
                    
                    selfObject.qmuictl_touchEndCount = 0;
                    if (selfObject.qmui_automaticallyAdjustTouchHighlightedInScrollView) {
                        selfObject.qmuictl_canSetHighlighted = YES;
                        callSuperBlock();
                        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                            if (selfObject.qmuictl_canSetHighlighted) {
                                [selfObject setHighlighted:YES];
                            }
                        });
                    } else {
                        callSuperBlock();
                    }
                };
            });
            
            OverrideImplementation([UIControl class], @selector(touchesMoved:withEvent:), ^id(__unsafe_unretained Class originClass, SEL originCMD, IMP (^originalIMPProvider)(void)) {
                return ^(UIControl *selfObject, NSSet *touches, UIEvent *event) {
                    
                    if (selfObject.qmui_automaticallyAdjustTouchHighlightedInScrollView) {
                        selfObject.qmuictl_canSetHighlighted = NO;
                    }
                    
                    // call super
                    void (*originSelectorIMP)(id, SEL, NSSet *, UIEvent *);
                    originSelectorIMP = (void (*)(id, SEL, NSSet *, UIEvent *))originalIMPProvider();
                    originSelectorIMP(selfObject, originCMD, touches, event);
                };
            });
            
            OverrideImplementation([UIControl class], @selector(touchesEnded:withEvent:), ^id(__unsafe_unretained Class originClass, SEL originCMD, IMP (^originalIMPProvider)(void)) {
                return ^(UIControl *selfObject, NSSet *touches, UIEvent *event) {
                    
                    if (selfObject.qmui_automaticallyAdjustTouchHighlightedInScrollView) {
                        selfObject.qmuictl_canSetHighlighted = NO;
                        if (selfObject.touchInside) {
                            [selfObject setHighlighted:YES];
                            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.02 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                                // 如果延迟时间太长，会导致快速点击两次，事件会触发两次
                                // 对于 3D Touch 的机器，如果点击按钮的时候在按钮上停留事件稍微长一点点，那么 touchesEnded 会被调用两次
                                // 把 super touchEnded 放到延迟里调用会导致长按无法触发点击，先这么改，再想想怎么办。// [selfObject qmui_touchesEnded:touches withEvent:event];
                                [selfObject sendActionsForAllTouchEventsIfCan];
                                if (selfObject.highlighted) {
                                    [selfObject setHighlighted:NO];
                                }
                            });
                        } else {
                            [selfObject setHighlighted:NO];
                        }
                        return;
                    }
                    
                    // call super
                    void (*originSelectorIMP)(id, SEL, NSSet *, UIEvent *);
                    originSelectorIMP = (void (*)(id, SEL, NSSet *, UIEvent *))originalIMPProvider();
                    originSelectorIMP(selfObject, originCMD, touches, event);
                };
            });
            
            OverrideImplementation([UIControl class], @selector(touchesCancelled:withEvent:), ^id(__unsafe_unretained Class originClass, SEL originCMD, IMP (^originalIMPProvider)(void)) {
                return ^(UIControl *selfObject, NSSet *touches, UIEvent *event) {
                    
                    // call super
                    void (^callSuperBlock)(void) = ^{
                        void (*originSelectorIMP)(id, SEL, NSSet *, UIEvent *);
                        originSelectorIMP = (void (*)(id, SEL, NSSet *, UIEvent *))originalIMPProvider();
                        originSelectorIMP(selfObject, originCMD, touches, event);
                    };
                    
                    if (selfObject.qmui_automaticallyAdjustTouchHighlightedInScrollView) {
                        selfObject.qmuictl_canSetHighlighted = NO;
                        callSuperBlock();
                        if (selfObject.highlighted) {
                            [selfObject setHighlighted:NO];
                        }
                        return;
                    }
                    callSuperBlock();
                };
            });
        } oncePerIdentifier:@"UIControl automaticallyAdjustTouchHighlightedInScrollView"];
    }
}

- (BOOL)qmui_automaticallyAdjustTouchHighlightedInScrollView {
    return [((NSNumber *)objc_getAssociatedObject(self, &kAssociatedObjectKey_automaticallyAdjustTouchHighlightedInScrollView)) boolValue];
}

// 这段代码需要以一个独立的方法存在，因为一旦有坑，外面可以直接通过runtime调用这个方法
// 但，不要开放到.h文件里，理论上外面不应该用到它
- (void)sendActionsForAllTouchEventsIfCan {
    self.qmuictl_touchEndCount += 1;
    if (self.qmuictl_touchEndCount == 1) {
        [self sendActionsForControlEvents:UIControlEventAllTouchEvents];
    }
}

#pragma mark - Prevents Repeated TouchUpInside Event

static char kAssociatedObjectKey_preventsRepeatedTouchUpInsideEvent;
- (void)setQmui_preventsRepeatedTouchUpInsideEvent:(BOOL)qmui_preventsRepeatedTouchUpInsideEvent {
    objc_setAssociatedObject(self, &kAssociatedObjectKey_preventsRepeatedTouchUpInsideEvent, @(qmui_preventsRepeatedTouchUpInsideEvent), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    if (qmui_preventsRepeatedTouchUpInsideEvent) {
        [QMUIHelper executeBlock:^{
            
            OverrideImplementation([UIControl class], @selector(sendAction:to:forEvent:), ^id(__unsafe_unretained Class originClass, SEL originCMD, IMP (^originalIMPProvider)(void)) {
                return ^(UIControl *selfObject, SEL action, id target, UIEvent *event) {
                    
                    if (selfObject.qmui_preventsRepeatedTouchUpInsideEvent) {
                        NSArray<NSString *> *actions = [selfObject actionsForTarget:target forControlEvent:UIControlEventTouchUpInside];
                        if (!actions) {
                            // iOS 10 UIBarButtonItem 里的 UINavigationButton 点击事件用的是 UIControlEventPrimaryActionTriggered
                            actions = [selfObject actionsForTarget:target forControlEvent:UIControlEventPrimaryActionTriggered];
                        }
                        if ([actions containsObject:NSStringFromSelector(action)]) {
                            UITouch *touch = event.allTouches.anyObject;
                            if (touch.tapCount > 1) {
                                return;
                            }
                        }
                    }
                    
                    // call super
                    void (*originSelectorIMP)(id, SEL, SEL, id, UIEvent *);
                    originSelectorIMP = (void (*)(id, SEL, SEL, id, UIEvent *))originalIMPProvider();
                    originSelectorIMP(selfObject, originCMD, action, target, event);
                };
            });
        } oncePerIdentifier:@"UIControl preventsRepeatedTouchUpInsideEvent"];
    }
}

- (BOOL)qmui_preventsRepeatedTouchUpInsideEvent {
    return [((NSNumber *)objc_getAssociatedObject(self, &kAssociatedObjectKey_preventsRepeatedTouchUpInsideEvent)) boolValue];
}

#pragma mark - Highlighted Block

static char kAssociatedObjectKey_setHighlightedBlock;
- (void)setQmui_setHighlightedBlock:(void (^)(BOOL))qmui_setHighlightedBlock {
    objc_setAssociatedObject(self, &kAssociatedObjectKey_setHighlightedBlock, qmui_setHighlightedBlock, OBJC_ASSOCIATION_COPY_NONATOMIC);
    if (qmui_setHighlightedBlock) {
        [QMUIHelper executeBlock:^{
            OverrideImplementation([UIControl class], @selector(setHighlighted:), ^id(__unsafe_unretained Class originClass, SEL originCMD, IMP (^originalIMPProvider)(void)) {
                return ^(UIControl *selfObject, BOOL highlighted) {
                    
                    // call super
                    void (*originSelectorIMP)(id, SEL, BOOL);
                    originSelectorIMP = (void (*)(id, SEL, BOOL))originalIMPProvider();
                    originSelectorIMP(selfObject, originCMD, highlighted);
                    
                    if (selfObject.qmui_setHighlightedBlock) {
                        selfObject.qmui_setHighlightedBlock(highlighted);
                    }
                };
            });
        } oncePerIdentifier:@"UIControl setHighlighted:"];
    }
}

- (void (^)(BOOL))qmui_setHighlightedBlock {
    return (void (^)(BOOL))objc_getAssociatedObject(self, &kAssociatedObjectKey_setHighlightedBlock);
}

#pragma mark - Selected Block

static char kAssociatedObjectKey_setSelectedBlock;
- (void)setQmui_setSelectedBlock:(void (^)(BOOL))qmui_setSelectedBlock {
    objc_setAssociatedObject(self, &kAssociatedObjectKey_setSelectedBlock, qmui_setSelectedBlock, OBJC_ASSOCIATION_COPY_NONATOMIC);
    if (qmui_setSelectedBlock) {
        [QMUIHelper executeBlock:^{
            OverrideImplementation([UIControl class], @selector(setSelected:), ^id(__unsafe_unretained Class originClass, SEL originCMD, IMP (^originalIMPProvider)(void)) {
                return ^(UIControl *selfObject, BOOL selected) {
                    
                    // call super
                    void (*originSelectorIMP)(id, SEL, BOOL);
                    originSelectorIMP = (void (*)(id, SEL, BOOL))originalIMPProvider();
                    originSelectorIMP(selfObject, originCMD, selected);
                    
                    if (selfObject.qmui_setSelectedBlock) {
                        selfObject.qmui_setSelectedBlock(selected);
                    }
                };
            });
        } oncePerIdentifier:@"UIControl setSelected:"];
    }
}

- (void (^)(BOOL))qmui_setSelectedBlock {
    return (void (^)(BOOL))objc_getAssociatedObject(self, &kAssociatedObjectKey_setSelectedBlock);
}

#pragma mark - Enabled Block

static char kAssociatedObjectKey_setEnabledBlock;
- (void)setQmui_setEnabledBlock:(void (^)(BOOL))qmui_setEnabledBlock {
    objc_setAssociatedObject(self, &kAssociatedObjectKey_setEnabledBlock, qmui_setEnabledBlock, OBJC_ASSOCIATION_COPY_NONATOMIC);
    if (qmui_setEnabledBlock) {
        [QMUIHelper executeBlock:^{
            OverrideImplementation([UIControl class], @selector(setEnabled:), ^id(__unsafe_unretained Class originClass, SEL originCMD, IMP (^originalIMPProvider)(void)) {
                return ^(UIControl *selfObject, BOOL enabled) {
                    
                    // call super
                    void (*originSelectorIMP)(id, SEL, BOOL);
                    originSelectorIMP = (void (*)(id, SEL, BOOL))originalIMPProvider();
                    originSelectorIMP(selfObject, originCMD, enabled);
                    
                    if (selfObject.qmui_setEnabledBlock) {
                        selfObject.qmui_setEnabledBlock(enabled);
                    }
                };
            });
        } oncePerIdentifier:@"UIControl setEnabled:"];
    }
}

- (void (^)(BOOL))qmui_setEnabledBlock {
    return (void (^)(BOOL))objc_getAssociatedObject(self, &kAssociatedObjectKey_setEnabledBlock);
}

#pragma mark - Tap Block

static char kAssociatedObjectKey_tapBlock;
- (void)setQmui_tapBlock:(void (^)(__kindof UIControl *))qmui_tapBlock {
    if (qmui_tapBlock) {
        [QMUIHelper executeBlock:^{
            OverrideImplementation([UIControl class], @selector(removeTarget:action:forControlEvents:), ^id(__unsafe_unretained Class originClass, SEL originCMD, IMP (^originalIMPProvider)(void)) {
                return ^(UIControl *selfObject, id target, SEL action, UIControlEvents controlEvents) {
                    
                    // call super
                    void (*originSelectorIMP)(id, SEL, id, SEL, UIControlEvents);
                    originSelectorIMP = (void (*)(id, SEL, id, SEL, UIControlEvents))originalIMPProvider();
                    originSelectorIMP(selfObject, originCMD, target, action, controlEvents);
                    
                    BOOL isTouchUpInsideEvent = controlEvents & UIControlEventTouchUpInside;
                    BOOL shouldRemoveTouchUpInsideSelector = (action == @selector(qmui_handleTouchUpInside:)) || (target == selfObject && !action) || (!target && !action);
                    if (isTouchUpInsideEvent && shouldRemoveTouchUpInsideSelector) {
                        // 避免触发 setter 又反过来 removeTarget，然后就死循环了
                        objc_setAssociatedObject(selfObject, &kAssociatedObjectKey_tapBlock, nil, OBJC_ASSOCIATION_COPY_NONATOMIC);
                    }
                };
            });
        } oncePerIdentifier:@"UIControl tapBlock"];
    }
    
    SEL action = @selector(qmui_handleTouchUpInside:);
    if (!qmui_tapBlock) {
        [self removeTarget:self action:action forControlEvents:UIControlEventTouchUpInside];
    } else {
        [self addTarget:self action:action forControlEvents:UIControlEventTouchUpInside];
    }
    objc_setAssociatedObject(self, &kAssociatedObjectKey_tapBlock, qmui_tapBlock, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (void (^)(__kindof UIControl *))qmui_tapBlock {
    return (void (^)(__kindof UIControl *))objc_getAssociatedObject(self, &kAssociatedObjectKey_tapBlock);
}

- (void)qmui_handleTouchUpInside:(__kindof UIControl *)sender {
    if (self.qmui_tapBlock) {
        self.qmui_tapBlock(self);
    }
}

@end
