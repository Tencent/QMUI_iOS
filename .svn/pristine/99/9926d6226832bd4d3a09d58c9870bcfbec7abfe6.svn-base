//
//  QMUIImagePreviewView.m
//  qmui
//
//  Created by MoLice on 2016/11/30.
//  Copyright © 2016年 QMUI Team. All rights reserved.
//

#import "QMUIImagePreviewView.h"
#import "QMUICommonDefines.h"
#import "QMUIConfiguration.h"
#import "QMUICollectionViewPagingLayout.h"
#import "QMUIZoomImageView.h"
#import "NSObject+QMUI.h"
#import "UICollectionView+QMUI.h"
#import "QMUIEmptyView.h"

@interface QMUIImagePreviewCell : UICollectionViewCell

@property(nonatomic, strong) QMUIZoomImageView *zoomImageView;
@end

@implementation QMUIImagePreviewCell

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = UIColorClear;
        
        self.zoomImageView = [[QMUIZoomImageView alloc] init];
        [self.contentView addSubview:self.zoomImageView];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    self.zoomImageView.frame = self.contentView.bounds;
}

@end

@interface QMUIImagePreviewView ()

@property(nonatomic, assign) BOOL isChangingCollectionViewBounds;
@property(nonatomic, assign) CGFloat previousIndexWhenScrolling;
@end

@implementation QMUIImagePreviewView

@synthesize currentImageIndex = _currentImageIndex;

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self didInitializedWithFrame:frame];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
        [self didInitializedWithFrame:self.frame];
    }
    return self;
}

- (void)didInitializedWithFrame:(CGRect)frame {
    _collectionViewLayout = [[QMUICollectionViewPagingLayout alloc] initWithStyle:QMUICollectionViewPagingLayoutStyleDefault];
    self.collectionViewLayout.allowsMultipleItemScroll = NO;
    
    _collectionView = [[UICollectionView alloc] initWithFrame:CGRectMakeWithSize(frame.size) collectionViewLayout:self.collectionViewLayout];
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
    self.collectionView.backgroundColor = UIColorClear;
    self.collectionView.showsHorizontalScrollIndicator = NO;
    self.collectionView.showsVerticalScrollIndicator = NO;
    self.collectionView.scrollsToTop = NO;
    self.collectionView.decelerationRate = UIScrollViewDecelerationRateFast;
    [self.collectionView registerClass:[QMUIImagePreviewCell class] forCellWithReuseIdentifier:@"cell"];
    [self addSubview:self.collectionView];
    
    self.loadingColor = UIColorWhite;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    BOOL isCollectionViewSizeChanged = !CGSizeEqualToSize(self.collectionView.bounds.size, self.bounds.size);
    if (isCollectionViewSizeChanged) {
        self.isChangingCollectionViewBounds = YES;
        
        // 必须先 invalidateLayout，再更新 collectionView.frame，否则横竖屏旋转前后的图片不一致（因为 scrollViewDidScroll: 时 contentSize、contentOffset 那些是错的）
        [self.collectionViewLayout invalidateLayout];
        self.collectionView.frame = self.bounds;
        [self.collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:self.currentImageIndex inSection:0] atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally animated:NO];
        
        self.isChangingCollectionViewBounds = NO;
    }
}

- (void)setCurrentImageIndex:(NSUInteger)currentImageIndex {
    [self setCurrentImageIndex:currentImageIndex animated:NO];
}

- (void)setCurrentImageIndex:(NSUInteger)currentImageIndex animated:(BOOL)animated {
    _currentImageIndex = currentImageIndex;
    [self.collectionView reloadData];
    if (currentImageIndex < [self.collectionView numberOfItemsInSection:0]) {
        [self.collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:currentImageIndex inSection:0] atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally animated:animated];
    } else {
        // dataSource 里的图片数量和当前 View 层的图片数量不匹配
        QMUILog(@"%@ %s，collectionView.numberOfItems = %@, collectionViewDataSource.numberOfItems = %@, currentImageIndex = %@", NSStringFromClass([self class]), __func__, @([self.collectionView numberOfItemsInSection:0]), @([self.collectionView.dataSource numberOfSectionsInCollectionView:self.collectionView]), @(_currentImageIndex));
    }
}

- (void)setLoadingColor:(UIColor *)loadingColor {
    BOOL isLoadingColorChanged = _loadingColor && ![_loadingColor isEqual:loadingColor];
    _loadingColor = loadingColor;
    if (isLoadingColorChanged) {
        [self.collectionView reloadItemsAtIndexPaths:self.collectionView.indexPathsForVisibleItems];
    }
}

#pragma mark - <UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    if ([self.delegate respondsToSelector:@selector(numberOfImagesInImagePreviewView:)]) {
        return [self.delegate numberOfImagesInImagePreviewView:self];
    }
    return 0;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    QMUIImagePreviewCell *cell = (QMUIImagePreviewCell *)[collectionView dequeueReusableCellWithReuseIdentifier:@"cell" forIndexPath:indexPath];
    cell.zoomImageView.delegate = self;
    ((UIActivityIndicatorView *)cell.zoomImageView.emptyView.loadingView).color = self.loadingColor;
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView willDisplayCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath {
    // 一张图滚走了再滚回来，会走到 willDisplayCell: 但不会走到 cellForItemAtIndexPath:，所以需要在这里更新图片，从而重置缩放状态
    QMUIImagePreviewCell *previewCell = (QMUIImagePreviewCell *)cell;
    if ([self.delegate respondsToSelector:@selector(imagePreviewView:renderZoomImageView:atIndex:)]) {
        [self.delegate imagePreviewView:self renderZoomImageView:previewCell.zoomImageView atIndex:indexPath.item];
    }
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return collectionView.bounds.size;
}

