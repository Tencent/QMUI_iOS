/*****
 * Tencent is pleased to support the open source community by making QMUI_iOS available.
 * Copyright (C) 2016-2019 THL A29 Limited, a Tencent company. All rights reserved.
 * Licensed under the MIT License (the "License"); you may not use this file except in compliance with the License. You may obtain a copy of the License at
 * http://opensource.org/licenses/MIT
 * Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.
 *****/

//
//  QMUIPopupContainerView.m
//  qmui
//
//  Created by QMUI Team on 15/12/17.
//

#import "QMUIPopupContainerView.h"
#import "QMUICore.h"
#import "QMUICommonViewController.h"
#import "UIViewController+QMUI.h"
#import "QMUILog.h"
#import "UIView+QMUI.h"
#import "UIWindow+QMUI.h"
#import "UIBarItem+QMUI.h"

@interface QMUIPopupContainerViewWindow : UIWindow

@end

@interface QMUIPopContainerViewController : QMUICommonViewController

@end

@interface QMUIPopContainerMaskControl : UIControl

@property(nonatomic, weak) QMUIPopupContainerView *popupContainerView;
@end

@interface QMUIPopupContainerView (UIAppearance)

- (void)updateAppearance;
@end

@interface QMUIPopupContainerView () {
    UIImageView                     *_imageView;
    UILabel                         *_textLabel;
}

@property(nonatomic, strong) QMUIPopupContainerViewWindow *popupWindow;
@property(nonatomic, weak) UIWindow *previousKeyWindow;
@property(nonatomic, assign) BOOL hidesByUserTap;
@end

@implementation QMUIPopupContainerView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self didInitialize];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
        [self didInitialize];
    }
    return self;
}

- (void)dealloc {
    _sourceView.qmui_frameDidChangeBlock = nil;
}

- (UIImageView *)imageView {
    if (!_imageView) {
        _imageView = [[UIImageView alloc] init];
        _imageView.contentMode = UIViewContentModeCenter;
        [self.contentView addSubview:_imageView];
    }
    return _imageView;
}

- (UILabel *)textLabel {
    if (!_textLabel) {
        _textLabel = [[UILabel alloc] init];
        _textLabel.font = UIFontMake(12);
        _textLabel.textColor = UIColorBlack;
        _textLabel.numberOfLines = 0;
        [self.contentView addSubview:_textLabel];
    }
    return _textLabel;
}

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
    UIView *result = [super hitTest:point withEvent:event];
    if (result == self.contentView) {
        return self;
    }
    return result;
}

- (void)setBackgroundColor:(UIColor *)backgroundColor {
    _backgroundColor = backgroundColor;
    _backgroundLayer.fillColor = _backgroundColor.CGColor;
}

- (void)setMaskViewBackgroundColor:(UIColor *)maskViewBackgroundColor {
    _maskViewBackgroundColor = maskViewBackgroundColor;
    if (self.popupWindow) {
        self.popupWindow.rootViewController.view.backgroundColor = maskViewBackgroundColor;
    }
}

- (void)setShadowColor:(UIColor *)shadowColor {
    _shadowColor = shadowColor;
    _backgroundLayer.shadowColor = shadowColor.CGColor;
}

- (void)setBorderColor:(UIColor *)borderColor {
    _borderColor = borderColor;
    _backgroundLayer.strokeColor = borderColor.CGColor;
}

- (void)setBorderWidth:(CGFloat)borderWidth {
    _borderWidth = borderWidth;
    _backgroundLayer.lineWidth = _borderWidth;
}

- (void)setCornerRadius:(CGFloat)cornerRadius {
    _cornerRadius = cornerRadius;
    [self setNeedsLayout];
}

- (void)setHighlighted:(BOOL)highlighted {
    [super setHighlighted:highlighted];
    if (self.highlightedBackgroundColor) {
        _backgroundLayer.fillColor = highlighted ? self.highlightedBackgroundColor.CGColor : self.backgroundColor.CGColor;
    }
}

