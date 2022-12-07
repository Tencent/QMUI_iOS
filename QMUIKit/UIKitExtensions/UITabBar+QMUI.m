/**
 * Tencent is pleased to support the open source community by making QMUI_iOS available.
 * Copyright (C) 2016-2021 THL A29 Limited, a Tencent company. All rights reserved.
 * Licensed under the MIT License (the "License"); you may not use this file except in compliance with the License. You may obtain a copy of the License at
 * http://opensource.org/licenses/MIT
 * Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.
 */

//
//  UITabBar+QMUI.m
//  qmui
//
//  Created by QMUI Team on 2017/2/14.
//

#import "UITabBar+QMUI.h"
#import "UITabBar+QMUIBarProtocol.h"
#import "QMUICore.h"
#import "UITabBarItem+QMUI.h"
#import "UIBarItem+QMUI.h"
#import "UIImage+QMUI.h"
#import "UIView+QMUI.h"
#import "UINavigationController+QMUI.h"
#import "UIApplication+QMUI.h"

NSInteger const kLastTouchedTabBarItemIndexNone = -1;
NSString *const kShouldCheckTabBarHiddenKey = @"kShouldCheckTabBarHiddenKey";

@interface UITabBar ()

@property(nonatomic, assign) BOOL canItemRespondDoubleTouch;
@property(nonatomic, assign) NSInteger lastTouchedTabBarItemViewIndex;
@property(nonatomic, assign) NSInteger tabBarItemViewTouchCount;
@end

@implementation UITabBar (QMUI)

