/**
 * Tencent is pleased to support the open source community by making QMUI_iOS available.
 * Copyright (C) 2016-2021 THL A29 Limited, a Tencent company. All rights reserved.
 * Licensed under the MIT License (the "License"); you may not use this file except in compliance with the License. You may obtain a copy of the License at
 * http://opensource.org/licenses/MIT
 * Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.
 */
//
//  NSStringTests.m
//  QMUIKitTests
//
//  Created by MoLice on 2021/4/1.
//

#import <XCTest/XCTest.h>
#import <QMUIKit/QMUIKit.h>

@interface NSStringTests : XCTestCase

@end

@implementation NSStringTests

- (void)testStringSafety {
    // 系统标注了 string 参数 nonnull，如果传了 nil 会 crash，QMUIStringPrivate 里对 nil 做了保护
    BeginIgnoreClangWarning(-Wnonnull)
    XCTAssertNoThrow([[NSAttributedString alloc] initWithString:nil]);
    XCTAssertNoThrow([[NSAttributedString alloc] initWithString:nil attributes:nil]);
    XCTAssertNoThrow([[NSMutableAttributedString alloc] initWithString:nil]);
    XCTAssertNoThrow([[NSMutableAttributedString alloc] initWithString:nil attributes:nil]);
    EndIgnoreClangWarning
    
    NSString *string = @"A😊B";
    
    XCTAssertNoThrow([string substringFromIndex:0]);
    XCTAssertNoThrow([string substringFromIndex:string.length]); // 系统自身对 length 的参数做了保护，返回空字符串
    XCTAssertThrows([string substringFromIndex:5]); // 越界的识别
    XCTAssertNoThrow([string substringFromIndex:1]);
    XCTAssertThrows([string substringFromIndex:2]); // emoji 中间裁剪的识别
    XCTAssertNoThrow([string substringFromIndex:3]);
    
    XCTAssertNoThrow([string substringToIndex:0]);
    XCTAssertNoThrow([string substringToIndex:string.length]); // toIndex 所在的字符不包含在返回结果里，所以允许传入 string.length 的位置
    XCTAssertThrows([string substringToIndex:string.length + 1]); // 越界的识别
    XCTAssertNoThrow([string substringToIndex:1]);
    XCTAssertThrows([string substringToIndex:2]);// emoji 中间裁剪的识别
    XCTAssertNoThrow([string substringToIndex:3]);
    
    XCTAssertNoThrow([string substringWithRange:NSMakeRange(0, 0)]);
    XCTAssertNoThrow([string substringWithRange:NSMakeRange(string.length, 0)]);
    XCTAssertThrows([string substringWithRange:NSMakeRange(string.length, 1)]); // 越界的识别
    XCTAssertNoThrow([string substringWithRange:NSMakeRange(1, 2)]);
    XCTAssertThrows([string substringWithRange:NSMakeRange(1, 1)]); // emoji 中间裁剪的识别
}

- (void)testStringMatching {
    NSString *string = @"string0.05";
    XCTAssertNil([string qmui_stringMatchedByPattern:@""]);
    XCTAssertNotNil([string qmui_stringMatchedByPattern:@"str"]);
    XCTAssertEqualObjects([string qmui_stringMatchedByPattern:@"[\\d\\.]+"], @"0.05");
    
    XCTAssertNil([string qmui_stringMatchedByPattern:@"str" groupIndex:1]);
    XCTAssertEqualObjects([string qmui_stringMatchedByPattern:@"ing([\\d\\.]+)" groupIndex:1], @"0.05");
    
    XCTAssertNil([string qmui_stringMatchedByPattern:@"str" groupName:@"number"]);
    XCTAssertEqualObjects([string qmui_stringMatchedByPattern:@"ing(?<number>[\\d\\.]+)" groupName:@"number"], @"0.05");
    XCTAssertNil([string qmui_stringMatchedByPattern:@"ing(?<number>[\\d\\.]+)" groupName:@"num"]);
}

