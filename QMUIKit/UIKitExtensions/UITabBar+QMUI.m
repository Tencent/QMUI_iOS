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
#import "QMUICore.h"
#import "UITabBarItem+QMUI.h"
#import "UIBarItem+QMUI.h"
#import "UIImage+QMUI.h"
#import "UIView+QMUI.h"
#import "UINavigationController+QMUI.h"
#import "UIVisualEffectView+QMUI.h"

NSInteger const kLastTouchedTabBarItemIndexNone = -1;
NSString *const kShouldCheckTabBarHiddenKey = @"kShouldCheckTabBarHiddenKey";

@interface UITabBar ()

@property(nonatomic, assign) BOOL canItemRespondDoubleTouch;
@property(nonatomic, assign) NSInteger lastTouchedTabBarItemViewIndex;
@property(nonatomic, assign) NSInteger tabBarItemViewTouchCount;
@property(nonatomic, assign) BOOL qmuitb_hasSetEffect;
@property(nonatomic, assign) BOOL qmuitb_hasSetEffectForegroundColor;
@end

@implementation UITabBar (QMUI)

QMUISynthesizeBOOLProperty(canItemRespondDoubleTouch, setCanItemRespondDoubleTouch)
QMUISynthesizeNSIntegerProperty(lastTouchedTabBarItemViewIndex, setLastTouchedTabBarItemViewIndex)
QMUISynthesizeNSIntegerProperty(tabBarItemViewTouchCount, setTabBarItemViewTouchCount)
QMUISynthesizeBOOLProperty(qmuitb_hasSetEffect, setQmuitb_hasSetEffect)
QMUISynthesizeBOOLProperty(qmuitb_hasSetEffectForegroundColor, setQmuitb_hasSetEffectForegroundColor)

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        ExtendImplementationOfVoidMethodWithoutArguments([UITabBarController class], @selector(viewDidLoad), ^(UITabBarController *selfObject) {
            if (QMUICMIActivated) {
                if (@available(iOS 13.0, *)) {
                    // iOS 13 不使用 tintColor 了，改为用 UITabBarAppearance，具体请看 QMUIConfiguration.m
                } else {
                    // 根据 TabBarContainerClasses 的值来决定是否设置 UITabBar.tintColor
                    // UITabBar.tintColor 没有被添加 UI_APPEARANCE_SELECTOR 标记，所以没有采用 UIAppearance 的方式去实现（虽然它实际上是支持的）
                    BOOL shouldSetTintColor = NO;
                    if (TabBarContainerClasses.count) {
                        for (Class class in TabBarContainerClasses) {
                            if ([selfObject isKindOfClass:class]) {
                                shouldSetTintColor = YES;
                                break;
                            }
                        }
                    } else {
                        shouldSetTintColor = YES;
                    }
                    if (shouldSetTintColor) {
                        selfObject.tabBar.tintColor = TabBarItemImageColorSelected;
                    }
                }
            }
        });
        
        // iOS 12 及以下，如果 UITabBar backgroundImage 为 nil，则 tabBar 会显示磨砂背景，此时不管怎么修改 shadowImage 都无效，都会显示系统默认的分隔线，导致无法很好地统一不同 iOS 版本的表现（iOS 13 及以上没有这个限制），所以这里做了兼容。
        if (@available(iOS 13.0, *)) {
        } else {
            ExtendImplementationOfVoidMethodWithoutArguments(NSClassFromString(@"_UITabBarVisualProviderLegacyIOS"), NSSelectorFromString(@"_updateBackground"), ^(NSObject *selfObject) {
                UITabBar *tabBar = [selfObject qmui_valueForKey:@"tabBar"];
                if (!tabBar) return;
                UIImage *shadowImage = tabBar.shadowImage;// 就算 tabBar 显示系统的分隔线，但依然能从 shadowImage 属性获取到业务自己设置的图片
                UIImageView *shadowImageView = tabBar.qmui_shadowImageView;
                if (shadowImage && shadowImageView && shadowImageView.backgroundColor && !shadowImageView.image) {
                    shadowImageView.backgroundColor = nil;
                    shadowImageView.image = shadowImage;
                }
            });
        }
        
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
        
        OverrideImplementation([UITabBar class], @selector(setFrame:), ^id(__unsafe_unretained Class originClass, SEL originCMD, IMP (^originalIMPProvider)(void)) {
            return ^(UITabBar *selfObject, CGRect frame) {
                if (QMUICMIActivated && ShouldFixTabBarTransitionBugInIPhoneX && IOS_VERSION < 11.2 && IS_58INCH_SCREEN) {
                    if (CGRectGetHeight(frame) == TabBarHeight && CGRectGetMaxY(frame) < CGRectGetHeight(selfObject.superview.bounds)) {
                        // iOS 11 在界面 push 的过程中 tabBar 会瞬间往上跳，所以做这个修复。这个 bug 在 iOS 11.2 里已被系统修复。
                        // https://github.com/Tencent/QMUI_iOS/issues/217
                        frame = CGRectSetY(frame, CGRectGetHeight(selfObject.superview.bounds) - CGRectGetHeight(frame));
                    }
                }
                
                // 修复这个 bug：https://github.com/Tencent/QMUI_iOS/issues/309
                if (@available(iOS 11, *)) {
                    if (IS_NOTCHED_SCREEN && ((CGRectGetHeight(frame) == 49 || CGRectGetHeight(frame) == 32))) {// 只关注全面屏设备下的这两种非正常的 tabBar 高度即可
                        CGFloat bottomSafeAreaInsets = selfObject.safeAreaInsets.bottom > 0 ? selfObject.safeAreaInsets.bottom : selfObject.superview.safeAreaInsets.bottom;// 注意，如果只是拿 selfObject.safeAreaInsets 判断，会肉眼看到高度的跳变，因此引入 superview 的值（虽然理论上 tabBar 不一定都会布局到 UITabBarController.view 的底部）
                        if (bottomSafeAreaInsets == CGRectGetHeight(selfObject.frame)) {
                            return;// 由于这个系统 bug https://github.com/Tencent/QMUI_iOS/issues/446，这里先暂时屏蔽本次 frame 变化
                        }
                        frame.size.height += bottomSafeAreaInsets;
                        frame.origin.y -= bottomSafeAreaInsets;
                    }
                }
                
                // call super
                void (*originSelectorIMP)(id, SEL, CGRect);
                originSelectorIMP = (void (*)(id, SEL, CGRect))originalIMPProvider();
                originSelectorIMP(selfObject, originCMD, frame);
            };
        });
        
        // 以下代码修复两个仅存在于 12.1.0 版本的系统 bug，实测 12.1.1 苹果已经修复
        if (@available(iOS 12.1, *)) {
            if (@available(iOS 12.1.1, *)) {
            } else {
                OverrideImplementation(NSClassFromString(@"UITabBarButton"), @selector(setFrame:), ^id(__unsafe_unretained Class originClass, SEL originCMD, IMP (^originalIMPProvider)(void)) {
                    return ^(UIView *selfObject, CGRect firstArgv) {
                        
                        // Fixed: UITabBar layout is broken on iOS 12.1
                        // https://github.com/Tencent/QMUI_iOS/issues/410
                        
                        if (!CGRectIsEmpty(selfObject.frame) && CGRectIsEmpty(firstArgv)) {
                            return;
                        }
                        
                        // Fixed: iOS 12.1 UITabBarItem positioning issue during swipe back gesture (when UINavigationBar is hidden)
                        // https://github.com/Tencent/QMUI_iOS/issues/422
                        if (IS_NOTCHED_SCREEN) {
                            if ((CGRectGetHeight(selfObject.frame) == 48 && CGRectGetHeight(firstArgv) == 33) || (CGRectGetHeight(selfObject.frame) == 31 && CGRectGetHeight(firstArgv) == 20)) {
                                return;
                            }
                        }
                        
                        // call super
                        void (*originSelectorIMP)(id, SEL, CGRect);
                        originSelectorIMP = (void (*)(id, SEL, CGRect))originalIMPProvider();
                        originSelectorIMP(selfObject, originCMD, firstArgv);
                    };
                });
            }
        }
        
        if (@available(iOS 13.0, *)) {
        } else {
            Class tabBarButtonLabelClass = NSClassFromString(@"UITabBarButtonLabel");
            
            UITabBarItem *(^tabBarItemOfLabelBlock)(UILabel *label) = ^UITabBarItem *(UILabel *label) {
                UIControl *tabBarButton = [label qmui_valueForKey:@"_tabBarButton"];
                UITabBar *tabBar = [tabBarButton qmui_valueForKey:@"tabBar"];
                __block UITabBarItem *tabBarItem = nil;
                if (!tabBar) {
                    return nil;
                }
                [tabBar.items enumerateObjectsUsingBlock:^(UITabBarItem * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                    if (obj.qmui_view == tabBarButton) {
                        tabBarItem = obj;
                        *stop = YES;
                    }
                }];
                return tabBarItem;
            };
            
            // iOS 12，如果用 UIAppearance 的方式设置了 UITabBar.appearance.unselectedItemTintColor，此时不管以 appearance 方式修改 UITabBarItem titleTextAttributes 的 NSForegroundColorAttributeName，或是直接修改 UITabBarItem 实例，均会被 unselectedItemTintColor 覆盖，所以这里做个保护
            OverrideImplementation(tabBarButtonLabelClass, NSSelectorFromString(@"_setUnselectedTintColor:"), ^id(__unsafe_unretained Class originClass, SEL originCMD, IMP (^originalIMPProvider)(void)) {
                return ^(UILabel *selfObject, UIColor *firstArgv) {
                    
                    UITabBarItem *item = tabBarItemOfLabelBlock(selfObject);
                    if (item) {
                        UITabBar *tabBar = [[selfObject qmui_valueForKey:@"_tabBarButton"] qmui_valueForKey:@"tabBar"];
                        NSDictionary<NSAttributedStringKey,id> *normalAttributes = [item titleTextAttributesForState:UIControlStateNormal] ?: [UITabBarItem.qmui_appearanceConfigured titleTextAttributesForState:UIControlStateNormal];
                        UIColor *normalColor = normalAttributes[NSForegroundColorAttributeName];
                        UIColor *unselectedTintColor = tabBar.unselectedItemTintColor;
                        if (normalColor && [unselectedTintColor isEqual:firstArgv] && ![normalColor isEqual:unselectedTintColor]) {
                            return;
                        }
                    }
                    
                    // call super
                    void (*originSelectorIMP)(id, SEL, UIColor *);
                    originSelectorIMP = (void (*)(id, SEL, UIColor *))originalIMPProvider();
                    originSelectorIMP(selfObject, originCMD, firstArgv);
                };
            });
            
            // 修复系统在 iOS 12 及以下，通过 [UITabBarItem setTitleTextAttributes:forState:] 设置的 selected 字体无法生效的 bug（selected 的颜色是可以生效的）
            OverrideImplementation(tabBarButtonLabelClass, @selector(setSelected:), ^id(__unsafe_unretained Class originClass, SEL originCMD, IMP (^originalIMPProvider)(void)) {
                return ^(UILabel *selfObject, BOOL selected) {
                    
                    // call super
                    void (*originSelectorIMP)(id, SEL, BOOL);
                    originSelectorIMP = (void (*)(id, SEL, BOOL))originalIMPProvider();
                    originSelectorIMP(selfObject, originCMD, selected);
                    
                    UITabBarItem *item = tabBarItemOfLabelBlock(selfObject);
                    if (!item) {
                        return;
                    }
                    
                    NSDictionary<NSAttributedStringKey,id> *normalAttributes = [item titleTextAttributesForState:UIControlStateNormal] ?: [UITabBarItem.qmui_appearanceConfigured titleTextAttributesForState:UIControlStateNormal];
                    NSDictionary<NSAttributedStringKey,id> *selectedAttributes = [item titleTextAttributesForState:UIControlStateSelected] ?: [UITabBarItem.qmui_appearanceConfigured titleTextAttributesForState:UIControlStateSelected];
                    if (normalAttributes[NSFontAttributeName] && selectedAttributes[NSFontAttributeName]) {
                        if (selected) {
                            selfObject.font = selectedAttributes[NSFontAttributeName];
                        } else {
                            selfObject.font = normalAttributes[NSFontAttributeName];
                        }
                        [selfObject sizeToFit];
                        [selfObject.superview setNeedsLayout];
                    }
                };
            });   
        }
        
        // iOS 13 下如果以 UITabBarAppearance 的方式将 UITabBarItem 的 font 大小设置为超过默认的 10，则会出现布局错误，文字被截断，所以这里做了个兼容
        // iOS 14.0 测试过已不存在该问题
        // https://github.com/Tencent/QMUI_iOS/issues/740
        if (@available(iOS 13.0, *)) {
            if (@available(iOS 14.0, *)) {
            } else {
                OverrideImplementation(NSClassFromString(@"UITabBarButtonLabel"), @selector(setAttributedText:), ^id(__unsafe_unretained Class originClass, SEL originCMD, IMP (^originalIMPProvider)(void)) {
                    return ^(UILabel *selfObject, NSAttributedString *firstArgv) {
                        
                        // call super
                        void (*originSelectorIMP)(id, SEL, NSAttributedString *);
                        originSelectorIMP = (void (*)(id, SEL, NSAttributedString *))originalIMPProvider();
                        originSelectorIMP(selfObject, originCMD, firstArgv);
                        
                        CGFloat fontSize = selfObject.font.pointSize;
                        if (fontSize > 10) {
                            [selfObject sizeToFit];
                        }
                    };
                });
            }
        }
        
        // iOS 14 修改 UITabBarAppearance.inlineLayoutAppearance.normal.titleTextAttributes[NSForegroundColor] 会导致 UITabBarItem 文字无法完整展示
        // https://github.com/Tencent/QMUI_iOS/issues/1110
        if (@available(iOS 14.0, *)) {
            OverrideImplementation(NSClassFromString(@"UITabBarButtonLabel"), @selector(sizeThatFits:), ^id(__unsafe_unretained Class originClass, SEL originCMD, IMP (^originalIMPProvider)(void)) {
                return ^CGSize(UILabel *selfObject, CGSize firstArgv) {
                    UIFont *font = selfObject.font;
                    SEL selectorForCSSFontFamily = NSSelectorFromString(@"familyNameForCSSFontFamilyValueForWebKit:");
                    if ([font respondsToSelector:selectorForCSSFontFamily]) {
                        BOOL forWebKit = YES;
                        NSString *fontFamily = [font qmui_performSelector:selectorForCSSFontFamily withArguments:&forWebKit, nil];
                        if ([fontFamily containsString:@"UICTFontTextStyleFootnote"]) {
                            static UILabel *standardLabel;
                            if (!standardLabel) {
                                standardLabel = [[UILabel alloc] init];
                            }
                            standardLabel.attributedText = selfObject.attributedText;
                            CGSize result = [standardLabel sizeThatFits:firstArgv];
                            return result;
                        }
                    }
                    
                    // call super
                    CGSize (*originSelectorIMP)(id, SEL, CGSize);
                    originSelectorIMP = (CGSize (*)(id, SEL, CGSize))originalIMPProvider();
                    CGSize result = originSelectorIMP(selfObject, originCMD, firstArgv);
                    return result;
                };
            });
        }
        
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
        if (@available(iOS 13.0, *)) {
            
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
                    
                    NSMutableDictionary *textAttributes = itemAppearance.selected.titleTextAttributes.mutableCopy;
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
                    appearance.backgroundEffect = [UIBlurEffect effectWithStyle:barStyle == UIBarStyleDefault ? UIBlurEffectStyleSystemMaterialLight : UIBlurEffectStyleSystemMaterialDark];
                }, nil);
            });
        }
    });
}

