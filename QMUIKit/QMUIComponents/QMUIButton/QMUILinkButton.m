/**
 * Tencent is pleased to support the open source community by making QMUI_iOS available.
 * Copyright (C) 2016-2021 THL A29 Limited, a Tencent company. All rights reserved.
 * Licensed under the MIT License (the "License"); you may not use this file except in compliance with the License. You may obtain a copy of the License at
 * http://opensource.org/licenses/MIT
 * Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.
 */

//
//  QMUILinkButton.m
//  QMUIKit
//
//  Created by QMUI Team on 2018/4/9.
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
    [super didInitialize];
    
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
