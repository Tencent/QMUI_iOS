/**
 * Tencent is pleased to support the open source community by making QMUI_iOS available.
 * Copyright (C) 2016-2020 THL A29 Limited, a Tencent company. All rights reserved.
 * Licensed under the MIT License (the "License"); you may not use this file except in compliance with the License. You may obtain a copy of the License at
 * http://opensource.org/licenses/MIT
 * Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.
 */

//
//  QMUINavigationTitleView.m
//  qmui
//
//  Created by QMUI Team on 14-7-2.
//

#import "QMUINavigationTitleView.h"
#import "QMUICore.h"
#import "UIFont+QMUI.h"
#import "UIImage+QMUI.h"
#import "UILabel+QMUI.h"
#import "UIActivityIndicatorView+QMUI.h"
#import "UIViewController+QMUI.h"
#import "UIView+QMUI.h"
#import "QMUIAppearance.h"

@interface UINavigationBar (TitleView)

@end

@implementation UINavigationBar (TitleView)

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        OverrideImplementation([UINavigationBar class], @selector(layoutSubviews), ^id(__unsafe_unretained Class originClass, SEL originCMD, IMP (^originalIMPProvider)(void)) {
            return ^(UINavigationBar *selfObject) {
                
                QMUINavigationTitleView *titleView = (QMUINavigationTitleView *)selfObject.topItem.titleView;
                
                if ([titleView isKindOfClass:[QMUINavigationTitleView class]]) {
                    CGFloat titleViewMaximumWidth = CGRectGetWidth(titleView.bounds);// 初始状态下titleView会被设置为UINavigationBar允许的最大宽度
                    CGSize titleViewSize = [titleView sizeThatFits:CGSizeMake(titleViewMaximumWidth, CGFLOAT_MAX)];
                    titleViewSize.height = ceil(titleViewSize.height);// titleView的高度如果非pt整数，会导致计算出来的y值时多时少，所以干脆做一下pt取整，这个策略不要改，改了要重新测试push过程中titleView是否会跳动
                    
                    // 当在UINavigationBar里使用自定义的titleView时，就算titleView的sizeThatFits:返回正确的高度，navigationBar也不会帮你设置高度（但会帮你设置宽度），所以我们需要自己更新高度并且修正y值
                    if (CGRectGetHeight(titleView.bounds) != titleViewSize.height) {
                        CGFloat titleViewMinY = flat(CGRectGetMinY(titleView.frame) - ((titleViewSize.height - CGRectGetHeight(titleView.bounds)) / 2.0));// 系统对titleView的y值布局是flat，注意，不能改，改了要测试
                        titleView.frame = CGRectMake(CGRectGetMinX(titleView.frame), titleViewMinY, MIN(titleViewMaximumWidth, titleViewSize.width), titleViewSize.height);
                    }
                    
                    // iOS 11 之后（iOS 11 Beta 5 测试过） titleView 的布局发生了一些变化，如果不主动设置宽度，titleView 里的内容就可能无法完整展示
                    if (@available(iOS 11, *)) {
                        if (CGRectGetWidth(titleView.bounds) != titleViewSize.width) {
                            titleView.frame = CGRectSetWidth(titleView.frame, titleViewSize.width);
                        }
                    }
                } else {
                    titleView = nil;
                }
                
                // call super
                void (*originSelectorIMP)(id, SEL);
                originSelectorIMP = (void (*)(id, SEL))originalIMPProvider();
                originSelectorIMP(selfObject, originCMD);
            };
        });
    });
}

@end

@interface QMUINavigationTitleView ()

