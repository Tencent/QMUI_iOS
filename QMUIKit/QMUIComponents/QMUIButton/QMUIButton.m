/**
 * Tencent is pleased to support the open source community by making QMUI_iOS available.
 * Copyright (C) 2016-2021 THL A29 Limited, a Tencent company. All rights reserved.
 * Licensed under the MIT License (the "License"); you may not use this file except in compliance with the License. You may obtain a copy of the License at
 * http://opensource.org/licenses/MIT
 * Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.
 */

//
//  QMUIButton.m
//  qmui
//
//  Created by QMUI Team on 14-7-7.
//

#import "QMUIButton.h"
#import "QMUICore.h"
#import "CALayer+QMUI.h"
#import "UIButton+QMUI.h"
#import "QMUILayouter.h"

const CGFloat QMUIButtonCornerRadiusAdjustsBounds = -1;

@interface QMUIButton ()

@property(nonatomic, strong) CALayer *highlightedBackgroundLayer;
@property(nonatomic, strong) UIColor *originBorderColor;
@end

@implementation QMUIButton

@synthesize subtitleLabel = _qmuisubtitleLabel;

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.tintColor = ButtonTintColor;
        [self setTitleColor:self.tintColor forState:UIControlStateNormal];// 初始化时 adjustsTitleTintColorAutomatically 还是 NO，所以这里手动把 titleColor 设置为 tintColor 的值
        self.subtitleColor = self.tintColor;
        
        // iOS7以后的button，sizeToFit后默认会自带一个上下的contentInsets，为了保证按钮大小即为内容大小，这里直接去掉，改为一个最小的值。
        self.contentEdgeInsets = UIEdgeInsetsMake(CGFLOAT_MIN, 0, CGFLOAT_MIN, 0);
        
        // 放在后面，让前面的默认值可以被子类重写的 didInitialize 覆盖
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
    // 默认接管highlighted和disabled的表现，去掉系统默认的表现
    self.adjustsImageWhenHighlighted = NO;
    self.adjustsImageWhenDisabled = NO;
    self.adjustsButtonWhenHighlighted = YES;
    self.adjustsButtonWhenDisabled = YES;
    
    // 图片默认在按钮左边，与系统UIButton保持一致
    self.imagePosition = QMUIButtonImagePositionLeft;
    
    _qmuisubtitleLabel = [[UILabel alloc] init];
    _qmuisubtitleLabel.textColor = self.subtitleColor;
    _qmuisubtitleLabel.lineBreakMode = NSLineBreakByTruncatingMiddle;
    
    self.subtitleEdgeInsets = UIEdgeInsetsMake(4, 0, 0, 0);
}

- (void)setSubtitle:(NSString *)subtitle {
    _subtitle = subtitle;
    if (subtitle.length) {
        [self addSubview:_qmuisubtitleLabel];
        _qmuisubtitleLabel.text = subtitle;
    } else {
        [_qmuisubtitleLabel removeFromSuperview];
    }
    [self setNeedsLayout];
}

- (void)setSubtitleEdgeInsets:(UIEdgeInsets)subtitleEdgeInsets {
    _subtitleEdgeInsets = subtitleEdgeInsets;
    [self setNeedsLayout];
}

- (void)setSubtitleColor:(UIColor *)subtitleColor {
    _subtitleColor = subtitleColor;
    _qmuisubtitleLabel.textColor = subtitleColor;
}

// 系统访问 self.imageView 会触发 layout，而私有方法 _imageView 则是简单地访问 imageView，所以在 QMUIButton layoutSubviews 里应该用这个方法
// https://github.com/Tencent/QMUI_iOS/issues/1051
- (UIImageView *)_qmui_imageView {
    BeginIgnorePerformSelectorLeaksWarning
    return [self performSelector:NSSelectorFromString(@"_imageView")];
    EndIgnorePerformSelectorLeaksWarning
}

