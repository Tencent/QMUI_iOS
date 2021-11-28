/**
 * Tencent is pleased to support the open source community by making QMUI_iOS available.
 * Copyright (C) 2016-2021 THL A29 Limited, a Tencent company. All rights reserved.
 * Licensed under the MIT License (the "License"); you may not use this file except in compliance with the License. You may obtain a copy of the License at
 * http://opensource.org/licenses/MIT
 * Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.
 */

//
//  UIBarItem+QMUI.m
//  QMUIKit
//
//  Created by QMUI Team on 2018/4/5.
//

#import "UIBarItem+QMUI.h"
#import "QMUICore.h"
#import "UIView+QMUI.h"

@interface UIBarItem ()

@property(nonatomic, copy) NSString *qmuibaritem_viewDidSetBlockIdentifier;
@end

@implementation UIBarItem (QMUI)

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        // UIBarButtonItem -setView:
        // @warning 如果作为 UIToolbar.items 使用，则 customView 的情况下，iOS 10 及以下的版本不会调用 setView:，所以那种情况改为在 setToolbarItems:animated: 时调用，代码见下方
        ExtendImplementationOfVoidMethodWithSingleArgument([UIBarButtonItem class], @selector(setView:), UIView *, ^(UIBarButtonItem *selfObject, UIView *firstArgv) {
            [UIBarItem setView:firstArgv inBarButtonItem:selfObject];
        });
        
        // UITabBarItem -setView:
        ExtendImplementationOfVoidMethodWithSingleArgument([UITabBarItem class], @selector(setView:), UIView *, ^(UITabBarItem *selfObject, UIView *firstArgv) {
            [UIBarItem setView:firstArgv inBarItem:selfObject];
        });
    });
}

- (UIView *)qmui_view {
    // UIBarItem 本身没有 view 属性，只有子类 UIBarButtonItem 和 UITabBarItem 才有
    if ([self respondsToSelector:@selector(view)]) {
        return [self qmui_valueForKey:@"view"];
    }
    return nil;
}

QMUISynthesizeIdCopyProperty(qmuibaritem_viewDidSetBlockIdentifier, setQmuibaritem_viewDidSetBlockIdentifier)
QMUISynthesizeIdCopyProperty(qmui_viewDidSetBlock, setQmui_viewDidSetBlock)

static char kAssociatedObjectKey_viewDidLayoutSubviewsBlock;
- (void)setQmui_viewDidLayoutSubviewsBlock:(void (^)(__kindof UIBarItem * _Nonnull, UIView * _Nullable))qmui_viewDidLayoutSubviewsBlock {
    objc_setAssociatedObject(self, &kAssociatedObjectKey_viewDidLayoutSubviewsBlock, qmui_viewDidLayoutSubviewsBlock, OBJC_ASSOCIATION_COPY_NONATOMIC);
    if (self.qmui_view) {
        __weak __typeof(self)weakSelf = self;
        self.qmui_view.qmui_layoutSubviewsBlock = ^(__kindof UIView * _Nonnull view) {
            if (weakSelf.qmui_viewDidLayoutSubviewsBlock) {
                weakSelf.qmui_viewDidLayoutSubviewsBlock(weakSelf, view);
            }
        };
    }
}

- (void (^)(__kindof UIBarItem * _Nonnull, UIView * _Nullable))qmui_viewDidLayoutSubviewsBlock {
    return (void (^)(__kindof UIBarItem * _Nonnull, UIView * _Nullable))objc_getAssociatedObject(self, &kAssociatedObjectKey_viewDidLayoutSubviewsBlock);
}

static char kAssociatedObjectKey_viewLayoutDidChangeBlock;
- (void)setQmui_viewLayoutDidChangeBlock:(void (^)(__kindof UIBarItem * _Nonnull, UIView * _Nullable))qmui_viewLayoutDidChangeBlock {
    objc_setAssociatedObject(self, &kAssociatedObjectKey_viewLayoutDidChangeBlock, qmui_viewLayoutDidChangeBlock, OBJC_ASSOCIATION_COPY_NONATOMIC);
    // 这里有个骚操作，对于 iOS 11 及以上，item.view 被放在一个 UIStackView 内，而当屏幕旋转时，通过 item.view.qmui_frameDidChangeBlock 得到的时机过早，布局尚未被更新，所以把 qmui_frameDidChangeBlock 放到 stackView 上以保证时机的准确性，但当调用 qmui_viewLayoutDidChangeBlock 时传进去的参数 view 依然要是 item.view
    UIView *view = self.qmui_view;
    if ([view.superview isKindOfClass:[UIStackView class]]) {
        view = self.qmui_view.superview;
    }
    if (view) {
        __weak __typeof(self)weakSelf = self;
        view.qmui_frameDidChangeBlock = ^(__kindof UIView * _Nonnull view, CGRect precedingFrame) {
            if (weakSelf.qmui_viewLayoutDidChangeBlock){
                weakSelf.qmui_viewLayoutDidChangeBlock(weakSelf, weakSelf.qmui_view);
            }
        };
    }
}

- (void (^)(__kindof UIBarItem * _Nonnull, UIView * _Nullable))qmui_viewLayoutDidChangeBlock {
    return (void (^)(__kindof UIBarItem * _Nonnull, UIView * _Nullable))objc_getAssociatedObject(self, &kAssociatedObjectKey_viewLayoutDidChangeBlock);
}

#pragma mark - Tools

+ (NSString *)identifierWithView:(UIView *)view block:(id)block {
    return [NSString stringWithFormat:@"%p, %p", view, block];
}

+ (void)setView:(UIView *)view inBarItem:(__kindof UIBarItem *)item {
    if (item.qmui_viewDidSetBlock) {
        item.qmui_viewDidSetBlock(item, view);
    }
    
    if (item.qmui_viewDidLayoutSubviewsBlock) {
        item.qmui_viewDidLayoutSubviewsBlock = item.qmui_viewDidLayoutSubviewsBlock;// to call setter
    }
    
    if (item.qmui_viewLayoutDidChangeBlock) {
        item.qmui_viewLayoutDidChangeBlock = item.qmui_viewLayoutDidChangeBlock;// to call setter
    }
}

+ (void)setView:(UIView *)view inBarButtonItem:(UIBarButtonItem *)item {
    if (![[UIBarItem identifierWithView:view block:item.qmui_viewDidSetBlock] isEqualToString:item.qmuibaritem_viewDidSetBlockIdentifier]) {
        item.qmuibaritem_viewDidSetBlockIdentifier = [UIBarItem identifierWithView:view block:item.qmui_viewDidSetBlock];
        
        [self setView:view inBarItem:item];
    }
}

@end
