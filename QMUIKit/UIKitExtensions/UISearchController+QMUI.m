/**
 * Tencent is pleased to support the open source community by making QMUI_iOS available.
 * Copyright (C) 2016-2021 THL A29 Limited, a Tencent company. All rights reserved.
 * Licensed under the MIT License (the "License"); you may not use this file except in compliance with the License. You may obtain a copy of the License at
 * http://opensource.org/licenses/MIT
 * Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.
 */
//
//  UISearchController+QMUI.m
//  QMUIKit
//
//  Created by ziezheng on 2019/9/27.
//

#import "UISearchController+QMUI.h"
#import "QMUICore.h"
#import "UIViewController+QMUI.h"
#import "UINavigationController+QMUI.h"
#import "UIView+QMUI.h"
#import "NSArray+QMUI.h"

@implementation UISearchController (QMUI)

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        // -[_UISearchControllerView didMoveToWindow]
        // 修复 https://github.com/Tencent/QMUI_iOS/issues/680 中提到的问题二：当有一个 TableViewController A，A 的 seachBar 被激活且 searchResultsController 正在显示的情况下，A.navigationController push 一个新的 viewController B，B 用 pop 手势返回到一半松手放弃返回，此时 B 再 push 一个新的 viewController 时，在转场过程中会看到 searchResultsController 的内容。
        OverrideImplementation(NSClassFromString(@"_UISearchControllerView"), @selector(didMoveToWindow), ^id(__unsafe_unretained Class originClass, SEL originCMD, IMP (^originalIMPProvider)(void)) {
            return ^(UIView *selfObject) {
                void (*originSelectorIMP)(id, SEL);
                originSelectorIMP = (void (*)(id, SEL))originalIMPProvider();
                originSelectorIMP(selfObject, originCMD);
                
                if (selfObject.window && [selfObject.superview isKindOfClass:NSClassFromString(@"UITransitionView")]) {
                    UIView *transitionView = selfObject.superview;
                    UISearchController *searchController = [selfObject qmui_viewController];
                    UIViewController *sourceViewController = [searchController valueForKey:@"_modalSourceViewController"];
                    UINavigationController *navigationController = sourceViewController.navigationController;
                    if (navigationController.qmui_isPushing) {
                        BOOL isFromPreviousViewController = [sourceViewController qmui_isDescendantOfViewController:navigationController.topViewController.qmui_previousViewController];
                        if (!isFromPreviousViewController) {
                            // 系统内部错误地添加了这个 view，这里直接 remove 掉，系统内部在真正要显示的时候再次添加回来。
                            [transitionView removeFromSuperview];
                        }
                    }
                }
                
            };
        });
        
        // - [UISearchController viewDidLayoutSubviews]
        OverrideImplementation([UISearchController class], @selector(viewDidLayoutSubviews), ^id(__unsafe_unretained Class originClass, SEL originCMD, IMP (^originalIMPProvider)(void)) {
            return ^(UISearchController *selfObject) {
                
                // call super
                void (*originSelectorIMP)(id, SEL);
                originSelectorIMP = (void (*)(id, SEL))originalIMPProvider();
                originSelectorIMP(selfObject, originCMD);
                
                // 某些场景（比如 setActive:YES animated:NO）会在 _UISearchBarContainerView 被添加到 view 上之后调用 -[UISearchController viewDidLayoutSubviews] 但不会调用 -[searchResultsController viewDidLayoutSubviews]，导致搜索结果界面里如果使用 qmui_searchBarMaxY 等依赖于 _UISearchBarContainerView 的方法时就会得到错误结果，所以这里每次都主动刷新搜索结果界面的布局。
                if (selfObject.searchResultsController.isViewLoaded && selfObject.searchResultsController.view.superview.superview == selfObject.view) {
                    [selfObject.searchResultsController.view setNeedsLayout];
                }
                
                if (selfObject.qmui_launchView) {
                    [UIView animateWithDuration:[CATransaction animationDuration] animations:^{
                        [selfObject qmuisc_layoutLaunchViewIfNeeded];
                    }];
                }
            };
        });
    });
}