@property(nonatomic, strong, readonly) UIView *contentView;
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
        
        _contentView = [[UIView alloc] init];
        _contentView.userInteractionEnabled = NO;
        [self addSubview:self.contentView];
        
        _titleLabel = [[UILabel alloc] init];
        self.titleLabel.textAlignment = NSTextAlignmentCenter;
        self.titleLabel.lineBreakMode = NSLineBreakByTruncatingTail;
        [self.contentView addSubview:self.titleLabel];
        
        _subtitleLabel = [[UILabel alloc] init];
        self.subtitleLabel.textAlignment = NSTextAlignmentCenter;
        self.subtitleLabel.lineBreakMode = NSLineBreakByTruncatingTail;
        [self.contentView addSubview:self.subtitleLabel];
        
        self.userInteractionEnabled = NO;
        self.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
        self.style = style;
        self.needsLoadingView = NO;
        self.loadingViewHidden = YES;
        self.needsAccessoryPlaceholderSpace = NO;
        self.needsSubAccessoryPlaceholderSpace = NO;
        self.needsLoadingPlaceholderSpace = YES;
        self.accessoryType = QMUINavigationTitleViewAccessoryTypeNone;
        
        [self qmui_applyAppearance];
        self.horizontalTitleFont = QMUINavigationTitleView.appearance.horizontalTitleFont ?: [UINavigationBar appearance].titleTextAttributes[NSFontAttributeName];
        self.horizontalSubtitleFont = QMUINavigationTitleView.appearance.horizontalSubtitleFont ?: self.horizontalTitleFont;
        
        self.adjustsSubviewsTintColorAutomatically = YES;
        self.tintColor = QMUICMIActivated ? NavBarTitleColor : [UINavigationBar appearance].titleTextAttributes[NSForegroundColorAttributeName];
    }
    return self;
}

- (NSString *)description {
    return [NSString stringWithFormat:@"%@, title = %@, subtitle = %@", [super description], self.title, self.subtitle];
}

#pragma mark - 布局

- (void)refreshLayout {
    UINavigationBar *navigationBar = [self navigationBarSuperviewForSubview:self];
    if (navigationBar) {
        [navigationBar setNeedsLayout];
    }
    [self setNeedsLayout];
}

// 找到 titleView 所在的 navigationBar（iOS 11 及以后，titleView.superview.superview == navigationBar，iOS 10 及以前，titleView.superview == navigationBar）
- (UINavigationBar *)navigationBarSuperviewForSubview:(UIView *)subview {
    if (!subview.superview) {
        return nil;
    }
    
    if ([subview.superview isKindOfClass:[UINavigationBar class]]) {
        return (UINavigationBar *)subview.superview;
    }
    
    return [self navigationBarSuperviewForSubview:subview.superview];
}

- (void)updateTitleLabelSize {
    if (self.titleLabel.text.length > 0) {
        // 这里用 CGSizeCeil 是特地保证 titleView 的 sizeThatFits 计算出来宽度是 pt 取整，这样在 layoutSubviews 我们以 px 取整时，才能保证不会出现水平居中时出现半像素的问题，然后由于我们对半像素会认为一像素，所以导致总体宽度多了一像素，从而导致文字布局可能出现缩略...
        self.titleLabelSize = CGSizeCeil([self.titleLabel sizeThatFits:CGSizeMax]);
    } else {
        self.titleLabelSize = CGSizeZero;
    }
}

