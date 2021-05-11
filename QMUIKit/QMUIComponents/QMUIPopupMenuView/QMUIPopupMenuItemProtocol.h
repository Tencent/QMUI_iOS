/**
 * Tencent is pleased to support the open source community by making QMUI_iOS available.
 * Copyright (C) 2016-2021 THL A29 Limited, a Tencent company. All rights reserved.
 * Licensed under the MIT License (the "License"); you may not use this file except in compliance with the License. You may obtain a copy of the License at
 * http://opensource.org/licenses/MIT
 * Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.
 */

//
//  QMUIPopupMenuItemProtocol.h
//  QMUIKit
//
//  Created by QMUI Team on 2018/8/21.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class QMUIPopupMenuView;

@protocol QMUIPopupMenuItemProtocol <NSObject>

/// item 里的文字
@property(nonatomic, copy, nullable) NSString *title;

/// item 的高度，默认为 -1。小于 0 的值均表示高度以 QMUIPopupMenuView.itemHeight 为准，当需要给某个 item 指定特定高度时才需要用这个 height 属性。
@property(nonatomic, assign) CGFloat height;

/// item 被点击时的事件处理，需要在内部自行隐藏 QMUIPopupMenuView。
@property(nonatomic, copy, nullable) void (^handler)(__kindof NSObject<QMUIPopupMenuItemProtocol> *aItem);

/// 当前 item 所在的 QMUIPopupMenuView 的引用，只有在 item 被添加到菜单之后才有值。
@property(nonatomic, weak, nullable) QMUIPopupMenuView *menuView;

/// item 被添加到 menuView 之后（也即 menuView 属性有值了）会被调用，可在这个方法里更新 item 的样式（因为某些样式可能需要从 menuView 那边读取）
- (void)updateAppearance;

@end

NS_ASSUME_NONNULL_END
