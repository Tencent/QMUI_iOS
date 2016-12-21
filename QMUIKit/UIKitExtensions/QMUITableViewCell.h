//
//  QMUITableViewCell.h
//  qmui
//
//  Created by QQMail on 14-7-7.
//  Copyright (c) 2014年 QMUI Team. All rights reserved.
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
 *  textLabelEdgeInsets，这个属性和imageEdgeInsets合作使用，用来调整titleLabel的位置。<br/>
 *  @warning 目前只对UITableViewCellStyleDefault和UITableViewCellStyleSubtitle类型的cell开放。
 */
@property(nonatomic, assign) UIEdgeInsets textLabelEdgeInsets;

/// 与textLabelEdgeInsets一致，作用目标为detailTextLabel。
@property(nonatomic, assign) UIEdgeInsets detailTextLabelEdgeInsets;

/// 用于调整accessoryView的点击响应区域，可用负值扩大点击范围，默认为(-12, -12, -12, -12)
@property(nonatomic, assign) UIEdgeInsets accessoryHitTestEdgeInsets;

/// 设置当前cell是否enabled，setter方法里面会修改当前的subviews样式。
@property(nonatomic, assign, getter = isEnabled) BOOL enabled;

/// 保存对tableView的弱引用，在布局时可能会使用到tableView的一些属性例如separatorColor等。只有使用下面两个 initForTableView: 的接口初始化时这个属性才有值，否则就只能自己初始化后赋值
@property(nonatomic, weak) QMUITableView *parentTableView;

/// cell处于section中的位置，只有在cellForRowAtIndexPath里面调用了updateCellAppearanceWithIndexPath:才会去设置这个position
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
- (instancetype)initForTableView:(QMUITableView *)tableView withStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier;

/// 同上
- (instancetype)initForTableView:(QMUITableView *)tableView withReuseIdentifier:(NSString *)reuseIdentifier;

@end


@interface QMUITableViewCell (QMUISubclassingHooks)

/// 用于继承的接口，设置一些cell相关的UI，需要自 cellForRowAtIndexPath 里面调用。默认实现是设置当前cell在哪个position。
- (void)updateCellAppearanceWithIndexPath:(NSIndexPath *)indexPath;

@end
