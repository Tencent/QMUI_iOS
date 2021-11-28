/**
 * Tencent is pleased to support the open source community by making QMUI_iOS available.
 * Copyright (C) 2016-2021 THL A29 Limited, a Tencent company. All rights reserved.
 * Licensed under the MIT License (the "License"); you may not use this file except in compliance with the License. You may obtain a copy of the License at
 * http://opensource.org/licenses/MIT
 * Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.
 */

//
//  QMUIEmotionView.m
//  qmui
//
//  Created by QMUI Team on 16/9/6.
//

#import "QMUIEmotionView.h"
#import "QMUICore.h"
#import "QMUIButton.h"
#import "UIView+QMUI.h"
#import "CALayer+QMUI.h"
#import "UIScrollView+QMUI.h"
#import "UIControl+QMUI.h"
#import "UIImage+QMUI.h"
#import "QMUILog.h"

@implementation QMUIEmotion

+ (instancetype)emotionWithIdentifier:(NSString *)identifier displayName:(NSString *)displayName {
    QMUIEmotion *emotion = [[self alloc] init];
    emotion.identifier = identifier;
    emotion.displayName = displayName;
    return emotion;
}

- (BOOL)isEqual:(id)object {
    if (!object) return NO;
    if (self == object) return YES;
    if (![object isKindOfClass:[self class]]) return NO;
    return [self.identifier isEqualToString:((QMUIEmotion *)object).identifier];
}

- (NSString *)description {
    return [NSString stringWithFormat:@"%@, identifier: %@, displayName: %@", [super description], self.identifier, self.displayName];
}

@end

@class QMUIEmotionPageView;

@protocol QMUIEmotionPageViewDelegate <NSObject>

@optional
- (void)emotionPageView:(QMUIEmotionPageView *)emotionPageView didSelectEmotion:(QMUIEmotion *)emotion atIndex:(NSInteger)index;
- (void)emotionPageViewDidLayoutEmotions:(QMUIEmotionPageView *)emotionPageView;
@end

/// 表情面板每一页的cell，在drawRect里将所有表情绘制上去，同时自带一个末尾的删除按钮
@interface QMUIEmotionPageView : UICollectionViewCell

@property(nonatomic, weak) QMUIEmotionView<QMUIEmotionPageViewDelegate> *delegate;

/// 表情被点击时盖在表情上方用于表示选中的遮罩
@property(nonatomic, strong) UIView *emotionSelectedBackgroundView;

/// 表情面板右下角的删除按钮
@property(nonatomic, weak) QMUIButton *deleteButton;

/// 表情面板右下角的删除按的截图，因为在 CollectionView 滑动的过程中可能会出现 2 个 deleteButton，但是真实的 deleteButton 只能有一个，所以用截图来过渡
@property(nonatomic, strong) UIView *deleteButtonSnapView;

/// 删除按钮位置的 (x,y) 的偏移
@property(nonatomic, assign) CGPoint deleteButtonOffset;

/// 所有表情的 Layer
@property(nonatomic, strong) NSMutableArray<CALayer *> *emotionLayers;

/// 分配给当前pageView的所有表情
@property(nonatomic, copy) NSArray<QMUIEmotion *> *emotions;

/// 记录当前pageView里所有表情的可点击区域的rect，在drawRect:里更新，在tap事件里使用
@property(nonatomic, strong) NSMutableArray<NSValue *> *emotionHittingRects;

/// 负责实现表情的点击
@property(nonatomic, strong) UITapGestureRecognizer *tapGestureRecognizer;

/// 整个pageView内部的padding
@property(nonatomic, assign) UIEdgeInsets padding;

/// 每个pageView能展示表情的行数
@property(nonatomic, assign) NSInteger numberOfRows;

/// 每个表情的绘制区域大小，表情图片最终会以UIViewContentModeScaleAspectFit的方式撑满这个大小。表情计算布局时也是基于这个大小来算的。
@property(nonatomic, assign) CGSize emotionSize;

/// 点击表情时出现的遮罩要在表情所在的矩形位置拓展多少空间，负值表示遮罩比emotionSize更大，正值表示遮罩比emotionSize更小。最终判断表情点击区域时也是以拓展后的区域来判定的
@property(nonatomic, assign) UIEdgeInsets emotionSelectedBackgroundExtension;