- (void)testSubstring1 {
    NSString *text = @"01234567890123456789"; // length = 20, 20
    NSString *zh = @"零一二三四五六七八九"; // length = 10, 20;
    NSString *emoji = @"😊😊😊😊😊😊😊😊😊😊";// length = 20, 20
    
    NSInteger toIndex = 7;
    BOOL lessValue = YES;// 系统的 substring 默认就是 lessValue = YES，也即 toIndex 所在位置的字符是不包含在返回结果里的
    BOOL countingNonASCIICharacterAsTwo = NO;
    
    NSString *text2 = [text qmui_substringAvoidBreakingUpCharacterSequencesToIndex:toIndex lessValue:lessValue countingNonASCIICharacterAsTwo:countingNonASCIICharacterAsTwo];
    XCTAssertEqual(text2.length, toIndex);
    
    NSString *zh2 = [zh qmui_substringAvoidBreakingUpCharacterSequencesToIndex:toIndex lessValue:lessValue countingNonASCIICharacterAsTwo:countingNonASCIICharacterAsTwo];
    XCTAssertEqual(zh2.length, toIndex);
    NSString *zh3 = [zh substringToIndex:toIndex];
    XCTAssertTrue((lessValue && zh2.length == zh3.length) || (!lessValue && zh2.length > zh3.length));
    
    NSString *emoji2 = [emoji qmui_substringAvoidBreakingUpCharacterSequencesToIndex:toIndex lessValue:lessValue countingNonASCIICharacterAsTwo:countingNonASCIICharacterAsTwo];
    NSString *emoji3 = [emoji substringToIndex:[emoji rangeOfComposedCharacterSequenceAtIndex:toIndex].location];
    XCTAssertTrue((lessValue && emoji2.length == emoji3.length) || (!lessValue && emoji2.length > emoji3.length));
}

- (void)testSubstring2 {
    NSString *text = @"01234567890123456789"; // length = 20, 20
    NSString *zh = @"零一二三四五六七八九"; // length = 10, 20;
    NSString *emoji = @"😊😊😊😊😊😊😊😊😊😊";// length = 20, 20
    
    NSInteger toIndex = 14;
    BOOL lessValue = YES;
    BOOL countingNonASCIICharacterAsTwo = YES;
    
    NSString *text2 = [text qmui_substringAvoidBreakingUpCharacterSequencesToIndex:toIndex lessValue:lessValue countingNonASCIICharacterAsTwo:countingNonASCIICharacterAsTwo];
    XCTAssertEqual(text2.length, toIndex);
    
    NSString *zh2 = [zh qmui_substringAvoidBreakingUpCharacterSequencesToIndex:toIndex lessValue:lessValue countingNonASCIICharacterAsTwo:countingNonASCIICharacterAsTwo];
    XCTAssertEqual(zh2.qmui_lengthWhenCountingNonASCIICharacterAsTwo, (toIndex / 2) * 2);
    NSString *zh3 = [zh substringToIndex:toIndex / 2];
    XCTAssertTrue(zh2.length == zh3.length && zh2.qmui_lengthWhenCountingNonASCIICharacterAsTwo == zh3.length * 2);
    
    NSString *emoji2 = [emoji qmui_substringAvoidBreakingUpCharacterSequencesToIndex:toIndex lessValue:lessValue countingNonASCIICharacterAsTwo:countingNonASCIICharacterAsTwo];
    NSString *emoji3 = [emoji substringToIndex:[emoji rangeOfComposedCharacterSequenceAtIndex:toIndex / 2].location];
    XCTAssertTrue((lessValue && emoji2.length == emoji3.length) || (!lessValue && emoji2.length > emoji3.length));
}

