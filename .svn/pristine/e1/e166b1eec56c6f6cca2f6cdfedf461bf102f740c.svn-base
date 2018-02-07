//
//  QMUIButton.m
//  qmui
//
//  Created by MoLice on 14-7-7.
//  Copyright (c) 2014年 QMUI Team. All rights reserved.
//

#import "QMUIButton.h"
#import "QMUICommonDefines.h"
#import "QMUIConfiguration.h"
#import "QMUICommonViewController.h"
#import "QMUINavigationController.h"
#import "UIImage+QMUI.h"
#import "UIViewController+QMUI.h"
#import "CALayer+QMUI.h"

@interface QMUIButton ()

@property(nonatomic, strong) CALayer *highlightedBackgroundLayer;
@property(nonatomic, strong) UIColor *originBorderColor;
- (void)didInitialized;// UISubclassingHooks
@end

@implementation QMUIButton

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
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
    self.adjustsTitleTintColorAutomatically = NO;
    self.adjustsImageTintColorAutomatically = NO;
    self.tintColor = ButtonTintColor;
    if (!self.adjustsTitleTintColorAutomatically) {
        [self setTitleColor:self.tintColor forState:UIControlStateNormal];
    }
    
    // 默认接管highlighted和disabled的表现，去掉系统默认的表现
    self.adjustsImageWhenHighlighted = NO;
    self.adjustsImageWhenDisabled = NO;
    self.adjustsButtonWhenHighlighted = YES;
    self.adjustsButtonWhenDisabled = YES;
    
    // iOS7以后的button，sizeToFit后默认会自带一个上下的contentInsets，为了保证按钮大小即为内容大小，这里直接去掉，改为一个最小的值。
    // 不能设为0，否则无效；也不能设置为小数点，否则无法像素对齐
    self.contentEdgeInsets = UIEdgeInsetsMake(1, 0, 1, 0);
    
    // 图片默认在按钮左边，与系统UIButton保持一致
    self.imagePosition = QMUIButtonImagePositionLeft;
}

