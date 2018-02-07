//
//  QMUIMoreOperationController.m
//  qmui
//
//  Created by QQMail on 15/1/28.
//  Copyright (c) 2015年 QMUI Team. All rights reserved.
//

#import "QMUIMoreOperationController.h"
#import "QMUICommonDefines.h"
#import "QMUIConfiguration.h"
#import "QMUIHelper.h"
#import "CALayer+QMUI.h"

#define TagOffset 999

@implementation QMUIMoreOperationController (UIAppearance)

+ (void)initialize {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        [self appearance];
    });
}

static QMUIMoreOperationController *moreOperationViewControllerAppearance;
+ (instancetype)appearance {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        [self resetAppearance];
    });
    return moreOperationViewControllerAppearance;
}

+ (void)resetAppearance {
    if (!moreOperationViewControllerAppearance) {
        moreOperationViewControllerAppearance = [[QMUIMoreOperationController alloc] init];
        moreOperationViewControllerAppearance.contentBackgroundColor = UIColorWhite;
        moreOperationViewControllerAppearance.contentSeparatorColor = UIColorMakeWithRGBA(0, 0, 0, .15f);
        moreOperationViewControllerAppearance.cancelButtonBackgroundColor = UIColorWhite;
        moreOperationViewControllerAppearance.cancelButtonTitleColor = UIColorBlue;
        moreOperationViewControllerAppearance.cancelButtonSeparatorColor = UIColorMakeWithRGBA(0, 0, 0, .15f);
        moreOperationViewControllerAppearance.itemBackgroundColor = UIColorClear;
        moreOperationViewControllerAppearance.itemTitleColor = UIColorGrayDarken;
        moreOperationViewControllerAppearance.itemTitleFont = UIFontMake(11);
        moreOperationViewControllerAppearance.cancelButtonFont = UIFontBoldMake(17);
        moreOperationViewControllerAppearance.contentEdgeMargin = 10;
        moreOperationViewControllerAppearance.contentMaximumWidth = [QMUIHelper screenSizeFor55Inch].width - moreOperationViewControllerAppearance.contentEdgeMargin * 2;
        moreOperationViewControllerAppearance.contentCornerRadius = 10;
        moreOperationViewControllerAppearance.itemMarginTop = 9;
        moreOperationViewControllerAppearance.topScrollViewInsets = UIEdgeInsetsMake(18, 14, 12, 14);
        moreOperationViewControllerAppearance.bottomScrollViewInsets = UIEdgeInsetsMake(18, 14, 12, 14);
        moreOperationViewControllerAppearance.cancelButtonHeight = 52.0;
        moreOperationViewControllerAppearance.cancelButtonMarginTop = 0;
    }
}

@end


@interface QMUIMoreOperationItemView ()

@property (nonatomic, assign, readwrite) QMUIMoreOperationItemType itemType;

@end


@implementation QMUIMoreOperationItemView {
    NSInteger _tag;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.imagePosition = QMUIButtonImagePositionTop;
        self.adjustsButtonWhenHighlighted = NO;
        self.adjustsImageWhenHighlighted = YES;
        self.adjustsImageWhenDisabled = YES;
        self.titleLabel.numberOfLines = 0;
        self.titleLabel.textAlignment = NSTextAlignmentCenter;
        self.imageView.contentMode = UIViewContentModeCenter;
        self.imageView.backgroundColor = UIColorClear;
    }
    return self;
}

- (void)setTag:(NSInteger)tag {
    _tag = tag + TagOffset;
    [super setTag:_tag];
}

- (NSInteger)tag {
    return _tag - TagOffset;
}

@end


@interface QMUIMoreOperationController ()

@property(nonatomic, strong) UIView *containerView;
@property(nonatomic, strong) UIView *contentView;
@property(nonatomic, strong) UIControl *maskView;
@property(nonatomic, strong) UIScrollView *importantItemsScrollView;
@property(nonatomic, strong) UIScrollView *normalItemsScrollView;