- (QMUILayouterItem *)generateLayouterForLayout:(BOOL)forLayout {
    __weak __typeof(self)weakSelf = self;
    
    QMUILayouterAlignment horizontal = [@[
        @(QMUILayouterAlignmentCenter),
        @(QMUILayouterAlignmentLeading),
        @(QMUILayouterAlignmentTrailing),
        @(QMUILayouterAlignmentFill),
        @(QMUILayouterAlignmentLeading),
        @(QMUILayouterAlignmentTrailing),
    ][self.contentHorizontalAlignment] integerValue];
    QMUILayouterAlignment vertical = [@[
        @(QMUILayouterAlignmentCenter),
        @(QMUILayouterAlignmentLeading),
        @(QMUILayouterAlignmentTrailing),
        @(QMUILayouterAlignmentFill),
    ][self.contentVerticalAlignment] integerValue];
    
    BOOL isImageViewShowing = !!self.currentImage;
    QMUILayouterItem *image = [QMUILayouterItem itemWithView:isImageViewShowing ? (forLayout ? self._qmui_imageView : self.imageView) : nil margin:self.imageEdgeInsets];
    image.visibleBlock = ^BOOL(QMUILayouterItem * _Nonnull aItem) {
        return !!weakSelf.currentImage;
    };
    image.sizeThatFitsBlock = ^CGSize(QMUILayouterItem * _Nonnull aItem, CGSize size, CGSize superResult) {
        // 某些时机下存在 image 但 imageView.image 尚为 nil 导致计算出来的尺寸错误，所以这里做个保护(ed4d87e86af12110b2c14359ef287be959c70af0)
        if (aItem.visible && CGSizeIsEmpty(superResult) && [aItem.view.superview isKindOfClass:QMUIButton.class]) {
            QMUIButton *btn = (QMUIButton *)aItem.view.superview;
            return btn.currentImage.size;
        }
        return superResult;
    };
    QMUILayouterItem *title = [QMUILayouterItem itemWithView:self.titleLabel margin:self.titleEdgeInsets grow:QMUILayouterGrowNever shrink:QMUILayouterShrinkDefault];
    title.visibleBlock = ^BOOL(QMUILayouterItem * _Nonnull aItem) {
        return !!weakSelf.currentTitle || !!weakSelf.currentAttributedTitle;
    };
    QMUILayouterItem *subtitle = [QMUILayouterItem itemWithView:self.subtitleLabel margin:self.subtitleEdgeInsets grow:QMUILayouterGrowNever shrink:QMUILayouterShrinkDefault];
    QMUILayouterLinearVertical *titles = [QMUILayouterLinearVertical itemWithChildItems:@[
        title,
        subtitle,
    ] spacingBetweenItems:0 horizontal:horizontal vertical:vertical];
    titles.shrink = QMUILayouterShrinkDefault;
    
    if (self.imagePosition == QMUIButtonImagePositionTop || self.imagePosition == QMUIButtonImagePositionBottom) {
        if (vertical == QMUILayouterAlignmentFill) {
            if (image.visible && title.visible && !subtitle.visible) {
                titles.grow = QMUILayouterGrowMost;
                title.grow = QMUILayouterGrowMost;
            } else if (image.visible && !title.visible && subtitle.visible) {
                titles.grow = QMUILayouterGrowMost;
                subtitle.grow = QMUILayouterGrowMost;
            } else if (!image.visible && title.visible && subtitle.visible) {
                titles.grow = QMUILayouterGrowMost;
                title.grow = QMUILayouterGrowMost;
            }
        }
    } else if (self.imagePosition == QMUIButtonImagePositionLeft || self.imagePosition == QMUIButtonImagePositionRight) {
        if (horizontal == QMUILayouterAlignmentFill) {
            if (image.visible && (title.visible || subtitle.visible)) {
                titles.grow = QMUILayouterGrowMost;
            }
        }
        if (vertical == QMUILayouterAlignmentFill) {
            if (title.visible) {
                title.grow = QMUILayouterGrowMost;
            } else if (subtitle.visible) {
                subtitle.grow = QMUILayouterGrowMost;
            }
        }
    }
    
    switch (self.imagePosition) {
        case QMUIButtonImagePositionTop: {
            return [QMUILayouterLinearVertical itemWithChildItems:@[
                image,
                titles,
            ] spacingBetweenItems:self.spacingBetweenImageAndTitle horizontal:horizontal vertical:vertical];
        }
        case QMUIButtonImagePositionBottom: {
            return [QMUILayouterLinearVertical itemWithChildItems:@[
                titles,
                image,
            ] spacingBetweenItems:self.spacingBetweenImageAndTitle horizontal:horizontal vertical:vertical];
        }
        case QMUIButtonImagePositionLeft: {
            return [QMUILayouterLinearHorizontal itemWithChildItems:@[
                image,
                titles,
            ] spacingBetweenItems:self.spacingBetweenImageAndTitle horizontal:horizontal vertical:vertical];
        }
        case QMUIButtonImagePositionRight: {
            return [QMUILayouterLinearHorizontal itemWithChildItems:@[
                titles,
                image,
            ] spacingBetweenItems:self.spacingBetweenImageAndTitle horizontal:horizontal vertical:vertical];
        }
    }
}

