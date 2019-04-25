/*****
 * Tencent is pleased to support the open source community by making QMUI_iOS available.
 * Copyright (C) 2016-2019 THL A29 Limited, a Tencent company. All rights reserved.
 * Licensed under the MIT License (the "License"); you may not use this file except in compliance with the License. You may obtain a copy of the License at
 * http://opensource.org/licenses/MIT
 * Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.
 *****/

//
//  CAAnimation+QMUI.m
//  QMUIKit
//
//  Created by QMUI Team on 2018/7/31.
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
        ExtendImplementationOfNonVoidMethodWithSingleArgument([CAAnimation class], @selector(copyWithZone:), NSZone *, id, ^id(CAAnimation *selfObject, NSZone *firstArgv, id originReturnValue) {
            CAAnimation *animation = (CAAnimation *)originReturnValue;
            animation.qmui_multipleDelegatesEnabled = selfObject.qmui_multipleDelegatesEnabled;
            animation.qmui_animationDidStartBlock = selfObject.qmui_animationDidStartBlock;
            animation.qmui_animationDidStopBlock = selfObject.qmui_animationDidStopBlock;
            return animation;
        });
    });
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
