/**
 * Tencent is pleased to support the open source community by making QMUI_iOS available.
 * Copyright (C) 2016-2021 THL A29 Limited, a Tencent company. All rights reserved.
 * Licensed under the MIT License (the "License"); you may not use this file except in compliance with the License. You may obtain a copy of the License at
 * http://opensource.org/licenses/MIT
 * Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.
 */
//
//  QMUIStringPrivate.m
//  QMUIKit
//
//  Created by molice on 2021/11/5.
//

#import "QMUIStringPrivate.h"
#import <CommonCrypto/CommonDigest.h>
#import "QMUICore.h"
#import "NSString+QMUI.h"

@implementation QMUIStringPrivate

+ (NSUInteger)transformIndexToDefaultMode:(NSUInteger)index inString:(NSString *)string {
    CGFloat strlength = 0.f;
    NSUInteger i = 0;
    for (i = 0; i < string.length; i++) {
        unichar character = [string characterAtIndex:i];
        if (isascii(character)) {
            strlength += 1;
        } else {
            strlength += 2;
        }
        if (strlength >= index + 1) return i;
    }
    return 0;
}

+ (NSRange)transformRangeToDefaultMode:(NSRange)range lessValue:(BOOL)lessValue inString:(NSString *)string {
    CGFloat strlength = 0.f;
    NSRange resultRange = NSMakeRange(NSNotFound, 0);
    NSUInteger i = 0;
    for (i = 0; i < string.length; i++) {
        unichar character = [string characterAtIndex:i];
        if (isascii(character)) {
            strlength += 1;
        } else {
            strlength += 2;
        }
        if ((lessValue && isascii(character) && strlength >= range.location + 1)
            || (lessValue && !isascii(character) && strlength > range.location + 1)
            || (!lessValue && strlength >= range.location + 1)) {
            if (resultRange.location == NSNotFound) {
                resultRange.location = i;
            }
            
            if (range.length > 0 && strlength >= NSMaxRange(range)) {
                resultRange.length = i - resultRange.location;
                if (lessValue && (strlength == NSMaxRange(range))) {
                    resultRange.length += 1;// 尽量不包含字符的，只有在精准等于时才+1，否则就不算这最后一个字符
                } else if (!lessValue) {
                    resultRange.length += 1;// 只要是最大能力包含字符的，一进来就+1
                }
                return resultRange;
            }
        }
    }
    return resultRange;
}

+ (NSRange)downRoundRangeOfComposedCharacterSequences:(NSRange)range inString:(NSString *)string {
    if (range.length == 0) {
        return range;
    }
    NSRange result = range;
    NSRange beginRange = [string rangeOfComposedCharacterSequenceAtIndex:range.location];
    result.location = beginRange.location < result.location ? NSMaxRange(beginRange) : result.location;
    NSRange endRange = [string rangeOfComposedCharacterSequenceAtIndex:NSMaxRange(range)];
    result.length = endRange.location < NSMaxRange(range) ? endRange.location - result.location : NSMaxRange(range) - result.location;
    return result;
}

+ (id)substring:(id)aString avoidBreakingUpCharacterSequencesFromIndex:(NSUInteger)index lessValue:(BOOL)lessValue countingNonASCIICharacterAsTwo:(BOOL)countingNonASCIICharacterAsTwo {
    NSAttributedString *attributedString = [aString isKindOfClass:NSAttributedString.class] ? (NSAttributedString *)aString : nil;
    NSString *string = attributedString.string ?: (NSString *)aString;
    NSUInteger length = countingNonASCIICharacterAsTwo ? string.qmui_lengthWhenCountingNonASCIICharacterAsTwo : string.length;
    QMUIAssert(index < length, @"QMUIStringPrivate", @"%s, index %@ out of bounds. string = %@", __func__, @(index), attributedString ?: string);
    if (index >= length) return nil;
    index = countingNonASCIICharacterAsTwo ? [self transformIndexToDefaultMode:index inString:string] : index;// 实际计算都按照系统默认的 length 规则来
    NSRange range = [string rangeOfComposedCharacterSequenceAtIndex:index];
    index = lessValue ? NSMaxRange(range) : range.location;
    if (attributedString) {
        NSAttributedString *resultString = [attributedString attributedSubstringFromRange:NSMakeRange(index, string.length - index)];
        return resultString;
    }
    NSString *resultString = [string substringFromIndex:index];
    return resultString;
}

