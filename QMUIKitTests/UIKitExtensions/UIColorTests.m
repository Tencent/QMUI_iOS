/*****
 * Tencent is pleased to support the open source community by making QMUI_iOS available.
 * Copyright (C) 2016-2019 THL A29 Limited, a Tencent company. All rights reserved.
 * Licensed under the MIT License (the "License"); you may not use this file except in compliance with the License. You may obtain a copy of the License at
 * http://opensource.org/licenses/MIT
 * Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.
 *****/
//
//  UIColorTests.m
//  QMUIKitTests
//
//  Created by MoLice on 2019/M/15.
//

#import <XCTest/XCTest.h>
#import <QMUIKit/QMUIKit.h>

@interface UIColorTests : XCTestCase

@end

@implementation UIColorTests

- (void)testColorWithHexString {
    XCTAssertTrue([UIColor qmui_colorWithHexString:@"#f0f"]);
    XCTAssertTrue([UIColor qmui_colorWithHexString:@"#F0F"]);
    XCTAssertTrue([UIColor qmui_colorWithHexString:@"#0f0f"]);
    XCTAssertTrue([UIColor qmui_colorWithHexString:@"#ff00ff"]);
    XCTAssertTrue([UIColor qmui_colorWithHexString:@"#00ff00ff"]);
    XCTAssertTrue([UIColor qmui_colorWithHexString:@"00ff00ff"]);
    XCTAssertFalse([UIColor qmui_colorWithHexString:@""]);
    XCTAssertFalse([UIColor qmui_colorWithHexString:nil]);
    XCTAssertThrows([UIColor qmui_colorWithHexString:@"#f0f0f"]);
}

- (void)testHexString {
    // 不同颜色空间的 UIColor 对象
    XCTAssertTrue([UIColor colorWithRed:1 green:.5 blue:0 alpha:1].qmui_hexString);
    XCTAssertTrue([UIColor colorWithHue:1 saturation:1 brightness:1 alpha:1].qmui_hexString);
    XCTAssertTrue([UIColor whiteColor].qmui_hexString);
    
    UIColor *nilColor = nil;
    XCTAssertFalse(nilColor.qmui_hexString);
    
    NSString *hexString = @"#00ff00ff";
    XCTAssertEqualObjects(hexString, [UIColor qmui_colorWithHexString:hexString].qmui_hexString);
}

- (void)testRGBA {
    // 不同颜色空间的 UIColor 对象
    XCTAssertEqual([UIColor redColor].qmui_red, 1);
    XCTAssertEqual([UIColor greenColor].qmui_green, 1);
    XCTAssertEqual([UIColor blueColor].qmui_blue, 1);
    XCTAssertEqual([UIColor blueColor].qmui_alpha, 1);
    
    UIColor *graySpaceColor = [UIColor whiteColor];
    XCTAssertEqual(graySpaceColor.qmui_red, 1);
    XCTAssertEqual(graySpaceColor.qmui_green, 1);
    XCTAssertEqual(graySpaceColor.qmui_blue, 1);
    XCTAssertEqual(graySpaceColor.qmui_alpha, 1);
    
    UIColor *hsbSpaceColor = [UIColor colorWithHue:1 saturation:1 brightness:1 alpha:1];// 纯红色
    XCTAssertEqual(hsbSpaceColor.qmui_red, 1);
    XCTAssertEqual(hsbSpaceColor.qmui_green, 0);
    XCTAssertEqual(hsbSpaceColor.qmui_blue, 0);
    XCTAssertEqual(hsbSpaceColor.qmui_alpha, 1);
    
    UIColor *zeroColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0];
    XCTAssertEqual(zeroColor.qmui_red, 0);
    XCTAssertEqual(zeroColor.qmui_green, 0);
    XCTAssertEqual(zeroColor.qmui_blue, 0);
    XCTAssertEqual(zeroColor.qmui_alpha, 0);
    
    CGFloat value = .25;
    UIColor *nonZeroColor = [UIColor colorWithRed:value green:value blue:value alpha:value];
    XCTAssertEqual(nonZeroColor.qmui_red, value);
    XCTAssertEqual(nonZeroColor.qmui_green, value);
    XCTAssertEqual(nonZeroColor.qmui_blue, value);
    XCTAssertEqual(nonZeroColor.qmui_alpha, value);
    
    UIColor *nilColor = nil;
    XCTAssertEqual(nilColor.qmui_red, 0);
    XCTAssertEqual(nilColor.qmui_green, 0);
    XCTAssertEqual(nilColor.qmui_blue, 0);
    XCTAssertEqual(nilColor.qmui_alpha, 0);
}

