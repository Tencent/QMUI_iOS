/*****
 * Tencent is pleased to support the open source community by making QMUI_iOS available.
 * Copyright (C) 2016-2019 THL A29 Limited, a Tencent company. All rights reserved.
 * Licensed under the MIT License (the "License"); you may not use this file except in compliance with the License. You may obtain a copy of the License at
 * http://opensource.org/licenses/MIT
 * Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.
 *****/

//
//  QMUISlider.h
//  qmui
//
//  Created by QMUI Team on 2017/6/1.
//

#import <UIKit/UIKit.h>

/**
 *  相比系统的 UISlider，支持：
 *  1. 修改背后导轨的高度
 *  2. 修改圆点的大小
 *  3. 修改圆点的阴影样式
 */
@interface QMUISlider : UISlider

/// 背后导轨的高度，默认为 0，表示使用系统默认的高度。
@property(nonatomic, assign) IBInspectable CGFloat trackHeight UI_APPEARANCE_SELECTOR;

/// 中间圆球的大小，默认为 CGSizeZero
/// @warning 注意若设置了 thumbSize 但没设置 thumbColor，则圆点的颜色会使用 self.tintColor 的颜色（但系统 UISlider 默认的圆点颜色是白色带阴影）
@property(nonatomic, assign) IBInspectable CGSize thumbSize UI_APPEARANCE_SELECTOR;

/// 中间圆球的颜色，默认为 nil。
/// @warning 注意请勿使用系统的 thumbTintColor，因为 thumbTintColor 和 thumbImage 是互斥的，设置一个会导致另一个被清空，从而导致样式错误。
@property(nonatomic, strong) IBInspectable UIColor *thumbColor UI_APPEARANCE_SELECTOR;

/// 中间圆球的阴影颜色，默认为 nil
@property(nonatomic, strong) IBInspectable UIColor *thumbShadowColor UI_APPEARANCE_SELECTOR;

/// 中间圆球的阴影偏移值，默认为 CGSizeZero
@property(nonatomic, assign) IBInspectable CGSize thumbShadowOffset UI_APPEARANCE_SELECTOR;

/// 中间圆球的阴影扩散度，默认为 0
@property(nonatomic, assign) IBInspectable CGFloat thumbShadowRadius UI_APPEARANCE_SELECTOR;

@end
