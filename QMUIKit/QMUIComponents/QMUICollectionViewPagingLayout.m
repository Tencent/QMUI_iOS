/*****
 * Tencent is pleased to support the open source community by making QMUI_iOS available.
 * Copyright (C) 2016-2019 THL A29 Limited, a Tencent company. All rights reserved.
 * Licensed under the MIT License (the "License"); you may not use this file except in compliance with the License. You may obtain a copy of the License at
 * http://opensource.org/licenses/MIT
 * Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.
 *****/

//
//  QMUICollectionViewPagingLayout.m
//  qmui
//
//  Created by QMUI Team on 15/9/24.
//

#import "QMUICollectionViewPagingLayout.h"
#import "QMUICore.h"
#import "UIScrollView+QMUI.h"
#import "CALayer+QMUI.h"

@interface QMUICollectionViewPagingLayout () {
    CGFloat _maximumScale;
    CGFloat _minimumScale;
    CGFloat _rotationRatio;
    CGFloat _rotationRadius;
    CGSize _finalItemSize;
    CGFloat _pagingThreshold;
    BOOL _debug;
}

@property(nonatomic, strong) CALayer *debugLayer;

@end

@implementation QMUICollectionViewPagingLayout (DefaultStyle)

- (CGFloat)pagingThreshold {
    return _pagingThreshold;
}

- (void)setPagingThreshold:(CGFloat)pagingThreshold {
    _pagingThreshold = pagingThreshold;
}

- (BOOL)debug {
    return _debug;
}

- (void)setDebug:(BOOL)debug {
    _debug = debug;
    if (self.style == QMUICollectionViewPagingLayoutStyleDefault && debug && !self.debugLayer) {
        self.debugLayer = [CALayer layer];
        [self.debugLayer qmui_removeDefaultAnimations];
        self.debugLayer.backgroundColor = UIColorTestRed.CGColor;
        UIView *backgroundView = self.collectionView.backgroundView;
        if (!backgroundView) {
            backgroundView = [[UIView alloc] init];
            backgroundView.tag = 1024;
            self.collectionView.backgroundView = backgroundView;
        }
        [backgroundView.layer addSublayer:self.debugLayer];
    } else if (!debug) {
        [self.debugLayer removeFromSuperlayer];
        self.debugLayer = nil;
        if (self.collectionView.backgroundView.tag == 1024) {
            self.collectionView.backgroundView = nil;
        }
    }
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
    return MAX(0.0, MIN(1.0, rotationRatio));
}

@end

@implementation QMUICollectionViewPagingLayout

- (instancetype)initWithStyle:(QMUICollectionViewPagingLayoutStyle)style {
    if (self = [super init]) {
        _style = style;
        self.velocityForEnsurePageDown = 0.4;
        self.allowsMultipleItemScroll = YES;
        self.multipleItemScrollVelocityLimit = 2.5;
        self.pagingThreshold = 2.0 / 3.0;
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
    
    if (self.debugLayer) {
        if (self.scrollDirection == UICollectionViewScrollDirectionVertical) {
            self.debugLayer.frame = CGRectFlatMake(0, self.collectionView.qmui_contentInset.top + self.sectionInset.top + _finalItemSize.height / 2, CGRectGetWidth(self.collectionView.bounds), PixelOne);
        } else {
            self.debugLayer.frame = CGRectFlatMake(self.collectionView.qmui_contentInset.left + self.sectionInset.left + _finalItemSize.width / 2, 0, PixelOne, CGRectGetHeight(self.collectionView.bounds));
        }
    }
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
            CGFloat distance = ABS(offset - attributes.center.x);
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
            CGFloat cosValue = ABS(cosf(AngleWithDegrees(degress)));
            CGFloat translateY = self.rotationRadius - self.rotationRadius * cosValue;
            CGAffineTransform transform = CGAffineTransformMakeTranslation(0, translateY);
            transform = CGAffineTransformRotate(transform, AngleWithDegrees(degress));
            attributes.transform = transform;
            attributes.zIndex = 1;
            if (ABS(distance) < centerMin) {
                centerMin = ABS(distance);
                centerAttribute = attributes;
            }
        }
        centerAttribute.zIndex = 10;
        return resultAttributes;
    }
    
    return resultAttributes;
}

