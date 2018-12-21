/*****
 * Tencent is pleased to support the open source community by making QMUI_iOS available.
 * Copyright (C) 2016-2018 THL A29 Limited, a Tencent company. All rights reserved.
 * Licensed under the MIT License (the "License"); you may not use this file except in compliance with the License. You may obtain a copy of the License at
 * http://opensource.org/licenses/MIT
 * Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.
 *****/

//
//  UIView+QMUI.m
//  qmui
//
//  Created by QMUI Team on 15/7/20.
//

#import "UIView+QMUI.h"
#import "QMUICore.h"
#import "CALayer+QMUI.h"
#import "UIColor+QMUI.h"
#import "NSObject+QMUI.h"
#import "UIImage+QMUI.h"
#import "NSNumber+QMUI.h"
#import "UIViewController+QMUI.h"
#import "QMUILog.h"
#import <objc/runtime.h>

@interface UIView ()

/// QMUI_Debug
@property(nonatomic, assign, readwrite) BOOL qmui_hasDebugColor;

/// QMUI_Border
@property(nonatomic, strong, readwrite) CAShapeLayer *qmui_borderLayer;

@end


@implementation UIView (QMUI)

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        SEL selectors[] = {
            @selector(tintColorDidChange),
            @selector(hitTest:withEvent:),
            @selector(addSubview:),
            @selector(becomeFirstResponder),
            
            // 检查调用这系列方法的两个 view 是否存在共同的父 view，不存在则可能导致转换结果错误
            @selector(convertPoint:toView:),
            @selector(convertPoint:fromView:),
            @selector(convertRect:toView:),
            @selector(convertRect:fromView:)
        };
        for (NSUInteger index = 0; index < sizeof(selectors) / sizeof(SEL); index++) {
            SEL originalSelector = selectors[index];
            SEL swizzledSelector = NSSelectorFromString([@"qmuiview_" stringByAppendingString:NSStringFromSelector(originalSelector)]);
            ExchangeImplementations([self class], originalSelector, swizzledSelector);
        }
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

- (void)qmuiview_tintColorDidChange {
    [self qmuiview_tintColorDidChange];
    if (self.qmui_tintColorDidChangeBlock) {
        self.qmui_tintColorDidChangeBlock(self);
    }
}

