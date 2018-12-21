/*****
 * Tencent is pleased to support the open source community by making QMUI_iOS available.
 * Copyright (C) 2016-2018 THL A29 Limited, a Tencent company. All rights reserved.
 * Licensed under the MIT License (the "License"); you may not use this file except in compliance with the License. You may obtain a copy of the License at
 * http://opensource.org/licenses/MIT
 * Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.
 *****/

//
//  UIWindow+QMUI.m
//  qmui
//
//  Created by QMUI Team on 16/7/21.
//

#import "UIWindow+QMUI.h"
#import "QMUICore.h"

const CGPoint kUnCapturesStatusBarAppearanceWindowOrigin = {-1, -1};

@interface UIWindow ()

@property(nonatomic, assign) BOOL qmuiWindow_didInitialize;
@end

@implementation UIWindow (QMUI)

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        SEL selectors[] = {
            @selector(init),
            @selector(initWithFrame:),
            @selector(setFrame:),
        };
        for (NSUInteger index = 0; index < sizeof(selectors) / sizeof(SEL); index++) {
            SEL originalSelector = selectors[index];
            SEL swizzledSelector = NSSelectorFromString([@"qmuiWindow_" stringByAppendingString:NSStringFromSelector(originalSelector)]);
            ExchangeImplementations([self class], originalSelector, swizzledSelector);
        }
    });
}

- (CGRect)fullSizeWindowReferenceRect {
    if (UIApplication.sharedApplication.delegate.window) {
        return UIApplication.sharedApplication.delegate.window.frame;
    }
    return UIScreen.mainScreen.bounds;
}

- (instancetype)qmuiWindow_init {
    if (@available(iOS 9.0, *)) {
        [self qmuiWindow_init];
        return self;
    } else {
        // iOS 9 以前的版本，UIWindow init时如果不给一个frame，默认是CGRectZero，而iOS 9以后的版本，由于增加了分屏（Split View）功能，你的App可能运行在一个非全屏大小的区域内，所以UIWindow如果调用init方法（而不是initWithFrame:）来初始化，系统会自动为你的window设置一个合适的大小。所以这里对iOS 9以前的版本做适配，默认与 UIApplication.delegate.window 一样大
        UIWindow *window = [self qmuiWindow_init];
        window.frame = [self fullSizeWindowReferenceRect];
        return window;
    }
}

- (instancetype)qmuiWindow_initWithFrame:(CGRect)frame {
    [self qmuiWindow_initWithFrame:frame];
    if (@available(iOS 10, *)) {
        self.qmui_capturesStatusBarAppearance = YES;
    }
    self.qmuiWindow_didInitialize = YES;
    return self;
}

- (void)qmuiWindow_setFrame:(CGRect)frame {
    if (!UIApplication.sharedApplication.delegate.window) {
        [self qmuiWindow_setFrame:frame];
        return;
    }
    
    if (@available(iOS 10, *)) {
        if (self.qmuiWindow_didInitialize && !self.qmui_capturesStatusBarAppearance) {
            if (CGRectEqualToRect(frame, UIApplication.sharedApplication.delegate.window.frame)) {
                frame = CGRectInset(frame, kUnCapturesStatusBarAppearanceWindowOrigin.x, kUnCapturesStatusBarAppearanceWindowOrigin.y);
            }
        }
    }
    [self qmuiWindow_setFrame:frame];
}

static char kAssociatedObjectKey_capturesStatusBarAppearance;
- (void)setQmui_capturesStatusBarAppearance:(BOOL)qmui_capturesStatusBarAppearance {
    if (UIApplication.sharedApplication.delegate.window && self == UIApplication.sharedApplication.delegate.window) {
        return;
    }
    
    BOOL valueChanged = self.qmui_capturesStatusBarAppearance != qmui_capturesStatusBarAppearance;
    
    objc_setAssociatedObject(self, &kAssociatedObjectKey_capturesStatusBarAppearance, @(qmui_capturesStatusBarAppearance), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    
    if (!self.qmuiWindow_didInitialize) {
        return;
    }
    
    if (valueChanged && qmui_capturesStatusBarAppearance && CGPointEqualToPoint(self.frame.origin, kUnCapturesStatusBarAppearanceWindowOrigin) && CGSizeEqualToSize(self.frame.size, UIScreen.mainScreen.bounds.size)) {
        self.frame = UIScreen.mainScreen.bounds;
    } else if (!qmui_capturesStatusBarAppearance && CGRectEqualToRect(self.frame, UIScreen.mainScreen.bounds)) {
        self.frame = CGRectInset(self.frame, kUnCapturesStatusBarAppearanceWindowOrigin.x, kUnCapturesStatusBarAppearanceWindowOrigin.y);
    }
}

- (BOOL)qmui_capturesStatusBarAppearance {
    return [((NSNumber *)objc_getAssociatedObject(self, &kAssociatedObjectKey_capturesStatusBarAppearance)) boolValue];
}

static char kAssociatedObjectKey_didInitialize;
- (void)setQmuiWindow_didInitialize:(BOOL)qmuiWindow_didInitialize {
    objc_setAssociatedObject(self, &kAssociatedObjectKey_didInitialize, @(qmuiWindow_didInitialize), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (BOOL)qmuiWindow_didInitialize {
    return [((NSNumber *)objc_getAssociatedObject(self, &kAssociatedObjectKey_didInitialize)) boolValue];
}

@end
