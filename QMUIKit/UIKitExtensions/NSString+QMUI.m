/*****
 * Tencent is pleased to support the open source community by making QMUI_iOS available.
 * Copyright (C) 2016-2019 THL A29 Limited, a Tencent company. All rights reserved.
 * Licensed under the MIT License (the "License"); you may not use this file except in compliance with the License. You may obtain a copy of the License at
 * http://opensource.org/licenses/MIT
 * Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.
 *****/

//
//  NSString+QMUI.m
//  qmui
//
//  Created by QMUI Team on 15/7/20.
//

#import "NSString+QMUI.h"
#import <CommonCrypto/CommonDigest.h>
#import "NSArray+QMUI.h"
#import "NSCharacterSet+QMUI.h"
#import <objc/runtime.h>

@implementation NSString (QMUI)

- (NSArray<NSString *> *)qmui_toArray {
    if (!self.length) {
        return nil;
    }
    
    NSMutableArray<NSString *> *array = [[NSMutableArray alloc] init];
    for (NSInteger i = 0; i < self.length; i++) {
        NSString *stringItem = [self substringWithRange:NSMakeRange(i, 1)];
        [array addObject:stringItem];
    }
    return [array copy];
}

- (NSArray<NSString *> *)qmui_toTrimmedArray {
    return [[self qmui_toArray] qmui_filterWithBlock:^BOOL(NSString *item) {
        return item.qmui_trim.length > 0;
    }];
}

- (NSString *)qmui_trim {
    return [self stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
}

- (NSString *)qmui_trimAllWhiteSpace {
    return [self stringByReplacingOccurrencesOfString:@"\\s" withString:@"" options:NSRegularExpressionSearch range:NSMakeRange(0, self.length)];
}

- (NSString *)qmui_trimLineBreakCharacter {
    return [self stringByReplacingOccurrencesOfString:@"[\r\n]" withString:@" " options:NSRegularExpressionSearch range:NSMakeRange(0, self.length)];
}

- (NSString *)qmui_md5 {
    const char *cStr = [self UTF8String];
    unsigned char result[CC_MD5_DIGEST_LENGTH];
    CC_MD5(cStr, (CC_LONG)strlen(cStr), result);
    return [NSString stringWithFormat:
            @"%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x",
            result[0], result[1], result[2], result[3],
            result[4], result[5], result[6], result[7],
            result[8], result[9], result[10], result[11],
            result[12], result[13], result[14], result[15]];
}

- (NSString *)qmui_stringByEncodingUserInputQuery {
    return [self stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet qmui_URLUserInputQueryAllowedCharacterSet]];
}

- (NSString *)qmui_capitalizedString {
    if (self.length)
        return [NSString stringWithFormat:@"%@%@", [self substringToIndex:1].uppercaseString, [self substringFromIndex:1]].copy;
    return nil;
}

+ (NSString *)hexLetterStringWithInteger:(NSInteger)integer {
    NSAssert(integer < 16, @"要转换的数必须是16进制里的个位数，也即小于16，但你传给我是%@", @(integer));
    
    NSString *letter = nil;
    switch (integer) {
        case 10:
            letter = @"A";
            break;
        case 11:
            letter = @"B";
            break;
        case 12:
            letter = @"C";
            break;
        case 13:
            letter = @"D";
            break;
        case 14:
            letter = @"E";
            break;
        case 15:
            letter = @"F";
            break;
        default:
            letter = [[NSString alloc]initWithFormat:@"%@", @(integer)];
            break;
    }
    return letter;
}

+ (NSString *)qmui_hexStringWithInteger:(NSInteger)integer {
    NSString *hexString = @"";
    NSInteger remainder = 0;
    for (NSInteger i = 0; i < 9; i++) {
        remainder = integer % 16;
        integer = integer / 16;
        NSString *letter = [self hexLetterStringWithInteger:remainder];
        hexString = [letter stringByAppendingString:hexString];
        if (integer == 0) {
            break;
        }
        
    }
    return hexString;
}

