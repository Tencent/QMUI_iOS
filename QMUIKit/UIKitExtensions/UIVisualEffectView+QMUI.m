/**
 * Tencent is pleased to support the open source community by making QMUI_iOS available.
 * Copyright (C) 2016-2021 THL A29 Limited, a Tencent company. All rights reserved.
 * Licensed under the MIT License (the "License"); you may not use this file except in compliance with the License. You may obtain a copy of the License at
 * http://opensource.org/licenses/MIT
 * Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.
 */

//
//  UIVisualEffectView+QMUI.m
//  QMUIKit
//
//  Created by MoLice on 2020/7/15.
//

#import "UIVisualEffectView+QMUI.h"
#import "QMUICore.h"
#import "CALayer+QMUI.h"

@interface UIView (QMUI_VisualEffectView)

// 为了方便，这个属性声明在 UIView 里，但实际上只有两个私有的 Visual View 会用到
@property(nonatomic, assign) BOOL qmuive_keepHidden;
@end

@interface UIVisualEffectView ()

@property(nonatomic, strong) CALayer *qmuive_foregroundLayer;
@property(nonatomic, assign, readonly) BOOL qmuive_showsForegroundLayer;
@end

@implementation UIVisualEffectView (QMUI)

QMUISynthesizeIdStrongProperty(qmuive_foregroundLayer, setQmuive_foregroundLayer)

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        OverrideImplementation([UIVisualEffectView class], @selector(didAddSubview:), ^id(__unsafe_unretained Class originClass, SEL originCMD, IMP (^originalIMPProvider)(void)) {
            return ^(UIVisualEffectView *selfObject, UIView *firstArgv) {
                
                // call super
                void (*originSelectorIMP)(id, SEL, UIView *);
                originSelectorIMP = (void (*)(id, SEL, UIView *))originalIMPProvider();
                originSelectorIMP(selfObject, originCMD, firstArgv);
                
                [selfObject qmuive_updateSubviews];
            };
        });
        
        ExtendImplementationOfVoidMethodWithoutArguments([UIVisualEffectView class], @selector(layoutSubviews), ^(UIVisualEffectView *selfObject) {
            if (selfObject.qmuive_showsForegroundLayer) {
                selfObject.qmuive_foregroundLayer.frame = selfObject.bounds;
            }
        });
    });
}

static char kAssociatedObjectKey_foregroundColor;
- (void)setQmui_foregroundColor:(UIColor *)qmui_foregroundColor {
    objc_setAssociatedObject(self, &kAssociatedObjectKey_foregroundColor, qmui_foregroundColor, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    if (qmui_foregroundColor && !self.qmuive_foregroundLayer) {
        self.qmuive_foregroundLayer = [CALayer layer];
        [self.qmuive_foregroundLayer qmui_removeDefaultAnimations];
        [self.layer addSublayer:self.qmuive_foregroundLayer];
        
        [[NSNotificationCenter defaultCenter] removeObserver:self name:UIAccessibilityReduceTransparencyStatusDidChangeNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleReduceTransparencyStatusDidChangeNotification:) name:UIAccessibilityReduceTransparencyStatusDidChangeNotification object:nil];
    }
    if (self.qmuive_foregroundLayer) {
        if (UIAccessibilityIsReduceTransparencyEnabled()) {
            qmui_foregroundColor = [qmui_foregroundColor colorWithAlphaComponent:1];
        }
        self.qmuive_foregroundLayer.backgroundColor = qmui_foregroundColor.CGColor;
        self.qmuive_foregroundLayer.hidden = !qmui_foregroundColor;
        [self qmuive_updateSubviews];
        [self setNeedsLayout];
    }
}

- (UIColor *)qmui_foregroundColor {
    return (UIColor *)objc_getAssociatedObject(self, &kAssociatedObjectKey_foregroundColor);
}

- (BOOL)qmuive_showsForegroundLayer {
    return self.qmuive_foregroundLayer && !self.qmuive_foregroundLayer.hidden;
}

- (void)qmuive_updateSubviews {
    if (self.qmuive_foregroundLayer) {
        
        // 先放在最背后，然后在遇到磨砂的 backdropLayer 时再放到它前面，因为有些情况下可能不存在 backdropLayer（例如 effect = nil 或者 effect 为 UIVibrancyEffect）
        [self.layer qmui_sendSublayerToBack:self.qmuive_foregroundLayer];
        for (NSInteger i = 0; i < self.layer.sublayers.count; i++) {
            CALayer *sublayer = self.layer.sublayers[i];
            if ([NSStringFromClass(sublayer.class) isEqualToString:@"UICABackdropLayer"]) {
                [self.layer insertSublayer:self.qmuive_foregroundLayer above:sublayer];
                break;
            }
        }
        
        [self.subviews enumerateObjectsUsingBlock:^(__kindof UIView * _Nonnull subview, NSUInteger idx, BOOL * _Nonnull stop) {
            NSString *className = NSStringFromClass(subview.class);
            if ([className isEqualToString:@"_UIVisualEffectSubview"] || [className isEqualToString:@"_UIVisualEffectFilterView"]) {
                subview.qmuive_keepHidden = !self.qmuive_foregroundLayer.hidden;
            }
        }];
    }
}

- (void)handleReduceTransparencyStatusDidChangeNotification:(NSNotification *)notification {
    if (self.qmui_foregroundColor) {
        self.qmui_foregroundColor = self.qmui_foregroundColor;
    }
}

@end

@implementation UIView (QMUI_VisualEffectView)

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        OverrideImplementation(NSClassFromString(@"_UIVisualEffectSubview"), @selector(setHidden:), ^id(__unsafe_unretained Class originClass, SEL originCMD, IMP (^originalIMPProvider)(void)) {
            return ^(UIView *selfObject, BOOL firstArgv) {
                
                if (selfObject.qmuive_keepHidden) {
                    firstArgv = YES;
                }
                
                // call super
                void (*originSelectorIMP)(id, SEL, BOOL);
                originSelectorIMP = (void (*)(id, SEL, BOOL))originalIMPProvider();
                originSelectorIMP(selfObject, originCMD, firstArgv);
            };
        });
    });
}

static char kAssociatedObjectKey_keepHidden;
- (void)setQmuive_keepHidden:(BOOL)qmuive_keepHidden {
    objc_setAssociatedObject(self, &kAssociatedObjectKey_keepHidden, @(qmuive_keepHidden), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    // 从语义来看，当 keepHidden = NO 时，并不意味着 hidden 就一定要为 NO，但为了方便添加了 foregroundColor 后再去除 foregroundColor 时做一些恢复性质的操作，这里就实现成 keepHidden = NO 时 hidden = NO
    self.hidden = qmuive_keepHidden;
}

- (BOOL)qmuive_keepHidden {
    return [((NSNumber *)objc_getAssociatedObject(self, &kAssociatedObjectKey_keepHidden)) boolValue];
}

@end
