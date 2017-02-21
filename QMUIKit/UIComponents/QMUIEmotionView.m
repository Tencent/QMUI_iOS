//
//  QMUIEmotionView.m
//  qmui
//
//  Created by MoLice on 16/9/6.
//  Copyright © 2016年 QMUI Team. All rights reserved.
//

#import "QMUIEmotionView.h"
#import "QMUICommonDefines.h"
#import "QMUIConfiguration.h"
#import "QMUIHelper.h"
#import "QMUIButton.h"
#import "UIView+QMUI.h"
#import "UIScrollView+QMUI.h"
#import "UIControl+QMUI.h"
#import "UIImage+QMUI.h"

@implementation QMUIEmotion

@synthesize image = _image;

+ (instancetype)emotionWithIdentifier:(NSString *)identifier displayName:(NSString *)displayName {
    QMUIEmotion *emotion = [[QMUIEmotion alloc] init];
    emotion.identifier = identifier;
    emotion.displayName = displayName;
    return emotion;
}

- (NSString *)description {
    return [NSString stringWithFormat:@"%@, identifier: %@, displayName: %@", [super description], self.identifier, self.displayName];
}

- (UIImage *)image {
    if (!_image) {
        _image = [QMUIHelper imageInBundle:[QMUIHelper resourcesBundleWithName:QMUIResourcesQQEmotionBundleName] withName:self.identifier];
    }
    return _image;
}

@end

@class QMUIEmotionPageView;

@protocol QMUIEmotionPageViewDelegate <NSObject>

@optional
- (void)emotionPageView:(QMUIEmotionPageView *)emotionPageView didSelectEmotion:(QMUIEmotion *)emotion atIndex:(NSInteger)index;
- (void)didSelectDeleteButtonInEmotionPageView:(QMUIEmotionPageView *)emotionPageView;

@end

/// 表情面板每一页的cell，在drawRect里将所有表情绘制上去，同时自带一个末尾的删除按钮
@interface QMUIEmotionPageView : UICollectionViewCell

@property(nonatomic, weak) QMUIEmotionView<QMUIEmotionPageViewDelegate> *delegate;

/// 表情被点击时盖在表情上方用于表示选中的遮罩
@property(nonatomic, strong) UIView *emotionSelectedBackgroundView;

/// 表情面板右下角的删除按钮
@property(nonatomic, strong) QMUIButton *deleteButton;

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
        
        self.deleteButton = [[QMUIButton alloc] init];
        self.deleteButton.adjustsButtonWhenHighlighted = NO;// 去掉QMUIButton默认的高亮动画，从而加快连续快速点击的响应速度
        self.deleteButton.qmui_needsTakeOverTouchEvent = YES;
        [self.deleteButton addTarget:self action:@selector(handleDeleteButtonEvent:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:self.deleteButton];
        
        self.emotionHittingRects = [[NSMutableArray alloc] init];
        self.tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapGestureRecognizer:)];
        [self addGestureRecognizer:self.tapGestureRecognizer];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    // 删除按钮必定布局到最后一个表情的位置，且与表情上下左右居中
    [self.deleteButton sizeToFit];
    self.deleteButton.frame = CGRectSetXY(self.deleteButton.frame, flat(CGRectGetWidth(self.bounds) - self.padding.right - CGRectGetWidth(self.deleteButton.frame) - (self.emotionSize.width - CGRectGetWidth(self.deleteButton.frame)) / 2.0), flat(CGRectGetHeight(self.bounds) - self.padding.bottom - CGRectGetHeight(self.deleteButton.frame) - (self.emotionSize.height - CGRectGetHeight(self.deleteButton.frame)) / 2.0));
}

- (void)drawRect:(CGRect)rect {
    [self.emotionHittingRects removeAllObjects];
    
    CGSize contentSize = CGRectInsetEdges(self.bounds, self.padding).size;
    NSInteger emotionCountPerRow = (contentSize.width + self.minimumEmotionHorizontalSpacing) / (self.emotionSize.width + self.minimumEmotionHorizontalSpacing);
    CGFloat emotionHorizontalSpacing = flat((contentSize.width - emotionCountPerRow * self.emotionSize.width) / (emotionCountPerRow - 1));
    CGFloat emotionVerticalSpacing = flat((contentSize.height - self.numberOfRows * self.emotionSize.height) / (self.numberOfRows - 1));
    
    CGPoint emotionOrigin = CGPointZero;
    for (NSInteger i = 0, l = self.emotions.count; i < l; i++) {
        NSInteger row = i / emotionCountPerRow;
        emotionOrigin.x = self.padding.left + (self.emotionSize.width + emotionHorizontalSpacing) * (i % emotionCountPerRow);
        emotionOrigin.y = self.padding.top + (self.emotionSize.height + emotionVerticalSpacing) * row;
        QMUIEmotion *emotion = self.emotions[i];
        CGRect emotionRect = CGRectMake(emotionOrigin.x, emotionOrigin.y, self.emotionSize.width, self.emotionSize.height);
        CGRect emotionHittingRect = CGRectInsetEdges(emotionRect, self.emotionSelectedBackgroundExtension);
        [self.emotionHittingRects addObject:[NSValue valueWithCGRect:emotionHittingRect]];
        [self drawImage:emotion.image inRect:emotionRect];
    }
}