+ (NSString *)qmui_stringByConcat:(id)firstArgv, ... {
    if (firstArgv) {
        NSMutableString *result = [[NSMutableString alloc] initWithFormat:@"%@", firstArgv];
        
        va_list argumentList;
        va_start(argumentList, firstArgv);
        id argument;
        while ((argument = va_arg(argumentList, id))) {
            [result appendFormat:@"%@", argument];
        }
        va_end(argumentList);
        
        return [result copy];
    }
    return nil;
}

+ (NSString *)qmui_timeStringWithMinsAndSecsFromSecs:(double)seconds {
    NSUInteger min = floor(seconds / 60);
    NSUInteger sec = floor(seconds - min * 60);
    return [NSString stringWithFormat:@"%02ld:%02ld", (long)min, (long)sec];
}

- (NSString *)qmui_removeMagicalChar {
    if (self.length == 0) {
        return self;
    }
    
    NSError *error = nil;
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"[\u0300-\u036F]" options:NSRegularExpressionCaseInsensitive error:&error];
    NSString *modifiedString = [regex stringByReplacingMatchesInString:self options:NSMatchingReportProgress range:NSMakeRange(0, self.length) withTemplate:@""];
    return modifiedString;
}

- (NSUInteger)qmui_lengthWhenCountingNonASCIICharacterAsTwo {
    NSUInteger length = 0;
    for (NSUInteger i = 0, l = self.length; i < l; i++) {
        unichar character = [self characterAtIndex:i];
        if (isascii(character)) {
            length += 1;
        } else {
            length += 2;
        }
    }
    return length;
}

- (NSUInteger)transformIndexToDefaultModeWithIndex:(NSUInteger)index {
    CGFloat strlength = 0.f;
    NSUInteger i = 0;
    for (i = 0; i < self.length; i++) {
        unichar character = [self characterAtIndex:i];
        if (isascii(character)) {
            strlength += 1;
        } else {
            strlength += 2;
        }
        if (strlength >= index + 1) return i;
    }
    return 0;
}

- (NSRange)transformRangeToDefaultModeWithRange:(NSRange)range {
    CGFloat strlength = 0.f;
    NSRange resultRange = NSMakeRange(NSNotFound, 0);
    NSUInteger i = 0;
    for (i = 0; i < self.length; i++) {
        unichar character = [self characterAtIndex:i];
        if (isascii(character)) {
            strlength += 1;
        } else {
            strlength += 2;
        }
        if (strlength >= range.location + 1) {
            if (resultRange.location == NSNotFound) {
                resultRange.location = i;
            }
            
            if (range.length > 0 && strlength >= NSMaxRange(range)) {
                resultRange.length = i - resultRange.location + (strlength == NSMaxRange(range) ? 1 : 0);
                return resultRange;
            }
        }
    }
    return resultRange;
}

- (NSString *)qmui_substringAvoidBreakingUpCharacterSequencesFromIndex:(NSUInteger)index lessValue:(BOOL)lessValue countingNonASCIICharacterAsTwo:(BOOL)countingNonASCIICharacterAsTwo {
    index = countingNonASCIICharacterAsTwo ? [self transformIndexToDefaultModeWithIndex:index] : index;
    NSRange range = [self rangeOfComposedCharacterSequenceAtIndex:index];
    return [self substringFromIndex:lessValue ? NSMaxRange(range) : range.location];
}

- (NSString *)qmui_substringAvoidBreakingUpCharacterSequencesFromIndex:(NSUInteger)index {
    return [self qmui_substringAvoidBreakingUpCharacterSequencesFromIndex:index lessValue:YES countingNonASCIICharacterAsTwo:NO];
}

