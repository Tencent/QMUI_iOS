/**
 * Tencent is pleased to support the open source community by making QMUI_iOS available.
 * Copyright (C) 2016-2021 THL A29 Limited, a Tencent company. All rights reserved.
 * Licensed under the MIT License (the "License"); you may not use this file except in compliance with the License. You may obtain a copy of the License at
 * http://opensource.org/licenses/MIT
 * Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.
 */
//
//  NSObject.m
//  QMUIKitTests
//
//  Created by MoLice on 2019/J/5.  
//

#import <XCTest/XCTest.h>
#import <QMUIKit/QMUIKit.h>

@interface NSObjectTests : XCTestCase

@end

@implementation NSObjectTests

- (void)testValueForKey {
    UINavigationBar *navigationBar = [UINavigationBar new];
    [navigationBar sizeToFit];
    XCTAssertTrue(navigationBar.qmui_backgroundView);
    if (@available(iOS 13.0, *)) {
        XCTAssertFalse(navigationBar.qmui_shadowImageView);
    } else {
        XCTAssertTrue(navigationBar.qmui_shadowImageView);
    }
    
    UITabBar *tabBar = [UITabBar new];
    [tabBar sizeToFit];
    XCTAssertTrue(tabBar.qmui_backgroundView);
    if (@available(iOS 13.0, *)) {
        XCTAssertFalse(tabBar.qmui_shadowImageView);
    } else {
        XCTAssertTrue(tabBar.qmui_shadowImageView);
    }
    
    UISearchBar *searchBar = [UISearchBar new];
    searchBar.scopeButtonTitles = @[@"A", @"B"];
    searchBar.showsCancelButton = YES;
    [searchBar sizeToFit];
    [searchBar qmui_setValue:@"Test" forKey:@"_cancelButtonText"];
    // iOS13 crash : [searchBar setValue:@"Test" forKey:@"_cancelButtonText"];
    UIView *searchField = [searchBar qmui_valueForKey:@"_searchField"];
    // iOS13 crash : [searchBar valueForKey:@"_searchField"];

    XCTAssertTrue(searchBar.qmui_backgroundView);
    XCTAssertTrue(searchBar.qmui_cancelButton);
    XCTAssertTrue(searchBar.qmui_segmentedControl);
    XCTAssertFalse([searchBar qmui_valueForKey:@"_searchController"]);
}

@end
