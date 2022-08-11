/**
 * Tencent is pleased to support the open source community by making QMUI_iOS available.
 * Copyright (C) 2016-2021 THL A29 Limited, a Tencent company. All rights reserved.
 * Licensed under the MIT License (the "License"); you may not use this file except in compliance with the License. You may obtain a copy of the License at
 * http://opensource.org/licenses/MIT
 * Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.
 */
//
//  UIToolbar+QMUI.m
//  QMUIKit
//
//  Created by MoLice on 2021/N/24.
//

#import "UIToolbar+QMUI.h"
#import "QMUICore.h"

@implementation UIToolbar (QMUI)

#ifdef IOS15_SDK_ALLOWED
+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        // 以下是将 iOS 12 修改 UIToolbar 样式的接口转换成用 iOS 13 的新接口去设置（因为新旧方法是互斥的，所以统一在新系统都用新方法）
        // 虽然系统的新接口是 iOS 13 就已经存在，但由于 iOS 13、14 都没必要用新接口，所以 QMUI 里在 iOS 15 才开始使用新接口，所以下方的 @available 填的是 iOS 15 而非 iOS 13（与 QMUIConfiguration.m 对应）。
        // 但这样有个风险，因为 QMUIConfiguration 配置表里都是用 appearance 的方式去设置 standardAppearance，所以如果在 UIToolbar 实例被添加到 window 之前修改过旧版任意一个样式接口，就会导致一个新的 UIToolbarAppearance 对象被设置给 standardAppearance 属性，这样系统就会认为你这个 UIToolbar 实例自定义了 standardAppearance，那么当它被 moveToWindow 时就不会自动应用 appearance 的值了，因此需要保证在添加到 window 前不要自行修改属性
        if (@available(iOS 15.0, *)) {
            
            void (^syncAppearance)(UIToolbar *, void(^barActionBlock)(UIToolbarAppearance *appearance)) = ^void(UIToolbar *toolbar, void(^barActionBlock)(UIToolbarAppearance *appearance)) {
                if (!barActionBlock) return;
                
                UIToolbarAppearance *appearance = toolbar.standardAppearance;
                barActionBlock(appearance);
                toolbar.standardAppearance = appearance;
                if (QMUICMIActivated && ToolBarUsesStandardAppearanceOnly) {
                    toolbar.scrollEdgeAppearance = appearance;
                }
            };
            
            OverrideImplementation([UIToolbar class], @selector(setBarTintColor:), ^id(__unsafe_unretained Class originClass, SEL originCMD, IMP (^originalIMPProvider)(void)) {
                return ^(UIToolbar *selfObject, UIColor *barTintColor) {
                    
                    // call super
                    void (*originSelectorIMP)(id, SEL, UIColor *);
                    originSelectorIMP = (void (*)(id, SEL, UIColor *))originalIMPProvider();
                    originSelectorIMP(selfObject, originCMD, barTintColor);
                    
                    syncAppearance(selfObject, ^void(UIToolbarAppearance *appearance) {
                        appearance.backgroundColor = barTintColor;
                    });
                };
            });
            
            OverrideImplementation([UIToolbar class], @selector(barTintColor), ^id(__unsafe_unretained Class originClass, SEL originCMD, IMP (^originalIMPProvider)(void)) {
                return ^UIColor *(UIToolbar *selfObject) {
                    return selfObject.standardAppearance.backgroundColor;
                };
            });
            
            OverrideImplementation([UIToolbar class], @selector(setBackgroundImage:forToolbarPosition:barMetrics:), ^id(__unsafe_unretained Class originClass, SEL originCMD, IMP (^originalIMPProvider)(void)) {
                return ^(UIToolbar *selfObject, UIImage *image, UIBarPosition barPosition, UIBarMetrics barMetrics) {
                    
                    // call super
                    void (*originSelectorIMP)(id, SEL, UIImage *, UIBarPosition, UIBarMetrics);
                    originSelectorIMP = (void (*)(id, SEL, UIImage *, UIBarPosition, UIBarMetrics))originalIMPProvider();
                    originSelectorIMP(selfObject, originCMD, image, barPosition, barMetrics);
                    
                    syncAppearance(selfObject, ^void(UIToolbarAppearance *appearance) {
                        appearance.backgroundImage = image;
                    });
                };
            });
            
            OverrideImplementation([UIToolbar class], @selector(backgroundImageForToolbarPosition:barMetrics:), ^id(__unsafe_unretained Class originClass, SEL originCMD, IMP (^originalIMPProvider)(void)) {
                return ^UIImage *(UIToolbar *selfObject, UIBarPosition firstArgv, UIBarMetrics secondArgv) {
                    return selfObject.standardAppearance.backgroundImage;
                };
            });
            
            OverrideImplementation([UIToolbar class], @selector(setShadowImage:forToolbarPosition:), ^id(__unsafe_unretained Class originClass, SEL originCMD, IMP (^originalIMPProvider)(void)) {
                return ^(UIToolbar *selfObject, UIImage *shadowImage, UIBarPosition position) {
                    
                    // call super
                    void (*originSelectorIMP)(id, SEL, UIImage *, UIBarPosition);
                    originSelectorIMP = (void (*)(id, SEL, UIImage *, UIBarPosition))originalIMPProvider();
                    originSelectorIMP(selfObject, originCMD, shadowImage, position);
                    
                    syncAppearance(selfObject, ^void(UIToolbarAppearance *appearance) {
                        appearance.shadowImage = shadowImage;
                    });
                };
            });
            
            OverrideImplementation([UIToolbar class], @selector(shadowImageForToolbarPosition:), ^id(__unsafe_unretained Class originClass, SEL originCMD, IMP (^originalIMPProvider)(void)) {
                return ^UIImage *(UIToolbar *selfObject, UIBarPosition position) {
                    return selfObject.standardAppearance.shadowImage;
                };
            });
            
//            OverrideImplementation([UIToolbar class], @selector(setBarStyle:), ^id(__unsafe_unretained Class originClass, SEL originCMD, IMP (^originalIMPProvider)(void)) {
//                return ^(UIToolbar *selfObject, UIBarStyle barStyle) {
//
//                    // call super
//                    void (*originSelectorIMP)(id, SEL, UIBarStyle);
//                    originSelectorIMP = (void (*)(id, SEL, UIBarStyle))originalIMPProvider();
//                    originSelectorIMP(selfObject, originCMD, barStyle);
//
//                    syncAppearance(selfObject, ^void(UIToolbarAppearance *appearance) {
//                        appearance.backgroundEffect = [UIBlurEffect effectWithStyle:barStyle == UIBarStyleDefault ? UIBlurEffectStyleSystemChromeMaterialLight : UIBlurEffectStyleSystemChromeMaterialDark];
//                    });
//                };
//            });
            
            // iOS 15 没有对应的属性
//            OverrideImplementation([UIToolbar class], @selector(barStyle), ^id(__unsafe_unretained Class originClass, SEL originCMD, IMP (^originalIMPProvider)(void)) {
//                return ^UIBarStyle(UIToolbar *selfObject) {
//
//                    if (@available(iOS 15.0, *)) {
//                        return ???;
//                    }
//
//                    // call super
//                    UIBarStyle (*originSelectorIMP)(id, SEL);
//                    originSelectorIMP = (UIBarStyle (*)(id, SEL))originalIMPProvider();
//                    UIBarStyle result = originSelectorIMP(selfObject, originCMD);
//
//                    return result;
//                };
//            });
        }
    });
}
#endif
@end
