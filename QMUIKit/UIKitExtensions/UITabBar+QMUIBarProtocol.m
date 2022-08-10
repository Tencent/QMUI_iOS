//
//  UITabBar+QMUIBarProtocol.m
//  QMUIKit
//
//  Created by molice on 2022/5/18.
//  Copyright © 2022 QMUI Team. All rights reserved.
//

#import "UITabBar+QMUIBarProtocol.h"
#import "QMUIBarProtocolPrivate.h"
#import "QMUICore.h"
#import "UIVisualEffectView+QMUI.h"
#import "NSArray+QMUI.h"

@interface UITabBar ()<QMUIBarProtocolPrivate>
@end

@implementation UITabBar (QMUIBarProtocol)

QMUISynthesizeBOOLProperty(qmuibar_hasSetEffect, setQmuibar_hasSetEffect)
QMUISynthesizeBOOLProperty(qmuibar_hasSetEffectForegroundColor, setQmuibar_hasSetEffectForegroundColor)

BeginIgnoreClangWarning(-Wobjc-protocol-method-implementation)
- (void)qmuibar_updateEffect {
    [self.qmui_effectViews enumerateObjectsUsingBlock:^(UIVisualEffectView * _Nonnull effectView, NSUInteger idx, BOOL * _Nonnull stop) {
        if (self.qmuibar_hasSetEffect) {
            // 这里对 iOS 13 不使用 UITabBarAppearance.backgroundEffect 来修改，是因为反正不管 iOS 10 还是 13，最终都是 setBackgroundEffects: 在起作用，而且不用 UITabBarAppearance 还可以规避与 UIAppearance 机制的冲突
            NSArray<UIVisualEffect *> *effects = self.qmuibar_backgroundEffects;
            [effectView qmui_performSelector:NSSelectorFromString(@"setBackgroundEffects:") withArguments:&effects, nil];
        }
        if (self.qmuibar_hasSetEffectForegroundColor) {
            effectView.qmui_foregroundColor = self.qmui_effectForegroundColor;
        }
    }];
}
EndIgnoreClangWarning

// UITabBar、UIVisualEffectView  都有一个私有的方法 backgroundEffects，当 UIVisualEffectView 应用于 UITabBar 场景时，磨砂的效果实际上被放在 backgroundEffects 内，而不是公开接口的 effect 属性里，这里为了方便，将 UITabBar (QMUI).effect 转成可用于 backgroundEffects 的数组
- (NSArray<UIVisualEffect *> *)qmuibar_backgroundEffects {
    if (self.qmuibar_hasSetEffect) {
        return self.qmui_effect ? @[self.qmui_effect] : nil;
    }
    return nil;
}

#pragma mark - <QMUIBarProtocol>

- (UIView *)qmui_backgroundView {
    return [self qmui_valueForKey:@"_backgroundView"];
}

- (UIImageView *)qmui_shadowImageView {
    // bar 在 init 完就可以获取到 backgroundView 和 shadowView，无需关心调用时机的问题
    if (@available(iOS 13, *)) {
        return [self.qmui_backgroundView qmui_valueForKey:@"_shadowView1"];
    }
    // iOS 10 及以后，在 bar 初始化之后就能获取到 backgroundView 和 shadowView 了
    return [self.qmui_backgroundView qmui_valueForKey:@"_shadowView"];
}

- (UIVisualEffectView *)qmui_effectView {
    NSArray<UIVisualEffectView *> *visibleEffectViews = [self.qmui_effectViews qmui_filterWithBlock:^BOOL(UIVisualEffectView * _Nonnull item) {
        return !item.hidden && item.alpha > 0.01 && item.superview;
    }];
    return visibleEffectViews.lastObject;
}

- (NSArray<UIVisualEffectView *> *)qmui_effectViews {
    UIView *backgroundView = self.qmui_backgroundView;
    NSMutableArray<UIVisualEffectView *> *result = NSMutableArray.new;
    if (@available(iOS 13.0, *)) {
        UIVisualEffectView *backgroundEffectView1 = [backgroundView valueForKey:@"_effectView1"];
        UIVisualEffectView *backgroundEffectView2 = [backgroundView valueForKey:@"_effectView2"];
        if (backgroundEffectView1) {
            [result addObject:backgroundEffectView1];
        }
        if (backgroundEffectView2) {
            [result addObject:backgroundEffectView2];
        }
    } else {
        UIVisualEffectView *backgroundEffectView = [backgroundView qmui_valueForKey:@"_backgroundEffectView"];
        if (backgroundEffectView) {
            [result addObject:backgroundEffectView];
        }
    }
    return result.count > 0 ? result : nil;
}

static char kAssociatedObjectKey_effect;
- (void)setQmui_effect:(UIBlurEffect *)qmui_effect {
    if (qmui_effect) {
        [QMUIBarProtocolPrivate swizzleBarBackgroundViewIfNeeded];
    }
    
    BOOL valueChanged = self.qmui_effect != qmui_effect;
    objc_setAssociatedObject(self, &kAssociatedObjectKey_effect, qmui_effect, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    if (valueChanged) {
        self.qmuibar_hasSetEffect = YES;// QMUITheme 切换时会重新赋值，所以可能出现本来就是 nil，还给它又赋值了 nil，这种场景不应该导致 hasSet 标志位改变，所以要把标志位的设置放在 if (valueChanged) 里
        [self qmuibar_updateEffect];
    }
}

- (UIBlurEffect *)qmui_effect {
    return (UIBlurEffect *)objc_getAssociatedObject(self, &kAssociatedObjectKey_effect);
}

static char kAssociatedObjectKey_effectForegroundColor;
- (void)setQmui_effectForegroundColor:(UIColor *)qmui_effectForegroundColor {
    if (qmui_effectForegroundColor) {
        [QMUIBarProtocolPrivate swizzleBarBackgroundViewIfNeeded];
    }
    BOOL valueChanged = ![self.qmui_effectForegroundColor isEqual:qmui_effectForegroundColor];
    objc_setAssociatedObject(self, &kAssociatedObjectKey_effectForegroundColor, qmui_effectForegroundColor, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    if (valueChanged) {
        self.qmuibar_hasSetEffectForegroundColor = YES;// QMUITheme 切换时会重新赋值，所以可能出现本来就是 nil，还给它又赋值了 nil，这种场景不应该导致 hasSet 标志位改变，所以要把标志位的设置放在 if (valueChanged) 里
        [self qmuibar_updateEffect];
    }
}

- (UIColor *)qmui_effectForegroundColor {
    return (UIColor *)objc_getAssociatedObject(self, &kAssociatedObjectKey_effectForegroundColor);
}

@end
