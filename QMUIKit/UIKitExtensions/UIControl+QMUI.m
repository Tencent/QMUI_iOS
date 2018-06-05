//
//  UIControl+QMUI.m
//  qmui
//
//  Created by ZhoonChen on 15/7/20.
//  Copyright (c) 2015年 QMUI Team. All rights reserved.
//

#import "UIControl+QMUI.h"
#import <objc/runtime.h>
#import "QMUICore.h"

static char kAssociatedObjectKey_automaticallyAdjustTouchHighlightedInScrollView;
static char kAssociatedObjectKey_canSetHighlighted;
static char kAssociatedObjectKey_touchEndCount;
static char kAssociatedObjectKey_outsideEdge;

@interface UIControl ()

@property(nonatomic,assign) BOOL canSetHighlighted;
@property(nonatomic,assign) NSInteger touchEndCount;

@end

@implementation UIControl (QMUI)

- (void)setQmui_automaticallyAdjustTouchHighlightedInScrollView:(BOOL)qmui_automaticallyAdjustTouchHighlightedInScrollView {
    objc_setAssociatedObject(self, &kAssociatedObjectKey_automaticallyAdjustTouchHighlightedInScrollView, [NSNumber numberWithBool:qmui_automaticallyAdjustTouchHighlightedInScrollView], OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (BOOL)qmui_automaticallyAdjustTouchHighlightedInScrollView {
    return (BOOL)[objc_getAssociatedObject(self, &kAssociatedObjectKey_automaticallyAdjustTouchHighlightedInScrollView) boolValue];
}

- (void)setCanSetHighlighted:(BOOL)canSetHighlighted {
    objc_setAssociatedObject(self, &kAssociatedObjectKey_canSetHighlighted, [NSNumber numberWithBool:canSetHighlighted], OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (BOOL)canSetHighlighted {
    return (BOOL)[objc_getAssociatedObject(self, &kAssociatedObjectKey_canSetHighlighted) boolValue];
}

- (void)setTouchEndCount:(NSInteger)touchEndCount {
    objc_setAssociatedObject(self, &kAssociatedObjectKey_touchEndCount, @(touchEndCount), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSInteger)touchEndCount {
    return [objc_getAssociatedObject(self, &kAssociatedObjectKey_touchEndCount) integerValue];
}

- (void)setQmui_outsideEdge:(UIEdgeInsets)qmui_outsideEdge {
    objc_setAssociatedObject(self, &kAssociatedObjectKey_outsideEdge, [NSValue valueWithUIEdgeInsets:qmui_outsideEdge], OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (UIEdgeInsets)qmui_outsideEdge {
    return [objc_getAssociatedObject(self, &kAssociatedObjectKey_outsideEdge) UIEdgeInsetsValue];
}

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        SEL selectors[] = {
            @selector(touchesBegan:withEvent:),
            @selector(touchesMoved:withEvent:),
            @selector(touchesEnded:withEvent:),
            @selector(touchesCancelled:withEvent:),
            @selector(pointInside:withEvent:),
            @selector(setHighlighted:),
            @selector(removeTarget:action:forControlEvents:)
        };
        for (NSUInteger index = 0; index < sizeof(selectors) / sizeof(SEL); index++) {
            SEL originalSelector = selectors[index];
            SEL swizzledSelector = NSSelectorFromString([@"qmui_" stringByAppendingString:NSStringFromSelector(originalSelector)]);
            ExchangeImplementations([self class], originalSelector, swizzledSelector);
        }
    });
}

- (void)qmui_setHighlighted:(BOOL)highlighted {
    [self qmui_setHighlighted:highlighted];
    if (self.qmui_setHighlightedBlock) {
        self.qmui_setHighlightedBlock(highlighted);
    }
}

BeginIgnoreDeprecatedWarning
- (void)qmui_touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    self.touchEndCount = 0;
    if (self.qmui_automaticallyAdjustTouchHighlightedInScrollView) {
        self.canSetHighlighted = YES;
        [self qmui_touchesBegan:touches withEvent:event];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            if (self.canSetHighlighted) {
                [self setHighlighted:YES];
            }
        });
    } else {
        [self qmui_touchesBegan:touches withEvent:event];
    }
}

- (void)qmui_touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    if (self.qmui_automaticallyAdjustTouchHighlightedInScrollView) {
        self.canSetHighlighted = NO;
        [self qmui_touchesMoved:touches withEvent:event];
    } else {
        [self qmui_touchesMoved:touches withEvent:event];
    }
}