- (void)updateSubtitleLabelSize {
    if (self.subtitleLabel.text.length > 0) {
        // 这里用 CGSizeCeil 是特地保证 titleView 的 sizeThatFits 计算出来宽度是 pt 取整，这样在 layoutSubviews 我们以 px 取整时，才能保证不会出现水平居中时出现半像素的问题，然后由于我们对半像素会认为一像素，所以导致总体宽度多了一像素，从而导致文字布局可能出现缩略...
        self.subtitleLabelSize = CGSizeCeil([self.subtitleLabel sizeThatFits:CGSizeMax]);
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

- (CGSize)subAccessorySpacingSize {
    if (self.subAccessoryView) {
        UIView *view = self.subAccessoryView;
        return CGSizeMake(CGRectGetWidth(view.bounds) + self.subAccessoryViewOffset.x, CGRectGetHeight(view.bounds));
    }
    return CGSizeZero;
}

- (CGSize)accessorySpacingSizeIfNeedesPlaceholder {
    return CGSizeMake([self accessorySpacingSize].width * (self.needsAccessoryPlaceholderSpace ? 2 : 1), [self accessorySpacingSize].height);
}

- (CGSize)subAccessorySpacingSizeIfNeedesPlaceholder {
    return CGSizeMake([self subAccessorySpacingSize].width * (self.needsSubAccessoryPlaceholderSpace ? 2 : 1), [self subAccessorySpacingSize].height);
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
        if (self.subtitleLabelSize.width > 0 && self.subAccessoryView && !self.subAccessoryView.hidden) {
            secondLineWidth += [self subAccessorySpacingSizeIfNeedesPlaceholder].width;
        }
        
        size.width = MAX(firstLineWidth, secondLineWidth);
        
        size.height = self.titleLabelSize.height + UIEdgeInsetsGetVerticalValue(self.titleEdgeInsetsIfShowingTitleLabel) + self.subtitleLabelSize.height + UIEdgeInsetsGetVerticalValue(self.subtitleEdgeInsetsIfShowingSubtitleLabel);
        return CGSizeFlatted(size);
    } else {
        CGSize size = CGSizeZero;
        size.width = self.titleLabelSize.width + UIEdgeInsetsGetHorizontalValue(self.titleEdgeInsetsIfShowingTitleLabel) + self.subtitleLabelSize.width + UIEdgeInsetsGetHorizontalValue(self.subtitleEdgeInsetsIfShowingSubtitleLabel);
        size.width += [self loadingViewSpacingSizeIfNeedsPlaceholder].width + [self accessorySpacingSizeIfNeedesPlaceholder].width;
        size.height = MAX(self.titleLabelSize.height + UIEdgeInsetsGetVerticalValue(self.titleEdgeInsetsIfShowingTitleLabel), self.subtitleLabelSize.height + UIEdgeInsetsGetVerticalValue(self.subtitleEdgeInsetsIfShowingSubtitleLabel));
        size.height = MAX(size.height, [self loadingViewSpacingSizeIfNeedsPlaceholder].height);
        size.height = MAX(size.height, [self accessorySpacingSizeIfNeedesPlaceholder].height);
        return CGSizeFlatted(size);
    }
}

- (CGSize)sizeThatFits:(CGSize)size {
    CGSize resultSize = [self contentSize];
    resultSize.width = MIN(resultSize.width, self.maximumWidth);
    return resultSize;
}

- (void)layoutSubviews {
    if (CGSizeIsEmpty(self.bounds.size)) {
        return;
    }
    
    [super layoutSubviews];
    
    self.contentView.frame = self.bounds;
    
    BOOL alignLeft = self.contentHorizontalAlignment == UIControlContentHorizontalAlignmentLeft;
    BOOL alignRight = self.contentHorizontalAlignment == UIControlContentHorizontalAlignmentRight;
    
    // 通过sizeThatFit计算出来的size，如果大于可使用的最大宽度，则会被系统改为最大限制的最大宽度
    CGSize maxSize = self.bounds.size;
    
    // 实际内容的size，小于等于maxSize
    CGSize contentSize = [self contentSize];
    contentSize.width = MIN(maxSize.width, contentSize.width);
    contentSize.height = MIN(maxSize.height, contentSize.height);
    
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
    
    // 获取当前 accessoryView
    UIView *accessoryView = self.accessoryView ?: self.accessoryTypeView;
    
    // 计算 accessoryView 占的单边宽度
    CGFloat accessoryViewSpace = [self accessorySpacingSize].width;
    
    BOOL isTitleLabelShowing = self.titleLabel.text.length > 0;
    BOOL isSubtitleLabelShowing = self.subtitleLabel.text.length > 0;
    BOOL isSubAccessoryViewShowing = isSubtitleLabelShowing && self.subAccessoryView && !self.subAccessoryView.hidden;
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
            [self.subtitleLabel sizeToFit];
            CGFloat subtitleMinX = subtitleEdgeInsets.left;
            CGFloat subtitleWidth = maxSize.width - UIEdgeInsetsGetHorizontalValue(subtitleEdgeInsets);
            
            if (isSubAccessoryViewShowing) {
                if (self.needsSubAccessoryPlaceholderSpace) {
                    // 副标题居中，accessoryView 在右边
                    CGFloat subtitleMaxWidth = subtitleWidth - [self subAccessorySpacingSizeIfNeedesPlaceholder].width;
                    subtitleWidth = MIN(CGRectGetWidth(self.subtitleLabel.bounds), subtitleMaxWidth);
                    subtitleMinX = (CGRectGetWidth(self.bounds) - subtitleWidth) / 2.0;
                } else {
                    // 整体居中
                    CGFloat subtitleMaxWidth = subtitleWidth - [self subAccessorySpacingSize].width;
                    subtitleWidth = MIN(CGRectGetWidth(self.subtitleLabel.bounds), subtitleMaxWidth);
                    subtitleMinX = (CGRectGetWidth(self.bounds) - subtitleWidth - [self subAccessorySpacingSize].width) / 2.0;
                }
            }
            
            self.subtitleLabel.frame = CGRectFlatMake(subtitleMinX, (isTitleLabelShowing ? CGRectGetMaxY(self.titleLabel.frame) + titleEdgeInsets.bottom : 0) + subtitleEdgeInsets.top, subtitleWidth, self.subtitleLabelSize.height);
            
            if (isSubAccessoryViewShowing) {
                self.subAccessoryView.frame = CGRectSetXY(self.subAccessoryView.frame, CGRectGetMaxX(self.subtitleLabel.frame) + self.subAccessoryViewOffset.x, CGRectGetMinYVerticallyCenter(self.subtitleLabel.frame, self.subAccessoryView.frame) + self.subAccessoryViewOffset.y);
            }
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
            BOOL shouldSubtitleLabelCenterVertically = self.subtitleLabelSize.height + UIEdgeInsetsGetVerticalValue(subtitleEdgeInsets) < contentSize.height;
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
            BOOL shouldTitleLabelCenterVertically = self.titleLabelSize.height + UIEdgeInsetsGetVerticalValue(titleEdgeInsets) < contentSize.height;
            CGFloat titleLabelMinY = shouldTitleLabelCenterVertically ? CGFloatGetCenter(maxSize.height, self.titleLabelSize.height) + titleEdgeInsets.top - titleEdgeInsets.bottom : titleEdgeInsets.top;
            self.titleLabel.frame = CGRectFlatMake(minX, titleLabelMinY, maxX - minX, self.titleLabelSize.height);
        } else {
            self.titleLabel.frame = CGRectZero;
        }
    }
    
    // 上面的布局都是按 UIControlContentVerticalAlignmentTop 来计算的，所以这里根据实际的 contentVerticalAlignment 进行偏移
    // 不支持 UIControlContentVerticalAlignmentFill
    CGFloat offsetY = CGFloatGetCenter(maxSize.height, contentSize.height);
    if (self.contentVerticalAlignment == UIControlContentVerticalAlignmentTop) {
        offsetY = 0;
    } else if (self.contentVerticalAlignment == UIControlContentVerticalAlignmentBottom) {
        offsetY = maxSize.height - contentSize.height;
    }
    [self.subviews enumerateObjectsUsingBlock:^(UIView *obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (!CGRectIsEmpty(obj.frame)) {
            obj.frame = CGRectSetY(obj.frame, CGRectGetMinY(obj.frame) + offsetY);
        }
    }];
}