- (CGPoint)targetContentOffsetForProposedContentOffset:(CGPoint)proposedContentOffset withScrollingVelocity:(CGPoint)velocity {
    
    CGFloat itemSpacing = (self.scrollDirection == UICollectionViewScrollDirectionHorizontal ? _finalItemSize.width : _finalItemSize.height) + self.minimumLineSpacing;
    
    CGSize contentSize = self.collectionViewContentSize;
    CGSize frameSize = self.collectionView.bounds.size;
    UIEdgeInsets contentInset = self.collectionView.qmui_contentInset;
    
    BOOL scrollingToRight = proposedContentOffset.x < self.collectionView.contentOffset.x;// 代表 collectionView 期望的实际滚动方向是向右，但不代表手指拖拽的方向是向右，因为有可能此时已经在左边的尽头，继续往右拖拽，松手的瞬间由于回弹，这里会判断为是想向左滚动，但其实你的手指是向右拖拽
    BOOL scrollingToBottom = proposedContentOffset.y < self.collectionView.contentOffset.y;
    BOOL forcePaging = NO;
    
    CGPoint translation = [self.collectionView.panGestureRecognizer translationInView:self.collectionView];
    
    if (self.scrollDirection == UICollectionViewScrollDirectionVertical) {
        if (!self.allowsMultipleItemScroll || ABS(velocity.y) <= ABS(self.multipleItemScrollVelocityLimit)) {
            proposedContentOffset = self.collectionView.contentOffset;// 一次性滚多次的本质是系统根据速度算出来的 proposedContentOffset 可能比当前 contentOffset 大很多，所以这里既然限制了一次只能滚一页，那就直接取瞬时 contentOffset 即可。
            
            // 只支持滚动一页 或者 支持滚动多页但是速度不够滚动多页，时，允许强制滚动
            if (ABS(velocity.y) > self.velocityForEnsurePageDown) {
                forcePaging = YES;
            }
        }
        
        // 最顶/最底
        if (proposedContentOffset.y < -contentInset.top || proposedContentOffset.y >= contentSize.height + contentInset.bottom - frameSize.height) {
            if (IOS_VERSION_NUMBER < 100000) {
                // iOS 10 及以上的版本，直接返回当前的 contentOffset，系统会自动帮你调整到边界状态，而 iOS 9 及以下的版本需要自己计算
                // https://github.com/Tencent/QMUI_iOS/issues/499
                proposedContentOffset.y = MIN(MAX(proposedContentOffset.y, -contentInset.top), contentSize.height + contentInset.bottom - frameSize.height);
            }
            return proposedContentOffset;
        }
        
        CGFloat progress = ((contentInset.top + proposedContentOffset.y) + _finalItemSize.height / 2/*因为第一个 item 初始状态中心点离 contentOffset.y 有半个 item 的距离*/) / itemSpacing;
        NSInteger currentIndex = (NSInteger)progress;
        NSInteger targetIndex = currentIndex;
        // 加上下面这两个额外的 if 判断是为了避免那种“从0滚到1的左边 1/3，松手后反而会滚回0”的 bug
        if (translation.y < 0 && (ABS(translation.y) > _finalItemSize.height / 2 + self.minimumLineSpacing)) {
        } else if (translation.y > 0 && ABS(translation.y > _finalItemSize.height / 2)) {
        } else {
            CGFloat remainder = progress - currentIndex;
            CGFloat offset = remainder * itemSpacing;
            BOOL shouldNext = (forcePaging && !scrollingToBottom && velocity.y > 0) ? YES : (offset / _finalItemSize.height >= self.pagingThreshold);
            BOOL shouldPrev = (forcePaging && scrollingToBottom && velocity.y < 0) ? YES : (offset / _finalItemSize.height <= 1 - self.pagingThreshold);
            targetIndex = currentIndex + (shouldNext ? 1 : (shouldPrev ? -1 : 0));
        }
        proposedContentOffset.y = -contentInset.top + targetIndex * itemSpacing;
    }
    else if (self.scrollDirection == UICollectionViewScrollDirectionHorizontal) {
        if (!self.allowsMultipleItemScroll || ABS(velocity.x) <= ABS(self.multipleItemScrollVelocityLimit)) {
            proposedContentOffset = self.collectionView.contentOffset;// 一次性滚多次的本质是系统根据速度算出来的 proposedContentOffset 可能比当前 contentOffset 大很多，所以这里既然限制了一次只能滚一页，那就直接取瞬时 contentOffset 即可。
            
            // 只支持滚动一页 或者 支持滚动多页但是速度不够滚动多页，时，允许强制滚动
            if (ABS(velocity.x) > self.velocityForEnsurePageDown) {
                forcePaging = YES;
            }
        }
        
        // 最左/最右
        if (proposedContentOffset.x < -contentInset.left || proposedContentOffset.x >= contentSize.width + contentInset.right - frameSize.width) {
            if (IOS_VERSION_NUMBER < 100000) {
                // iOS 10 及以上的版本，直接返回当前的 contentOffset，系统会自动帮你调整到边界状态，而 iOS 9 及以下的版本需要自己计算
                // https://github.com/Tencent/QMUI_iOS/issues/499
                proposedContentOffset.x = MIN(MAX(proposedContentOffset.x, -contentInset.left), contentSize.width + contentInset.right - frameSize.width);
            }
            return proposedContentOffset;
        }
        
        CGFloat progress = ((contentInset.left + proposedContentOffset.x) + _finalItemSize.width / 2/*因为第一个 item 初始状态中心点离 contentOffset.x 有半个 item 的距离*/) / itemSpacing;
        NSInteger currentIndex = (NSInteger)progress;
        NSInteger targetIndex = currentIndex;
        // 加上下面这两个额外的 if 判断是为了避免那种“从0滚到1的左边 1/3，松手后反而会滚回0”的 bug
        if (translation.x < 0 && (ABS(translation.x) > _finalItemSize.width / 2 + self.minimumLineSpacing)) {
        } else if (translation.x > 0 && ABS(translation.x > _finalItemSize.width / 2)) {
        } else {
            CGFloat remainder = progress - currentIndex;
            CGFloat offset = remainder * itemSpacing;
            // collectionView 关闭了 bounces 后，如果在第一页向左边快速滑动一段距离，并不会触发上一个「最左/最右」的判断（因为 proposedContentOffset 不够），此时的 velocity 为负数，所以要加上 velocity.x > 0 的判断，否则这种情况会命中 forcePaging && !scrollingToRight 这两个条件，当做下一页处理。
            BOOL shouldNext = (forcePaging && !scrollingToRight && velocity.x > 0) ? YES : (offset / _finalItemSize.width >= self.pagingThreshold);
            BOOL shouldPrev = (forcePaging && scrollingToRight && velocity.x < 0) ? YES : (offset / _finalItemSize.width <= 1 - self.pagingThreshold);
            targetIndex = currentIndex + (shouldNext ? 1 : (shouldPrev ? -1 : 0));
        }
        proposedContentOffset.x = -contentInset.left + targetIndex * itemSpacing;
    }
    
    return proposedContentOffset;
}

@end
