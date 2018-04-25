//
//  QMUIToolbarButton.h
//  QMUIKit
//
//  Created by MoLice on 2018/4/9.
//  Copyright © 2018年 QMUI Team. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, QMUIToolbarButtonType) {
    QMUIToolbarButtonTypeNormal,            // 普通工具栏按钮
    QMUIToolbarButtonTypeRed,               // 工具栏红色按钮，用于删除等警告性操作
    QMUIToolbarButtonTypeImage,              // 图标类型的按钮
};

/**
 *  `QMUIToolbarButton`是用于底部工具栏的按钮
 */
@interface QMUIToolbarButton : UIButton

/// 获取当前按钮的type
@property(nonatomic, assign, readonly) QMUIToolbarButtonType type;

/**
 *  工具栏按钮的初始化函数
 *  @param type  按钮类型
 */
- (instancetype)initWithType:(QMUIToolbarButtonType)type;

/**
 *  工具栏按钮的初始化函数
 *  @param type 按钮类型
 *  @param title 按钮的title
 */
- (instancetype)initWithType:(QMUIToolbarButtonType)type title:(nullable NSString *)title;

/**
 *  工具栏按钮的初始化函数
 *  @param image 按钮的image
 */
- (instancetype)initWithImage:(UIImage *)image;

/// 在原有的QMUIToolbarButton上创建一个UIBarButtonItem
+ (nullable UIBarButtonItem *)barButtonItemWithToolbarButton:(QMUIToolbarButton *)button target:(nullable id)target action:(nullable SEL)selector;

/// 创建一个特定type的UIBarButtonItem
+ (nullable UIBarButtonItem *)barButtonItemWithType:(QMUIToolbarButtonType)type title:(nullable NSString *)title target:(nullable id)target action:(nullable SEL)selector;

/// 创建一个图标类型的UIBarButtonItem
+ (nullable UIBarButtonItem *)barButtonItemWithImage:(nullable UIImage *)image target:(nullable id)target action:(nullable SEL)selector;

@end

NS_ASSUME_NONNULL_END