@property(nonatomic, strong) CALayer *scrollViewDividingLayer;
@property(nonatomic, strong) CALayer *cancelButtonDividingLayer;

@property(nonatomic, strong) NSMutableArray *importantItems;
@property(nonatomic, strong) NSMutableArray *normalItems;
@property(nonatomic, strong) NSMutableArray *importantShowingItems;
@property(nonatomic, strong) NSMutableArray *normalShowingItems;

@property(nonatomic, assign, readwrite) BOOL showing;
@property(nonatomic, assign, readwrite) BOOL animating;

@end
@implementation QMUIMoreOperationController

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
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
    if (moreOperationViewControllerAppearance) {
        self.contentBackgroundColor = [QMUIMoreOperationController appearance].contentBackgroundColor;
        self.contentSeparatorColor = [QMUIMoreOperationController appearance].contentSeparatorColor;
        self.cancelButtonBackgroundColor = [QMUIMoreOperationController appearance].cancelButtonBackgroundColor;
        self.cancelButtonTitleColor = [QMUIMoreOperationController appearance].cancelButtonTitleColor;
        self.cancelButtonSeparatorColor = [QMUIMoreOperationController appearance].cancelButtonSeparatorColor;
        self.itemBackgroundColor = [QMUIMoreOperationController appearance].itemBackgroundColor;
        self.itemTitleColor = [QMUIMoreOperationController appearance].itemTitleColor;
        self.itemTitleFont = [QMUIMoreOperationController appearance].itemTitleFont;
        self.cancelButtonFont = [QMUIMoreOperationController appearance].cancelButtonFont;
        self.contentEdgeMargin = [QMUIMoreOperationController appearance].contentEdgeMargin;
        self.contentMaximumWidth = [QMUIMoreOperationController appearance].contentMaximumWidth;
        self.contentCornerRadius = [QMUIMoreOperationController appearance].contentCornerRadius;
        self.itemMarginTop = [QMUIMoreOperationController appearance].itemMarginTop;
        self.topScrollViewInsets = [QMUIMoreOperationController appearance].topScrollViewInsets;
        self.bottomScrollViewInsets = [QMUIMoreOperationController appearance].bottomScrollViewInsets;
        self.cancelButtonHeight = [QMUIMoreOperationController appearance].cancelButtonHeight;
        self.cancelButtonMarginTop = [QMUIMoreOperationController appearance].cancelButtonMarginTop;
    }
    self.importantItems = [[NSMutableArray alloc] init];
    self.normalItems = [[NSMutableArray alloc] init];
    self.importantShowingItems = [[NSMutableArray alloc] init];
    self.normalShowingItems = [[NSMutableArray alloc] init];
    
    [self initSubviewsIfNeeded];
}

- (void)setContentBackgroundColor:(UIColor *)contentBackgroundColor {
    _contentBackgroundColor = contentBackgroundColor;
    if (self.contentView) {
        self.contentView.backgroundColor = contentBackgroundColor;
    }
}

- (void)setContentSeparatorColor:(UIColor *)contentSeparatorColor {
    _contentSeparatorColor = contentSeparatorColor;
    if (self.scrollViewDividingLayer) {
        self.scrollViewDividingLayer.backgroundColor = contentSeparatorColor.CGColor;
    }
}

- (void)setCancelButtonBackgroundColor:(UIColor *)cancelButtonBackgroundColor {
    _cancelButtonBackgroundColor = cancelButtonBackgroundColor;
    if (self.cancelButton) {
        self.cancelButton.backgroundColor = cancelButtonBackgroundColor;
    }
}

