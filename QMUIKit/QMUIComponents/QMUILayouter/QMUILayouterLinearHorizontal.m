/**
 * Tencent is pleased to support the open source community by making QMUI_iOS available.
 * Copyright (C) 2016-2021 THL A29 Limited, a Tencent company. All rights reserved.
 * Licensed under the MIT License (the "License"); you may not use this file except in compliance with the License. You may obtain a copy of the License at
 * http://opensource.org/licenses/MIT
 * Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.
 */

//
//  QMUILayouterLinearHorizontal.m
//  QMUIKit
//
//  Created by QMUI Team on 2024/1/2.
//

#import "QMUILayouterLinearHorizontal.h"
#import "QMUICore.h"
#import "NSArray+QMUI.h"
#import "UIView+QMUI.h"

@implementation QMUILayouterLinearHorizontal

+ (instancetype)itemWithChildItems:(NSArray<QMUILayouterItem *> *)childItems spacingBetweenItems:(CGFloat)spacingBetweenItems {
    return [self itemWithChildItems:childItems spacingBetweenItems:spacingBetweenItems horizontal:QMUILayouterAlignmentLeading vertical:QMUILayouterAlignmentLeading];
}

+ (instancetype)itemWithChildItems:(NSArray<QMUILayouterItem *> *)childItems spacingBetweenItems:(CGFloat)spacingBetweenItems horizontal:(QMUILayouterAlignment)horizontal vertical:(QMUILayouterAlignment)vertical {
    QMUILayouterLinearHorizontal *item = [[self alloc] init];
    item.childItems = childItems;
    item.spacingBetweenItems = spacingBetweenItems;
    item.childHorizontalAlignment = horizontal;
    item.childVerticalAlignment = vertical;
    return item;
}

- (NSString *)description {
    NSString * (^alignmentName)(QMUILayouterAlignment alignment) = ^NSString *(QMUILayouterAlignment alignment) {
        return @[@"Leading", @"Trailing", @"Center", @"Fill"][alignment];
    };
    return [NSString qmui_stringByConcat:[super description], @", horizontal = ", alignmentName(self.childHorizontalAlignment), @", vertical = ", alignmentName(self.childVerticalAlignment), nil];
}

// 容器性质的 layouter，不存在关联的实体 view，则始终认为是可视的，如果是 parentItem 的 parentItem 不可见，则由 parentItem 自己去管
- (BOOL)visible {
    if (self.visibleBlock) return self.visibleBlock(self);
    return self.visibleChildItems.count;
}

