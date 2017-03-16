//
//  QMUINavigationTitleView.m
//  qmui
//
//  Created by QQMail on 14-7-2.
//  Copyright (c) 2014年 QMUI Team. All rights reserved.
//

#import "QMUINavigationTitleView.h"
#import "QMUICommonDefines.h"
#import "QMUIConfiguration.h"
#import "UIImage+QMUI.h"
#import "UILabel+QMUI.h"
#import "UIActivityIndicatorView+QMUI.h"
#import "UIView+QMUI.h"

@interface UINavigationBar (QMUI)

@end

@implementation UINavigationBar (QMUI)

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        ReplaceMethod([self class], @selector(layoutSubviews), @selector(qmui_navigationBarLayoutSubviews));
    });
}

- (void)qmui_navigationBarLayoutSubviews {
    QMUINavigationTitleView *titleView = (QMUINavigationTitleView *)self.topItem.titleView;
    
    if ([titleView isKindOfClass:[QMUINavigationTitleView class]]) {
        CGFloat titleViewMaximumWidth = CGRectGetWidth(titleView.bounds);// 初始状态下titleView会被设置为UINavigationBar允许的最大宽度
        CGSize titleViewSize = [titleView sizeThatFits:CGSizeMake(titleViewMaximumWidth, CGFLOAT_MAX)];
        titleViewSize.height = ceil(titleViewSize.height);// titleView的高度如果非pt整数，会导致计算出来的y值时多时少，所以干脆做一下pt取整，这个策略不要改，改了要重新测试push过程中titleView是否会跳动
        
        // 当在UINavigationBar里使用自定义的titleView时，就算titleView的sizeThatFits:返回正确的高度，navigationBar也不会帮你设置高度（但会帮你设置宽度），所以我们需要自己更新高度并且修正y值
        if (CGRectGetHeight(titleView.bounds) != titleViewSize.height) {
//            NSLog(@"【%@】修正布局前\ntitleView = %@", NSStringFromClass(titleView.class), titleView);
            CGFloat titleViewMinY = flat(CGRectGetMinY(titleView.frame) - ((titleViewSize.height - CGRectGetHeight(titleView.bounds)) / 2.0));// 系统对titleView的y值布局是flat，注意，不能改，改了要测试
            titleView.frame = CGRectMake(CGRectGetMinX(titleView.frame), titleViewMinY, fminf(titleViewMaximumWidth, titleViewSize.width), titleViewSize.height);
//            NSLog(@"【%@】修正布局后\ntitleView = %@", NSStringFromClass(titleView.class), titleView);
        }
    } else {
        titleView = nil;
    }
    
    [self qmui_navigationBarLayoutSubviews];
    
    if (titleView) {
//        NSLog(@"【%@】系统布局后\ntitleView = %@", NSStringFromClass(titleView.class), titleView);
    }
}

@end

@interface QMUINavigationTitleView ()

@property(nonatomic, assign) BOOL accessoryViewAnimating;
@property(nonatomic, assign) CGSize titleLabelSize;
@property(nonatomic, assign) CGSize subtitleLabelSize;
@property(nonatomic, strong) UIImageView *accessoryTypeView;
@end

@implementation QMUINavigationTitleView

#pragma mark - 初始化

- (instancetype)initWithFrame:(CGRect)frame {
    return [self initWithStyle:QMUINavigationTitleViewStyleDefault frame:frame];
}

- (instancetype)initWithStyle:(QMUINavigationTitleViewStyle)style {
    return [self initWithStyle:style frame:CGRectZero];
}

