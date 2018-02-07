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
        ReplaceMethod([self class], @selector(setAttributedText:), @selector(qmui_setAttributedText:));
    });
}

- (void)qmui_setText:(NSString *)text {
    if (!self.qmui_textAttributes.count || !text) {
        [self qmui_setText:text];
        return;
    }
    NSAttributedString *attributedString = [[NSAttributedString alloc] initWithString:text attributes:self.qmui_textAttributes];
    [self qmui_setAttributedText:[self attributedStringWithEndKernRemoved:attributedString]];
}

// 在 qmui_textAttributes 样式基础上添加用户传入的 attributedString 中包含的新样式。换句话说，如果这个方法里有样式冲突，则以 attributedText 为准
- (void)qmui_setAttributedText:(NSAttributedString *)text {
    if (!self.qmui_textAttributes.count || !text) {
        [self qmui_setAttributedText:text];
        return;
    }
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:text.string attributes:self.qmui_textAttributes];
    attributedString = [[self attributedStringWithEndKernRemoved:attributedString] mutableCopy];
    [text enumerateAttributesInRange:NSMakeRange(0, text.length) options:0 usingBlock:^(NSDictionary<NSString *,id> * _Nonnull attrs, NSRange range, BOOL * _Nonnull stop) {
        [attributedString addAttributes:attrs range:range];
    }];
    [self qmui_setAttributedText:attributedString];
}

static char kAssociatedObjectKey_textAttributes;
// 在现有样式基础上增加 qmui_textAttributes 样式。换句话说，如果这个方法里有样式冲突，则以 qmui_textAttributes 为准
- (void)setQmui_textAttributes:(NSDictionary<NSString *, id> *)qmui_textAttributes {
    NSDictionary *prevTextAttributes = self.qmui_textAttributes;
    if ([prevTextAttributes isEqualToDictionary:qmui_textAttributes]) {
        return;
    }
    
    objc_setAssociatedObject(self, &kAssociatedObjectKey_textAttributes, qmui_textAttributes, OBJC_ASSOCIATION_COPY_NONATOMIC);
    
    if (!self.text.length) {
        return;
    }
    NSMutableAttributedString *string = [self.attributedText mutableCopy];
    NSRange fullRange = NSMakeRange(0, string.length);
    
    // 1）清除掉旧的通过 qmui_textAttributes 设置的样式
    if (prevTextAttributes) {
        // 找出现在 attributedText 中哪些 attrs 是通过上次的 qmui_textAttributes 设置的
        NSMutableArray *willRemovedAttributes = [NSMutableArray array];
        [string enumerateAttributesInRange:NSMakeRange(0, string.length) options:0 usingBlock:^(NSDictionary<NSString *,id> * _Nonnull attrs, NSRange range, BOOL * _Nonnull stop) {
            // 如果存在 kern 属性，则只有 range 是第一个字至倒数第二个字，才有可能是通过 qmui_textAttribtus 设置的
            if (NSEqualRanges(range, NSMakeRange(0, string.length - 1)) && [attrs[NSKernAttributeName] isEqualToNumber:prevTextAttributes[NSKernAttributeName]]) {
                [string removeAttribute:NSKernAttributeName range:NSMakeRange(0, string.length - 1)];
            }
            // 上面排除掉 kern 属性后，如果 range 不是整个字符串，那肯定不是通过 qmui_textAttributes 设置的
            if (!NSEqualRanges(range, fullRange)) {
                return;
            }
            [attrs enumerateKeysAndObjectsUsingBlock:^(NSString * _Nonnull attr, id  _Nonnull value, BOOL * _Nonnull stop) {
                if (prevTextAttributes[attr] == value) {
                    [willRemovedAttributes addObject:attr];
                }
            }];
        }];
        [willRemovedAttributes enumerateObjectsUsingBlock:^(id  _Nonnull attr, NSUInteger idx, BOOL * _Nonnull stop) {
            [string removeAttribute:attr range:fullRange];
        }];
    }
    
    // 2）添加新样式
    if (qmui_textAttributes) {
        [string addAttributes:qmui_textAttributes range:fullRange];
    }
    // 不能调用 setAttributedText: ，否则若遇到样式冲突，那个方法会让用户传进来的 NSAttributedString 样式覆盖 qmui_textAttributes 的样式
    [self qmui_setAttributedText:[self attributedStringWithEndKernRemoved:string]];
}

- (NSDictionary *)qmui_textAttributes {
    return (NSDictionary *)objc_getAssociatedObject(self, &kAssociatedObjectKey_textAttributes);
}

// 去除最后一个字的 kern 效果，使得文字整体在视觉上居中
- (NSAttributedString *)attributedStringWithEndKernRemoved:(NSAttributedString *)string {
    if (!string || !string.length) {
        return string;
    }
    NSMutableAttributedString *attributedString = nil;
    if ([string isKindOfClass:[NSMutableAttributedString class]]) {
        attributedString = (NSMutableAttributedString *)string;
    } else {
        attributedString = [string mutableCopy];
    }
    [attributedString removeAttribute:NSKernAttributeName range:NSMakeRange(string.length - 1, 1)];
    return [[NSAttributedString alloc] initWithAttributedString:attributedString];
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