- (CGSize)sizeThatFits:(CGSize)size {
    // 如果调用 sizeToFit，那么传进来的 size 就是当前按钮的 size，此时的计算不要去限制宽高
    if (CGSizeEqualToSize(self.bounds.size, size)) {
        size = CGSizeMake(CGFLOAT_MAX, CGFLOAT_MAX);
    }
    
    CGSize resultSize = CGSizeZero;
    CGSize contentLimitSize = CGSizeMake(size.width - UIEdgeInsetsGetHorizontalValue(self.contentEdgeInsets), size.height - UIEdgeInsetsGetVerticalValue(self.contentEdgeInsets));
    switch (self.imagePosition) {
        case QMUIButtonImagePositionTop:
        case QMUIButtonImagePositionBottom: {
            // 图片和文字上下排版时，宽度以文字或图片的最大宽度为最终宽度
            CGFloat imageLimitWidth = contentLimitSize.width - UIEdgeInsetsGetHorizontalValue(self.imageEdgeInsets);
            CGSize imageSize = [self.imageView sizeThatFits:CGSizeMake(imageLimitWidth, CGFLOAT_MAX)];// 假设图片高度必定完整显示
            
            CGSize titleLimitSize = CGSizeMake(contentLimitSize.width - UIEdgeInsetsGetHorizontalValue(self.titleEdgeInsets), contentLimitSize.height - UIEdgeInsetsGetVerticalValue(self.imageEdgeInsets) - imageSize.height - UIEdgeInsetsGetVerticalValue(self.titleEdgeInsets));
            CGSize titleSize = [self.titleLabel sizeThatFits:titleLimitSize];
            titleSize.height = fminf(titleSize.height, titleLimitSize.height);
            
            resultSize.width = UIEdgeInsetsGetHorizontalValue(self.contentEdgeInsets);
            resultSize.width += fmaxf(UIEdgeInsetsGetHorizontalValue(self.imageEdgeInsets) + imageSize.width, UIEdgeInsetsGetHorizontalValue(self.titleEdgeInsets) + titleSize.width);
            resultSize.height = UIEdgeInsetsGetVerticalValue(self.contentEdgeInsets) + UIEdgeInsetsGetVerticalValue(self.imageEdgeInsets) + imageSize.height + UIEdgeInsetsGetVerticalValue(self.titleEdgeInsets) + titleSize.height;
        }
            break;
            
        case QMUIButtonImagePositionLeft:
        case QMUIButtonImagePositionRight: {
            if (self.imagePosition == QMUIButtonImagePositionLeft && self.titleLabel.numberOfLines == 1) {
                
                // QMUIButtonImagePositionLeft使用系统默认布局
                resultSize = [super sizeThatFits:size];
                
            } else {
                // 图片和文字水平排版时，高度以文字或图片的最大高度为最终高度
                // titleLabel为多行时，系统的sizeThatFits计算结果依然为单行的，所以当QMUIButtonImagePositionLeft并且titleLabel多行的情况下，使用自己计算的结果
                
                CGFloat imageLimitHeight = contentLimitSize.height - UIEdgeInsetsGetVerticalValue(self.imageEdgeInsets);
                CGSize imageSize = [self.imageView sizeThatFits:CGSizeMake(CGFLOAT_MAX, imageLimitHeight)];// 假设图片宽度必定完整显示，高度不超过按钮内容
                
                CGSize titleLimitSize = CGSizeMake(contentLimitSize.width - UIEdgeInsetsGetHorizontalValue(self.titleEdgeInsets) - imageSize.width - UIEdgeInsetsGetHorizontalValue(self.imageEdgeInsets), contentLimitSize.height - UIEdgeInsetsGetVerticalValue(self.titleEdgeInsets));
                CGSize titleSize = [self.titleLabel sizeThatFits:titleLimitSize];
                titleSize.height = fminf(titleSize.height, titleLimitSize.height);
                
                resultSize.width = UIEdgeInsetsGetHorizontalValue(self.contentEdgeInsets) + UIEdgeInsetsGetHorizontalValue(self.imageEdgeInsets) + imageSize.width + UIEdgeInsetsGetHorizontalValue(self.titleEdgeInsets) + titleSize.width;
                resultSize.height = UIEdgeInsetsGetVerticalValue(self.contentEdgeInsets);
                resultSize.height += fmaxf(UIEdgeInsetsGetVerticalValue(self.imageEdgeInsets) + imageSize.height, UIEdgeInsetsGetVerticalValue(self.titleEdgeInsets) + titleSize.height);
            }
        }
            break;
    }
    return resultSize;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    if (CGRectIsEmpty(self.bounds)) {
        return;
    }
    
    if (self.imagePosition == QMUIButtonImagePositionLeft) {
        return;
    }
    
    CGSize contentSize = CGSizeMake(CGRectGetWidth(self.bounds) - UIEdgeInsetsGetHorizontalValue(self.contentEdgeInsets), CGRectGetHeight(self.bounds) - UIEdgeInsetsGetVerticalValue(self.contentEdgeInsets));
    
    if (self.imagePosition == QMUIButtonImagePositionTop || self.imagePosition == QMUIButtonImagePositionBottom) {
        
        CGFloat imageLimitWidth = contentSize.width - UIEdgeInsetsGetHorizontalValue(self.imageEdgeInsets);
        CGSize imageSize = [self.imageView sizeThatFits:CGSizeMake(imageLimitWidth, CGFLOAT_MAX)];// 假设图片高度必定完整显示
        CGRect imageFrame = CGRectMakeWithSize(imageSize);
        
        CGSize titleLimitSize = CGSizeMake(contentSize.width - UIEdgeInsetsGetHorizontalValue(self.titleEdgeInsets), contentSize.height - UIEdgeInsetsGetVerticalValue(self.imageEdgeInsets) - imageSize.height - UIEdgeInsetsGetVerticalValue(self.titleEdgeInsets));
        CGSize titleSize = [self.titleLabel sizeThatFits:titleLimitSize];
        titleSize.height = fminf(titleSize.height, titleLimitSize.height);
        CGRect titleFrame = CGRectMakeWithSize(titleSize);
        
        
        switch (self.contentHorizontalAlignment) {
            case UIControlContentHorizontalAlignmentLeft:
                imageFrame = CGRectSetX(imageFrame, self.contentEdgeInsets.left + self.imageEdgeInsets.left);
                titleFrame = CGRectSetX(titleFrame, self.contentEdgeInsets.left + self.titleEdgeInsets.left);
                break;
            case UIControlContentHorizontalAlignmentCenter:
                imageFrame = CGRectSetX(imageFrame, self.contentEdgeInsets.left + self.imageEdgeInsets.left + CGFloatGetCenter(imageLimitWidth, imageSize.width));
                titleFrame = CGRectSetX(titleFrame, self.contentEdgeInsets.left + self.titleEdgeInsets.left + CGFloatGetCenter(titleLimitSize.width, titleSize.width));
                break;
            case UIControlContentHorizontalAlignmentRight:
                imageFrame = CGRectSetX(imageFrame, CGRectGetWidth(self.bounds) - self.contentEdgeInsets.right - self.imageEdgeInsets.right - imageSize.width);
                titleFrame = CGRectSetX(titleFrame, CGRectGetWidth(self.bounds) - self.contentEdgeInsets.right - self.titleEdgeInsets.right - titleSize.width);
                break;
            case UIControlContentHorizontalAlignmentFill:
                imageFrame = CGRectSetX(imageFrame, self.contentEdgeInsets.left + self.imageEdgeInsets.left);
                imageFrame = CGRectSetWidth(imageFrame, imageLimitWidth);
                titleFrame = CGRectSetX(titleFrame, self.contentEdgeInsets.left + self.titleEdgeInsets.left);
                titleFrame = CGRectSetWidth(titleFrame, titleLimitSize.width);
                break;
        }
        
        if (self.imagePosition == QMUIButtonImagePositionTop) {
            switch (self.contentVerticalAlignment) {
                case UIControlContentVerticalAlignmentTop:
                    imageFrame = CGRectSetY(imageFrame, self.contentEdgeInsets.top + self.imageEdgeInsets.top);
                    titleFrame = CGRectSetY(titleFrame, CGRectGetMaxY(imageFrame) + self.imageEdgeInsets.bottom + self.titleEdgeInsets.top);
                    break;
                case UIControlContentVerticalAlignmentCenter: {
                    CGFloat contentHeight = CGRectGetHeight(imageFrame) + UIEdgeInsetsGetVerticalValue(self.imageEdgeInsets) + CGRectGetHeight(titleFrame) + UIEdgeInsetsGetVerticalValue(self.titleEdgeInsets);
                    CGFloat minY = CGFloatGetCenter(contentSize.height, contentHeight) + self.contentEdgeInsets.top;
                    imageFrame = CGRectSetY(imageFrame, minY + self.imageEdgeInsets.top);
                    titleFrame = CGRectSetY(titleFrame, CGRectGetMaxY(imageFrame) + self.imageEdgeInsets.bottom + self.titleEdgeInsets.top);
                }
                    break;
                case UIControlContentVerticalAlignmentBottom:
                    titleFrame = CGRectSetY(titleFrame, CGRectGetHeight(self.bounds) - self.contentEdgeInsets.bottom - self.titleEdgeInsets.bottom - CGRectGetHeight(titleFrame));
                    imageFrame = CGRectSetY(imageFrame, CGRectGetMinY(titleFrame) - self.titleEdgeInsets.top - self.imageEdgeInsets.bottom - CGRectGetHeight(imageFrame));
                    break;
                case UIControlContentVerticalAlignmentFill:
                    // 图片按自身大小显示，剩余空间由标题占满
                    imageFrame = CGRectSetY(imageFrame, self.contentEdgeInsets.top + self.imageEdgeInsets.top);
                    titleFrame = CGRectSetY(titleFrame, CGRectGetMaxY(imageFrame) + self.imageEdgeInsets.bottom + self.titleEdgeInsets.top);
                    titleFrame = CGRectSetHeight(titleFrame, CGRectGetHeight(self.bounds) - self.contentEdgeInsets.bottom - self.titleEdgeInsets.bottom - CGRectGetMinY(titleFrame));
                    break;
            }
        } else {
            switch (self.contentVerticalAlignment) {
                case UIControlContentVerticalAlignmentTop:
                    titleFrame = CGRectSetY(titleFrame, self.contentEdgeInsets.top + self.titleEdgeInsets.top);
                    imageFrame = CGRectSetY(imageFrame, CGRectGetMaxY(titleFrame) + self.titleEdgeInsets.bottom + self.imageEdgeInsets.top);
                    break;
                case UIControlContentVerticalAlignmentCenter: {
                    CGFloat contentHeight = CGRectGetHeight(titleFrame) + UIEdgeInsetsGetVerticalValue(self.titleEdgeInsets) + CGRectGetHeight(imageFrame) + UIEdgeInsetsGetVerticalValue(self.imageEdgeInsets);
                    CGFloat minY = CGFloatGetCenter(contentSize.height, contentHeight) + self.contentEdgeInsets.top;
                    titleFrame = CGRectSetY(titleFrame, minY + self.titleEdgeInsets.top);
                    imageFrame = CGRectSetY(imageFrame, CGRectGetMaxY(titleFrame) + self.titleEdgeInsets.bottom + self.imageEdgeInsets.top);
                }
                    break;
                case UIControlContentVerticalAlignmentBottom:
                    imageFrame = CGRectSetY(imageFrame, CGRectGetHeight(self.bounds) - self.contentEdgeInsets.bottom - self.imageEdgeInsets.bottom - CGRectGetHeight(imageFrame));
                    titleFrame = CGRectSetY(titleFrame, CGRectGetMinY(imageFrame) - self.imageEdgeInsets.top - self.titleEdgeInsets.bottom - CGRectGetHeight(titleFrame));
                    
                    break;
                case UIControlContentVerticalAlignmentFill:
                    // 图片按自身大小显示，剩余空间由标题占满
                    imageFrame = CGRectSetY(imageFrame, CGRectGetHeight(self.bounds) - self.contentEdgeInsets.bottom - self.imageEdgeInsets.bottom - CGRectGetHeight(imageFrame));
                    titleFrame = CGRectSetY(titleFrame, self.contentEdgeInsets.top + self.titleEdgeInsets.top);
                    titleFrame = CGRectSetHeight(titleFrame, CGRectGetMinY(imageFrame) - self.imageEdgeInsets.top - self.titleEdgeInsets.bottom - CGRectGetMinY(titleFrame));
                    break;
            }
        }
        
        self.imageView.frame = CGRectFlatted(imageFrame);
        self.titleLabel.frame = CGRectFlatted(titleFrame);
        
    } else if (self.imagePosition == QMUIButtonImagePositionRight) {
        
        CGFloat imageLimitHeight = contentSize.height - UIEdgeInsetsGetVerticalValue(self.imageEdgeInsets);
        CGSize imageSize = [self.imageView sizeThatFits:CGSizeMake(CGFLOAT_MAX, imageLimitHeight)];// 假设图片宽度必定完整显示，高度不超过按钮内容
        CGRect imageFrame = CGRectMakeWithSize(imageSize);
        
        CGSize titleLimitSize = CGSizeMake(contentSize.width - UIEdgeInsetsGetHorizontalValue(self.titleEdgeInsets) - CGRectGetWidth(imageFrame) - UIEdgeInsetsGetHorizontalValue(self.imageEdgeInsets), contentSize.height - UIEdgeInsetsGetVerticalValue(self.titleEdgeInsets));
        CGSize titleSize = [self.titleLabel sizeThatFits:titleLimitSize];
        titleSize.height = fminf(titleSize.height, titleLimitSize.height);
        CGRect titleFrame = CGRectMakeWithSize(titleSize);
        
        switch (self.contentHorizontalAlignment) {
            case UIControlContentHorizontalAlignmentLeft:
                titleFrame = CGRectSetX(titleFrame, self.contentEdgeInsets.left + self.titleEdgeInsets.left);
                imageFrame = CGRectSetX(imageFrame, CGRectGetMaxX(titleFrame) + self.titleEdgeInsets.right + self.imageEdgeInsets.left);
                break;
            case UIControlContentHorizontalAlignmentCenter: {
                CGFloat contentWidth = CGRectGetWidth(titleFrame) + UIEdgeInsetsGetHorizontalValue(self.titleEdgeInsets) + CGRectGetWidth(imageFrame) + UIEdgeInsetsGetHorizontalValue(self.imageEdgeInsets);
                CGFloat minX = self.contentEdgeInsets.left + CGFloatGetCenter(contentSize.width, contentWidth);
                titleFrame = CGRectSetX(titleFrame, minX + self.titleEdgeInsets.left);
                imageFrame = CGRectSetX(imageFrame, CGRectGetMaxX(titleFrame) + self.titleEdgeInsets.right + self.imageEdgeInsets.left);
            }
                break;
            case UIControlContentHorizontalAlignmentRight:
                imageFrame = CGRectSetX(imageFrame, CGRectGetWidth(self.bounds) - self.contentEdgeInsets.right - self.imageEdgeInsets.right - CGRectGetWidth(imageFrame));
                titleFrame = CGRectSetX(titleFrame, CGRectGetMinX(imageFrame) - self.imageEdgeInsets.left - self.titleEdgeInsets.right - CGRectGetWidth(titleFrame));
                break;
            case UIControlContentHorizontalAlignmentFill:
                // 图片按自身大小显示，剩余空间由标题占满
                imageFrame = CGRectSetX(imageFrame, CGRectGetWidth(self.bounds) - self.contentEdgeInsets.right - self.imageEdgeInsets.right - CGRectGetWidth(imageFrame));
                titleFrame = CGRectSetX(titleFrame, self.contentEdgeInsets.left + self.titleEdgeInsets.left);
                titleFrame = CGRectSetWidth(titleFrame, CGRectGetMinX(imageFrame) - self.imageEdgeInsets.left - self.titleEdgeInsets.right - CGRectGetMinX(titleFrame));
                break;
        }
        
        switch (self.contentVerticalAlignment) {
            case UIControlContentVerticalAlignmentTop:
                titleFrame = CGRectSetY(titleFrame, self.contentEdgeInsets.top + self.titleEdgeInsets.top);
                imageFrame = CGRectSetY(imageFrame, self.contentEdgeInsets.top + self.imageEdgeInsets.top);
                break;
            case UIControlContentVerticalAlignmentCenter:
                titleFrame = CGRectSetY(titleFrame, self.contentEdgeInsets.top + self.titleEdgeInsets.top + CGFloatGetCenter(contentSize.height, CGRectGetHeight(titleFrame) + UIEdgeInsetsGetVerticalValue(self.titleEdgeInsets)));
                imageFrame = CGRectSetY(imageFrame, self.contentEdgeInsets.top + self.imageEdgeInsets.top + CGFloatGetCenter(contentSize.height, CGRectGetHeight(imageFrame) + UIEdgeInsetsGetVerticalValue(self.imageEdgeInsets)));
                break;
            case UIControlContentVerticalAlignmentBottom:
                titleFrame = CGRectSetY(titleFrame, CGRectGetHeight(self.bounds) - self.contentEdgeInsets.bottom - self.titleEdgeInsets.bottom - CGRectGetHeight(titleFrame));
                imageFrame = CGRectSetY(imageFrame, CGRectGetHeight(self.bounds) - self.contentEdgeInsets.bottom - self.imageEdgeInsets.bottom - CGRectGetHeight(imageFrame));
                break;
            case UIControlContentVerticalAlignmentFill:
                titleFrame = CGRectSetY(titleFrame, self.contentEdgeInsets.top + self.titleEdgeInsets.top);
                titleFrame = CGRectSetHeight(titleFrame, CGRectGetHeight(self.bounds) - self.contentEdgeInsets.bottom - self.titleEdgeInsets.bottom - CGRectGetMinY(titleFrame));
                imageFrame = CGRectSetY(imageFrame, self.contentEdgeInsets.top + self.imageEdgeInsets.top);
                imageFrame = CGRectSetHeight(imageFrame, CGRectGetHeight(self.bounds) - self.contentEdgeInsets.bottom - self.imageEdgeInsets.bottom - CGRectGetMinY(imageFrame));
                break;
        }
        
        self.imageView.frame = CGRectFlatted(imageFrame);
        self.titleLabel.frame = CGRectFlatted(titleFrame);
    }
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
            [UIView animateWithDuration:0.25f animations:^{
                self.alpha = 1;
            }];
        }
    }
}

