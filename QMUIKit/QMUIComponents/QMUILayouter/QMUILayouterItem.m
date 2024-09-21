/**
 * Tencent is pleased to support the open source community by making QMUI_iOS available.
 * Copyright (C) 2016-2021 THL A29 Limited, a Tencent company. All rights reserved.
 * Licensed under the MIT License (the "License"); you may not use this file except in compliance with the License. You may obtain a copy of the License at
 * http://opensource.org/licenses/MIT
 * Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.
 */

//
//  QMUILayouterItem.m
//  QMUIKit
//
//  Created by QMUI Team on 2024/1/2.
//

#import "QMUILayouterItem.h"
#import "QMUICore.h"
#import "NSArray+QMUI.h"
#import "NSString+QMUI.h"
#import "CALayer+QMUI.h"
#import "UIColor+QMUI.h"

const CGFloat QMUILayouterGrowNever = 0.0;
const CGFloat QMUILayouterGrowMost = 99.0;
const CGFloat QMUILayouterShrinkDefault = 1.0;
const CGFloat QMUILayouterShrinkNever = 0.0;
const CGFloat QMUILayouterShrinkMost = 99.0;

@interface QMUILayouterItem ()
@property(nonatomic, strong) CALayer *debugBorderLayer;
@end

@implementation QMUILayouterItem {
    BOOL _shouldInvalidateLayout;
}

+ (instancetype)itemWithView:(__kindof UIView *)view margin:(UIEdgeInsets)margin {
    return [self itemWithView:view margin:margin grow:QMUILayouterGrowNever shrink:QMUILayouterShrinkNever];
}

+ (instancetype)itemWithView:(__kindof UIView *)view margin:(UIEdgeInsets)margin grow:(CGFloat)grow shrink:(CGFloat)shrink {
    QMUILayouterItem *item = [[self alloc] init];
    item.view = view;
    item.margin = margin;
    item.grow = grow;
    item.shrink = shrink;
    return item;
}

- (instancetype)init {
    if (self = [super init]) {
        _maximumSize = CGSizeMax;
        _minimumSize = CGSizeZero;
    }
    return self;
}

- (NSString *)description {
    NSString * (^growName)(CGFloat grow) = ^NSString * (CGFloat grow) {
        if (grow == QMUILayouterGrowNever) return @"Never";
        if (grow == QMUILayouterGrowMost) return @"Most";
        return [NSString stringWithFormat:@"%.1f", grow];
    };
    NSString * (^shrinkName)(CGFloat shrink) = ^NSString * (CGFloat shrink) {
        if (shrink == QMUILayouterShrinkDefault) return @"Default";
        if (shrink == QMUILayouterShrinkNever) return @"Never";
        if (shrink == QMUILayouterShrinkMost) return @"Most";
        return [NSString stringWithFormat:@"%.1f", shrink];
    };
    return [NSString qmui_stringByConcat:[super description], @", visible = ", StringFromBOOL(self.visible), @", frame = ", NSStringFromCGRect(self.frame), @", margin = ", NSStringFromUIEdgeInsets(self.margin), @", grow = ", growName(self.grow), @", shrink = ", shrinkName(self.shrink), (self.visibleChildItems.count ? [NSString stringWithFormat:@", visibleChild(%@)", @(self.visibleChildItems.count)] : @""), (self.view ? [NSString stringWithFormat:@", view = <%@: %p>", NSStringFromClass(self.view.class), self.view] : @""), nil];
}

@synthesize frame = _frame;
- (void)setFrame:(CGRect)frame {
    // QMUIViewSelfSizingHeight 的功能
    if (isinf(frame.size.height)) {
        if (frame.size.width > 0) {
            CGFloat height = flat([self sizeThatFits:CGSizeMake(CGRectGetWidth(frame), CGFLOAT_MAX) shouldConsiderBlock:NO].height);
            frame = CGRectSetHeight(frame, height);
        } else {
            frame.size.height = _frame.size.height;
        }
    }
    BOOL frameChanged = !CGRectEqualToRect(self.frame, frame);
    _frame = frame;
    self.view.frame = frame;
    if (frameChanged) {
        [self setNeedsLayout];
    }
}

- (CGRect)frame {
    // 每个 item 不一定都存在 view，可能它只是一个虚拟的布局节点，所以这里要区分
    if (self.view) {
        return self.view.frame;
    }
    return _frame;
}

- (void)setView:(__kindof UIView *)view {
    BOOL valueChanged = _view != view;
    _view = view;
    if (valueChanged) {
        [self setNeedsLayout];
    }
}

- (void)setMargin:(UIEdgeInsets)margin {
    BOOL valueChanged = UIEdgeInsetsEqualToEdgeInsets(_margin, margin);
    _margin = margin;
    if (valueChanged) {
        [self.parentItem setNeedsLayout];
    }
}

- (void)setGrow:(CGFloat)grow {
    NSAssert(grow >= 0, @"negative values are invalid for grow.");
    grow = MAX(0, grow);
    BOOL valueChanged = _grow != grow;
    _grow = grow;
    if (valueChanged) {
        [self.parentItem setNeedsLayout];
    }
}

- (void)setShrink:(CGFloat)shrink {
    NSAssert(shrink >= 0, @"negative values are invalid for grow.");
    shrink = MAX(0, shrink);
    BOOL valueChanged = _shrink != shrink;
    _shrink = shrink;
    if (valueChanged) {
        [self.parentItem setNeedsLayout];
    }
}

- (BOOL)visible {
    if (self.visibleBlock) return self.visibleBlock(self);
    return self.view.superview && !self.view.hidden;
}