/// 表情与表情之间的水平间距的最小值，实际值可能比这个要大一点（pageView会把剩余空间分配到表情的水平间距里）
@property(nonatomic, assign) CGFloat minimumEmotionHorizontalSpacing;

/// debug模式会把表情的绘制矩形显示出来
@property(nonatomic, assign) BOOL debug;

@property(nonatomic, assign, readonly) BOOL needsLayoutEmotions;

@property(nonatomic, assign) CGRect previousLayoutFrame;

@end

@implementation QMUIEmotionPageView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = UIColorClear;
        
        self.emotionSelectedBackgroundView = [[UIView alloc] init];
        self.emotionSelectedBackgroundView.userInteractionEnabled = NO;
        self.emotionSelectedBackgroundView.backgroundColor = UIColorMakeWithRGBA(0, 0, 0, .16);
        self.emotionSelectedBackgroundView.layer.cornerRadius = 3;
        self.emotionSelectedBackgroundView.alpha = 0;
        [self addSubview:self.emotionSelectedBackgroundView];
        
        self.emotionHittingRects = [[NSMutableArray alloc] init];
        self.tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapGestureRecognizer:)];
        [self addGestureRecognizer:self.tapGestureRecognizer];
    }
    return self;
}

- (CGRect)frameForDeleteButton:(__kindof UIView *)deleteButton {
    return CGRectSetXY(deleteButton.frame, CGRectGetWidth(self.bounds) - self.padding.right - CGRectGetWidth(deleteButton.frame) - (self.emotionSize.width - CGRectGetWidth(deleteButton.frame)) / 2.0 + self.deleteButtonOffset.x, CGRectGetHeight(self.bounds) - self.padding.bottom - CGRectGetHeight(deleteButton.frame) - (self.emotionSize.height - CGRectGetHeight(deleteButton.frame)) / 2.0 + self.deleteButtonOffset.y);
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    if (self.deleteButton.superview == self) {
        // 删除按钮必定布局到最后一个表情的位置，且与表情上下左右居中
        [self.deleteButton sizeToFit];
        self.deleteButton.frame = [self frameForDeleteButton:self.deleteButton];
    }
    if (self.deleteButtonSnapView) {
        self.deleteButtonSnapView.frame = [self frameForDeleteButton:self.deleteButtonSnapView];
    }
    BOOL isSizeChanged = !CGSizeEqualToSize(self.previousLayoutFrame.size, self.frame.size);
    self.previousLayoutFrame = self.frame;
    if (isSizeChanged) {
        [self setNeedsLayoutEmotions];
    }
    [self layoutEmotionsIfNeeded];
}

- (void)willRemoveSubview:(UIView *)subview {
    if (subview == self.deleteButton) {
        self.deleteButtonSnapView = [self.deleteButton snapshotViewAfterScreenUpdates:NO];
        [self addSubview:self.deleteButtonSnapView];
    }
}

- (void)setNeedsLayoutEmotions {
    _needsLayoutEmotions = YES;
}

- (void)setEmotions:(NSArray<QMUIEmotion *> *)emotions {
    if ([_emotions isEqualToArray:emotions]) return;
    _emotions = emotions;
    [self setNeedsLayoutEmotions];
    [self setNeedsLayout];
}