- (void)setEnabled:(BOOL)enabled {
    [super setEnabled:enabled];
    if (!enabled && self.adjustsButtonWhenDisabled) {
        self.alpha = ButtonDisabledAlpha;
    } else {
        [UIView animateWithDuration:0.25f animations:^{
            self.alpha = 1;
        }];
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
    if (self.adjustsTitleTintColorAutomatically && self.currentTitleColor) {
        [self setTitleColor:self.tintColor forState:UIControlStateNormal];
    }
    if (self.adjustsTitleTintColorAutomatically && self.currentAttributedTitle) {
        NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithAttributedString:self.currentAttributedTitle];
        [attributedString addAttribute:NSForegroundColorAttributeName value:self.tintColor range:NSMakeRange(0, attributedString.length)];
        [self setAttributedTitle:attributedString forState:UIControlStateNormal];
    }
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
        NSArray<NSNumber *> *states = @[@(UIControlStateNormal), @(UIControlStateHighlighted), @(UIControlStateDisabled)];
        for (NSNumber *number in states) {
            UIImage *image = [self imageForState:[number unsignedIntegerValue]];
            if (!image) {
                continue;
            }
            
            if (self.adjustsImageTintColorAutomatically) {
                // 这里的image不用做renderingMode的处理，而是放到重写的setImage:forState里去做
                [self setImage:image forState:[number unsignedIntegerValue]];
            } else {
                // 如果不需要用template的模式渲染，并且之前是使用template的，则把renderingMode改回Original
                [self setImage:[image imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] forState:[number unsignedIntegerValue]];
            }
        }
    }
}