#pragma mark - setter / getter

- (void)setMaximumWidth:(CGFloat)maximumWidth {
    _maximumWidth = maximumWidth;
    [self refreshLayout];
}

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

- (void)setNeedsSubAccessoryPlaceholderSpace:(BOOL)needsSubAccessoryPlaceholderSpace {
    _needsSubAccessoryPlaceholderSpace = needsSubAccessoryPlaceholderSpace;
    [self refreshLayout];
}

- (void)setSubAccessoryViewOffset:(CGPoint)subAccessoryViewOffset {
    _subAccessoryViewOffset = subAccessoryViewOffset;
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
    [self updateSubAccessoryViewHidden];
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
    }
    
    UIImage *accessoryImage = nil;
    if (accessoryType == QMUINavigationTitleViewAccessoryTypeDisclosureIndicator) {
        accessoryImage = [NavBarAccessoryViewTypeDisclosureIndicatorImage qmui_imageWithOrientation:UIImageOrientationUp];
    }
    
    self.accessoryTypeView.image = accessoryImage;
    [self.accessoryTypeView sizeToFit];
    
    // 经过上面的 setImage 和 sizeToFit 之后再 addSubview，因为 addSubview 会触发系统来询问你的 sizeThatFits:
    if (self.accessoryTypeView.superview != self) {
        [self.contentView addSubview:self.accessoryTypeView];
    }
    
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
        [self.contentView addSubview:self.accessoryView];
    }
    [self refreshLayout];
}