- (instancetype)initWithStyle:(QMUINavigationTitleViewStyle)style frame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        
        [self addTarget:self action:@selector(handleTouchTitleViewEvent) forControlEvents:UIControlEventTouchUpInside];
        
        _titleLabel = [[UILabel alloc] init];
        self.titleLabel.textAlignment = NSTextAlignmentCenter;
        self.titleLabel.lineBreakMode = NSLineBreakByTruncatingTail;
        [self addSubview:self.titleLabel];
        
        _subtitleLabel = [[UILabel alloc] init];
        self.subtitleLabel.textAlignment = NSTextAlignmentCenter;
        self.subtitleLabel.lineBreakMode = NSLineBreakByTruncatingTail;
        [self addSubview:self.subtitleLabel];
        
        self.userInteractionEnabled = NO;
        self.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
        self.style = style;
        self.needsLoadingView = NO;
        self.loadingViewHidden = YES;
        self.needsAccessoryPlaceholderSpace = NO;
        self.needsLoadingPlaceholderSpace = YES;
        self.accessoryType = QMUINavigationTitleViewAccessoryTypeNone;
        
        QMUINavigationTitleView *appearance = [QMUINavigationTitleView appearance];
        self.loadingViewSize = appearance.loadingViewSize;
        self.loadingViewMarginRight = appearance.loadingViewMarginRight;
        self.horizontalTitleFont = appearance.horizontalTitleFont;
        self.horizontalSubtitleFont = appearance.horizontalSubtitleFont;
        self.verticalTitleFont = appearance.verticalTitleFont;
        self.verticalSubtitleFont = appearance.verticalSubtitleFont;
        self.accessoryViewOffset = appearance.accessoryViewOffset;
        self.tintColor = NavBarTitleColor;
    }
    return self;
}

- (NSString *)description {
    return [NSString stringWithFormat:@"%@, title = %@, subtitle = %@", [super description], self.title, self.subtitle];
}

#pragma mark - 布局

- (void)refreshLayout {
    [self.superview setNeedsLayout];
    [self setNeedsLayout];
}

- (void)updateTitleLabelSize {
    if (self.titleLabel.text.length > 0) {
        // 这里用 CGSizeCeil 是特地保证 titleView 的 sizeThatFits 计算出来宽度是 pt 取整，这样在 layoutSubviews 我们以 px 取整时，才能保证不会出现水平居中时出现半像素的问题，然后由于我们对半像素会认为一像素，所以导致总体宽度多了一像素，从而导致文字布局可能出现缩略...
        self.titleLabelSize = CGSizeCeil([self.titleLabel sizeThatFits:CGSizeMake(CGFLOAT_MAX, CGFLOAT_MAX)]);
    } else {
        self.titleLabelSize = CGSizeZero;
    }
}

- (void)updateSubtitleLabelSize {
    if (self.subtitleLabel.text.length > 0) {
        // 这里用 CGSizeCeil 是特地保证 titleView 的 sizeThatFits 计算出来宽度是 pt 取整，这样在 layoutSubviews 我们以 px 取整时，才能保证不会出现水平居中时出现半像素的问题，然后由于我们对半像素会认为一像素，所以导致总体宽度多了一像素，从而导致文字布局可能出现缩略...
        self.subtitleLabelSize = CGSizeCeil([self.subtitleLabel sizeThatFits:CGSizeMake(CGFLOAT_MAX, CGFLOAT_MAX)]);
    } else {
        self.subtitleLabelSize = CGSizeZero;
    }
}

- (CGSize)loadingViewSpacingSize {
    if (self.needsLoadingView) {
        return CGSizeMake(self.loadingViewSize.width + self.loadingViewMarginRight, self.loadingViewSize.height);
    }
    return CGSizeZero;
}

- (CGSize)loadingViewSpacingSizeIfNeedsPlaceholder {
    return CGSizeMake([self loadingViewSpacingSize].width * (self.needsLoadingPlaceholderSpace ? 2 : 1), [self loadingViewSpacingSize].height);
}

- (CGSize)accessorySpacingSize {
    if (self.accessoryView || self.accessoryTypeView) {
        UIView *view = self.accessoryView ?: self.accessoryTypeView;
        return CGSizeMake(CGRectGetWidth(view.bounds) + self.accessoryViewOffset.x, CGRectGetHeight(view.bounds));
    }
    return CGSizeZero;
}

