//
//  QMUIStaticTableViewCellData.m
//  qmui
//
//  Created by MoLice on 15/5/3.
//  Copyright (c) 2015年 QMUI Team. All rights reserved.
//

#import "QMUIStaticTableViewCellData.h"
#import "QMUIHelper.h"
#import "QMUITableViewCell.h"
#import "QMUICommonDefines.h"

@implementation QMUIStaticTableViewCellData

+ (instancetype)staticTableViewCellDataWithIdentifier:(NSInteger)identifier
                                                image:(UIImage *)image
                                                 text:(NSString *)text
                                           detailText:(NSString *)detailText
                                        accessoryType:(QMUIStaticTableViewCellAccessoryType)accessoryType
                                               target:(id)target
                                               action:(SEL)action {
    return [QMUIStaticTableViewCellData staticTableViewCellDataWithIdentifier:identifier
                                                                        style:UITableViewCellStyleDefault
                                                                        image:image
                                                                         text:text
                                                                   detailText:detailText
                                                                accessoryType:accessoryType
                                                         accessoryValueObject:nil
                                                                       target:target
                                                                       action:action];
}

+ (instancetype)staticTableViewCellDataWithIdentifier:(NSInteger)identifier
                                                style:(UITableViewCellStyle)style
                                                image:(UIImage *)image
                                                 text:(NSString *)text
                                           detailText:(NSString *)detailText
                                        accessoryType:(QMUIStaticTableViewCellAccessoryType)accessoryType
                                 accessoryValueObject:(NSObject *)accessoryValueObject
                                               target:(id)target
                                               action:(SEL)action {
    QMUIStaticTableViewCellData *data = [[QMUIStaticTableViewCellData alloc] init];
    data.identifier = identifier;
    data.style = style;
    data.image = image;
    data.text = text;
    data.detailText = detailText;
    data.accessoryType = accessoryType;
    data.accessoryValueObject = accessoryValueObject;
    data.actionTarget = target;
    data.action = action;
    return data;
}

+ (UITableViewCellAccessoryType)tableViewCellAccessoryTypeWithStaticAccessoryType:(QMUIStaticTableViewCellAccessoryType)type {
    switch (type) {
        case QMUIStaticTableViewCellAccessoryTypeDisclosureIndicator:
            return UITableViewCellAccessoryDisclosureIndicator;
        case QMUIStaticTableViewCellAccessoryTypeDetailDisclosureButton:
            return UITableViewCellAccessoryDisclosureIndicator;
        case QMUIStaticTableViewCellAccessoryTypeCheckmark:
            return UITableViewCellAccessoryCheckmark;
        case QMUIStaticTableViewCellAccessoryTypeDetailButton:
            return UITableViewCellAccessoryDetailButton;
        case QMUIStaticTableViewCellAccessoryTypeSwitch:
        default:
            return UITableViewCellAccessoryNone;
    }
}

@end


@implementation QMUIHelper (StaticTableViewController)

+ (QMUIStaticTableViewCellData *)staticTableCellDataInDataSource:(NSArray *)dataSource withIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section >= dataSource.count) {
        NSLog(@"cellDataWithIndexPath:[%lu-%lu], data not exist in section!", (long)indexPath.section, (long)indexPath.row);
        return nil;
    }
    
    NSArray *rowDatas = [dataSource objectAtIndex:indexPath.section];
    if (indexPath.row >= rowDatas.count) {
        NSLog(@"cellDataWithIndexPath:[%lu-%lu], data not exist in row!", (long)indexPath.section, (long)indexPath.row);
        return nil;
    }
    
    return [rowDatas objectAtIndex:indexPath.row];
}

+ (NSString *)staticTableViewReuseIdentifierAtIndexPath:(NSIndexPath *)indexPath withDataSource:(NSArray *)dataSource {
    QMUIStaticTableViewCellData *data = [QMUIHelper staticTableCellDataInDataSource:dataSource withIndexPath:indexPath];
    return [NSString stringWithFormat:@"cell%lu", (long)data.identifier];
}

+ (UITableViewCell *)staticTableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath ofClass:(Class)cellClass withDataSource:(NSArray *)dataSource {
    
    QMUIStaticTableViewCellData *data = [QMUIHelper staticTableCellDataInDataSource:dataSource withIndexPath:indexPath];
    if (!data) {
        return nil;
    }
    
    NSString *identifier = [QMUIHelper staticTableViewReuseIdentifierAtIndexPath:indexPath withDataSource:dataSource];
    if (!cellClass) {
        cellClass = [QMUITableViewCell class];
    }
    
    NSAssert([cellClass isSubclassOfClass:[QMUITableViewCell class]], @"staticTableView不支持非QMUITableViewCell子类的class");
    
    QMUITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (!cell) {
        cell = [[cellClass alloc] initForTableView:(QMUITableView *)tableView withStyle:data.style reuseIdentifier:identifier];
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
        [switcher addTarget:data.actionTarget action:data.action forControlEvents:UIControlEventValueChanged];
        cell.accessoryView = switcher;
    }
    
    // 统一设置selectionStyle
    if (data.accessoryType == QMUIStaticTableViewCellAccessoryTypeSwitch) {
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    } else {
        cell.selectionStyle = UITableViewCellSelectionStyleBlue;
    }
    
    [cell updateCellAppearanceWithIndexPath:indexPath];

    return cell;
}

+ (UITableViewCell *)staticTableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath withDataSource:(NSArray *)dataSource {
    return [QMUIHelper staticTableView:tableView cellForRowAtIndexPath:indexPath ofClass:[QMUITableViewCell class] withDataSource:dataSource];
}

+ (void)staticTableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath withDataSource:(NSArray *)dataSource {
    QMUIStaticTableViewCellData *cellData = [QMUIHelper staticTableCellDataInDataSource:dataSource withIndexPath:indexPath];
    if (!cellData || !cellData.actionTarget || !cellData.action) {
        UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
        if (cell.selectionStyle != UITableViewCellSelectionStyleNone) {
            [tableView deselectRowAtIndexPath:indexPath animated:YES];
        }
        return;
    }
    
    // 1、分发选中事件（对于switch类型的，交给UISwitch响应，选中cell不响应）
    if ([cellData.actionTarget respondsToSelector:cellData.action] && cellData.accessoryType != QMUIStaticTableViewCellAccessoryTypeSwitch) {
        BeginIgnorePerformSelectorLeaksWarning
        [cellData.actionTarget performSelector:cellData.action withObject:cellData];
        EndIgnorePerformSelectorLeaksWarning
    }
    
    // 2、处理点击状态（对checkmark类型的cell，选中后自动反选）
    if (cellData.accessoryType == QMUIStaticTableViewCellAccessoryTypeCheckmark) {
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
    }
}

@end