- (void)layoutEmotionsIfNeeded {
    if (!self.needsLayoutEmotions) return;
    _needsLayoutEmotions = NO;
    [self.emotionHittingRects removeAllObjects];
    
    CGSize contentSize = CGRectInsetEdges(self.bounds, self.padding).size;
    NSInteger emotionCountPerRow = (contentSize.width + self.minimumEmotionHorizontalSpacing) / (self.emotionSize.width + self.minimumEmotionHorizontalSpacing);
    CGFloat emotionHorizontalSpacing = flat((contentSize.width - emotionCountPerRow * self.emotionSize.width) / (emotionCountPerRow - 1));
    CGFloat emotionVerticalSpacing = flat((contentSize.height - self.numberOfRows * self.emotionSize.height) / (self.numberOfRows - 1));
    CGPoint emotionOrigin = CGPointZero;
    NSInteger emotionCount = self.emotions.count;
    if (!self.emotionLayers) {
        self.emotionLayers = [NSMutableArray arrayWithCapacity:emotionCount];
    }
    for (NSInteger i = 0; i < emotionCount; i++) {
        CALayer *emotionlayer = nil;
        if (i < self.emotionLayers.count) {
            emotionlayer = self.emotionLayers[i];
        } else {
            emotionlayer = [CALayer layer];
            emotionlayer.contentsScale = ScreenScale;
            [self.emotionLayers addObject:emotionlayer];
            [self.layer addSublayer:emotionlayer];
        }
        
        emotionlayer.contents = (__bridge id)(self.emotions[i].image.CGImage);
        NSInteger row = i / emotionCountPerRow;
        emotionOrigin.x = self.padding.left + (self.emotionSize.width + emotionHorizontalSpacing) * (i % emotionCountPerRow);
        emotionOrigin.y = self.padding.top + (self.emotionSize.height + emotionVerticalSpacing) * row;
        CGRect emotionRect = CGRectMake(emotionOrigin.x, emotionOrigin.y, self.emotionSize.width, self.emotionSize.height);
        CGRect emotionHittingRect = CGRectInsetEdges(emotionRect, self.emotionSelectedBackgroundExtension);
        [self.emotionHittingRects addObject:[NSValue valueWithCGRect:emotionHittingRect]];
        emotionlayer.frame = emotionRect;
        emotionlayer.hidden = NO;
    }
    
    if (self.emotionLayers.count > emotionCount) {
        for (NSInteger i = self.emotionLayers.count - emotionCount - 1; i < self.emotionLayers.count; i++) {
            self.emotionLayers[i].hidden = YES;
        }
    }
    if ([self.delegate respondsToSelector:@selector(emotionPageViewDidLayoutEmotions:)]) {
        [self.delegate emotionPageViewDidLayoutEmotions:self];
    }
}


- (void)handleTapGestureRecognizer:(UITapGestureRecognizer *)gestureRecognizer {
    CGPoint location = [gestureRecognizer locationInView:self];
    for (NSInteger i = 0; i < self.emotionHittingRects.count; i ++) {
        CGRect rect = [self.emotionHittingRects[i] CGRectValue];
        if (CGRectContainsPoint(rect, location)) {
            CALayer *layer = self.emotionLayers[i];
            if (layer.opacity < 0.2) return;
            QMUIEmotion *emotion = self.emotions[i];
            self.emotionSelectedBackgroundView.frame = rect;
            [UIView animateWithDuration:.08 animations:^{
                self.emotionSelectedBackgroundView.alpha = 1;
            } completion:^(BOOL finished) {
                [UIView animateWithDuration:.08 animations:^{
                    self.emotionSelectedBackgroundView.alpha = 0;
                } completion:nil];
            }];
            if ([self.delegate respondsToSelector:@selector(emotionPageView:didSelectEmotion:atIndex:)]) {
                [self.delegate emotionPageView:self didSelectEmotion:emotion atIndex:i];
            }
            if (self.debug) {
                QMUILog(NSStringFromClass(self.class), @"点击的是当前页里的第 %@ 个表情，%@", @(i), emotion);
            }
            return;
        }
    }
}

- (CGSize)verticalSizeThatFits:(CGSize)size emotionVerticalSpacing:(CGFloat)emotionVerticalSpacing {
    CGSize contentSize = CGRectInsetEdges(CGRectMakeWithSize(size), self.padding).size;
    NSInteger emotionCountPerRow = (contentSize.width + self.minimumEmotionHorizontalSpacing) / (self.emotionSize.width + self.minimumEmotionHorizontalSpacing);
    NSInteger row = ceil(self.emotions.count / (emotionCountPerRow * 1.0));
    CGFloat height = (self.emotionSize.height + emotionVerticalSpacing) * row - emotionVerticalSpacing + UIEdgeInsetsGetVerticalValue(self.padding);
    return CGSizeMake(size.width, height);
}