+ (id)substring:(id)aString avoidBreakingUpCharacterSequencesToIndex:(NSUInteger)index lessValue:(BOOL)lessValue countingNonASCIICharacterAsTwo:(BOOL)countingNonASCIICharacterAsTwo {
    NSAttributedString *attributedString = [aString isKindOfClass:NSAttributedString.class] ? (NSAttributedString *)aString : nil;
    NSString *string = attributedString.string ?: (NSString *)aString;
    NSUInteger length = countingNonASCIICharacterAsTwo ? string.qmui_lengthWhenCountingNonASCIICharacterAsTwo : string.length;
    QMUIAssert(index < length, @"QMUIStringPrivate", @"%s, index %@ out of bounds. string = %@", __func__, @(index), attributedString ?: string);
    if (index == 0 || index > length) return nil;
    index = countingNonASCIICharacterAsTwo ? [self transformIndexToDefaultMode:index inString:string] : index;// 实际计算都按照系统默认的 length 规则来
    NSRange range = [string rangeOfComposedCharacterSequenceAtIndex:index];
    index = lessValue ? range.location : NSMaxRange(range);
    if (attributedString) {
        NSAttributedString *resultString = [attributedString attributedSubstringFromRange:NSMakeRange(0, index)];
        return resultString;
    }
    NSString *resultString = [string substringToIndex:index];
    return resultString;
}

+ (id)substring:(id)aString avoidBreakingUpCharacterSequencesWithRange:(NSRange)range lessValue:(BOOL)lessValue countingNonASCIICharacterAsTwo:(BOOL)countingNonASCIICharacterAsTwo {
    NSAttributedString *attributedString = [aString isKindOfClass:NSAttributedString.class] ? (NSAttributedString *)aString : nil;
    NSString *string = attributedString.string ?: (NSString *)aString;
    NSUInteger length = countingNonASCIICharacterAsTwo ? string.qmui_lengthWhenCountingNonASCIICharacterAsTwo : string.length;
    QMUIAssert(NSMaxRange(range) <= length, @"QMUIStringPrivate", @"%s, range %@ out of bounds. string = %@", __func__, NSStringFromRange(range), attributedString ?: string);
    if (NSMaxRange(range) > length) return nil;
    range = countingNonASCIICharacterAsTwo ? [self transformRangeToDefaultMode:range lessValue:lessValue inString:string] : range;// 实际计算都按照系统默认的 length 规则来
    NSRange characterSequencesRange = lessValue ? [self downRoundRangeOfComposedCharacterSequences:range inString:string] : [string rangeOfComposedCharacterSequencesForRange:range];
    if (attributedString) {
        NSAttributedString *resultString = [attributedString attributedSubstringFromRange:characterSequencesRange];
        return resultString;
    }
    NSString *resultString = [string substringWithRange:characterSequencesRange];
    return resultString;
}

+ (id)string:(id)aString avoidBreakingUpCharacterSequencesByRemoveCharacterAtIndex:(NSUInteger)index {
    NSAttributedString *attributedString = [aString isKindOfClass:NSAttributedString.class] ? (NSAttributedString *)aString : nil;
    NSString *string = attributedString.string ?: (NSString *)aString;
    NSRange rangeForRemove = [string rangeOfComposedCharacterSequenceAtIndex:index];
    if (attributedString) {
        NSMutableAttributedString *resultString = attributedString.mutableCopy;
        [resultString replaceCharactersInRange:rangeForRemove withString:@""];
        return resultString.copy;
    }
    NSString *resultString = [string stringByReplacingCharactersInRange:rangeForRemove withString:@""];
    return resultString;
}

@end