QMUISynthesizeBOOLProperty(canItemRespondDoubleTouch, setCanItemRespondDoubleTouch)
QMUISynthesizeNSIntegerProperty(lastTouchedTabBarItemViewIndex, setLastTouchedTabBarItemViewIndex)
QMUISynthesizeNSIntegerProperty(tabBarItemViewTouchCount, setTabBarItemViewTouchCount)

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        OverrideImplementation([UITabBar class], @selector(setItems:animated:), ^id(__unsafe_unretained Class originClass, SEL originCMD, IMP (^originalIMPProvider)(void)) {
            return ^void(UITabBar *selfObject, NSArray<UITabBarItem *> *items, BOOL animated) {
                
                // call super
                void (*originSelectorIMP)(id, SEL, NSArray<UITabBarItem *> *, BOOL);
                originSelectorIMP = (void (*)(id, SEL, NSArray<UITabBarItem *> *, BOOL))originalIMPProvider();
                originSelectorIMP(selfObject, originCMD, items, animated);
                
                [items enumerateObjectsUsingBlock:^(UITabBarItem * _Nonnull item, NSUInteger idx, BOOL * _Nonnull stop) {
                    // 双击 tabBarItem 的功能需要在设置完 item 后才能获取到 qmui_view 来实现
                    UIControl *itemView = (UIControl *)item.qmui_view;
                    [itemView addTarget:selfObject action:@selector(handleTabBarItemViewEvent:) forControlEvents:UIControlEventTouchUpInside];
                }];
            };
        });
        
        OverrideImplementation([UITabBar class], @selector(setSelectedItem:), ^id(__unsafe_unretained Class originClass, SEL originCMD, IMP (^originalIMPProvider)(void)) {
            return ^(UITabBar *selfObject, UITabBarItem *selectedItem) {
                
                NSInteger olderSelectedIndex = selfObject.selectedItem ? [selfObject.items indexOfObject:selfObject.selectedItem] : -1;
                
                // call super
                void (*originSelectorIMP)(id, SEL, UITabBarItem *);
                originSelectorIMP = (void (*)(id, SEL, UITabBarItem *))originalIMPProvider();
                originSelectorIMP(selfObject, originCMD, selectedItem);
                
                NSInteger newerSelectedIndex = [selfObject.items indexOfObject:selectedItem];
                // 只有双击当前正在显示的界面的 tabBarItem，才能正常触发双击事件
                selfObject.canItemRespondDoubleTouch = olderSelectedIndex == newerSelectedIndex;
            };
        });
        
        // iOS 13 下如果以 UITabBarAppearance 的方式将 UITabBarItem 的 font 大小设置为超过默认的 10，则会出现布局错误，文字被截断，所以这里做了个兼容，iOS 14.0 测试过已不存在该问题
        // https://github.com/Tencent/QMUI_iOS/issues/740
        //
        // iOS 14 修改 UITabBarAppearance.inlineLayoutAppearance.normal.titleTextAttributes[NSForegroundColor] 会导致 UITabBarItem 文字无法完整展示
        // https://github.com/Tencent/QMUI_iOS/issues/1110
        //
        // [UIKit Bug] 使用 UITabBarAppearance 将 UITabBarItem 选中时的字体设置为 bold 则无法完整显示 title
        // https://github.com/Tencent/QMUI_iOS/issues/1286
        OverrideImplementation(NSClassFromString(@"UITabBarButtonLabel"), @selector(setAttributedText:), ^id(__unsafe_unretained Class originClass, SEL originCMD, IMP (^originalIMPProvider)(void)) {
            return ^(UILabel *selfObject, NSAttributedString *firstArgv) {
                
                // call super
                void (*originSelectorIMP)(id, SEL, NSAttributedString *);
                originSelectorIMP = (void (*)(id, SEL, NSAttributedString *))originalIMPProvider();
                originSelectorIMP(selfObject, originCMD, firstArgv);
                
                if (@available(iOS 14.0, *)) {
                    // iOS 14 只有在 bold 时才有问题，所以把额外的 sizeToFit 做一些判断，尽量减少调用次数
                    UIFont *font = selfObject.font;
                    BOOL isBold = [font.fontName containsString:@"bold"];
                    if (isBold) {
                        [selfObject sizeToFit];
                    }
                } else {
                    // iOS 13 加粗时有 #1286 描述的问题，不加粗时有 #740 描述的问题，所以干脆只要是 iOS 13 都加粗算了
                    [selfObject sizeToFit];
                }
            };
        });
        
        // iOS 14.0 如果 pop 到一个 hidesBottomBarWhenPushed = NO 的 vc，tabBar 无法正确显示出来
        // 根据测试，iOS 14.2 开始，系统已修复该问题
        // https://github.com/Tencent/QMUI_iOS/issues/1100
        if (@available(iOS 14.0, *)) {
            if (@available(iOS 14.2, *)) {
            } else {
                OverrideImplementation([UINavigationController class], @selector(qmui_didInitialize), ^id(__unsafe_unretained Class originClass, SEL originCMD, IMP (^originalIMPProvider)(void)) {
                    return ^(UINavigationController *selfObject) {
                        
                        // call super
                        void (*originSelectorIMP)(id, SEL);
                        originSelectorIMP = (void (*)(id, SEL))originalIMPProvider();
                        originSelectorIMP(selfObject, originCMD);
                        
                        [selfObject qmui_addNavigationActionDidChangeBlock:^(QMUINavigationAction action, BOOL animated, __kindof UINavigationController * _Nullable weakNavigationController, __kindof UIViewController * _Nullable appearingViewController, NSArray<__kindof UIViewController *> * _Nullable disappearingViewControllers) {
                            switch (action) {
                                case QMUINavigationActionWillPop:
                                case QMUINavigationActionWillSet: {
                                    // 系统的逻辑就是，在 push N 个 vc 的过程中，只要其中出现任意一个 vc.hidesBottomBarWhenPushed = YES，则 tabBar 不会再出现（不管后续有没有 vc.hidesBottomBarWhenPushed = NO），所以在 pop 回去的时候也要遵循这个规则
                                    if (animated && weakNavigationController.tabBarController && !appearingViewController.hidesBottomBarWhenPushed) {
                                        BOOL systemShouldHideTabBar = NO;
                                        
                                        // setViewControllers 可能出现当前 vc 不存在已有 viewControllers 数组内的情况，要保护
                                        // https://github.com/Tencent/QMUI_iOS/issues/1177
                                        NSUInteger index = [weakNavigationController.viewControllers indexOfObject:appearingViewController];
                                        
                                        if (index != NSNotFound) {
                                            NSArray<UIViewController *> *viewControllers = [weakNavigationController.viewControllers subarrayWithRange:NSMakeRange(0, index + 1)];
                                            for (UIViewController *vc in viewControllers) {
                                                if (vc.hidesBottomBarWhenPushed) {
                                                    systemShouldHideTabBar = YES;
                                                }
                                            }
                                            if (!systemShouldHideTabBar) {
                                                [weakNavigationController qmui_bindBOOL:YES forKey:kShouldCheckTabBarHiddenKey];
                                            }
                                        }
                                    }
                                }
                                    break;
                                case QMUINavigationActionDidPop:
                                case QMUINavigationActionDidSet: {
                                    [weakNavigationController qmui_bindBOOL:NO forKey:kShouldCheckTabBarHiddenKey];
                                }
                                    break;
                                    
                                default:
                                    break;
                            }
                        }];
                    };
                });
                
                OverrideImplementation([UINavigationController class], NSSelectorFromString(@"_shouldBottomBarBeHidden"), ^id(__unsafe_unretained Class originClass, SEL originCMD, IMP (^originalIMPProvider)(void)) {
                    return ^BOOL(UINavigationController *selfObject) {
                        // call super
                        BOOL (*originSelectorIMP)(id, SEL);
                        originSelectorIMP = (BOOL (*)(id, SEL))originalIMPProvider();
                        BOOL result = originSelectorIMP(selfObject, originCMD);
                        
                        if ([selfObject qmui_getBoundBOOLForKey:kShouldCheckTabBarHiddenKey]) {
                            result = NO;
                        }
                        return result;
                    };
                });
            }
        }
        
        
        // 以下是将 iOS 12 修改 UITabBar 样式的接口转换成用 iOS 13 的新接口去设置（因为新旧方法是互斥的，所以统一在新系统都用新方法）
        // 但这样有个风险，因为 QMUIConfiguration 配置表里都是用 appearance 的方式去设置 standardAppearance，所以如果在 UITabBar 实例被添加到 window 之前修改过旧版任意一个样式接口，就会导致一个新的 UITabBarAppearance 对象被设置给 standardAppearance 属性，这样系统就会认为你这个 UITabBar 实例自定义了 standardAppearance，那么当它被 moveToWindow 时就不会自动应用 appearance 的值了，因此需要保证在添加到 window 前不要自行修改属性
        void (^syncAppearance)(UITabBar *, void(^barActionBlock)(UITabBarAppearance *appearance), void (^itemActionBlock)(UITabBarItemAppearance *itemAppearance)) = ^void(UITabBar *tabBar, void(^barActionBlock)(UITabBarAppearance *appearance), void (^itemActionBlock)(UITabBarItemAppearance *itemAppearance)) {
            if (!barActionBlock && !itemActionBlock) return;
            
            UITabBarAppearance *appearance = tabBar.standardAppearance;
            if (barActionBlock) {
                barActionBlock(appearance);
            }
            if (itemActionBlock) {
                [appearance qmui_applyItemAppearanceWithBlock:itemActionBlock];
            }
            tabBar.standardAppearance = appearance;
#ifdef IOS15_SDK_ALLOWED
            if (@available(iOS 15.0, *)) {
                if (QMUICMIActivated && TabBarUsesStandardAppearanceOnly) {
                    tabBar.scrollEdgeAppearance = appearance;
                }
            }
#endif
        };
        
        ExtendImplementationOfVoidMethodWithSingleArgument([UITabBar class], @selector(setTintColor:), UIColor *, ^(UITabBar *selfObject, UIColor *tintColor) {
            syncAppearance(selfObject, nil, ^void(UITabBarItemAppearance *itemAppearance) {
                itemAppearance.selected.iconColor = tintColor;
                
                NSMutableDictionary<NSAttributedStringKey, id> *textAttributes = itemAppearance.selected.titleTextAttributes.mutableCopy;
                textAttributes[NSForegroundColorAttributeName] = tintColor;
                itemAppearance.selected.titleTextAttributes = textAttributes.copy;
            });
        });
        
        ExtendImplementationOfVoidMethodWithSingleArgument([UITabBar class], @selector(setBarTintColor:), UIColor *, ^(UITabBar *selfObject, UIColor *barTintColor) {
            syncAppearance(selfObject, ^void(UITabBarAppearance *appearance) {
                appearance.backgroundColor = barTintColor;
            }, nil);
        });
        
        ExtendImplementationOfVoidMethodWithSingleArgument([UITabBar class], @selector(setUnselectedItemTintColor:), UIColor *, ^(UITabBar *selfObject, UIColor *tintColor) {
            syncAppearance(selfObject, nil, ^void(UITabBarItemAppearance *itemAppearance) {
                itemAppearance.normal.iconColor = tintColor;
                
                NSMutableDictionary *textAttributes = itemAppearance.normal.titleTextAttributes.mutableCopy;
                textAttributes[NSForegroundColorAttributeName] = tintColor;
                itemAppearance.normal.titleTextAttributes = textAttributes.copy;
            });
        });
        
        ExtendImplementationOfVoidMethodWithSingleArgument([UITabBar class], @selector(setBackgroundImage:), UIImage *, ^(UITabBar *selfObject, UIImage *image) {
            syncAppearance(selfObject, ^void(UITabBarAppearance *appearance) {
                appearance.backgroundImage = image;
            }, nil);
        });
        
        ExtendImplementationOfVoidMethodWithSingleArgument([UITabBar class], @selector(setShadowImage:), UIImage *, ^(UITabBar *selfObject, UIImage *shadowImage) {
            syncAppearance(selfObject, ^void(UITabBarAppearance *appearance) {
                appearance.shadowImage = shadowImage;
            }, nil);
        });
        
        ExtendImplementationOfVoidMethodWithSingleArgument([UITabBar class], @selector(setBarStyle:), UIBarStyle, ^(UITabBar *selfObject, UIBarStyle barStyle) {
            syncAppearance(selfObject, ^void(UITabBarAppearance *appearance) {
                appearance.backgroundEffect = [UIBlurEffect effectWithStyle:barStyle == UIBarStyleDefault ? UIBlurEffectStyleSystemChromeMaterialLight : UIBlurEffectStyleSystemChromeMaterialDark];
            }, nil);
        });
    });
}

