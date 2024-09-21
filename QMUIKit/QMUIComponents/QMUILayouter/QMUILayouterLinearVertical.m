/**
 * Tencent is pleased to support the open source community by making QMUI_iOS available.
 * Copyright (C) 2016-2021 THL A29 Limited, a Tencent company. All rights reserved.
 * Licensed under the MIT License (the "License"); you may not use this file except in compliance with the License. You may obtain a copy of the License at
 * http://opensource.org/licenses/MIT
 * Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.
 */

//
//  QMUILayouterLinearVertical.m
//  QMUIKit
//
//  Created by QMUI Team on 2024/1/2.
//

#import "QMUILayouterLinearVertical.h"
#import "QMUICore.h"
#import "NSString+QMUI.h"

@implementation QMUILayouterLinearVertical

+ (instancetype)itemWithChildItems:(NSArray<QMUILayouterItem *> *)childItems spacingBetweenItems:(CGFloat)spacingBetweenItems {
    return [self itemWithChildItems:childItems spacingBetweenItems:spacingBetweenItems horizontal:QMUILayouterAlignmentLeading vertical:QMUILayouterAlignmentLeading];
}

+ (instancetype)itemWithChildItems:(NSArray<QMUILayouterItem *> *)childItems spacingBetweenItems:(CGFloat)spacingBetweenItems horizontal:(QMUILayouterAlignment)horizontal vertical:(QMUILayouterAlignment)vertical {
    QMUILayouterLinearVertical *item = [[self alloc] init];
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
        CGSize s = [obj sizeThatFits:CGSizeMake(size.width - UIEdgeInsetsGetHorizontalValue(obj.margin), CGFLOAT_MAX)];
        cachedSize[[NSString stringWithFormat:@"%p", obj]] = [NSValue valueWithCGSize:s];
        contentSize.width = MAX(contentSize.width, s.width + UIEdgeInsetsGetHorizontalValue(obj.margin));
        contentSize.height += s.height + UIEdgeInsetsGetVerticalValue(obj.margin) + self.spacingBetweenItems;
        
        if (obj.shrink > QMUILayouterShrinkNever) {
            totalShrink += s.height * obj.shrink;
        }
    }];
    contentSize.height -= self.spacingBetweenItems;
    if (contentSize.height <= size.height || totalShrink == QMUILayouterShrinkNever) {
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
        if (obj.shrink > QMUILayouterShrinkNever) {
            CGFloat spaceToShrink = contentSize.height - size.height;
            CGFloat h = s.height - spaceToShrink * s.height * obj.shrink / totalShrink;
            s.height = h;
        }
        resultSize.width = MAX(resultSize.width, s.width + UIEdgeInsetsGetHorizontalValue(obj.margin));
        resultSize.height += s.height + UIEdgeInsetsGetVerticalValue(obj.margin) + self.spacingBetweenItems;
    }];
    resultSize.height -= self.spacingBetweenItems;
    if (shouldConsiderBlock && self.sizeThatFitsBlock) {
        resultSize = self.sizeThatFitsBlock(self, size, resultSize);
    }
    resultSize.width = MIN(self.maximumSize.width, MAX(self.minimumSize.width, resultSize.width));
    resultSize.height = MIN(self.maximumSize.height, MAX(self.minimumSize.height, resultSize.height));
    return resultSize;
}

