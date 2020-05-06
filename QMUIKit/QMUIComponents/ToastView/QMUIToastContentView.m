/**
 * Tencent is pleased to support the open source community by making QMUI_iOS available.
 * Copyright (C) 2016-2020 THL A29 Limited, a Tencent company. All rights reserved.
 * Licensed under the MIT License (the "License"); you may not use this file except in compliance with the License. You may obtain a copy of the License at
 * http://opensource.org/licenses/MIT
 * Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.
 */

//
//  QMUIToastContentView.m
//  qmui
//
//  Created by QMUI Team on 2016/12/11.
//

#import "QMUIToastContentView.h"
#import "QMUICore.h"
#import "UIView+QMUI.h"
#import "NSParagraphStyle+QMUI.h"

@implementation QMUIToastContentView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.layer.allowsGroupOpacity = NO;
        [self initSubviews];
    }
    return self;
}

- (void)initSubviews {
    
    _textLabel = [[UILabel alloc] init];
    self.textLabel.numberOfLines = 0;
    self.textLabel.opaque = NO;
    [self addSubview:self.textLabel];
    
    _detailTextLabel = [[UILabel alloc] init];
    self.detailTextLabel.numberOfLines = 0;
    self.detailTextLabel.opaque = NO;
    [self addSubview:self.detailTextLabel];
}

- (void)setCustomView:(UIView *)customView {
    if (self.customView) {
        [self.customView removeFromSuperview];
        _customView = nil;
    }
    _customView = customView;
    [self addSubview:self.customView];
    [self updateCustomViewTintColor];
    [self setNeedsLayout];
}

- (void)setTextLabelText:(NSString *)textLabelText {
    _textLabelText = textLabelText;
    if (textLabelText) {
        self.textLabel.attributedText = [[NSAttributedString alloc] initWithString:textLabelText attributes:self.textLabelAttributes];
        self.textLabel.textAlignment = NSTextAlignmentCenter;
        [self setNeedsLayout];
    }
}

- (void)setDetailTextLabelText:(NSString *)detailTextLabelText {
    _detailTextLabelText = detailTextLabelText;
    if (detailTextLabelText) {
        self.detailTextLabel.attributedText = [[NSAttributedString alloc] initWithString:detailTextLabelText attributes:self.detailTextLabelAttributes];
        self.detailTextLabel.textAlignment = NSTextAlignmentCenter;
    }
}

- (CGSize)sizeThatFits:(CGSize)size {
    return [self sizeThatFits:size shouldConsiderMinimumSize:YES];
}

- (CGSize)sizeThatFits:(CGSize)size shouldConsiderMinimumSize:(BOOL)shouldConsiderMinimumSize {
    BOOL hasCustomView = !!self.customView;
    BOOL hasTextLabel = self.textLabel.text.length > 0;
    BOOL hasDetailTextLabel = self.detailTextLabel.text.length > 0;
    
    CGFloat width = 0;
    CGFloat height = 0;
    
    CGFloat maxContentWidth = size.width - UIEdgeInsetsGetHorizontalValue(self.insets);
    CGFloat maxContentHeight = size.height - UIEdgeInsetsGetVerticalValue(self.insets);
    
    if (hasCustomView) {
        width = MIN(maxContentWidth, MAX(width, CGRectGetWidth(self.customView.frame)));
        height += (CGRectGetHeight(self.customView.frame) + ((hasTextLabel || hasDetailTextLabel) ? self.customViewMarginBottom : 0));
    }
    
    if (hasTextLabel) {
        CGSize textLabelSize = [self.textLabel sizeThatFits:CGSizeMake(maxContentWidth, maxContentHeight)];
        width = MIN(maxContentWidth, MAX(width, textLabelSize.width));
        height += (textLabelSize.height + (hasDetailTextLabel ? self.textLabelMarginBottom : 0));
    }
    
    if (hasDetailTextLabel) {
        CGSize detailTextLabelSize = [self.detailTextLabel sizeThatFits:CGSizeMake(maxContentWidth, maxContentHeight)];
        width = MIN(maxContentWidth, MAX(width, detailTextLabelSize.width));
        height += (detailTextLabelSize.height + self.detailTextLabelMarginBottom);
    }
    
    width += UIEdgeInsetsGetHorizontalValue(self.insets);
    height += UIEdgeInsetsGetVerticalValue(self.insets);
    
    if (shouldConsiderMinimumSize) {
        width = MAX(width, self.minimumSize.width);
        height = MAX(height, self.minimumSize.height);
    }
    
    return CGSizeMake(width, height);
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    BOOL hasCustomView = !!self.customView;
    BOOL hasTextLabel = self.textLabel.text.length > 0;
    BOOL hasDetailTextLabel = self.detailTextLabel.text.length > 0;
    
    CGFloat contentLimitWidth = self.qmui_width - UIEdgeInsetsGetHorizontalValue(self.insets);
    CGSize contentSize = [self sizeThatFits:self.bounds.size shouldConsiderMinimumSize:NO];
    CGFloat minY = self.insets.top + CGFloatGetCenter(self.qmui_height - UIEdgeInsetsGetVerticalValue(self.insets), contentSize.height - UIEdgeInsetsGetVerticalValue(self.insets));
    if (hasCustomView) {
        self.customView.qmui_left = self.insets.left + CGFloatGetCenter(contentLimitWidth, self.customView.qmui_width);
        self.customView.qmui_top = minY;
        minY = self.customView.qmui_bottom + self.customViewMarginBottom;
    }
    if (hasTextLabel) {
        CGSize textLabelSize = [self.textLabel sizeThatFits:CGSizeMake(contentLimitWidth, CGFLOAT_MAX)];
        self.textLabel.qmui_left = self.insets.left;
        self.textLabel.qmui_top = minY;
        self.textLabel.qmui_width = contentLimitWidth;
        self.textLabel.qmui_height = textLabelSize.height;
        minY = self.textLabel.qmui_bottom + self.textLabelMarginBottom;
    }
    if (hasDetailTextLabel) {
        CGSize detailTextLabelSize = [self.detailTextLabel sizeThatFits:CGSizeMake(contentLimitWidth, CGFLOAT_MAX)];
        self.detailTextLabel.qmui_left = self.insets.left;
        self.detailTextLabel.qmui_top = minY;
        self.detailTextLabel.qmui_width = contentLimitWidth;
        self.detailTextLabel.qmui_height = detailTextLabelSize.height;
    }
}

