/**
 * Tencent is pleased to support the open source community by making QMUI_iOS available.
 * Copyright (C) 2016-2021 THL A29 Limited, a Tencent company. All rights reserved.
 * Licensed under the MIT License (the "License"); you may not use this file except in compliance with the License. You may obtain a copy of the License at
 * http://opensource.org/licenses/MIT
 * Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.
 */

//
//  UIButton+QMUI.h
//  qmui
//
//  Created by QMUI Team on 15/7/20.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIButton (QMUI)

- (instancetype)qmui_initWithImage:(nullable UIImage *)image title:(nullable NSString *)title;

/**
 * 在UIButton的样式（如字体）设置完后，将button的text设置为一个测试字符，再调用sizeToFit，从而令button的高度适应字体
 * @warning 会调用<i>setText:forState:</i>，因此请确保在设置完按钮的样式之后、设置text之前调用
 */
- (void)qmui_calculateHeightAfterSetAppearance;

/**
 * 通过这个方法设置了 attributes 之后，setTitle:forState: 会自动把文字转成 attributedString 再添加上去，无需每次都自己构造 attributedString
 * @note 即使先调用 setTitle:forState: 然后再调用这个方法，之前的 title 仍然会被应用上这些 attributes
 * @note 该方法和 setTitleColor:forState: 均可设置字体颜色，如果二者冲突，则代码顺序较后的方法定义的颜色会最终生效
 * @note 如果包含了 NSKernAttributeName ，则此方法会自动帮你去掉最后一个字的 kern 效果，否则容易导致文字整体在视觉上不居中
 */
- (void)qmui_setTitleAttributes:(nullable NSDictionary<NSAttributedStringKey, id> *)attributes forState:(UIControlState)state;

/**
 为指定 state 的图片设置颜色，当使用这个方法时，会用 Core Graphic 将该状态的图片渲染成指定颜色，并修改 renderingMode 为 UIImageRenderingModeAlwaysOriginal，会有一定性能负担，所以只适用于小图场景。
 @param color 图片的颜色，为 nil 则清空之前为该 state 指定的 imageTintColor
 @param state 指定的状态
 @note 先 setImage 还是先 setImageTintColor，效果都是相同的
 */
- (void)qmui_setImageTintColor:(nullable UIColor *)color forState:(UIControlState)state;

@end

NS_ASSUME_NONNULL_END
