/**
 * Tencent is pleased to support the open source community by making QMUI_iOS available.
 * Copyright (C) 2016-2021 THL A29 Limited, a Tencent company. All rights reserved.
 * Licensed under the MIT License (the "License"); you may not use this file except in compliance with the License. You may obtain a copy of the License at
 * http://opensource.org/licenses/MIT
 * Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.
 */

//
//  QMUIEmptyView.m
//  qmui
//
//  Created by QMUI Team on 2016/10/9.
//

#import "QMUIEmptyView.h"
#import "QMUICore.h"
#import "UIControl+QMUI.h"
#import "NSParagraphStyle+QMUI.h"
#import "UIView+QMUI.h"
#import "QMUIButton.h"
#import "QMUIAppearance.h"

@interface QMUIEmptyView ()

@property(nonatomic, strong) UIScrollView *scrollView;  // 保证内容超出屏幕时也不至于直接被clip（比如横屏时）

@end

@implementation QMUIEmptyView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self didInitialize];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
        [self didInitialize];
    }
    return self;
}

- (void)didInitialize {
    // 系统默认会在view即将被add到window上时才设置这些值，这个时机有点晚了，因为我们可能在add到window之前就进行sizeThatFits计算或对view进行截图等操作，因此这里提前到init时就去做
    [self qmui_applyAppearance];
    
    self.scrollView = [[UIScrollView alloc] init];
    self.scrollView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    self.scrollView.showsVerticalScrollIndicator = NO;
    self.scrollView.showsHorizontalScrollIndicator = NO;
    self.scrollView.scrollsToTop = NO;
    self.scrollView.contentInset = UIEdgeInsetsMake(0, 16, 0, 16);
    [self addSubview:self.scrollView];
    
    _contentView = [[UIView alloc] init];
    [self.scrollView addSubview:self.contentView];
    
    _loadingView = (UIView<QMUIEmptyViewLoadingViewProtocol> *)[[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    ((UIActivityIndicatorView *)self.loadingView).hidesWhenStopped = NO;    // 此控件是通过loadingView.hidden属性来控制显隐的，如果UIActivityIndicatorView的hidesWhenStopped属性设置为YES的话，则手动设置它的hidden属性就会失效，因此这里要置为NO
    [self.contentView addSubview:self.loadingView];
    
    _imageView = [[UIImageView alloc] init];
    self.imageView.contentMode = UIViewContentModeCenter;
    [self.contentView addSubview:self.imageView];
    
    _textLabel = [[UILabel alloc] init];
    self.textLabel.textAlignment = NSTextAlignmentCenter;
    self.textLabel.numberOfLines = 0;
    [self.contentView addSubview:self.textLabel];
    
    _detailTextLabel = [[UILabel alloc] init];
    self.detailTextLabel.textAlignment = NSTextAlignmentCenter;
    self.detailTextLabel.numberOfLines = 0;
    [self.contentView addSubview:self.detailTextLabel];
    
    _actionButton = [[QMUIButton alloc] init];
    self.actionButton.qmui_outsideEdge = UIEdgeInsetsMake(-20, -20, -20, -20);
    self.actionButton.qmui_automaticallyAdjustTouchHighlightedInScrollView = YES;
    [self.contentView addSubview:self.actionButton];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    self.scrollView.frame = self.bounds;
    
    CGSize contentViewSize = CGSizeFlatted([self sizeThatContentViewFits]);
    // contentView 默认垂直居中于 scrollView
    self.contentView.frame = CGRectFlatMake(0, CGRectGetMidY(self.scrollView.bounds) - contentViewSize.height / 2 + self.verticalOffset, contentViewSize.width, contentViewSize.height);
    
    // 如果 contentView 要比 scrollView 高，则置顶展示
    if (CGRectGetHeight(self.contentView.bounds) > CGRectGetHeight(self.scrollView.bounds)) {
        self.contentView.frame = CGRectSetY(self.contentView.frame, 0);
    }
    
    self.scrollView.contentSize = CGSizeMake(MAX(CGRectGetWidth(self.scrollView.bounds) - UIEdgeInsetsGetHorizontalValue(self.scrollView.contentInset), contentViewSize.width), MAX(CGRectGetHeight(self.scrollView.bounds) - UIEdgeInsetsGetVerticalValue(self.scrollView.contentInset), CGRectGetMaxY(self.contentView.frame)));
    
    CGFloat originY = 0;
    
    if (!self.imageView.hidden) {
        [self.imageView sizeToFit];
        self.imageView.frame = CGRectSetXY(self.imageView.frame, CGRectGetMinXHorizontallyCenterInParentRect(self.contentView.bounds, self.imageView.frame) + self.imageViewInsets.left - self.imageViewInsets.right, originY + self.imageViewInsets.top);
        originY = CGRectGetMaxY(self.imageView.frame) + self.imageViewInsets.bottom;
    }
    
    if (!self.loadingView.hidden) {
        self.loadingView.frame = CGRectSetXY(self.loadingView.frame, CGRectGetMinXHorizontallyCenterInParentRect(self.contentView.bounds, self.loadingView.frame) + self.loadingViewInsets.left - self.loadingViewInsets.right, originY + self.loadingViewInsets.top);
        originY = CGRectGetMaxY(self.loadingView.frame) + self.loadingViewInsets.bottom;
    }
    
    if (!self.textLabel.hidden) {
        self.textLabel.frame = CGRectFlatMake(self.textLabelInsets.left, originY + self.textLabelInsets.top, CGRectGetWidth(self.contentView.bounds) - UIEdgeInsetsGetHorizontalValue(self.textLabelInsets), QMUIViewSelfSizingHeight);
        originY = CGRectGetMaxY(self.textLabel.frame) + self.textLabelInsets.bottom;
    }
    
    if (!self.detailTextLabel.hidden) {
        self.detailTextLabel.frame = CGRectFlatMake(self.detailTextLabelInsets.left, originY + self.detailTextLabelInsets.top, CGRectGetWidth(self.contentView.bounds) - UIEdgeInsetsGetHorizontalValue(self.detailTextLabelInsets), QMUIViewSelfSizingHeight);
        originY = CGRectGetMaxY(self.detailTextLabel.frame) + self.detailTextLabelInsets.bottom;
    }
    
    if (!self.actionButton.hidden) {
        [self.actionButton sizeToFit];
        self.actionButton.frame = CGRectSetXY(self.actionButton.frame, CGRectGetMinXHorizontallyCenterInParentRect(self.contentView.bounds, self.actionButton.frame) + self.actionButtonInsets.left - self.actionButtonInsets.right, originY + self.actionButtonInsets.top);
        originY = CGRectGetMaxY(self.actionButton.frame) + self.actionButtonInsets.bottom;
    }
}

- (CGSize)sizeThatContentViewFits {
    CGFloat resultWidth = CGRectGetWidth(self.scrollView.bounds) - UIEdgeInsetsGetHorizontalValue(self.scrollView.contentInset);
    CGFloat resultHeight = 0;
    if (!self.imageView.hidden) {
        CGFloat imageViewHeight = [self.imageView sizeThatFits:CGSizeMake(resultWidth - UIEdgeInsetsGetHorizontalValue(self.imageViewInsets), CGFLOAT_MAX)].height + UIEdgeInsetsGetVerticalValue(self.imageViewInsets);
        resultHeight += imageViewHeight;
    }
    if (!self.loadingView.hidden) {
        CGFloat loadingViewHeight = CGRectGetHeight(self.loadingView.bounds) + UIEdgeInsetsGetVerticalValue(self.loadingViewInsets);
        resultHeight += loadingViewHeight;
    }
    if (!self.textLabel.hidden) {
        CGFloat textLabelHeight = [self.textLabel sizeThatFits:CGSizeMake(resultWidth - UIEdgeInsetsGetHorizontalValue(self.textLabelInsets), CGFLOAT_MAX)].height + UIEdgeInsetsGetVerticalValue(self.textLabelInsets);
        resultHeight += textLabelHeight;
    }
    if (!self.detailTextLabel.hidden) {
        CGFloat detailTextLabelHeight = [self.detailTextLabel sizeThatFits:CGSizeMake(resultWidth - UIEdgeInsetsGetHorizontalValue(self.detailTextLabelInsets), CGFLOAT_MAX)].height + UIEdgeInsetsGetVerticalValue(self.detailTextLabelInsets);
        resultHeight += detailTextLabelHeight;
    }
    if (!self.actionButton.hidden) {
        CGFloat actionButtonHeight = [self.actionButton sizeThatFits:CGSizeMake(resultWidth - UIEdgeInsetsGetHorizontalValue(self.actionButtonInsets), CGFLOAT_MAX)].height + UIEdgeInsetsGetVerticalValue(self.actionButtonInsets);
        resultHeight += actionButtonHeight;
    }
    
    return CGSizeMake(resultWidth, resultHeight);
}

- (void)updateDetailTextLabelWithText:(NSString *)text {
    if (self.detailTextLabelFont && self.detailTextLabelTextColor && text) {
        NSAttributedString *string = [[NSAttributedString alloc] initWithString:text attributes:@{
                                                                                                  NSFontAttributeName: self.detailTextLabelFont,
                                                                                                  NSForegroundColorAttributeName: self.detailTextLabelTextColor,
                                                                                                  NSParagraphStyleAttributeName: [NSMutableParagraphStyle qmui_paragraphStyleWithLineHeight:self.detailTextLabelFont.pointSize + 10 lineBreakMode:NSLineBreakByWordWrapping textAlignment:NSTextAlignmentCenter]
                                                                                                  }];
        self.detailTextLabel.attributedText = string;
    }
    self.detailTextLabel.hidden = !text;
    [self setNeedsLayout];
}

- (void)setLoadingView:(UIView<QMUIEmptyViewLoadingViewProtocol> *)loadingView {
    if (self.loadingView != loadingView) {
        [self.loadingView removeFromSuperview];
        _loadingView = loadingView;
        [self.contentView addSubview:loadingView];
    }
    [self setNeedsLayout];
}

- (void)setLoadingViewHidden:(BOOL)hidden {
    self.loadingView.hidden = hidden;
    if (!hidden && [self.loadingView respondsToSelector:@selector(startAnimating)]) {
        [self.loadingView startAnimating];
    }
    [self setNeedsLayout];
}

- (void)setImage:(UIImage *)image {
    self.imageView.image = image;
    self.imageView.hidden = !image;
    [self setNeedsLayout];
}

- (void)setTextLabelText:(NSString *)text {
    self.textLabel.text = text;
    self.textLabel.hidden = !text;
    [self setNeedsLayout];
}

- (void)setDetailTextLabelText:(NSString *)text {
    [self updateDetailTextLabelWithText:text];
}

- (void)setActionButtonTitle:(NSString *)title {
    [self.actionButton setTitle:title forState:UIControlStateNormal];
    self.actionButton.hidden = !title;
    [self setNeedsLayout];
}

- (void)setImageViewInsets:(UIEdgeInsets)imageViewInsets {
    _imageViewInsets = imageViewInsets;
    [self setNeedsLayout];
}

- (void)setTextLabelInsets:(UIEdgeInsets)textLabelInsets {
    _textLabelInsets = textLabelInsets;
    [self setNeedsLayout];
}

- (void)setDetailTextLabelInsets:(UIEdgeInsets)detailTextLabelInsets {
    _detailTextLabelInsets = detailTextLabelInsets;
    [self setNeedsLayout];
}

- (void)setActionButtonInsets:(UIEdgeInsets)actionButtonInsets {
    _actionButtonInsets = actionButtonInsets;
    [self setNeedsLayout];
}

- (void)setVerticalOffset:(CGFloat)verticalOffset {
    _verticalOffset = verticalOffset;
    [self setNeedsLayout];
}

- (void)setTextLabelFont:(UIFont *)textLabelFont {
    _textLabelFont = textLabelFont;
    self.textLabel.font = textLabelFont;
    [self setNeedsLayout];
}

- (void)setDetailTextLabelFont:(UIFont *)detailTextLabelFont {
    _detailTextLabelFont = detailTextLabelFont;
    [self updateDetailTextLabelWithText:self.detailTextLabel.text];
}

- (void)setActionButtonFont:(UIFont *)actionButtonFont {
    _actionButtonFont = actionButtonFont;
    self.actionButton.titleLabel.font = actionButtonFont;
    [self setNeedsLayout];
}

- (void)setTextLabelTextColor:(UIColor *)textLabelTextColor {
    _textLabelTextColor = textLabelTextColor;
    self.textLabel.textColor = textLabelTextColor;
}

- (void)setDetailTextLabelTextColor:(UIColor *)detailTextLabelTextColor {
    _detailTextLabelTextColor = detailTextLabelTextColor;
    [self updateDetailTextLabelWithText:self.detailTextLabel.text];
}

- (void)setActionButtonTitleColor:(UIColor *)actionButtonTitleColor {
    _actionButtonTitleColor = actionButtonTitleColor;
    [self.actionButton setTitleColor:actionButtonTitleColor forState:UIControlStateNormal];
    [self.actionButton setTitleColor:[actionButtonTitleColor colorWithAlphaComponent:ButtonHighlightedAlpha] forState:UIControlStateHighlighted];
    [self.actionButton setTitleColor:[actionButtonTitleColor colorWithAlphaComponent:ButtonDisabledAlpha] forState:UIControlStateDisabled];
}

@end

@interface QMUIEmptyView (UIAppearance)

@end

@implementation QMUIEmptyView (UIAppearance)

+ (void)initialize {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        [self setDefaultAppearance];
    });
}

+ (void)setDefaultAppearance {
    QMUIEmptyView *appearance = [QMUIEmptyView appearance];
    appearance.imageViewInsets = UIEdgeInsetsMake(0, 0, 36, 0);
    appearance.loadingViewInsets = UIEdgeInsetsMake(0, 0, 36, 0);
    appearance.textLabelInsets = UIEdgeInsetsMake(0, 0, 10, 0);
    appearance.detailTextLabelInsets = UIEdgeInsetsMake(0, 0, 14, 0);
    appearance.actionButtonInsets = UIEdgeInsetsZero;
    appearance.verticalOffset = -30;
    
    appearance.textLabelFont = UIFontMake(15);
    appearance.detailTextLabelFont = UIFontMake(14);
    appearance.actionButtonFont = UIFontMake(15);
    
    appearance.textLabelTextColor = UIColorMake(93, 100, 110);
    appearance.detailTextLabelTextColor = UIColorMake(133, 140, 150);
    appearance.actionButtonTitleColor = ButtonTintColor;
}

@end