- (void)updateDeleteButton:(QMUIButton *)deleteButton {
    _deleteButton = deleteButton;
    if (self.deleteButtonSnapView) {
        [self.deleteButtonSnapView removeFromSuperview];
        self.deleteButtonSnapView = nil;
    }
    [self addSubview:deleteButton];
}

- (void)setDeleteButtonOffset:(CGPoint)deleteButtonOffset {
    _deleteButtonOffset = deleteButtonOffset;
    [self setNeedsLayout];
}


@end

@interface QMUIEmotionVerticalScrollView : UIScrollView
@property(nonatomic, strong) QMUIEmotionPageView *pageView;
@end

@implementation QMUIEmotionVerticalScrollView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        _pageView = [[QMUIEmotionPageView alloc] init];
        self.pageView.deleteButton.hidden = YES;
        [self addSubview:self.pageView];
    }
    return self;
}

- (void)setEmotions:(NSArray<QMUIEmotion *> *)emotions
                          emotionSize:(CGSize)emotionSize
      minimumEmotionHorizontalSpacing:(CGFloat)minimumEmotionHorizontalSpacing
               emotionVerticalSpacing:(CGFloat)emotionVerticalSpacing
   emotionSelectedBackgroundExtension:(UIEdgeInsets)emotionSelectedBackgroundExtension
                        paddingInPage:(UIEdgeInsets)paddingInPage {
    QMUIEmotionPageView *pageView = self.pageView;
    pageView.emotions = emotions;
    pageView.padding = paddingInPage;
    CGSize contentSize = CGSizeMake(self.bounds.size.width - UIEdgeInsetsGetHorizontalValue(paddingInPage), self.bounds.size.height - UIEdgeInsetsGetVerticalValue(paddingInPage));
    NSInteger emotionCountPerRow = (contentSize.width + minimumEmotionHorizontalSpacing) / (emotionSize.width + minimumEmotionHorizontalSpacing);
    pageView.numberOfRows = ceil(emotions.count / (CGFloat)emotionCountPerRow);
    pageView.emotionSize =emotionSize;
    pageView.emotionSelectedBackgroundExtension = emotionSelectedBackgroundExtension;
    pageView.minimumEmotionHorizontalSpacing = minimumEmotionHorizontalSpacing;
    [pageView setNeedsLayout];
    CGSize size = [pageView verticalSizeThatFits:self.bounds.size emotionVerticalSpacing:emotionVerticalSpacing];
    self.pageView.frame = CGRectMakeWithSize(size);
    self.contentSize = size;
}

- (void)adjustEmotionsAlphaWithFloatingRect:(CGRect)floatingRect {
    CGSize contentSize = CGSizeMake(self.contentSize.width - UIEdgeInsetsGetHorizontalValue(self.pageView.padding), self.contentSize.height - UIEdgeInsetsGetVerticalValue(self.pageView.padding));
    NSInteger emotionCountPerRow = (contentSize.width + self.pageView.minimumEmotionHorizontalSpacing) / (self.pageView.emotionSize.width + self.pageView.minimumEmotionHorizontalSpacing);
    CGFloat emotionVerticalSpacing = flat((contentSize.height - self.pageView.numberOfRows * self.pageView.emotionSize.height) / (self.pageView.numberOfRows - 1));
    NSInteger columnIndexLeft = ceil((floatingRect.origin.x - self.pageView.padding.left) / (self.pageView.emotionSize.width + self.pageView.minimumEmotionHorizontalSpacing)) - 1;
    NSInteger columnIndexRight = emotionCountPerRow - 1;
    CGFloat rowIndexTop = ((floatingRect.origin.y - self.pageView.padding.top) / (self.pageView.emotionSize.height + emotionVerticalSpacing)) - 1;
    for (NSInteger i = 0; i < self.pageView.emotionLayers.count; i++) {
        NSInteger row = (i / emotionCountPerRow);
        NSInteger column = (i % emotionCountPerRow);
        [CALayer qmui_performWithoutAnimation:^{
            if (column >= columnIndexLeft && column <= columnIndexRight && row > rowIndexTop) {
                if (row == ceil(rowIndexTop)) {
                    CGFloat intersectAreaHeight = floatingRect.origin.y - self.pageView.emotionLayers[i].frame.origin.y;
                    CGFloat percent = intersectAreaHeight / self.pageView.emotionSize.height;
                    self.pageView.emotionLayers[i].opacity = percent * percent;
                } else {
                    self.pageView.emotionLayers[i].opacity = 0;
                }
            } else {
                self.pageView.emotionLayers[i].opacity = 1.0f;
            }
        }];
    }
}