- (void)handleTabBarItemViewEvent:(UIControl *)itemView {
    
    if (!self.canItemRespondDoubleTouch) {
        return;
    }
    
    if (!self.selectedItem.qmui_doubleTapBlock) {
        return;
    }
    
    // 如果一定时间后仍未触发双击，则废弃当前的点击状态
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(.25 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self revertTabBarItemTouch];
    });
    
    NSInteger selectedIndex = [self.items indexOfObject:self.selectedItem];
    
    if (self.lastTouchedTabBarItemViewIndex == kLastTouchedTabBarItemIndexNone) {
        // 记录第一次点击的 index
        self.lastTouchedTabBarItemViewIndex = selectedIndex;
    } else if (self.lastTouchedTabBarItemViewIndex != selectedIndex) {
        // 后续的点击如果与第一次点击的 index 不一致，则认为是重新开始一次新的点击
        [self revertTabBarItemTouch];
        self.lastTouchedTabBarItemViewIndex = selectedIndex;
        return;
    }
    
    self.tabBarItemViewTouchCount ++;
    if (self.tabBarItemViewTouchCount == 2) {
        // 第二次点击了相同的 tabBarItem，触发双击事件
        UITabBarItem *item = self.items[selectedIndex];
        if (item.qmui_doubleTapBlock) {
            item.qmui_doubleTapBlock(item, selectedIndex);
        }
        [self revertTabBarItemTouch];
    }
}

- (void)revertTabBarItemTouch {
    self.lastTouchedTabBarItemViewIndex = kLastTouchedTabBarItemIndexNone;
    self.tabBarItemViewTouchCount = 0;
}

@end

@implementation UITabBarAppearance (QMUI)

- (void)qmui_applyItemAppearanceWithBlock:(void (^)(UITabBarItemAppearance * _Nonnull))block {
    block(self.stackedLayoutAppearance);
    block(self.inlineLayoutAppearance);
    block(self.compactInlineLayoutAppearance);
}

@end