- (CGSize)accessorySpacingSizeIfNeedesPlaceholder {
    return CGSizeMake([self accessorySpacingSize].width * (self.needsAccessoryPlaceholderSpace ? 2 : 1), [self accessorySpacingSize].height);
}

- (UIEdgeInsets)titleEdgeInsetsIfShowingTitleLabel {
    return CGSizeIsEmpty(self.titleLabelSize) ? UIEdgeInsetsZero : self.titleEdgeInsets;
}

- (UIEdgeInsets)subtitleEdgeInsetsIfShowingSubtitleLabel {
    return CGSizeIsEmpty(self.subtitleLabelSize) ? UIEdgeInsetsZero : self.subtitleEdgeInsets;
}

- (CGSize)contentSize {
    
    if (self.style == QMUINavigationTitleViewStyleSubTitleVertical) {
        CGSize size = CGSizeZero;
        // 垂直排列的情况下，loading和accessory与titleLabel同一行
        CGFloat firstLineWidth = self.titleLabelSize.width + UIEdgeInsetsGetHorizontalValue(self.titleEdgeInsetsIfShowingTitleLabel);
        firstLineWidth += [self loadingViewSpacingSizeIfNeedsPlaceholder].width;
        firstLineWidth += [self accessorySpacingSizeIfNeedesPlaceholder].width;
        
        CGFloat secondLineWidth = self.subtitleLabelSize.width + UIEdgeInsetsGetHorizontalValue(self.subtitleEdgeInsetsIfShowingSubtitleLabel);
        
        size.width = fmaxf(firstLineWidth, secondLineWidth);
        
        size.height = self.titleLabelSize.height + UIEdgeInsetsGetVerticalValue(self.titleEdgeInsetsIfShowingTitleLabel) + self.subtitleLabelSize.height + UIEdgeInsetsGetVerticalValue(self.subtitleEdgeInsetsIfShowingSubtitleLabel);
        return CGSizeFlatted(size);
    } else {
        CGSize size = CGSizeZero;
        size.width = self.titleLabelSize.width + UIEdgeInsetsGetHorizontalValue(self.titleEdgeInsetsIfShowingTitleLabel) + self.subtitleLabelSize.width + UIEdgeInsetsGetHorizontalValue(self.subtitleEdgeInsetsIfShowingSubtitleLabel);
        size.width += [self loadingViewSpacingSizeIfNeedsPlaceholder].width + [self accessorySpacingSizeIfNeedesPlaceholder].width;
        size.height = fmaxf(self.titleLabelSize.height + UIEdgeInsetsGetVerticalValue(self.titleEdgeInsetsIfShowingTitleLabel), self.subtitleLabelSize.height + UIEdgeInsetsGetVerticalValue(self.subtitleEdgeInsetsIfShowingSubtitleLabel));
        size.height = fmaxf(size.height, [self loadingViewSpacingSizeIfNeedsPlaceholder].height);
        size.height = fmaxf(size.height, [self accessorySpacingSizeIfNeedesPlaceholder].height);
        return CGSizeFlatted(size);
    }
}

- (CGSize)sizeThatFits:(CGSize)size {
    CGSize resultSize = [self contentSize];
    return resultSize;
}

