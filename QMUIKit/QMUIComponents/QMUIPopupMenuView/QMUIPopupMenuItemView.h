//
//  QMUIPopupMenuItemView.h
//  QMUIKit
//
//  Created by molice on 2024/6/17.
//  Copyright © 2024 QMUI Team. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "QMUIPopupMenuItemViewProtocol.h"

NS_ASSUME_NONNULL_BEGIN

@class QMUIButton;
@class QMUICheckbox;

@interface QMUIPopupMenuItemView : UIControl<QMUIPopupMenuItemViewProtocol>

/// 图片、文本、第二行文本所在的 view，不接受事件，点击事件由 self 接管。
@property(nonatomic, strong, readonly) QMUIButton *button;

/// 当菜单进入选择模式时，代表被选中的勾。非选择模式时不存在。
@property(nonatomic, strong, readonly, nullable) UIImageView *checkmark;

/// 当菜单进入选择模式时，代表被选中的圆形勾，不接受事件，勾选状态由菜单控制。非选择模式时不存在。
@property(nonatomic, strong, readonly, nullable) QMUICheckbox *checkbox;

@property(nonatomic, strong, nullable) UIColor *highlightedBackgroundColor;

@property(nonatomic, assign) UIEdgeInsets padding;
@property(nonatomic, assign) CGFloat spacingBetweenButtonAndCheck;
@end

NS_ASSUME_NONNULL_END
