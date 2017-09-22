//
//  QMUIToastContentView.h
//  qmui
//
//  Created by zhoonchen on 2016/12/11.
//  Copyright © 2016年 QMUI Team. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
 * `QMUIToastView`默认使用的contentView。其结构是：customView->textLabel->detailTextLabel等三个view依次往下排列。其中customView可以赋值任意的UIView或者自定义的view。
 *
 * @TODO: 增加多种类型的progressView的支持。
 */
@interface QMUIToastContentView : UIView

/**
 * 设置一个UIView，可以是：菊花、图片等等
 */
@property(nonatomic, strong) UIView *customView;

/**
 * 设置第一行大文字label
 */
@property(nonatomic, strong, readonly) UILabel *textLabel;

/**
 * 通过textLabelText设置可以应用textLabelAttributes的样式，如果通过textLabel.text设置则可能导致一些样式失效。
 */
@property(nonatomic, copy) NSString *textLabelText;

/**
 * 设置第二行小文字label
 */
@property(nonatomic, strong, readonly) UILabel *detailTextLabel;

/**
 * 通过detailTextLabelText设置可以应用detailTextLabelAttributes的样式，如果通过detailTextLabel.text设置则可能导致一些样式失效。
 */
@property(nonatomic, copy) NSString *detailTextLabelText;

/**
 * 设置上下左右的padding。
 */
@property(nonatomic, assign) UIEdgeInsets insets UI_APPEARANCE_SELECTOR;

/**
 * 设置最小size。
 */
@property(nonatomic, assign) CGSize minimumSize UI_APPEARANCE_SELECTOR;

/**
 * 设置customView的marginBottom
 */
@property(nonatomic, assign) CGFloat customViewMarginBottom UI_APPEARANCE_SELECTOR;

/**
 * 设置textLabel的marginBottom
 */
@property(nonatomic, assign) CGFloat textLabelMarginBottom UI_APPEARANCE_SELECTOR;

/**
 * 设置detailTextLabel的marginBottom
 */
@property(nonatomic, assign) CGFloat detailTextLabelMarginBottom UI_APPEARANCE_SELECTOR;

/**
 * 设置textLabel的attributes
 */
@property(nonatomic, strong) NSDictionary <NSString *, id> *textLabelAttributes UI_APPEARANCE_SELECTOR;

/**
 * 设置detailTextLabel的attributes
 */
@property(nonatomic, strong) NSDictionary <NSString *, id> *detailTextLabelAttributes UI_APPEARANCE_SELECTOR;

@end