- (void)layoutSubviews {
    
    if (CGSizeIsEmpty(self.bounds.size)) {
        NSLog(@"%@, layoutSubviews, size = %@", NSStringFromClass([self class]), NSStringFromCGSize(self.bounds.size));
        return;
    }
    
    if (self.accessoryViewAnimating) {
        return;
    }
    
    [super layoutSubviews];
    
    BOOL alignLeft = self.contentHorizontalAlignment == UIControlContentHorizontalAlignmentLeft;
    BOOL alignRight = self.contentHorizontalAlignment == UIControlContentHorizontalAlignmentRight;
    
    // 通过sizeThatFit计算出来的size，如果大于可使用的最大宽度，则会被系统改为最大限制的最大宽度
    CGSize maxSize = self.bounds.size;
    
    // 实际内容的size，小于等于maxSize
    CGSize contentSize = [self contentSize];
    contentSize.width = fminf(maxSize.width, contentSize.width);
    contentSize.height = fminf(maxSize.height, contentSize.height);
    
    // 计算左右两边的偏移值
    CGFloat offsetLeft = 0;
    CGFloat offsetRight = 0;
    if (alignLeft) {
        offsetLeft = 0;
        offsetRight = maxSize.width - contentSize.width;
    } else if (alignRight) {
        offsetLeft = maxSize.width - contentSize.width;
        offsetRight = 0;
    } else {
        offsetLeft = offsetRight = floorInPixel((maxSize.width - contentSize.width) / 2.0);
    }
    
    // 计算loading占的单边宽度
    CGFloat loadingViewSpace = [self loadingViewSpacingSize].width;
    
    // 获取当前accessoryView
    UIView *accessoryView = self.accessoryView ?: self.accessoryTypeView;
    
    // 计算accessoryView占的单边宽度
    CGFloat accessoryViewSpace = [self accessorySpacingSize].width;
    
    BOOL isTitleLabelShowing = self.titleLabel.text.length > 0;
    BOOL isSubtitleLabelShowing = self.subtitleLabel.text.length > 0;
    UIEdgeInsets titleEdgeInsets = self.titleEdgeInsetsIfShowingTitleLabel;
    UIEdgeInsets subtitleEdgeInsets = self.subtitleEdgeInsetsIfShowingSubtitleLabel;
    
    CGFloat minX = offsetLeft + (self.needsAccessoryPlaceholderSpace ? accessoryViewSpace : 0);
    CGFloat maxX = maxSize.width - offsetRight - (self.needsLoadingPlaceholderSpace ? loadingViewSpace : 0);
    
    if (self.style == QMUINavigationTitleViewStyleSubTitleVertical) {
        
        if (self.loadingView) {
            self.loadingView.frame = CGRectSetXY(self.loadingView.frame, minX, CGFloatGetCenter(self.titleLabelSize.height, self.loadingViewSize.height) + titleEdgeInsets.top);
            minX = CGRectGetMaxX(self.loadingView.frame) + self.loadingViewMarginRight;
        }
        if (accessoryView) {
            accessoryView.frame = CGRectSetXY(accessoryView.frame, maxX - CGRectGetWidth(accessoryView.bounds), CGFloatGetCenter(self.titleLabelSize.height, CGRectGetHeight(accessoryView.bounds)) + titleEdgeInsets.top + self.accessoryViewOffset.y);
            maxX = CGRectGetMinX(accessoryView.frame) - self.accessoryViewOffset.x;
        }
        if (isTitleLabelShowing) {
            minX += titleEdgeInsets.left;
            maxX -= titleEdgeInsets.right;
            self.titleLabel.frame = CGRectFlatMake(minX, titleEdgeInsets.top, maxX - minX, self.titleLabelSize.height);
        } else {
            self.titleLabel.frame = CGRectZero;
        }
        if (isSubtitleLabelShowing) {
            self.subtitleLabel.frame = CGRectFlatMake(subtitleEdgeInsets.left, (isTitleLabelShowing ? CGRectGetMaxY(self.titleLabel.frame) + titleEdgeInsets.bottom : 0) + subtitleEdgeInsets.top, maxSize.width - UIEdgeInsetsGetHorizontalValue(subtitleEdgeInsets), self.subtitleLabelSize.height);
        } else {
            self.subtitleLabel.frame = CGRectZero;
        }
        
    } else {
        
        if (self.loadingView) {
            self.loadingView.frame = CGRectSetXY(self.loadingView.frame, minX, CGFloatGetCenter(maxSize.height, self.loadingViewSize.height));
            minX = CGRectGetMaxX(self.loadingView.frame) + self.loadingViewMarginRight;
        }
        if (accessoryView) {
            accessoryView.frame = CGRectSetXY(accessoryView.frame, maxX - CGRectGetWidth(accessoryView.bounds), CGFloatGetCenter(maxSize.height, CGRectGetHeight(accessoryView.bounds)) + self.accessoryViewOffset.y);
            maxX = CGRectGetMinX(accessoryView.frame) - self.accessoryViewOffset.x;
        }
        if (isSubtitleLabelShowing) {
            maxX -= subtitleEdgeInsets.right;
            // 如果当前的 contentSize 就是以这个 label 的最大占位计算出来的，那么就不应该先计算 center 再计算偏移
            CGFloat shouldSubtitleLabelCenterVertically = self.subtitleLabelSize.height + UIEdgeInsetsGetVerticalValue(subtitleEdgeInsets) < contentSize.height;
            CGFloat subtitleMinY = shouldSubtitleLabelCenterVertically ? CGFloatGetCenter(maxSize.height, self.subtitleLabelSize.height) + subtitleEdgeInsets.top - subtitleEdgeInsets.bottom : subtitleEdgeInsets.top;
            self.subtitleLabel.frame = CGRectFlatMake(maxX - self.subtitleLabelSize.width, subtitleMinY, self.subtitleLabelSize.width, self.subtitleLabelSize.height);
            maxX = CGRectGetMinX(self.subtitleLabel.frame) - subtitleEdgeInsets.left;
        } else {
            self.subtitleLabel.frame = CGRectZero;
        }
        if (isTitleLabelShowing) {
            minX += titleEdgeInsets.left;
            maxX -= titleEdgeInsets.right;
            // 如果当前的 contentSize 就是以这个 label 的最大占位计算出来的，那么就不应该先计算 center 再计算偏移
            CGFloat shouldTitleLabelCenterVertically = self.titleLabelSize.height + UIEdgeInsetsGetVerticalValue(titleEdgeInsets) < contentSize.height;
            CGFloat titleLabelMinY = shouldTitleLabelCenterVertically ? CGFloatGetCenter(maxSize.height, self.titleLabelSize.height) + titleEdgeInsets.top - titleEdgeInsets.bottom : titleEdgeInsets.top;
            self.titleLabel.frame = CGRectFlatMake(minX, titleLabelMinY, maxX - minX, self.titleLabelSize.height);
        } else {
            self.titleLabel.frame = CGRectZero;
        }
    }
}