- (void)layout {
    NSArray<QMUILayouterItem *> *childItems = self.visibleChildItems;
    CGSize contentSize = [self sizeThatFits:CGSizeMake(CGRectGetWidth(self.frame), CGFLOAT_MAX) shouldConsiderBlock:NO];
    __block CGFloat totalGrow = QMUILayouterGrowNever;
    __block CGFloat spaceToGrow = CGRectGetHeight(self.frame);// 父容器里待填充的多余空间（容器总大小减去所有固定的值，包括 spacingBetweenItems、所有 item 的 margin 区域、grow = Never 的 item 的 width之后，剩下的空间）
    __block CGFloat totalShrink = QMUILayouterShrinkNever;
    [childItems enumerateObjectsUsingBlock:^(QMUILayouterItem * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        CGFloat itemMaxWidth = CGRectGetWidth(self.frame) - UIEdgeInsetsGetHorizontalValue(obj.margin);
        CGSize itemSize = [obj sizeThatFits:CGSizeMake(itemMaxWidth, CGFLOAT_MAX)];
        itemSize.width = MIN(itemMaxWidth, itemSize.width);
        obj.frame = CGRectSetSize(obj.frame, itemSize);
        
        spaceToGrow -= CGRectGetHeight(obj.frame) + UIEdgeInsetsGetVerticalValue(obj.margin) + self.spacingBetweenItems;
        if (obj.grow > QMUILayouterGrowNever) {
            totalGrow += obj.grow;
        }
        
        if (obj.shrink > QMUILayouterShrinkNever) {
            totalShrink += CGRectGetHeight(obj.frame) * obj.shrink;
        }
    }];
    spaceToGrow += self.spacingBetweenItems;
    BOOL shouldCalcGrow = totalGrow > QMUILayouterGrowNever && contentSize.height < CGRectGetHeight(self.frame);
    BOOL shouldCalcShrink = totalShrink > QMUILayouterShrinkNever && contentSize.height > CGRectGetHeight(self.frame);
    
    __block CGFloat minX = CGRectGetMinX(self.frame);
    __block CGFloat minY = CGRectGetMinY(self.frame);
    __block CGFloat maxX = CGRectGetMaxX(self.frame);
    __block CGFloat maxY = CGRectGetMaxY(self.frame);
    QMUILayouterAlignment childVerticalAlignment = self.childVerticalAlignment;
    QMUILayouterAlignment childHorizontalAlignment = self.childHorizontalAlignment;
    
    // 不需要考虑 grow/shrink 的情况，先把 minX 算出来
    if (!shouldCalcGrow && !shouldCalcShrink && childVerticalAlignment != QMUILayouterAlignmentLeading) {
        if (contentSize.height >= CGRectGetHeight(self.frame)) {
            // 不管哪种布局方式，只要内容超过容器，统一按 Leading 处理
            childVerticalAlignment = QMUILayouterAlignmentLeading;
        } else if (childVerticalAlignment == QMUILayouterAlignmentTrailing) {
            minY = MAX(minY, CGRectGetMaxY(self.frame) - contentSize.height);
            childVerticalAlignment = QMUILayouterAlignmentLeading;
        } else if (childVerticalAlignment == QMUILayouterAlignmentCenter) {
            minY = MAX(minY, minY + CGFloatGetCenter(CGRectGetHeight(self.frame), contentSize.height));
            childVerticalAlignment = QMUILayouterAlignmentLeading;
        } else if (childVerticalAlignment == QMUILayouterAlignmentFill) {
            if (childItems.count > 1) {
                // 与容器相同方向的 Fill 仅在只有一个子元素时有效，超过一个子元素则视为 Leading
                // 如果你希望多个 childItem 可拉伸铺满，应该用 childItem.grow 来控制，而不是用 Fill
                childVerticalAlignment = QMUILayouterAlignmentLeading;
            } else {
                // 一个子元素的情况，直接布局掉算了
                QMUILayouterItem *obj = self.visibleChildItem0;
                obj.frame = CGRectSetY(obj.frame, minY + obj.margin.top);
                obj.frame = CGRectSetHeight(obj.frame, maxY - obj.margin.bottom - CGRectGetMinY(obj.frame));
            }
        }
    }
    
    [childItems enumerateObjectsUsingBlock:^(QMUILayouterItem * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        obj.frame = CGRectSetY(obj.frame, minY + obj.margin.top);
        if (shouldCalcGrow && obj.grow > QMUILayouterGrowNever) {
            CGFloat h = CGRectGetHeight(obj.frame) + spaceToGrow * obj.grow / totalGrow;
            obj.frame = CGRectSetHeight(obj.frame, h);
        }
        if (shouldCalcShrink && obj.shrink > QMUILayouterShrinkNever) {
            CGFloat spaceToShrink = contentSize.height - CGRectGetHeight(self.frame);
            CGFloat h = CGRectGetHeight(obj.frame) - spaceToShrink * CGRectGetHeight(obj.frame) * obj.shrink / totalShrink;
            h = MAX(0, h);
            obj.frame = CGRectSetHeight(obj.frame, h);
        }
        if (CGRectGetMaxY(obj.frame) + obj.margin.bottom > maxY) {
            obj.frame = CGRectSetHeight(obj.frame, maxY - obj.margin.bottom - CGRectGetMinY(obj.frame));
        }
        
        minY = CGRectGetMaxY(obj.frame) + obj.margin.bottom + self.spacingBetweenItems;
        
        if (childHorizontalAlignment == QMUILayouterAlignmentTrailing) {
            obj.frame = CGRectSetX(obj.frame, maxX - obj.margin.right - CGRectGetWidth(obj.frame));
        } else if (childHorizontalAlignment == QMUILayouterAlignmentCenter) {
            obj.frame = CGRectSetX(obj.frame, minX + obj.margin.left + CGFloatGetCenter(maxX - minX - UIEdgeInsetsGetHorizontalValue(obj.margin), CGRectGetWidth(obj.frame)));
        } else if (childHorizontalAlignment == QMUILayouterAlignmentFill) {
            obj.frame = CGRectSetX(obj.frame, minX + obj.margin.left);
            obj.frame = CGRectSetWidth(obj.frame, maxX - obj.margin.right - CGRectGetMinX(obj.frame));
        } else {
            obj.frame = CGRectSetX(obj.frame, minX + obj.margin.left);
        }
        
        [obj layoutIfNeeded];
    }];
}

@end