- (void)setCancelButtonTitleColor:(UIColor *)cancelButtonTitleColor {
    _cancelButtonTitleColor = cancelButtonTitleColor;
    if (self.cancelButton) {
        [self.cancelButton setTitleColor:cancelButtonTitleColor forState:UIControlStateNormal];
        [self.cancelButton setTitleColor:[cancelButtonTitleColor colorWithAlphaComponent:ButtonHighlightedAlpha] forState:UIControlStateHighlighted];
    }
}

- (void)setCancelButtonSeparatorColor:(UIColor *)cancelButtonSeparatorColor {
    _cancelButtonSeparatorColor = cancelButtonSeparatorColor;
    if (self.cancelButtonDividingLayer) {
        self.cancelButtonDividingLayer.backgroundColor = cancelButtonSeparatorColor.CGColor;
    }
}

- (void)setItemBackgroundColor:(UIColor *)itemBackgroundColor {
    _itemBackgroundColor = itemBackgroundColor;
    for (QMUIMoreOperationItemView *item in [self.importantItems arrayByAddingObjectsFromArray:self.normalItems]) {
        item.imageView.backgroundColor = itemBackgroundColor;
    }
}

- (void)setItemTitleColor:(UIColor *)itemTitleColor {
    _itemTitleColor = itemTitleColor;
    for (QMUIMoreOperationItemView *item in [self.importantItems arrayByAddingObjectsFromArray:self.normalItems]) {
        [item setTitleColor:itemTitleColor forState:UIControlStateNormal];
    }
}

- (void)setItemTitleFont:(UIFont *)itemTitleFont {
    _itemTitleFont = itemTitleFont;
    for (QMUIMoreOperationItemView *item in [self.importantItems arrayByAddingObjectsFromArray:self.normalItems]) {
        item.titleLabel.font = itemTitleFont;
    }
}

- (void)setCancelButtonFont:(UIFont *)cancelButtonFont {
    _cancelButtonFont = cancelButtonFont;
    if (self.cancelButton) {
        self.cancelButton.titleLabel.font = cancelButtonFont;
    }
}

- (void)setContentCornerRadius:(CGFloat)contentCornerRadius {
    _contentCornerRadius = contentCornerRadius;
    [self updateCornerRadius];
}

- (void)setCancelButtonMarginTop:(CGFloat)cancelButtonMarginTop {
    _cancelButtonMarginTop = cancelButtonMarginTop;
    [self updateCornerRadius];
}

- (void)updateCornerRadius {
    if (self.cancelButtonMarginTop > 0) {
        self.contentView.layer.cornerRadius = self.contentCornerRadius;
        self.containerView.layer.cornerRadius = 0;
        self.cancelButton.layer.cornerRadius = self.contentCornerRadius;
    } else {
        self.containerView.layer.cornerRadius = self.contentCornerRadius;
        self.contentView.layer.cornerRadius = 0;
        self.cancelButton.layer.cornerRadius = 0;
    }
}

- (void)setItemMarginTop:(CGFloat)itemMarginTop {
    _itemMarginTop = itemMarginTop;
    for (QMUIMoreOperationItemView *item in [self.importantItems arrayByAddingObjectsFromArray:self.normalItems]) {
        item.titleEdgeInsets = UIEdgeInsetsMake(itemMarginTop, 0, 0, 0);
    }
}