- (CGSize)sizeThatFits:(CGSize)size {
    size.width = MIN(size.width, CGRectGetWidth(self.superview.bounds) - UIEdgeInsetsGetHorizontalValue(self.safetyMarginsOfSuperview));
    size.height = MIN(size.height, CGRectGetHeight(self.superview.bounds) - UIEdgeInsetsGetVerticalValue(self.safetyMarginsOfSuperview));
    
    CGSize contentLimitSize = [self contentSizeInSize:size];
    CGSize contentSize = [self sizeThatFitsInContentView:contentLimitSize];
    CGSize resultSize = [self sizeWithContentSize:contentSize sizeThatFits:size];
    return resultSize;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    CGSize arrowSize = self.arrowSize;
    CGRect roundedRect = CGRectMake(self.borderWidth / 2.0, self.borderWidth / 2.0 + (self.currentLayoutDirection == QMUIPopupContainerViewLayoutDirectionAbove ? 0 : arrowSize.height), CGRectGetWidth(self.bounds) - self.borderWidth, CGRectGetHeight(self.bounds) - arrowSize.height - self.borderWidth);
    CGFloat cornerRadius = self.cornerRadius;
    
    CGPoint leftTopArcCenter = CGPointMake(CGRectGetMinX(roundedRect) + cornerRadius, CGRectGetMinY(roundedRect) + cornerRadius);
    CGPoint leftBottomArcCenter = CGPointMake(leftTopArcCenter.x, CGRectGetMaxY(roundedRect) - cornerRadius);
    CGPoint rightTopArcCenter = CGPointMake(CGRectGetMaxX(roundedRect) - cornerRadius, leftTopArcCenter.y);
    CGPoint rightBottomArcCenter = CGPointMake(rightTopArcCenter.x, leftBottomArcCenter.y);
    
    UIBezierPath *path = [UIBezierPath bezierPath];
    [path moveToPoint:CGPointMake(leftTopArcCenter.x, CGRectGetMinY(roundedRect))];
    [path addArcWithCenter:leftTopArcCenter radius:cornerRadius startAngle:M_PI * 1.5 endAngle:M_PI clockwise:NO];
    [path addLineToPoint:CGPointMake(CGRectGetMinX(roundedRect), leftBottomArcCenter.y)];
    [path addArcWithCenter:leftBottomArcCenter radius:cornerRadius startAngle:M_PI endAngle:M_PI * 0.5 clockwise:NO];
    
    if (self.currentLayoutDirection == QMUIPopupContainerViewLayoutDirectionAbove) {
        // 让开，我要开始开始画三角形了，箭头向下
        [path addLineToPoint:CGPointMake(_arrowMinX, CGRectGetMaxY(roundedRect))];
        [path addLineToPoint:CGPointMake(_arrowMinX + arrowSize.width / 2, CGRectGetMaxY(roundedRect) + arrowSize.height)];
        [path addLineToPoint:CGPointMake(_arrowMinX + arrowSize.width, CGRectGetMaxY(roundedRect))];
    }
    
    [path addLineToPoint:CGPointMake(rightBottomArcCenter.x, CGRectGetMaxY(roundedRect))];
    [path addArcWithCenter:rightBottomArcCenter radius:cornerRadius startAngle:M_PI * 0.5 endAngle:0.0 clockwise:NO];
    [path addLineToPoint:CGPointMake(CGRectGetMaxX(roundedRect), rightTopArcCenter.y)];
    [path addArcWithCenter:rightTopArcCenter radius:cornerRadius startAngle:0.0 endAngle:M_PI * 1.5 clockwise:NO];
    
    if (self.currentLayoutDirection == QMUIPopupContainerViewLayoutDirectionBelow) {
        // 箭头向上
        [path addLineToPoint:CGPointMake(_arrowMinX + arrowSize.width, CGRectGetMinY(roundedRect))];
        [path addLineToPoint:CGPointMake(_arrowMinX + arrowSize.width / 2, CGRectGetMinY(roundedRect) - arrowSize.height)];
        [path addLineToPoint:CGPointMake(_arrowMinX, CGRectGetMinY(roundedRect))];
    }
    [path closePath];
    
    _backgroundLayer.path = path.CGPath;
    _backgroundLayer.shadowPath = path.CGPath;
    _backgroundLayer.frame = self.bounds;
    
    [self layoutDefaultSubviews];
}