- (void)testSubstring3 {
    NSString *text = @"01234567890123456789"; // length = 20, 20
    NSString *zh = @"零一二三四五六七八九"; // length = 10, 20;
    NSString *emoji = @"😊😊😊😊😊😊😊😊😊😊";// length = 20, 20
    
    NSInteger toIndex = 15;
    BOOL lessValue = YES;
    BOOL countingNonASCIICharacterAsTwo = YES;
    
    NSString *text2 = [text qmui_substringAvoidBreakingUpCharacterSequencesToIndex:toIndex lessValue:lessValue countingNonASCIICharacterAsTwo:countingNonASCIICharacterAsTwo];
    XCTAssertEqual(text2.length, toIndex);
    
    NSString *zh2 = [zh qmui_substringAvoidBreakingUpCharacterSequencesToIndex:toIndex lessValue:lessValue countingNonASCIICharacterAsTwo:countingNonASCIICharacterAsTwo];
    XCTAssertEqual(zh2.qmui_lengthWhenCountingNonASCIICharacterAsTwo, (toIndex / 2) * 2);
    NSString *zh3 = [zh substringToIndex:toIndex / 2];
    XCTAssertTrue(zh2.length == zh3.length && zh2.qmui_lengthWhenCountingNonASCIICharacterAsTwo == zh3.length * 2);
    
    NSString *emoji2 = [emoji qmui_substringAvoidBreakingUpCharacterSequencesToIndex:toIndex lessValue:lessValue countingNonASCIICharacterAsTwo:countingNonASCIICharacterAsTwo];
    NSString *emoji3 = [emoji substringToIndex:[emoji rangeOfComposedCharacterSequenceAtIndex:toIndex / 2].location];
    XCTAssertTrue((lessValue && emoji2.length == emoji3.length) || (!lessValue && emoji2.length > emoji3.length));
}

- (void)testSubstring4 {
    NSString *text = @"01234567890123456789"; // length = 20, 20
    NSString *zh = @"零一二三四五六七八九"; // length = 10, 20;
    NSString *emoji = @"😊😊😊😊😊😊😊😊😊😊";// length = 20, 20
    
    NSInteger toIndex = 7;
    BOOL lessValue = NO;
    BOOL countingNonASCIICharacterAsTwo = NO;
    
    NSString *text2 = [text qmui_substringAvoidBreakingUpCharacterSequencesToIndex:toIndex lessValue:lessValue countingNonASCIICharacterAsTwo:countingNonASCIICharacterAsTwo];
    XCTAssertEqual(text2.length, toIndex + 1);
    
    NSString *zh2 = [zh qmui_substringAvoidBreakingUpCharacterSequencesToIndex:toIndex lessValue:lessValue countingNonASCIICharacterAsTwo:countingNonASCIICharacterAsTwo];
    XCTAssertEqual(zh2.length, toIndex + 1);
    NSString *zh3 = [zh substringToIndex:toIndex];
    XCTAssertTrue((lessValue && zh2.length == zh3.length) || (!lessValue && zh2.length > zh3.length));
    
    NSString *emoji2 = [emoji qmui_substringAvoidBreakingUpCharacterSequencesToIndex:toIndex lessValue:lessValue countingNonASCIICharacterAsTwo:countingNonASCIICharacterAsTwo];
    NSString *emoji3 = [emoji substringToIndex:[emoji rangeOfComposedCharacterSequenceAtIndex:toIndex].location];
    XCTAssertTrue((lessValue && emoji2.length == emoji3.length) || (!lessValue && emoji2.length > emoji3.length));
}

- (void)testSubstring5 {
    NSString *text = @"01234567890123456789"; // length = 20, 20
    NSString *zh = @"零一二三四五六七八九"; // length = 10, 20;
    NSString *emoji = @"😊😊😊😊😊😊😊😊😊😊";// length = 20, 20
    
    NSInteger toIndex = 14;
    BOOL lessValue = NO;
    BOOL countingNonASCIICharacterAsTwo = YES;
    
    NSString *text2 = [text qmui_substringAvoidBreakingUpCharacterSequencesToIndex:toIndex lessValue:lessValue countingNonASCIICharacterAsTwo:countingNonASCIICharacterAsTwo];
    XCTAssertEqual(text2.length, toIndex + 1);
    
    NSString *zh2 = [zh qmui_substringAvoidBreakingUpCharacterSequencesToIndex:toIndex lessValue:lessValue countingNonASCIICharacterAsTwo:countingNonASCIICharacterAsTwo];
    XCTAssertEqual(zh2.qmui_lengthWhenCountingNonASCIICharacterAsTwo, (toIndex / 2 + 1) * 2);
    NSString *zh3 = [zh substringToIndex:toIndex / 2];
    XCTAssertTrue(zh2.length == zh3.length + 1);
    XCTAssertEqual(zh2.qmui_lengthWhenCountingNonASCIICharacterAsTwo, (zh3.length + 1) * 2);
    
    NSString *emoji2 = [emoji qmui_substringAvoidBreakingUpCharacterSequencesToIndex:toIndex lessValue:lessValue countingNonASCIICharacterAsTwo:countingNonASCIICharacterAsTwo];
    NSString *emoji3 = [emoji substringToIndex:[emoji rangeOfComposedCharacterSequenceAtIndex:toIndex].location];
    XCTAssertEqual(emoji2.length, emoji3.length / 2 + 1);
}

