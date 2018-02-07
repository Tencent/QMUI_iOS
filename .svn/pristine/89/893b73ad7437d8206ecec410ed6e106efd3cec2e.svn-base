//
//  QMUICollectionViewPagingLayout.m
//  qmui
//
//  Created by QQMail on 15/9/24.
//  Copyright © 2015年 QMUI Team. All rights reserved.
//

#import "QMUICollectionViewPagingLayout.h"
#import "QMUICommonDefines.h"

@interface QMUICollectionViewPagingLayout () {
    CGFloat _maximumScale;
    CGFloat _minimumScale;
    CGFloat _rotationRatio;
    CGFloat _rotationRadius;
    CGSize _finalItemSize;
}

@end

@implementation QMUICollectionViewPagingLayout (ScaleStyle)

- (CGFloat)maximumScale {
    return _maximumScale;
}

- (void)setMaximumScale:(CGFloat)maximumScale {
    _maximumScale = maximumScale;
}

- (CGFloat)minimumScale {
    return _minimumScale;
}

- (void)setMinimumScale:(CGFloat)minimumScale {
    _minimumScale = minimumScale;
}

@end

const CGFloat QMUICollectionViewPagingLayoutRotationRadiusAutomatic = -1.0;

@implementation QMUICollectionViewPagingLayout (RotationStyle)

- (CGFloat)rotationRatio {
    return _rotationRatio;
}

- (void)setRotationRatio:(CGFloat)rotationRatio {
    _rotationRatio = [self validatedRotationRatio:rotationRatio];
}

- (CGFloat)rotationRadius {
    return _rotationRadius;
}

- (void)setRotationRadius:(CGFloat)rotationRadius {
    _rotationRadius = rotationRadius;
}

- (CGFloat)validatedRotationRatio:(CGFloat)rotationRatio {
    return fmaxf(0.0, fminf(1.0, rotationRatio));
}

@end

@implementation QMUICollectionViewPagingLayout

- (instancetype)initWithStyle:(QMUICollectionViewPagingLayoutStyle)style {
    if (self = [super init]) {
        _style = style;
        self.velocityForEnsurePageDown = 0.4;
        self.allowsMultipleItemScroll = YES;
        self.mutipleItemScrollVelocityLimit = 0.7;
        self.maximumScale = 1.0;
        self.minimumScale = 0.94;
        self.rotationRatio = .5;
        self.rotationRadius = QMUICollectionViewPagingLayoutRotationRadiusAutomatic;
        
        self.minimumInteritemSpacing = 0;
        self.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    }
    return self;
}

- (instancetype)init {
    return [self initWithStyle:QMUICollectionViewPagingLayoutStyleDefault];
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    return [self init];
}

- (void)prepareLayout {
    [super prepareLayout];
    CGSize itemSize = self.itemSize;
    id<UICollectionViewDelegateFlowLayout> layoutDelegate = (id<UICollectionViewDelegateFlowLayout>)self.collectionView.delegate;
    if ([layoutDelegate respondsToSelector:@selector(collectionView:layout:sizeForItemAtIndexPath:)]) {
        itemSize = [layoutDelegate collectionView:self.collectionView layout:self sizeForItemAtIndexPath:[NSIndexPath indexPathForItem:0 inSection:0]];
    }
    _finalItemSize = itemSize;
}

- (BOOL)shouldInvalidateLayoutForBoundsChange:(CGRect)newBounds {
    if (self.style == QMUICollectionViewPagingLayoutStyleScale || self.style == QMUICollectionViewPagingLayoutStyleRotation) {
        return YES;
    }
    return !CGSizeEqualToSize(self.collectionView.bounds.size, newBounds.size);
}

- (NSArray<UICollectionViewLayoutAttributes *> *)layoutAttributesForElementsInRect:(CGRect)rect {
    if (self.style == QMUICollectionViewPagingLayoutStyleDefault) {
        return [super layoutAttributesForElementsInRect:rect];
    }
    
    NSArray<UICollectionViewLayoutAttributes *> *resultAttributes = [[NSArray alloc] initWithArray:[super layoutAttributesForElementsInRect:rect] copyItems:YES];
    CGFloat offset = CGRectGetMidX(self.collectionView.bounds);// 当前滚动位置的可视区域的中心点
    CGSize itemSize = _finalItemSize;

    if (self.style == QMUICollectionViewPagingLayoutStyleScale) {
        
        CGFloat distanceForMinimumScale = itemSize.width + self.minimumLineSpacing;
        CGFloat distanceForMaximumScale = 0.0;
        
        for (UICollectionViewLayoutAttributes *attributes in resultAttributes) {
            CGFloat scale = 0;
            CGFloat distance = fabs(offset - attributes.center.x);
            if (distance >= distanceForMinimumScale) {
                scale = self.minimumScale;
            } else if (distance == distanceForMaximumScale) {
                scale = self.maximumScale;
            } else {
                scale = self.minimumScale + (distanceForMinimumScale - distance) * (self.maximumScale - self.minimumScale) / (distanceForMinimumScale - distanceForMaximumScale);
            }
            attributes.transform3D = CATransform3DMakeScale(scale, scale, 1);
            attributes.zIndex = 1;
        }
        return resultAttributes;
    }
    
    if (self.style == QMUICollectionViewPagingLayoutStyleRotation) {
        if (self.rotationRadius == QMUICollectionViewPagingLayoutRotationRadiusAutomatic) {
            self.rotationRadius = itemSize.height;
        }
        UICollectionViewLayoutAttributes *centerAttribute = nil;
        CGFloat centerMin = 10000;
        for (UICollectionViewLayoutAttributes *attributes in resultAttributes) {
            CGFloat distance = self.collectionView.contentOffset.x + CGRectGetWidth(self.collectionView.bounds) / 2.0 - attributes.center.x;
            CGFloat degress = - 90 * self.rotationRatio * (distance / CGRectGetWidth(self.collectionView.bounds));
            CGFloat cosValue = fabs(cosf(AngleWithDegrees(degress)));
            CGFloat translateY = self.rotationRadius - self.rotationRadius * cosValue;
            CGAffineTransform transform = CGAffineTransformMakeTranslation(0, translateY);
            transform = CGAffineTransformRotate(transform, AngleWithDegrees(degress));
            attributes.transform = transform;
            attributes.zIndex = 1;
            if (fabs(distance) < centerMin) {
                centerMin = fabs(distance);
                centerAttribute = attributes;
            }
        }
        centerAttribute.zIndex = 10;
        return resultAttributes;
    }
    
    return resultAttributes;
}

- (CGPoint)targetContentOffsetForProposedContentOffset:(CGPoint)proposedContentOffset withScrollingVelocity:(CGPoint)velocity {
    CGFloat itemSpacing = _finalItemSize.width + self.minimumLineSpacing;
    
    if (!self.allowsMultipleItemScroll || fabs(velocity.x) <= fabs(self.mutipleItemScrollVelocityLimit)) {
        // 只滚动一页
        
        if (fabs(velocity.x) > self.velocityForEnsurePageDown) {
            // 为了更容易触发翻页，这里主动增加滚动位置
            BOOL scrollingToRight = proposedContentOffset.x < self.collectionView.contentOffset.x;
            proposedContentOffset = CGPointMake(self.collectionView.contentOffset.x + (itemSpacing / 2) * (scrollingToRight ? -1 : 1), self.collectionView.contentOffset.y);
        } else {
            proposedContentOffset = self.collectionView.contentOffset;
        }
    }
    
    proposedContentOffset.x = round(proposedContentOffset.x / itemSpacing) * itemSpacing;
    
    return proposedContentOffset;
}

@end