- (void)layoutDefaultSubviews {
    self.contentView.frame = CGRectMake(self.borderWidth + self.contentEdgeInsets.left, (self.currentLayoutDirection == QMUIPopupContainerViewLayoutDirectionAbove ? self.borderWidth : self.arrowSize.height + self.borderWidth) + self.contentEdgeInsets.top, CGRectGetWidth(self.bounds) - self.borderWidth * 2 - UIEdgeInsetsGetHorizontalValue(self.contentEdgeInsets), CGRectGetHeight(self.bounds) - self.arrowSize.height - self.borderWidth * 2 - UIEdgeInsetsGetVerticalValue(self.contentEdgeInsets));
    // contentView的圆角取一个比整个path的圆角小的最大值（极限情况下如果self.contentEdgeInsets.left比self.cornerRadius还大，那就意味着contentView不需要圆角了）
    // 这么做是为了尽量去掉contentView对内容不必要的裁剪，以免有些东西被裁剪了看不到
    CGFloat contentViewCornerRadius = fabs(MIN(CGRectGetMinX(self.contentView.frame) - self.cornerRadius, 0));
    self.contentView.layer.cornerRadius = contentViewCornerRadius;
    
    BOOL isImageViewShowing = [self isSubviewShowing:_imageView];
    BOOL isTextLabelShowing = [self isSubviewShowing:_textLabel];
    if (isImageViewShowing) {
        [_imageView sizeToFit];
        _imageView.frame = CGRectSetXY(_imageView.frame, self.imageEdgeInsets.left, CGFloatGetCenter(CGRectGetHeight(self.contentView.bounds), CGRectGetHeight(_imageView.frame) + self.imageEdgeInsets.top));
    }
    if (isTextLabelShowing) {
        CGFloat textLabelMinX = (isImageViewShowing ? ceil(CGRectGetMaxX(_imageView.frame) + self.imageEdgeInsets.right) : 0) + self.textEdgeInsets.left;
        CGSize textLabelLimitSize = CGSizeMake(ceil(CGRectGetWidth(self.contentView.bounds) - textLabelMinX), ceil(CGRectGetHeight(self.contentView.bounds) - self.textEdgeInsets.top - self.textEdgeInsets.bottom));
        CGSize textLabelSize = [_textLabel sizeThatFits:textLabelLimitSize];
        CGPoint textLabelOrigin = CGPointMake(textLabelMinX, flat(CGFloatGetCenter(CGRectGetHeight(self.contentView.bounds), ceil(textLabelSize.height)) + self.textEdgeInsets.top));
        _textLabel.frame = CGRectMake(textLabelOrigin.x, textLabelOrigin.y, textLabelLimitSize.width, ceil(textLabelSize.height));
    }
}

- (void)setSourceBarItem:(__kindof UIBarItem *)sourceBarItem {
    _sourceBarItem = sourceBarItem;
    __weak __typeof(self)weakSelf = self;
    if (!sourceBarItem.qmui_viewLayoutDidChangeBlock) {
        sourceBarItem.qmui_viewLayoutDidChangeBlock = ^(__kindof UIBarItem * _Nonnull item, UIView * _Nullable view) {
            if (!view.window || !weakSelf.superview) return;
            UIView *convertToView = weakSelf.popupWindow ? UIApplication.sharedApplication.delegate.window : weakSelf.superview;// 对于以 window 方式显示的情况，由于横竖屏旋转时，不同 window 的旋转顺序不同，所以可能导致 sourceBarItem 所在的 window 已经旋转了但 popupWindow 还没旋转（iOS 11 及以后），那么计算出来的坐标就错了，所以这里改为用 UIApplication window
            CGRect rect = [view qmui_convertRect:view.bounds toView:convertToView];
            weakSelf.sourceRect = rect;
        };
    }
    if (sourceBarItem.qmui_view && sourceBarItem.qmui_viewLayoutDidChangeBlock) {
        sourceBarItem.qmui_viewLayoutDidChangeBlock(sourceBarItem, sourceBarItem.qmui_view);// update layout immediately
    }
}

- (void)setSourceView:(__kindof UIView *)sourceView {
    _sourceView = sourceView;
    __weak __typeof(self)weakSelf = self;
    sourceView.qmui_frameDidChangeBlock = ^(__kindof UIView * _Nonnull view, CGRect precedingFrame) {
        if (!view.window || !weakSelf.superview) return;
        UIView *convertToView = weakSelf.popupWindow ? UIApplication.sharedApplication.delegate.window : weakSelf.superview;// 对于以 window 方式显示的情况，由于横竖屏旋转时，不同 window 的旋转顺序不同，所以可能导致 sourceBarItem 所在的 window 已经旋转了但 popupWindow 还没旋转（iOS 11 及以后），那么计算出来的坐标就错了，所以这里改为用 UIApplication window
        CGRect rect = [view qmui_convertRect:view.bounds toView:convertToView];
        weakSelf.sourceRect = rect;
    };
    sourceView.qmui_frameDidChangeBlock(sourceView, sourceView.frame);// update layout immediately
}

