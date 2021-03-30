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
        
        // iOS 10 及以下，如果 UINavigationBar backgroundImage 为 nil，则 navigationBar 会显示磨砂背景，此时不管怎么修改 shadowImage 都无效，都会显示系统默认的分隔线，导致无法很好地统一不同 iOS 版本的表现（iOS 11 及以上没有这个限制），所以这里做了兼容。
        if (@available(iOS 11.0, *)) {
        } else {
            ExtendImplementationOfVoidMethodWithoutArguments([UINavigationBar class], NSSelectorFromString(@"_updateBackgroundView"), ^(UINavigationBar *selfObject) {
                UIImage *shadowImage = selfObject.shadowImage;// 就算 navigationBar 显示系统的分隔线，但依然能从 shadowImage 属性获取到业务自己设置的图片
                UIImageView *shadowImageView = selfObject.qmui_shadowImageView;
                if (shadowImage && shadowImageView && shadowImageView.backgroundColor && !shadowImageView.image) {
                    shadowImageView.backgroundColor = nil;
                    shadowImageView.image = shadowImage;
                }
            });
        }
        
        
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
    });
}

- (UIView *)qmui_contentView {
    return [self valueForKeyPath:@"visualProvider.contentView"];
}

- (UIView *)qmui_backgroundView {
    return [self qmui_valueForKey:@"_backgroundView"];
}

- (__kindof UIView *)qmui_backgroundContentView {
    if (@available(iOS 13, *)) {
        return [self.qmui_backgroundView qmui_valueForKey:@"_colorAndImageView1"];
    } else {
        UIImageView *imageView = [self.qmui_backgroundView qmui_valueForKey:@"_backgroundImageView"];
        UIVisualEffectView *visualEffectView = [self.qmui_backgroundView qmui_valueForKey:@"_backgroundEffectView"];
        UIView *customView = [self.qmui_backgroundView qmui_valueForKey:@"_customBackgroundView"];
        UIView *result = customView && customView.superview ? customView : (imageView && imageView.superview ? imageView : visualEffectView);
        return result;
    }
}

- (UIImageView *)qmui_shadowImageView {
    // UINavigationBar 在 init 完就可以获取到 backgroundView 和 shadowView，无需关心调用时机的问题
    if (@available(iOS 13, *)) {
        return [self.qmui_backgroundView qmui_valueForKey:@"_shadowView1"];
    }
    return [self.qmui_backgroundView qmui_valueForKey:@"_shadowView"];
}

@end