@end

@interface QMUIEmotionView ()<QMUIEmotionPageViewDelegate>
/// 用于展示表情面板的竖向滚动 scrollView，布局撑满整个控件
@property(nonatomic, strong, readonly) QMUIEmotionVerticalScrollView *verticalScrollView;
@property(nonatomic, strong) NSMutableArray<NSArray<QMUIEmotion *> *> *pagedEmotions;
@property(nonatomic, assign) BOOL debug;
@end

@implementation QMUIEmotionView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self didInitializedWithFrame:frame];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
        [self didInitializedWithFrame:CGRectZero];
    }
    return self;
}

- (void)setVerticalAlignment:(BOOL)verticalAlignment {
    _verticalAlignment = verticalAlignment;
    self.collectionView.hidden = verticalAlignment;
    self.pageControl.hidden = verticalAlignment;
    self.verticalScrollView.hidden = !verticalAlignment;
    if (!verticalAlignment && self.deleteButton.superview) {
        [self.deleteButton removeFromSuperview];
    }
    [self setNeedsLayout];
}

- (void)didInitializedWithFrame:(CGRect)frame {
    self.debug = NO;
    
    self.pagedEmotions = [[NSMutableArray alloc] init];
    
    _collectionViewLayout = [[UICollectionViewFlowLayout alloc] init];
    self.collectionViewLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    self.collectionViewLayout.minimumLineSpacing = 0;
    self.collectionViewLayout.minimumInteritemSpacing = 0;
    self.collectionViewLayout.sectionInset = UIEdgeInsetsZero;
    
    _collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(self.safeAreaInsets.left, self.safeAreaInsets.top, CGRectGetWidth(frame) - UIEdgeInsetsGetHorizontalValue(self.safeAreaInsets), CGRectGetHeight(frame) - UIEdgeInsetsGetVerticalValue(self.safeAreaInsets)) collectionViewLayout:self.collectionViewLayout];
    self.collectionView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    self.collectionView.backgroundColor = UIColorClear;
    self.collectionView.scrollsToTop = NO;
    self.collectionView.pagingEnabled = YES;
    self.collectionView.showsHorizontalScrollIndicator = NO;
    self.collectionView.dataSource = self;
    self.collectionView.delegate = self;
    [self.collectionView registerClass:[QMUIEmotionPageView class] forCellWithReuseIdentifier:@"page"];
    [self addSubview:self.collectionView];
    
    _verticalScrollView = [[QMUIEmotionVerticalScrollView alloc] init];
    self.verticalScrollView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    _verticalScrollView.delegate = self;
    _verticalScrollView.hidden = YES;
    [self addSubview:self.verticalScrollView];
    
    _pageControl = [[UIPageControl alloc] init];
    [self.pageControl addTarget:self action:@selector(handlePageControlEvent:) forControlEvents:UIControlEventValueChanged];
    [self addSubview:self.pageControl];
    
    _sendButton = [[QMUIButton alloc] init];
    [self.sendButton setTitle:@"发送" forState:UIControlStateNormal];
    self.sendButton.contentEdgeInsets = UIEdgeInsetsMake(5, 17, 5, 17);
    [self addSubview:self.sendButton];

    _deleteButton = [[QMUIButton alloc] init];
    self.deleteButton.qmui_automaticallyAdjustTouchHighlightedInScrollView = YES;
    __weak __typeof(self)weakSelf = self;
    self.deleteButton.qmui_tapBlock = ^(__kindof UIControl *sender) {
        __strong __typeof(weakSelf)strongSelf = weakSelf;
        if (strongSelf.didSelectDeleteButtonBlock) {
            strongSelf.didSelectDeleteButtonBlock();
        }
    };
}