- (void)setSourceRect:(CGRect)sourceRect {
    _sourceRect = sourceRect;
    if (self.isShowing) {
        [self layoutWithTargetRect:sourceRect];
    }
}

- (void)updateLayout {
    // call setter to layout immediately
    if (self.sourceBarItem) {
        self.sourceBarItem = self.sourceBarItem;
    } else if (self.sourceView) {
        self.sourceView = self.sourceView;
    } else {
        self.sourceRect = self.sourceRect;
    }
}

// 参数 targetRect 在 window 模式下是 window 的坐标系内的，如果是 subview 模式下则是 superview 坐标系内的
- (void)layoutWithTargetRect:(CGRect)targetRect {
    UIView *superview = self.superview;
    if (!superview) {
        return;
    }
    
    targetRect = self.popupWindow ? [self.popupWindow convertRect:targetRect toView:superview] : targetRect;
    CGRect containerRect = superview.bounds;
    
    CGSize tipSize = [self sizeThatFits:CGSizeMake(self.maximumWidth, self.maximumHeight)];
    CGFloat preferredTipWidth = tipSize.width;
    
    // 保护tips最往左只能到达self.safetyMarginsOfSuperview.left
    CGFloat a = CGRectGetMidX(targetRect) - tipSize.width / 2;
    CGFloat tipMinX = MAX(CGRectGetMinX(containerRect) + self.safetyMarginsOfSuperview.left, a);
    
    CGFloat tipMaxX = tipMinX + tipSize.width;
    if (tipMaxX + self.safetyMarginsOfSuperview.right > CGRectGetMaxX(containerRect)) {
        // 右边超出了
        // 先尝试把右边超出的部分往左边挪，看是否会令左边到达临界点
        CGFloat distanceCanMoveToLeft = tipMaxX - (CGRectGetMaxX(containerRect) - self.safetyMarginsOfSuperview.right);
        if (tipMinX - distanceCanMoveToLeft >= CGRectGetMinX(containerRect) + self.safetyMarginsOfSuperview.left) {
            // 可以往左边挪
            tipMinX -= distanceCanMoveToLeft;
        } else {
            // 不可以往左边挪，那么让左边靠到临界点，然后再把宽度减小，以让右边处于临界点以内
            tipMinX = CGRectGetMinX(containerRect) + self.safetyMarginsOfSuperview.left;
            tipMaxX = CGRectGetMaxX(containerRect) - self.safetyMarginsOfSuperview.right;
            tipSize.width = MIN(tipSize.width, tipMaxX - tipMinX);
        }
    }
    
    // 经过上面一番调整，可能tipSize.width发生变化，一旦宽度变化，高度要重新计算，所以重新调用一次sizeThatFits
    BOOL tipWidthChanged = tipSize.width != preferredTipWidth;
    if (tipWidthChanged) {
        tipSize = [self sizeThatFits:tipSize];
    }
    
    _currentLayoutDirection = self.preferLayoutDirection;
    
    // 检查当前的最大高度是否超过任一方向的剩余空间，如果是，则强制减小最大高度，避免后面计算布局选择方向时死循环
    BOOL canShowAtAbove = [self canTipShowAtSpecifiedLayoutDirect:QMUIPopupContainerViewLayoutDirectionAbove targetRect:targetRect tipSize:tipSize];
    BOOL canShowAtBelow = [self canTipShowAtSpecifiedLayoutDirect:QMUIPopupContainerViewLayoutDirectionBelow targetRect:targetRect tipSize:tipSize];
    
    if (!canShowAtAbove && !canShowAtBelow) {
        // 上下都没有足够的空间，所以要调整maximumHeight
        CGFloat maximumHeightAbove = CGRectGetMinY(targetRect) - CGRectGetMinY(containerRect) - self.distanceBetweenSource - self.safetyMarginsOfSuperview.top;
        CGFloat maximumHeightBelow = CGRectGetMaxY(containerRect) - self.safetyMarginsOfSuperview.bottom - self.distanceBetweenSource - CGRectGetMaxY(targetRect);
        self.maximumHeight = MAX(self.minimumHeight, MAX(maximumHeightAbove, maximumHeightBelow));
        tipSize.height = self.maximumHeight;
        _currentLayoutDirection = maximumHeightAbove > maximumHeightBelow ? QMUIPopupContainerViewLayoutDirectionAbove : QMUIPopupContainerViewLayoutDirectionBelow;
        
        QMUILog(NSStringFromClass(self.class), @"%@, 因为上下都不够空间，所以最大高度被强制改为%@, 位于目标的%@", self, @(self.maximumHeight), maximumHeightAbove > maximumHeightBelow ? @"上方" : @"下方");
        
    } else if (_currentLayoutDirection == QMUIPopupContainerViewLayoutDirectionAbove && !canShowAtAbove) {
        _currentLayoutDirection = QMUIPopupContainerViewLayoutDirectionBelow;
    } else if (_currentLayoutDirection == QMUIPopupContainerViewLayoutDirectionBelow && !canShowAtBelow) {
        _currentLayoutDirection = QMUIPopupContainerViewLayoutDirectionAbove;
    }
    
    CGFloat tipMinY = [self tipMinYWithTargetRect:targetRect tipSize:tipSize preferLayoutDirection:_currentLayoutDirection];
    
    // 当上下的剩余空间都比最小高度要小的时候，tip会靠在safetyMargins范围内的上（下）边缘
    if (_currentLayoutDirection == QMUIPopupContainerViewLayoutDirectionAbove) {
        CGFloat tipMinYIfAlignSafetyMarginTop = CGRectGetMinY(containerRect) + self.safetyMarginsOfSuperview.top;
        tipMinY = MAX(tipMinY, tipMinYIfAlignSafetyMarginTop);
    } else if (_currentLayoutDirection == QMUIPopupContainerViewLayoutDirectionBelow) {
        CGFloat tipMinYIfAlignSafetyMarginBottom = CGRectGetMaxY(containerRect) - self.safetyMarginsOfSuperview.bottom - tipSize.height;
        tipMinY = MIN(tipMinY, tipMinYIfAlignSafetyMarginBottom);
    }
    
    self.frame = CGRectFlatMake(tipMinX, tipMinY, tipSize.width, tipSize.height);
    
    // 调整浮层里的箭头的位置
    CGPoint targetRectCenter = CGPointGetCenterWithRect(targetRect);
    CGFloat selfMidX = targetRectCenter.x - CGRectGetMinX(self.frame);
    _arrowMinX = selfMidX - self.arrowSize.width / 2;
    [self setNeedsLayout];
    
    if (self.debug) {
        self.contentView.backgroundColor = UIColorTestGreen;
        self.borderColor = UIColorRed;
        self.borderWidth = PixelOne;
        _imageView.backgroundColor = UIColorTestRed;
        _textLabel.backgroundColor = UIColorTestBlue;
    }
}

