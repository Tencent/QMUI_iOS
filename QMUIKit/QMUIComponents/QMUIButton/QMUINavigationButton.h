/**
 * Tencent is pleased to support the open source community by making QMUI_iOS available.
 * Copyright (C) 2016-2020 THL A29 Limited, a Tencent company. All rights reserved.
 * Licensed under the MIT License (the "License"); you may not use this file except in compliance with the License. You may obtain a copy of the License at
 * http://opensource.org/licenses/MIT
 * Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.
 */

//
//  QMUINavigationButton.h
//  QMUIKit
//
//  Created by QMUI Team on 2018/4/9.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, QMUINavigationButtonType) {
    QMUINavigationButtonTypeNormal,         // 普通导航栏文字按钮
    QMUINavigationButtonTypeBold,           // 导航栏加粗按钮
    QMUINavigationButtonTypeImage,          // 图标按钮
    QMUINavigationButtonTypeBack            // 自定义返回按钮(可以同时带有title)
};

/**
 *  QMUINavigationButton 有两部分组成：
 *  一部分是 UIBarButtonItem (QMUINavigationButton)，提供比系统更便捷的类方法来快速初始化一个 UIBarButtonItem，推荐首选这种方式（原则是能用系统的尽量用系统的，不满足才用自定义的）。
 *  另一部分就是 QMUINavigationButton，会提供一个按钮，作为 customView 给 UIBarButtonItem 使用，这种常用于自定义的返回按钮。
 *  对于第二种按钮，会尽量保证样式、布局看起来都和系统的 UIBarButtonItem 一致，所以内部做了许多 iOS 版本兼容的微调。
 */
@interface QMUINavigationButton : UIButton

/**
 *  获取当前按钮的`QMUINavigationButtonType`
 */
@property(nonatomic, assign, readonly) QMUINavigationButtonType type;

/**
 * UIBarButtonItem 默认都是跟随 tintColor 的，所以这里声明是否让图片也是用 AlwaysTemplate 模式
 * 默认为 YES
 */
@property(nonatomic, assign) BOOL adjustsImageTintColorAutomatically;

/**
 *  导航栏按钮的初始化函数，指定的初始化方法
 *  @param type 按钮类型
 *  @param title 按钮的title
 */
- (instancetype)initWithType:(QMUINavigationButtonType)type title:(nullable NSString *)title;

/**
 *  导航栏按钮的初始化函数
 *  @param type 按钮类型
 */
- (instancetype)initWithType:(QMUINavigationButtonType)type;

/**
 *  导航栏按钮的初始化函数
 *  @param image 按钮的image
 */
- (instancetype)initWithImage:(nullable UIImage *)image;

@end

@interface UIBarButtonItem (QMUINavigationButton)

+ (instancetype)qmui_itemWithButton:(nullable QMUINavigationButton *)button target:(nullable id)target action:(nullable SEL)action;
+ (instancetype)qmui_itemWithImage:(nullable UIImage *)image target:(nullable id)target action:(nullable SEL)action;
+ (instancetype)qmui_itemWithTitle:(nullable NSString *)title target:(nullable id)target action:(nullable SEL)action;
+ (instancetype)qmui_itemWithBoldTitle:(nullable NSString *)title target:(nullable id)target action:(nullable SEL)action;
+ (instancetype)qmui_backItemWithTitle:(nullable NSString *)title target:(nullable id)target action:(nullable SEL)action;
+ (instancetype)qmui_backItemWithTarget:(nullable id)target action:(nullable SEL)action;
+ (instancetype)qmui_closeItemWithTarget:(nullable id)target action:(nullable SEL)action;
+ (instancetype)qmui_fixedSpaceItemWithWidth:(CGFloat)width;
+ (instancetype)qmui_flexibleSpaceItem;
@end

NS_ASSUME_NONNULL_END
