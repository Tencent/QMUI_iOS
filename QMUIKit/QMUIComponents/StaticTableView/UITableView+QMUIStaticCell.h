/**
 * Tencent is pleased to support the open source community by making QMUI_iOS available.
 * Copyright (C) 2016-2021 THL A29 Limited, a Tencent company. All rights reserved.
 * Licensed under the MIT License (the "License"); you may not use this file except in compliance with the License. You may obtain a copy of the License at
 * http://opensource.org/licenses/MIT
 * Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.
 */

//
//  UITableView+QMUIStaticCell.h
//  qmui
//
//  Created by QMUI Team on 2017/6/20.
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
