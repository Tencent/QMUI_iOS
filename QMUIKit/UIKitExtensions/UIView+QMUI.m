/**
 * Tencent is pleased to support the open source community by making QMUI_iOS available.
 * Copyright (C) 2016-2021 THL A29 Limited, a Tencent company. All rights reserved.
 * Licensed under the MIT License (the "License"); you may not use this file except in compliance with the License. You may obtain a copy of the License at
 * http://opensource.org/licenses/MIT
 * Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.
 */

//
//  UIView+QMUI.m
//  qmui
//
//  Created by QMUI Team on 15/7/20.
//

#import "UIView+QMUI.h"
#import "QMUICore.h"
#import "UIColor+QMUI.h"
#import "NSObject+QMUI.h"
#import "UIImage+QMUI.h"
#import "NSNumber+QMUI.h"
#import "UIViewController+QMUI.h"
#import "QMUILog.h"
#import "QMUIWeakObjectContainer.h"

@interface UIView ()

/// QMUI_Debug
@property(nonatomic, assign, readwrite) BOOL qmui_hasDebugColor;
@end


@implementation UIView (QMUI)

QMUISynthesizeBOOLProperty(qmui_tintColorCustomized, setQmui_tintColorCustomized)
QMUISynthesizeIdCopyProperty(qmui_frameWillChangeBlock, setQmui_frameWillChangeBlock)
QMUISynthesizeIdCopyProperty(qmui_frameDidChangeBlock, setQmui_frameDidChangeBlock)

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        ExtendImplementationOfVoidMethodWithSingleArgument([UIView class], @selector(setTintColor:), UIColor *, ^(UIView *selfObject, UIColor *tintColor) {
            selfObject.qmui_tintColorCustomized = !!tintColor;
        });
        
        // 这个私有方法在 view 被调用 becomeFirstResponder 并且处于 window 上时，才会被调用，所以比 becomeFirstResponder 更适合用来检测
        ExtendImplementationOfVoidMethodWithSingleArgument([UIView class], NSSelectorFromString(@"_didChangeToFirstResponder:"), id, ^(UIView *selfObject, id firstArgv) {
            if (selfObject == firstArgv && [selfObject conformsToProtocol:@protocol(UITextInput)]) {
                // 像 QMUIModalPresentationViewController 那种以 window 的形式展示浮层，浮层里的输入框 becomeFirstResponder 的场景，[window makeKeyAndVisible] 被调用后，就会立即走到这里，但此时该 window 尚不是 keyWindow，所以这里延迟到下一个 runloop 里再去判断
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (IS_DEBUG && ![selfObject isKindOfClass:[UIWindow class]] && selfObject.window && !selfObject.window.keyWindow) {
                        [selfObject QMUISymbolicUIViewBecomeFirstResponderWithoutKeyWindow];
                    }
                });
            }
        });
    });
}

- (instancetype)qmui_initWithSize:(CGSize)size {
    return [self initWithFrame:CGRectMakeWithSize(size)];
}

- (void)setQmui_frameApplyTransform:(CGRect)qmui_frameApplyTransform {
    self.frame = CGRectApplyAffineTransformWithAnchorPoint(qmui_frameApplyTransform, self.transform, self.layer.anchorPoint);
}

- (CGRect)qmui_frameApplyTransform {
    return self.frame;
}

- (UIEdgeInsets)qmui_safeAreaInsets {
    if (@available(iOS 11.0, *)) {
        return self.safeAreaInsets;
    }
    return UIEdgeInsetsZero;
}

