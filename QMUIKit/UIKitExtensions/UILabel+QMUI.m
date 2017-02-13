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

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        ReplaceMethod([self class], @selector(setText:), @selector(qmui_setText:));
    });
}

- (void)qmui_setText:(NSString *)text {
    [self qmui_setText:text];
    if (self.qmui_textAttributes && text) {
        NSAttributedString *attributedString = [[NSAttributedString alloc] initWithString:text attributes:self.qmui_textAttributes];
        self.attributedText = attributedString;
    }
}

static char kAssociatedObjectKey_textAttributes;
- (void)setQmui_textAttributes:(NSDictionary<NSString *, id> *)qmui_textAttributes {
    objc_setAssociatedObject(self, &kAssociatedObjectKey_textAttributes, qmui_textAttributes, OBJC_ASSOCIATION_COPY_NONATOMIC);
    [self setText:self.text];
}

- (NSDictionary *)qmui_textAttributes {
    return (NSDictionary *)objc_getAssociatedObject(self, &kAssociatedObjectKey_textAttributes);
}

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
