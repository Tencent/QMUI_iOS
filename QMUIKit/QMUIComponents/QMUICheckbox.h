//
//  QMUICheckbox.h
//  QMUIKit
//
//  Created by molice on 2024/8/1.
//  Copyright © 2024 QMUI Team. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "QMUIButton.h"

NS_ASSUME_NONNULL_BEGIN

/// 圆形勾选控件，selected = YES 表示勾选，indeterminate = YES 表示半选，enabled = NO 表示禁用。
/// 由于父类是 QMUIButton，所以可以通过 setTitle:forState: 轻松实现左边 checkbox 右边说明文本的效果。
/// 尺寸可以通过 checkboxSize 修改，颜色可通过 tintColor 修改。
/// 点击勾选的交互需要由业务自己实现。
@interface QMUICheckbox : QMUIButton

/// 置为半选状态。可以理解为一个 Checkbox 的 indeterminate 和 checked(selected) 是平级的、互斥的，当该属性被设置为 YES 时，会将 selected 置为 NO，当 selected 被置为 YES 时，会将该属性置为 NO。
@property(nonatomic, assign) BOOL indeterminate;

/// 指定 checkbox 图片的尺寸（如果存在 title，不影响 title 的尺寸）
/// 默认为(16, 16)
@property(nonatomic, assign) CGSize checkboxSize;

/// 未勾选的状态，置为 nil 则使用组件默认图
@property(nonatomic, strong) UIImage *normalImage;

/// 勾选的状态，置为 nil 则使用组件默认图
@property(nonatomic, strong) UIImage *selectedImage;

/// 半勾选的状态，置为 nil 则使用组件默认图
@property(nonatomic, strong) UIImage *indeterminateImage;

/// 未勾选且禁用的状态（如果是已勾选的禁用，会直接沿用该状态的图片，只有未勾选的禁用可以有单独的图），置为 nil 则使用组件默认图
@property(nonatomic, strong) UIImage *disabledImage;
@end

NS_ASSUME_NONNULL_END