- (void)setImage:(UIImage *)image forState:(UIControlState)state {
    if (self.adjustsImageTintColorAutomatically) {
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

@end

@interface QMUINavigationButton()

@property(nonatomic, assign) QMUINavigationButtonPosition buttonPosition;
@end


@implementation QMUINavigationButton

- (instancetype)init {
    return [self initWithType:QMUINavigationButtonTypeNormal];
}

- (instancetype)initWithType:(QMUINavigationButtonType)type {
    return [self initWithType:type title:nil];
}

- (instancetype)initWithType:(QMUINavigationButtonType)type title:(NSString *)title {
    if (self = [super initWithFrame:CGRectZero]) {
        _type = type;
        self.buttonPosition = QMUINavigationButtonPositionNone;
        self.useForBarButtonItem = YES;
        [self setTitle:title forState:UIControlStateNormal];
        [self renderButtonStyle];
        [self sizeToFit];
    }
    return self;
}

- (instancetype)initWithImage:(UIImage *)image {
    if (self = [self initWithType:QMUINavigationButtonTypeImage]) {
        [self setImage:image forState:UIControlStateNormal];
        // 系统在iOS8及以后的版本默认对image的UIBarButtonItem加了上下3、左右11的padding，所以这里统一一下
        self.contentEdgeInsets = UIEdgeInsetsMake(3, 11, 3, 11);
        [self sizeToFit];
    }
    return self;
}

// 对按钮内容添加偏移，让UIBarButtonItem适配最新设备的系统行为，统一位置
- (UIEdgeInsets)alignmentRectInsets {
    
    UIEdgeInsets insets = [super alignmentRectInsets];
    if (!self.useForBarButtonItem || self.buttonPosition == QMUINavigationButtonPositionNone) {
        return insets;
    }
    
    if (self.buttonPosition == QMUINavigationButtonPositionLeft) {
        // 正值表示往左偏移
        if (self.type == QMUINavigationButtonTypeImage) {
            insets = UIEdgeInsetsSetLeft(insets, 11);
        } else {
            insets = UIEdgeInsetsSetLeft(insets, 8);
        }
    } else if (self.buttonPosition == QMUINavigationButtonPositionRight) {
        // 正值表示往右偏移
        if (self.type == QMUINavigationButtonTypeImage) {
            insets = UIEdgeInsetsSetRight(insets, 11);
        } else {
            insets = UIEdgeInsetsSetRight(insets, 8);
        }
    }
    
    
    BOOL isBackOrImageType = self.type == QMUINavigationButtonTypeBack || self.type == QMUINavigationButtonTypeImage;
    if (isBackOrImageType) {
        insets = UIEdgeInsetsSetTop(insets, PixelOne);
    } else {
        insets = UIEdgeInsetsSetTop(insets, 1);
    }
    
    return insets;
}

- (void)renderButtonStyle {
    
    self.titleLabel.backgroundColor = UIColorClear;
    self.titleLabel.font = NavBarButtonFont;
    self.titleLabel.lineBreakMode = NSLineBreakByTruncatingTail;
    self.contentMode = UIViewContentModeCenter;
    self.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
    self.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    self.adjustsImageWhenHighlighted = NO;
    self.adjustsImageWhenDisabled = NO;
    
    switch (self.type) {
        case QMUINavigationButtonTypeNormal:
        case QMUINavigationButtonTypeImage:
            break;
        case QMUINavigationButtonTypeBold: {
            self.titleLabel.font = NavBarButtonFontBold;
        }
            break;
        case QMUINavigationButtonTypeBack: {
            self.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
            UIImage *backIndicatorImage = NavBarBackIndicatorImage;
            if (!backIndicatorImage) {
                QMUILog(@"NavBarBackIndicatorImage 为 nil，无法创建正确的 QMUINavigationButtonTypeBack 按钮");
                return;
            }
            [self setImage:backIndicatorImage forState:UIControlStateNormal];
            [self setImage:[backIndicatorImage qmui_imageWithAlpha:NavBarHighlightedAlpha] forState:UIControlStateHighlighted];
            [self setImage:[backIndicatorImage qmui_imageWithAlpha:NavBarDisabledAlpha] forState:UIControlStateDisabled];
        }
            break;
            
        default:
            break;
    }
}

- (void)setUseForBarButtonItem:(BOOL)useForBarButtonItem {
    if (_useForBarButtonItem != useForBarButtonItem) {
        if (self.type == QMUINavigationButtonTypeBack) {
            // 只针对返回按钮，调整箭头和title之间的间距
            // @warning 这些数值都是每个iOS版本核对过没问题的，如果修改则要检查要每个版本里与系统UIBarButtonItem的布局是否一致
            if (useForBarButtonItem) {
                UIOffset titleOffset = NavBarBarBackButtonTitlePositionAdjustment;
                CGFloat customTitleOffset = IOS_VERSION < 8.0 ? 1 : 0;  // 除了全局设置的titleOffset，有些版本的自定义返回按钮还需要一个偏移值
                CGFloat titleHorizontalOffset = 7.0;
                self.titleEdgeInsets = UIEdgeInsetsMake(titleOffset.vertical + customTitleOffset, titleHorizontalOffset + titleOffset.horizontal, - titleOffset.vertical, -titleHorizontalOffset - titleOffset.horizontal);
                self.contentEdgeInsets = UIEdgeInsetsMake(1, 0, 0, titleHorizontalOffset + titleOffset.horizontal);// 箭头左边的间距
            }
            // 由于contentEdgeInsets会影响frame的大小，所以更新数值后需要重新计算size
            [self sizeToFit];
        }
    }
    _useForBarButtonItem = useForBarButtonItem;
}

// 修复系统的UIBarButtonItem里的图片无法跟着tintColor走
- (void)setImage:(UIImage *)image forState:(UIControlState)state {
    if (image && [image respondsToSelector:@selector(imageWithRenderingMode:)]) {
        image = [image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    }
    [super setImage:image forState:state];
}

// 自定义nav按钮，需要根据这个来修改title的三态颜色。
- (void)tintColorDidChange {
    [super tintColorDidChange];
    [self setTitleColor:self.tintColor forState:UIControlStateNormal];
    [self setTitleColor:[self.tintColor colorWithAlphaComponent:NavBarHighlightedAlpha] forState:UIControlStateHighlighted];
    [self setTitleColor:[self.tintColor colorWithAlphaComponent:NavBarDisabledAlpha] forState:UIControlStateDisabled];
}

+ (void)renderNavigationButtonAppearanceStyle {
    // 更改全局的返回按钮图片
    UIImage *customBackIndicatorImage = NavBarBackIndicatorImage;
    if (customBackIndicatorImage && [UINavigationBar instancesRespondToSelector:@selector(setBackIndicatorImage:)]) {
        UINavigationBar *navBarAppearance = [UINavigationBar appearanceWhenContainedIn:[QMUINavigationController class], nil];
        
        // 返回按钮的图片frame是和系统默认的返回图片的大小一致的（13, 21），所以用自定义返回箭头时要保证图片大小与系统的箭头大小一样，否则无法对齐
        CGSize systemBackIndicatorImageSize = CGSizeMake(13, 21); // 在iOS9上实际测量得到
        CGSize customBackIndicatorImageSize = customBackIndicatorImage.size;
        if (!CGSizeEqualToSize(customBackIndicatorImageSize, systemBackIndicatorImageSize)) {
            CGFloat imageExtensionVerticalFloat = CGFloatGetCenter(systemBackIndicatorImageSize.height, customBackIndicatorImageSize.height);
            customBackIndicatorImage = [customBackIndicatorImage qmui_imageWithSpacingExtensionInsets:UIEdgeInsetsMake(imageExtensionVerticalFloat,
                                                                                                                  0,
                                                                                                                  imageExtensionVerticalFloat,
                                                                                                                  systemBackIndicatorImageSize.width - customBackIndicatorImageSize.width)];
        }
        
        navBarAppearance.backIndicatorImage = customBackIndicatorImage;
        navBarAppearance.backIndicatorTransitionMaskImage = navBarAppearance.backIndicatorImage;
    }
    // 更改全局返回按钮的文字间距
    UIBarButtonItem *backBarButtonItem = [UIBarButtonItem appearanceWhenContainedIn:[QMUINavigationController class], nil];
    [backBarButtonItem setBackButtonTitlePositionAdjustment:NavBarBarBackButtonTitlePositionAdjustment forBarMetrics:UIBarMetricsDefault];
}

// 返回按钮的文字会自动匹配上一个界面的title，如果需要自定义title，则直接用initWithType:title:工具类来做
+ (UIBarButtonItem *)backBarButtonItemWithTarget:(id)target action:(SEL)selector tintColor:(UIColor *)tintColor {
    NSString *backTitle = nil;
    if (NeedsBackBarButtonItemTitle) {
        backTitle = @"返回"; // 默认文字用返回
        
        if ([target isKindOfClass:[UIViewController class]]) {
            UIViewController *viewController = (UIViewController *)target;
            UIViewController *previousViewController = viewController.qmui_previousViewController;
            if (previousViewController.navigationItem.backBarButtonItem) {
                // 如果前一个界面有
                backTitle = previousViewController.navigationItem.backBarButtonItem.title;
                
            } else if (previousViewController.title) {
                backTitle = previousViewController.title;
            }
        }
        
    } else {
        backTitle = @" ";
    }
    
    return [self systemBarButtonItemWithType:QMUINavigationButtonTypeBack title:backTitle tintColor:tintColor position:QMUINavigationButtonPositionLeft target:target action:selector];
}

+ (UIBarButtonItem *)backBarButtonItemWithTarget:(id)target action:(SEL)selector {
    return [self backBarButtonItemWithTarget:target action:selector tintColor:nil];
}

+ (UIBarButtonItem *)closeBarButtonItemWithTarget:(id)target action:(SEL)selector tintColor:(UIColor *)tintColor {
    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithImage:NavBarCloseButtonImage style:UIBarButtonItemStylePlain target:target action:selector];
    item.tintColor = tintColor;
    return item;
}

+ (UIBarButtonItem *)closeBarButtonItemWithTarget:(id)target action:(SEL)selector {
    return [self closeBarButtonItemWithTarget:target action:selector tintColor:nil];
}

+ (UIBarButtonItem *)barButtonItemWithNavigationButton:(QMUINavigationButton *)button tintColor:(UIColor *)tintColor position:(QMUINavigationButtonPosition)position target:(id)target action:(SEL)selector {
    if (target) {
        [button addTarget:target action:selector forControlEvents:UIControlEventTouchUpInside];
    }
    button.tintColor = tintColor;
    button.buttonPosition = position;
    UIBarButtonItem *barButtonItem = [[UIBarButtonItem alloc] initWithCustomView:button];
    return barButtonItem;
}

+ (UIBarButtonItem *)barButtonItemWithNavigationButton:(QMUINavigationButton *)button position:(QMUINavigationButtonPosition)position target:(id)target action:(SEL)selector {
    return [self barButtonItemWithNavigationButton:button tintColor:nil position:position target:target action:selector];
}

+ (UIBarButtonItem *)barButtonItemWithType:(QMUINavigationButtonType)type title:(NSString *)title tintColor:(UIColor *)tintColor position:(QMUINavigationButtonPosition)position target:(id)target action:(SEL)selector {
    UIBarButtonItem *barButtonItem = [QMUINavigationButton systemBarButtonItemWithType:type title:title tintColor:tintColor position:position target:target action:selector];
    return barButtonItem;
}

+ (UIBarButtonItem *)barButtonItemWithType:(QMUINavigationButtonType)type title:(NSString *)title position:(QMUINavigationButtonPosition)position target:(id)target action:(SEL)selector {
    return [QMUINavigationButton barButtonItemWithType:type title:title tintColor:nil position:position target:target action:selector];
}

+ (UIBarButtonItem *)barButtonItemWithImage:(UIImage *)image tintColor:(UIColor *)tintColor position:(QMUINavigationButtonPosition)position target:(id)target action:(SEL)selector {
    UIBarButtonItem *barButtonItem = [[UIBarButtonItem alloc] initWithImage:image style:UIBarButtonItemStylePlain target:target action:selector];
    barButtonItem.tintColor = tintColor;
    return barButtonItem;
}

+ (UIBarButtonItem *)barButtonItemWithImage:(UIImage *)image position:(QMUINavigationButtonPosition)position target:(id)target action:(SEL)selector {
    return [QMUINavigationButton barButtonItemWithImage:image tintColor:nil position:position target:target action:selector];
}

+ (UIBarButtonItem *)systemBarButtonItemWithType:(QMUINavigationButtonType)type title:(NSString *)title tintColor:(UIColor *)tintColor position:(QMUINavigationButtonPosition)position target:(id)target action:(SEL)selector {
    switch (type) {
            
        case QMUINavigationButtonTypeBack:
        {
            // 因为有可能出现有箭头图片又有title的情况，所以这里不适合用barButtonItemWithImage:target:action:的那个接口
            QMUINavigationButton *button = [[QMUINavigationButton alloc] initWithType:QMUINavigationButtonTypeBack title:title];
            button.buttonPosition = position;
            [button addTarget:target action:selector forControlEvents:UIControlEventTouchUpInside];
            button.tintColor = tintColor;
            UIBarButtonItem *barButtonItem = [[UIBarButtonItem alloc] initWithCustomView:button];
            return barButtonItem;
        }
            break;
            
        case QMUINavigationButtonTypeBold:
        {
            UIBarButtonItem *barButtonItem = [[UIBarButtonItem alloc] initWithTitle:title style:UIBarButtonItemStylePlain target:target action:selector];
            [barButtonItem setTitleTextAttributes:@{NSFontAttributeName:NavBarButtonFontBold} forState:UIControlStateNormal];
            barButtonItem.tintColor = tintColor;
            return barButtonItem;
        }
            break;
            
        case QMUINavigationButtonTypeImage:
            // icon - 这种类型请通过barButtonItemWithImage:position:target:action:来定义
            return nil;
            
        default:
        {
            UIBarButtonItem *barButtonItem = [[UIBarButtonItem alloc] initWithTitle:title style:UIBarButtonItemStylePlain target:target action:selector];
            barButtonItem.tintColor = tintColor;
            return barButtonItem;
        }
            break;
    }
}

@end


@implementation QMUIToolbarButton

- (instancetype)init {
    return [self initWithType:QMUIToolbarButtonTypeNormal];
}

- (instancetype)initWithType:(QMUIToolbarButtonType)type {
    return [self initWithType:type title:nil];
}

- (instancetype)initWithType:(QMUIToolbarButtonType)type title:(NSString *)title {
    if (self = [super init]) {
        _type = type;
        [self setTitle:title forState:UIControlStateNormal];
        [self renderButtonStyle];
        [self sizeToFit];
    }
    return self;
}

- (instancetype)initWithImage:(UIImage *)image {
    if (self = [self initWithType:QMUIToolbarButtonTypeImage]) {
        [self setImage:image forState:UIControlStateNormal];
        [self setImage:[image qmui_imageWithAlpha:ToolBarHighlightedAlpha] forState:UIControlStateHighlighted];
        [self setImage:[image qmui_imageWithAlpha:ToolBarDisabledAlpha] forState:UIControlStateDisabled];
        [self sizeToFit];
    }
    return self;
}

- (void)renderButtonStyle {
    self.imageView.contentMode = UIViewContentModeCenter;
    self.imageView.tintColor = nil; // 重置默认值，nil表示跟随父元素
    self.titleLabel.font = ToolBarButtonFont;
    switch (self.type) {
        case QMUIToolbarButtonTypeNormal:
            [self setTitleColor:ToolBarTintColor forState:UIControlStateNormal];
            [self setTitleColor:ToolBarTintColorHighlighted forState:UIControlStateHighlighted];
            [self setTitleColor:ToolBarTintColorDisabled forState:UIControlStateDisabled];
            break;
        case QMUIToolbarButtonTypeRed:
            [self setTitleColor:UIColorRed forState:UIControlStateNormal];
            [self setTitleColor:[UIColorRed colorWithAlphaComponent:ToolBarHighlightedAlpha] forState:UIControlStateHighlighted];
            [self setTitleColor:[UIColorRed colorWithAlphaComponent:ToolBarDisabledAlpha] forState:UIControlStateDisabled];
            self.imageView.tintColor = UIColorRed; // 修改为红色
            break;
        case QMUIToolbarButtonTypeImage:
            break;
        default:
            break;
    }
}

+ (void)renderToolbarButtonAppearanceStyle {
    UIFont *titleFont = ToolBarButtonFont;
    if (titleFont) {
        UIBarButtonItem *barButtonItemAppearance = [UIBarButtonItem appearanceWhenContainedIn:QMUINavigationController.class, nil];
        [barButtonItemAppearance setTitleTextAttributes:@{NSFontAttributeName: titleFont} forState:UIControlStateNormal];
    }
}

+ (UIBarButtonItem *)barButtonItemWithToolbarButton:(QMUIToolbarButton *)button target:(id)target action:(SEL)selector {
    [button addTarget:target action:selector forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *buttonItem = [[UIBarButtonItem alloc] initWithCustomView:button];
    return buttonItem;
}

+ (UIBarButtonItem *)barButtonItemWithType:(QMUIToolbarButtonType)type title:(NSString *)title target:(id)target action:(SEL)selector {
    UIBarButtonItem *buttonItem = [[UIBarButtonItem alloc] initWithTitle:title style:UIBarButtonItemStylePlain target:target action:selector];
    if (type == QMUIToolbarButtonTypeRed) {
        // 默认继承toolBar的tintColor，红色需要重置
        buttonItem.tintColor = UIColorRed;
    }
    return buttonItem;
}

+ (UIBarButtonItem *)barButtonItemWithImage:(UIImage *)image target:(id)target action:(SEL)selector {
    UIBarButtonItem *buttonItem = [[UIBarButtonItem alloc] initWithImage:image style:UIBarButtonItemStylePlain target:target action:selector];
    return buttonItem;
}

@end

@interface QMUILinkButton ()

@property(nonatomic, strong) CALayer *underlineLayer;
@end

@implementation QMUILinkButton

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
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
    [super didInitialized];
    [self setTitleColor:ButtonTintColor forState:UIControlStateNormal];
    
    self.underlineLayer = [CALayer layer];
    [self.underlineLayer qmui_removeDefaultAnimations];
    [self.layer addSublayer:self.underlineLayer];
    
    self.underlineHidden = NO;
    self.underlineWidth = 1;
    self.underlineColor = nil;
    self.underlineInsets = UIEdgeInsetsZero;
}

- (void)setUnderlineHidden:(BOOL)underlineHidden {
    _underlineHidden = underlineHidden;
    self.underlineLayer.hidden = underlineHidden;
}

- (void)setUnderlineWidth:(CGFloat)underlineWidth {
    _underlineWidth = underlineWidth;
    [self setNeedsLayout];
}

- (void)setUnderlineColor:(UIColor *)underlineColor {
    _underlineColor = underlineColor;
    [self updateUnderlineColor];
}

- (void)setUnderlineInsets:(UIEdgeInsets)underlineInsets {
    _underlineInsets = underlineInsets;
    [self setNeedsLayout];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    if (!self.underlineLayer.hidden) {
        self.underlineLayer.frame = CGRectMake(self.underlineInsets.left, CGRectGetMaxY(self.titleLabel.frame) + self.underlineInsets.top - self.underlineInsets.bottom, CGRectGetWidth(self.bounds) - UIEdgeInsetsGetHorizontalValue(self.underlineInsets), self.underlineWidth);
    }
}

- (void)setTitleColor:(UIColor *)color forState:(UIControlState)state {
    [super setTitleColor:color forState:state];
    [self updateUnderlineColor];
}

- (void)updateUnderlineColor {
    UIColor *color = self.underlineColor ? : [self titleColorForState:UIControlStateNormal];
    self.underlineLayer.backgroundColor = color.CGColor;
}

@end

const CGFloat QMUIGhostButtonCornerRadiusAdjustsBounds = -1;

@implementation QMUIGhostButton

- (instancetype)initWithFrame:(CGRect)frame {
    return [self initWithGhostType:QMUIGhostButtonColorBlue frame:frame];
}

- (instancetype)initWithGhostType:(QMUIGhostButtonColor)ghostType {
    return [self initWithGhostType:ghostType frame:CGRectZero];
}

- (instancetype)initWithGhostType:(QMUIGhostButtonColor)ghostType frame:(CGRect)frame {
    UIColor *ghostColor = nil;
    switch (ghostType) {
        case QMUIGhostButtonColorBlue:
            ghostColor = GhostButtonColorBlue;
            break;
        case QMUIGhostButtonColorRed:
            ghostColor = GhostButtonColorRed;
            break;
        case QMUIGhostButtonColorGreen:
            ghostColor = GhostButtonColorGreen;
            break;
        case QMUIGhostButtonColorGray:
            ghostColor = GhostButtonColorGray;
            break;
        case QMUIGhostButtonColorWhite:
            ghostColor = GhostButtonColorWhite;
            break;
        default:
            break;
    }
    return [self initWithGhostColor:ghostColor frame:frame];
}

- (instancetype)initWithGhostColor:(UIColor *)ghostColor {
    return [self initWithGhostColor:ghostColor frame:CGRectZero];
}

- (instancetype)initWithGhostColor:(UIColor *)ghostColor frame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self initializeWithGhostColor:ghostColor];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
        [self initializeWithGhostColor:GhostButtonColorBlue];
    }
    return self;
}

