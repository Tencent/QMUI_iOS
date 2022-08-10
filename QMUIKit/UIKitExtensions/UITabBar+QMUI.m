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
                
                if (UIApplication.sharedApplication.qmui_didFinishLaunching) {
                    if (QMUICMIActivated && ShouldFixTabBarTransitionBugInIPhoneX && IOS_VERSION < 11.2 && IS_58INCH_SCREEN) {
                        if (CGRectGetHeight(frame) == TabBarHeight && CGRectGetMaxY(frame) < CGRectGetHeight(selfObject.superview.bounds)) {
                            // iOS 11 在界面 push 的过程中 tabBar 会瞬间往上跳，所以做这个修复。这个 bug 在 iOS 11.2 里已被系统修复。
                            // https://github.com/Tencent/QMUI_iOS/issues/217
                            frame = CGRectSetY(frame, CGRectGetHeight(selfObject.superview.bounds) - CGRectGetHeight(frame));
                        }
                    }
                    
                    // [UIKit Bug] iOS 11-12，opaque 的 tabBar 在某些情况下会高度塌陷
                    // https://github.com/Tencent/QMUI_iOS/issues/309
                    // [UIKit Bug] iOS 11-12，全面屏设备下，带 TabBar 的界面在 push/pop 后，UIScrollView 的滚动位置可能发生变化
                    // https://github.com/Tencent/QMUI_iOS/issues/934
                    if (@available(iOS 13.0, *)) {
                    } else if (IS_NOTCHED_SCREEN && ((CGRectGetHeight(frame) == 49 || CGRectGetHeight(frame) == 32))) {// 只关注全面屏设备下的这两种非正常的 tabBar 高度即可
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
        
        if (@available(iOS 13.0, *)) {
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
        }
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