- (CGFloat)tipMinYWithTargetRect:(CGRect)itemRect tipSize:(CGSize)tipSize preferLayoutDirection:(QMUIPopupContainerViewLayoutDirection)direction {
    CGFloat tipMinY = 0;
    if (direction == QMUIPopupContainerViewLayoutDirectionAbove) {
        tipMinY = CGRectGetMinY(itemRect) - tipSize.height - self.distanceBetweenSource;
    } else if (direction == QMUIPopupContainerViewLayoutDirectionBelow) {
        tipMinY = CGRectGetMaxY(itemRect) + self.distanceBetweenSource;
    }
    return tipMinY;
}

- (BOOL)canTipShowAtSpecifiedLayoutDirect:(QMUIPopupContainerViewLayoutDirection)direction targetRect:(CGRect)itemRect tipSize:(CGSize)tipSize {
    BOOL canShow = NO;
    CGFloat tipMinY = [self tipMinYWithTargetRect:itemRect tipSize:tipSize preferLayoutDirection:direction];
    if (direction == QMUIPopupContainerViewLayoutDirectionAbove) {
        canShow = tipMinY >= self.safetyMarginsOfSuperview.top;
    } else if (direction == QMUIPopupContainerViewLayoutDirectionBelow) {
        canShow = tipMinY + tipSize.height + self.safetyMarginsOfSuperview.bottom <= CGRectGetHeight(self.superview.bounds);
    }
    return canShow;
}

- (void)showWithAnimated:(BOOL)animated {
    [self showWithAnimated:animated completion:nil];
}

