/*****
 * Tencent is pleased to support the open source community by making QMUI_iOS available.
 * Copyright (C) 2016-2019 THL A29 Limited, a Tencent company. All rights reserved.
 * Licensed under the MIT License (the "License"); you may not use this file except in compliance with the License. You may obtain a copy of the License at
 * http://opensource.org/licenses/MIT
 * Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.
 *****/

//
//  QMUIViewController.m
//  qmui
//
//  Created by QMUI Team on 15/4/13.
//

#import "QMUIViewController.h"

@interface QMUIViewController ()

@end

@implementation QMUIViewController
{
    UILabel *_homeLabel;
}

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)initSubviews {
    [super initSubviews];
    _homeLabel = [[UILabel alloc] init];
    _homeLabel.numberOfLines = 0;
    _homeLabel.textColor = UIColorGray;
    _homeLabel.text = @"欢迎使用 QMUI，如需了解 QMUI 的使用，请下载 QMUI Demo 项目进行查看。";
    [self.view addSubview:_homeLabel];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    CGFloat paddingHorizontal = 20;
    CGFloat homeLabelLimitWidth = CGRectGetWidth(self.view.bounds) - paddingHorizontal * 2;
    CGSize homeLabelSize = [_homeLabel sizeThatFits:CGSizeMake(homeLabelLimitWidth, CGFLOAT_MAX)];
    _homeLabel.frame = CGRectMake(paddingHorizontal, self.qmui_navigationBarMaxYInViewCoordinator + 50, homeLabelLimitWidth, homeLabelSize.height);
}

- (void)setupNavigationItems {
    [super setupNavigationItems];
    self.title = @"QMUI";
}

@end
