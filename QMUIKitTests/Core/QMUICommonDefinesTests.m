/**
 * Tencent is pleased to support the open source community by making QMUI_iOS available.
 * Copyright (C) 2016-2020 THL A29 Limited, a Tencent company. All rights reserved.
 * Licensed under the MIT License (the "License"); you may not use this file except in compliance with the License. You may obtain a copy of the License at
 * http://opensource.org/licenses/MIT
 * Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.
 */

//
//  QMUICommonDefinesTests.m
//  QMUIKitTests
//
//  Created by MoLice on 2020/5/12.
//

#import <XCTest/XCTest.h>
#import <QMUIKit/QMUIKit.h>

@interface QMUICommonDefinesTests : XCTestCase

@end

@implementation QMUICommonDefinesTests

- (void)testCGFloatCalcOperator {
    CGFloat a = 0.999;
    CGFloat b = 1.011;
    CGFloat c = 1.033;
    CGFloat d = 1.099;
    
    XCTAssertTrue(CGFloatEqualToFloat(a, b));
    XCTAssertTrue(CGFloatEqualToFloat(b, c));
    XCTAssertTrue(CGFloatEqualToFloat(c, d));
    
    XCTAssertTrue(CGFloatEqualToFloatWithPrecision(a, b, 1));
    XCTAssertTrue(CGFloatEqualToFloatWithPrecision(b, c, 1));
    XCTAssertFalse(CGFloatEqualToFloatWithPrecision(c, d, 1));
    
    XCTAssertFalse(CGFloatEqualToFloatWithPrecision(a, b, 2));
    XCTAssertFalse(CGFloatEqualToFloatWithPrecision(b, c, 2));
    XCTAssertFalse(CGFloatEqualToFloatWithPrecision(c, d, 2));
}

@end
