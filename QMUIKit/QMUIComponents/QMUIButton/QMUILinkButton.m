//
//  QMUILinkButton.m
//  QMUIKit
//
//  Created by MoLice on 2018/4/9.
//  Copyright © 2018年 QMUI Team. All rights reserved.
//

#import "QMUILinkButton.h"
#import "QMUICore.h"
#import "CALayer+QMUI.h"

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
