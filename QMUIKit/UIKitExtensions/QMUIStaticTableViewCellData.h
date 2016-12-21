//
//  QMUIStaticTableViewCellData.h
//  qmui
//
//  Created by MoLice on 15/5/3.
//  Copyright (c) 2015年 QMUI Team. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "QMUIHelper.h"
#import "QMUITableViewCell.h"

typedef NS_ENUM(NSInteger, QMUIStaticTableViewCellAccessoryType) {
    QMUIStaticTableViewCellAccessoryTypeNone,
    QMUIStaticTableViewCellAccessoryTypeDisclosureIndicator,
    QMUIStaticTableViewCellAccessoryTypeDetailDisclosureButton,
    QMUIStaticTableViewCellAccessoryTypeCheckmark,
    QMUIStaticTableViewCellAccessoryTypeDetailButton,
    QMUIStaticTableViewCellAccessoryTypeSwitch,
};

@interface QMUIStaticTableViewCellData : NSObject

@property(nonatomic, assign) NSInteger identifier;
@property(nonatomic, assign) UITableViewCellStyle style;
@property(nonatomic, strong) UIImage *image;
@property(nonatomic, copy) NSString *text;
@property(nonatomic, copy) NSString *detailText;
@property(nonatomic, assign) QMUIStaticTableViewCellAccessoryType accessoryType;
@property(nonatomic, copy) NSObject *accessoryValueObject;
@property(nonatomic, assign) id actionTarget;
@property(nonatomic, assign) SEL action;
+ (instancetype)staticTableViewCellDataWithIdentifier:(NSInteger)identifier
                                                image:(UIImage *)image
                                                 text:(NSString *)text
                                           detailText:(NSString *)detailText
                                        accessoryType:(QMUIStaticTableViewCellAccessoryType)accessoryType
                                               target:(id)target
                                               action:(SEL)action;

+ (instancetype)staticTableViewCellDataWithIdentifier:(NSInteger)identifier
                                                style:(UITableViewCellStyle)style
                                                image:(UIImage *)image
                                                 text:(NSString *)text
                                           detailText:(NSString *)detailText
                                        accessoryType:(QMUIStaticTableViewCellAccessoryType)accessoryType
                                 accessoryValueObject:(NSObject *)accessoryValueObject
                                               target:(id)target
                                               action:(SEL)action;
+ (UITableViewCellAccessoryType)tableViewCellAccessoryTypeWithStaticAccessoryType:(QMUIStaticTableViewCellAccessoryType)type;
@end


@interface QMUIHelper (StaticTableView)

+ (QMUIStaticTableViewCellData *)staticTableCellDataInDataSource:(NSArray *)dataSource withIndexPath:(NSIndexPath *)indexPath;
+ (NSString *)staticTableViewReuseIdentifierAtIndexPath:(NSIndexPath *)indexPath withDataSource:(NSArray *)dataSource;

/**
 * 用于结合indexPath和dataSource生成cell的方法
 * @param tableView 要显示设置列表的UITableView
 * @prama indexPath 当前cell的indexPath
 * @param cellClass cell的Class，必须为QMUITableViewCell或它的subclass
 * @param dataSource 一个包含QMUIStaticTableViewCellData的数组
 */
+ (QMUITableViewCell *)staticTableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath ofClass:(Class)cellClass withDataSource:(NSArray *)dataSource;
+ (QMUITableViewCell *)staticTableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath withDataSource:(NSArray *)dataSource;
+ (void)staticTableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath withDataSource:(NSArray *)dataSource;
@end