- (void)showWithAnimated:(BOOL)animated completion:(void (^)(BOOL))completion {
    
    BOOL isShowingByWindowMode = NO;
    if (!self.superview) {
        [self initPopupContainerViewWindowIfNeeded];
        
        QMUICommonViewController *viewController = (QMUICommonViewController *)self.popupWindow.rootViewController;
        viewController.supportedOrientationMask = [QMUIHelper visibleViewController].supportedInterfaceOrientations;
        
        self.previousKeyWindow = [UIApplication sharedApplication].keyWindow;
        [self.popupWindow makeKeyAndVisible];
        
        isShowingByWindowMode = YES;
    } else {
        self.hidden = NO;
    }
    
    [self updateLayout];
    
    if (self.willShowBlock) {
        self.willShowBlock(animated);
    }
    
    if (animated) {
        if (isShowingByWindowMode) {
            self.popupWindow.alpha = 0;
        } else {
            self.alpha = 0;
        }
        self.layer.transform = CATransform3DMakeScale(0.98, 0.98, 1);
        [UIView animateWithDuration:0.4 delay:0 usingSpringWithDamping:0.3 initialSpringVelocity:12 options:UIViewAnimationOptionCurveLinear animations:^{
            self.layer.transform = CATransform3DMakeScale(1, 1, 1);
        } completion:^(BOOL finished) {
            if (completion) {
                completion(finished);
            }
        }];
        [UIView animateWithDuration:0.2 delay:0 options:UIViewAnimationOptionCurveLinear animations:^{
            if (isShowingByWindowMode) {
                self.popupWindow.alpha = 1;
            } else {
                self.alpha = 1;
            }
        } completion:nil];
    } else {
        if (isShowingByWindowMode) {
            self.popupWindow.alpha = 1;
        } else {
            self.alpha = 1;
        }
        if (completion) {
            completion(YES);
        }
    }
}

- (void)hideWithAnimated:(BOOL)animated {
    [self hideWithAnimated:animated completion:nil];
}

- (void)hideWithAnimated:(BOOL)animated completion:(void (^)(BOOL))completion {
    if (self.willHideBlock) {
        self.willHideBlock(self.hidesByUserTap, animated);
    }
    
    BOOL isShowingByWindowMode = !!self.popupWindow;
    
    if (animated) {
        [UIView animateWithDuration:0.2 delay:0 options:UIViewAnimationOptionCurveLinear animations:^{
            if (isShowingByWindowMode) {
                self.popupWindow.alpha = 0;
            } else {
                self.alpha = 0;
            }
        } completion:^(BOOL finished) {
            [self hideCompletionWithWindowMode:isShowingByWindowMode completion:completion];
        }];
    } else {
        [self hideCompletionWithWindowMode:isShowingByWindowMode completion:completion];
    }
}

- (void)hideCompletionWithWindowMode:(BOOL)windowMode completion:(void (^)(BOOL))completion {
    if (windowMode) {
        // 恢复 keyWindow 之前做一下检查，避免类似问题 https://github.com/Tencent/QMUI_iOS/issues/90
        if ([[UIApplication sharedApplication] keyWindow] == self.popupWindow) {
            [self.previousKeyWindow makeKeyWindow];
        }
        
        // iOS 9 下（iOS 8 和 10 都没问题）需要主动移除，才能令 rootViewController 和 popupWindow 立即释放，不影响后续的 layout 判断，如果不加这两句，虽然 popupWindow 指针被置为 nil，但其实对象还存在，View 层级关系也还在
        // https://github.com/Tencent/QMUI_iOS/issues/75
        [self removeFromSuperview];
        self.popupWindow.rootViewController = nil;
        
        self.popupWindow.hidden = YES;
        self.popupWindow = nil;
    } else {
        self.hidden = YES;
    }
    if (completion) {
        completion(YES);
    }
    if (self.didHideBlock) {
        self.didHideBlock(self.hidesByUserTap);
    }
    self.hidesByUserTap = NO;
}

- (BOOL)isShowing {
    BOOL isShowingIfAddedToView = self.superview && !self.hidden && !self.popupWindow;
    BOOL isShowingIfInWindow = self.superview && self.popupWindow && !self.popupWindow.hidden;
    return isShowingIfAddedToView || isShowingIfInWindow;
}

#pragma mark - Private Tools

- (BOOL)isSubviewShowing:(UIView *)subview {
    return subview && !subview.hidden && subview.superview;
}

