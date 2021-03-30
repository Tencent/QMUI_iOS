/**
 * Tencent is pleased to support the open source community by making QMUI_iOS available.
 * Copyright (C) 2016-2021 THL A29 Limited, a Tencent company. All rights reserved.
 * Licensed under the MIT License (the "License"); you may not use this file except in compliance with the License. You may obtain a copy of the License at
 * http://opensource.org/licenses/MIT
 * Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.
 */

//
//  UIControl+QMUI.h
//  qmui
//
//  Created by QMUI Team on 15/7/20.
//

#import <UIKit/UIKit.h>

@interface UIControl (QMUI)

/**
 *  是否优化 UIControl 被放在 UIScrollView 上时的点击体验。系统默认行为下，UIControl 在 UIScrollView 上会有300毫秒的延迟，当你快速点击某个 UIControl 时，将不会看到 setHighlighted 的效果。
 *
 *  此时可以将 UIControl.qmui_automaticallyAdjustTouchHighlightedInScrollView 属性置为 YES，会使用自己的一套计算方式去判断触发 setHighlighted 的时机，从而保证既不影响 UIScrollView 的滚动，又能让 UIControl 在被快速点击时也能立马看到 setHighlighted 的效果。
 *
 *  @warning 使用了这个属性则不需要设置 UIScrollView.delaysContentTouches。因为如果将 UIScrollView.delaysContentTouches 置为 NO 来取消这个延迟，则系统无法判断 touch 时是要点击还是要滚动，你就会观察到当你想要滚动 UIScrollView 时，手指触摸到的那个 UIControl 会呈现出 highlighted 的效果，但通常这并不符合预期。
 */
@property(nonatomic, assign) BOOL qmui_automaticallyAdjustTouchHighlightedInScrollView;

/**
 当快速重复点击某个 UIControl 时，系统的默认行为是每次点击都会触发一次 UIControlEventTouchUpInside 事件，但通常这并不是我们想要的，可能会导致某段逻辑被重复触发。因此提供这个属性，当置为 YES 时，连续的快速点击只有第一次会触发 UIControlEventTouchUpInside，当停止300ms后再重新点击，才会重新触发一次 UIControlEventTouchUpInside。该属性对非 UIControlEventTouchUpInside 的事件无效（例如 UIControlEventTouchDownRepeat、UIControlEventEditingChanged 等事件本来就会短时间内重复被触发多次）。
 
 @note 系统默认就会对同一点击区域短时间内触发的多次 touch 都归到同一组，所以如果10s内连续不断地快速点击同一个按钮，这10s的时间里也只会触发一次 UIControlEventTouchUpInside，因为这10s里的所有 touch 都被归到同一组事件里。但如果通过定时器实现，假设以1s为临界点，那么这10s的快速点击就会触发十次。QMUI 的实现采用的是前一种。
 
 @warning 不能与 @c qmui_automaticallyAdjustTouchHighlightedInScrollView 同时开启。
 */
@property(nonatomic, assign) BOOL qmui_preventsRepeatedTouchUpInsideEvent;

/// setHighlighted: 方法的回调 block
@property(nonatomic, copy) void (^qmui_setHighlightedBlock)(BOOL highlighted);

/// 等同于 addTarget:action:forControlEvents:UIControlEventTouchUpInside
@property(nonatomic, copy) void (^qmui_tapBlock)(__kindof UIControl *sender);

@end
