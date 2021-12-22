/**
 * Tencent is pleased to support the open source community by making QMUI_iOS available.
 * Copyright (C) 2016-2021 THL A29 Limited, a Tencent company. All rights reserved.
 * Licensed under the MIT License (the "License"); you may not use this file except in compliance with the License. You may obtain a copy of the License at
 * http://opensource.org/licenses/MIT
 * Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.
 */

//
//  NSAttributedString+QMUI.m
//  qmui
//
//  Created by QMUI Team on 16/9/23.
//

#import "NSAttributedString+QMUI.h"
#import "QMUICore.h"
#import "NSString+QMUI.h"
#import "UIImage+QMUI.h"
#import "QMUIStringPrivate.h"

NSAttributedStringKey const QMUIImageMarginsAttributeName = @"QMUI_attributedImageMargins";
NSString *const kQMUIImageOriginalAttributedStringKey = @"QMUI_attributedString";

@implementation NSAttributedString (QMUI)

+ (instancetype)qmui_attributedStringWithImage:(UIImage *)image {
    return [self qmui_attributedStringWithImage:image alignByAttributes:image.qmui_stringAttributes];
}

+ (instancetype)qmui_attributedStringWithImage:(UIImage *)image alignByAttributes:(NSDictionary<NSAttributedStringKey,id> *)attributes {
    CGFloat marginTop = [QMUIHelper topMarginForAttributedImage:image attributes:attributes];
    return [self qmui_attributedStringWithImage:image margins:UIEdgeInsetsMake(marginTop, 0, 0, 0)];
}

+ (instancetype)qmui_attributedStringWithImage:(UIImage *)image baselineOffset:(CGFloat)offset leftMargin:(CGFloat)leftMargin rightMargin:(CGFloat)rightMargin {
    return [self qmui_attributedStringWithImage:image margins:UIEdgeInsetsMake(-offset, leftMargin, 0, rightMargin)];
}

+ (instancetype)qmui_attributedStringWithImage:(UIImage *)image margins:(UIEdgeInsets)margins {
    if (!image) {
        return nil;
    }
    NSTextAttachment *attachment = [[NSTextAttachment alloc] init];
    attachment.image = image;
    attachment.bounds = CGRectMake(0, -margins.top, image.size.width, image.size.height);
    NSMutableAttributedString *string = [[NSAttributedString attributedStringWithAttachment:attachment] mutableCopy];
    if (margins.left > 0) {
        [string insertAttributedString:[self qmui_attributedStringWithFixedSpace:margins.left] atIndex:0];
    }
    if (margins.right > 0) {
        [string appendAttributedString:[self qmui_attributedStringWithFixedSpace:margins.right]];
    }
    if (image.qmui_stringAttributes) {
        [string addAttributes:image.qmui_stringAttributes range:NSMakeRange(0, string.length)];
    }
    [string addAttribute:QMUIImageMarginsAttributeName value:[NSValue valueWithUIEdgeInsets:margins] range:NSMakeRange(0, string.length)];
    return string;
}

+ (instancetype)qmui_attributedStringWithFixedSpace:(CGFloat)width {
    UIGraphicsBeginImageContext(CGSizeMake(width, 1));
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return [self qmui_attributedStringWithImage:image];
}

#pragma mark - <QMUIStringProtocol>

- (NSUInteger)qmui_lengthWhenCountingNonASCIICharacterAsTwo {
    return self.string.qmui_lengthWhenCountingNonASCIICharacterAsTwo;
}

- (instancetype)qmui_substringAvoidBreakingUpCharacterSequencesFromIndex:(NSUInteger)index lessValue:(BOOL)lessValue countingNonASCIICharacterAsTwo:(BOOL)countingNonASCIICharacterAsTwo {
    return [QMUIStringPrivate substring:self avoidBreakingUpCharacterSequencesFromIndex:index lessValue:lessValue countingNonASCIICharacterAsTwo:countingNonASCIICharacterAsTwo];
}

- (instancetype)qmui_substringAvoidBreakingUpCharacterSequencesFromIndex:(NSUInteger)index {
    return [self qmui_substringAvoidBreakingUpCharacterSequencesFromIndex:index lessValue:YES countingNonASCIICharacterAsTwo:NO];
}

- (instancetype)qmui_substringAvoidBreakingUpCharacterSequencesToIndex:(NSUInteger)index lessValue:(BOOL)lessValue countingNonASCIICharacterAsTwo:(BOOL)countingNonASCIICharacterAsTwo {
    return [QMUIStringPrivate substring:self avoidBreakingUpCharacterSequencesToIndex:index lessValue:lessValue countingNonASCIICharacterAsTwo:countingNonASCIICharacterAsTwo];
}

