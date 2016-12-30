//
//  UILabel+QMUI.m
//  qmui
//
//  Created by ZhoonChen on 15/7/20.
//  Copyright (c) 2015年 QMUI Team. All rights reserved.
//

#import "UILabel+QMUI.h"
#import "QMUICommonDefines.h"
#import "QMUIConfiguration.h"
#import "QMUILabel.h"

@implementation UILabel (QMUI)

- (instancetype)initWithFont:(UIFont *)font textColor:(UIColor *)textColor {
    if (self = [super init]) {
        self.font = font;
        self.textColor = textColor;
    }
    return self;
}

- (void)qmui_setTheSameAppearanceAsLabel:(UILabel *)label {
    self.font = label.font;
    self.textColor = label.textColor;
    self.backgroundColor = label.backgroundColor;
    self.lineBreakMode = label.lineBreakMode;
    self.textAlignment = label.textAlignment;
    if ([self respondsToSelector:@selector(contentEdgeInsets)] && [label respondsToSelector:@selector(contentEdgeInsets)]) {
        ((QMUILabel *)self).contentEdgeInsets = ((QMUILabel *)label).contentEdgeInsets;
    }
}

- (void)qmui_calculateHeightAfterSetAppearance {
    self.text = @"测";
    [self sizeToFit];
    self.text = nil;
}

- (void)qmui_avoidBlendedLayersIfShowingChineseWithBackgroundColor:(UIColor *)color {
    self.opaque = YES;// 本来默认就是YES，这里还是明确写一下，表意清晰
    self.backgroundColor = color;
    if (IOS_VERSION >= 8.0) {
        self.clipsToBounds = YES;// 只clip不适用cornerRadius就不会触发offscreen render
    }
}

@end
