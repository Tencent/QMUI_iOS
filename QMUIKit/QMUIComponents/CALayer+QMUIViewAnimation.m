/**
 * Tencent is pleased to support the open source community by making QMUI_iOS available.
 * Copyright (C) 2016-2021 THL A29 Limited, a Tencent company. All rights reserved.
 * Licensed under the MIT License (the "License"); you may not use this file except in compliance with the License. You may obtain a copy of the License at
 * http://opensource.org/licenses/MIT
 * Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.
 */
//
//  CALayer+QMUIViewAnimation.m
//  QMUIKit
//
//  Created by ziezheng on 2020/4/4.
//

#import "CALayer+QMUIViewAnimation.h"
#import "CALayer+QMUI.h"
#import "QMUICore.h"
#import "QMUIMultipleDelegates.h"


@interface _QMUICALayerDelegator : NSObject <CALayerDelegate>

@end

@implementation _QMUICALayerDelegator

+ (instancetype)sharedDelegator {
    static dispatch_once_t onceToken;
    static _QMUICALayerDelegator *instance = nil;
    dispatch_once(&onceToken,^{
        instance = [[super allocWithZone:NULL] init];
    });
    return instance;
}

+ (id)allocWithZone:(struct _NSZone *)zone {
    return [self sharedDelegator];
}

- (id<CAAction>)actionForLayer:(CALayer *)layer forKey:(NSString *)event {
    static UIView *standardView = nil;
    if (!standardView) standardView = UIView.new;
    // 被 +[UIView animateWithDuration:animations:] 包裹的代码可利用任意 UIView 的 actionForLayer:forKey: 来获得默认的 CAAction
    id<CAAction> action = [standardView actionForLayer:standardView.layer forKey:event];
    if (action == [NSNull null]) {
        // -[CALayer actionForKey:] 会先询问本代理，一旦代理返回了 NSNull， 则不会执行 self.actions 里隐式动画，为保持 CALayer 的原有逻辑，这里返回 nil，详见 -[CALayer actionForKey:] 的文档描述。
        return nil;
    } else {
        return action;
    }
}

@end

@implementation CALayer (QMUIViewAnimation)

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        OverrideImplementation([CALayer class], @selector(addAnimation:forKey:), ^id(__unsafe_unretained Class originClass, SEL originCMD, IMP (^originalIMPProvider)(void)) {
            return ^(CALayer *selfObject, CAAnimation *animation, NSString *key) {
                if (selfObject.qmui_viewAnimationEnabled) {
                    BOOL isViewAnimtion = [animation isKindOfClass:CABasicAnimation.class] && [animation.delegate isKindOfClass:NSClassFromString(@"UIViewAnimationState")];
                    if (isViewAnimtion) {
                        // 这里需要清空 fromValue 和 toValue，后面会在 CAMediaTimingCopyRenderTiming 取到这个 animtion 的参数并设置到 CATransaction 中，让 Layer 改变属性时，运用上这些动画
                        ((CABasicAnimation *)animation).fromValue = nil;
                        ((CABasicAnimation *)animation).toValue = nil;
                        // 这个机制下的 toValue 已是最终值，这里 additive 要设置成 NO，否则会多叠加一次计算结果，导致动画出错。
                        ((CABasicAnimation *)animation).additive = NO;
                    }
                }
                void (*originSelectorIMP)(id, SEL, CAAnimation *, NSString *);
                originSelectorIMP = (void (*)(id, SEL, CAAnimation *, NSString *))originalIMPProvider();
                originSelectorIMP(selfObject, originCMD, animation, key);
                
            };
        });
    });
}


static char kAssociatedObjectKey_qmuiviewAnimationEnabled;
- (void)setQmui_viewAnimationEnabled:(BOOL)qmui_viewAnimationEnabled {
    QMUIAssert(!self.qmui_isRootLayerOfView, @"CALayer (QMUIViewAnimation)", @"UIView 本身的 Layer 无须开启 %s", __func__);
    objc_setAssociatedObject(self, &kAssociatedObjectKey_qmuiviewAnimationEnabled, @(qmui_viewAnimationEnabled), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    if (qmui_viewAnimationEnabled) {
        self.qmui_multipleDelegatesEnabled = YES;
        self.delegate = [_QMUICALayerDelegator sharedDelegator];
    } else {
        [self qmui_removeDelegate:[_QMUICALayerDelegator sharedDelegator]];
    }
}

- (BOOL)qmui_viewAnimationEnabled {
    return [((NSNumber *)objc_getAssociatedObject(self, &kAssociatedObjectKey_qmuiviewAnimationEnabled)) boolValue];
}

@end