- (void)initPopupContainerViewWindowIfNeeded {
    if (!self.popupWindow) {
        self.popupWindow = [[QMUIPopupContainerViewWindow alloc] init];
        self.popupWindow.qmui_capturesStatusBarAppearance = NO;
        self.popupWindow.backgroundColor = UIColorClear;
        self.popupWindow.windowLevel = UIWindowLevelQMUIAlertView;
        QMUIPopContainerViewController *viewController = [[QMUIPopContainerViewController alloc] init];
        ((QMUIPopContainerMaskControl *)viewController.view).popupContainerView = self;
        if (self.automaticallyHidesWhenUserTap) {
            viewController.view.backgroundColor = self.maskViewBackgroundColor;
        } else {
            viewController.view.backgroundColor = UIColorClear;
        }
        viewController.supportedOrientationMask = [QMUIHelper visibleViewController].supportedInterfaceOrientations;
        self.popupWindow.rootViewController = viewController;// 利用 rootViewController 来管理横竖屏
        [self.popupWindow.rootViewController.view addSubview:self];
    }
}

/// 根据一个给定的大小，计算出符合这个大小的内容大小
- (CGSize)contentSizeInSize:(CGSize)size {
    CGSize contentSize = CGSizeMake(size.width - UIEdgeInsetsGetHorizontalValue(self.contentEdgeInsets) - self.borderWidth * 2, size.height - self.arrowSize.height - UIEdgeInsetsGetVerticalValue(self.contentEdgeInsets) - self.borderWidth * 2);
    return contentSize;
}

/// 根据内容大小和外部限制的大小，计算出合适的self size（包含箭头）
- (CGSize)sizeWithContentSize:(CGSize)contentSize sizeThatFits:(CGSize)sizeThatFits {
    CGFloat resultWidth = contentSize.width + UIEdgeInsetsGetHorizontalValue(self.contentEdgeInsets) + self.borderWidth * 2;
    resultWidth = MIN(resultWidth, sizeThatFits.width);// 宽度不能超过传进来的size.width
    resultWidth = MAX(MIN(resultWidth, self.maximumWidth), self.minimumWidth);// 宽度必须在最小值和最大值之间
    resultWidth = ceil(resultWidth);
    
    CGFloat resultHeight = contentSize.height + UIEdgeInsetsGetVerticalValue(self.contentEdgeInsets) + self.arrowSize.height + self.borderWidth * 2;
    resultHeight = MIN(resultHeight, sizeThatFits.height);
    resultHeight = MAX(MIN(resultHeight, self.maximumHeight), self.minimumHeight);
    resultHeight = ceil(resultHeight);
    
    return CGSizeMake(resultWidth, resultHeight);
}

@end

@implementation QMUIPopupContainerView (UISubclassingHooks)

- (void)didInitialize {
    _backgroundLayer = [CAShapeLayer layer];
    _backgroundLayer.shadowOffset = CGSizeMake(0, 2);
    _backgroundLayer.shadowOpacity = 1;
    _backgroundLayer.shadowRadius = 10;
    [self.layer addSublayer:_backgroundLayer];
    
    _contentView = [[UIView alloc] init];
    self.contentView.clipsToBounds = YES;
    [self addSubview:self.contentView];
    
    // 由于浮层是在调用 showWithAnimated: 时才会被添加到 window 上，所以 appearance 也是在 showWithAnimated: 后才生效，这太晚了，会导致 showWithAnimated: 之前用到那些支持 appearance 的属性值都不准确，所以这里手动提前触发。
    [self updateAppearance];
}

- (CGSize)sizeThatFitsInContentView:(CGSize)size {
    // 如果没内容则返回自身大小
    if (![self isSubviewShowing:_imageView] && ![self isSubviewShowing:_textLabel]) {
        CGSize selfSize = [self contentSizeInSize:self.bounds.size];
        return selfSize;
    }
    
    CGSize resultSize = CGSizeZero;
    
    BOOL isImageViewShowing = [self isSubviewShowing:_imageView];
    if (isImageViewShowing) {
        CGSize imageViewSize = [_imageView sizeThatFits:size];
        resultSize.width += ceil(imageViewSize.width) + self.imageEdgeInsets.left;
        resultSize.height += ceil(imageViewSize.height) + self.imageEdgeInsets.top;
    }
    
    BOOL isTextLabelShowing = [self isSubviewShowing:_textLabel];
    if (isTextLabelShowing) {
        CGSize textLabelLimitSize = CGSizeMake(size.width - resultSize.width - self.imageEdgeInsets.right, size.height);
        CGSize textLabelSize = [_textLabel sizeThatFits:textLabelLimitSize];
        resultSize.width += (isImageViewShowing ? self.imageEdgeInsets.right : 0) + ceil(textLabelSize.width) + self.textEdgeInsets.left;
        resultSize.height = MAX(resultSize.height, ceil(textLabelSize.height) + self.textEdgeInsets.top);
    }
    resultSize.width = MIN(size.width, resultSize.width);
    resultSize.height = MIN(size.height, resultSize.height);
    return resultSize;
}