- (UIView *)qmui_backgroundView {
    return [self qmui_valueForKey:@"_backgroundView"];
}

- (UIImageView *)qmui_shadowImageView {
    if (@available(iOS 13, *)) {
        return [self.qmui_backgroundView qmui_valueForKey:@"_shadowView1"];
    }
    // iOS 10 及以后，在 UITabBar 初始化之后就能获取到 backgroundView 和 shadowView 了
    return [self.qmui_backgroundView qmui_valueForKey:@"_shadowView"];
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

- (UIVisualEffectView *)qmui_effectView {
    for (UIView *subview in self.qmui_backgroundView.subviews) {
        if ([subview isMemberOfClass:UIVisualEffectView.class]) {
            return (UIVisualEffectView *)subview;
        }
    }
    return nil;
}

- (void)qmuitb_swizzleBackgroundView {
    [QMUIHelper executeBlock:^{
        Class backgroundClass = NSClassFromString(@"_UIBarBackground");
        OverrideImplementation(backgroundClass, @selector(didAddSubview:), ^id(__unsafe_unretained Class originClass, SEL originCMD, IMP (^originalIMPProvider)(void)) {
            return ^(UIView *selfObject, UIView *subview) {
                
                // call super
                void (*originSelectorIMP)(id, SEL, UIView *);
                originSelectorIMP = (void (*)(id, SEL, UIView *))originalIMPProvider();
                originSelectorIMP(selfObject, originCMD, subview);
                
                // 注意可能存在多个 UIVisualEffectView，例如用于 shadowImage 的 _UIBarBackgroundShadowView，需要过滤掉
                if ([selfObject.superview isKindOfClass:UITabBar.class] && [subview isMemberOfClass:UIVisualEffectView.class]) {
                    UITabBar *tabBar = (UITabBar *)selfObject.superview;
                    if (tabBar.qmuitb_hasSetEffect || tabBar.qmuitb_hasSetEffectForegroundColor) {
                        [tabBar qmuitb_updateEffect];
                    }
                }
            };
        });
        // 系统会在任意可能的时机去刷新 backgroundEffects，为了避免被系统的值覆盖，这里需要重写它
        OverrideImplementation(UIVisualEffectView.class, NSSelectorFromString(@"setBackgroundEffects:"), ^id(__unsafe_unretained Class originClass, SEL originCMD, IMP (^originalIMPProvider)(void)) {
            return ^(UIVisualEffectView *selfObject, NSArray<UIVisualEffect *> *firstArgv) {
                
                if ([selfObject.superview isKindOfClass:backgroundClass] && [selfObject.superview.superview isKindOfClass:UITabBar.class]) {
                    UITabBar *tabBar = (UITabBar *)selfObject.superview.superview;
                    if (tabBar.qmui_effectView == selfObject) {
                        if (tabBar.qmuitb_hasSetEffect) {
                            firstArgv = tabBar.qmuitb_backgroundEffects;
                        }
                    }
                }
                
                // call super
                void (*originSelectorIMP)(id, SEL, NSArray<UIVisualEffect *> *);
                originSelectorIMP = (void (*)(id, SEL, NSArray<UIVisualEffect *> *))originalIMPProvider();
                originSelectorIMP(selfObject, originCMD, firstArgv);
            };
        });
    } oncePerIdentifier:@"UITabBar (QMUI) effect"];
}

- (void)qmuitb_updateEffect {
    if (self.qmuitb_hasSetEffect) {
        // 这里对 iOS 13 不使用 UITabBarAppearance.backgroundEffect 来修改，是因为反正不管 iOS 10 还是 13，最终都是 setBackgroundEffects: 在起作用，而且不用 UITabBarAppearance 还可以规避与 UIAppearance 机制的冲突
        NSArray<UIVisualEffect *> *effects = self.qmuitb_backgroundEffects;
        [self.qmui_effectView qmui_performSelector:NSSelectorFromString(@"setBackgroundEffects:") withArguments:&effects, nil];
    }
    if (self.qmuitb_hasSetEffectForegroundColor) {
        self.qmui_effectView.qmui_foregroundColor = self.qmui_effectForegroundColor;
    }
}

// UITabBar、UIVisualEffectView  都有一个私有的方法 backgroundEffects，当 UIVisualEffectView 应用于 UITabBar 场景时，磨砂的效果实际上被放在 backgroundEffects 内，而不是公开接口的 effect 属性里，这里为了方便，将 UITabBar (QMUI).effect 转成可用于 backgroundEffects 的数组
- (NSArray<UIVisualEffect *> *)qmuitb_backgroundEffects {
    if (self.qmuitb_hasSetEffect) {
        return self.qmui_effect ? @[self.qmui_effect] : nil;
    }
    return nil;
}

static char kAssociatedObjectKey_effect;
- (void)setQmui_effect:(UIBlurEffect *)qmui_effect {
    if (qmui_effect) {
        [self qmuitb_swizzleBackgroundView];
    }
    
    BOOL valueChanged = self.qmui_effect != qmui_effect;
    objc_setAssociatedObject(self, &kAssociatedObjectKey_effect, qmui_effect, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    if (valueChanged) {
        self.qmuitb_hasSetEffect = YES;// QMUITheme 切换时会重新赋值，所以可能出现本来就是 nil，还给它又赋值了 nil，这种场景不应该导致 hasSet 标志位改变，所以要把标志位的设置放在 if (valueChanged) 里
        [self qmuitb_updateEffect];
    }
}

- (UIBlurEffect *)qmui_effect {
    return (UIBlurEffect *)objc_getAssociatedObject(self, &kAssociatedObjectKey_effect);
}

static char kAssociatedObjectKey_effectForegroundColor;
- (void)setQmui_effectForegroundColor:(UIColor *)qmui_effectForegroundColor {
    if (qmui_effectForegroundColor) {
        [self qmuitb_swizzleBackgroundView];
    }
    BOOL valueChanged = ![self.qmui_effectForegroundColor isEqual:qmui_effectForegroundColor];
    objc_setAssociatedObject(self, &kAssociatedObjectKey_effectForegroundColor, qmui_effectForegroundColor, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    if (valueChanged) {
        self.qmuitb_hasSetEffectForegroundColor = YES;// QMUITheme 切换时会重新赋值，所以可能出现本来就是 nil，还给它又赋值了 nil，这种场景不应该导致 hasSet 标志位改变，所以要把标志位的设置放在 if (valueChanged) 里
        [self qmuitb_updateEffect];
    }
}

- (UIColor *)qmui_effectForegroundColor {
    return (UIColor *)objc_getAssociatedObject(self, &kAssociatedObjectKey_effectForegroundColor);
}

@end

@implementation UITabBarAppearance (QMUI)

- (void)qmui_applyItemAppearanceWithBlock:(void (^)(UITabBarItemAppearance * _Nonnull))block {
    block(self.stackedLayoutAppearance);
    block(self.inlineLayoutAppearance);
    block(self.compactInlineLayoutAppearance);
}

@end