- (CGSize)sizeThatFits:(CGSize)size shouldConsiderBlock:(BOOL)shouldConsiderBlock {
    NSArray<QMUILayouterItem *> *childItems = self.visibleChildItems;
    if (!childItems.count) return self.minimumSize;
    if (CGSizeEqualToSize(self.frame.size, size) || CGSizeIsEmpty(size)) {
        size = CGSizeMax;
    }
    __block CGSize contentSize = CGSizeZero;
    __block CGFloat totalShrink = QMUILayouterShrinkNever;
    __block NSMutableDictionary<NSString *, NSValue *> *cachedSize = NSMutableDictionary.new;
    [childItems enumerateObjectsUsingBlock:^(QMUILayouterItem * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        CGSize s = [obj sizeThatFits:CGSizeMax];
        cachedSize[[NSString stringWithFormat:@"%p", obj]] = [NSValue valueWithCGSize:s];
        contentSize.width += s.width + UIEdgeInsetsGetHorizontalValue(obj.margin) + self.spacingBetweenItems;
        contentSize.height = MAX(contentSize.height, s.height + UIEdgeInsetsGetVerticalValue(obj.margin));
        
        if (obj.shrink > QMUILayouterShrinkNever) {
            totalShrink += s.width * obj.shrink;
        }
    }];
    contentSize.width -= self.spacingBetweenItems;
    if (contentSize.width <= size.width || totalShrink == QMUILayouterShrinkNever) {
        if (shouldConsiderBlock && self.sizeThatFitsBlock) {
            contentSize = self.sizeThatFitsBlock(self, size, contentSize);
        }
        contentSize.width = MIN(self.maximumSize.width, MAX(self.minimumSize.width, contentSize.width));
        contentSize.height = MIN(self.maximumSize.height, MAX(self.minimumSize.height, contentSize.height));
        return contentSize;
    }
    
    __block CGSize resultSize = CGSizeZero;
    [childItems enumerateObjectsUsingBlock:^(QMUILayouterItem * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        CGSize s = cachedSize[[NSString stringWithFormat:@"%p", obj]].CGSizeValue;
        if (obj.shrink > QMUILayouterGrowNever) {
            CGFloat spaceToShrink = contentSize.width - size.width;
            CGFloat w = s.width - spaceToShrink * s.width * obj.shrink / totalShrink;
            CGFloat h = [obj sizeThatFits:CGSizeMake(w, CGFLOAT_MAX)].height;
            s.width = w;
            s.height = h;
        }
        resultSize.width += s.width + UIEdgeInsetsGetHorizontalValue(obj.margin) + self.spacingBetweenItems;
        resultSize.height = MAX(resultSize.height, s.height + UIEdgeInsetsGetVerticalValue(obj.margin));
    }];
    resultSize.width -= self.spacingBetweenItems;
    if (shouldConsiderBlock && self.sizeThatFitsBlock) {
        resultSize = self.sizeThatFitsBlock(self, size, resultSize);
    }
    resultSize.width = MIN(self.maximumSize.width, MAX(self.minimumSize.width, resultSize.width));
    resultSize.height = MIN(self.maximumSize.height, MAX(self.minimumSize.height, resultSize.height));
    return resultSize;
}