- (void)initSubviewsIfNeeded {
    
    self.maskView = [[UIControl alloc] init];
    self.maskView.alpha = 0;
    self.maskView.backgroundColor = UIColorMask;
    [self.maskView addTarget:self action:@selector(handleMaskControlEvent:) forControlEvents:UIControlEventTouchUpInside];
    
    self.containerView = [[UIView alloc] init];
    self.containerView.clipsToBounds = YES;
    
    self.contentView = [[UIView alloc] init];
    self.contentView.clipsToBounds = YES;
    self.contentView.backgroundColor = self.contentBackgroundColor;
    
    self.scrollViewDividingLayer = [CALayer layer];
    self.scrollViewDividingLayer.hidden = YES;
    self.scrollViewDividingLayer.backgroundColor = self.contentSeparatorColor.CGColor;
    [self.scrollViewDividingLayer qmui_removeDefaultAnimations];
    
    self.importantItemsScrollView = [[UIScrollView alloc] init];
    self.importantItemsScrollView.showsHorizontalScrollIndicator = NO;
    self.importantItemsScrollView.showsVerticalScrollIndicator = NO;
    
    self.normalItemsScrollView = [[UIScrollView alloc] init];
    self.normalItemsScrollView.showsHorizontalScrollIndicator = NO;
    self.normalItemsScrollView.showsVerticalScrollIndicator = NO;
    self.normalItemsScrollView.hidden = YES;
    
    _cancelButton = [[QMUIButton alloc] init];
    self.cancelButton.adjustsButtonWhenHighlighted = NO;
    self.cancelButton.titleLabel.font = self.cancelButtonFont;
    self.cancelButton.backgroundColor = self.cancelButtonBackgroundColor;
    [self.cancelButton setTitle:@"取消" forState:UIControlStateNormal];
    [self.cancelButton setTitleColor:self.cancelButtonTitleColor forState:UIControlStateNormal];
    [self.cancelButton setTitleColor:[self.cancelButtonTitleColor colorWithAlphaComponent:ButtonHighlightedAlpha] forState:UIControlStateHighlighted];
    [self.cancelButton addTarget:self action:@selector(handleCancelButtonEvent:) forControlEvents:UIControlEventTouchUpInside];
    
    self.cancelButtonDividingLayer = [CALayer layer];
    self.cancelButtonDividingLayer.backgroundColor = self.cancelButtonSeparatorColor.CGColor;
    [self.cancelButtonDividingLayer qmui_removeDefaultAnimations];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.view addSubview:self.maskView];
    [self.view addSubview:self.containerView];
    [self.containerView addSubview:self.contentView];
    [self.contentView.layer addSublayer:self.scrollViewDividingLayer];
    [self.contentView addSubview:self.importantItemsScrollView];
    [self.contentView addSubview:self.normalItemsScrollView];
    [self.containerView addSubview:self.cancelButton];
    [self.containerView.layer addSublayer:self.cancelButtonDividingLayer];
    [self updateCornerRadius];
}

- (NSArray *)items {
    return [self.importantItems arrayByAddingObjectsFromArray:self.normalItems];
}

- (void)resetShowingItemsArray {
    [self.importantShowingItems removeAllObjects];
    [self.normalShowingItems removeAllObjects];
    for (QMUIMoreOperationItemView *item in self.importantItems) {
        if (!item.hidden) {
            [self.importantShowingItems addObject:item];
        }
    }
    for (QMUIMoreOperationItemView *item in self.normalItems) {
        if (!item.hidden) {
            [self.normalShowingItems addObject:item];
        }
    }
}