- (CGSize)sizeThatFits:(CGSize)size {
    // 如果调用 sizeToFit，那么传进来的 size 就是当前按钮的 size，此时的计算不要去限制宽高
    // 系统 UIButton 不管任何时候，对 sizeThatFits:CGSizeZero 都会返回真实的内容大小，这里对齐
    if (CGSizeEqualToSize(self.bounds.size, size) || CGSizeIsEmpty(size)) {
        size = CGSizeMax;
    }
    
    QMUILayouterItem *layouter = [self generateLayouterForLayout:NO];
    CGSize result = [layouter sizeThatFits:size];
    result.width += UIEdgeInsetsGetHorizontalValue(self.contentEdgeInsets);
    result.height += UIEdgeInsetsGetVerticalValue(self.contentEdgeInsets);
    return result;
}

- (CGSize)intrinsicContentSize {
    return [self sizeThatFits:CGSizeMax];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    if (CGRectIsEmpty(self.bounds)) {
        return;
    }
    
    if (self.cornerRadius == QMUIButtonCornerRadiusAdjustsBounds) {
        self.layer.cornerRadius = CGRectGetHeight(self.bounds) / 2;
    }
    
    QMUILayouterItem *layouter = [self generateLayouterForLayout:YES];
    layouter.frame = CGRectInsetEdges(self.bounds, self.contentEdgeInsets);
    [layouter layoutIfNeeded];
    
    // UIButton 有一个特性是不管哪种 alignment，imageView 的宽高必定不超过 button 的宽高（也不管 imageView 的宽高比例是否产生变化），从而保证就算设置了超过 button 大小的 image，也会在 button 容器内部显示。这里对齐系统的特性
    BOOL isImageViewShowing = !!self.currentImage;
    if (isImageViewShowing && !CGRectIsEmpty(self.bounds)) {
        UIImageView *imageView = self._qmui_imageView;
        CGRect rect = imageView.frame;
        CGRect limitRect = CGRectInsetEdges(CGRectInsetEdges(self.bounds, self.contentEdgeInsets), self.imageEdgeInsets);
        if (CGRectGetWidth(rect) > CGRectGetWidth(limitRect)) {
            rect = CGRectSetWidth(rect, CGRectGetWidth(limitRect));
            rect = CGRectSetX(rect, self.contentEdgeInsets.left + self.imageEdgeInsets.left);
        }
        if (CGRectGetHeight(rect) > CGRectGetHeight(limitRect)) {
            rect = CGRectSetHeight(rect, CGRectGetHeight(limitRect));
            rect = CGRectSetY(rect, self.contentEdgeInsets.top + self.imageEdgeInsets.top);
        }
        imageView.frame = rect;
    }
}

- (void)setSpacingBetweenImageAndTitle:(CGFloat)spacingBetweenImageAndTitle {
    _spacingBetweenImageAndTitle = spacingBetweenImageAndTitle;
    
    [self setNeedsLayout];
}

- (void)setImagePosition:(QMUIButtonImagePosition)imagePosition {
    _imagePosition = imagePosition;
    
    [self setNeedsLayout];
}

- (void)setHighlightedBackgroundColor:(UIColor *)highlightedBackgroundColor {
    _highlightedBackgroundColor = highlightedBackgroundColor;
    if (_highlightedBackgroundColor) {
        // 只要开启了highlightedBackgroundColor，就默认不需要alpha的高亮
        self.adjustsButtonWhenHighlighted = NO;
    }
}

- (void)setHighlightedBorderColor:(UIColor *)highlightedBorderColor {
    _highlightedBorderColor = highlightedBorderColor;
    if (_highlightedBorderColor) {
        // 只要开启了highlightedBorderColor，就默认不需要alpha的高亮
        self.adjustsButtonWhenHighlighted = NO;
    }
}

- (void)setHighlighted:(BOOL)highlighted {
    [super setHighlighted:highlighted];
    
    if (highlighted && !self.originBorderColor) {
        // 手指按在按钮上会不断触发setHighlighted:，所以这里做了保护，设置过一次就不用再设置了
        self.originBorderColor = [UIColor colorWithCGColor:self.layer.borderColor];
    }
    
    // 渲染背景色
    if (self.highlightedBackgroundColor || self.highlightedBorderColor) {
        [self adjustsButtonHighlighted];
    }
    // 如果此时是disabled，则disabled的样式优先
    if (!self.enabled) {
        return;
    }
    // 自定义highlighted样式
    if (self.adjustsButtonWhenHighlighted) {
        if (highlighted) {
            self.alpha = ButtonHighlightedAlpha;
        } else {
            self.alpha = 1;
        }
    }
}

- (void)setEnabled:(BOOL)enabled {
    [super setEnabled:enabled];
    if (self.adjustsButtonWhenDisabled) {
        self.alpha = enabled ? 1 : ButtonDisabledAlpha;
    }
}