- (void)layout {
    NSArray<QMUILayouterItem *> *childItems = self.visibleChildItems;
    CGSize contentSize = [self sizeThatFits:CGSizeMax shouldConsiderBlock:NO];
    
    __block CGFloat totalGrow = QMUILayouterGrowNever;
    __block CGFloat spaceToGrow = CGRectGetWidth(self.frame);// 父容器里待填充的多余空间（容器总大小减去所有固定的值，包括 spacingBetweenItems、所有 item 的 margin 区域、grow = Never 的 item 的 width之后，剩下的空间）
    __block CGFloat totalShrink = QMUILayouterShrinkNever;
    [childItems enumerateObjectsUsingBlock:^(QMUILayouterItem * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [obj sizeToFit];
        
        spaceToGrow -= CGRectGetWidth(obj.frame) + UIEdgeInsetsGetHorizontalValue(obj.margin) + self.spacingBetweenItems;
        if (obj.grow > QMUILayouterGrowNever) {
            totalGrow += obj.grow;
        }
        
        if (obj.shrink > QMUILayouterShrinkNever) {
            totalShrink += CGRectGetWidth(obj.frame) * obj.shrink;
        }
    }];
    spaceToGrow += self.spacingBetweenItems;
    BOOL shouldCalcGrow = totalGrow > QMUILayouterGrowNever && contentSize.width < CGRectGetWidth(self.frame);
    BOOL shouldCalcShrink = totalShrink > QMUILayouterShrinkNever && contentSize.width > CGRectGetWidth(self.frame);
    
    __block CGFloat minX = CGRectGetMinX(self.frame);
    __block CGFloat minY = CGRectGetMinY(self.frame);
    __block CGFloat maxX = CGRectGetMaxX(self.frame);
    __block CGFloat maxY = CGRectGetMaxY(self.frame);
    QMUILayouterAlignment childHorizontalAlignment = self.childHorizontalAlignment;
    QMUILayouterAlignment childVerticalAlignment = self.childVerticalAlignment;
    
    // 不需要考虑 grow/shrink 的情况，先把 minX 算出来
    if (!shouldCalcGrow && !shouldCalcShrink && childHorizontalAlignment != QMUILayouterAlignmentLeading) {
        if (contentSize.width >= CGRectGetWidth(self.frame)) {
            // 不管哪种布局方式，只要内容超过容器，统一按 Leading 处理
            childHorizontalAlignment = QMUILayouterAlignmentLeading;
        } else if (childHorizontalAlignment == QMUILayouterAlignmentTrailing) {
            minX = MAX(minX, CGRectGetMaxX(self.frame) - contentSize.width);
            childHorizontalAlignment = QMUILayouterAlignmentLeading;
        } else if (childHorizontalAlignment == QMUILayouterAlignmentCenter) {
            minX = MAX(minX, minX + CGFloatGetCenter(CGRectGetWidth(self.frame), contentSize.width));
            childHorizontalAlignment = QMUILayouterAlignmentLeading;
        } else if (childHorizontalAlignment == QMUILayouterAlignmentFill) {
            if (childItems.count > 1) {
                // 与容器相同方向的 Fill 仅在只有一个子元素时有效，超过一个子元素则视为 Leading
                // 如果你希望多个 childItem 可拉伸铺满，应该用 childItem.grow 来控制，而不是用 Fill
                childHorizontalAlignment = QMUILayouterAlignmentLeading;
            } else {
                // 一个子元素的情况，直接布局掉算了
                QMUILayouterItem *obj = self.visibleChildItem0;
                obj.frame = CGRectSetX(obj.frame, minX + obj.margin.left);
                obj.frame = CGRectSetWidth(obj.frame, maxX - obj.margin.right - CGRectGetMinX(obj.frame));
            }
        }
    }
    
    [childItems enumerateObjectsUsingBlock:^(QMUILayouterItem * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        obj.frame = CGRectSetX(obj.frame, minX + obj.margin.left);
        if (shouldCalcGrow && obj.grow > QMUILayouterGrowNever) {
            CGFloat w = CGRectGetWidth(obj.frame) + spaceToGrow * obj.grow / totalGrow;
            obj.frame = CGRectSetSize(obj.frame, CGSizeMake(w, QMUIViewSelfSizingHeight));
        }
        if (shouldCalcShrink && obj.shrink > QMUILayouterGrowNever) {
            CGFloat spaceToShrink = contentSize.width - CGRectGetWidth(self.frame);
            CGFloat w = CGRectGetWidth(obj.frame) - spaceToShrink * CGRectGetWidth(obj.frame) * obj.shrink / totalShrink;
            w = MAX(0, w);
            obj.frame = CGRectSetSize(obj.frame, CGSizeMake(w, QMUIViewSelfSizingHeight));
            obj.frame = CGRectSetHeight(obj.frame, MIN(CGRectGetHeight(self.frame) - UIEdgeInsetsGetVerticalValue(obj.margin), CGRectGetHeight(obj.frame)));
        }
        if (CGRectGetMaxX(obj.frame) + obj.margin.right > maxX) {
            obj.frame = CGRectSetWidth(obj.frame, maxX - obj.margin.right - CGRectGetMinX(obj.frame));
        }
        
        minX = CGRectGetMaxX(obj.frame) + obj.margin.right + self.spacingBetweenItems;
        
        if (childVerticalAlignment == QMUILayouterAlignmentTrailing) {
            obj.frame = CGRectSetY(obj.frame, maxY - obj.margin.bottom - CGRectGetHeight(obj.frame));
        } else if (childVerticalAlignment == QMUILayouterAlignmentCenter) {
            obj.frame = CGRectSetY(obj.frame, minY + obj.margin.top + CGFloatGetCenter(maxY - minY - UIEdgeInsetsGetVerticalValue(obj.margin), CGRectGetHeight(obj.frame)));
        } else if (childVerticalAlignment == QMUILayouterAlignmentFill) {
            obj.frame = CGRectSetY(obj.frame, minY + obj.margin.top);
            obj.frame = CGRectSetHeight(obj.frame, maxY - obj.margin.bottom - CGRectGetMinY(obj.frame));
        } else {
            obj.frame = CGRectSetY(obj.frame, minY + obj.margin.top);
        }
        
        [obj layoutIfNeeded];
    }];
}

@end