- (void)initializeWithGhostColor:(UIColor *)ghostColor {
    self.ghostColor = ghostColor;
}

- (void)setGhostColor:(UIColor *)ghostColor {
    _ghostColor = ghostColor;
    [self setTitleColor:_ghostColor forState:UIControlStateNormal];
    self.layer.borderColor = _ghostColor.CGColor;
    if (self.adjustsImageWithGhostColor) {
        [self updateImageColor];
    }
}

- (void)setBorderWidth:(CGFloat)borderWidth {
    _borderWidth = borderWidth;
    self.layer.borderWidth = _borderWidth;
}

- (void)setAdjustsImageWithGhostColor:(BOOL)adjustsImageWithGhostColor {
    _adjustsImageWithGhostColor = adjustsImageWithGhostColor;
    [self updateImageColor];
}

- (void)updateImageColor {
    self.imageView.tintColor = self.adjustsImageWithGhostColor ? self.ghostColor : nil;
    if (self.currentImage) {
        NSArray<NSNumber *> *states = @[@(UIControlStateNormal), @(UIControlStateHighlighted), @(UIControlStateDisabled)];
        for (NSNumber *number in states) {
            UIImage *image = [self imageForState:[number unsignedIntegerValue]];
            if (!image) {
                continue;
            }
            if (self.adjustsImageWithGhostColor) {
                // 这里的image不用做renderingMode的处理，而是放到重写的setImage:forState里去做
                [self setImage:image forState:[number unsignedIntegerValue]];
            } else {
                // 如果不需要用template的模式渲染，并且之前是使用template的，则把renderingMode改回Original
                [self setImage:[image imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] forState:[number unsignedIntegerValue]];
            }
        }
    }
}