- (void)qmui_removeAllSubviews {
    [self.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
}

static char kAssociatedObjectKey_outsideEdge;
- (void)setQmui_outsideEdge:(UIEdgeInsets)qmui_outsideEdge {
    objc_setAssociatedObject(self, &kAssociatedObjectKey_outsideEdge, @(qmui_outsideEdge), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    
    if (!UIEdgeInsetsEqualToEdgeInsets(qmui_outsideEdge, UIEdgeInsetsZero)) {
        [QMUIHelper executeBlock:^{
            OverrideImplementation([UIView class], @selector(pointInside:withEvent:), ^id(__unsafe_unretained Class originClass, SEL originCMD, IMP (^originalIMPProvider)(void)) {
                return ^BOOL(UIControl *selfObject, CGPoint point, UIEvent *event) {
                    
                    if (!UIEdgeInsetsEqualToEdgeInsets(selfObject.qmui_outsideEdge, UIEdgeInsetsZero)) {
                        CGRect rect = UIEdgeInsetsInsetRect(selfObject.bounds, selfObject.qmui_outsideEdge);
                        BOOL result = CGRectContainsPoint(rect, point);
                        return result;
                    }
                    
                    // call super
                    BOOL (*originSelectorIMP)(id, SEL, CGPoint, UIEvent *);
                    originSelectorIMP = (BOOL (*)(id, SEL, CGPoint, UIEvent *))originalIMPProvider();
                    BOOL result = originSelectorIMP(selfObject, originCMD, point, event);
                    return result;
                };
            });
        } oncePerIdentifier:@"UIView (QMUI) outsideEdge"];
    }
}

- (UIEdgeInsets)qmui_outsideEdge {
    return [((NSNumber *)objc_getAssociatedObject(self, &kAssociatedObjectKey_outsideEdge)) UIEdgeInsetsValue];
}

static char kAssociatedObjectKey_tintColorDidChangeBlock;
- (void)setQmui_tintColorDidChangeBlock:(void (^)(__kindof UIView * _Nonnull))qmui_tintColorDidChangeBlock {
    objc_setAssociatedObject(self, &kAssociatedObjectKey_tintColorDidChangeBlock, qmui_tintColorDidChangeBlock, OBJC_ASSOCIATION_COPY_NONATOMIC);
    if (qmui_tintColorDidChangeBlock) {
        [QMUIHelper executeBlock:^{
            ExtendImplementationOfVoidMethodWithoutArguments([UIView class], @selector(tintColorDidChange), ^(UIView *selfObject) {
                if (selfObject.qmui_tintColorDidChangeBlock) {
                    selfObject.qmui_tintColorDidChangeBlock(selfObject);
                }
            });
        } oncePerIdentifier:@"UIView (QMUI) tintColorDidChangeBlock"];
    }
}

- (void (^)(__kindof UIView * _Nonnull))qmui_tintColorDidChangeBlock {
    return (void (^)(__kindof UIView * _Nonnull))objc_getAssociatedObject(self, &kAssociatedObjectKey_tintColorDidChangeBlock);
}

static char kAssociatedObjectKey_hitTestBlock;
- (void)setQmui_hitTestBlock:(__kindof UIView * _Nonnull (^)(CGPoint, UIEvent * _Nonnull, __kindof UIView * _Nonnull))qmui_hitTestBlock {
    objc_setAssociatedObject(self, &kAssociatedObjectKey_hitTestBlock, qmui_hitTestBlock, OBJC_ASSOCIATION_COPY_NONATOMIC);
    [QMUIHelper executeBlock:^{
        ExtendImplementationOfNonVoidMethodWithTwoArguments([UIView class], @selector(hitTest:withEvent:), CGPoint, UIEvent *, UIView *, ^UIView *(UIView *selfObject, CGPoint point, UIEvent *event, UIView *originReturnValue) {
            if (selfObject.qmui_hitTestBlock) {
                UIView *view = selfObject.qmui_hitTestBlock(point, event, originReturnValue);
                return view;
            }
            return originReturnValue;
        });
    } oncePerIdentifier:@"UIView (QMUI) hitTestBlock"];
}

- (__kindof UIView * _Nonnull (^)(CGPoint, UIEvent * _Nonnull, __kindof UIView * _Nonnull))qmui_hitTestBlock {
    return (__kindof UIView * _Nonnull (^)(CGPoint, UIEvent * _Nonnull, __kindof UIView * _Nonnull))objc_getAssociatedObject(self, &kAssociatedObjectKey_hitTestBlock);
}

- (CGPoint)qmui_convertPoint:(CGPoint)point toView:(nullable UIView *)view {
    if (view) {
        return [view qmui_convertPoint:point fromView:view];
    }
    return [self convertPoint:point toView:view];
}

- (CGPoint)qmui_convertPoint:(CGPoint)point fromView:(nullable UIView *)view {
    UIWindow *selfWindow = [self isKindOfClass:[UIWindow class]] ? (UIWindow *)self : self.window;
    UIWindow *fromWindow = [view isKindOfClass:[UIWindow class]] ? (UIWindow *)view : view.window;
    if (selfWindow && fromWindow && selfWindow != fromWindow) {
        CGPoint pointInFromWindow = fromWindow == view ? point : [view convertPoint:point toView:nil];
        CGPoint pointInSelfWindow = [selfWindow convertPoint:pointInFromWindow fromWindow:fromWindow];
        CGPoint pointInSelf = selfWindow == self ? pointInSelfWindow : [self convertPoint:pointInSelfWindow fromView:nil];
        return pointInSelf;
    }
    return [self convertPoint:point fromView:view];
}

- (CGRect)qmui_convertRect:(CGRect)rect toView:(nullable UIView *)view {
    if (view) {
        return [view qmui_convertRect:rect fromView:self];
    }
    return [self convertRect:rect toView:view];
}

- (CGRect)qmui_convertRect:(CGRect)rect fromView:(nullable UIView *)view {
    UIWindow *selfWindow = [self isKindOfClass:[UIWindow class]] ? (UIWindow *)self : self.window;
    UIWindow *fromWindow = [view isKindOfClass:[UIWindow class]] ? (UIWindow *)view : view.window;
    if (selfWindow && fromWindow && selfWindow != fromWindow) {
        CGRect rectInFromWindow = fromWindow == view ? rect : [view convertRect:rect toView:nil];
        CGRect rectInSelfWindow = [selfWindow convertRect:rectInFromWindow fromWindow:fromWindow];
        CGRect rectInSelf = selfWindow == self ? rectInSelfWindow : [self convertRect:rectInSelfWindow fromView:nil];
        return rectInSelf;
    }
    return [self convertRect:rect fromView:view];
}

+ (void)qmui_animateWithAnimated:(BOOL)animated duration:(NSTimeInterval)duration delay:(NSTimeInterval)delay options:(UIViewAnimationOptions)options animations:(void (^)(void))animations completion:(void (^ __nullable)(BOOL finished))completion {
    if (animated) {
        [UIView animateWithDuration:duration delay:delay options:options animations:animations completion:completion];
    } else {
        if (animations) {
            animations();
        }
        if (completion) {
            completion(YES);
        }
    }
}

+ (void)qmui_animateWithAnimated:(BOOL)animated duration:(NSTimeInterval)duration animations:(void (^ __nullable)(void))animations completion:(void (^)(BOOL finished))completion {
    if (animated) {
        [UIView animateWithDuration:duration animations:animations completion:completion];
    } else {
        if (animations) {
            animations();
        }
        if (completion) {
            completion(YES);
        }
    }
}

+ (void)qmui_animateWithAnimated:(BOOL)animated duration:(NSTimeInterval)duration animations:(void (^ __nullable)(void))animations {
    if (animated) {
        [UIView animateWithDuration:duration animations:animations];
    } else {
        if (animations) {
            animations();
        }
    }
}

+ (void)qmui_animateWithAnimated:(BOOL)animated duration:(NSTimeInterval)duration delay:(NSTimeInterval)delay usingSpringWithDamping:(CGFloat)dampingRatio initialSpringVelocity:(CGFloat)velocity options:(UIViewAnimationOptions)options animations:(void (^)(void))animations completion:(void (^)(BOOL finished))completion {
    if (animated) {
        [UIView animateWithDuration:duration delay:delay usingSpringWithDamping:dampingRatio initialSpringVelocity:velocity options:options animations:animations completion:completion];
    } else {
        if (animations) {
            animations();
        }
        if (completion) {
            completion(YES);
        }
    }
}

- (void)QMUISymbolicUIViewBecomeFirstResponderWithoutKeyWindow {
    QMUILogWarn(@"UIView (QMUI)", @"尝试让一个处于非 keyWindow 上的 %@ becomeFirstResponder，可能导致界面显示异常，请添加 '%@' 的 Symbolic Breakpoint 以捕捉此类信息\n%@", NSStringFromClass(self.class), NSStringFromSelector(_cmd), [NSThread callStackSymbols]);
}

@end

@implementation UIView (QMUI_ViewController)

QMUISynthesizeBOOLProperty(qmui_isControllerRootView, setQmui_isControllerRootView)

- (BOOL)qmui_visible {
    if (self.hidden || self.alpha <= 0.01) {
        return NO;
    }
    if (self.window) {
        return YES;
    }
    if ([self isKindOfClass:UIWindow.class]) {
        if (@available(iOS 13.0, *)) {
            return !!((UIWindow *)self).windowScene;
        } else {
            return YES;
        }
    }
    UIViewController *viewController = self.qmui_viewController;
    return viewController.qmui_visibleState >= QMUIViewControllerWillAppear && viewController.qmui_visibleState < QMUIViewControllerWillDisappear;
}

static char kAssociatedObjectKey_viewController;
- (void)setQmui_viewController:(__kindof UIViewController * _Nullable)qmui_viewController {
    QMUIWeakObjectContainer *weakContainer = objc_getAssociatedObject(self, &kAssociatedObjectKey_viewController);
    if (!weakContainer) {
        weakContainer = [[QMUIWeakObjectContainer alloc] init];
    }
    weakContainer.object = qmui_viewController;
    objc_setAssociatedObject(self, &kAssociatedObjectKey_viewController, weakContainer, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    
    self.qmui_isControllerRootView = !!qmui_viewController;
}

- (__kindof UIViewController *)qmui_viewController {
    if (self.qmui_isControllerRootView) {
        return (__kindof UIViewController *)((QMUIWeakObjectContainer *)objc_getAssociatedObject(self, &kAssociatedObjectKey_viewController)).object;
    }
    return self.superview.qmui_viewController;
}

@end

@interface UIViewController (QMUI_View)

@end

@implementation UIViewController (QMUI_View)

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        ExtendImplementationOfVoidMethodWithoutArguments([UIViewController class], @selector(viewDidLoad), ^(UIViewController *selfObject) {
            if (@available(iOS 11.0, *)) {
                selfObject.view.qmui_viewController = selfObject;
            } else {
                // 临时修复 iOS 10.0.2 上在输入框内切换输入法可能引发死循环的 bug，待查
                // https://github.com/Tencent/QMUI_iOS/issues/471
                ((UIView *)[selfObject qmui_valueForKey:@"_view"]).qmui_viewController = selfObject;
            }
        });
    });
}

