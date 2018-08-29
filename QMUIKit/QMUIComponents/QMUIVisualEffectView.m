//
//  QMUIVisualEffectView.m
//  QMUIKit
//
//  Created by zhoonchen on 2018/6/19.
//  Copyright © 2018年 QMUI Team. All rights reserved.
//

#import "QMUIVisualEffectView.h"
#import "QMUICore.h"
#import "CALayer+QMUI.h"

@interface QMUIVisualEffectView ()

@property(nonatomic, strong) CALayer *foregroundLayer;

@end

@implementation QMUIVisualEffectView

- (instancetype)initWithEffect:(nullable UIVisualEffect *)effect {
    if (self = [super initWithEffect:effect]) {
        [self didInitialize];
    }
    return self;
}

- (nullable instancetype)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
        [self didInitialize];
    }
    return self;
}

- (void)didInitialize {
    self.foregroundLayer = [CALayer layer];
    [self.foregroundLayer qmui_removeDefaultAnimations];
    [self.contentView.layer addSublayer:self.foregroundLayer];
}

- (void)setForegroundColor:(UIColor *)foregroundColor {
    _foregroundColor = foregroundColor;
    self.foregroundLayer.backgroundColor = foregroundColor.CGColor;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    self.foregroundLayer.frame = self.contentView.bounds;
}

@end