- (void)qmui_touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    if (self.qmui_automaticallyAdjustTouchHighlightedInScrollView) {
        self.canSetHighlighted = NO;
        if (self.touchInside) {
            [self setHighlighted:YES];
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.02 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                // 如果延迟时间太长，会导致快速点击两次，事件会触发两次
                // 对于 3D Touch 的机器，如果点击按钮的时候在按钮上停留事件稍微长一点点，那么 touchesEnded 会被调用两次
                // 把 super touchEnded 放到延迟里调用会导致长按无法触发点击，先这么改，再想想怎么办。// [self qmui_touchesEnded:touches withEvent:event];
                [self sendActionsForAllTouchEventsIfCan];
                if (self.highlighted) {
                    [self setHighlighted:NO];
                }
            });
        } else {
            [self setHighlighted:NO];
        }
    } else {
        [self qmui_touchesEnded:touches withEvent:event];
    }
}

- (void)qmui_touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
    if (self.qmui_automaticallyAdjustTouchHighlightedInScrollView) {
        self.canSetHighlighted = NO;
        [self qmui_touchesCancelled:touches withEvent:event];
        if (self.highlighted) {
            [self setHighlighted:NO];
        }
    } else {
        [self qmui_touchesCancelled:touches withEvent:event];
    }
}
EndIgnoreDeprecatedWarning

- (BOOL)qmui_pointInside:(CGPoint)point withEvent:(UIEvent *)event {
    if (([event type] != UIEventTypeTouches)) {
        return [self qmui_pointInside:point withEvent:event];
    }
    UIEdgeInsets qmui_outsideEdge = self.qmui_outsideEdge;
    CGRect boundsInsetOutsideEdge = CGRectMake(CGRectGetMinX(self.bounds) + qmui_outsideEdge.left, CGRectGetMinY(self.bounds) + qmui_outsideEdge.top, CGRectGetWidth(self.bounds) - UIEdgeInsetsGetHorizontalValue(qmui_outsideEdge), CGRectGetHeight(self.bounds) - UIEdgeInsetsGetVerticalValue(qmui_outsideEdge));
    return CGRectContainsPoint(boundsInsetOutsideEdge, point);
}

// 这段代码需要以一个独立的方法存在，因为一旦有坑，外面可以直接通过runtime调用这个方法
// 但，不要开放到.h文件里，理论上外面不应该用到它
- (void)sendActionsForAllTouchEventsIfCan {
    self.touchEndCount += 1;
    if (self.touchEndCount == 1) {
        [self sendActionsForControlEvents:UIControlEventAllTouchEvents];
    }
}

#pragma mark - Highlighted Block

- (void)setQmui_setHighlightedBlock:(void (^)(BOOL))qmui_setHighlightedBlock {
    objc_setAssociatedObject(self, @selector(qmui_setHighlightedBlock), qmui_setHighlightedBlock, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (void (^)(BOOL))qmui_setHighlightedBlock {
    return objc_getAssociatedObject(self, _cmd);
}

#pragma mark - Tap Block

static char kAssociatedObjectKey_tapBlock;
- (void)setQmui_tapBlock:(void (^)(__kindof UIControl *))qmui_tapBlock {
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

- (void)qmui_removeTarget:(id)target action:(SEL)action forControlEvents:(UIControlEvents)controlEvents {
    [self qmui_removeTarget:target action:action forControlEvents:controlEvents];
    BOOL isTouchUpInsideEvent = controlEvents & UIControlEventTouchUpInside;
    BOOL shouldRemoveTouchUpInsideSelector = (action == @selector(qmui_handleTouchUpInside:)) || (target == self && !action) || (!target && !action);
    if (isTouchUpInsideEvent && shouldRemoveTouchUpInsideSelector) {
        // 避免触发 setter 又反过来 removeTarget，然后就死循环了
        objc_setAssociatedObject(self, &kAssociatedObjectKey_tapBlock, nil, OBJC_ASSOCIATION_COPY_NONATOMIC);
    }
}

@end