@end


@implementation UIView (QMUI_Runtime)

- (BOOL)qmui_hasOverrideUIKitMethod:(SEL)selector {
    // 排序依照 Xcode Interface Builder 里的控件排序，但保证子类在父类前面
    NSMutableArray<Class> *viewSuperclasses = [[NSMutableArray alloc] initWithObjects:
                                               [UIStackView class],
                                               [UILabel class],
                                               [UIButton class],
                                               [UISegmentedControl class],
                                               [UITextField class],
                                               [UISlider class],
                                               [UISwitch class],
                                               [UIActivityIndicatorView class],
                                               [UIProgressView class],
                                               [UIPageControl class],
                                               [UIStepper class],
                                               [UITableView class],
                                               [UITableViewCell class],
                                               [UIImageView class],
                                               [UICollectionView class],
                                               [UICollectionViewCell class],
                                               [UICollectionReusableView class],
                                               [UITextView class],
                                               [UIScrollView class],
                                               [UIDatePicker class],
                                               [UIPickerView class],
                                               [UIVisualEffectView class],
                                               // Apple 不再接受使用了 UIWebView 的 App 提交，所以这里去掉 UIWebView
                                               // https://github.com/Tencent/QMUI_iOS/issues/741
//                                               [UIWebView class],
                                               [UIWindow class],
                                               [UINavigationBar class],
                                               [UIToolbar class],
                                               [UITabBar class],
                                               [UISearchBar class],
                                               [UIControl class],
                                               [UIView class],
                                               nil];
    
    for (NSInteger i = 0, l = viewSuperclasses.count; i < l; i++) {
        Class superclass = viewSuperclasses[i];
        if ([self qmui_hasOverrideMethod:selector ofSuperclass:superclass]) {
            return YES;
        }
    }
    return NO;
}

