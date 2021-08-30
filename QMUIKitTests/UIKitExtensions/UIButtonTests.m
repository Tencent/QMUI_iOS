/**
 * Tencent is pleased to support the open source community by making QMUI_iOS available.
 * Copyright (C) 2016-2021 THL A29 Limited, a Tencent company. All rights reserved.
 * Licensed under the MIT License (the "License"); you may not use this file except in compliance with the License. You may obtain a copy of the License at
 * http://opensource.org/licenses/MIT
 * Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.
 */
//
//  UIButtonTests.m
//  QMUIKitTests
//
//  Created by MoLice on 2021/6/15.
//

#import <XCTest/XCTest.h>
#import <QMUIKit/QMUIKit.h>

@interface UIButtonTests : XCTestCase

@end

@implementation UIButtonTests

#pragma mark - TitleAttributes

/**
 1. 两者的存储互不影响，设置了 attributedTitle 后从 title 获取纯文本，得到的依然是 nil。
 2. attributedTitle 的优先级一定比 title 高，即便 setTitle 更晚设置。
 3. 当某个 state 没设置值时，会从 normal 取值，不管是 title 还是 attributedTitle。
 4. 展示逻辑总是优先询问 attributedTitleForState:，再询问 titleForState:，遇到前者有值则用前者。由于第2、3点，假设你设置了 Normal title，再设置了 Highlighted attributedTitle，则都会生效。但如果设置 Normal attirbutedTitle，再设置 Highlighted title，则后者不生效，因为处于 Highlighted 状态时，会先询问 attirubtedTitleForState:Highlighted，此时没有，于是从 attributedTitleForState:Normal 取值，发现有值，则用它，不管你的 Highlighted title 其实是有值的。
 */

// 先设置 title，再设置 titleAttributes
- (void)testTitleAttributes1 {
    UIButton *button = [[UIButton alloc] init];
    [button setTitle:@"Normal" forState:UIControlStateNormal];
    [button qmui_setTitleAttributes:@{
        NSForegroundColorAttributeName: UIColorRed,
    } forState:UIControlStateNormal];
    NSString *title = button.currentTitle;
    NSAttributedString *attributedTitle = button.currentAttributedTitle;
    XCTAssertTrue([title isEqualToString:attributedTitle.string]);
    
    [button sizeToFit];
    [button layoutIfNeeded];
    XCTAssertTrue([button.titleLabel.textColor isEqual:UIColorRed]);
}

// 先设置多个 state 的 title，再设置 titleAttributes
- (void)testTitleAttributes2 {
    UIButton *button = [[UIButton alloc] init];
    [button setTitle:@"Normal" forState:UIControlStateNormal];
    [button setTitle:@"Disabled" forState:UIControlStateDisabled];
    [button qmui_setTitleAttributes:@{
        NSForegroundColorAttributeName: UIColorRed,
    } forState:UIControlStateNormal];
    XCTAssertTrue([button.currentAttributedTitle.string isEqualToString:@"Normal"]);
    
    button.enabled = NO;
    [button sizeToFit];
    [button layoutIfNeeded];
    XCTAssertTrue([button.currentAttributedTitle.string isEqualToString:@"Disabled"]);
    XCTAssertTrue([button.titleLabel.textColor isEqual:UIColorRed]);
}

// 先设置 titleAttributes，再设置 title
- (void)testTitleAttributes3 {
    UIButton *button = [[UIButton alloc] init];
    [button qmui_setTitleAttributes:@{
        NSForegroundColorAttributeName: UIColorRed,
    } forState:UIControlStateNormal];
    [button setTitle:@"Normal" forState:UIControlStateNormal];
    
    NSString *title = button.currentTitle;
    NSAttributedString *attributedTitle = button.currentAttributedTitle;
    XCTAssertTrue([title isEqualToString:attributedTitle.string]);
    
    [button sizeToFit];
    [button layoutIfNeeded];
    XCTAssertTrue([button.titleLabel.textColor isEqual:UIColorRed]);
}

// 先设置 titleAttributes，再设置多个 state 的 title
- (void)testTitleAttributes4 {
    UIButton *button = [[UIButton alloc] init];
    [button qmui_setTitleAttributes:@{
        NSForegroundColorAttributeName: UIColorRed,
    } forState:UIControlStateNormal];
    [button setTitle:@"Normal" forState:UIControlStateNormal];
    [button setTitle:@"Disabled" forState:UIControlStateDisabled];
    
    XCTAssertTrue([button.currentAttributedTitle.string isEqualToString:@"Normal"]);
    
    button.enabled = NO;
    [button sizeToFit];
    [button layoutIfNeeded];
    XCTAssertTrue([button.currentAttributedTitle.string isEqualToString:@"Disabled"]);
    XCTAssertTrue([button.titleLabel.textColor isEqual:UIColorRed]);
}

// 分别设置多个 state 的 titleAttributes、title
- (void)testTitleAttributes5 {
    UIButton *button = [[UIButton alloc] init];
    [button qmui_setTitleAttributes:@{
        NSFontAttributeName: UIFontBoldMake(20),
        NSForegroundColorAttributeName: UIColorRed,
    } forState:UIControlStateNormal];
    [button qmui_setTitleAttributes:@{
        NSForegroundColorAttributeName: UIColorBlue,
    } forState:UIControlStateDisabled];
    [button setTitle:@"Normal" forState:UIControlStateNormal];
    [button setTitle:@"Disabled" forState:UIControlStateDisabled];
    [button sizeToFit];
    [button layoutIfNeeded];
    XCTAssertTrue([button.titleLabel.textColor isEqual:UIColorRed]);
    
    button.enabled = NO;
    XCTAssertTrue([button.titleLabel.textColor isEqual:UIColorBlue]);
    
    // 自动从 Normal 复制其他样式过来
    XCTAssertTrue(button.titleLabel.font.pointSize == 20);
}

@end
