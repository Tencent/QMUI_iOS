//
//  UIVisualEffect+QMUITheme.m
//  QMUIKit
//
//  Created by MoLice on 2019/7/20.
//  Copyright © 2019 QMUI Team. All rights reserved.
//

#import "UIVisualEffect+QMUITheme.h"
#import "QMUIThemeManager.h"
#import "NSMethodSignature+QMUI.h"
#import "QMUICore.h"

@interface QMUIThemeVisualEffect : NSObject <QMUIDynamicEffectProtocol>

@property(nonatomic, copy) __kindof UIVisualEffect *(^themeProvider)(__kindof QMUIThemeManager * _Nonnull manager, __kindof NSObject<NSCopying> * _Nullable identifier, __kindof NSObject * _Nullable theme);
@end

@implementation QMUIThemeVisualEffect

- (id)copyWithZone:(NSZone *)zone {
    QMUIThemeVisualEffect *effect = [[self class] allocWithZone:zone];
    effect.themeProvider = self.themeProvider;
    return effect;
}

- (NSMethodSignature *)methodSignatureForSelector:(SEL)aSelector {
    NSMethodSignature *result = [super methodSignatureForSelector:aSelector];
    if (result) {
        return result;
    }
    
    result = [self.qmui_rawEffect methodSignatureForSelector:aSelector];
    if (result && [self.qmui_rawEffect respondsToSelector:aSelector]) {
        return result;
    }
    
    return [NSMethodSignature qmui_avoidExceptionSignature];
}

- (void)forwardInvocation:(NSInvocation *)anInvocation {
    SEL selector = anInvocation.selector;
    if ([self.qmui_rawEffect respondsToSelector:selector]) {
        [anInvocation invokeWithTarget:self.qmui_rawEffect];
    }
}

- (BOOL)respondsToSelector:(SEL)aSelector {
    if ([super respondsToSelector:aSelector]) {
        return YES;
    }
    
    return [self.qmui_rawEffect respondsToSelector:aSelector];
}

- (NSUInteger)hash {
    return (NSUInteger)self.themeProvider;
}

- (BOOL)isEqual:(id)object {
    return NO;
}

#pragma mark - <QMUIDynamicEffectProtocol>

- (UIVisualEffect *)qmui_rawEffect {
    QMUIThemeManager *manager = QMUIThemeManager.sharedInstance;
    return self.themeProvider(manager, manager.currentThemeIdentifier, manager.currentTheme).qmui_rawEffect;
}

- (BOOL)qmui_isDynamicEffect {
    return YES;
}

@end

@implementation UIVisualEffect (QMUITheme)

+ (UIVisualEffect *)qmui_effectWithThemeProvider:(UIVisualEffect * _Nonnull (^)(__kindof QMUIThemeManager * _Nonnull, __kindof NSObject<NSCopying> * _Nullable, __kindof NSObject * _Nullable))provider {
    QMUIThemeVisualEffect *effect = [[QMUIThemeVisualEffect alloc] init];
    effect.themeProvider = provider;
    return (UIVisualEffect *)effect;
}

#pragma mark - <QMUIDynamicEffectProtocol>

- (UIVisualEffect *)qmui_rawEffect {
    return self;
}

- (BOOL)qmui_isDynamicEffect {
    return NO;
}

@end