@end


const CGFloat QMUIViewSelfSizingHeight = INFINITY;

@implementation UIView (QMUI_Layout)

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        OverrideImplementation([UIView class], @selector(setFrame:), ^id(__unsafe_unretained Class originClass, SEL originCMD, IMP (^originalIMPProvider)(void)) {
            return ^(UIView *selfObject, CGRect frame) {
                
                // QMUIViewSelfSizingHeight 的功能
                if (frame.size.width > 0 && isinf(frame.size.height)) {
                    CGFloat height = flat([selfObject sizeThatFits:CGSizeMake(CGRectGetWidth(frame), CGFLOAT_MAX)].height);
                    frame = CGRectSetHeight(frame, height);
                }
                
                // 对非法的 frame，Debug 下中 assert，Release 下会将其中的 NaN 改为 0，避免 crash
                if (CGRectIsNaN(frame)) {
                    QMUILogWarn(@"UIView (QMUI)", @"%@ setFrame:%@，参数包含 NaN，已被拦截并处理为 0。%@", selfObject, NSStringFromCGRect(frame), [NSThread callStackSymbols]);
                    if (QMUICMIActivated && !ShouldPrintQMUIWarnLogToConsole) {
                        NSAssert(NO, @"UIView setFrame: 出现 NaN");
                    }
                    if (!IS_DEBUG) {
                        frame = CGRectSafeValue(frame);
                    }
                }
                
                CGRect precedingFrame = selfObject.frame;
                BOOL valueChange = !CGRectEqualToRect(frame, precedingFrame);
                if (selfObject.qmui_frameWillChangeBlock && valueChange) {
                    frame = selfObject.qmui_frameWillChangeBlock(selfObject, frame);
                }
                
                // call super
                void (*originSelectorIMP)(id, SEL, CGRect);
                originSelectorIMP = (void (*)(id, SEL, CGRect))originalIMPProvider();
                originSelectorIMP(selfObject, originCMD, frame);
                
                if (selfObject.qmui_frameDidChangeBlock && valueChange) {
                    selfObject.qmui_frameDidChangeBlock(selfObject, precedingFrame);
                }
            };
        });
        
        OverrideImplementation([UIView class], @selector(setBounds:), ^id(__unsafe_unretained Class originClass, SEL originCMD, IMP (^originalIMPProvider)(void)) {
            return ^(UIView *selfObject, CGRect bounds) {
                
                CGRect precedingFrame = selfObject.frame;
                CGRect precedingBounds = selfObject.bounds;
                BOOL valueChange = !CGSizeEqualToSize(bounds.size, precedingBounds.size);// bounds 只有 size 发生变化才会影响 frame
                if (selfObject.qmui_frameWillChangeBlock && valueChange) {
                    CGRect followingFrame = CGRectMake(CGRectGetMinX(precedingFrame) + CGFloatGetCenter(CGRectGetWidth(bounds), CGRectGetWidth(precedingFrame)), CGRectGetMinY(precedingFrame) + CGFloatGetCenter(CGRectGetHeight(bounds), CGRectGetHeight(precedingFrame)), bounds.size.width, bounds.size.height);
                    followingFrame = selfObject.qmui_frameWillChangeBlock(selfObject, followingFrame);
                    bounds = CGRectSetSize(bounds, followingFrame.size);
                }
                
                // call super
                void (*originSelectorIMP)(id, SEL, CGRect);
                originSelectorIMP = (void (*)(id, SEL, CGRect))originalIMPProvider();
                originSelectorIMP(selfObject, originCMD, bounds);
                
                if (selfObject.qmui_frameDidChangeBlock && valueChange) {
                    selfObject.qmui_frameDidChangeBlock(selfObject, precedingFrame);
                }
            };
        });
        
        OverrideImplementation([UIView class], @selector(setCenter:), ^id(__unsafe_unretained Class originClass, SEL originCMD, IMP (^originalIMPProvider)(void)) {
            return ^(UIView *selfObject, CGPoint center) {
                
                CGRect precedingFrame = selfObject.frame;
                CGPoint precedingCenter = selfObject.center;
                BOOL valueChange = !CGPointEqualToPoint(center, precedingCenter);
                if (selfObject.qmui_frameWillChangeBlock && valueChange) {
                    CGRect followingFrame = CGRectSetXY(precedingFrame, center.x - CGRectGetWidth(selfObject.frame) / 2, center.y - CGRectGetHeight(selfObject.frame) / 2);
                    followingFrame = selfObject.qmui_frameWillChangeBlock(selfObject, followingFrame);
                    center = CGPointMake(CGRectGetMidX(followingFrame), CGRectGetMidY(followingFrame));
                }
                
                // call super
                void (*originSelectorIMP)(id, SEL, CGPoint);
                originSelectorIMP = (void (*)(id, SEL, CGPoint))originalIMPProvider();
                originSelectorIMP(selfObject, originCMD, center);
                
                if (selfObject.qmui_frameDidChangeBlock && valueChange) {
                    selfObject.qmui_frameDidChangeBlock(selfObject, precedingFrame);
                }
            };
        });
        
        OverrideImplementation([UIView class], @selector(setTransform:), ^id(__unsafe_unretained Class originClass, SEL originCMD, IMP (^originalIMPProvider)(void)) {
            return ^(UIView *selfObject, CGAffineTransform transform) {
                
                CGRect precedingFrame = selfObject.frame;
                CGAffineTransform precedingTransform = selfObject.transform;
                BOOL valueChange = !CGAffineTransformEqualToTransform(transform, precedingTransform);
                if (selfObject.qmui_frameWillChangeBlock && valueChange) {
                    CGRect followingFrame = CGRectApplyAffineTransformWithAnchorPoint(precedingFrame, transform, selfObject.layer.anchorPoint);
                    selfObject.qmui_frameWillChangeBlock(selfObject, followingFrame);// 对于 CGAffineTransform，无法根据修改后的 rect 来算出新的 transform，所以就不修改 transform 的值了
                }
                
                // call super
                void (*originSelectorIMP)(id, SEL, CGAffineTransform);
                originSelectorIMP = (void (*)(id, SEL, CGAffineTransform))originalIMPProvider();
                originSelectorIMP(selfObject, originCMD, transform);
                
                if (selfObject.qmui_frameDidChangeBlock && valueChange) {
                    selfObject.qmui_frameDidChangeBlock(selfObject, precedingFrame);
                }
            };
        });
    });
}