- (QMUILayouterItem *)visibleChildItem0 {
    return [self visibleChildItemAtIndex:0];
}

- (QMUILayouterItem *)visibleChildItem1 {
    return [self visibleChildItemAtIndex:1];
}

- (QMUILayouterItem *)visibleChildItem2 {
    return [self visibleChildItemAtIndex:2];
}

- (QMUILayouterItem *)visibleChildItem3 {
    return [self visibleChildItemAtIndex:3];
}

- (QMUILayouterItem *)visibleChildItemAtIndex:(NSUInteger)index {
    return index < self.visibleChildItems.count ? self.visibleChildItems[index] : nil;
}

- (void)setChildItems:(NSArray<QMUILayouterItem *> *)childItems {
    [_childItems enumerateObjectsUsingBlock:^(QMUILayouterItem * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        obj->_parentItem = nil;
    }];
    _childItems = childItems;
    [childItems enumerateObjectsUsingBlock:^(QMUILayouterItem * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        obj->_parentItem = self;
    }];
}

- (NSArray<QMUILayouterItem *> *)visibleChildItems {
    return self.childItems.count ? [self.childItems qmui_filterWithBlock:^BOOL(QMUILayouterItem * _Nonnull item) {
        return item.visible;
    }] : nil;
}

- (CGSize)sizeThatFits:(CGSize)size {
    return [self sizeThatFits:size shouldConsiderBlock:YES];
}

- (void)sizeToFit {
    CGSize prefersSize = CGSizeMax;
    // 参照系统 UILabel 的 sizeToFit 方式（在当前宽度下计算高度）
    if ([self.view isKindOfClass:UILabel.class] && CGRectGetWidth(self.frame) > 0) {
        prefersSize.width = CGRectGetWidth(self.frame);
    }
    CGSize size = [self sizeThatFits:prefersSize];
    self.frame = CGRectSetSize(self.frame, size);
}

- (void)setNeedsLayout {
    if (_shouldInvalidateLayout) return;
    _shouldInvalidateLayout = YES;
    dispatch_async(dispatch_get_main_queue(), ^{
        if (self->_shouldInvalidateLayout) {
            [self layoutIfNeeded];
        }
    });
}

- (void)layoutIfNeeded {
    [self layout];
    [self layoutDebugBorderLayer];
    _shouldInvalidateLayout = NO;
}

- (CALayer *)generateDebugBorderLayerContainer {
    CALayer *layer = CALayer.layer;
    layer.name = @"QMUILayouterDebugBorderLayerContainer";
    [layer qmui_removeDefaultAnimations];
    return layer;
}

- (CALayer *)generateDebugBorderLayer {
    CALayer *layer = CALayer.layer;
    layer.name = @"QMUILayouterDebugBorderLayer";
    [layer qmui_removeDefaultAnimations];
    UIColor *color = UIColor.qmui_randomColor;
    layer.backgroundColor = [color colorWithAlphaComponent:.1].CGColor;
    layer.borderColor = color.CGColor;
    layer.borderWidth = 1;
    return layer;
}

- (void)showDebugBorderRecursivelyInView:(UIView *)view {
    if (!view) return;
    CALayer *container = [view.layer.sublayers qmui_firstMatchWithBlock:^BOOL(__kindof CALayer * _Nonnull item) {
        return [item.name isEqualToString:@"QMUILayouterDebugBorderLayerContainer"];
    }];
    if (!container) {
        container = [self generateDebugBorderLayerContainer];
        [view.layer addSublayer:container];
    }
    [container.sublayers.copy enumerateObjectsUsingBlock:^(__kindof CALayer * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj.name isEqualToString:@"QMUILayouterDebugBorderLayer"]) [obj removeFromSuperlayer];
    }];
    container.frame = view.bounds;
    [self showDebugBorderInContainer:container];
    [self.childItems enumerateObjectsUsingBlock:^(QMUILayouterItem * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [obj showDebugBorderInContainer:container];
    }];
}

- (void)showDebugBorderInContainer:(CALayer *)container {
    if (!container) return;
    if (!self.debugBorderLayer) {
        self.debugBorderLayer = [self generateDebugBorderLayer];
        [container addSublayer:self.debugBorderLayer];
    } else if (self.debugBorderLayer.superlayer != container) {
        [self.debugBorderLayer removeFromSuperlayer];
        [container addSublayer:self.debugBorderLayer];
    }
}

- (void)layoutDebugBorderLayer {
    if (!self.debugBorderLayer || !self.debugBorderLayer.superlayer) return;
    if (self.view) {
        UIView *containerView = (UIView *)self.debugBorderLayer.superlayer.superlayer.delegate;
        CGRect frame = [self.view convertRect:self.view.bounds toView:containerView];
        self.debugBorderLayer.frame = frame;
    } else {
        self.debugBorderLayer.frame = self.frame;
    }
}

@end

@implementation QMUILayouterItem (UISubclassingHooks)

- (void)layout {
}

- (CGSize)sizeThatFits:(CGSize)size shouldConsiderBlock:(BOOL)shouldConsiderBlock {
    if (CGSizeEqualToSize(self.view.bounds.size, size) || CGSizeIsEmpty(size)) {
        size = CGSizeMax;
    }
    CGSize result = [self.view sizeThatFits:size];
    if (shouldConsiderBlock && self.sizeThatFitsBlock) {
        result = self.sizeThatFitsBlock(self, size, result);
    }
    result.width = MIN(self.maximumSize.width, MAX(self.minimumSize.width, result.width));
    result.height = MIN(self.maximumSize.height, MAX(self.minimumSize.height, result.height));
    return result;
}

@end