- (void)adjustsButtonHighlighted {
    if (self.highlightedBackgroundColor) {
        if (!self.highlightedBackgroundLayer) {
            self.highlightedBackgroundLayer = [CALayer layer];
            [self.highlightedBackgroundLayer qmui_removeDefaultAnimations];
            [self.layer insertSublayer:self.highlightedBackgroundLayer atIndex:0];
        }
        self.highlightedBackgroundLayer.frame = self.bounds;
        self.highlightedBackgroundLayer.cornerRadius = self.layer.cornerRadius;
        self.highlightedBackgroundLayer.maskedCorners = self.layer.maskedCorners;
        self.highlightedBackgroundLayer.backgroundColor = self.highlighted ? self.highlightedBackgroundColor.CGColor : UIColorClear.CGColor;
    }
    
    if (self.highlightedBorderColor) {
        self.layer.borderColor = self.highlighted ? self.highlightedBorderColor.CGColor : self.originBorderColor.CGColor;
    }
}

- (void)setAdjustsTitleTintColorAutomatically:(BOOL)adjustsTitleTintColorAutomatically {
    _adjustsTitleTintColorAutomatically = adjustsTitleTintColorAutomatically;
    [self updateTitleColorIfNeeded];
}

- (void)updateTitleColorIfNeeded {
    if (!self.adjustsTitleTintColorAutomatically) return;
    if (self.currentTitleColor) {
        [self setTitleColor:self.tintColor forState:UIControlStateNormal];
    }
    if (self.currentAttributedTitle) {
        NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithAttributedString:self.currentAttributedTitle];
        [attributedString addAttribute:NSForegroundColorAttributeName value:self.tintColor range:NSMakeRange(0, attributedString.length)];
        [self setAttributedTitle:attributedString forState:UIControlStateNormal];
    }
    self.subtitleColor = self.tintColor;
}

- (void)setAdjustsImageTintColorAutomatically:(BOOL)adjustsImageTintColorAutomatically {
    BOOL valueDifference = _adjustsImageTintColorAutomatically != adjustsImageTintColorAutomatically;
    _adjustsImageTintColorAutomatically = adjustsImageTintColorAutomatically;
    
    if (valueDifference) {
        [self updateImageRenderingModeIfNeeded];
    }
}

- (void)updateImageRenderingModeIfNeeded {
    if (self.currentImage) {
        NSArray<NSNumber *> *states = @[@(UIControlStateNormal), @(UIControlStateHighlighted), @(UIControlStateSelected), @(UIControlStateSelected|UIControlStateHighlighted), @(UIControlStateDisabled)];
        
        for (NSNumber *number in states) {
            UIImage *image = [self imageForState:number.unsignedIntegerValue];
            if (!image) {
                continue;
            }
            if (number.unsignedIntegerValue != UIControlStateNormal && image == [self imageForState:UIControlStateNormal]) {
                continue;
            }
            
            if (self.adjustsImageTintColorAutomatically) {
                // 这里的 setImage: 操作不需要使用 renderingMode 对 image 重新处理，而是放到重写的 setImage:forState 里去做就行了
                [self setImage:image forState:[number unsignedIntegerValue]];
            } else {
                // 如果不需要用template的模式渲染，并且之前是使用template的，则把renderingMode改回Original
                [self setImage:[image imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] forState:[number unsignedIntegerValue]];
            }
        }
    }
}

- (void)setImage:(UIImage *)image forState:(UIControlState)state {
    if (self.adjustsImageTintColorAutomatically && image.renderingMode != UIImageRenderingModeAlwaysOriginal) {
        image = [image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    }
    
    [super setImage:image forState:state];
}

- (void)tintColorDidChange {
    [super tintColorDidChange];
    
    [self updateTitleColorIfNeeded];
    
    if (self.adjustsImageTintColorAutomatically) {
        [self updateImageRenderingModeIfNeeded];
    }
}

- (void)setTintColorAdjustsTitleAndImage:(UIColor *)tintColorAdjustsTitleAndImage {
    _tintColorAdjustsTitleAndImage = tintColorAdjustsTitleAndImage;
    if (tintColorAdjustsTitleAndImage) {
        self.tintColor = tintColorAdjustsTitleAndImage;
        self.adjustsTitleTintColorAutomatically = YES;
        self.adjustsImageTintColorAutomatically = YES;
    }
}

- (void)setCornerRadius:(CGFloat)cornerRadius {
    _cornerRadius = cornerRadius;
    if (cornerRadius != QMUIButtonCornerRadiusAdjustsBounds) {
        self.layer.cornerRadius = cornerRadius;
    }
    [self setNeedsLayout];
}

@end
