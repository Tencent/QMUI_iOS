//
//  QMUISheetPresentationNavigationBar.m
//  QMUIKit
//
//  Created by molice on 2024/2/27.
//  Copyright © 2024 QMUI Team. All rights reserved.
//

#import "QMUISheetPresentationNavigationBar.h"
#import "QMUICore.h"
#import "QMUIButton.h"
#import "QMUINavigationButton.h"

@interface QMUISheetPresentationNavigationBar ()
@property(nonatomic, strong) QMUINavigationButton *backButton;
@property(nonatomic, strong) QMUIButton *leftButton;
@property(nonatomic, strong) QMUIButton *rightButton;
@end

@implementation QMUISheetPresentationNavigationBar

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = UIColor.whiteColor;
        
        self.titleLabel = [[UILabel alloc] init];
        if (QMUICMIActivated) {
            self.titleLabel.font = NavBarTitleFont;
            self.titleLabel.textColor = NavBarTitleColor;
        }
    }
    return self;
}

- (void)setNavigationItem:(UINavigationItem *)navigationItem {
    if (_navigationItem != navigationItem) {
        self.titleLabel.text = nil;
        [self.titleView removeFromSuperview];
    }
    _navigationItem = navigationItem;
    if (navigationItem.titleView) {
        self.titleView = navigationItem.titleView;
    } else if (navigationItem.title.length) {
        self.titleLabel.text = navigationItem.title;
        self.titleView = self.titleLabel;
    }
    [self addSubview:self.titleView];
}

- (CGSize)sizeThatFits:(CGSize)size {
    return CGSizeMake(size.width, 56);
}

- (void)layoutSubviews {
    [super layoutSubviews];
    [self.titleView sizeToFit];
    self.titleView.center = CGPointMake(CGRectGetWidth(self.bounds) / 2, CGRectGetHeight(self.bounds) / 2);
}

@end
