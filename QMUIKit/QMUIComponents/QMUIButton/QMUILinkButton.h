//
//  QMUILinkButton.h
//  QMUIKit
//
//  Created by MoLice on 2018/4/9.
//  Copyright © 2018年 QMUI Team. All rights reserved.
//

#import "QMUIButton.h"

NS_ASSUME_NONNULL_BEGIN

/**
 *  支持显示下划线的按钮，可用于需要链接的场景。下划线默认和按钮宽度一样，可通过 `underlineInsets` 调整。
 */
@interface QMUILinkButton : QMUIButton

/// 控制下划线隐藏或显示，默认为NO，也即显示下划线
@property(nonatomic, assign) IBInspectable BOOL underlineHidden;

/// 设置下划线的宽度，默认为 1
@property(nonatomic, assign) IBInspectable CGFloat underlineWidth;

/// 控制下划线颜色，若设置为nil，则使用当前按钮的titleColor的颜色作为下划线的颜色。默认为 nil。
@property(nonatomic, strong, nullable) IBInspectable UIColor *underlineColor;

/// 下划线的位置是基于 titleLabel 的位置来计算的，默认x、width均和titleLabel一致，而可以通过这个属性来调整下划线的偏移值。默认为UIEdgeInsetsZero。
@property(nonatomic, assign) UIEdgeInsets underlineInsets;

@end

NS_ASSUME_NONNULL_END
