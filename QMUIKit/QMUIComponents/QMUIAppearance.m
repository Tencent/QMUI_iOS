/**
 * Tencent is pleased to support the open source community by making QMUI_iOS available.
 * Copyright (C) 2016-2021 THL A29 Limited, a Tencent company. All rights reserved.
 * Licensed under the MIT License (the "License"); you may not use this file except in compliance with the License. You may obtain a copy of the License at
 * http://opensource.org/licenses/MIT
 * Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.
 */
//
//  QMUIAppearance.m
//  QMUIKit
//
//  Created by MoLice on 2020/3/25.
//

#import "QMUIAppearance.h"
#import "QMUICore.h"
#import "QMUIWeakObjectContainer.h"

@implementation QMUIAppearance

static NSMutableDictionary *appearances;
+ (id)appearanceForClass:(Class)aClass {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (!appearances) {
            appearances = NSMutableDictionary.new;
        }
    });
    NSString *className = NSStringFromClass(aClass);
    id appearance = appearances[className];
    if (!appearance) {
        BeginIgnorePerformSelectorLeaksWarning
        SEL selector = NSSelectorFromString([NSString stringWithFormat:@"_%@:%@:", @"appearanceForClass", @"withContainerList"]);
        appearance = [NSClassFromString(@"_UIAppearance") performSelector:selector withObject:aClass withObject:nil];
        appearances[className] = appearance;
        EndIgnorePerformSelectorLeaksWarning
    }
    return appearance;
}

@end

BeginIgnoreClangWarning(-Wincomplete-implementation)
@interface NSObject (QMUIAppearance_Private)
@property(nonatomic, assign) BOOL qmui_applyingAppearance;
+ (instancetype)appearance;
@end

@implementation NSObject (QMUIAppearnace)
QMUISynthesizeBOOLProperty(qmui_applyingAppearance, setQmui_applyingAppearance)

/**
 关于 appearance 要考虑这几点：
 1. 是否产生内存泄漏
 2. 父类的 appearance 能否在子类里生效
 3. 如果某个 property 在 ClassA 里声明为 UI_APPEARANCE_SELECTOR，则在子类 Class B : Class A 里获取该 property 的值将为 nil，这是正常的，系统默认行为如此，系统是在应用 appearance 的时候发现子类的 property 值为 nil 时才会从父类里读取值，在这个阶段才完成继承效果。
 */
- (void)qmui_applyAppearance {
    Class class = self.class;
    if ([class respondsToSelector:@selector(appearance)]) {
        // -[_UIAppearance _applyInvocationsTo:window:] 会调用 _appearanceGuideClass，如果不是 UIView 或者 UIViewController 的子类，需要额外实现这个方法。
        SEL appearanceGuideClassSelector = NSSelectorFromString(@"_appearanceGuideClass");
        if (!class_respondsToSelector(class, appearanceGuideClassSelector)) {
            const char * typeEncoding = method_getTypeEncoding(class_getInstanceMethod(UIView.class, appearanceGuideClassSelector));
            class_addMethod(class, appearanceGuideClassSelector, imp_implementationWithBlock(^Class(void) {
                return nil;
            }), typeEncoding);
        }
        
        self.qmui_applyingAppearance = YES;
        BeginIgnorePerformSelectorLeaksWarning
        SEL selector = NSSelectorFromString([NSString stringWithFormat:@"_%@:%@:", @"applyInvocationsTo", @"window"]);
        [NSClassFromString(@"_UIAppearance") performSelector:selector withObject:self withObject:nil];
        EndIgnorePerformSelectorLeaksWarning
        self.qmui_applyingAppearance = NO;
    }
}

@end
EndIgnoreClangWarning