#pragma mark - setter / getter

- (void)setContentHorizontalAlignment:(UIControlContentHorizontalAlignment)contentHorizontalAlignment {
    [super setContentHorizontalAlignment:contentHorizontalAlignment];
    [self refreshLayout];
}

- (void)setNeedsLoadingPlaceholderSpace:(BOOL)needsLoadingPlaceholderSpace {
    _needsLoadingPlaceholderSpace = needsLoadingPlaceholderSpace;
    [self refreshLayout];
}

- (void)setNeedsAccessoryPlaceholderSpace:(BOOL)needsAccessoryPlaceholderSpace {
    _needsAccessoryPlaceholderSpace = needsAccessoryPlaceholderSpace;
    [self refreshLayout];
}

- (void)setAccessoryViewOffset:(CGPoint)accessoryViewOffset {
    _accessoryViewOffset = accessoryViewOffset;
    [self refreshLayout];
}

- (void)setLoadingViewMarginRight:(CGFloat)loadingViewMarginRight {
    _loadingViewMarginRight = loadingViewMarginRight;
    [self refreshLayout];
}

- (void)setHorizontalTitleFont:(UIFont *)horizontalTitleFont {
    _horizontalTitleFont = horizontalTitleFont;
    if (self.style == QMUINavigationTitleViewStyleDefault) {
        self.titleLabel.font = horizontalTitleFont;
        [self updateTitleLabelSize];
        [self refreshLayout];
    }
}

