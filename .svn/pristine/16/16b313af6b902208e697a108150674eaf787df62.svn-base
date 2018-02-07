//
//  QMUIViewController.m
//  qmui
//
//  Created by ZhoonChen on 15/4/13.
//  Copyright (c) 2015年 QMUI Team. All rights reserved.
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
    _homeLabel.text = @"欢迎使用QMUI，如需了解QMUI的使用，请下载QMUI的demo项目进行查看。\n\n\n如有问题请联系RTX：\nzhoonchen\nmolicechen";
    [self.view addSubview:_homeLabel];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    CGFloat paddingHorizontal = 20;
    CGFloat homeLabelLimitWidth = CGRectGetWidth(self.view.bounds) - paddingHorizontal * 2;
    CGSize homeLabelSize = [_homeLabel sizeThatFits:CGSizeMake(homeLabelLimitWidth, CGFLOAT_MAX)];
    _homeLabel.frame = CGRectMake(paddingHorizontal, self.qmui_navigationBarMaxYInViewCoordinator + 50, homeLabelLimitWidth, homeLabelSize.height);
}

- (void)setNavigationItemsIsInEditMode:(BOOL)isInEditMode animated:(BOOL)animated {
    [super setNavigationItemsIsInEditMode:isInEditMode animated:animated];
    self.title = @"QMUI";
}

@end
