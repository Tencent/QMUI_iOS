/**
 * Tencent is pleased to support the open source community by making QMUI_iOS available.
 * Copyright (C) 2016-2021 THL A29 Limited, a Tencent company. All rights reserved.
 * Licensed under the MIT License (the "License"); you may not use this file except in compliance with the License. You may obtain a copy of the License at
 * http://opensource.org/licenses/MIT
 * Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.
 */

//
//  UINavigationBar+QMUI.m
//  QMUIKit
//
//  Created by QMUI Team on 2018/O/8.
//

#import "UINavigationBar+QMUI.h"
#import "QMUICore.h"
#import "NSObject+QMUI.h"
#import "UIView+QMUI.h"
#import "NSArray+QMUI.h"

NSString *const kShouldFixTitleViewBugKey = @"kShouldFixTitleViewBugKey";

@implementation UINavigationBar (QMUI)

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        // [UIKit Bug] iOS 12 及以上的系统，如果设置了自己的 leftBarButtonItem，且 title 很长时，则当 pop 的时候，title 会瞬间跳到左边，与 leftBarButtonItem 重叠
        // https://github.com/Tencent/QMUI_iOS/issues/1217
        if (@available(iOS 12.0, *)) {
            
            // _UITAMICAdaptorView
            Class adaptorClass = NSClassFromString([NSString qmui_stringByConcat:@"_", @"UITAMIC", @"Adaptor", @"View", nil]);
            
            // _UINavigationBarContentView
            OverrideImplementation(NSClassFromString([NSString qmui_stringByConcat:@"_", @"UINavigationBar", @"ContentView", nil]), @selector(didAddSubview:), ^id(__unsafe_unretained Class originClass, SEL originCMD, IMP (^originalIMPProvider)(void)) {
                return ^(UIView *selfObject, UIView *firstArgv) {
                    
                    // call super
                    void (*originSelectorIMP)(id, SEL, UIView *);
                    originSelectorIMP = (void (*)(id, SEL, UIView *))originalIMPProvider();
                    originSelectorIMP(selfObject, originCMD, firstArgv);
                    
                    if ([firstArgv isKindOfClass:adaptorClass] || [firstArgv isKindOfClass:UILabel.class]) {
                        firstArgv.qmui_frameWillChangeBlock = ^CGRect(__kindof UIView * _Nonnull view, CGRect followingFrame) {
                            if ([view qmui_getBoundObjectForKey:kShouldFixTitleViewBugKey]) {
                                followingFrame = [[view qmui_getBoundObjectForKey:kShouldFixTitleViewBugKey] CGRectValue];
                            }
                            return followingFrame;
                        };
                    }
                };
            });
            
            void (^boundTitleViewMinXBlock)(UINavigationBar *, BOOL) = ^void(UINavigationBar *navigationBar, BOOL cleanup) {
                
                if (!navigationBar.topItem.leftBarButtonItem) return;
                
                UIView *titleView = nil;
                UIView *adapterView = navigationBar.topItem.titleView.superview;
                if ([adapterView isKindOfClass:adaptorClass]) {
                    titleView = adapterView;
                } else {
                    titleView = [navigationBar.qmui_contentView.subviews qmui_filterWithBlock:^BOOL(__kindof UIView * _Nonnull item) {
                        return [item isKindOfClass:UILabel.class];
                    }].firstObject;
                }
                if (!titleView) return;
                
                if (cleanup) {
                    [titleView qmui_bindObject:nil forKey:kShouldFixTitleViewBugKey];
                } else if (CGRectGetWidth(titleView.frame) > CGRectGetWidth(navigationBar.bounds) / 2) {
                    [titleView qmui_bindObject:[NSValue valueWithCGRect:titleView.frame] forKey:kShouldFixTitleViewBugKey];
                }
            };
            
            // - (id) _popNavigationItemWithTransition:(int)arg1; (0x1a15513a0)
            OverrideImplementation([UINavigationBar class], NSSelectorFromString([NSString qmui_stringByConcat:@"_", @"popNavigationItem", @"With", @"Transition:", nil]), ^id(__unsafe_unretained Class originClass, SEL originCMD, IMP (^originalIMPProvider)(void)) {
                return ^id(UINavigationBar *selfObject, NSInteger firstArgv) {
                    
                    boundTitleViewMinXBlock(selfObject, NO);
                    
                    // call super
                    id (*originSelectorIMP)(id, SEL, NSInteger);
                    originSelectorIMP = (id (*)(id, SEL, NSInteger))originalIMPProvider();
                    id result = originSelectorIMP(selfObject, originCMD, firstArgv);
                    return result;
                };
            });
            
            // - (void) _completePopOperationAnimated:(BOOL)arg1 transitionAssistant:(id)arg2; (0x1a1551668)
            OverrideImplementation([UINavigationBar class], NSSelectorFromString([NSString qmui_stringByConcat:@"_", @"complete", @"PopOperationAnimated:", @"transitionAssistant:", nil]), ^id(__unsafe_unretained Class originClass, SEL originCMD, IMP (^originalIMPProvider)(void)) {
                return ^(UINavigationBar *selfObject, BOOL firstArgv, id secondArgv) {
                    
                    // call super
                    void (*originSelectorIMP)(id, SEL, BOOL, id);
                    originSelectorIMP = (void (*)(id, SEL, BOOL, id))originalIMPProvider();
                    originSelectorIMP(selfObject, originCMD, firstArgv, secondArgv);
                    
                    boundTitleViewMinXBlock(selfObject, YES);
                };
            });
        }
        
        // 以下是将 iOS 12 修改 UINavigationBar 样式的接口转换成用 iOS 13 的新接口去设置（因为新旧方法是互斥的，所以统一在新系统都用新方法）
        // 虽然系统的新接口是 iOS 13 就已经存在，但由于 iOS 13、14 都没必要用新接口，所以 QMUI 里在 iOS 15 才开始使用新接口，所以下方的 @available 填的是 iOS 15 而非 iOS 13（与 QMUIConfiguration.m 对应）。
        // 但这样有个风险，因为 QMUIConfiguration 配置表里都是用 appearance 的方式去设置 standardAppearance，所以如果在 UINavigationBar 实例被添加到 window 之前修改过旧版任意一个样式接口，就会导致一个新的 UINavigationBarAppearance 对象被设置给 standardAppearance 属性，这样系统就会认为你这个 UINavigationBar 实例自定义了 standardAppearance，那么当它被 moveToWindow 时就不会自动应用 appearance 的值了，因此需要保证在添加到 window 前不要自行修改属性
