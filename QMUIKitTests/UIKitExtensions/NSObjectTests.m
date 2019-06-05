//
//  NSObject.m
//  QMUIKitTests
//
//  Created by MoLice on 2019/J/5.
//  Copyright © 2019 QMUI Team. All rights reserved.
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
        XCTAssertFalse(navigationBar.qmui_backgroundContentView);
        XCTAssertFalse(navigationBar.qmui_shadowImageView);
    } else {
        XCTAssertTrue(navigationBar.qmui_backgroundContentView);
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
    XCTAssertTrue(searchBar.qmui_backgroundView);
    XCTAssertTrue(searchBar.qmui_cancelButton);
    XCTAssertTrue(searchBar.qmui_segmentedControl);
    XCTAssertFalse([searchBar qmui_valueForKey:@"_searchController"]);
}

@end
