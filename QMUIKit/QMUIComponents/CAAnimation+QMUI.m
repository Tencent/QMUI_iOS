//
//  CAAnimation+QMUI.m
//  QMUIKit
//
//  Created by MoLice on 2018/7/31.
//  Copyright © 2018年 QMUI Team. All rights reserved.
//

#import "CAAnimation+QMUI.h"
#import "QMUICore.h"
#import "QMUIMultipleDelegates.h"

@interface _QMUICAAnimationDelegator : NSObject<CAAnimationDelegate>

@end

@implementation CAAnimation (QMUI)

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        ExchangeImplementations(self.class, @selector(copyWithZone:), @selector(qmui_copyWithZone:));
    });
}

- (id)qmui_copyWithZone:(NSZone *)zone {
    CAAnimation *animation = [self qmui_copyWithZone:zone];
    animation.qmui_multipleDelegatesEnabled = self.qmui_multipleDelegatesEnabled;
    animation.qmui_animationDidStartBlock = self.qmui_animationDidStartBlock;
    animation.qmui_animationDidStopBlock = self.qmui_animationDidStopBlock;
    return animation;
}

- (void)enabledDelegateBlocks {
    self.qmui_multipleDelegatesEnabled = YES;
    BOOL shouldSetDelegator = !self.delegate;
    if (!shouldSetDelegator && [self.delegate isKindOfClass:[QMUIMultipleDelegates class]]) {
        QMUIMultipleDelegates *delegates = (QMUIMultipleDelegates *)self.delegate;
        NSPointerArray *array = delegates.delegates;
        for (NSUInteger i = 0; i < array.count; i++) {
            if ([((NSObject *)[array pointerAtIndex:i]) isKindOfClass:[_QMUICAAnimationDelegator class]]) {
                shouldSetDelegator = NO;
                break;
            }
        }
    }
    if (shouldSetDelegator) {
        self.delegate = [[_QMUICAAnimationDelegator alloc] init];// delegate is a strong property, it can retain _QMUICAAnimationDelegator
    }
}

static char kAssociatedObjectKey_animationDidStartBlock;
- (void)setQmui_animationDidStartBlock:(void (^)(__kindof CAAnimation *))qmui_animationDidStartBlock {
    objc_setAssociatedObject(self, &kAssociatedObjectKey_animationDidStartBlock, qmui_animationDidStartBlock, OBJC_ASSOCIATION_COPY_NONATOMIC);
    if (qmui_animationDidStartBlock) {
        [self enabledDelegateBlocks];
    }
}

- (void (^)(__kindof CAAnimation *))qmui_animationDidStartBlock {
    return (void (^)(__kindof CAAnimation *))objc_getAssociatedObject(self, &kAssociatedObjectKey_animationDidStartBlock);
}

static char kAssociatedObjectKey_animationDidStopBlock;
- (void)setQmui_animationDidStopBlock:(void (^)(__kindof CAAnimation *, BOOL))qmui_animationDidStopBlock {
    objc_setAssociatedObject(self, &kAssociatedObjectKey_animationDidStopBlock, qmui_animationDidStopBlock, OBJC_ASSOCIATION_COPY_NONATOMIC);
    if (qmui_animationDidStopBlock) {
        [self enabledDelegateBlocks];
    }
}

- (void (^)(__kindof CAAnimation *, BOOL))qmui_animationDidStopBlock {
    return (void (^)(__kindof CAAnimation *, BOOL))objc_getAssociatedObject(self, &kAssociatedObjectKey_animationDidStopBlock);
}

@end

@implementation _QMUICAAnimationDelegator

- (void)animationDidStart:(CAAnimation *)anim {
    if (anim.qmui_animationDidStartBlock) {
        anim.qmui_animationDidStartBlock(anim);
    }
}

- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag {
    if (anim.qmui_animationDidStopBlock) {
        anim.qmui_animationDidStopBlock(anim, flag);
    }
}

@end
