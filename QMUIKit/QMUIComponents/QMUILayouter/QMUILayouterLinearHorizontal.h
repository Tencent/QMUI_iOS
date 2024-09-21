/**
 * Tencent is pleased to support the open source community by making QMUI_iOS available.
 * Copyright (C) 2016-2021 THL A29 Limited, a Tencent company. All rights reserved.
 * Licensed under the MIT License (the "License"); you may not use this file except in compliance with the License. You may obtain a copy of the License at
 * http://opensource.org/licenses/MIT
 * Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.
 */

//
//  QMUILayouterLinearHorizontal.h
//  QMUIKit
//
//  Created by QMUI Team on 2024/1/2.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "QMUILayouterItem.h"

NS_ASSUME_NONNULL_BEGIN

/**
 水平方向的线性布局，若容器大小不足以容纳所有 item，则末尾的 item 大小会被强制裁剪以保证不溢出。
 子元素可通过设置自己的 grow 来达到撑满容器的效果。
 */
@interface QMUILayouterLinearHorizontal : QMUILayouterItem

+ (instancetype)itemWithChildItems:(NSArray<QMUILayouterItem *> *)childItems
               spacingBetweenItems:(CGFloat)spacingBetweenItems;

+ (instancetype)itemWithChildItems:(NSArray<QMUILayouterItem *> *)childItems
               spacingBetweenItems:(CGFloat)spacingBetweenItems
                        horizontal:(QMUILayouterAlignment)horizontal
                          vertical:(QMUILayouterAlignment)vertical;

/// 子元素之间的间距
@property(nonatomic, assign) CGFloat spacingBetweenItems;

/// 子元素水平方向上的布局方式，默认为 QMUILayouterAlignmentLeading，每种 enum 的布局说明请查看 enum 定义。
@property(nonatomic, assign) QMUILayouterAlignment childHorizontalAlignment;

/// 子元素竖直方向上的布局方式，默认为 QMUILayouterAlignmentLeading，每种 enum 的布局说明请查看 enum 定义。
@property(nonatomic, assign) QMUILayouterAlignment childVerticalAlignment;
@end

NS_ASSUME_NONNULL_END