- (CGFloat)qmui_top {
    return CGRectGetMinY(self.frame);
}

- (void)setQmui_top:(CGFloat)top {
    self.frame = CGRectSetY(self.frame, top);
}

- (CGFloat)qmui_left {
    return CGRectGetMinX(self.frame);
}

- (void)setQmui_left:(CGFloat)left {
    self.frame = CGRectSetX(self.frame, left);
}

- (CGFloat)qmui_bottom {
    return CGRectGetMaxY(self.frame);
}

- (void)setQmui_bottom:(CGFloat)bottom {
    self.frame = CGRectSetY(self.frame, bottom - CGRectGetHeight(self.frame));
}

- (CGFloat)qmui_right {
    return CGRectGetMaxX(self.frame);
}

- (void)setQmui_right:(CGFloat)right {
    self.frame = CGRectSetX(self.frame, right - CGRectGetWidth(self.frame));
}

- (CGFloat)qmui_width {
    return CGRectGetWidth(self.frame);
}

- (void)setQmui_width:(CGFloat)width {
    self.frame = CGRectSetWidth(self.frame, width);
}

- (CGFloat)qmui_height {
    return CGRectGetHeight(self.frame);
}

- (void)setQmui_height:(CGFloat)height {
    self.frame = CGRectSetHeight(self.frame, height);
}