- (void)tintColorDidChange {
    [super tintColorDidChange];
    
    if (self.customView) {
        [self updateCustomViewTintColor];
    }
    
    // 如果通过 attributes 设置了文字颜色，则不再响应 tintColor
    if (!self.textLabelAttributes[NSForegroundColorAttributeName]) {
        self.textLabel.textColor = self.tintColor;
    }
    
    if (!self.detailTextLabelAttributes[NSForegroundColorAttributeName]) {
        self.detailTextLabel.textColor = self.tintColor;
    }
}

- (void)updateCustomViewTintColor {
    if (!self.customView) {
        return;
    }
    self.customView.tintColor = self.tintColor;
    if ([self.customView isKindOfClass:[UIActivityIndicatorView class]]) {
        UIActivityIndicatorView *customView = (UIActivityIndicatorView *)self.customView;
        customView.color = self.tintColor;
    }
}

#pragma mark - UIAppearance

- (void)setInsets:(UIEdgeInsets)insets {
    _insets = insets;
    [self setNeedsLayout];
}

- (void)setMinimumSize:(CGSize)minimumSize {
    _minimumSize = minimumSize;
    [self setNeedsLayout];
}

- (void)setCustomViewMarginBottom:(CGFloat)customViewMarginBottom {
    _customViewMarginBottom = customViewMarginBottom;
    [self setNeedsLayout];
}

- (void)setTextLabelMarginBottom:(CGFloat)textLabelMarginBottom {
    _textLabelMarginBottom = textLabelMarginBottom;
    [self setNeedsLayout];
}

- (void)setDetailTextLabelMarginBottom:(CGFloat)detailTextLabelMarginBottom {
    _detailTextLabelMarginBottom = detailTextLabelMarginBottom;
    [self setNeedsLayout];
}

- (void)setTextLabelAttributes:(NSDictionary *)textLabelAttributes {
    _textLabelAttributes = textLabelAttributes;
    if (self.textLabelText && self.textLabelText.length > 0) {
        // 刷新label的attributes
        self.textLabelText = self.textLabelText;
    }
}

- (void)setDetailTextLabelAttributes:(NSDictionary *)detailTextLabelAttributes {
    _detailTextLabelAttributes = detailTextLabelAttributes;
    if (self.detailTextLabelText && self.detailTextLabelText.length > 0) {
        // 刷新label的attributes
        self.detailTextLabelText = self.detailTextLabelText;
    }
}

@end


@interface QMUIToastContentView (UIAppearance)

@end

@implementation QMUIToastContentView (UIAppearance)

+ (void)initialize {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        [self setDefaultAppearance];
    });
}

+ (void)setDefaultAppearance {
    QMUIToastContentView *appearance = [QMUIToastContentView appearance];
    appearance.insets = UIEdgeInsetsMake(16, 16, 16, 16);
    appearance.minimumSize = CGSizeZero;
    appearance.customViewMarginBottom = 8;
    appearance.textLabelMarginBottom = 4;
    appearance.detailTextLabelMarginBottom = 0;
    appearance.textLabelAttributes = @{NSFontAttributeName: UIFontBoldMake(16), NSParagraphStyleAttributeName: [NSMutableParagraphStyle qmui_paragraphStyleWithLineHeight:22 lineBreakMode:NSLineBreakByWordWrapping textAlignment:NSTextAlignmentCenter]};
    appearance.detailTextLabelAttributes = @{NSFontAttributeName: UIFontBoldMake(12), NSParagraphStyleAttributeName: [NSMutableParagraphStyle qmui_paragraphStyleWithLineHeight:18 lineBreakMode:NSLineBreakByWordWrapping textAlignment:NSTextAlignmentCenter]};
}

@end
