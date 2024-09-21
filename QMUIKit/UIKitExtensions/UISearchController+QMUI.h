/**
 * Tencent is pleased to support the open source community by making QMUI_iOS available.
 * Copyright (C) 2016-2021 THL A29 Limited, a Tencent company. All rights reserved.
 * Licensed under the MIT License (the "License"); you may not use this file except in compliance with the License. You may obtain a copy of the License at
 * http://opensource.org/licenses/MIT
 * Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.
 */
//
//  UISearchController+QMUI.h
//  QMUIKit
//
//  Created by ziezheng on 2019/9/27.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UISearchController (QMUI)

/// 系统默认是只有搜索框文本不为空时才会显示搜索结果，将该属性置为 YES 可以做到只要 active 就能显示搜索结果列表。
/// 该属性与 qmui_launchView、obscuresBackgroundDuringPresentation 互斥，打开该属性时会强制清除互斥属性（但如果你非要在打开该属性之后，再重新为这两个互斥属性赋值，也是可以的）。
/// 默认为 NO。
@property(nonatomic, assign) BOOL qmui_alwaysShowSearchResultsController;

/// 当 A 里构造了一个 UISearchController（称为B），当B进入搜索状态后，再 push/present 到其他界面，B的 viewWillAppear: 等生命周期方法并不会被调用，但A的生命周期方法会被调用，这令搜索业务难以感知当前的界面状态。
/// 若将当前属性置为 YES，则会保证A的生命周期方法被调用时也触发B的生命周期方法。
/// 默认为 NO。
@property(nonatomic, assign) BOOL qmui_forwardAppearanceMethodsFromPresentingController;

/// 升起键盘时的半透明遮罩，nil 表示用系统的，非 nil 则用自己的。默认为 nil。
/// @note 如果使用了 launchView 则该属性无效。
@property(nonatomic, strong, nullable) UIColor *qmui_dimmingColor;

/// 在搜索文字为空时会展示的一个 view，通常用于实现“最近搜索”之类的功能。launchView 最终会被布局为撑满搜索框以下的所有空间。
@property(nonatomic, strong, nullable) UIView *qmui_launchView;

/// 获取进入搜索状态后 searchBar 在 UISearchController.view 坐标系内的 maxY 值，方便 searchResultsController 布局。
@property(nonatomic, assign, readonly) CGFloat qmui_searchBarMaxY;
@end

NS_ASSUME_NONNULL_END
