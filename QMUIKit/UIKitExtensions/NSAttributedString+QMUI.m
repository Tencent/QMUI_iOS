/*****
 * Tencent is pleased to support the open source community by making QMUI_iOS available.
 * Copyright (C) 2016-2019 THL A29 Limited, a Tencent company. All rights reserved.
 * Licensed under the MIT License (the "License"); you may not use this file except in compliance with the License. You may obtain a copy of the License at
 * http://opensource.org/licenses/MIT
 * Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.
 *****/

//
//  NSAttributedString+QMUI.m
//  qmui
//
//  Created by QMUI Team on 16/9/23.
//

#import "NSAttributedString+QMUI.h"
#import "QMUICore.h"
#import "NSString+QMUI.h"

@implementation NSAttributedString (QMUI)

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        // 类簇对不同的init方法对应不同的私有class，所以要用实例来得到真正的class
        ExchangeImplementations([[[NSAttributedString alloc] initWithString:@""] class], @selector(initWithString:), @selector(qmuiattr_initWithString:));
        ExchangeImplementations([[[NSAttributedString alloc] initWithString:@"" attributes:nil] class], @selector(initWithString:attributes:), @selector(qmuiattr_initWithString:attributes:));
    });
}

- (instancetype)qmuiattr_initWithString:(NSString *)str {
    str = str ?: @"";
    return [self qmuiattr_initWithString:str];
}

- (instancetype)qmuiattr_initWithString:(NSString *)str attributes:(NSDictionary<NSString *,id> *)attrs {
    str = str ?: @"";
    return [self qmuiattr_initWithString:str attributes:attrs];
}

- (NSUInteger)qmui_lengthWhenCountingNonASCIICharacterAsTwo {
    return self.string.qmui_lengthWhenCountingNonASCIICharacterAsTwo;
}

+ (instancetype)qmui_attributedStringWithImage:(UIImage *)image {
    return [self qmui_attributedStringWithImage:image baselineOffset:0 leftMargin:0 rightMargin:0];
}

+ (instancetype)qmui_attributedStringWithImage:(UIImage *)image baselineOffset:(CGFloat)offset leftMargin:(CGFloat)leftMargin rightMargin:(CGFloat)rightMargin {
    if (!image) {
        return nil;
    }
    NSTextAttachment *attachment = [[NSTextAttachment alloc] init];
    attachment.image = image;
    attachment.bounds = CGRectMake(0, 0, image.size.width, image.size.height);
    NSMutableAttributedString *string = [[NSAttributedString attributedStringWithAttachment:attachment] mutableCopy];
    [string addAttribute:NSBaselineOffsetAttributeName value:@(offset) range:NSMakeRange(0, string.length)];
    if (leftMargin > 0) {
        [string insertAttributedString:[self qmui_attributedStringWithFixedSpace:leftMargin] atIndex:0];
    }
    if (rightMargin > 0) {
        [string appendAttributedString:[self qmui_attributedStringWithFixedSpace:rightMargin]];
    }
    return string;
}

+ (instancetype)qmui_attributedStringWithFixedSpace:(CGFloat)width {
    UIGraphicsBeginImageContext(CGSizeMake(width, 1));
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return [self qmui_attributedStringWithImage:image];
}

@end

@implementation NSMutableAttributedString (QMUI)

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        // 类簇对不同的init方法对应不同的私有class，所以要用实例来得到真正的class
        ExchangeImplementations([[[NSMutableAttributedString alloc] initWithString:@""] class], @selector(initWithString:), @selector(qmuimutableattr_initWithString:));
        ExchangeImplementations([[[NSMutableAttributedString alloc] initWithString:@"" attributes:nil] class], @selector(initWithString:attributes:), @selector(qmuimutableattr_initWithString:attributes:));
    });
}

- (instancetype)qmuimutableattr_initWithString:(NSString *)str {
    str = str ?: @"";
    return [self qmuimutableattr_initWithString:str];
}

- (instancetype)qmuimutableattr_initWithString:(NSString *)str attributes:(NSDictionary<NSString *,id> *)attrs {
    str = str ?: @"";
    return [self qmuimutableattr_initWithString:str attributes:attrs];
}

@end
