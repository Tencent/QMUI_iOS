/*****
 * Tencent is pleased to support the open source community by making QMUI_iOS available.
 * Copyright (C) 2016-2019 THL A29 Limited, a Tencent company. All rights reserved.
 * Licensed under the MIT License (the "License"); you may not use this file except in compliance with the License. You may obtain a copy of the License at
 * http://opensource.org/licenses/MIT
 * Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.
 *****/

//
//  QMUIGridView.m
//  qmui
//
//  Created by QMUI Team on 15/1/30.
//

#import "QMUIGridView.h"
#import "QMUICore.h"
#import "CALayer+QMUI.h"

@interface QMUIGridView ()

@property(nonatomic, strong) CAShapeLayer *separatorLayer;
@end

@implementation QMUIGridView

- (instancetype)initWithFrame:(CGRect)frame column:(NSInteger)column rowHeight:(CGFloat)rowHeight {
    if (self = [super initWithFrame:frame]) {
        [self didInitialize];
        self.columnCount = column;
        self.rowHeight = rowHeight;
    }
    return self;
}

- (instancetype)initWithColumn:(NSInteger)column rowHeight:(CGFloat)rowHeight {
    return [self initWithFrame:CGRectZero column:column rowHeight:rowHeight];
}

- (instancetype)initWithFrame:(CGRect)frame {
    return [self initWithFrame:frame column:0 rowHeight:0];
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
        [self didInitialize];
    }
    return self;
}

- (void)didInitialize {
    self.separatorLayer = [CAShapeLayer layer];
    [self.separatorLayer qmui_removeDefaultAnimations];
    self.separatorLayer.hidden = YES;
    [self.layer addSublayer:self.separatorLayer];
    
    self.separatorColor = UIColorSeparator;
}

- (void)setSeparatorWidth:(CGFloat)separatorWidth {
    _separatorWidth = separatorWidth;
    self.separatorLayer.lineWidth = _separatorWidth;
    self.separatorLayer.hidden = _separatorWidth <= 0;
}

- (void)setSeparatorColor:(UIColor *)separatorColor {
    _separatorColor = separatorColor;
    self.separatorLayer.strokeColor = _separatorColor.CGColor;
}

// 返回最接近平均列宽的值，保证其为整数，因此所有columnWidth加起来可能比总宽度要小
- (CGFloat)stretchColumnWidth {
    return floor((CGRectGetWidth(self.bounds) - self.separatorWidth * (self.columnCount - 1)) / self.columnCount);
}

- (NSInteger)rowCount {
    NSInteger subviewCount = self.subviews.count;
    return subviewCount / self.columnCount + (subviewCount % self.columnCount > 0 ? 1 : 0);
}

- (CGSize)sizeThatFits:(CGSize)size {
    NSInteger rowCount = [self rowCount];
    CGFloat totalHeight = rowCount * self.rowHeight + (rowCount - 1) * self.separatorWidth;
    size.height = totalHeight;
    return size;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    NSInteger subviewCount = self.subviews.count;
    if (subviewCount == 0) return;
    
    CGSize size = self.bounds.size;
    if (CGSizeIsEmpty(size)) return;
    
    CGFloat columnWidth = [self stretchColumnWidth];
    CGFloat rowHeight = self.rowHeight;
    NSInteger rowCount = [self rowCount];
    
    BOOL shouldShowSeparator = self.separatorWidth > 0;
    CGFloat lineOffset = shouldShowSeparator ? self.separatorWidth / 2.0 : 0;
    UIBezierPath *separatorPath = shouldShowSeparator ? [UIBezierPath bezierPath] : nil;
    
    for (NSInteger row = 0; row < rowCount; row++) {
        for (NSInteger column = 0; column < self.columnCount; column++) {
            NSInteger index = row * self.columnCount + column;
            if (index < subviewCount) {
                BOOL isLastColumn = column == self.columnCount - 1;
                BOOL isLastRow = row == rowCount - 1;
                
                UIView *subview = self.subviews[index];
                CGRect subviewFrame = CGRectMake(columnWidth * column + self.separatorWidth * column, rowHeight * row + self.separatorWidth * row, columnWidth, rowHeight);
                
                if (isLastColumn) {
                    // 每行最后一个item要占满剩余空间，否则可能因为strecthColumnWidth不精确导致右边漏空白
                    subviewFrame.size.width = size.width - columnWidth * (self.columnCount - 1) - self.separatorWidth * (self.columnCount - 1);
                }
                if (isLastRow) {
                    // 最后一行的item要占满剩余空间，避免一些计算偏差
                    subviewFrame.size.height = size.height - rowHeight * (rowCount - 1) - self.separatorWidth * (rowCount - 1);
                }
                
                subview.frame = subviewFrame;
                [subview setNeedsLayout];
                
                if (shouldShowSeparator) {
                    // 每个 item 都画右边和下边这两条分隔线
                    CGPoint rightTopPoint = CGPointMake(CGRectGetMaxX(subviewFrame) + lineOffset, CGRectGetMinY(subviewFrame));
                    CGPoint rightBottomPoint = CGPointMake(rightTopPoint.x - (isLastColumn ? lineOffset : 0), CGRectGetMaxY(subviewFrame) + (!isLastRow ? lineOffset : 0));
                    CGPoint leftBottomPoint = CGPointMake(CGRectGetMinX(subviewFrame), rightBottomPoint.y);
                    
                    if (!isLastColumn) {
                        [separatorPath moveToPoint:rightTopPoint];
                        [separatorPath addLineToPoint:rightBottomPoint];
                    }
                    if (!isLastRow) {
                        [separatorPath moveToPoint:rightBottomPoint];
                        [separatorPath addLineToPoint:leftBottomPoint];
                    }
                }
            }
        }
    }
    
    if (shouldShowSeparator) {
        self.separatorLayer.path = separatorPath.CGPath;
    }
}

@end