- (void)setEmotions:(NSArray<QMUIEmotion *> *)emotions {
    _emotions = emotions;
    if (self.verticalAlignment) {
        [self setNeedsLayout];
    } else {
        [self pageEmotions];
    }
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    [self.sendButton sizeToFit];
    self.sendButton.qmui_right = self.qmui_width - self.safeAreaInsets.right - self.sendButtonMargins.right;
    self.sendButton.qmui_bottom = self.qmui_height - self.safeAreaInsets.bottom - self.sendButtonMargins.bottom;
    if (self.verticalAlignment) {
        CGRect verticalScrollViewFrame = CGRectInsetEdges(self.bounds, UIEdgeInsetsSetBottom(self.safeAreaInsets, 0));
        self.verticalScrollView.frame = verticalScrollViewFrame;
        [self.verticalScrollView setEmotions:self.emotions
                                 emotionSize:self.emotionSize
             minimumEmotionHorizontalSpacing:self.minimumEmotionHorizontalSpacing
                      emotionVerticalSpacing:self.emotionVerticalSpacing
          emotionSelectedBackgroundExtension:self.emotionSelectedBackgroundExtension
                               paddingInPage:UIEdgeInsetsSetBottom(self.paddingInPage, self.paddingInPage.bottom + self.safeAreaInsets.bottom)];
        self.verticalScrollView.pageView.delegate = self;
        [self addSubview:self.deleteButton];
        [self.deleteButton setImage:self.deleteButtonImage forState:UIControlStateNormal];
        [self.deleteButton setImage:[self.deleteButtonImage qmui_imageWithAlpha:ButtonHighlightedAlpha] forState:UIControlStateHighlighted];
        self.deleteButton.bounds = CGRectMakeWithSize(CGSizeMake([self.deleteButton sizeThatFits:CGSizeZero].width, self.sendButton.qmui_height));
        static CGFloat spacingBetweenDeleteButtonAndSendButton = 4.0f;
        self.deleteButton.qmui_right = self.sendButton.qmui_left - spacingBetweenDeleteButtonAndSendButton + self.deleteButtonOffset.x;
        self.deleteButton.qmui_top = CGRectGetMinYVerticallyCenter(self.sendButton.frame, self.deleteButton.frame) + self.deleteButtonOffset.y;
        
    } else {
        CGRect collectionViewFrame = CGRectInsetEdges(self.bounds, self.safeAreaInsets);
        BOOL collectionViewSizeChanged = !CGSizeEqualToSize(collectionViewFrame.size, self.collectionView.bounds.size);
        self.collectionViewLayout.itemSize = collectionViewFrame.size;// 先更新 itemSize 再设置 collectionView.frame，否则会触发系统的 UICollectionViewFlowLayoutBreakForInvalidSizes 断点
        self.collectionView.frame = collectionViewFrame;
        
        if (collectionViewSizeChanged) {
            [self pageEmotions];
        }
        CGFloat pageControlHeight = 16;
        CGFloat pageControlMaxX = self.sendButton.qmui_left;
        CGFloat pageControlMinX = self.qmui_width - pageControlMaxX;
        self.pageControl.frame = CGRectMake(pageControlMinX, self.qmui_height - self.safeAreaInsets.bottom - self.pageControlMarginBottom - pageControlHeight, pageControlMaxX - pageControlMinX, pageControlHeight);
    }
}

