/*****
 * Tencent is pleased to support the open source community by making QMUI_iOS available.
 * Copyright (C) 2016-2019 THL A29 Limited, a Tencent company. All rights reserved.
 * Licensed under the MIT License (the "License"); you may not use this file except in compliance with the License. You may obtain a copy of the License at
 * http://opensource.org/licenses/MIT
 * Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.
 *****/
//
//  UIVisualEffect+QMUITheme.m
//  QMUIKit
//
//  Created by MoLice on 2019/7/20.
//

#import "UIVisualEffect+QMUITheme.h"
#import "QMUIThemeManager.h"
#import "QMUIThemeManagerCenter.h"
#import "QMUIThemePrivate.h"
#import "NSMethodSignature+QMUI.h"
#import "QMUICore.h"

@implementation QMUIThemeVisualEffect

- (id)copyWithZone:(NSZone *)zone {
    QMUIThemeVisualEffect *effect = [[self class] allocWithZone:zone];
    effect.managerName = self.managerName;
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

- (BOOL)isKindOfClass:(Class)aClass {
    if (aClass == QMUIThemeVisualEffect.class) return YES;
    return [self.qmui_rawEffect isKindOfClass:aClass];
}

- (BOOL)isMemberOfClass:(Class)aClass {
    if (aClass == QMUIThemeVisualEffect.class) return YES;
    return [self.qmui_rawEffect isMemberOfClass:aClass];
}

- (BOOL)conformsToProtocol:(Protocol *)aProtocol {
    return [self.qmui_rawEffect conformsToProtocol:aProtocol];
}

- (NSUInteger)hash {
    return (NSUInteger)self.themeProvider;
}

- (BOOL)isEqual:(id)object {
    return NO;
}

#pragma mark - <QMUIDynamicEffectProtocol>

- (UIVisualEffect *)qmui_rawEffect {
    QMUIThemeManager *manager = [QMUIThemeManagerCenter themeManagerWithName:self.managerName];
    return self.themeProvider(manager, manager.currentThemeIdentifier, manager.currentTheme).qmui_rawEffect;
}

- (BOOL)qmui_isDynamicEffect {
    return YES;
}

@end

@implementation UIVisualEffect (QMUITheme)

+ (UIVisualEffect *)qmui_effectWithThemeProvider:(UIVisualEffect * _Nonnull (^)(__kindof QMUIThemeManager * _Nonnull, __kindof NSObject<NSCopying> * _Nullable, __kindof NSObject * _Nullable))provider {
    return [UIVisualEffect qmui_effectWithThemeManagerName:QMUIThemeManagerNameDefault provider:provider];
}

+ (UIVisualEffect *)qmui_effectWithThemeManagerName:(__kindof NSObject<NSCopying> *)name provider:(UIVisualEffect * _Nonnull (^)(__kindof QMUIThemeManager * _Nonnull, __kindof NSObject<NSCopying> * _Nullable, __kindof NSObject * _Nullable))provider {
    QMUIThemeVisualEffect *effect = [[QMUIThemeVisualEffect alloc] init];
    effect.managerName = name;
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
