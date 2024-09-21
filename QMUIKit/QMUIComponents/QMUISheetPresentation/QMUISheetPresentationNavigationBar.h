//
//  QMUISheetPresentationNavigationBar.h
//  QMUIKit
//
//  Created by molice on 2024/2/27.
//  Copyright © 2024 QMUI Team. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface QMUISheetPresentationNavigationBar : UIView

@property(nonatomic, strong, nullable) UINavigationItem *navigationItem;

@property(nonatomic, strong) UILabel *titleLabel;
@property(nonatomic, strong) __kindof UIView *titleView;
@end

NS_ASSUME_NONNULL_END