- (void)viewDidLayoutSubviews {
    
    [super viewDidLayoutSubviews];
    [self resetShowingItemsArray];
    
    self.maskView.frame = self.view.bounds;
    
    CGFloat layoutOriginY = 0;
    CGFloat contentWidth =  fmin(CGRectGetWidth(self.view.bounds) - self.contentEdgeMargin * 2, self.contentMaximumWidth);
    
    UIEdgeInsets importantScrollViewInsets = self.topScrollViewInsets;
    UIEdgeInsets normaltScrollViewInsets = self.bottomScrollViewInsets;
    
    if (self.importantShowingItems.count <= 0 || self.normalShowingItems.count <= 0) {
        // 当两个scrollView其中一个没有的时候，需要调整对应的insets
        if (self.importantShowingItems.count <= 0) {
            normaltScrollViewInsets = UIEdgeInsetsSetTop(normaltScrollViewInsets, importantScrollViewInsets.top);
            self.bottomScrollViewInsets = normaltScrollViewInsets;
        }
        if (self.normalShowingItems.count <= 0) {
            importantScrollViewInsets = UIEdgeInsetsSetBottom(importantScrollViewInsets, normaltScrollViewInsets.bottom);
            self.topScrollViewInsets = importantScrollViewInsets;
        }
    }
    
    BOOL isLargeSreen = CGRectGetWidth(self.view.bounds) > [QMUIHelper screenSizeFor40Inch].width;
    NSInteger maxItemCountInScrollView = MAX(self.importantShowingItems.count, self.normalShowingItems.count);
    NSInteger itemCountForTotallyVisibleItem = isLargeSreen ? 4 : 3;
    
    CGFloat itemWidth = flat((contentWidth - fmaxf(UIEdgeInsetsGetHorizontalValue(importantScrollViewInsets), UIEdgeInsetsGetHorizontalValue(normaltScrollViewInsets))) / itemCountForTotallyVisibleItem) - (maxItemCountInScrollView > itemCountForTotallyVisibleItem ? (isLargeSreen ? 8 : 12) : 0);
    
    CGFloat itemMaxHeight = 0;
    CGFloat itemMaxX = 0;
    if (self.importantShowingItems.count > 0) {
        self.importantItemsScrollView.hidden = NO;
        for (NSInteger i = 0; i < self.importantShowingItems.count; i++) {
            QMUIMoreOperationItemView *itemView = [self.importantShowingItems objectAtIndex:i];
            [itemView sizeToFit];
            itemView.frame = CGRectFlatted(CGRectMake(itemWidth * i, 0, itemWidth, CGRectGetHeight(itemView.bounds)));
            itemMaxX = CGRectGetMaxX(itemView.frame);
            if (CGRectGetHeight(itemView.bounds) > itemMaxHeight) {
                itemMaxHeight = CGRectGetHeight(itemView.bounds);
            }
        }
        self.importantItemsScrollView.contentSize = CGSizeMake(flat(itemMaxX), flat(itemMaxHeight));
        self.importantItemsScrollView.contentInset = importantScrollViewInsets;
        self.importantItemsScrollView.contentOffset = CGPointMake(-self.importantItemsScrollView.contentInset.left, -self.importantItemsScrollView.contentInset.top);
        self.importantItemsScrollView.frame = CGRectFlatted(CGRectMake(0, 0, contentWidth, UIEdgeInsetsGetVerticalValue(self.importantItemsScrollView.contentInset) + self.importantItemsScrollView.contentSize.height));
        layoutOriginY = CGRectGetMaxY(self.importantItemsScrollView.frame);
    } else {
        self.importantItemsScrollView.hidden = YES;
    }
    
    itemMaxHeight = 0;
    itemMaxX = 0;
    if (self.normalShowingItems.count > 0) {
        self.normalItemsScrollView.hidden = NO;
        self.scrollViewDividingLayer.hidden = !(self.importantShowingItems.count > 0);
        self.scrollViewDividingLayer.frame = CGRectFlatted(CGRectMake(0, layoutOriginY, contentWidth, PixelOne));
        layoutOriginY = CGRectGetMaxY(self.scrollViewDividingLayer.frame);
        for (NSInteger i = 0; i < self.normalShowingItems.count; i++) {
            QMUIMoreOperationItemView *itemView = [self.normalShowingItems objectAtIndex:i];
            [itemView sizeToFit];
            itemView.frame = CGRectFlatted(CGRectMake(itemWidth * i, 0, itemWidth, CGRectGetHeight(itemView.bounds)));
            itemMaxX = CGRectGetMaxX(itemView.frame);
            if (CGRectGetHeight(itemView.bounds) > itemMaxHeight) {
                itemMaxHeight = CGRectGetHeight(itemView.bounds);
            }
        }
        self.normalItemsScrollView.contentSize = CGSizeMake(flat(itemMaxX), flat(itemMaxHeight));
        self.normalItemsScrollView.contentInset = normaltScrollViewInsets;
        self.normalItemsScrollView.frame = CGRectFlatted(CGRectMake(0, layoutOriginY, contentWidth, UIEdgeInsetsGetVerticalValue(self.normalItemsScrollView.contentInset) + self.normalItemsScrollView.contentSize.height));
        self.normalItemsScrollView.contentOffset = CGPointMake(-self.normalItemsScrollView.contentInset.left, -self.normalItemsScrollView.contentInset.top);
        layoutOriginY = CGRectGetMaxY(self.normalItemsScrollView.frame);
    } else {
        self.normalItemsScrollView.hidden = YES;
        self.scrollViewDividingLayer.hidden = YES;
    }
    
    self.contentView.frame = CGRectFlatted(CGRectMake(0, 0, contentWidth, layoutOriginY));
    layoutOriginY = CGRectGetMaxY(self.contentView.frame);

    self.cancelButtonDividingLayer.hidden = self.cancelButtonMarginTop > 0;
    self.cancelButtonDividingLayer.frame = CGRectFlatted(CGRectMake(0, layoutOriginY + self.cancelButtonMarginTop, contentWidth, PixelOne));
    self.cancelButton.frame = CGRectFlatted(CGRectMake(0, CGRectGetMinY(self.cancelButtonDividingLayer.frame), contentWidth, self.cancelButtonHeight));
    
    self.containerView.frame = CGRectFlatted(CGRectMake((CGRectGetWidth(self.view.bounds) - contentWidth) / 2,
                                                    CGRectGetHeight(self.view.bounds) - CGRectGetMaxY(self.cancelButton.frame) - self.contentEdgeMargin,
                                                    contentWidth,
                                                    CGRectGetMaxY(self.cancelButton.frame)));
}

