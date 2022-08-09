/**
 * Tencent is pleased to support the open source community by making QMUI_iOS available.
 * Copyright (C) 2016-2021 THL A29 Limited, a Tencent company. All rights reserved.
 * Licensed under the MIT License (the "License"); you may not use this file except in compliance with the License. You may obtain a copy of the License at
 * http://opensource.org/licenses/MIT
 * Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.
 */

//
//  QMUIPopupMenuButtonItem.h
//  QMUIKit
//
//  Created by QMUI Team on 2018/8/21.
//

#import "QMUIPopupMenuBaseItem.h"

NS_ASSUME_NONNULL_BEGIN

@class QMUIButton;

/**
 *  配合 QMUIPopupMenuView 使用，用于可点击的菜单项。
 *  支持显示图片和标题，以及点击事件的回调。
 *  可在 QMUIPopupMenuView 里统一修改菜单项的样式，如果某个菜单项需要特殊调整，可通过 QMUIPopupMenuButtonItem.button 拿到 view 并进行调整。
 */
@interface QMUIPopupMenuButtonItem : QMUIPopupMenuBaseItem

/// item 里的图片，默认在左边，也可通过 item.button.imagePosition 修改图片的位置
@property(nonatomic, strong, nullable) UIImage *image;

/// 每个 item 都通过一个 button 来显示内容，可直接修改 button 的相关属性达到自定义的效果，button 的 tintColor 为 nil，因此可以自动响应 QMUIPopupMenuView 的 tintColor 变化。
@property(nonatomic, strong, readonly, nonnull) QMUIButton *button;

/// item 被点击时的背景色，默认为 TableViewCellSelectedBackgroundColor，与列表的 cell 点击背景色一致。
@property(nonatomic, strong, nullable) UIColor *highlightedBackgroundColor UI_APPEARANCE_SELECTOR;

/// item 里图片和文字之间的间距，默认为 6，只有同时存在图片和文字时这个属性才会生效。
@property(nonatomic, assign) CGFloat imageMarginRight UI_APPEARANCE_SELECTOR;

/**
 推荐的初始化方法
 
 @param image item 的图片
 @param title item 的文字
 @param handler item 点击时的事件回调，需要在这里自行隐藏 aMenuView
 @return item
 */
+ (instancetype)itemWithImage:(nullable UIImage *)image title:(nullable NSString *)title handler:(nullable void (^)(__kindof QMUIPopupMenuButtonItem *aItem))handler;

@end

NS_ASSUME_NONNULL_END
