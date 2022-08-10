/**
 * Tencent is pleased to support the open source community by making QMUI_iOS available.
 * Copyright (C) 2016-2021 THL A29 Limited, a Tencent company. All rights reserved.
 * Licensed under the MIT License (the "License"); you may not use this file except in compliance with the License. You may obtain a copy of the License at
 * http://opensource.org/licenses/MIT
 * Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.
 */

//
//  NSString+QMUI.m
//  qmui
//
//  Created by QMUI Team on 15/7/20.
//

#import "NSString+QMUI.h"
#import <CommonCrypto/CommonDigest.h>
#import "QMUICore.h"
#import "NSArray+QMUI.h"
#import "NSCharacterSet+QMUI.h"
#import "QMUIStringPrivate.h"

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
    NSMutableCharacterSet * characterSet = [NSMutableCharacterSet whitespaceAndNewlineCharacterSet];
    [characterSet addCharactersInString:@"\0"];
    return [self stringByTrimmingCharactersInSet:characterSet];
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
    if (self.length) {
        NSRange range = [self rangeOfComposedCharacterSequenceAtIndex:0];
        if (range.length > 1) {
            return self;// 说明这个字符没法大写
        }
        return [NSString stringWithFormat:@"%@%@", [self substringToIndex:1].uppercaseString, [self substringFromIndex:1]].copy;
    }
    return nil;
}

+ (NSString *)hexLetterStringWithInteger:(NSInteger)integer {
    QMUIAssert(integer < 16, @"NSString (QMUI)", @"%s 参数仅接受小于16的值，当前传入的是 %@", __func__, @(integer));
    
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

- (NSString *)qmui_stringMatchedByPattern:(NSString *)pattern {
    return [self qmui_stringMatchedByPattern:pattern groupIndex:0];
}

- (NSString *)qmui_stringMatchedByPattern:(NSString *)pattern groupIndex:(NSInteger)index {
    if (pattern.length <= 0 || index < 0) return nil;
    
    NSRegularExpression *regx = [NSRegularExpression regularExpressionWithPattern:pattern options:NSRegularExpressionCaseInsensitive error:nil];
    NSTextCheckingResult *result = [regx firstMatchInString:self options:NSMatchingReportCompletion range:NSMakeRange(0, self.length)];
    if (result.numberOfRanges > index) {
        NSRange range = [result rangeAtIndex:index];
        return [self substringWithRange:range];
    }
    return nil;
}

- (NSString *)qmui_stringMatchedByPattern:(NSString *)pattern groupName:(NSString *)name {
    if (pattern.length <= 0) return nil;
    
    NSRegularExpression *regx = [NSRegularExpression regularExpressionWithPattern:pattern options:NSRegularExpressionCaseInsensitive error:nil];
    NSTextCheckingResult *result = [regx firstMatchInString:self options:NSMatchingReportCompletion range:NSMakeRange(0, self.length)];
    if (result.numberOfRanges > 1) {
        NSRange range = [result rangeWithName:name];
        QMUIAssert(range.location != NSNotFound, @"NSString (QMUI)", @"%s, 不存在名为 %@ 的 group name", __func__, name);
        if (range.location != NSNotFound) {
            return [self substringWithRange:range];
        }
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

#pragma mark - <QMUIStringProtocol>

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

@implementation NSString (QMUI_StringFormat)

+ (NSString *)qmui_stringWithNSInteger:(NSInteger)integerValue {
    return @(integerValue).stringValue;
}

+ (NSString *)qmui_stringWithCGFloat:(CGFloat)floatValue {
    return [NSString qmui_stringWithCGFloat:floatValue decimal:2];
}

+ (NSString *)qmui_stringWithCGFloat:(CGFloat)floatValue decimal:(NSUInteger)decimal {
    NSString *formatString = [NSString stringWithFormat:@"%%.%@f", @(decimal)];
    return [NSString stringWithFormat:formatString, floatValue];
}

@end
