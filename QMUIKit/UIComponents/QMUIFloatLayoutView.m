//
//  QMUIFloatLayoutView.m
//  qmui
//
//  Created by MoLice on 2016/11/10.
//  Copyright © 2016年 QMUI Team. All rights reserved.
//

#import "QMUIFloatLayoutView.h"
#import "QMUICommonDefines.h"

@implementation QMUIFloatLayoutView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self didInitialized];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
        [self didInitialized];
    }
    return self;
}

- (void)didInitialized {
    self.minimumItemSize = CGSizeZero;
    self.maximumItemSize = CGSizeMake(CGFLOAT_MAX, CGFLOAT_MAX);
}

- (CGSize)sizeThatFits:(CGSize)size {
    return [self layoutSubviewsWithSize:size shouldLayout:NO];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    [self layoutSubviewsWithSize:self.bounds.size shouldLayout:YES];
}

- (CGSize)layoutSubviewsWithSize:(CGSize)size shouldLayout:(BOOL)shouldLayout {
    NSArray<UIView *> *visibleItemViews = [self visibleSubviews];
    
    if (visibleItemViews.count == 0) {
        return CGSizeMake(UIEdgeInsetsGetHorizontalValue(self.padding), UIEdgeInsetsGetVerticalValue(self.padding));
    }
    
    CGPoint itemViewOrigin = CGPointMake(self.padding.left, self.padding.top);
    CGFloat currentRowMaxY = itemViewOrigin.y;
    
    for (NSInteger i = 0, l = visibleItemViews.count; i < l; i ++) {
        UIView *itemView = visibleItemViews[i];
        
        CGSize itemViewSize = [itemView sizeThatFits:CGSizeMake(self.maximumItemSize.width, self.maximumItemSize.height)];
        itemViewSize.width = fmaxf(self.minimumItemSize.width, itemViewSize.width);
        itemViewSize.height = fmaxf(self.minimumItemSize.height, itemViewSize.height);
        
        if (itemViewOrigin.x + self.itemMargins.left + itemViewSize.width > size.width - self.padding.right) {
            // 换行，左边第一个 item 是不考虑 itemMargins.left 的
            if (shouldLayout) {
                itemView.frame = CGRectMake(self.padding.left, currentRowMaxY + self.itemMargins.top, itemViewSize.width, itemViewSize.height);
            }
            
            itemViewOrigin.x = self.padding.left + itemViewSize.width + self.itemMargins.right;
            itemViewOrigin.y = currentRowMaxY;
        } else {
            // 当前行放得下
            if (shouldLayout) {
                itemView.frame = CGRectMake(itemViewOrigin.x + self.itemMargins.left, itemViewOrigin.y + self.itemMargins.top, itemViewSize.width, itemViewSize.height);
            }
            
            itemViewOrigin.x += UIEdgeInsetsGetHorizontalValue(self.itemMargins) + itemViewSize.width;
        }
        
        currentRowMaxY = fmaxf(currentRowMaxY, itemViewOrigin.y + UIEdgeInsetsGetVerticalValue(self.itemMargins) + itemViewSize.height);
    }
    
    // 最后一行不需要考虑 itemMarins.bottom，所以这里减掉
    currentRowMaxY -= self.itemMargins.bottom;
    
    CGSize resultSize = CGSizeMake(size.width, currentRowMaxY + self.padding.bottom);
    return resultSize;
}

- (NSArray<UIView *> *)visibleSubviews {
    NSMutableArray<UIView *> *visibleItemViews = [[NSMutableArray alloc] init];
    
    for (NSInteger i = 0, l = self.subviews.count; i < l; i++) {
        UIView *itemView = self.subviews[i];
        if (!itemView.hidden) {
            [visibleItemViews addObject:itemView];
        }
    }
    
    return visibleItemViews;
}

@end
