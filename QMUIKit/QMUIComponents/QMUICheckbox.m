//
//  QMUICheckbox.m
//  QMUIKit
//
//  Created by molice on 2024/8/1.
//  Copyright © 2024 QMUI Team. All rights reserved.
//

#import "QMUICheckbox.h"
#import "QMUICore.h"
#import "CALayer+QMUI.h"
#import "UIView+QMUI.h"

@interface QMUICheckbox ()
@property(nonatomic, strong) UIImageView *indeterminateImageView;
@property(nonatomic, strong) CALayer *imageViewMaks;
@end

@implementation QMUICheckbox

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.normalImage = self.normalImage;
        self.selectedImage = self.selectedImage;
        self.indeterminateImage = self.indeterminateImage;
        self.disabledImage = self.disabledImage;
        
        _checkboxSize = self.currentImage.size;
        self.imageView.contentMode = UIViewContentModeScaleToFill;
        self.qmui_outsideEdge = UIEdgeInsetsMake(-8, -8, -8, -8);
    }
    return self;
}

- (void)setNormalImage:(UIImage *)normalImage {
    _normalImage = normalImage ?: [[QMUIHelper imageWithName:@"QMUI_checkbox16"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    [self setImage:_normalImage forState:UIControlStateNormal];
}

- (void)setSelectedImage:(UIImage *)selectedImage {
    _selectedImage = selectedImage ?: [[QMUIHelper imageWithName:@"QMUI_checkbox16_checked"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    [self setImage:_selectedImage forState:UIControlStateSelected];
    [self setImage:_selectedImage forState:UIControlStateSelected|UIControlStateHighlighted];
    [self setImage:_selectedImage forState:UIControlStateSelected|UIControlStateDisabled];
}

- (void)setDisabledImage:(UIImage *)disabledImage {
    _disabledImage = disabledImage ?: [[QMUIHelper imageWithName:@"QMUI_checkbox16_disabled"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    [self setImage:_disabledImage forState:UIControlStateDisabled];
}

- (void)setIndeterminateImage:(UIImage *)indeterminateImage {
    _indeterminateImage = indeterminateImage ?: [[QMUIHelper imageWithName:@"QMUI_checkbox16_indeterminate"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
}

- (void)setIndeterminate:(BOOL)indeterminate {
    BOOL valueChanged = _indeterminate != indeterminate;
    if (!valueChanged) return;
    
    _indeterminate = indeterminate;
    if (indeterminate) {
        if (self.selected) {
            self.selected = NO;
        }
        if (!self.indeterminateImageView) {
            self.indeterminateImageView = [[UIImageView alloc] init];
            self.indeterminateImageView.contentMode = UIViewContentModeScaleToFill;
            [self addSubview:self.indeterminateImageView];
        }
        if (!self.imageViewMaks) {
            self.imageViewMaks = CALayer.layer;
            [self.imageViewMaks qmui_removeDefaultAnimations];
        }
        self.indeterminateImageView.image = self.indeterminateImage;
        self.indeterminateImageView.hidden = NO;
        self.imageView.layer.mask = self.imageViewMaks;// 保持 imageView 布局不变的情况下让 imageView 不可见
        [self setNeedsLayout];
    } else {
        self.indeterminateImageView.hidden = YES;
        self.imageView.layer.mask = nil;
    }
}

- (void)setSelected:(BOOL)selected {
    [super setSelected:selected];
    if (selected && self.indeterminate) {
        self.indeterminate = NO;
    }
}

- (void)layoutSubviews {
    [super layoutSubviews];
    self.indeterminateImageView.frame = self.imageView.frame;
}

- (void)setCheckboxSize:(CGSize)checkboxSize {
    if (CGSizeIsEmpty(checkboxSize)) return;
    _checkboxSize = checkboxSize;
    self.imageView.qmui_fixedSize = checkboxSize;
    self.indeterminateImageView.qmui_fixedSize = checkboxSize;
    [self setNeedsLayout];
}

@end