- (void)showFromBottom {
    if (self.showing || self.animating) {
        return;
    }
    
    __weak __typeof(self)weakSelf = self;
    
    QMUIModalPresentationViewController *modalPresentationViewController = [[QMUIModalPresentationViewController alloc] init];
    modalPresentationViewController.maximumContentViewWidth = CGFLOAT_MAX;
    modalPresentationViewController.contentViewMargins = UIEdgeInsetsZero;
    modalPresentationViewController.dimmingView = nil;
    modalPresentationViewController.contentViewController = self;
    
    modalPresentationViewController.showingAnimation = ^(UIView *dimmingView, CGRect containerBounds, CGFloat keyboardHeight, CGRect contentViewFrame, void(^completion)(BOOL finished)) {
        
        if ([weakSelf.delegate respondsToSelector:@selector(willPresentMoreOperationController:)]) {
            [weakSelf.delegate willPresentMoreOperationController:weakSelf];
        }
        
        weakSelf.containerView.frame = CGRectSetY(weakSelf.containerView.frame, CGRectGetHeight(weakSelf.view.bounds));
        [UIView animateWithDuration:.25 delay:0.0 options:QMUIViewAnimationOptionsCurveOut animations:^(void) {
            weakSelf.maskView.alpha = 1;
            weakSelf.containerView.frame = CGRectSetY(weakSelf.containerView.frame, CGRectGetHeight(weakSelf.view.bounds) - CGRectGetHeight(weakSelf.containerView.frame) - weakSelf.contentEdgeMargin);
        } completion:^(BOOL finished) {
            weakSelf.showing = YES;
            weakSelf.animating = NO;
            if ([weakSelf.delegate respondsToSelector:@selector(didPresentMoreOperationController:)]) {
                [weakSelf.delegate didPresentMoreOperationController:weakSelf];
            }
            if (completion) {
                completion(finished);
            }
        }];
    };
    
    modalPresentationViewController.hidingAnimation = ^(UIView *dimmingView, CGRect containerBounds, CGFloat keyboardHeight, void(^completion)(BOOL finished)) {
        [UIView animateWithDuration:.25 delay:0.0 options:QMUIViewAnimationOptionsCurveOut animations:^(void) {
            weakSelf.maskView.alpha = 0;
            weakSelf.containerView.frame = CGRectSetY(weakSelf.containerView.frame, CGRectGetHeight(containerBounds));
        } completion:^(BOOL finished) {
            if (completion) {
                completion(finished);
            }
        }];
    };
    
    self.animating = YES;
    [modalPresentationViewController showWithAnimated:YES completion:NULL];
}