- (void)testSubstring6 {
    NSString *emoji = @"😡😊😞😊😊😊😊😊😊😊";// length = 20, 20
    NSRange range = NSMakeRange(1, 6);
    BOOL lessValue = YES;
    BOOL countingNonASCIICharacterAsTwo = NO;
    NSString *emoji2 = [emoji qmui_substringAvoidBreakingUpCharacterSequencesWithRange:range lessValue:lessValue countingNonASCIICharacterAsTwo:countingNonASCIICharacterAsTwo];
    XCTAssertEqual(emoji2.length, 4);
    
    lessValue = NO;
    emoji2 = [emoji qmui_substringAvoidBreakingUpCharacterSequencesWithRange:range lessValue:lessValue countingNonASCIICharacterAsTwo:countingNonASCIICharacterAsTwo];
    XCTAssertEqual(emoji2.length, 8);
    
    range = NSMakeRange(0, 6);
    lessValue = YES;
    emoji2 = [emoji qmui_substringAvoidBreakingUpCharacterSequencesWithRange:range lessValue:lessValue countingNonASCIICharacterAsTwo:countingNonASCIICharacterAsTwo];
    XCTAssertEqual(emoji2.length, 6);
    
    lessValue = NO;
    emoji2 = [emoji qmui_substringAvoidBreakingUpCharacterSequencesWithRange:range lessValue:lessValue countingNonASCIICharacterAsTwo:countingNonASCIICharacterAsTwo];
    XCTAssertEqual(emoji2.length, 6);
    
    range = NSMakeRange(0, 1);
    lessValue = YES;
    emoji2 = [emoji qmui_substringAvoidBreakingUpCharacterSequencesWithRange:range lessValue:lessValue countingNonASCIICharacterAsTwo:countingNonASCIICharacterAsTwo];
    XCTAssertEqual(emoji2.length, 0);
    
    lessValue = NO;
    emoji2 = [emoji qmui_substringAvoidBreakingUpCharacterSequencesWithRange:range lessValue:lessValue countingNonASCIICharacterAsTwo:countingNonASCIICharacterAsTwo];
    XCTAssertEqual(emoji2.length, 2);
    
    NSString *text = @"01234567890123456789"; // length = 20, 20
    NSString *zh = @"零一二三四五六七八九"; // length = 10, 20;
    range = NSMakeRange(3, 5);
    lessValue = YES;
    NSString *text2 = [text qmui_substringAvoidBreakingUpCharacterSequencesWithRange:range lessValue:lessValue countingNonASCIICharacterAsTwo:countingNonASCIICharacterAsTwo];
    XCTAssertEqual(text2.length, range.length);
    
    NSString *zh2 = [zh qmui_substringAvoidBreakingUpCharacterSequencesWithRange:range lessValue:lessValue countingNonASCIICharacterAsTwo:countingNonASCIICharacterAsTwo];
    XCTAssertEqual(zh2.length, range.length);
    NSString *zh3 = [zh substringWithRange:range];
    XCTAssertTrue(zh2.length == zh3.length);
    
    countingNonASCIICharacterAsTwo = YES;
    
    text2 = [text qmui_substringAvoidBreakingUpCharacterSequencesWithRange:range lessValue:lessValue countingNonASCIICharacterAsTwo:countingNonASCIICharacterAsTwo];
    XCTAssertEqual(text2.length, range.length);
    
    zh2 = [zh qmui_substringAvoidBreakingUpCharacterSequencesWithRange:range lessValue:lessValue countingNonASCIICharacterAsTwo:countingNonASCIICharacterAsTwo];
    XCTAssertEqual(zh2.length, 2);
    
    range = NSMakeRange(3, 6);
    
    text2 = [text qmui_substringAvoidBreakingUpCharacterSequencesWithRange:range lessValue:lessValue countingNonASCIICharacterAsTwo:countingNonASCIICharacterAsTwo];
    XCTAssertEqual(text2.length, range.length);
    
    zh2 = [zh qmui_substringAvoidBreakingUpCharacterSequencesWithRange:range lessValue:lessValue countingNonASCIICharacterAsTwo:countingNonASCIICharacterAsTwo];
    XCTAssertEqual(zh2.length, 2);
    
    lessValue = NO;
    
    text2 = [text qmui_substringAvoidBreakingUpCharacterSequencesWithRange:range lessValue:lessValue countingNonASCIICharacterAsTwo:countingNonASCIICharacterAsTwo];
    XCTAssertEqual(text2.length, range.length);
    
    zh2 = [zh qmui_substringAvoidBreakingUpCharacterSequencesWithRange:range lessValue:lessValue countingNonASCIICharacterAsTwo:countingNonASCIICharacterAsTwo];
    XCTAssertEqual(zh2.length, 4);
    
    zh = @"零一二三4五六七八九"; // length = 10, 19;
    lessValue = YES;
    
    zh2 = [zh qmui_substringAvoidBreakingUpCharacterSequencesWithRange:range lessValue:lessValue countingNonASCIICharacterAsTwo:countingNonASCIICharacterAsTwo];
    XCTAssertEqual(zh2.length, 3);
}