@end

@implementation QMUIPopupContainerView (UIAppearance)

+ (void)initialize {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        [self setDefaultAppearance];
    });
}

+ (void)setDefaultAppearance {
    QMUIPopupContainerView *appearance = [QMUIPopupContainerView appearance];
    appearance.contentEdgeInsets = UIEdgeInsetsMake(8, 8, 8, 8);
    appearance.arrowSize = CGSizeMake(18, 9);
    appearance.maximumWidth = CGFLOAT_MAX;
    appearance.minimumWidth = 0;
    appearance.maximumHeight = CGFLOAT_MAX;
    appearance.minimumHeight = 0;
    appearance.preferLayoutDirection = QMUIPopupContainerViewLayoutDirectionAbove;
    appearance.distanceBetweenSource = 5;
    appearance.safetyMarginsOfSuperview = UIEdgeInsetsMake(10, 10, 10, 10);
    appearance.backgroundColor = UIColorWhite;
    appearance.maskViewBackgroundColor = UIColorMask;
    appearance.highlightedBackgroundColor = nil;
    appearance.shadowColor = UIColorMakeWithRGBA(0, 0, 0, .1);
    appearance.borderColor = UIColorGrayLighten;
    appearance.borderWidth = PixelOne;
    appearance.cornerRadius = 10;
    appearance.qmui_outsideEdge = UIEdgeInsetsZero;
    
}

- (void)updateAppearance {
    QMUIPopupContainerView *appearance = [QMUIPopupContainerView appearance];
    self.contentEdgeInsets = appearance.contentEdgeInsets;
    self.arrowSize = appearance.arrowSize;
    self.maximumWidth = appearance.maximumWidth;
    self.minimumWidth = appearance.minimumWidth;
    self.maximumHeight = appearance.maximumHeight;
    self.minimumHeight = appearance.minimumHeight;
    self.preferLayoutDirection = appearance.preferLayoutDirection;
    self.safetyMarginsOfSuperview = appearance.safetyMarginsOfSuperview;
    self.distanceBetweenSource = appearance.distanceBetweenSource;
    self.backgroundColor = appearance.backgroundColor;
    self.maskViewBackgroundColor = appearance.maskViewBackgroundColor;
    self.shadowColor = appearance.shadowColor;
    self.borderColor = appearance.borderColor;
    self.borderWidth = appearance.borderWidth;
    self.cornerRadius = appearance.cornerRadius;
    self.qmui_outsideEdge = appearance.qmui_outsideEdge;
}

@end

@implementation QMUIPopContainerViewController

- (void)loadView {
    QMUIPopContainerMaskControl *maskControl = [[QMUIPopContainerMaskControl alloc] init];
    self.view = maskControl;
}

@end

@implementation QMUIPopContainerMaskControl

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self addTarget:self action:@selector(handleMaskEvent:) forControlEvents:UIControlEventTouchDown];
    }
    return self;
}

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
    UIView *result = [super hitTest:point withEvent:event];
    if (result == self) {
        if (!self.popupContainerView.automaticallyHidesWhenUserTap) {
            return nil;
        }
    }
    return result;
}

// 把点击遮罩的事件放在 addTarget: 里而不直接在 hitTest:withEvent: 里处理是因为 hitTest:withEvent: 总是会走两遍
- (void)handleMaskEvent:(id)sender {
    if (self.popupContainerView.automaticallyHidesWhenUserTap) {
        self.popupContainerView.hidesByUserTap = YES;
        [self.popupContainerView hideWithAnimated:YES];
    }
}

- (void)layoutSubviews {
    [super layoutSubviews];
    [self.popupContainerView updateLayout];// 横竖屏旋转时，可能 sourceView window 已经旋转，但 popupWindow 尚未旋转，所以在 popupWindow 布局更新完成后再刷新一次 popup 的布局
}

@end

@implementation QMUIPopupContainerViewWindow

// 避免 UIWindow 拦截掉事件，保证让事件继续往背后传递
- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
    UIView *result = [super hitTest:point withEvent:event];
    if (result == self) {
        return nil;
    }
    return result;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    self.rootViewController.view.frame = self.bounds;// 保证来电模式下也是撑满全屏
}

@end