- (void)testHSB {
    UIColor *zeroHSBColor = [UIColor colorWithHue:0 saturation:0 brightness:0 alpha:0];
    XCTAssertTrue(zeroHSBColor.qmui_hue == 0 || zeroHSBColor.qmui_hue == 1);
    XCTAssertEqual(zeroHSBColor.qmui_saturation, 0);
    XCTAssertEqual(zeroHSBColor.qmui_brightness, 0);
    XCTAssertEqual(zeroHSBColor.qmui_alpha, 0);
    
    UIColor *nonZeroHSBColor = [UIColor colorWithHue:1 saturation:1 brightness:1 alpha:1];
    XCTAssertTrue(nonZeroHSBColor.qmui_hue == 0 || nonZeroHSBColor.qmui_hue == 1);
    XCTAssertEqual(nonZeroHSBColor.qmui_saturation, 1);
    XCTAssertEqual(nonZeroHSBColor.qmui_brightness, 1);
    XCTAssertEqual(nonZeroHSBColor.qmui_alpha, 1);
    
    UIColor *rgbSpaceColor = [UIColor colorWithRed:1 green:0 blue:0 alpha:1];
    XCTAssertTrue(rgbSpaceColor.qmui_hue == 0 || nonZeroHSBColor.qmui_hue == 1);
    XCTAssertEqual(rgbSpaceColor.qmui_saturation, 1);
    XCTAssertEqual(rgbSpaceColor.qmui_brightness, 1);
    XCTAssertEqual(rgbSpaceColor.qmui_alpha, 1);
    
    UIColor *graySpaceColor = [UIColor whiteColor];
    XCTAssertTrue(graySpaceColor.qmui_hue == 0 || nonZeroHSBColor.qmui_hue == 1);
    XCTAssertEqual(graySpaceColor.qmui_saturation, 0);
    XCTAssertEqual(graySpaceColor.qmui_brightness, 1);
    XCTAssertEqual(graySpaceColor.qmui_alpha, 1);
    
    UIColor *nilColor = nil;
    XCTAssertEqual(nilColor.qmui_hue, 0);
    XCTAssertEqual(nilColor.qmui_saturation, 0);
    XCTAssertEqual(nilColor.qmui_brightness, 0);
    XCTAssertEqual(nilColor.qmui_alpha, 0);
}

- (void)testColorWithoutAlpha {
    UIColor *rgbSpaceColor = [UIColor colorWithRed:1 green:0 blue:0 alpha:.5];
    UIColor *rgbSpaceWithoutAlphaColor = rgbSpaceColor.qmui_colorWithoutAlpha;
    XCTAssertTrue(rgbSpaceColor.qmui_red == rgbSpaceWithoutAlphaColor.qmui_red);
    XCTAssertTrue(rgbSpaceColor.qmui_green == rgbSpaceWithoutAlphaColor.qmui_green);
    XCTAssertTrue(rgbSpaceColor.qmui_blue == rgbSpaceWithoutAlphaColor.qmui_blue);
    XCTAssertFalse(rgbSpaceColor.qmui_alpha == rgbSpaceWithoutAlphaColor.qmui_alpha);
    
    UIColor *graySpaceColor = [[UIColor whiteColor] colorWithAlphaComponent:.5];
    UIColor *graySpaceWithoutAlphaColor = graySpaceColor.qmui_colorWithoutAlpha;
    XCTAssertTrue(graySpaceColor.qmui_red == graySpaceWithoutAlphaColor.qmui_red);
    XCTAssertTrue(graySpaceColor.qmui_green == graySpaceWithoutAlphaColor.qmui_green);
    XCTAssertTrue(graySpaceColor.qmui_blue == graySpaceWithoutAlphaColor.qmui_blue);
    XCTAssertFalse(graySpaceColor.qmui_alpha == graySpaceWithoutAlphaColor.qmui_alpha);
    
    UIColor *nilColor = nil;
    XCTAssertFalse(nilColor.qmui_colorWithoutAlpha);
}

- (void)testColorIsDark {
    XCTAssertTrue([UIColor blackColor].qmui_colorIsDark);
    XCTAssertTrue([UIColor redColor].qmui_colorIsDark);
    XCTAssertFalse([UIColor whiteColor].qmui_colorIsDark);
}

- (void)testInverseColor {
    UIColor *targetColor = [UIColor colorWithRed:1 green:0 blue:0 alpha:.5];
    UIColor *inverseColor = [UIColor colorWithRed:0 green:1 blue:1 alpha:.5];
    XCTAssertEqualObjects(targetColor.qmui_inverseColor, inverseColor);
}

- (void)testSystemTintColor {
    XCTAssertTrue([UIView new].tintColor.qmui_isSystemTintColor);
    XCTAssertFalse([UIColor redColor].qmui_isSystemTintColor);
}

- (void)testColorWithBackendAndFront {
    // 前景色不透明则叠加后就是前景色
    XCTAssertEqualObjects([UIColor qmui_colorWithBackendColor:[UIColor redColor] frontColor:[UIColor blackColor]], [UIColor colorWithRed:0 green:0 blue:0 alpha:1]);
    
    // 前景色半透明则叠加后与前景色不同
    XCTAssertNotEqualObjects([UIColor qmui_colorWithBackendColor:[UIColor redColor] frontColor:[[UIColor blackColor] colorWithAlphaComponent:.5]], [UIColor colorWithRed:0 green:0 blue:0 alpha:1]);
    
    // 前景色全透明则叠加后与背景色相同
    XCTAssertEqualObjects([UIColor qmui_colorWithBackendColor:[UIColor redColor] frontColor:[UIColor clearColor]], [UIColor colorWithRed:1 green:0 blue:0 alpha:1]);
    
    // 背景色全透明则叠加后就是前景色
    XCTAssertEqualObjects([UIColor qmui_colorWithBackendColor:[UIColor clearColor] frontColor:[UIColor redColor]], [UIColor colorWithRed:1 green:0 blue:0 alpha:1]);
}

- (void)testColorFromTo {
    XCTAssertEqualObjects([UIColor qmui_colorFromColor:[UIColor blackColor] toColor:[[UIColor blackColor] colorWithAlphaComponent:0] progress:.5], [UIColor colorWithRed:0 green:0 blue:0 alpha:.5]);
}

- (void)testRadomColor {
    XCTAssertNotEqualObjects([UIColor qmui_randomColor], [UIColor qmui_randomColor]);
}

@end
