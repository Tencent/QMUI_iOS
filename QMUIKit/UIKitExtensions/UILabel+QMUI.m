/**
 * Tencent is pleased to support the open source community by making QMUI_iOS available.
 * Copyright (C) 2016-2021 THL A29 Limited, a Tencent company. All rights reserved.
 * Licensed under the MIT License (the "License"); you may not use this file except in compliance with the License. You may obtain a copy of the License at
 * http://opensource.org/licenses/MIT
 * Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.
 */

//
//  UILabel+QMUI.m
//  qmui
//
//  Created by QMUI Team on 15/7/20.
//

#import "UILabel+QMUI.h"
#import "QMUICore.h"
#import "NSParagraphStyle+QMUI.h"
#import "NSObject+QMUI.h"
#import "NSNumber+QMUI.h"
#import "CALayer+QMUI.h"
#import "UIView+QMUI.h"

const CGFloat QMUILineHeightIdentity = -1000;

@interface UILabel ()

@property(nonatomic, strong) CAShapeLayer *qmuilb_principalLineLayer;
@end

@implementation UILabel (QMUI)

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        SEL selectors[] = {
            @selector(setText:),
            @selector(setAttributedText:),
            @selector(setLineBreakMode:),
            @selector(setTextAlignment:),
        };
        for (NSUInteger index = 0; index < sizeof(selectors) / sizeof(SEL); index++) {
            SEL originalSelector = selectors[index];
            SEL swizzledSelector = NSSelectorFromString([@"qmuilb_" stringByAppendingString:NSStringFromSelector(originalSelector)]);
            ExchangeImplementations([self class], originalSelector, swizzledSelector);
        }
    });
}

- (void)qmuilb_setText:(NSString *)text {
    if (!text) {
        [self qmuilb_setText:text];
        return;
    }
    if (!self.qmui_textAttributes.count && ![self _hasSetQmuiLineHeight]) {
        [self qmuilb_setText:text];
        return;
    }
    NSAttributedString *attributedString = [[NSAttributedString alloc] initWithString:text attributes:self.qmui_textAttributes];
    [self qmuilb_setAttributedText:[self attributedStringWithKernAndLineHeightAdjusted:attributedString]];
}

// 在 qmui_textAttributes 样式基础上添加用户传入的 attributedString 中包含的新样式。换句话说，如果这个方法里有样式冲突，则以 attributedText 为准
- (void)qmuilb_setAttributedText:(NSAttributedString *)text {
    if (!text || (!self.qmui_textAttributes.count && ![self _hasSetQmuiLineHeight])) {
        [self qmuilb_setAttributedText:text];
        return;
    }
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:text.string attributes:self.qmui_textAttributes];
    attributedString = [[self attributedStringWithKernAndLineHeightAdjusted:attributedString] mutableCopy];
    [text enumerateAttributesInRange:NSMakeRange(0, text.length) options:0 usingBlock:^(NSDictionary<NSString *,id> * _Nonnull attrs, NSRange range, BOOL * _Nonnull stop) {
        [attributedString addAttributes:attrs range:range];
    }];
    [self qmuilb_setAttributedText:attributedString];
}