- (void)pageEmotions {
    [self.pagedEmotions removeAllObjects];
    self.pageControl.numberOfPages = 0;
    
    if (!CGRectIsEmpty(self.collectionView.bounds) && self.emotions.count && !CGSizeIsEmpty(self.emotionSize)) {
        CGFloat contentWidthInPage = CGRectGetWidth(self.collectionView.bounds) - UIEdgeInsetsGetHorizontalValue(self.paddingInPage);
        NSInteger maximumEmotionCountPerRowInPage = (contentWidthInPage + self.minimumEmotionHorizontalSpacing) / (self.emotionSize.width + self.minimumEmotionHorizontalSpacing);
        NSInteger maximumEmotionCountPerPage = maximumEmotionCountPerRowInPage * self.numberOfRowsPerPage - 1;// 删除按钮占一个表情位置
        NSInteger pageCount = ceil((CGFloat)self.emotions.count / (CGFloat)maximumEmotionCountPerPage);
        for (NSInteger i = 0; i < pageCount; i ++) {
            NSRange emotionRangeForPage = NSMakeRange(maximumEmotionCountPerPage * i, maximumEmotionCountPerPage);
            if (NSMaxRange(emotionRangeForPage) > self.emotions.count) {
                // 最后一页可能不满一整页，所以取剩余的所有表情即可
                emotionRangeForPage.length = self.emotions.count - emotionRangeForPage.location;
            }
            NSArray<QMUIEmotion *> *emotionForPage = [self.emotions objectsAtIndexes:[NSIndexSet indexSetWithIndexesInRange:emotionRangeForPage]];
            [self.pagedEmotions addObject:emotionForPage];
        }
        self.pageControl.numberOfPages = pageCount;
    }
    
    [self.collectionView reloadData];
    [self.collectionView qmui_scrollToTop];
}

- (void)handlePageControlEvent:(UIPageControl *)pageControl {
    [self.collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:pageControl.currentPage inSection:0] atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally animated:YES];
}

- (void)adjustEmotionsAlpha {
    CGFloat x = MIN(self.deleteButton.frame.origin.x, self.sendButton.frame.origin.x);
    CGFloat y = MIN(self.deleteButton.frame.origin.y, self.sendButton.frame.origin.y);
    CGFloat width = CGRectGetMaxX(self.sendButton.frame) - CGRectGetMinX(self.deleteButton.frame);
    CGFloat height = MAX(CGRectGetMaxY(self.deleteButton.frame), CGRectGetMaxY(self.sendButton.frame)) - MIN(CGRectGetMinY(self.deleteButton.frame), CGRectGetMinY(self.sendButton.frame));
    CGRect buttonGruopRect = CGRectMake(x, y, width, height);
    CGRect floatingRect = [self.verticalScrollView convertRect:buttonGruopRect fromView:self];
    [self.verticalScrollView adjustEmotionsAlphaWithFloatingRect:floatingRect];
}

#pragma mark - UIAppearance Setter

- (void)setSendButtonTitleAttributes:(NSDictionary *)sendButtonTitleAttributes {
    _sendButtonTitleAttributes = sendButtonTitleAttributes;
    [self.sendButton setAttributedTitle:[[NSAttributedString alloc] initWithString:[self.sendButton currentTitle] attributes:_sendButtonTitleAttributes] forState:UIControlStateNormal];
}

- (void)setSendButtonBackgroundColor:(UIColor *)sendButtonBackgroundColor {
    _sendButtonBackgroundColor = sendButtonBackgroundColor;
    self.sendButton.backgroundColor = _sendButtonBackgroundColor;
}

- (void)setSendButtonCornerRadius:(CGFloat)sendButtonCornerRadius {
    _sendButtonCornerRadius = sendButtonCornerRadius;
    self.sendButton.layer.cornerRadius = _sendButtonCornerRadius;
}

- (void)setDeleteButtonBackgroundColor:(UIColor *)deleteButtonBackgroundColor {
    _deleteButtonBackgroundColor = deleteButtonBackgroundColor;
    self.deleteButton.backgroundColor = deleteButtonBackgroundColor;
}

- (void)setDeleteButtonImage:(UIImage *)deleteButtonImage {
    _deleteButtonImage = deleteButtonImage;
    [self.deleteButton setImage:self.deleteButtonImage forState:UIControlStateNormal];
}

- (void)setDeleteButtonCornerRadius:(CGFloat)deleteButtonCornerRadius {
    _deleteButtonCornerRadius = deleteButtonCornerRadius;
    self.deleteButton.layer.cornerRadius = deleteButtonCornerRadius;
}

#pragma mark - <UIScrollViewDelegate>

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (scrollView == self.verticalScrollView) {
        [self adjustEmotionsAlpha];
    } else if (scrollView == self.collectionView) {
        CGFloat index = scrollView.contentOffset.x / scrollView.bounds.size.width;
        if (ceil(index) == floor(index)) {
            // 滚到到整页，需要调用 updateDeleteButton: 重新设置一次删除按钮，否则有可能是截图按钮
            QMUIEmotionPageView *pageView = (QMUIEmotionPageView *)[self.collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForRow:index inSection:0]];
            [pageView updateDeleteButton:self.deleteButton];
        }
    }
}

