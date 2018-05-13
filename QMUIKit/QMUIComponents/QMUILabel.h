//
//  QMUILabel.h
//  qmui
//
//  Created by QMUI Team on 14-7-3.
//  Copyright (c) 2014年 QMUI Team. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
 * `QMUILabel`支持通过`contentEdgeInsets`属性来实现类似padding的效果。
 *
 * 同时通过将`canPerformCopyAction`置为`YES`来开启长按复制文本的功能，复制 item 的文案可通过 menuItemTitleForCopyAction 修改，长按时label的背景色默认为`highlightedBackgroundColor`
 */
@interface QMUILabel : UILabel

/// 控制label内容的padding，默认为UIEdgeInsetsZero
@property(nonatomic,assign) UIEdgeInsets contentEdgeInsets;

/// 是否需要长按复制的功能，默认为 NO。
/// 长按时的背景色通过`highlightedBackgroundColor`设置。
@property(nonatomic,assign) IBInspectable BOOL canPerformCopyAction;

/// 当 canPerformCopyAction 开启时，长按出来的菜单上的复制按钮的文本，默认为 nil，nil 时 menuItem 上的文字为“复制”
@property(nonatomic, copy) IBInspectable NSString *menuItemTitleForCopyAction;

/// 如果打开了`canPerformCopyAction`，则长按时背景色将会被改为`highlightedBackgroundColor`
@property(nonatomic,strong) IBInspectable UIColor *highlightedBackgroundColor;

@end