#ifdef IOS15_SDK_ALLOWED
        if (@available(iOS 15.0, *)) {
            
            void (^syncAppearance)(UINavigationBar *, void(^barActionBlock)(UINavigationBarAppearance *appearance)) = ^void(UINavigationBar *navigationBar, void(^barActionBlock)(UINavigationBarAppearance *appearance)) {
                if (!barActionBlock) return;
                
                UINavigationBarAppearance *appearance = navigationBar.standardAppearance;
                barActionBlock(appearance);
                navigationBar.standardAppearance = appearance;
                if (QMUICMIActivated && NavBarUsesStandardAppearanceOnly) {
                    navigationBar.scrollEdgeAppearance = appearance;
                }
            };
            
            OverrideImplementation([UINavigationBar class], @selector(setBarTintColor:), ^id(__unsafe_unretained Class originClass, SEL originCMD, IMP (^originalIMPProvider)(void)) {
                return ^(UINavigationBar *selfObject, UIColor *barTintColor) {
                    
                    // call super
                    void (*originSelectorIMP)(id, SEL, UIColor *);
                    originSelectorIMP = (void (*)(id, SEL, UIColor *))originalIMPProvider();
                    originSelectorIMP(selfObject, originCMD, barTintColor);
                    
                    syncAppearance(selfObject, ^void(UINavigationBarAppearance *appearance) {
                        appearance.backgroundColor = barTintColor;
                    });
                };
            });
            
            OverrideImplementation([UINavigationBar class], @selector(barTintColor), ^id(__unsafe_unretained Class originClass, SEL originCMD, IMP (^originalIMPProvider)(void)) {
                return ^UIColor *(UINavigationBar *selfObject) {
                    return selfObject.standardAppearance.backgroundColor;
                };
            });
            
            OverrideImplementation([UINavigationBar class], @selector(setBackgroundImage:forBarPosition:barMetrics:), ^id(__unsafe_unretained Class originClass, SEL originCMD, IMP (^originalIMPProvider)(void)) {
                return ^(UINavigationBar *selfObject, UIImage *image, UIBarPosition barPosition, UIBarMetrics barMetrics) {
                    
                    // call super
                    void (*originSelectorIMP)(id, SEL, UIImage *, UIBarPosition, UIBarMetrics);
                    originSelectorIMP = (void (*)(id, SEL, UIImage *, UIBarPosition, UIBarMetrics))originalIMPProvider();
                    originSelectorIMP(selfObject, originCMD, image, barPosition, barMetrics);
                    
                    syncAppearance(selfObject, ^void(UINavigationBarAppearance *appearance) {
                        appearance.backgroundImage = image;
                    });
                };
            });
            
            OverrideImplementation([UINavigationBar class], @selector(backgroundImageForBarPosition:barMetrics:), ^id(__unsafe_unretained Class originClass, SEL originCMD, IMP (^originalIMPProvider)(void)) {
                return ^UIImage *(UINavigationBar *selfObject, UIBarPosition firstArgv, UIBarMetrics secondArgv) {
                    return selfObject.standardAppearance.backgroundImage;
                };
            });
            
            OverrideImplementation([UINavigationBar class], @selector(setShadowImage:), ^id(__unsafe_unretained Class originClass, SEL originCMD, IMP (^originalIMPProvider)(void)) {
                return ^(UINavigationBar *selfObject, UIImage *shadowImage) {
                    
                    // call super
                    void (*originSelectorIMP)(id, SEL, UIImage *);
                    originSelectorIMP = (void (*)(id, SEL, UIImage *))originalIMPProvider();
                    originSelectorIMP(selfObject, originCMD, shadowImage);
                    
                    syncAppearance(selfObject, ^void(UINavigationBarAppearance *appearance) {
                        appearance.shadowImage = shadowImage;
                    });
                };
            });
            
            OverrideImplementation([UINavigationBar class], @selector(shadowImage), ^id(__unsafe_unretained Class originClass, SEL originCMD, IMP (^originalIMPProvider)(void)) {
                return ^UIImage *(UINavigationBar *selfObject) {
                    return selfObject.standardAppearance.shadowImage;
                };
            });
            
            OverrideImplementation([UINavigationBar class], @selector(setBarStyle:), ^id(__unsafe_unretained Class originClass, SEL originCMD, IMP (^originalIMPProvider)(void)) {
                return ^(UINavigationBar *selfObject, UIBarStyle barStyle) {
                    
                    // call super
                    void (*originSelectorIMP)(id, SEL, UIBarStyle);
                    originSelectorIMP = (void (*)(id, SEL, UIBarStyle))originalIMPProvider();
                    originSelectorIMP(selfObject, originCMD, barStyle);
                    
                    syncAppearance(selfObject, ^void(UINavigationBarAppearance *appearance) {
                        appearance.backgroundEffect = [UIBlurEffect effectWithStyle:barStyle == UIBarStyleDefault ? UIBlurEffectStyleSystemChromeMaterialLight : UIBlurEffectStyleSystemChromeMaterialDark];
                    });
                };
            });
            
            // iOS 15 没有对应的属性
//            OverrideImplementation([UINavigationBar class], @selector(barStyle), ^id(__unsafe_unretained Class originClass, SEL originCMD, IMP (^originalIMPProvider)(void)) {
//                return ^UIBarStyle(UINavigationBar *selfObject) {
//
//                    if (@available(iOS 15.0, *)) {
//                        return ???;
//                    }
//
//
//                    // call super
//                    UIBarStyle (*originSelectorIMP)(id, SEL);
//                    originSelectorIMP = (UIBarStyle (*)(id, SEL))originalIMPProvider();
//                    UIBarStyle result = originSelectorIMP(selfObject, originCMD);
//
//                    return result;
//                };
//            });
            
            OverrideImplementation([UINavigationBar class], @selector(setTitleTextAttributes:), ^id(__unsafe_unretained Class originClass, SEL originCMD, IMP (^originalIMPProvider)(void)) {
                return ^(UINavigationBar *selfObject, NSDictionary<NSAttributedStringKey, id> *titleTextAttributes) {
                    
                    // call super
                    void (*originSelectorIMP)(id, SEL, NSDictionary<NSAttributedStringKey, id> *);
                    originSelectorIMP = (void (*)(id, SEL, NSDictionary<NSAttributedStringKey, id> *))originalIMPProvider();
                    originSelectorIMP(selfObject, originCMD, titleTextAttributes);
                    
                    syncAppearance(selfObject, ^void(UINavigationBarAppearance *appearance) {
                        appearance.titleTextAttributes = titleTextAttributes;
                    });
                };
            });
        }
        
        if (@available(iOS 15.0, *)) {
            if (!QMUICMIActivated) return;
            if (!(NavBarRemoveBackgroundEffectAutomatically || TabBarRemoveBackgroundEffectAutomatically || ToolBarRemoveBackgroundEffectAutomatically)
                && !(NavBarUsesStandardAppearanceOnly || TabBarUsesStandardAppearanceOnly || ToolBarUsesStandardAppearanceOnly)) return;
            
            // - [_UIBarBackground updateBackground]
            OverrideImplementation(NSClassFromString(@"_UIBarBackground"), NSSelectorFromString(@"updateBackground"), ^id(__unsafe_unretained Class originClass, SEL originCMD, IMP (^originalIMPProvider)(void)) {
                return ^(UIView *selfObject) {
                    
                    // call super
                    void (*originSelectorIMP)(id, SEL);
                    originSelectorIMP = (void (*)(id, SEL))originalIMPProvider();
                    originSelectorIMP(selfObject, originCMD);
                    
                    if (!selfObject.superview) return;
                    if (!NavBarRemoveBackgroundEffectAutomatically && !NavBarUsesStandardAppearanceOnly && [selfObject.superview isKindOfClass:UINavigationBar.class]) return;
                    if (!TabBarRemoveBackgroundEffectAutomatically && !TabBarUsesStandardAppearanceOnly && [selfObject.superview isKindOfClass:UITabBar.class]) return;
                    if (!ToolBarRemoveBackgroundEffectAutomatically && !ToolBarUsesStandardAppearanceOnly && [selfObject.superview isKindOfClass:UIToolbar.class]) return;
                    
                    UIImageView *backgroundImageView1 = [selfObject valueForKey:@"_colorAndImageView1"];
                    UIImageView *backgroundImageView2 = [selfObject valueForKey:@"_colorAndImageView2"];
                    UIVisualEffectView *backgroundEffectView1 = [selfObject valueForKey:@"_effectView1"];
                    UIVisualEffectView *backgroundEffectView2 = [selfObject valueForKey:@"_effectView2"];
                    
                    // iOS 14 系统默认特性是存在 backgroundImage 则不存在其他任何背景，但如果存在 barTintColor 则磨砂 view 也可以共存。
                    // iOS 15 系统默认特性是 backgroundImage、backgroundColor、backgroundEffect 三者都可以共存，其中前两者共用 _colorAndImageView，而我们这个开关为了符合 iOS 14 的特性，仅针对 _colorAndImageView 是因为 backgroundImage 存在而出现的情况做处理。
                    if (NavBarRemoveBackgroundEffectAutomatically || TabBarRemoveBackgroundEffectAutomatically || ToolBarRemoveBackgroundEffectAutomatically) {
                        BOOL hasBackgroundImage1 = backgroundImageView1 && backgroundImageView1.superview && !backgroundImageView1.hidden && backgroundImageView1.image;
                        BOOL hasBackgroundImage2 = backgroundImageView2 && backgroundImageView2.superview && !backgroundImageView2.hidden && backgroundImageView2.image;
                        BOOL shouldHideEffectView = hasBackgroundImage1 || hasBackgroundImage2;
                        if (shouldHideEffectView) {
                            backgroundEffectView1.hidden = YES;
                            backgroundEffectView2.hidden = YES;
                        } else {
                            // 把 backgroundImage 置为 nil，理应要恢复 effectView 的显示，但由于 iOS 15 里 effectView 有2个，什么时候显示哪个取决于 contentScrollView 的滚动位置，而这个位置在当前上下文里我们是无法得知的，所以先不处理了，交给系统在下一次 updateBackground 时刷新吧...
                        }
                    }
                    
                    // 虽然 4.4.0 增加的这些开关会保证 scrollEdgeAppearance 也被设置，但系统始终都会同时显示两份 view（一份 standard 的一份 scrollEdge 的），当你的样式是不透明时没问题，但如果存在半透明，同时显示两份 view 就会导致两个半透明的效果重叠在一起，最终肉眼看到的样式和预期是不符合的，所以 4.4.4 开始，我们会强制让其中一份 view 隐藏掉。
                    if (NavBarUsesStandardAppearanceOnly || TabBarUsesStandardAppearanceOnly || ToolBarUsesStandardAppearanceOnly) {
                        backgroundImageView2.hidden = YES;
                        backgroundEffectView2.hidden = YES;
                    }
                };
            });
        }
#endif
    });
}

- (UIView *)qmui_contentView {
    return [self valueForKeyPath:@"visualProvider.contentView"];
}

@end