- (void)setImage:(UIImage *)image forState:(UIControlState)state {
    if (self.adjustsImageWithGhostColor) {
        image = [image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    }
    [super setImage:image forState:state];
}

- (void)layoutSublayersOfLayer:(CALayer *)layer {
    [super layoutSublayersOfLayer:layer];
    if (self.cornerRadius != QMUIGhostButtonCornerRadiusAdjustsBounds) {
        self.layer.cornerRadius = self.cornerRadius;
    } else {
        self.layer.cornerRadius = flat(CGRectGetHeight(self.bounds) / 2);
    }
}

- (void)setCornerRadius:(CGFloat)cornerRadius {
    _cornerRadius = cornerRadius;
    [self setNeedsLayout];
}

@end

@interface QMUIGhostButton (UIAppearance)

@end

@implementation QMUIGhostButton (UIAppearance)

+ (void)initialize {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        [self setDefaultAppearance];
    });
}

+ (void)setDefaultAppearance {
    QMUIGhostButton *appearance = [QMUIGhostButton appearance];
    appearance.borderWidth = 1;
    appearance.cornerRadius = QMUIGhostButtonCornerRadiusAdjustsBounds;
    if (IOS_VERSION >= 8.0) {
        appearance.adjustsImageWithGhostColor = NO;
    }
}

