//
//  QMUIToastBackgroundView.h
//  qmui
//
//  Created by zhoonchen on 2016/12/11.
//  Copyright © 2016年 QMUI Team. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface QMUIToastBackgroundView : UIView

/**
 * 是否需要磨砂，默认NO。仅支持iOS8及以上版本。
 */
@property(nonatomic, assign) BOOL shouldBlurBackgroundView;

/**
 * 如果不设置磨砂，则styleColor直接作为`QMUIToastBackgroundView`的backgroundColor；如果需要磨砂，则会新增加一个`UIVisualEffectView`放在`QMUIToastBackgroundView`上面
 */
@property(nonatomic, strong) UIColor *styleColor UI_APPEARANCE_SELECTOR;

/**
 * 设置圆角。
 */
@property(nonatomic, assign) CGFloat cornerRadius UI_APPEARANCE_SELECTOR;

@end