- (CGFloat)qmui_extendToTop {
    return self.qmui_top;
}

- (void)setQmui_extendToTop:(CGFloat)qmui_extendToTop {
    self.qmui_height = self.qmui_bottom - qmui_extendToTop;
    self.qmui_top = qmui_extendToTop;
}

- (CGFloat)qmui_extendToLeft {
    return self.qmui_left;
}

- (void)setQmui_extendToLeft:(CGFloat)qmui_extendToLeft {
    self.qmui_width = self.qmui_right - qmui_extendToLeft;
    self.qmui_left = qmui_extendToLeft;
}

- (CGFloat)qmui_extendToBottom {
    return self.qmui_bottom;
}

- (void)setQmui_extendToBottom:(CGFloat)qmui_extendToBottom {
    self.qmui_height = qmui_extendToBottom - self.qmui_top;
    self.qmui_bottom = qmui_extendToBottom;
}

- (CGFloat)qmui_extendToRight {
    return self.qmui_right;
}

- (void)setQmui_extendToRight:(CGFloat)qmui_extendToRight {
    self.qmui_width = qmui_extendToRight - self.qmui_left;
    self.qmui_right = qmui_extendToRight;
}

- (CGFloat)qmui_leftWhenCenterInSuperview {
    return CGFloatGetCenter(CGRectGetWidth(self.superview.bounds), CGRectGetWidth(self.frame));
}