@end


const CGFloat QMUIFillButtonCornerRadiusAdjustsBounds = -1;

@implementation QMUIFillButton

- (instancetype)init {
    return [self initWithFillType:QMUIFillButtonColorBlue];
}

- (instancetype)initWithFrame:(CGRect)frame {
    return [self initWithFillType:QMUIFillButtonColorBlue frame:frame];
}

- (instancetype)initWithFillType:(QMUIFillButtonColor)fillType {
    return [self initWithFillType:fillType frame:CGRectZero];
}

- (instancetype)initWithFillType:(QMUIFillButtonColor)fillType frame:(CGRect)frame {
    UIColor *fillColor = nil;
    UIColor *textColor = UIColorWhite;
    switch (fillType) {
        case QMUIFillButtonColorBlue:
            fillColor = FillButtonColorBlue;
            break;
        case QMUIFillButtonColorRed:
            fillColor = FillButtonColorRed;
            break;
        case QMUIFillButtonColorGreen:
            fillColor = FillButtonColorGreen;
            break;
        case QMUIFillButtonColorGray:
            fillColor = FillButtonColorGray;
            break;
        case QMUIFillButtonColorWhite:
            fillColor = FillButtonColorWhite;
            textColor = UIColorBlue;
        default:
            break;
    }
    return [self initWithFillColor:fillColor titleTextColor:textColor frame:frame];
}