- (void)hideToBottom {
    [self hideToBottomCancelled:NO];
}

- (void)hideToBottomCancelled:(BOOL)cancelled {
    
    if (!self.showing || self.animating) {
        return;
    }
    self.animating = YES;
    
    __weak __typeof(self)weakSelf = self;
    
    if ([self.delegate respondsToSelector:@selector(willDismissMoreOperationController:cancelled:)]) {
        [self.delegate willDismissMoreOperationController:self cancelled:cancelled];
    }
    
    [self.modalPresentedViewController hideWithAnimated:YES completion:^(BOOL finished) {
        weakSelf.showing = NO;
        weakSelf.animating = NO;
        if ([weakSelf.delegate respondsToSelector:@selector(didDismissMoreOperationController:cancelled:)]) {
            [weakSelf.delegate didDismissMoreOperationController:weakSelf cancelled:cancelled];
        }
    }];
}

- (void)handleCancelButtonEvent:(id)sender {
    [self hideToBottomCancelled:YES];
}

- (void)handleMaskControlEvent:(id)sender {
    [self hideToBottomCancelled:YES];
}

- (NSInteger)addItemWithTitle:(NSString *)title selectedTitle:(NSString *)selectedTitle image:(UIImage *)image selectedImage:(UIImage *)selectedImage type:(QMUIMoreOperationItemType)itemType tag:(NSInteger)tag {
    QMUIMoreOperationItemView *itemView = [self createItemWithTitle:title selectedTitle:selectedTitle image:image selectedImage:selectedImage type:itemType tag:tag];
    if (itemView.itemType == QMUIMoreOperationItemTypeImportant) {
        return [self insertItem:itemView toIndex:self.importantItems.count] ? [self.importantItems indexOfObject:itemView] : -1;
    } else if (itemView.itemType == QMUIMoreOperationItemTypeNormal) {
        return [self insertItem:itemView toIndex:self.normalItems.count] ? [self.normalItems indexOfObject:itemView] : -1;
    }
    return -1;
}

- (NSInteger)addItemWithTitle:(NSString *)title image:(UIImage *)image type:(QMUIMoreOperationItemType)itemType tag:(NSInteger)tag {
    return [self addItemWithTitle:title selectedTitle:title image:image selectedImage:image type:itemType tag:tag];
}

- (NSInteger)addItemWithTitle:(NSString *)title selectedTitle:(NSString *)selectedTitle image:(UIImage *)image selectedImage:(UIImage *)selectedImage type:(QMUIMoreOperationItemType)itemType {
    return [self addItemWithTitle:title selectedTitle:selectedTitle image:image selectedImage:selectedImage type:itemType tag:-1];
}

- (NSInteger)addItemWithTitle:(NSString *)title image:(UIImage *)image type:(QMUIMoreOperationItemType)itemType {
    return [self addItemWithTitle:title selectedTitle:title image:image selectedImage:image type:itemType tag:-1];
}

