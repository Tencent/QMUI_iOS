/**
 * Tencent is pleased to support the open source community by making QMUI_iOS available.
 * Copyright (C) 2016-2020 THL A29 Limited, a Tencent company. All rights reserved.
 * Licensed under the MIT License (the "License"); you may not use this file except in compliance with the License. You may obtain a copy of the License at
 * http://opensource.org/licenses/MIT
 * Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.
 */

//
//  UIScrollView+QMUI.m
//  qmui
//
//  Created by QMUI Team on 15/7/20.
//

#import "UIScrollView+QMUI.h"
#import "QMUICore.h"
#import "NSNumber+QMUI.h"
#import "UIView+QMUI.h"
#import "UIViewController+QMUI.h"

@interface UIScrollView ()

@property(nonatomic, assign) CGFloat qmuiscroll_lastInsetTopWhenScrollToTop;
@property(nonatomic, assign) BOOL qmuiscroll_hasSetInitialContentInset;
@end

@implementation UIScrollView (QMUI)

QMUISynthesizeCGFloatProperty(qmuiscroll_lastInsetTopWhenScrollToTop, setQmuiscroll_lastInsetTopWhenScrollToTop)
QMUISynthesizeBOOLProperty(qmuiscroll_hasSetInitialContentInset, setQmuiscroll_hasSetInitialContentInset)

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        ExtendImplementationOfNonVoidMethodWithoutArguments([UIScrollView class], @selector(description), NSString *, ^NSString *(UIScrollView *selfObject, NSString *originReturnValue) {
            originReturnValue = ([NSString stringWithFormat:@"%@, contentInset = %@", originReturnValue, NSStringFromUIEdgeInsets(selfObject.contentInset)]);
            if (@available(iOS 13.0, *)) {
                return originReturnValue.mutableCopy;
            }
            return originReturnValue;
        });
#ifdef IOS13_SDK_ALLOWED
        if (@available(iOS 13.0, *)) {
            if (QMUICMIActivated && AdjustScrollIndicatorInsetsByContentInsetAdjustment) {
                OverrideImplementation([UIScrollView class], @selector(setContentInsetAdjustmentBehavior:), ^id(__unsafe_unretained Class originClass, SEL originCMD, IMP (^originalIMPProvider)(void)) {
                    return ^(UIScrollView *selfObject, UIScrollViewContentInsetAdjustmentBehavior firstArgv) {
                        
                        // call super
                        void (*originSelectorIMP)(id, SEL, UIScrollViewContentInsetAdjustmentBehavior);
                        originSelectorIMP = (void (*)(id, SEL, UIScrollViewContentInsetAdjustmentBehavior))originalIMPProvider();
                        originSelectorIMP(selfObject, originCMD, firstArgv);
                        
                        if (firstArgv == UIScrollViewContentInsetAdjustmentNever) {
                            selfObject.automaticallyAdjustsScrollIndicatorInsets = NO;
                        } else {
                            selfObject.automaticallyAdjustsScrollIndicatorInsets = YES;
                        }
                    };
                });
            }
        }
#endif
    });
}

- (BOOL)qmui_alreadyAtTop {
    if (((NSInteger)self.contentOffset.y) == -((NSInteger)self.qmui_contentInset.top)) {
        return YES;
    }
    
    return NO;
}

- (BOOL)qmui_alreadyAtBottom {
    if (!self.qmui_canScroll) {
        return YES;
    }
    
    if (((NSInteger)self.contentOffset.y) == ((NSInteger)self.contentSize.height + self.qmui_contentInset.bottom - CGRectGetHeight(self.bounds))) {
        return YES;
    }
    
    return NO;
}

- (UIEdgeInsets)qmui_contentInset {
    if (@available(iOS 11, *)) {
        return self.adjustedContentInset;
    } else {
        return self.contentInset;
    }
}

static char kAssociatedObjectKey_initialContentInset;
- (void)setQmui_initialContentInset:(UIEdgeInsets)qmui_initialContentInset {
    objc_setAssociatedObject(self, &kAssociatedObjectKey_initialContentInset, [NSValue valueWithUIEdgeInsets:qmui_initialContentInset], OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    self.contentInset = qmui_initialContentInset;
    self.scrollIndicatorInsets = qmui_initialContentInset;
    if (!self.qmuiscroll_hasSetInitialContentInset || !self.qmui_viewController || self.qmui_viewController.qmui_visibleState < QMUIViewControllerDidAppear) {
        [self qmui_scrollToTopUponContentInsetTopChange];
    }
    self.qmuiscroll_hasSetInitialContentInset = YES;
}

- (UIEdgeInsets)qmui_initialContentInset {
    return [((NSValue *)objc_getAssociatedObject(self, &kAssociatedObjectKey_initialContentInset)) UIEdgeInsetsValue];
}

- (BOOL)qmui_canScroll {
    // 没有高度就不用算了，肯定不可滚动，这里只是做个保护
    if (CGSizeIsEmpty(self.bounds.size)) {
        return NO;
    }
    BOOL canVerticalScroll = self.contentSize.height + UIEdgeInsetsGetVerticalValue(self.qmui_contentInset) > CGRectGetHeight(self.bounds);
    BOOL canHorizontalScoll = self.contentSize.width + UIEdgeInsetsGetHorizontalValue(self.qmui_contentInset) > CGRectGetWidth(self.bounds);
    return canVerticalScroll || canHorizontalScoll;
}

- (void)qmui_scrollToTopForce:(BOOL)force animated:(BOOL)animated {
    if (force || (!force && [self qmui_canScroll])) {
        [self setContentOffset:CGPointMake(-self.qmui_contentInset.left, -self.qmui_contentInset.top) animated:animated];
    }
}

- (void)qmui_scrollToTopAnimated:(BOOL)animated {
    [self qmui_scrollToTopForce:NO animated:animated];
}

- (void)qmui_scrollToTop {
    [self qmui_scrollToTopAnimated:NO];
}

- (void)qmui_scrollToTopUponContentInsetTopChange {
    if (self.qmuiscroll_lastInsetTopWhenScrollToTop != self.contentInset.top) {
        [self qmui_scrollToTop];
        self.qmuiscroll_lastInsetTopWhenScrollToTop = self.contentInset.top;
    }
}

- (void)qmui_scrollToBottomAnimated:(BOOL)animated {
    if ([self qmui_canScroll]) {
        [self setContentOffset:CGPointMake(self.contentOffset.x, self.contentSize.height + self.qmui_contentInset.bottom - CGRectGetHeight(self.bounds)) animated:animated];
    }
}

- (void)qmui_scrollToBottom {
    [self qmui_scrollToBottomAnimated:NO];
}

- (void)qmui_stopDeceleratingIfNeeded {
    if (self.decelerating) {
        [self setContentOffset:self.contentOffset animated:NO];
    }
}

- (void)qmui_setContentInset:(UIEdgeInsets)contentInset animated:(BOOL)animated {
    [UIView qmui_animateWithAnimated:animated duration:.25 delay:0 options:QMUIViewAnimationOptionsCurveOut animations:^{
        self.contentInset = contentInset;
    } completion:nil];
}

@end
