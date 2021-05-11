/**
 * Tencent is pleased to support the open source community by making QMUI_iOS available.
 * Copyright (C) 2016-2021 THL A29 Limited, a Tencent company. All rights reserved.
 * Licensed under the MIT License (the "License"); you may not use this file except in compliance with the License. You may obtain a copy of the License at
 * http://opensource.org/licenses/MIT
 * Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.
 */

//
//  QMUIFloatLayoutView.h
//  qmui
//
//  Created by QMUI Team on 2016/11/10.
//

#import <UIKit/UIKit.h>

/// 用于属性 maximumItemSize，是它的默认值。表示 item 的最大宽高会自动根据当前 floatLayoutView 的内容大小来调整，从而避免 item 内容过多时可能溢出 floatLayoutView。
extern const CGSize QMUIFloatLayoutViewAutomaticalMaximumItemSize;

/**
 *  做类似 CSS 里的 float:left 的布局，自行使用 addSubview: 将子 View 添加进来即可。
 *
 *  支持通过 `contentMode` 属性修改子 View 的对齐方式，目前仅支持 `UIViewContentModeLeft` 和 `UIViewContentModeRight`，默认为 `UIViewContentModeLeft`。
 */
@interface QMUIFloatLayoutView : UIView

/**
 *  QMUIFloatLayoutView 内部的间距，默认为 UIEdgeInsetsZero
 */
@property(nonatomic, assign) UIEdgeInsets padding;

/**
 *  item 的最小宽高，默认为 CGSizeZero，也即不限制。
 */
@property(nonatomic, assign) IBInspectable CGSize minimumItemSize;

/**
 *  item 的最大宽高，默认为 QMUIFloatLayoutViewAutomaticalMaximumItemSize，也即不超过 floatLayoutView 自身最大内容宽高。
 */
@property(nonatomic, assign) IBInspectable CGSize maximumItemSize;

/**
 *  item 之间的间距，默认为 UIEdgeInsetsZero。
 * 
 *  @warning 上、下、左、右四个边缘的 item 布局时不会考虑 itemMargins.top/bottom/left/right。
 */
@property(nonatomic, assign) UIEdgeInsets itemMargins;
@end