- (void)setHorizontalSubtitleFont:(UIFont *)horizontalSubtitleFont {
    _horizontalSubtitleFont = horizontalSubtitleFont;
    if (self.style == QMUINavigationTitleViewStyleDefault) {
        self.subtitleLabel.font = horizontalSubtitleFont;
        [self updateSubtitleLabelSize];
        [self refreshLayout];
    }
}

- (void)setVerticalTitleFont:(UIFont *)verticalTitleFont {
    _verticalTitleFont = verticalTitleFont;
    if (self.style == QMUINavigationTitleViewStyleSubTitleVertical) {
        self.titleLabel.font = verticalTitleFont;
        [self updateTitleLabelSize];
        [self refreshLayout];
    }
}

- (void)setVerticalSubtitleFont:(UIFont *)verticalSubtitleFont {
    _verticalSubtitleFont = verticalSubtitleFont;
    if (self.style == QMUINavigationTitleViewStyleSubTitleVertical) {
        self.subtitleLabel.font = verticalSubtitleFont;
        [self updateSubtitleLabelSize];
        [self refreshLayout];
    }
}

- (void)setTitleEdgeInsets:(UIEdgeInsets)titleEdgeInsets {
    _titleEdgeInsets = titleEdgeInsets;
    [self refreshLayout];
}

- (void)setSubtitleEdgeInsets:(UIEdgeInsets)subtitleEdgeInsets {
    _subtitleEdgeInsets = subtitleEdgeInsets;
    [self refreshLayout];
}

- (void)setTitle:(NSString *)title {
    _title = title;
    self.titleLabel.text = title;
    [self updateTitleLabelSize];
    [self refreshLayout];
}

- (void)setSubtitle:(NSString *)subtitle {
    _subtitle = subtitle;
    self.subtitleLabel.text = subtitle;
    [self updateSubtitleLabelSize];
    [self refreshLayout];
}

- (void)setAccessoryType:(QMUINavigationTitleViewAccessoryType)accessoryType {
    
    // 如果已设置了accessoryView，则accessoryType不生效
    if (self.accessoryView) {
        accessoryType = QMUINavigationTitleViewAccessoryTypeNone;
    }
    
    _accessoryType = accessoryType;
    
    if (accessoryType == QMUINavigationTitleViewAccessoryTypeNone) {
        [self.accessoryTypeView removeFromSuperview];
        self.accessoryTypeView = nil;
        [self refreshLayout];
        return;
    }
    
    if (!self.accessoryTypeView) {
        self.accessoryTypeView = [[UIImageView alloc] init];
        self.accessoryTypeView.contentMode = UIViewContentModeCenter;
        [self addSubview:self.accessoryTypeView];
    }
    
    UIImage *accessoryImage;
    if (accessoryType == QMUINavigationTitleViewAccessoryTypeDisclosureIndicator) {
        accessoryImage = [NavBarAccessoryViewTypeDisclosureIndicatorImage qmui_imageWithOrientation:UIImageOrientationUp];
    }
    
    self.accessoryTypeView.image = accessoryImage;
    [self.accessoryTypeView sizeToFit];
    [self refreshLayout];
}

- (void)setAccessoryView:(UIView *)accessoryView {
    if (_accessoryView != accessoryView) {
        [_accessoryView removeFromSuperview];
        _accessoryView = nil;
    }
    if (accessoryView) {
        _accessoryView = accessoryView;
        self.accessoryType = QMUINavigationTitleViewAccessoryTypeNone;
        [self.accessoryView sizeToFit];
        [self addSubview:self.accessoryView];
    }
    [self refreshLayout];
}

- (void)setNeedsLoadingView:(BOOL)needsLoadingView {
    _needsLoadingView = needsLoadingView;
    if (needsLoadingView) {
        if (!self.loadingView) {
            _loadingView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:NavBarActivityIndicatorViewStyle size:self.loadingViewSize];
            self.loadingView.color = self.tintColor;
            [self.loadingView stopAnimating];
            [self addSubview:self.loadingView];
        }
    } else {
        if (self.loadingView) {
            [self.loadingView stopAnimating];
            [self.loadingView removeFromSuperview];
            _loadingView = nil;
        }
    }
    [self refreshLayout];
}

