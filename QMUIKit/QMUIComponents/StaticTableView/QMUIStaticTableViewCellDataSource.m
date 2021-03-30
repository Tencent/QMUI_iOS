/**
 * Tencent is pleased to support the open source community by making QMUI_iOS available.
 * Copyright (C) 2016-2021 THL A29 Limited, a Tencent company. All rights reserved.
 * Licensed under the MIT License (the "License"); you may not use this file except in compliance with the License. You may obtain a copy of the License at
 * http://opensource.org/licenses/MIT
 * Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.
 */

//
//  QMUIStaticTableViewCellDataSource.m
//  qmui
//
//  Created by QMUI Team on 2017/6/20.
//

#import "QMUIStaticTableViewCellDataSource.h"
#import "QMUICore.h"
#import "QMUIStaticTableViewCellData.h"
#import "QMUITableViewCell.h"
#import "UITableView+QMUIStaticCell.h"
#import "QMUILog.h"
#import "QMUIMultipleDelegates.h"
#import "NSArray+QMUI.h"

@interface QMUIStaticTableViewCellDataSource ()
@end

@implementation QMUIStaticTableViewCellDataSource

- (instancetype)init {
    if (self = [super init]) {
    }
    return self;
}

- (instancetype)initWithCellDataSections:(NSArray<NSArray<QMUIStaticTableViewCellData *> *> *)cellDataSections {
    if (self = [super init]) {
        self.cellDataSections = cellDataSections;
    }
    return self;
}

- (void)setCellDataSections:(NSArray<NSArray<QMUIStaticTableViewCellData *> *> *)cellDataSections {
#ifdef DEBUG
    [cellDataSections qmui_enumerateNestedArrayWithBlock:^(QMUIStaticTableViewCellData *obj, BOOL * _Nonnull stop) {
        NSAssert([obj isKindOfClass:QMUIStaticTableViewCellData.class], @"cellDataSections 内只允许出现 QMUIStatictableViewCellData 类型的元素");
    }];
#endif
    _cellDataSections = cellDataSections;
    [self.tableView reloadData];
}

// 在 UITableView (QMUI_StaticCell) 那边会把 tableView 的 property 改为 readwrite，所以这里补上 setter
- (void)setTableView:(UITableView *)tableView {
    _tableView = tableView;
    // 触发 UITableView (QMUI_StaticCell) 里重写的 setter 里的逻辑
    tableView.delegate = tableView.delegate;
    tableView.dataSource = tableView.dataSource;
}

@end

@interface QMUIStaticTableViewCellData (Manual)

@property(nonatomic, strong, readwrite) NSIndexPath *indexPath;
@end

@implementation QMUIStaticTableViewCellDataSource (Manual)

- (QMUIStaticTableViewCellData *)cellDataAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section >= self.cellDataSections.count) {
        QMUILog(NSStringFromClass(self.class), @"cellDataWithIndexPath:%@, data not exist in section!", indexPath);
        return nil;
    }
    
    NSArray<QMUIStaticTableViewCellData *> *rowDatas = [self.cellDataSections objectAtIndex:indexPath.section];
    if (indexPath.row >= rowDatas.count) {
        QMUILog(NSStringFromClass(self.class), @"cellDataWithIndexPath:%@, data not exist in row!", indexPath);
        return nil;
    }
    
    QMUIStaticTableViewCellData *cellData = [rowDatas objectAtIndex:indexPath.row];
    [cellData setIndexPath:indexPath];// 在这里才为 cellData.indexPath 赋值
    return cellData;
}

- (NSString *)reuseIdentifierForCellAtIndexPath:(NSIndexPath *)indexPath {
    QMUIStaticTableViewCellData *data = [self cellDataAtIndexPath:indexPath];
    return [NSString stringWithFormat:@"cell_%@", @(data.identifier)];
}