#pragma mark - <UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.pagedEmotions.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    QMUIEmotionPageView *pageView = [collectionView dequeueReusableCellWithReuseIdentifier:@"page" forIndexPath:indexPath];
    pageView.delegate = self;
    pageView.emotions = self.pagedEmotions[indexPath.item];
    pageView.padding = self.paddingInPage;
    pageView.numberOfRows = self.numberOfRowsPerPage;
    pageView.emotionSize = self.emotionSize;
    pageView.emotionSelectedBackgroundExtension = self.emotionSelectedBackgroundExtension;
    pageView.minimumEmotionHorizontalSpacing = self.minimumEmotionHorizontalSpacing;
    [pageView updateDeleteButton:self.deleteButton];
    pageView.deleteButtonOffset = self.deleteButtonOffset;
    pageView.debug = self.debug;
    [pageView setNeedsDisplay];
    return pageView;
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    if (scrollView == self.collectionView) {
        NSInteger currentPage = round(scrollView.contentOffset.x / CGRectGetWidth(scrollView.bounds));
        self.pageControl.currentPage = currentPage;
    }
}

#pragma mark - <QMUIEmotionPageViewDelegate>

- (void)emotionPageView:(QMUIEmotionPageView *)emotionPageView didSelectEmotion:(QMUIEmotion *)emotion atIndex:(NSInteger)index {
    if (self.didSelectEmotionBlock) {
        NSInteger index = [self.emotions indexOfObject:emotion];
        self.didSelectEmotionBlock(index, emotion);
    }
}

- (void)emotionPageViewDidLayoutEmotions:(QMUIEmotionPageView *)emotionPageView {
    if (self.verticalAlignment) {
        [self adjustEmotionsAlpha];
    }
}

#pragma mark - Getter

- (UIScrollView *)scrollView {
    return self.verticalScrollView;
}

@end

@interface QMUIEmotionView (UIAppearance)

@end

@implementation QMUIEmotionView (UIAppearance)

+ (void)initialize {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        [self setDefaultAppearance];
    });
}

+ (void)setDefaultAppearance {
    QMUIEmotionView *appearance = [QMUIEmotionView appearance];
    appearance.backgroundColor = UIColorForBackground;// 如果先设置了 UIView.appearance.backgroundColor，再使用最传统的 method_exchangeImplementations 交换 UIView.setBackgroundColor 方法，则会 crash。QMUI 这里是在 +initialize 时设置的，业务如果要 hook -[UIView setBackgroundColor:] 则需要比 +initialize 更早才行
    appearance.deleteButtonImage = [QMUIHelper imageWithName:@"QMUI_emotion_delete"];
    appearance.paddingInPage = UIEdgeInsetsMake(18, 18, 65, 18);
    appearance.numberOfRowsPerPage = 4;
    appearance.emotionSize = CGSizeMake(30, 30);
    appearance.emotionSelectedBackgroundExtension = UIEdgeInsetsMake(-3, -3, -3, -3);
    appearance.minimumEmotionHorizontalSpacing = 10;
    appearance.sendButtonTitleAttributes = @{NSFontAttributeName: UIFontMake(15), NSForegroundColorAttributeName: UIColorWhite};
    appearance.sendButtonBackgroundColor = UIColorBlue;
    appearance.sendButtonCornerRadius = 4;
    appearance.sendButtonMargins = UIEdgeInsetsMake(0, 0, 16, 16);
    appearance.pageControlMarginBottom = 22;
    appearance.deleteButtonCornerRadius = 4;
    appearance.emotionVerticalSpacing = 10;
    
    UIPageControl *pageControlAppearance = [UIPageControl appearanceWhenContainedInInstancesOfClasses:@[[QMUIEmotionView class]]];
    pageControlAppearance.pageIndicatorTintColor = UIColorMake(210, 210, 210);
    pageControlAppearance.currentPageIndicatorTintColor = UIColorMake(162, 162, 162);
}

@end