- (void)setLoadingViewHidden:(BOOL)loadingViewHidden {
    _loadingViewHidden = loadingViewHidden;
    if (self.needsLoadingView) {
        loadingViewHidden ? [self.loadingView stopAnimating] : [self.loadingView startAnimating];
    }
    [self refreshLayout];
}

- (void)setActive:(BOOL)active {
    _active = active;
    if ([self.delegate respondsToSelector:@selector(didChangedActive:forTitleView:)]) {
        [self.delegate didChangedActive:active forTitleView:self];
    }
    if (self.accessoryType == QMUINavigationTitleViewAccessoryTypeDisclosureIndicator) {
        // 目前只对默认的accessoryView添加动画
        self.accessoryViewAnimating = YES;
        if (active) {
            [UIView animateWithDuration:.25f delay:0 options:QMUIViewAnimationOptionsCurveIn animations:^(void){
                self.accessoryTypeView.transform = CGAffineTransformMakeRotation(AngleWithDegrees(-180));
            } completion:^(BOOL finished) {
                self.accessoryViewAnimating = NO;
            }];
        } else {
            [UIView animateWithDuration:.25f delay:0 options:QMUIViewAnimationOptionsCurveIn animations:^(void){
                self.accessoryTypeView.transform = CGAffineTransformMakeRotation(AngleWithDegrees(0.1));
            } completion:^(BOOL finished) {
                self.accessoryViewAnimating = NO;
            }];
        }
    }
}

#pragma mark - Style & Type

- (void)setStyle:(QMUINavigationTitleViewStyle)style {
    _style = style;
    if (style == QMUINavigationTitleViewStyleSubTitleVertical) {
        self.titleLabel.font = self.verticalTitleFont;
        [self updateTitleLabelSize];
        
        self.subtitleLabel.font = self.verticalSubtitleFont;
        [self updateSubtitleLabelSize];
    } else {
        self.titleLabel.font = self.horizontalTitleFont;
        [self updateTitleLabelSize];
        
        self.subtitleLabel.font = self.horizontalSubtitleFont;
        [self updateSubtitleLabelSize];
    }
    [self refreshLayout];
}

- (void)tintColorDidChange {
    [super tintColorDidChange];
    self.titleLabel.textColor = self.tintColor;
    self.subtitleLabel.textColor = self.tintColor;
    self.loadingView.color = self.tintColor;
}

#pragma mark - Events

- (void)setHighlighted:(BOOL)highlighted {
    [super setHighlighted:highlighted];
    self.alpha = highlighted ? UIControlHighlightedAlpha : 1;
}

- (void)handleTouchTitleViewEvent {
    BOOL active = !self.active;
    if ([self.delegate respondsToSelector:@selector(didTouchTitleView:isActive:)]) {
        [self.delegate didTouchTitleView:self isActive:active];
    }
    self.active = active;
    [self refreshLayout];
}

@end

@interface QMUINavigationTitleView (UIAppearance)

@end

@implementation QMUINavigationTitleView (UIAppearance)

+ (void)initialize {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        [self setDefaultAppearance];
    });
}

+ (void)setDefaultAppearance {
    QMUINavigationTitleView *appearance = [QMUINavigationTitleView appearance];
    appearance.loadingViewSize = CGSizeMake(18, 18);
    appearance.loadingViewMarginRight = 3;
    appearance.horizontalTitleFont = NavBarTitleFont;
    appearance.horizontalSubtitleFont = NavBarTitleFont;
    appearance.verticalTitleFont = UIFontMake(15);
    appearance.verticalSubtitleFont = UIFontLightMake(12);
    appearance.accessoryViewOffset = CGPointMake(3, 0);
    appearance.titleEdgeInsets = UIEdgeInsetsZero;
    appearance.subtitleEdgeInsets = UIEdgeInsetsZero;
}

@end