static char kAssociatedObjectKey_alwaysShowSearchResultsController;
- (void)setQmui_alwaysShowSearchResultsController:(BOOL)qmui_alwaysShowSearchResultsController {
    BOOL hasSet = !!objc_getAssociatedObject(self, &kAssociatedObjectKey_alwaysShowSearchResultsController);
    objc_setAssociatedObject(self, &kAssociatedObjectKey_alwaysShowSearchResultsController, @(qmui_alwaysShowSearchResultsController), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    if (qmui_alwaysShowSearchResultsController) {
        self.qmui_launchView = nil;
        self.obscuresBackgroundDuringPresentation = NO;
    } else if (hasSet) {
        // 用变量 hasSet 表示用过 qmui_alwaysShowSearchResultsController 属性再关回去时才需要重置，否则就不用干预
        self.obscuresBackgroundDuringPresentation = YES;
        return;
    }
    [QMUIHelper executeBlock:^{
        // - [UISearchController _updateVisibilityOfSearchResultsForSearchBar:]
        // - (void) _updateVisibilityOfSearchResultsForSearchBar:(id)arg1;
        OverrideImplementation([UISearchController class], NSSelectorFromString([NSString qmui_stringByConcat:@"_", @"updateVisibility", @"OfSearchResults", @"ForSearchBar:", nil]), ^id(__unsafe_unretained Class originClass, SEL originCMD, IMP (^originalIMPProvider)(void)) {
            return ^(UISearchController *selfObject, UISearchBar *searchBar) {
                
                // call super
                void (*originSelectorIMP)(id, SEL, UISearchBar *);
                originSelectorIMP = (void (*)(id, SEL, UISearchBar *))originalIMPProvider();
                originSelectorIMP(selfObject, originCMD, searchBar);
                
                if (selfObject.qmui_alwaysShowSearchResultsController) {
                    selfObject.searchResultsController.view.hidden = NO;
                }
            };
        });
    } oncePerIdentifier:@"UISearchController (QMUI) alwaysShowResults"];
}

- (BOOL)qmui_alwaysShowSearchResultsController {
    return [((NSNumber *)objc_getAssociatedObject(self, &kAssociatedObjectKey_alwaysShowSearchResultsController)) boolValue];
}

static char kAssociatedObjectKey_forwardAppearance;
- (void)setQmui_forwardAppearanceMethodsFromPresentingController:(BOOL)qmui_forwardAppearanceMethodsFromPresentingController {
    objc_setAssociatedObject(self, &kAssociatedObjectKey_forwardAppearance, @(qmui_forwardAppearanceMethodsFromPresentingController), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    if (qmui_forwardAppearanceMethodsFromPresentingController) {
        [QMUIHelper executeBlock:^{
            OverrideImplementation([UIViewController class], @selector(viewWillAppear:), ^id(__unsafe_unretained Class originClass, SEL originCMD, IMP (^originalIMPProvider)(void)) {
                return ^(UISearchController *selfObject, BOOL firstArgv) {
                    
                    // call super
                    void (*originSelectorIMP)(id, SEL, BOOL);
                    originSelectorIMP = (void (*)(id, SEL, BOOL))originalIMPProvider();
                    originSelectorIMP(selfObject, originCMD, firstArgv);
                    
                    UISearchController *searchController = [selfObject.presentedViewController isKindOfClass:UISearchController.class] ? (UISearchController *)selfObject.presentedViewController : nil;
                    if (searchController && searchController.qmui_forwardAppearanceMethodsFromPresentingController && searchController.active) {
                        [searchController beginAppearanceTransition:YES animated:firstArgv];
                    }
                };
            });
            
            OverrideImplementation([UIViewController class], @selector(viewDidAppear:), ^id(__unsafe_unretained Class originClass, SEL originCMD, IMP (^originalIMPProvider)(void)) {
                return ^(UISearchController *selfObject, BOOL firstArgv) {
                    
                    // call super
                    void (*originSelectorIMP)(id, SEL, BOOL);
                    originSelectorIMP = (void (*)(id, SEL, BOOL))originalIMPProvider();
                    originSelectorIMP(selfObject, originCMD, firstArgv);
                    
                    UISearchController *searchController = [selfObject.presentedViewController isKindOfClass:UISearchController.class] ? (UISearchController *)selfObject.presentedViewController : nil;
                    if (searchController && searchController.qmui_forwardAppearanceMethodsFromPresentingController && searchController.active) {
                        [searchController endAppearanceTransition];
                    }
                };
            });
            
            OverrideImplementation([UIViewController class], @selector(viewWillDisappear:), ^id(__unsafe_unretained Class originClass, SEL originCMD, IMP (^originalIMPProvider)(void)) {
                return ^(UISearchController *selfObject, BOOL firstArgv) {
                    
                    // call super
                    void (*originSelectorIMP)(id, SEL, BOOL);
                    originSelectorIMP = (void (*)(id, SEL, BOOL))originalIMPProvider();
                    originSelectorIMP(selfObject, originCMD, firstArgv);
                    
                    UISearchController *searchController = [selfObject.presentedViewController isKindOfClass:UISearchController.class] ? (UISearchController *)selfObject.presentedViewController : nil;
                    if (searchController && searchController.qmui_forwardAppearanceMethodsFromPresentingController && searchController.active) {
                        [searchController beginAppearanceTransition:NO animated:firstArgv];
                    }
                };
            });
            
            OverrideImplementation([UIViewController class], @selector(viewDidDisappear:), ^id(__unsafe_unretained Class originClass, SEL originCMD, IMP (^originalIMPProvider)(void)) {
                return ^(UISearchController *selfObject, BOOL firstArgv) {
                    
                    // call super
                    void (*originSelectorIMP)(id, SEL, BOOL);
                    originSelectorIMP = (void (*)(id, SEL, BOOL))originalIMPProvider();
                    originSelectorIMP(selfObject, originCMD, firstArgv);
                    
                    UISearchController *searchController = [selfObject.presentedViewController isKindOfClass:UISearchController.class] ? (UISearchController *)selfObject.presentedViewController : nil;
                    if (searchController && searchController.qmui_forwardAppearanceMethodsFromPresentingController && searchController.active) {
                        [searchController endAppearanceTransition];
                    }
                };
            });
        } oncePerIdentifier:@"UISearchController (QMUI) forwardAppearance"];
    }
}

- (BOOL)qmui_forwardAppearanceMethodsFromPresentingController {
    return [((NSNumber *)objc_getAssociatedObject(self, &kAssociatedObjectKey_forwardAppearance)) boolValue];
}

- (CGFloat)qmui_searchBarMaxY {
    if (!self.viewLoaded) return 0;
    
    UIView *searchBarContainerView = [self.view.subviews qmui_firstMatchWithBlock:^BOOL(__kindof UIView * _Nonnull subview) {
        return [NSStringFromClass(subview.class) isEqualToString:@"_UISearchBarContainerView"];
    }];
    CGFloat maxY = searchBarContainerView ? CGRectGetMaxY(searchBarContainerView.frame) : 0;
    return maxY;
}

static char kAssociatedObjectKey_dimmingColor;
- (void)setQmui_dimmingColor:(UIColor *)qmui_dimmingColor {
    objc_setAssociatedObject(self, &kAssociatedObjectKey_dimmingColor, qmui_dimmingColor, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    [QMUIHelper executeBlock:^{
        // - [UIDimmingView updateBackgroundColor]
        OverrideImplementation(NSClassFromString([NSString qmui_stringByConcat:@"UI", @"Dimming", @"View", nil]), NSSelectorFromString([NSString qmui_stringByConcat:@"update", @"Background", @"Color", nil]), ^id(__unsafe_unretained Class originClass, SEL originCMD, IMP (^originalIMPProvider)(void)) {
            return ^(UIView *selfObject) {
                for (UIView *subview in selfObject.superview.subviews) {
                    // _UISearchControllerView
                    if ([NSStringFromClass(subview.class) isEqualToString:[NSString qmui_stringByConcat:@"_", @"UISearchController", @"View", nil]]) {
                        UISearchController *searchController = subview.qmui_viewController;
                        if ([searchController isKindOfClass:UISearchController.class]) {
                            UIColor *color = searchController.qmui_dimmingColor;
                            if (color) {
                                // - [UIDimmingView setDimmingColor:]
                                [selfObject qmui_performSelector:NSSelectorFromString(@"setDimmingColor:") withArguments:&color, nil];
                            }
                        } else {
                            QMUIAssert(NO, @"UISearchController (QMUI)", @"qmui_dimmingColor 找到的 vc 类型错误");
                        }
                        break;
                    }
                }
                
                // call super
                void (*originSelectorIMP)(id, SEL);
                originSelectorIMP = (void (*)(id, SEL))originalIMPProvider();
                originSelectorIMP(selfObject, originCMD);
            };
        });
    } oncePerIdentifier:@"QMUISearchController dimmingColor"];
}

- (UIColor *)qmui_dimmingColor {
    return (UIColor *)objc_getAssociatedObject(self, &kAssociatedObjectKey_dimmingColor);
}

static char kAssociatedObjectKey_launchView;
- (void)setQmui_launchView:(UIView *)qmui_launchView {
    if (self.qmui_launchView != qmui_launchView) {
        [self.qmui_launchView removeFromSuperview];
    }
    objc_setAssociatedObject(self, &kAssociatedObjectKey_launchView, qmui_launchView, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    
    if (qmui_launchView) {
        [QMUIHelper executeBlock:^{
            // - [UISearchController viewWillAppear:]
            OverrideImplementation([UISearchController class], @selector(viewWillAppear:), ^id(__unsafe_unretained Class originClass, SEL originCMD, IMP (^originalIMPProvider)(void)) {
                return ^(UISearchController *selfObject, BOOL firstArgv) {
                    
                    // call super
                    void (*originSelectorIMP)(id, SEL, BOOL);
                    originSelectorIMP = (void (*)(id, SEL, BOOL))originalIMPProvider();
                    originSelectorIMP(selfObject, originCMD, firstArgv);
                    
                    [selfObject qmuisc_addLaunchViewIfNeeded];
                };
            });
        } oncePerIdentifier:@"UISearchController (QMUI) launchView"];
    }
    
    self.obscuresBackgroundDuringPresentation = !qmui_launchView;
    if (self.viewLoaded) {
        [self qmuisc_addLaunchViewIfNeeded];
    }
}

- (UIView *)qmui_launchView {
    return (UIView *)objc_getAssociatedObject(self, &kAssociatedObjectKey_launchView);
}

- (void)qmuisc_addLaunchViewIfNeeded {
    if (!self.qmui_launchView) return;
    UIView *superviewOfLaunchView = self.searchResultsController.view.superview;
    if (self.qmui_launchView.superview != superviewOfLaunchView) {
        [superviewOfLaunchView insertSubview:self.qmui_launchView atIndex:0];
        [self qmuisc_layoutLaunchViewIfNeeded];
    }
}

- (void)qmuisc_layoutLaunchViewIfNeeded {
    if (!self.qmui_launchView || !self.viewLoaded) return;
    self.qmui_launchView.frame = CGRectInsetEdges(self.qmui_launchView.superview.bounds, UIEdgeInsetsMake(self.qmui_searchBarMaxY, 0, 0, 0));
}

@end