- (NSString *)qmui_substringAvoidBreakingUpCharacterSequencesToIndex:(NSUInteger)index lessValue:(BOOL)lessValue countingNonASCIICharacterAsTwo:(BOOL)countingNonASCIICharacterAsTwo {
    index = countingNonASCIICharacterAsTwo ? [self transformIndexToDefaultModeWithIndex:index] : index;
    NSRange range = [self rangeOfComposedCharacterSequenceAtIndex:index];
    return [self substringToIndex:lessValue ? range.location : NSMaxRange(range)];
}

- (NSString *)qmui_substringAvoidBreakingUpCharacterSequencesToIndex:(NSUInteger)index {
    return [self qmui_substringAvoidBreakingUpCharacterSequencesToIndex:index lessValue:YES countingNonASCIICharacterAsTwo:NO];
}

- (NSString *)qmui_substringAvoidBreakingUpCharacterSequencesWithRange:(NSRange)range lessValue:(BOOL)lessValue countingNonASCIICharacterAsTwo:(BOOL)countingNonASCIICharacterAsTwo {
    range = countingNonASCIICharacterAsTwo ? [self transformRangeToDefaultModeWithRange:range] : range;
    NSRange characterSequencesRange = lessValue ? [self downRoundRangeOfComposedCharacterSequencesForRange:range] : [self rangeOfComposedCharacterSequencesForRange:range];
    NSString *resultString = [self substringWithRange:characterSequencesRange];
    return resultString;
}

- (NSString *)qmui_substringAvoidBreakingUpCharacterSequencesWithRange:(NSRange)range {
    return [self qmui_substringAvoidBreakingUpCharacterSequencesWithRange:range lessValue:YES countingNonASCIICharacterAsTwo:NO];
}

- (NSRange)downRoundRangeOfComposedCharacterSequencesForRange:(NSRange)range {
    if (range.length == 0) {
        return range;
    }
    
    NSRange resultRange = [self rangeOfComposedCharacterSequencesForRange:range];
    if (NSMaxRange(resultRange) > NSMaxRange(range)) {
        return [self downRoundRangeOfComposedCharacterSequencesForRange:NSMakeRange(range.location, range.length - 1)];
    }
    return resultRange;
}

- (NSString *)qmui_stringByRemoveCharacterAtIndex:(NSUInteger)index {
    NSRange rangeForRemove = [self rangeOfComposedCharacterSequenceAtIndex:index];
    NSString *resultString = [self stringByReplacingCharactersInRange:rangeForRemove withString:@""];
    return resultString;
}

- (NSString *)qmui_stringByRemoveLastCharacter {
    return [self qmui_stringByRemoveCharacterAtIndex:self.length - 1];
}

- (NSString *)qmui_stringMatchedByPattern:(NSString *)pattern {
    NSRange range = [self rangeOfString:pattern options:NSRegularExpressionSearch|NSCaseInsensitiveSearch];
    if (range.location != NSNotFound) {
        return [self substringWithRange:range];
    }
    return nil;
}

- (NSString *)qmui_stringByReplacingPattern:(NSString *)pattern withString:(NSString *)replacement {
    NSError *error = nil;
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:pattern options:NSRegularExpressionCaseInsensitive error:&error];
    if (error) {
        return self;
    }
    return [regex stringByReplacingMatchesInString:self options:NSMatchingReportCompletion range:NSMakeRange(0, self.length) withTemplate:replacement];
}

@end

@implementation NSString (QMUI_StringFormat)

+ (instancetype)qmui_stringWithNSInteger:(NSInteger)integerValue {
    return @(integerValue).stringValue;
}

+ (instancetype)qmui_stringWithCGFloat:(CGFloat)floatValue {
    return [NSString qmui_stringWithCGFloat:floatValue decimal:2];
}

+ (instancetype)qmui_stringWithCGFloat:(CGFloat)floatValue decimal:(NSUInteger)decimal {
    NSString *formatString = [NSString stringWithFormat:@"%%.%@f", @(decimal)];
    return [NSString stringWithFormat:formatString, floatValue];
}

@end