- (QMUIMoreOperationItemView *)createItemWithTitle:(NSString *)title selectedTitle:(NSString *)selectedTitle image:(UIImage *)image selectedImage:(UIImage *)selectedImage type:(QMUIMoreOperationItemType)itemType tag:(NSInteger)tag {
    QMUIMoreOperationItemView *itemView = [[QMUIMoreOperationItemView alloc] init];
    itemView.itemType = itemType;
    itemView.titleLabel.font = self.itemTitleFont;
    itemView.titleEdgeInsets = UIEdgeInsetsMake(self.itemMarginTop, 0, 0, 0);
    [itemView setImage:image forState:UIControlStateNormal];
    [itemView setImage:selectedImage forState:UIControlStateSelected];
    [itemView setImage:selectedImage forState:UIControlStateHighlighted|UIControlStateSelected];
    [itemView setTitle:title forState:UIControlStateNormal];
    [itemView setTitle:selectedTitle forState:UIControlStateHighlighted|UIControlStateSelected];
    [itemView setTitle:selectedTitle forState:UIControlStateSelected];
    [itemView setTitleColor:self.itemTitleColor forState:UIControlStateNormal];
    itemView.imageView.backgroundColor = self.itemBackgroundColor;
    itemView.tag = tag;
    [itemView addTarget:self action:@selector(handleButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    return itemView;
}

- (BOOL)insertItem:(QMUIMoreOperationItemView *)itemView toIndex:(NSInteger)index {
    if (itemView.itemType == QMUIMoreOperationItemTypeImportant) {
        [self.importantItems insertObject:itemView atIndex:index];
        [self.importantItemsScrollView addSubview:itemView];
        return YES;
    } else if (itemView.itemType == QMUIMoreOperationItemTypeNormal) {
        [self.normalItems insertObject:itemView atIndex:index];
        [self.normalItemsScrollView addSubview:itemView];
        return YES;
    }
    return NO;
}

- (QMUIMoreOperationItemView *)itemAtIndex:(NSInteger)index type:(QMUIMoreOperationItemType)type {
    if (type == QMUIMoreOperationItemTypeImportant) {
        return [self.importantItems objectAtIndex:index];
    } else {
        return [self.normalItems objectAtIndex:index];
    }
}

- (QMUIMoreOperationItemView *)itemAtTag:(NSInteger)tag {
    QMUIMoreOperationItemView *item = (QMUIMoreOperationItemView *)[self.importantItemsScrollView viewWithTag:tag + TagOffset];
    if (!item) {
        item = (QMUIMoreOperationItemView *)[self.normalItemsScrollView viewWithTag:tag + TagOffset];
    }
    return item;
}

- (void)setItemHidden:(BOOL)hidden index:(NSInteger)index type:(QMUIMoreOperationItemType)type {
    QMUIMoreOperationItemView *item = [self itemAtIndex:index type:type];
    item.hidden = hidden;
}

- (void)setItemHidden:(BOOL)hidden tag:(NSInteger)tag {
    QMUIMoreOperationItemView *item = [self itemAtTag:tag];
    item.hidden = hidden;
}

- (void)handleButtonClick:(id)sender {
    QMUIMoreOperationItemView *item = sender;
    NSUInteger index;
    QMUIMoreOperationItemType itemType;
    if (item.superview == self.importantItemsScrollView) {
        index = [self.importantItems indexOfObject:item];
        itemType = QMUIMoreOperationItemTypeImportant;
    } else {
        index = [self.normalItems indexOfObject:item];
        itemType = QMUIMoreOperationItemTypeNormal;
    }
    NSInteger tag = item.tag;
    if ([self.delegate respondsToSelector:@selector(moreOperationController:didSelectItemAtIndex:type:)]) {
        [self.delegate moreOperationController:self didSelectItemAtIndex:index type:itemType];
    }
    if ([self.delegate respondsToSelector:@selector(moreOperationController:didSelectItemAtTag:)]) {
        [self.delegate moreOperationController:self didSelectItemAtTag:tag];
    }
}

#pragma mark - <QMUIModalPresentationContentViewControllerProtocol>

- (CGSize)preferredContentSizeInModalPresentationViewController:(QMUIModalPresentationViewController *)controller limitSize:(CGSize)limitSize {
    return controller.view.bounds.size;
}

@end
