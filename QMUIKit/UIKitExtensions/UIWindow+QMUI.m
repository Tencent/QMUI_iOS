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