static char kAssociatedObjectKey_tintColorDidChagneBlock;
- (void)setQmui_tintColorDidChangeBlock:(void (^)(__kindof UIView * _Nonnull))qmui_tintColorDidChangeBlock {
    objc_setAssociatedObject(self, &kAssociatedObjectKey_tintColorDidChagneBlock, qmui_tintColorDidChangeBlock, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (void (^)(__kindof UIView *))qmui_tintColorDidChangeBlock {
    return (void (^)(__kindof UIView *))objc_getAssociatedObject(self, &kAssociatedObjectKey_tintColorDidChagneBlock);
}

- (nullable UIView *)qmuiview_hitTest:(CGPoint)point withEvent:(nullable UIEvent *)event {
    UIView *originalView = [self qmuiview_hitTest:point withEvent:event];
    if (self.qmui_hitTestBlock) {
        UIView *view = self.qmui_hitTestBlock(point, event, originalView);
        return view;
    }
    return originalView;
}

static char kAssociatedObjectKey_hitTestBlock;
- (void)setQmui_hitTestBlock:(__kindof UIView * (^)(CGPoint, UIEvent *, __kindof UIView *))qmui_hitTestBlock {
    objc_setAssociatedObject(self, &kAssociatedObjectKey_hitTestBlock, qmui_hitTestBlock, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (__kindof UIView * (^)(CGPoint, UIEvent *, __kindof UIView *))qmui_hitTestBlock {
    return (__kindof UIView * (^)(CGPoint, UIEvent *, __kindof UIView *))objc_getAssociatedObject(self, &kAssociatedObjectKey_hitTestBlock);
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

- (void)qmuiview_addSubview:(UIView *)view {
    if (view == self) {
        NSAssert(NO, @"把自己作为 subview 添加到自己身上！\n%@", [NSThread callStackSymbols]);
    }
    [self qmuiview_addSubview:view];
}

- (BOOL)qmuiview_becomeFirstResponder {
    if (IS_SIMULATOR && ![self isKindOfClass:[UIWindow class]] && (self.window ? !self.window.keyWindow : YES) && !self.qmui_visible) {
        [self QMUISymbolicUIViewBecomeFirstResponderWithoutKeyWindow];
    }
    return [self qmuiview_becomeFirstResponder];
}

- (void)QMUISymbolicUIViewBecomeFirstResponderWithoutKeyWindow {
    QMUILogWarn(@"UIView (QMUI)", @"尝试让一个处于非 keyWindow 上的 %@ becomeFirstResponder，可能导致界面显示异常，请添加 '%@' 的 Symbolic Breakpoint 以捕捉此类信息\n%@", NSStringFromClass(self.class), NSStringFromSelector(_cmd), [NSThread callStackSymbols]);
}

- (BOOL)hasSharedAncestorViewWithView:(UIView *)view {
    UIView *sharedAncestorView = self;
    if (!view) {
        return YES;
    }
    while (sharedAncestorView && ![view isDescendantOfView:sharedAncestorView]) {
        sharedAncestorView = sharedAncestorView.superview;
    }
    return !!sharedAncestorView;
}

- (BOOL)isUIKitPrivateView {
    // 系统有些东西本身也存在不合理，但我们不关心这种，所以过滤掉
    if ([self isKindOfClass:[UIWindow class]]) return YES;
    
    __block BOOL isPrivate = NO;
    NSString *classString = NSStringFromClass(self.class);
    [@[@"LayoutContainer", @"NavigationItemButton", @"NavigationItemView", @"SelectionGrabber", @"InputViewContent", @"InputSetContainer", @"TextFieldContentView"] enumerateObjectsUsingBlock:^(NSString * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (([classString hasPrefix:@"UI"] || [classString hasPrefix:@"_UI"]) && [classString containsString:obj]) {
            isPrivate = YES;
            *stop = YES;
        }
    }];
    return isPrivate;
}

- (void)alertConvertValueWithView:(UIView *)view {
    if (IS_DEBUG && ![self isUIKitPrivateView] && ![self hasSharedAncestorViewWithView:view]) {
        QMUILog(@"UIView (QMUI)", @"进行坐标系转换运算的 %@ 和 %@ 不存在共同的父 view，可能导致运算结果不准确（特别是在横屏状态下）", self, view);
    }
}

- (CGPoint)qmuiview_convertPoint:(CGPoint)point toView:(nullable UIView *)view {
    [self alertConvertValueWithView:view];
    return [self qmuiview_convertPoint:point toView:view];
}

- (CGPoint)qmuiview_convertPoint:(CGPoint)point fromView:(nullable UIView *)view {
    [self alertConvertValueWithView:view];
    return [self qmuiview_convertPoint:point fromView:view];
}

- (CGRect)qmuiview_convertRect:(CGRect)rect toView:(nullable UIView *)view {
    [self alertConvertValueWithView:view];
    return [self qmuiview_convertRect:rect toView:view];
}

- (CGRect)qmuiview_convertRect:(CGRect)rect fromView:(nullable UIView *)view {
    [self alertConvertValueWithView:view];
    return [self qmuiview_convertRect:rect fromView:view];
}

@end

@implementation UIView (QMUI_ViewController)

- (BOOL)qmui_visible {
    if (self.hidden || self.alpha <= 0.01) {
        return NO;
    }
    if (self.window) {
        return YES;
    }
    UIViewController *viewController = self.qmui_viewController;
    return viewController.qmui_visibleState >= QMUIViewControllerWillAppear && viewController.qmui_visibleState < QMUIViewControllerWillDisappear;
}

static char kAssociatedObjectKey_isControllerRootView;
- (void)setQmui_isControllerRootView:(BOOL)qmui_isControllerRootView {
    objc_setAssociatedObject(self, &kAssociatedObjectKey_isControllerRootView, @(qmui_isControllerRootView), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (BOOL)qmui_isControllerRootView {
    return [((NSNumber *)objc_getAssociatedObject(self, &kAssociatedObjectKey_isControllerRootView)) boolValue];
}

static char kAssociatedObjectKey_viewController;
- (void)setQmui_viewController:(__kindof UIViewController * _Nullable)qmui_viewController {
    objc_setAssociatedObject(self, &kAssociatedObjectKey_viewController, qmui_viewController, OBJC_ASSOCIATION_ASSIGN);
    self.qmui_isControllerRootView = !!qmui_viewController;
}

- (__kindof UIViewController *)qmui_viewController {
    if (self.qmui_isControllerRootView) {
        return (__kindof UIViewController *)objc_getAssociatedObject(self, &kAssociatedObjectKey_viewController);
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
        ExchangeImplementations([self class], @selector(viewDidLoad), @selector(qmuiview_viewDidLoad));
    });
}

- (void)qmuiview_viewDidLoad {
    [self qmuiview_viewDidLoad];
    self.view.qmui_viewController = self;
}

@end


@implementation UIView (QMUI_Runtime)

- (BOOL)qmui_hasOverrideUIKitMethod:(SEL)selector {
    // 排序依照 Xcode Interface Builder 里的控件排序，但保证子类在父类前面
    NSMutableArray<Class> *viewSuperclasses = [[NSMutableArray alloc] initWithObjects:
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
                                               [UIWebView class],
                                               [UIWindow class],
                                               [UINavigationBar class],
                                               [UIToolbar class],
                                               [UITabBar class],
                                               [UISearchBar class],
                                               [UIControl class],
                                               [UIView class],
                                               nil];
    
    if (@available(iOS 9.0, *)) {
        [viewSuperclasses insertObject:[UIStackView class] atIndex:0];
    }
    
    for (NSInteger i = 0, l = viewSuperclasses.count; i < l; i++) {
        Class superclass = viewSuperclasses[i];
        if ([self qmui_hasOverrideMethod:selector ofSuperclass:superclass]) {
            return YES;
        }
    }
    return NO;
}

@end


@implementation UIView (QMUI_Border)

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        ExchangeImplementations([self class], @selector(initWithFrame:), @selector(QMUIBorder_initWithFrame:));
        ExchangeImplementations([self class], @selector(initWithCoder:), @selector(QMUIBorder_initWithCoder:));
        ExchangeImplementations([self class], @selector(layoutSublayersOfLayer:), @selector(QMUIBorder_layoutSublayersOfLayer:));
    });
}

- (instancetype)QMUIBorder_initWithFrame:(CGRect)frame {
    [self QMUIBorder_initWithFrame:frame];
    [self setDefaultStyle];
    return self;
}

- (instancetype)QMUIBorder_initWithCoder:(NSCoder *)aDecoder {
    [self QMUIBorder_initWithCoder:aDecoder];
    [self setDefaultStyle];
    return self;
}

- (void)QMUIBorder_layoutSublayersOfLayer:(CALayer *)layer {
    
    [self QMUIBorder_layoutSublayersOfLayer:layer];
    
    if ((!self.qmui_borderLayer && self.qmui_borderPosition == QMUIViewBorderPositionNone) || (!self.qmui_borderLayer && self.qmui_borderWidth == 0)) {
        return;
    }
    
    if (self.qmui_borderLayer && self.qmui_borderPosition == QMUIViewBorderPositionNone && !self.qmui_borderLayer.path) {
        return;
    }
    
    if (self.qmui_borderLayer && self.qmui_borderWidth == 0 && self.qmui_borderLayer.lineWidth == 0) {
        return;
    }
    
    if (!self.qmui_borderLayer) {
        self.qmui_borderLayer = [CAShapeLayer layer];
        self.qmui_borderLayer.fillColor = UIColorClear.CGColor;
        [self.qmui_borderLayer qmui_removeDefaultAnimations];
        [self.layer addSublayer:self.qmui_borderLayer];
    }
    self.qmui_borderLayer.frame = self.bounds;
    
    CGFloat borderWidth = self.qmui_borderWidth;
    self.qmui_borderLayer.lineWidth = borderWidth;
    self.qmui_borderLayer.strokeColor = self.qmui_borderColor.CGColor;
    self.qmui_borderLayer.lineDashPhase = self.qmui_dashPhase;
    self.qmui_borderLayer.lineDashPattern = self.qmui_dashPattern;
    
    UIBezierPath *path = nil;
    
    if (self.qmui_borderPosition != QMUIViewBorderPositionNone) {
        path = [UIBezierPath bezierPath];
    }
    
    CGFloat (^adjustsLocation)(CGFloat, CGFloat, CGFloat) = ^CGFloat(CGFloat inside, CGFloat center, CGFloat outside) {
        return self.qmui_borderLocation == QMUIViewBorderLocationInside ? inside : (self.qmui_borderLocation == QMUIViewBorderLocationCenter ? center : outside);
    };
    
    CGFloat lineOffset = adjustsLocation(borderWidth / 2.0, 0, -borderWidth / 2.0); // 为了像素对齐而做的偏移
    CGFloat lineCapOffset = adjustsLocation(0, borderWidth / 2.0, borderWidth); // 两条相邻的边框连接的位置
    
    BOOL shouldShowTopBorder = (self.qmui_borderPosition & QMUIViewBorderPositionTop) == QMUIViewBorderPositionTop;
    BOOL shouldShowLeftBorder = (self.qmui_borderPosition & QMUIViewBorderPositionLeft) == QMUIViewBorderPositionLeft;
    BOOL shouldShowBottomBorder = (self.qmui_borderPosition & QMUIViewBorderPositionBottom) == QMUIViewBorderPositionBottom;
    BOOL shouldShowRightBorder = (self.qmui_borderPosition & QMUIViewBorderPositionRight) == QMUIViewBorderPositionRight;

    UIBezierPath *topPath = [UIBezierPath bezierPath];
    UIBezierPath *leftPath = [UIBezierPath bezierPath];
    UIBezierPath *bottomPath = [UIBezierPath bezierPath];
    UIBezierPath *rightPath = [UIBezierPath bezierPath];
    
    if (self.layer.qmui_originCornerRadius > 0) {
        
        CGFloat cornerRadius = self.layer.qmui_originCornerRadius;
        
        if (self.layer.qmui_maskedCorners) {
            if ((self.layer.qmui_maskedCorners & QMUILayerMinXMinYCorner) == QMUILayerMinXMinYCorner) {
                [topPath addArcWithCenter:CGPointMake(cornerRadius, cornerRadius) radius:cornerRadius - lineOffset startAngle:1.25 * M_PI endAngle:1.5 * M_PI clockwise:YES];
                [topPath addLineToPoint:CGPointMake(CGRectGetWidth(self.bounds) - cornerRadius, lineOffset)];
                [leftPath addArcWithCenter:CGPointMake(cornerRadius, cornerRadius) radius:cornerRadius - lineOffset startAngle:-0.75 * M_PI endAngle:-1 * M_PI clockwise:NO];
                [leftPath addLineToPoint:CGPointMake(lineOffset, CGRectGetHeight(self.bounds) - cornerRadius)];
            } else {
                [topPath moveToPoint:CGPointMake(shouldShowLeftBorder ? -lineCapOffset : 0, lineOffset)];
                [topPath addLineToPoint:CGPointMake(CGRectGetWidth(self.bounds) - cornerRadius, lineOffset)];
                [leftPath moveToPoint:CGPointMake(lineOffset, shouldShowTopBorder ? -lineCapOffset : 0)];
                [leftPath addLineToPoint:CGPointMake(lineOffset, CGRectGetHeight(self.bounds) - cornerRadius)];
            }
            if ((self.layer.qmui_maskedCorners & QMUILayerMinXMaxYCorner) == QMUILayerMinXMaxYCorner) {
                [leftPath addArcWithCenter:CGPointMake(cornerRadius, CGRectGetHeight(self.bounds) - cornerRadius) radius:cornerRadius - lineOffset startAngle:-1 * M_PI endAngle:-1.25 * M_PI clockwise:NO];
                [bottomPath addArcWithCenter:CGPointMake(cornerRadius, CGRectGetHeight(self.bounds) - cornerRadius) radius:cornerRadius - lineOffset startAngle:-1.25 * M_PI endAngle:-1.5 * M_PI clockwise:NO];
                [bottomPath addLineToPoint:CGPointMake(CGRectGetWidth(self.bounds) - cornerRadius, CGRectGetHeight(self.bounds) - lineOffset)];
            } else {
                [leftPath addLineToPoint:CGPointMake(lineOffset, CGRectGetHeight(self.bounds) + (shouldShowBottomBorder ? lineCapOffset : 0))];
                CGFloat y = CGRectGetHeight(self.bounds) - lineOffset;
                [bottomPath moveToPoint:CGPointMake(shouldShowLeftBorder ? -lineCapOffset : 0, y)];
                [bottomPath addLineToPoint:CGPointMake(CGRectGetWidth(self.bounds) - cornerRadius, y)];
            }
            if ((self.layer.qmui_maskedCorners & QMUILayerMaxXMaxYCorner) == QMUILayerMaxXMaxYCorner) {
                [bottomPath addArcWithCenter:CGPointMake(CGRectGetHeight(self.bounds) - cornerRadius, CGRectGetHeight(self.bounds) - cornerRadius) radius:cornerRadius - lineOffset startAngle:-1.5 * M_PI endAngle:-1.75 * M_PI clockwise:NO];
                [rightPath addArcWithCenter:CGPointMake(CGRectGetWidth(self.bounds) - cornerRadius, CGRectGetHeight(self.bounds) - cornerRadius) radius:cornerRadius - lineOffset startAngle:-1.75 * M_PI endAngle:-2 * M_PI clockwise:NO];
                [rightPath addLineToPoint:CGPointMake(CGRectGetWidth(self.bounds) - lineOffset, cornerRadius)];
            } else {
                CGFloat y = CGRectGetHeight(self.bounds) - lineOffset;
                [bottomPath addLineToPoint:CGPointMake(CGRectGetWidth(self.bounds) + (shouldShowRightBorder ? lineCapOffset : 0), y)];
                CGFloat x = CGRectGetWidth(self.bounds) - lineOffset;
                [rightPath moveToPoint:CGPointMake(x, CGRectGetHeight(self.bounds) + (shouldShowBottomBorder ? lineCapOffset : 0))];
                [rightPath addLineToPoint:CGPointMake(x, cornerRadius)];
            }
            if ((self.layer.qmui_maskedCorners & QMUILayerMaxXMinYCorner) == QMUILayerMaxXMinYCorner) {
                [rightPath addArcWithCenter:CGPointMake(CGRectGetWidth(self.bounds) - cornerRadius, cornerRadius) radius:cornerRadius - lineOffset startAngle:0 * M_PI endAngle:-0.25 * M_PI clockwise:NO];
                [topPath addArcWithCenter:CGPointMake(CGRectGetWidth(self.bounds) - cornerRadius, cornerRadius) radius:cornerRadius - lineOffset startAngle:1.5 * M_PI endAngle:1.75 * M_PI clockwise:YES];
            } else {
                CGFloat x = CGRectGetWidth(self.bounds) - lineOffset;
                [rightPath addLineToPoint:CGPointMake(x, shouldShowTopBorder ? -lineCapOffset : 0)];
                [topPath addLineToPoint:CGPointMake(CGRectGetWidth(self.bounds) + (shouldShowRightBorder ? lineCapOffset : 0), lineOffset)];
            }
        } else {
            [topPath addArcWithCenter:CGPointMake(cornerRadius, cornerRadius) radius:cornerRadius - lineOffset startAngle:1.25 * M_PI endAngle:1.5 * M_PI clockwise:YES];
            [topPath addLineToPoint:CGPointMake(CGRectGetWidth(self.bounds) - cornerRadius, lineOffset)];
            [topPath addArcWithCenter:CGPointMake(CGRectGetWidth(self.bounds) - cornerRadius, cornerRadius) radius:cornerRadius - lineOffset startAngle:1.5 * M_PI endAngle:1.75 * M_PI clockwise:YES];
            
            [leftPath addArcWithCenter:CGPointMake(cornerRadius, cornerRadius) radius:cornerRadius - lineOffset startAngle:-0.75 * M_PI endAngle:-1 * M_PI clockwise:NO];
            [leftPath addLineToPoint:CGPointMake(lineOffset, CGRectGetHeight(self.bounds) - cornerRadius)];
            [leftPath addArcWithCenter:CGPointMake(cornerRadius, CGRectGetHeight(self.bounds) - cornerRadius) radius:cornerRadius - lineOffset startAngle:-1 * M_PI endAngle:-1.25 * M_PI clockwise:NO];
            
            [bottomPath addArcWithCenter:CGPointMake(cornerRadius, CGRectGetHeight(self.bounds) - cornerRadius) radius:cornerRadius - lineOffset startAngle:-1.25 * M_PI endAngle:-1.5 * M_PI clockwise:NO];
            [bottomPath addLineToPoint:CGPointMake(CGRectGetWidth(self.bounds) - cornerRadius, CGRectGetHeight(self.bounds) - lineOffset)];
            [bottomPath addArcWithCenter:CGPointMake(CGRectGetHeight(self.bounds) - cornerRadius, CGRectGetHeight(self.bounds) - cornerRadius) radius:cornerRadius - lineOffset startAngle:-1.5 * M_PI endAngle:-1.75 * M_PI clockwise:NO];
            
            [rightPath addArcWithCenter:CGPointMake(CGRectGetWidth(self.bounds) - cornerRadius, CGRectGetHeight(self.bounds) - cornerRadius) radius:cornerRadius - lineOffset startAngle:-1.75 * M_PI endAngle:-2 * M_PI clockwise:NO];
            [rightPath addLineToPoint:CGPointMake(CGRectGetWidth(self.bounds) - lineOffset, cornerRadius)];
            [rightPath addArcWithCenter:CGPointMake(CGRectGetWidth(self.bounds) - cornerRadius, cornerRadius) radius:cornerRadius - lineOffset startAngle:0 * M_PI endAngle:-0.25 * M_PI clockwise:NO];
        }
        
    } else {
        [topPath moveToPoint:CGPointMake(shouldShowLeftBorder ? -lineCapOffset : 0, lineOffset)];
        [topPath addLineToPoint:CGPointMake(CGRectGetWidth(self.bounds) + (shouldShowRightBorder ? lineCapOffset : 0), lineOffset)];
        
        [leftPath moveToPoint:CGPointMake(lineOffset, shouldShowTopBorder ? -lineCapOffset : 0)];
        [leftPath addLineToPoint:CGPointMake(lineOffset, CGRectGetHeight(self.bounds) + (shouldShowBottomBorder ? lineCapOffset : 0))];
        
        CGFloat y = CGRectGetHeight(self.bounds) - lineOffset;
        [bottomPath moveToPoint:CGPointMake(shouldShowLeftBorder ? -lineCapOffset : 0, y)];
        [bottomPath addLineToPoint:CGPointMake(CGRectGetWidth(self.bounds) + (shouldShowRightBorder ? lineCapOffset : 0), y)];
        
        CGFloat x = CGRectGetWidth(self.bounds) - lineOffset;
        [rightPath moveToPoint:CGPointMake(x, CGRectGetHeight(self.bounds) + (shouldShowBottomBorder ? lineCapOffset : 0))];
        [rightPath addLineToPoint:CGPointMake(x, shouldShowTopBorder ? -lineCapOffset : 0)];
    }
    
    if (shouldShowTopBorder && ![topPath isEmpty]) {
        [path appendPath:topPath];
    }
    if (shouldShowLeftBorder && ![leftPath isEmpty]) {
        [path appendPath:leftPath];
    }
    if (shouldShowBottomBorder && ![bottomPath isEmpty]) {
        [path appendPath:bottomPath];
    }
    if (shouldShowRightBorder && ![rightPath isEmpty]) {
        [path appendPath:rightPath];
    }
    
    self.qmui_borderLayer.path = path.CGPath;
}

- (void)setDefaultStyle {
    self.qmui_borderWidth = PixelOne;
    self.qmui_borderColor = UIColorSeparator;
}

static char kAssociatedObjectKey_borderLocation;
- (void)setQmui_borderLocation:(QMUIViewBorderLocation)qmui_borderLocation {
    objc_setAssociatedObject(self, &kAssociatedObjectKey_borderLocation, @(qmui_borderLocation), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    [self setNeedsLayout];
}

- (QMUIViewBorderLocation)qmui_borderLocation {
    return [((NSNumber *)objc_getAssociatedObject(self, &kAssociatedObjectKey_borderLocation)) unsignedIntegerValue];
}

static char kAssociatedObjectKey_borderPosition;
- (void)setQmui_borderPosition:(QMUIViewBorderPosition)qmui_borderPosition {
    objc_setAssociatedObject(self, &kAssociatedObjectKey_borderPosition, @(qmui_borderPosition), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    [self setNeedsLayout];
}

- (QMUIViewBorderPosition)qmui_borderPosition {
    return (QMUIViewBorderPosition)[objc_getAssociatedObject(self, &kAssociatedObjectKey_borderPosition) unsignedIntegerValue];
}

static char kAssociatedObjectKey_borderWidth;
- (void)setQmui_borderWidth:(CGFloat)qmui_borderWidth {
    objc_setAssociatedObject(self, &kAssociatedObjectKey_borderWidth, @(qmui_borderWidth), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    [self setNeedsLayout];
}

- (CGFloat)qmui_borderWidth {
    return [((NSNumber *)objc_getAssociatedObject(self, &kAssociatedObjectKey_borderWidth)) qmui_CGFloatValue];
}

static char kAssociatedObjectKey_borderColor;
- (void)setQmui_borderColor:(UIColor *)qmui_borderColor {
    objc_setAssociatedObject(self, &kAssociatedObjectKey_borderColor, qmui_borderColor, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    [self setNeedsLayout];
}

- (UIColor *)qmui_borderColor {
    return (UIColor *)objc_getAssociatedObject(self, &kAssociatedObjectKey_borderColor);
}

static char kAssociatedObjectKey_dashPhase;
- (void)setQmui_dashPhase:(CGFloat)qmui_dashPhase {
    objc_setAssociatedObject(self, &kAssociatedObjectKey_dashPhase, @(qmui_dashPhase), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    [self setNeedsLayout];
}

- (CGFloat)qmui_dashPhase {
    return [(NSNumber *)objc_getAssociatedObject(self, &kAssociatedObjectKey_dashPhase) qmui_CGFloatValue];
}

static char kAssociatedObjectKey_dashPattern;
- (void)setQmui_dashPattern:(NSArray<NSNumber *> *)qmui_dashPattern {
    objc_setAssociatedObject(self, &kAssociatedObjectKey_dashPattern, qmui_dashPattern, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    [self setNeedsLayout];
}

- (NSArray *)qmui_dashPattern {
    return (NSArray<NSNumber *> *)objc_getAssociatedObject(self, &kAssociatedObjectKey_dashPattern);
}

static char kAssociatedObjectKey_borderLayer;
- (void)setQmui_borderLayer:(CAShapeLayer *)qmui_borderLayer {
    objc_setAssociatedObject(self, &kAssociatedObjectKey_borderLayer, qmui_borderLayer, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (CAShapeLayer *)qmui_borderLayer {
    return (CAShapeLayer *)objc_getAssociatedObject(self, &kAssociatedObjectKey_borderLayer);
}

@end


const CGFloat QMUIViewSelfSizingHeight = INFINITY;

@implementation UIView (QMUI_Layout)

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        ExchangeImplementations([UIView class], @selector(setFrame:), @selector(qmui_setFrame:));
    });
}

- (void)qmui_setFrame:(CGRect)frame {
    
    // QMUIViewSelfSizingHeight 的功能
    if (CGRectGetWidth(frame) > 0 && isinf(CGRectGetHeight(frame))) {
        CGFloat height = flat([self sizeThatFits:CGSizeMake(CGRectGetWidth(frame), CGFLOAT_MAX)].height);
        frame = CGRectSetHeight(frame, height);
    }
    
    // 对非法的 frame，Debug 下中 assert，Release 下会将其中的 NaN 改为 0，避免 crash
    if (CGRectIsNaN(frame)) {
        QMUILogWarn(@"UIView (QMUI)", @"%@ setFrame:%@，参数包含 NaN，已被拦截并处理为 0。%@", self, NSStringFromCGRect(frame), [NSThread callStackSymbols]);
        NSAssert(NO, @"UIView setFrame: 出现 NaN");
        if (!IS_DEBUG) {
            frame = CGRectSafeValue(frame);
        }
    }
    
    [self qmui_setFrame:frame];
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

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        ExchangeImplementations([self class], @selector(layoutSubviews), @selector(qmui_debug_layoutSubviews));
    });
}

static char kAssociatedObjectKey_needsDifferentDebugColor;
- (void)setQmui_needsDifferentDebugColor:(BOOL)qmui_needsDifferentDebugColor {
    objc_setAssociatedObject(self, &kAssociatedObjectKey_needsDifferentDebugColor, @(qmui_needsDifferentDebugColor), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}
- (BOOL)qmui_needsDifferentDebugColor {
    BOOL flag = [objc_getAssociatedObject(self, &kAssociatedObjectKey_needsDifferentDebugColor) boolValue];
    return flag;
}

static char kAssociatedObjectKey_shouldShowDebugColor;
- (void)setQmui_shouldShowDebugColor:(BOOL)qmui_shouldShowDebugColor {
    objc_setAssociatedObject(self, &kAssociatedObjectKey_shouldShowDebugColor, @(qmui_shouldShowDebugColor), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    if (qmui_shouldShowDebugColor) {
        [self setNeedsLayout];
    }
}
- (BOOL)qmui_shouldShowDebugColor {
    BOOL flag = [objc_getAssociatedObject(self, &kAssociatedObjectKey_shouldShowDebugColor) boolValue];
    return flag;
}

static char kAssociatedObjectKey_hasDebugColor;
- (void)setQmui_hasDebugColor:(BOOL)qmui_hasDebugColor {
    objc_setAssociatedObject(self, &kAssociatedObjectKey_hasDebugColor, @(qmui_hasDebugColor), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}
- (BOOL)qmui_hasDebugColor {
    BOOL flag = [objc_getAssociatedObject(self, &kAssociatedObjectKey_hasDebugColor) boolValue];
    return flag;
}

- (void)qmui_debug_layoutSubviews {
    [self qmui_debug_layoutSubviews];
    if (self.qmui_shouldShowDebugColor) {
        self.qmui_hasDebugColor = YES;
        self.backgroundColor = [self debugColor];
        [self renderColorWithSubviews:self.subviews];
    }
}

- (void)renderColorWithSubviews:(NSArray *)subviews {
    for (UIView *view in subviews) {
        if (@available(iOS 9.0, *)) {
            if ([view isKindOfClass:[UIStackView class]]) {
                UIStackView *stackView = (UIStackView *)view;
                [self renderColorWithSubviews:stackView.arrangedSubviews];
            }
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
