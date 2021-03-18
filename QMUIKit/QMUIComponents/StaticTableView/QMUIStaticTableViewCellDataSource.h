/**
 * Tencent is pleased to support the open source community by making QMUI_iOS available.
 * Copyright (C) 2016-2020 THL A29 Limited, a Tencent company. All rights reserved.
 * Licensed under the MIT License (the "License"); you may not use this file except in compliance with the License. You may obtain a copy of the License at
 * http://opensource.org/licenses/MIT
 * Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.
 */

//
//  QMUIStaticTableViewCellDataSource.h
//  qmui
//
//  Created by QMUI Team on 2017/6/20.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@class QMUIStaticTableViewCellData;
@class QMUIStaticTableViewCellDataSource;
@class QMUITableViewCell;

/**
 *  这个控件是为了方便地实现那种类似设置界面的列表（每个 cell 的样式、内容、操作控件均不太一样，每个 cell 之间不复用），使用方式：
 *  1. 创建一个带 UITableView 的 viewController。
 *  2. 通过 init 或 initWithCellDataSections: 创建一个 dataSource。若通过 init 方法初始化，则请在 tableView 渲染前（viewDidLoad 或更早）手动设置一个 cellDataSections 数组。
 *  3. 将第 2 步里的 dataSource 赋值给 tableView.qmui_staticCellDataSource 即可完成一般情况下的界面展示。
 *  4. 若需要重写某些 UITableViewDataSource、UITableViewDelegate 方法，则在 viewController 里直接实现该方法，并在方法里调用 QMUIStaticTableViewCellDataSource (Manual) 提供的同名方法即可，具体可参考 QMUI Demo。
 */
@interface QMUIStaticTableViewCellDataSource : NSObject

/// 列表的数据源，是一个二维数组，其中一维表示 section，二维表示某个 section 里的 rows，每次调用这个属性的 setter 方法都会自动刷新 tableView 内容。
@property(nonatomic, copy) NSArray<NSArray<QMUIStaticTableViewCellData *> *> *cellDataSections;

/// 数据源绑定到的列表，在 UITableView (QMUI_StaticCell) 里会被赋值
@property(nonatomic, weak, readonly) UITableView *tableView;

- (instancetype)init NS_DESIGNATED_INITIALIZER;
- (instancetype)initWithCellDataSections:(NSArray<NSArray<QMUIStaticTableViewCellData *> *> *)cellDataSections NS_DESIGNATED_INITIALIZER;

@end


/// 当需要重写某些 UITableViewDataSource、UITableViewDelegate 方法时，这个分类里提供的同名方法需要在该方法中被调用，否则可能导致 QMUIStaticTableViewCellData 里设置的一些值无效。
@interface QMUIStaticTableViewCellDataSource (Manual)

/**
 *  从 dataSource 里获取处于 indexPath 位置的 QMUIStaticTableViewCellData 对象
 *  @param indexPath cell 所处的位置
 */
- (QMUIStaticTableViewCellData *)cellDataAtIndexPath:(NSIndexPath *)indexPath;

/**
 *  根据 dataSource 计算出指定的 indexPath 的 cell 所对应的 reuseIdentifier（static tableView 里一般每个 cell 的 reuseIdentifier 都是不一样的，避免复用）
 *  @param indexPath cell 所处的位置
 */
- (NSString *)reuseIdentifierForCellAtIndexPath:(NSIndexPath *)indexPath;

/**
 *  用于结合 indexPath 和 dataSource 生成 cell 的方法，其中 cell 使用的是 QMUITableViewCell
 *  @prama indexPath 当前 cell 的 indexPath
 */
- (__kindof QMUITableViewCell *)cellForRowAtIndexPath:(NSIndexPath *)indexPath;

/**
 *  从 dataSource 里获取指定位置的 cell 的高度
 *  @prama indexPath 当前 cell 的 indexPath
 *  @return 该位置的 cell 的高度
 */
- (CGFloat)heightForRowAtIndexPath:(NSIndexPath *)indexPath;

/**
 *  在 tableView:didSelectRowAtIndexPath: 里调用，可从 dataSource 里读取对应 indexPath 的 cellData，然后触发其中的 target 和 action
 *  @param indexPath 当前 cell 的 indexPath
 */
- (void)didSelectRowAtIndexPath:(NSIndexPath *)indexPath;

/**
 *  在 tableView:accessoryButtonTappedForRowWithIndexPath: 里调用，可从 dataSource 里读取对应 indexPath 的 cellData，然后触发其中的 target 和 action
 *  @param indexPath 当前 cell 的 indexPath
 */
- (void)accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath;
@end