static char kAssociatedObjectKey_textAttributes;
// 在现有样式基础上增加 qmui_textAttributes 样式。换句话说，如果这个方法里有样式冲突，则以 qmui_textAttributes 为准
- (void)setQmui_textAttributes:(NSDictionary<NSAttributedStringKey, id> *)qmui_textAttributes {
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
    
    // 1）当前 attributedText 包含的样式可能来源于两方面：通过 qmui_textAttributes 设置的、通过直接传入 attributedString 设置的，这里要过滤删除掉前者的样式效果，保留后者的样式效果
    if (prevTextAttributes) {
        // 找出现在 attributedText 中哪些 attrs 是通过上次的 qmui_textAttributes 设置的
        NSMutableArray *willRemovedAttributes = [NSMutableArray array];
        [string enumerateAttributesInRange:NSMakeRange(0, string.length) options:0 usingBlock:^(NSDictionary<NSAttributedStringKey,id> * _Nonnull attrs, NSRange range, BOOL * _Nonnull stop) {
            // 如果存在 kern 属性，则只有 range 是第一个字至倒数第二个字，才有可能是通过 qmui_textAttribtus 设置的
            if (NSEqualRanges(range, NSMakeRange(0, string.length - 1)) && [attrs[NSKernAttributeName] isEqualToNumber:prevTextAttributes[NSKernAttributeName]]) {
                [string removeAttribute:NSKernAttributeName range:NSMakeRange(0, string.length - 1)];
            }
            // 上面排除掉 kern 属性后，如果 range 不是整个字符串，那肯定不是通过 qmui_textAttributes 设置的
            if (!NSEqualRanges(range, fullRange)) {
                return;
            }
            [attrs enumerateKeysAndObjectsUsingBlock:^(NSAttributedStringKey _Nonnull attr, id  _Nonnull value, BOOL * _Nonnull stop) {
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
    [self qmuilb_setAttributedText:[self attributedStringWithKernAndLineHeightAdjusted:string]];
}

- (NSDictionary *)qmui_textAttributes {
    return (NSDictionary *)objc_getAssociatedObject(self, &kAssociatedObjectKey_textAttributes);
}

// 去除最后一个字的 kern 效果，并且在有必要的情况下应用 qmui_setLineHeight: 设置的行高
- (NSAttributedString *)attributedStringWithKernAndLineHeightAdjusted:(NSAttributedString *)string {
    if (!string.length) {
        return string;
    }
    NSMutableAttributedString *attributedString = nil;
    if ([string isKindOfClass:[NSMutableAttributedString class]]) {
        attributedString = (NSMutableAttributedString *)string;
    } else {
        attributedString = [string mutableCopy];
    }
    
    // 去除最后一个字的 kern 效果，使得文字整体在视觉上居中
    // 只有当 qmui_textAttributes 中设置了 kern 时这里才应该做调整
    if (self.qmui_textAttributes[NSKernAttributeName]) {
        [attributedString removeAttribute:NSKernAttributeName range:NSMakeRange(string.length - 1, 1)];
    }
    
    // 判断是否应该应用上通过 qmui_setLineHeight: 设置的行高
    __block BOOL shouldAdjustLineHeight = [self _hasSetQmuiLineHeight];
    [attributedString enumerateAttribute:NSParagraphStyleAttributeName inRange:NSMakeRange(0, attributedString.length) options:0 usingBlock:^(NSParagraphStyle *style, NSRange range, BOOL * _Nonnull stop) {
        // 如果用户已经通过传入 NSParagraphStyle 对文字整个 range 设置了行高，则这里不应该再次调整行高
        if (NSEqualRanges(range, NSMakeRange(0, attributedString.length))) {
            if (style && (style.maximumLineHeight || style.minimumLineHeight)) {
                shouldAdjustLineHeight = NO;
                *stop = YES;
            }
        }
    }];
    if (shouldAdjustLineHeight) {
        NSMutableParagraphStyle *paraStyle = [NSMutableParagraphStyle qmui_paragraphStyleWithLineHeight:self.qmui_lineHeight lineBreakMode:self.lineBreakMode textAlignment:self.textAlignment];
        [attributedString addAttribute:NSParagraphStyleAttributeName value:paraStyle range:NSMakeRange(0, attributedString.length)];
        
        // iOS 默认文字底对齐，改了行高要自己调整才能保证文字一直在 label 里垂直居中
        CGFloat baselineOffset = (self.qmui_lineHeight - self.font.lineHeight) / 4;// 实际测量得知，baseline + 1，文字会往上移动 2pt，所以这里为了垂直居中，需要 / 4。
        [attributedString addAttribute:NSBaselineOffsetAttributeName value:@(baselineOffset) range:NSMakeRange(0, attributedString.length)];
    }
    
    return attributedString;
}

- (void)qmuilb_setLineBreakMode:(NSLineBreakMode)lineBreakMode {
    [self qmuilb_setLineBreakMode:lineBreakMode];
    if (!self.qmui_textAttributes) return;
    if (self.qmui_textAttributes[NSParagraphStyleAttributeName]) {
        NSMutableParagraphStyle *p = ((NSParagraphStyle *)self.qmui_textAttributes[NSParagraphStyleAttributeName]).mutableCopy;
        p.lineBreakMode = lineBreakMode;
        NSMutableDictionary<NSAttributedStringKey, id> *attrs = self.qmui_textAttributes.mutableCopy;
        attrs[NSParagraphStyleAttributeName] = p.copy;
        self.qmui_textAttributes = attrs.copy;
    }
}

- (void)qmuilb_setTextAlignment:(NSTextAlignment)textAlignment {
    [self qmuilb_setTextAlignment:textAlignment];
    if (!self.qmui_textAttributes) return;
    if (self.qmui_textAttributes[NSParagraphStyleAttributeName]) {
        NSMutableParagraphStyle *p = ((NSParagraphStyle *)self.qmui_textAttributes[NSParagraphStyleAttributeName]).mutableCopy;
        p.alignment = textAlignment;
        NSMutableDictionary<NSAttributedStringKey, id> *attrs = self.qmui_textAttributes.mutableCopy;
        attrs[NSParagraphStyleAttributeName] = p.copy;
        self.qmui_textAttributes = attrs.copy;
    }
}

static char kAssociatedObjectKey_lineHeight;
- (void)setQmui_lineHeight:(CGFloat)qmui_lineHeight {
    if (qmui_lineHeight == QMUILineHeightIdentity) {
        objc_setAssociatedObject(self, &kAssociatedObjectKey_lineHeight, nil, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    } else {
        objc_setAssociatedObject(self, &kAssociatedObjectKey_lineHeight, @(qmui_lineHeight), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    // 注意：对于 UILabel，只要你设置过 text，则 attributedText 就是有值的，因此这里无需区分 setText 还是 setAttributedText
    // 注意：这里需要刷新一下 qmui_textAttributes 对 text 的样式，否则刚进行设置的 lineHeight 就会无法设置。
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:self.attributedText.string attributes:self.qmui_textAttributes];
    attributedString = [[self attributedStringWithKernAndLineHeightAdjusted:attributedString] mutableCopy];
    [self setAttributedText:attributedString];
}

- (CGFloat)qmui_lineHeight {
    if ([self _hasSetQmuiLineHeight]) {
        return [(NSNumber *)objc_getAssociatedObject(self, &kAssociatedObjectKey_lineHeight) qmui_CGFloatValue];
    } else if (self.attributedText.length) {
        __block NSMutableAttributedString *string = [self.attributedText mutableCopy];
        __block CGFloat result = 0;
        [string enumerateAttribute:NSParagraphStyleAttributeName inRange:NSMakeRange(0, string.length) options:0 usingBlock:^(NSParagraphStyle *style, NSRange range, BOOL * _Nonnull stop) {
            // 如果用户已经通过传入 NSParagraphStyle 对文字整个 range 设置了行高，则这里不应该再次调整行高
            if (NSEqualRanges(range, NSMakeRange(0, string.length))) {
                if (style && (style.maximumLineHeight || style.minimumLineHeight)) {
                    result = style.maximumLineHeight;
                    *stop = YES;
                }
            }
        }];
        
        return result == 0 ? self.font.lineHeight : result;
    } else if (self.text.length) {
        return self.font.lineHeight;
    } else if (self.qmui_textAttributes) {
        // 当前 label 连文字都没有时，再尝试从 qmui_textAttributes 里获取
        if ([self.qmui_textAttributes.allKeys containsObject:NSParagraphStyleAttributeName]) {
            return ((NSParagraphStyle *)self.qmui_textAttributes[NSParagraphStyleAttributeName]).minimumLineHeight;
        } else if ([self.qmui_textAttributes.allKeys containsObject:NSFontAttributeName]) {
            return ((UIFont *)self.qmui_textAttributes[NSFontAttributeName]).lineHeight;
        }
    }
    
    return 0;
}

- (BOOL)_hasSetQmuiLineHeight {
    return !!objc_getAssociatedObject(self, &kAssociatedObjectKey_lineHeight);
}

- (instancetype)qmui_initWithFont:(UIFont *)font textColor:(UIColor *)textColor {
    BeginIgnoreClangWarning(-Wunused-value)
    [self init];
    EndIgnoreClangWarning
    self.font = font;
    self.textColor = textColor;
    return self;
}

- (void)qmui_setTheSameAppearanceAsLabel:(UILabel *)label {
    self.font = label.font;
    self.textColor = label.textColor;
    self.backgroundColor = label.backgroundColor;
    self.lineBreakMode = label.lineBreakMode;
    self.textAlignment = label.textAlignment;
    if ([self respondsToSelector:@selector(setContentEdgeInsets:)] && [label respondsToSelector:@selector(contentEdgeInsets)]) {
        UIEdgeInsets contentEdgeInsets;
        [label qmui_performSelector:@selector(contentEdgeInsets) withPrimitiveReturnValue:&contentEdgeInsets];
        [self qmui_performSelector:@selector(setContentEdgeInsets:) withArguments:&contentEdgeInsets, nil];
    }
}

- (void)qmui_calculateHeightAfterSetAppearance {
    self.text = @"测";
    [self sizeToFit];
    self.text = nil;
}

- (void)qmui_avoidBlendedLayersIfShowingChineseWithBackgroundColor:(UIColor *)color {
    self.opaque = YES;// 本来默认就是YES，这里还是明确写一下
    self.backgroundColor = color;
    self.clipsToBounds = YES;// 只 clip 不使用 cornerRadius就不会触发offscreen render
}

@end

@implementation UILabel (QMUI_Debug)

QMUISynthesizeIdStrongProperty(qmuilb_principalLineLayer, setQmuilb_principalLineLayer)
QMUISynthesizeIdStrongProperty(qmui_principalLineColor, setQmui_principalLineColor)

static char kAssociatedObjectKey_showPrincipalLines;
- (void)setQmui_showPrincipalLines:(BOOL)qmui_showPrincipalLines {
    objc_setAssociatedObject(self, &kAssociatedObjectKey_showPrincipalLines, @(qmui_showPrincipalLines), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    if (qmui_showPrincipalLines && !self.qmuilb_principalLineLayer) {
        self.qmuilb_principalLineLayer = [CAShapeLayer layer];
        [self.qmuilb_principalLineLayer qmui_removeDefaultAnimations];
        self.qmuilb_principalLineLayer.strokeColor = (self.qmui_principalLineColor ?: UIColorTestRed).CGColor;
        self.qmuilb_principalLineLayer.lineWidth = PixelOne;
        [self.layer addSublayer:self.qmuilb_principalLineLayer];
        
        if (!self.qmui_layoutSubviewsBlock) {
            self.qmui_layoutSubviewsBlock = ^(UILabel * _Nonnull label) {
                if (!label.qmuilb_principalLineLayer || label.qmuilb_principalLineLayer.hidden)  return;
                
                label.qmuilb_principalLineLayer.frame  = label.bounds;
                
                NSRange range = NSMakeRange(0, label.attributedText.length);
                CGFloat baselineOffset = [[label.attributedText attribute:NSBaselineOffsetAttributeName atIndex:0 effectiveRange:&range] doubleValue];
                CGFloat lineOffset = baselineOffset * 2;
                UIFont *font = label.font;
                CGFloat maxX = CGRectGetWidth(label.bounds);
                CGFloat maxY = CGRectGetHeight(label.bounds);
                CGFloat descenderY = maxY + font.descender - lineOffset;
                CGFloat xHeightY = maxY - (font.xHeight - font.descender) - lineOffset;
                CGFloat capHeightY = maxY - (font.capHeight - font.descender) - lineOffset;
                CGFloat lineHeightY = maxY - font.lineHeight - lineOffset;
                
                void (^addLineAtY)(UIBezierPath *, CGFloat) = ^void(UIBezierPath *p, CGFloat y) {
                    CGFloat offset = PixelOne / 2;
                    y = flat(y) - offset;
                    [p moveToPoint:CGPointMake(0, y)];
                    [p addLineToPoint:CGPointMake(maxX, y)];
                };
                UIBezierPath *path = [UIBezierPath bezierPath];
                addLineAtY(path, descenderY);
                addLineAtY(path, xHeightY);
                addLineAtY(path, capHeightY);
                addLineAtY(path, lineHeightY);
                label.qmuilb_principalLineLayer.path = path.CGPath;
            };
        }
    }
    self.qmuilb_principalLineLayer.hidden = !qmui_showPrincipalLines;
}

- (BOOL)qmui_showPrincipalLines {
    return [((NSNumber *)objc_getAssociatedObject(self, &kAssociatedObjectKey_showPrincipalLines)) boolValue];
}

@end
