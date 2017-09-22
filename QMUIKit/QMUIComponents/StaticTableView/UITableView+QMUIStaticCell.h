//
//  UITableView+QMUIStaticCell.h
//  qmui
//
//  Created by MoLice on 2017/6/20.
//  Copyright © 2017年 QMUI Team. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@class QMUIStaticTableViewCellDataSource;

/**
 *  配合 QMUIStaticTableViewCellDataSource 使用，主要负责：
 *  1. 提供 property 去绑定一个 static dataSource
 *  2. 重写 setDataSource:、setDelegate: 方法，自动实现 UITableViewDataSource、UITableViewDelegate 里一些必要的方法
 *
 *  使用方式：初始化一个 QMUIStaticTableViewCellDataSource 并将其赋值给 qmui_staticCellDataSource 属性即可。
 *
 *  @warning 当要动态更新 dataSource 时，可直接修改 self.qmui_staticCellDataSource.cellDataSections 数组，或者创建一个新的 QMUIStaticTableViewCellDataSource。不管用哪种方法，都不需要手动调用 reloadData，tableView 会自动刷新的。
 */
@interface UITableView (QMUI_StaticCell)

@property(nonatomic, strong) QMUIStaticTableViewCellDataSource *qmui_staticCellDataSource;
@end
