/*****
 * Tencent is pleased to support the open source community by making QMUI_iOS available.
 * Copyright (C) 2016-2019 THL A29 Limited, a Tencent company. All rights reserved.
 * Licensed under the MIT License (the "License"); you may not use this file except in compliance with the License. You may obtain a copy of the License at
 * http://opensource.org/licenses/MIT
 * Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.
 *****/
//
//  QMUIThemeTests.m
//  QMUIKitTests
//
//  Created by MoLice on 2019/J/27.
//

#import <XCTest/XCTest.h>
#import <QMUIKit/QMUIKit.h>

@interface QMUIThemeTests : XCTestCase

@end

@implementation QMUIThemeTests

- (void)testUIColorMethods {
    UIColor *color = [UIColor qmui_colorWithThemeProvider:^UIColor * _Nonnull(__kindof QMUIThemeManager * _Nonnull manager, __kindof NSObject<NSCopying> * _Nullable identifier, __kindof NSObject * _Nullable theme) {
        return UIColorWhite;
    }];
    XCTAssertNoThrow([color set]);
    XCTAssertNoThrow([color setFill]);
    XCTAssertNoThrow([color setStroke]);
    
    CGFloat white;
    CGFloat alpha;
    XCTAssertNoThrow([color getWhite:&white alpha:&alpha]);
    XCTAssertTrue(betweenOrEqual(.9, white, 1));// 由于精度问题...先这么写吧
    XCTAssertEqual(alpha, 1);
    
    CGFloat hue;
    CGFloat saturation;
    CGFloat brightness;
    CGFloat alpha2;
    XCTAssertNoThrow([color getHue:&hue saturation:&saturation brightness:&brightness alpha:&alpha2]);
    XCTAssertTrue(hue == 0 || hue == 1);
    XCTAssertTrue(saturation = 1);
    XCTAssertTrue(brightness = 1);
    XCTAssertTrue(alpha2 = 1);
    
    CGFloat red;
    CGFloat green;
    CGFloat blue;
    CGFloat alpha3;
    XCTAssertNoThrow([color getRed:&red green:&green blue:&blue alpha:&alpha3]);
    XCTAssertEqual(red, 1);
    XCTAssertEqual(green, 1);
    XCTAssertEqual(blue, 1);
    XCTAssertEqual(alpha3, 1);
    
    XCTAssertNoThrow([color colorWithAlphaComponent:.5]);
    CGFloat alpha4;
    UIColor *colorWithAlpha = [color colorWithAlphaComponent:.5];
    [colorWithAlpha getRed:nil green:nil blue:nil alpha:&alpha4];
    XCTAssertEqual(alpha4, .5);
    
    XCTAssertNoThrow(color.CGColor);
    XCTAssertFalse(color.CGColor == nil);
    
    XCTAssertNoThrow([color copy]);
    XCTAssertTrue(((UIColor *)[color copy]).qmui_isDynamicColor);
    
    XCTAssertNoThrow([color isEqual:nil]);
    XCTAssertTrue([color isEqual:color]);
    XCTAssertFalse([color isEqual:[UIColor whiteColor]]);
    
    XCTAssertEqual(([NSSet setWithObjects:color, color, nil]).count, 1);
    XCTAssertEqual(([NSSet setWithObjects:color, color.copy, nil]).count, 2);
}

- (void)testQMUIMethods {
    
}

@end