#pragma mark - <UIScrollViewDelegate>

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    if (scrollView != self.collectionView) {
        return;
    }
    
    // 当前滚动到的页数
    if ([self.delegate respondsToSelector:@selector(imagePreviewView:didScrollToIndex:)]) {
        [self.delegate imagePreviewView:self didScrollToIndex:self.currentImageIndex];
    }
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (scrollView != self.collectionView) {
        return;
    }
    
    if (self.isChangingCollectionViewBounds) {
        return;
    }
    
    CGFloat pageWidth = [self collectionView:self.collectionView layout:self.collectionViewLayout sizeForItemAtIndexPath:[NSIndexPath indexPathForItem:0 inSection:0]].width;
    CGFloat pageHorizontalMargin = self.collectionViewLayout.minimumLineSpacing;
    CGFloat contentOffsetX = self.collectionView.contentOffset.x;
    CGFloat index = contentOffsetX / (pageWidth + pageHorizontalMargin);
    
    // 在滑动过临界点的那一次才去调用 delegate，避免过于频繁的调用
    BOOL isFirstDidScroll = self.previousIndexWhenScrolling == 0;
    BOOL turnPageToRight = betweenOrEqual(self.previousIndexWhenScrolling, floor(index) + 0.5, index);
    BOOL turnPageToLeft = betweenOrEqual(index, floor(index) + 0.5, self.previousIndexWhenScrolling);
    if (!isFirstDidScroll && (turnPageToRight || turnPageToLeft)) {
        index = round(index);
        if (0 <= index && index < [self.collectionView numberOfItemsInSection:0]) {
            
            // 不调用 setter，避免又走一次 scrollToItem
            _currentImageIndex = index;
            
            if ([self.delegate respondsToSelector:@selector(imagePreviewView:willScrollHalfToIndex:)]) {
                [self.delegate imagePreviewView:self willScrollHalfToIndex:index];
            }
        }
    }
    self.previousIndexWhenScrolling = index;
}

@end

@implementation QMUIImagePreviewView (QMUIZoomImageView)

- (NSUInteger)indexForZoomImageView:(QMUIZoomImageView *)zoomImageView {
    if ([zoomImageView.superview.superview isKindOfClass:[QMUIImagePreviewCell class]]) {
        return [self.collectionView indexPathForCell:(QMUIImagePreviewCell *)zoomImageView.superview.superview].item;
    } else {
        NSAssert(NO, @"尝试通过 %s 获取 QMUIZoomImageView 所在的 index，但找不到 QMUIZoomImageView 所在的 cell，index 获取失败。%@", __func__, zoomImageView);
    }
    return NSUIntegerMax;
}

- (QMUIZoomImageView *)zoomImageViewAtIndex:(NSUInteger)index {
    QMUIImagePreviewCell *cell = (QMUIImagePreviewCell *)[self.collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForItem:index inSection:0]];
    return cell.zoomImageView;
}

- (void)checkIfDelegateMissing {
#ifdef DEBUG
    [NSObject qmui_enumerateProtocolMethods:@protocol(QMUIZoomImageViewDelegate) usingBlock:^(SEL selector) {
        if (![self respondsToSelector:selector]) {
            NSAssert(NO, @"%@ 需要响应 %@ 的方法 -%@", NSStringFromClass([self class]), NSStringFromProtocol(@protocol(QMUIZoomImageViewDelegate)), NSStringFromSelector(selector));
        }
    }];
#endif
}

#pragma mark - <QMUIZoomImageViewDelegate>

- (void)singleTouchInZoomingImageView:(QMUIZoomImageView *)imageView location:(CGPoint)location {
    [self checkIfDelegateMissing];
    if ([self.delegate respondsToSelector:_cmd]) {
        [self.delegate singleTouchInZoomingImageView:imageView location:location];
    }
}

- (void)doubleTouchInZoomingImageView:(QMUIZoomImageView *)imageView location:(CGPoint)location {
    [self checkIfDelegateMissing];
    if ([self.delegate respondsToSelector:_cmd]) {
        [self.delegate doubleTouchInZoomingImageView:imageView location:location];
    }
}

- (void)longPressInZoomingImageView:(QMUIZoomImageView *)imageView {
    [self checkIfDelegateMissing];
    if ([self.delegate respondsToSelector:_cmd]) {
        [self.delegate longPressInZoomingImageView:imageView];
    }
}

- (BOOL)enabledZoomViewInZoomImageView:(QMUIZoomImageView *)imageView {
    [self checkIfDelegateMissing];
    if ([self.delegate respondsToSelector:_cmd]) {
        return [self.delegate enabledZoomViewInZoomImageView:imageView];
    }
    return YES;
}

@end