- (QMUITableViewCell *)cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    QMUIStaticTableViewCellData *data = [self cellDataAtIndexPath:indexPath];
    if (!data) {
        return nil;
    }
    
    NSString *identifier = [self reuseIdentifierForCellAtIndexPath:indexPath];
    
    QMUITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:identifier];
    if (!cell) {
        cell = [[data.cellClass alloc] initForTableView:self.tableView withStyle:data.style reuseIdentifier:identifier];
    }
    cell.imageView.image = data.image;
    cell.textLabel.text = data.text;
    cell.detailTextLabel.text = data.detailText;
    cell.accessoryType = [QMUIStaticTableViewCellData tableViewCellAccessoryTypeWithStaticAccessoryType:data.accessoryType];
    
    // 为某些控件类型的accessory添加控件及相应的事件绑定
    if (data.accessoryType == QMUIStaticTableViewCellAccessoryTypeSwitch) {
        UISwitch *switcher;
        BOOL switcherOn = NO;
        if ([cell.accessoryView isKindOfClass:[UISwitch class]]) {
            switcher = (UISwitch *)cell.accessoryView;
        } else {
            switcher = [[UISwitch alloc] init];
        }
        if ([data.accessoryValueObject isKindOfClass:[NSNumber class]]) {
            switcherOn = [((NSNumber *)data.accessoryValueObject) boolValue];
        }
        switcher.on = switcherOn;
        [switcher removeTarget:nil action:NULL forControlEvents:UIControlEventAllEvents];
        if (data.accessorySwitchBlock) {
            [switcher addTarget:self action:@selector(handleSwitcherEvent:) forControlEvents:UIControlEventValueChanged];
        } else if ([data.accessoryTarget respondsToSelector:data.accessoryAction]) {
            [switcher addTarget:data.accessoryTarget action:data.accessoryAction forControlEvents:UIControlEventValueChanged];
        }
        cell.accessoryView = switcher;
    }
    
    // 统一设置selectionStyle
    if (data.accessoryType == QMUIStaticTableViewCellAccessoryTypeSwitch || (!data.didSelectBlock && (!data.didSelectTarget || !data.didSelectAction))) {
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    } else {
        cell.selectionStyle = UITableViewCellSelectionStyleBlue;
    }
    
    [cell updateCellAppearanceWithIndexPath:indexPath];
    
    if (data.cellForRowBlock) {
        data.cellForRowBlock(self.tableView, cell, data);
    }
    
    return cell;
}

- (CGFloat)heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    QMUIStaticTableViewCellData *cellData = [self cellDataAtIndexPath:indexPath];
    return cellData.height;
}

- (void)didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    QMUIStaticTableViewCellData *cellData = [self cellDataAtIndexPath:indexPath];
    if (!cellData || (!cellData.didSelectBlock && (!cellData.didSelectTarget || !cellData.didSelectAction))) {
        QMUITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
        if (cell.selectionStyle != UITableViewCellSelectionStyleNone) {
            [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
        }
        return;
    }
    
    // 1、分发选中事件（UISwitch 类型不支持 didSelect）
    if (cellData.accessoryType != QMUIStaticTableViewCellAccessoryTypeSwitch) {
        if (cellData.didSelectBlock) {
            cellData.didSelectBlock(self.tableView, cellData);
        } else if ([cellData.didSelectTarget respondsToSelector:cellData.didSelectAction]) {
            BeginIgnorePerformSelectorLeaksWarning
            [cellData.didSelectTarget performSelector:cellData.didSelectAction withObject:cellData];
            EndIgnorePerformSelectorLeaksWarning
        }
    }
    
    // 2、处理点击状态（对checkmark类型的cell，选中后自动反选）
    if (cellData.accessoryType == QMUIStaticTableViewCellAccessoryTypeCheckmark) {
        [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    }
}

- (void)accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath {
    QMUIStaticTableViewCellData *cellData = [self cellDataAtIndexPath:indexPath];
    if (cellData.accessoryBlock) {
        cellData.accessoryBlock(self.tableView, cellData);
    } else if ([cellData.accessoryTarget respondsToSelector:cellData.accessoryAction]) {
        BeginIgnorePerformSelectorLeaksWarning
        [cellData.accessoryTarget performSelector:cellData.accessoryAction withObject:cellData];
        EndIgnorePerformSelectorLeaksWarning
    }
}

- (void)handleSwitcherEvent:(UISwitch *)swicher {
    NSIndexPath *indexPath = [self.tableView qmui_indexPathForRowAtView:swicher];
    QMUIStaticTableViewCellData *cellData = [self cellDataAtIndexPath:indexPath];
    if (cellData.accessorySwitchBlock) {
        cellData.accessorySwitchBlock(self.tableView, cellData, swicher);
    }
}

@end