- (CGFloat)qmui_topWhenCenterInSuperview {
    return CGFloatGetCenter(CGRectGetHeight(self.superview.bounds), CGRectGetHeight(self.frame));
}

@end


@implementation UIView (CGAffineTransform)

- (CGFloat)qmui_scaleX {
    return self.transform.a;
}

- (CGFloat)qmui_scaleY {
    return self.transform.d;
}

- (CGFloat)qmui_translationX {
    return self.transform.tx;
}

- (CGFloat)qmui_translationY {
    return self.transform.ty;
}

@end


@implementation UIView (QMUI_Snapshotting)

- (UIImage *)qmui_snapshotLayerImage {
    return [UIImage qmui_imageWithView:self];
}

- (UIImage *)qmui_snapshotImageAfterScreenUpdates:(BOOL)afterScreenUpdates {
    return [UIImage qmui_imageWithView:self afterScreenUpdates:afterScreenUpdates];
}

@end


@implementation UIView (QMUI_Debug)

QMUISynthesizeBOOLProperty(qmui_needsDifferentDebugColor, setQmui_needsDifferentDebugColor)
QMUISynthesizeBOOLProperty(qmui_hasDebugColor, setQmui_hasDebugColor)

static char kAssociatedObjectKey_shouldShowDebugColor;
- (void)setQmui_shouldShowDebugColor:(BOOL)qmui_shouldShowDebugColor {
    objc_setAssociatedObject(self, &kAssociatedObjectKey_shouldShowDebugColor, @(qmui_shouldShowDebugColor), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    if (qmui_shouldShowDebugColor) {
        [QMUIHelper executeBlock:^{
            ExtendImplementationOfVoidMethodWithoutArguments([UIView class], @selector(layoutSubviews), ^(UIView *selfObject) {
                if (selfObject.qmui_shouldShowDebugColor) {
                    selfObject.qmui_hasDebugColor = YES;
                    selfObject.backgroundColor = [selfObject debugColor];
                    [selfObject renderColorWithSubviews:selfObject.subviews];
                }
            });
        } oncePerIdentifier:@"UIView (QMUIDebug) shouldShowDebugColor"];
        
        [self setNeedsLayout];
    }
}
- (BOOL)qmui_shouldShowDebugColor {
    BOOL flag = [objc_getAssociatedObject(self, &kAssociatedObjectKey_shouldShowDebugColor) boolValue];
    return flag;
}

static char kAssociatedObjectKey_layoutSubviewsBlock;
- (void)setQmui_layoutSubviewsBlock:(void (^)(__kindof UIView * _Nonnull))qmui_layoutSubviewsBlock {
    objc_setAssociatedObject(self, &kAssociatedObjectKey_layoutSubviewsBlock, qmui_layoutSubviewsBlock, OBJC_ASSOCIATION_COPY_NONATOMIC);
    Class viewClass = self.class;
    [QMUIHelper executeBlock:^{
        ExtendImplementationOfVoidMethodWithoutArguments(viewClass, @selector(layoutSubviews), ^(__kindof UIView *selfObject) {
            if (selfObject.qmui_layoutSubviewsBlock && [selfObject isMemberOfClass:viewClass]) {
                selfObject.qmui_layoutSubviewsBlock(selfObject);
            }
        });
    } oncePerIdentifier:[NSString stringWithFormat:@"UIView %@-%@", NSStringFromClass(viewClass), NSStringFromSelector(@selector(layoutSubviews))]];
}

- (void (^)(UIView * _Nonnull))qmui_layoutSubviewsBlock {
    return objc_getAssociatedObject(self, &kAssociatedObjectKey_layoutSubviewsBlock);
}

static char kAssociatedObjectKey_sizeThatFitsBlock;
- (void)setQmui_sizeThatFitsBlock:(CGSize (^)(__kindof UIView * _Nonnull, CGSize, CGSize))qmui_sizeThatFitsBlock {
    objc_setAssociatedObject(self, &kAssociatedObjectKey_sizeThatFitsBlock, qmui_sizeThatFitsBlock, OBJC_ASSOCIATION_COPY_NONATOMIC);
    
    if (!qmui_sizeThatFitsBlock) return;
    
    // Extend 每个实例对象的类是为了保证比子类的 sizeThatFits 逻辑要更晚调用
    Class viewClass = self.class;
    [QMUIHelper executeBlock:^{
        ExtendImplementationOfNonVoidMethodWithSingleArgument(viewClass, @selector(sizeThatFits:), CGSize, CGSize, ^CGSize(UIView *selfObject, CGSize firstArgv, CGSize originReturnValue) {
            if (selfObject.qmui_sizeThatFitsBlock && [selfObject isMemberOfClass:viewClass]) {
                originReturnValue = selfObject.qmui_sizeThatFitsBlock(selfObject, firstArgv, originReturnValue);
            }
            return originReturnValue;
        });
    } oncePerIdentifier:[NSString stringWithFormat:@"UIView %@-%@", NSStringFromClass(viewClass), NSStringFromSelector(@selector(sizeThatFits:))]];
}

- (CGSize (^)(__kindof UIView * _Nonnull, CGSize, CGSize))qmui_sizeThatFitsBlock {
    return objc_getAssociatedObject(self, &kAssociatedObjectKey_sizeThatFitsBlock);
}

- (void)renderColorWithSubviews:(NSArray *)subviews {
    for (UIView *view in subviews) {
        if ([view isKindOfClass:[UIStackView class]]) {
            UIStackView *stackView = (UIStackView *)view;
            [self renderColorWithSubviews:stackView.arrangedSubviews];
        }
        view.qmui_hasDebugColor = YES;
        view.qmui_shouldShowDebugColor = self.qmui_shouldShowDebugColor;
        view.qmui_needsDifferentDebugColor = self.qmui_needsDifferentDebugColor;
        view.backgroundColor = [self debugColor];
    }
}

- (UIColor *)debugColor {
    if (!self.qmui_needsDifferentDebugColor) {
        return UIColorTestRed;
    } else {
        return [[UIColor qmui_randomColor] colorWithAlphaComponent:.3];
    }
}

@end
