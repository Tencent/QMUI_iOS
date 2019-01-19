/*****
 * Tencent is pleased to support the open source community by making QMUI_iOS available.
 * Copyright (C) 2016-2019 THL A29 Limited, a Tencent company. All rights reserved.
 * Licensed under the MIT License (the "License"); you may not use this file except in compliance with the License. You may obtain a copy of the License at
 * http://opensource.org/licenses/MIT
 * Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.
 *****/

//
//  QMUITableViewCell.h
//  qmui
//
//  Created by QMUI Team on 14-7-7.
//

#import <UIKit/UIKit.h>
#import "UITableView+QMUI.h"


@interface QMUITableViewCell : UITableViewCell

@property(nonatomic, assign, readonly) UITableViewCellStyle style;

/**
 *  imageEdgeInsets，这个属性用来调整imageView里面图片的位置，有些情况titleLabel前面是一个icon，但是icon与titleLabel的间距不是你想要的。<br/>
 *  @warning 目前只对UITableViewCellStyleDefault和UITableViewCellStyleSubtitle类型的cell开放
 */
@property(nonatomic, assign) UIEdgeInsets imageEdgeInsets;

/**
 *  textLabelEdgeInsets，这个属性和imageEdgeInsets合作使用，用来调整titleLabel的位置，默认为 UIEdgeInsetsZero。<br/>
 *  @warning 目前只对UITableViewCellStyleDefault和UITableViewCellStyleSubtitle类型的cell开放。
 */
@property(nonatomic, assign) UIEdgeInsets textLabelEdgeInsets;

/// 与textLabelEdgeInsets一致，作用目标为detailTextLabel，默认为 UIEdgeInsetsZero。
@property(nonatomic, assign) UIEdgeInsets detailTextLabelEdgeInsets;

/// 用于调整右边 accessoryView 的布局偏移，默认为 UIEdgeInsetsZero。
@property(nonatomic, assign) UIEdgeInsets accessoryEdgeInsets;

/// 用于调整accessoryView的点击响应区域，可用负值扩大点击范围，默认为(-12, -12, -12, -12)
@property(nonatomic, assign) UIEdgeInsets accessoryHitTestEdgeInsets;

/// 设置当前cell是否enabled，setter方法里面会修改当前的subviews样式。
@property(nonatomic, assign, getter = isEnabled) BOOL enabled;

/// 保存对tableView的弱引用，在布局时可能会使用到tableView的一些属性例如separatorColor等。只有使用下面两个 initForTableView: 的接口初始化时这个属性才有值，否则就只能自己初始化后赋值
@property(nonatomic, weak) UITableView *parentTableView;

/**
 *  cell 处于 section 中的位置，要求：
 *  1. cell 使用 initForTableViewXxx 方法初始化，或者初始化完后为 parentTableView 属性赋值。
 *  2. 在 cellForRow 里调用 [cell updateCellAppearanceWithIndexPath:] 方法。
 *  3. 之后即可通过 cellPosition 获取到正确的位置。
 */
@property(nonatomic, assign, readonly) QMUITableViewCellPosition cellPosition;

/**
 *  首选初始化方法
 *
 *  @param tableView       cell所在的tableView
 *  @param style           tableView的style
 *  @param reuseIdentifier tableView的reuseIdentifier
 *
 *  @return 一个QMUITableViewCell实例
 */
- (instancetype)initForTableView:(UITableView *)tableView withStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier;

/// 同上
- (instancetype)initForTableView:(UITableView *)tableView withReuseIdentifier:(NSString *)reuseIdentifier;

@end


@interface QMUITableViewCell (QMUISubclassingHooks)

/**
 *  初始化时调用的方法，会在两个 NS_DESIGNATED_INITIALIZER 方法中被调用，所以子类如果需要同时支持两个 NS_DESIGNATED_INITIALIZER 方法，则建议把初始化时要做的事情放到这个方法里。否则仅需重写要支持的那个 NS_DESIGNATED_INITIALIZER 方法即可。
 */
- (void)didInitializeWithStyle:(UITableViewCellStyle)style NS_REQUIRES_SUPER;

/// 用于继承的接口，设置一些cell相关的UI，需要自 cellForRowAtIndexPath 里面调用。默认实现是设置当前cell在哪个position。
- (void)updateCellAppearanceWithIndexPath:(NSIndexPath *)indexPath NS_REQUIRES_SUPER;

@end