- (void)setSubAccessoryView:(UIView *)subAccessoryView {
    if (_subAccessoryView != subAccessoryView) {
        [_subAccessoryView removeFromSuperview];
        _subAccessoryView = nil;
    }
    if (subAccessoryView) {
        _subAccessoryView = subAccessoryView;
        [self.subAccessoryView sizeToFit];
        [self.contentView addSubview:self.subAccessoryView];
    }
    
    [self updateSubAccessoryViewHidden];
    [self refreshLayout];
}

- (void)updateSubAccessoryViewHidden {
    if (self.subAccessoryView && self.subtitle.length && self.style == QMUINavigationTitleViewStyleSubTitleVertical) {
        self.subAccessoryView.hidden = NO;
    } else {
        self.subAccessoryView.hidden = YES;
    }
}

- (void)setNeedsLoadingView:(BOOL)needsLoadingView {
    _needsLoadingView = needsLoadingView;
    if (needsLoadingView) {
        if (!self.loadingView) {
            _loadingView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:NavBarActivityIndicatorViewStyle size:self.loadingViewSize];
            self.loadingView.color = self.tintColor;
            [self.loadingView stopAnimating];
            [self.contentView addSubview:self.loadingView];
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
        if (active) {
            [UIView animateWithDuration:.25f delay:0 options:QMUIViewAnimationOptionsCurveIn animations:^(void){
                self.accessoryTypeView.transform = CGAffineTransformMakeRotation(AngleWithDegrees(-180));
            } completion:^(BOOL finished) {
            }];
        } else {
            [UIView animateWithDuration:.25f delay:0 options:QMUIViewAnimationOptionsCurveIn animations:^(void){
                self.accessoryTypeView.transform = CGAffineTransformMakeRotation(AngleWithDegrees(0.1));
            } completion:^(BOOL finished) {
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
    
    [self updateSubAccessoryViewHidden];
    [self refreshLayout];
}

- (void)tintColorDidChange {
    [super tintColorDidChange];
    
    if (self.adjustsSubviewsTintColorAutomatically) {
        UIColor *color = self.tintColor;
        self.titleLabel.textColor = color;
        self.subtitleLabel.textColor = color;
        self.loadingView.color = color;
    }
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
    appearance.adjustsSubviewsTintColorAutomatically = YES;
    appearance.maximumWidth = CGFLOAT_MAX;
    appearance.loadingViewSize = CGSizeMake(18, 18);
    appearance.loadingViewMarginRight = 3;
    appearance.horizontalTitleFont = NavBarTitleFont;
    appearance.horizontalSubtitleFont = NavBarTitleFont;
    appearance.verticalTitleFont = UIFontMake(15);
    appearance.verticalSubtitleFont = UIFontLightMake(12);
    appearance.accessoryViewOffset = CGPointMake(3, 0);
    appearance.subAccessoryViewOffset = CGPointMake(3, 0);
    appearance.titleEdgeInsets = UIEdgeInsetsZero;
    appearance.subtitleEdgeInsets = UIEdgeInsetsZero;
}

@end

#pragma mark - LargeTitle 兼容

@implementation QMUINavigationTitleView (LargeTitleCompatibility)

- (void)setAlpha:(BOOL)alpha animated:(BOOL)animated {
    // 在 push 和 pop 过渡期间系统会对自定义的 titleView 的 alpha 进行调整，了避免和系统的设置冲突（比如设置 alpha 为 0 又被系统还原为 1）这里通过设置 contentView 的 alpha 来控制整个 QMUINavigationTitleView 显示与隐藏。
    [UIView qmui_animateWithAnimated:animated duration:0.25f animations:^{
        self.contentView.alpha = alpha;
    }];
}

@end

@implementation UINavigationBar (LargeTitleCompatibility)

- (UIView *)qmui_largeTitleView {
    for (UIView *subview in self.subviews) {
        if ([NSStringFromClass(subview.class) hasSuffix:@"LargeTitleView"]) {
            return subview;
        }
    }
    return nil;
}

@end


@implementation UINavigationController(LargeTitleCompatibility)

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (@available(iOS 11.0, *)) {
            OverrideImplementation([UINavigationController class], sel_registerName("_updateTopViewFramesToMatchScrollOffsetInViewController:contentScrollView:topLayoutType:"), ^id(__unsafe_unretained Class originClass, SEL originCMD, IMP (^originalIMPProvider)(void)) {
                return ^(UINavigationController *selfObject, UIViewController *viewController, UIScrollView *scrollView, NSUInteger topLayoutType) {
                    
                    // call super
                    void (*originSelectorIMP)(id, SEL, UIViewController *, UIScrollView *, NSUInteger);
                    originSelectorIMP = (void (*)(id, SEL,  UIViewController *, UIScrollView *, NSUInteger))originalIMPProvider();
                    originSelectorIMP(selfObject, originCMD, viewController, scrollView, topLayoutType);
                    
                    [selfObject qmui_updateTitleViewToMatchScrollOffsetInViewController:viewController contentScrollView:scrollView topLayoutType:topLayoutType];
                };
            });
        }
    });
}

- (void)qmui_updateTitleViewToMatchScrollOffsetInViewController:(UIViewController *)viewController contentScrollView:(UIScrollView *)contentScrollView topLayoutType:(NSInteger)topLayoutType {
    if (@available(iOS 11.0, *)) {
        UIView *titleView = viewController.navigationItem.titleView;
        if (!titleView || ![titleView isKindOfClass:[QMUINavigationTitleView class]]) {
            return;
        }
        
        NSAssert(viewController.navigationController == self, @"navigationController is nil");
        
        QMUINavigationTitleView *navigationTitleView = (QMUINavigationTitleView *)titleView;
        UIView *largeTitleView = self.navigationBar.qmui_largeTitleView;
        BOOL largeTitleLabelVisable = self.navigationBar.prefersLargeTitles && viewController.qmui_prefersLargeTitleDisplayed && largeTitleView.alpha != 0;
        BOOL titleViewAlpha = largeTitleLabelVisable ? 0 : 1;
        BOOL animated = contentScrollView.layer.presentationLayer && !CGRectEqualToRect(contentScrollView.layer.presentationLayer.bounds, contentScrollView.layer.bounds);
        [navigationTitleView setAlpha:titleViewAlpha animated:animated];
    }
}


@end