- (void)drawImage:(UIImage *)image inRect:(CGRect)contextRect {
    CGSize imageSize = image.size;
    CGFloat horizontalRatio = CGRectGetWidth(contextRect) / imageSize.width;
    CGFloat verticalRatio = CGRectGetHeight(contextRect) / imageSize.height;
    // 表情图片按UIViewContentModeScaleAspectFit的方式来绘制
    CGFloat ratio = fminf(horizontalRatio, verticalRatio);
    CGRect drawingRect = CGRectZero;
    drawingRect.size.width = imageSize.width * ratio;
    drawingRect.size.height = imageSize.height * ratio;
    drawingRect = CGRectSetXY(drawingRect, CGRectGetMinXHorizontallyCenter(contextRect, drawingRect), CGRectGetMinYVerticallyCenter(contextRect, drawingRect));
    if (self.debug) {
        CGContextRef context = UIGraphicsGetCurrentContext();
        CGContextSetLineWidth(context, PixelOne);
        CGContextSetStrokeColorWithColor(context, UIColorTestRed.CGColor);
        CGContextStrokeRect(context, CGRectInset(contextRect, PixelOne / 2.0, PixelOne / 2.0));
    }
    [image drawInRect:drawingRect];
}

- (void)handleTapGestureRecognizer:(UITapGestureRecognizer *)gestureRecognizer {
    CGPoint location = [gestureRecognizer locationInView:self];
    for (NSInteger i = 0; i < self.emotionHittingRects.count; i ++) {
        CGRect rect = [self.emotionHittingRects[i] CGRectValue];
        if (CGRectContainsPoint(rect, location)) {
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
                NSLog(@"最终确定了点击的是当前页里的第 %@ 个表情，%@", @(i), emotion);
            }
            return;
        }
    }
}

- (void)handleDeleteButtonEvent:(QMUIButton *)deleteButton {
    if ([self.delegate respondsToSelector:@selector(didSelectDeleteButtonInEmotionPageView:)]) {
        [self.delegate didSelectDeleteButtonInEmotionPageView:self];
    }
}

@end

@interface QMUIEmotionView ()<QMUIEmotionPageViewDelegate>

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

- (void)didInitializedWithFrame:(CGRect)frame {
    self.debug = NO;
    
    self.pagedEmotions = [[NSMutableArray alloc] init];
    
    _collectionViewLayout = [[UICollectionViewFlowLayout alloc] init];
    self.collectionViewLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    self.collectionViewLayout.minimumLineSpacing = 0;
    self.collectionViewLayout.minimumInteritemSpacing = 0;
    self.collectionViewLayout.sectionInset = UIEdgeInsetsZero;
    
    _collectionView = [[UICollectionView alloc] initWithFrame:CGRectMakeWithSize(frame.size) collectionViewLayout:self.collectionViewLayout];
    self.collectionView.backgroundColor = UIColorClear;
    self.collectionView.scrollsToTop = NO;
    self.collectionView.pagingEnabled = YES;
    self.collectionView.showsHorizontalScrollIndicator = NO;
    self.collectionView.dataSource = self;
    self.collectionView.delegate = self;
    [self.collectionView registerClass:[QMUIEmotionPageView class] forCellWithReuseIdentifier:@"page"];
    [self addSubview:self.collectionView];
    
    _pageControl = [[UIPageControl alloc] init];
    [self.pageControl addTarget:self action:@selector(handlePageControlEvent:) forControlEvents:UIControlEventValueChanged];
    [self addSubview:self.pageControl];
    
    _sendButton = [[QMUIButton alloc] init];
    [self.sendButton setTitle:@"发送" forState:UIControlStateNormal];
    self.sendButton.contentEdgeInsets = UIEdgeInsetsMake(5, 17, 5, 17);
    [self.sendButton sizeToFit];
    [self addSubview:self.sendButton];
}

- (void)setEmotions:(NSArray<QMUIEmotion *> *)emotions {
    _emotions = emotions;
    [self pageEmotions];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    BOOL collectionViewSizeChanged = !CGSizeEqualToSize(self.bounds.size, self.collectionView.bounds.size);
    self.collectionView.frame = self.bounds;
    self.collectionViewLayout.itemSize = self.collectionView.bounds.size;
    
    if (collectionViewSizeChanged) {
        [self pageEmotions];
    }
    
    CGFloat pageControlHeight = 16;
    self.pageControl.frame = CGRectMake(0, CGRectGetHeight(self.bounds) - self.pageControlMarginBottom - pageControlHeight, CGRectGetWidth(self.bounds), pageControlHeight);
    
    self.sendButton.frame = CGRectSetXY(self.sendButton.frame, CGRectGetWidth(self.bounds) - self.sendButtonMargins.right - CGRectGetWidth(self.sendButton.frame), CGRectGetHeight(self.bounds) - self.sendButtonMargins.bottom - CGRectGetHeight(self.sendButton.frame));
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
    [pageView.deleteButton setImage:self.deleteButtonImage forState:UIControlStateNormal];
    [pageView.deleteButton setImage:[self.deleteButtonImage qmui_imageWithAlpha:ButtonHighlightedAlpha] forState:UIControlStateHighlighted];
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

- (void)didSelectDeleteButtonInEmotionPageView:(QMUIEmotionPageView *)emotionPageView {
    if (self.didSelectDeleteButtonBlock) {
        self.didSelectDeleteButtonBlock();
    }
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
    appearance.backgroundColor = UIColorWhite;
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
    
    UIPageControl *pageControlAppearance = [UIPageControl appearanceWhenContainedIn:[QMUIEmotionView class], nil];
    pageControlAppearance.pageIndicatorTintColor = UIColorMake(210, 210, 210);
    pageControlAppearance.currentPageIndicatorTintColor = UIColorMake(162, 162, 162);
}

@end
