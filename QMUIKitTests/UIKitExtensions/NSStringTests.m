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

- (void)testStringMatching {
    NSString *string = @"string0.05";
    XCTAssertNil([string qmui_stringMatchedByPattern:@""]);
    XCTAssertNotNil([string qmui_stringMatchedByPattern:@"str"]);
    XCTAssertEqualObjects([string qmui_stringMatchedByPattern:@"[\\d\\.]+"], @"0.05");
    
    XCTAssertNil([string qmui_stringMatchedByPattern:@"str" groupIndex:1]);
    XCTAssertEqualObjects([string qmui_stringMatchedByPattern:@"ing([\\d\\.]+)" groupIndex:1], @"0.05");
    
    if (@available(iOS 11.0, *)) {
        XCTAssertNil([string qmui_stringMatchedByPattern:@"str" groupName:@"number"]);
        XCTAssertEqualObjects([string qmui_stringMatchedByPattern:@"ing(?<number>[\\d\\.]+)" groupName:@"number"], @"0.05");
        XCTAssertThrows([string qmui_stringMatchedByPattern:@"ing(?<number>[\\d\\.]+)" groupName:@"num"]);
    }
}

//- (void)testPerformanceExample {
//    // This is an example of a performance test case.
//    [self measureBlock:^{
//        // Put the code you want to measure the time of here.
//    }];
//}

@end