- (instancetype)initWithFillColor:(UIColor *)fillColor titleTextColor:(UIColor *)textColor {
    return [self initWithFillColor:fillColor titleTextColor:textColor frame:CGRectZero];
}

- (instancetype)initWithFillColor:(UIColor *)fillColor titleTextColor:(UIColor *)textColor frame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.fillColor = fillColor;
        self.titleTextColor = textColor;
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
        self.fillColor = FillButtonColorBlue;
        self.titleTextColor = UIColorWhite;
    }
    return self;
}

- (void)setAdjustsImageWithTitleTextColor:(BOOL)adjustsImageWithTitleTextColor {
    _adjustsImageWithTitleTextColor = adjustsImageWithTitleTextColor;
    if (adjustsImageWithTitleTextColor) {
        [self updateImageColor];
    }
}

- (void)setFillColor:(UIColor *)fillColor {
    _fillColor = fillColor;
    self.backgroundColor = fillColor;
}

- (void)setTitleTextColor:(UIColor *)titleTextColor {
    _titleTextColor = titleTextColor;
    [self setTitleColor:titleTextColor forState:UIControlStateNormal];
    if (self.adjustsImageWithTitleTextColor) {
        [self updateImageColor];
    }
}

- (void)setImage:(UIImage *)image forState:(UIControlState)state {
    if (self.adjustsImageWithTitleTextColor) {
        image = [image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    }
    [super setImage:image forState:state];
}

- (void)updateImageColor {
    self.imageView.tintColor = self.adjustsImageWithTitleTextColor ? self.titleTextColor : nil;
    if (self.currentImage) {
        NSArray<NSNumber *> *states = @[@(UIControlStateNormal), @(UIControlStateHighlighted), @(UIControlStateDisabled)];
        for (NSNumber *number in states) {
            UIImage *image = [self imageForState:[number unsignedIntegerValue]];
            if (!image) {
                continue;
            }
            if (self.adjustsImageWithTitleTextColor) {
                // 这里的image不用做renderingMode的处理，而是放到重写的setImage:forState里去做
                [self setImage:image forState:[number unsignedIntegerValue]];
            } else {
                // 如果不需要用template的模式渲染，并且之前是使用template的，则把renderingMode改回Original
                [self setImage:[image imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] forState:[number unsignedIntegerValue]];
            }
        }
    }
}

- (void)layoutSublayersOfLayer:(CALayer *)layer {
    [super layoutSublayersOfLayer:layer];
    if (self.cornerRadius != QMUIFillButtonCornerRadiusAdjustsBounds) {
        self.layer.cornerRadius = self.cornerRadius;
    } else {
        self.layer.cornerRadius = flat(CGRectGetHeight(self.bounds) / 2);
    }
}

- (void)setCornerRadius:(CGFloat)cornerRadius {
    _cornerRadius = cornerRadius;
    [self setNeedsLayout];
}

@end

@interface QMUIFillButton (UIAppearance)

@end

@implementation QMUIFillButton (UIAppearance)

+ (void)initialize {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        [self setDefaultAppearance];
    });
}

+ (void)setDefaultAppearance {
    QMUIFillButton *appearance = [QMUIFillButton appearance];
    appearance.cornerRadius = QMUIFillButtonCornerRadiusAdjustsBounds;
    if (IOS_VERSION >= 8.0) {
        appearance.adjustsImageWithTitleTextColor = NO;
    }
}

@end