- (instancetype)qmui_substringAvoidBreakingUpCharacterSequencesToIndex:(NSUInteger)index {
    return [self qmui_substringAvoidBreakingUpCharacterSequencesToIndex:index lessValue:YES countingNonASCIICharacterAsTwo:NO];
}

- (instancetype)qmui_substringAvoidBreakingUpCharacterSequencesWithRange:(NSRange)range lessValue:(BOOL)lessValue countingNonASCIICharacterAsTwo:(BOOL)countingNonASCIICharacterAsTwo {
    return [QMUIStringPrivate substring:self avoidBreakingUpCharacterSequencesWithRange:range lessValue:lessValue countingNonASCIICharacterAsTwo:countingNonASCIICharacterAsTwo];
}

- (instancetype)qmui_substringAvoidBreakingUpCharacterSequencesWithRange:(NSRange)range {
    return [self qmui_substringAvoidBreakingUpCharacterSequencesWithRange:range lessValue:YES countingNonASCIICharacterAsTwo:NO];
}

- (instancetype)qmui_stringByRemoveCharacterAtIndex:(NSUInteger)index {
    return [QMUIStringPrivate string:self avoidBreakingUpCharacterSequencesByRemoveCharacterAtIndex:index];
}

- (instancetype)qmui_stringByRemoveLastCharacter {
    return [self qmui_stringByRemoveCharacterAtIndex:self.length - 1];
}

@end

@implementation UIImage (QMUI_NSAttributedStringSupports)

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        OverrideImplementation([UIImage class], @selector(copyWithZone:), ^id(__unsafe_unretained Class originClass, SEL originCMD, IMP (^originalIMPProvider)(void)) {
            return ^id (UIImage *selfObject, NSZone *firstArgv) {
                
                // call super
                id (*originSelectorIMP)(id, SEL, NSZone *);
                originSelectorIMP = (id (*)(id, SEL, NSZone *))originalIMPProvider();
                id result = originSelectorIMP(selfObject, originCMD, firstArgv);
                
                if ([result isKindOfClass:UIImage.class]) {
                    id obj = [result qmui_getBoundObjectForKey:kQMUIImageOriginalAttributedStringKey];
                    if (obj) {
                        [result qmui_bindObjectWeakly:obj forKey:kQMUIImageOriginalAttributedStringKey];
                    }
                }
                return result;
            };
        });
    });
}

+ (UIImage *)qmui_imageWithAttributedString:(NSAttributedString *)attributedString {
    CGSize stringSize = [attributedString boundingRectWithSize:CGSizeMax options:NSStringDrawingUsesLineFragmentOrigin context:nil].size;
    stringSize = CGSizeCeil(stringSize);
    UIImage *image = [UIImage qmui_imageWithSize:stringSize opaque:NO scale:0 actions:^(CGContextRef contextRef) {
        [attributedString drawInRect:CGRectMakeWithSize(stringSize)];
    }];
    [image qmui_bindObject:attributedString.copy forKey:kQMUIImageOriginalAttributedStringKey];
    return image;
}

- (NSAttributedString *)qmui_attributedString {
    return [self qmui_getBoundObjectForKey:kQMUIImageOriginalAttributedStringKey];
}

- (NSDictionary<NSAttributedStringKey,id> *)qmui_stringAttributes {
    NSAttributedString *string = self.qmui_attributedString;
    NSRange range = NSMakeRange(0, string.length);
    return [[self qmui_attributedString] attributesAtIndex:0 effectiveRange:&range];
}

@end

@implementation QMUIHelper (NSAttributedStringSupports)

+ (CGFloat)topMarginForAttributedImage:(UIImage *)image attributes:(NSDictionary<NSAttributedStringKey,id> *)attributes {
    if (!image || !attributes) return 0;
    
    CGFloat marginTop = 0;
    CGFloat fontCapHeight = ({
        UIFont *font = attributes[NSFontAttributeName];
        font ? font.capHeight : 0;
    });
    CGFloat fontLineHeight = ({
        UIFont *font = attributes[NSFontAttributeName];
        font ? font.lineHeight : 0;
    });
    CGFloat lineHeight = ({
        NSParagraphStyle *paragraphStyle = attributes[NSParagraphStyleAttributeName];
        paragraphStyle ? paragraphStyle.maximumLineHeight : 0;
    });
    CGFloat imageHeight = image.size.height;
    if (fontCapHeight) {
        marginTop = -(fontCapHeight - imageHeight) / 2;
    }
    if (fontLineHeight && lineHeight) {
        marginTop -= (lineHeight - fontLineHeight) / 2;
    }
    return marginTop;
}

@end