// NSAttributedString 的简单处理，只要和 NSString 一致就行了
- (void)testAttributedString {
    NSArray<NSAttributedString *> *strs = @[
        [[NSAttributedString alloc] initWithString:@"01234567890123456789"],// length = 20, 20
        [[NSAttributedString alloc] initWithString:@"零一二三四五六七八九"],// length = 10, 20;
        [[NSAttributedString alloc] initWithString:@"😡😊😞😊😊😊😊😊😊😊"],// length = 20, 20
    ];
    
    void (^testingBlock)(NSAttributedString *, BOOL, BOOL) = ^void(NSAttributedString *str, BOOL lessValue, BOOL asTwo) {
        XCTAssertEqualObjects(
                              [str qmui_substringAvoidBreakingUpCharacterSequencesFromIndex:7 lessValue:lessValue countingNonASCIICharacterAsTwo:asTwo].string,
                              [str.string qmui_substringAvoidBreakingUpCharacterSequencesFromIndex:7 lessValue:lessValue countingNonASCIICharacterAsTwo:asTwo]);
        
        XCTAssertEqualObjects(
                              [str qmui_substringAvoidBreakingUpCharacterSequencesToIndex:7 lessValue:lessValue countingNonASCIICharacterAsTwo:asTwo].string,
                              [str.string qmui_substringAvoidBreakingUpCharacterSequencesToIndex:7 lessValue:lessValue countingNonASCIICharacterAsTwo:asTwo]);
        
        XCTAssertEqualObjects(
                              [str qmui_substringAvoidBreakingUpCharacterSequencesWithRange:NSMakeRange(3, 6) lessValue:lessValue countingNonASCIICharacterAsTwo:asTwo].string,
                              [str.string qmui_substringAvoidBreakingUpCharacterSequencesWithRange:NSMakeRange(3, 6) lessValue:lessValue countingNonASCIICharacterAsTwo:asTwo]);
    };
    
    [strs enumerateObjectsUsingBlock:^(NSAttributedString * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        testingBlock(obj, YES, NO);
        testingBlock(obj, YES, YES);
        testingBlock(obj, NO, NO);
        testingBlock(obj, NO, YES);
    }];
}

@end
