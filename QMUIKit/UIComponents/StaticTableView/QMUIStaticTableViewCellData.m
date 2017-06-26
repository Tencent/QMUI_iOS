//
//  QMUIStaticTableViewCellData.m
//  qmui
//
//  Created by MoLice on 15/5/3.
//  Copyright (c) 2015年 QMUI Team. All rights reserved.
//

#import "QMUIStaticTableViewCellData.h"
#import "QMUICore.h"
#import "QMUITableViewCell.h"

@implementation QMUIStaticTableViewCellData

- (void)setIndexPath:(NSIndexPath *)indexPath {
    _indexPath = indexPath;
}

+ (instancetype)staticTableViewCellDataWithIdentifier:(NSInteger)identifier
                                                image:(UIImage *)image
                                                 text:(NSString *)text
                                           detailText:(NSString *)detailText
                                      didSelectTarget:(id)didSelectTarget
                                      didSelectAction:(SEL)didSelectAction
                                        accessoryType:(QMUIStaticTableViewCellAccessoryType)accessoryType {
    return [QMUIStaticTableViewCellData staticTableViewCellDataWithIdentifier:identifier
                                                                        style:UITableViewCellStyleDefault
                                                                       height:TableViewCellNormalHeight
                                                                        image:image
                                                                         text:text
                                                                   detailText:detailText
                                                              didSelectTarget:didSelectTarget
                                                              didSelectAction:didSelectAction
                                                                accessoryType:accessoryType
                                                         accessoryValueObject:nil
                                                              accessoryTarget:nil
                                                              accessoryAction:NULL];
}

+ (instancetype)staticTableViewCellDataWithIdentifier:(NSInteger)identifier
                                                style:(UITableViewCellStyle)style
                                               height:(CGFloat)height
                                                image:(UIImage *)image
                                                 text:(NSString *)text
                                           detailText:(NSString *)detailText
                                      didSelectTarget:(id)didSelectTarget
                                      didSelectAction:(SEL)didSelectAction
                                        accessoryType:(QMUIStaticTableViewCellAccessoryType)accessoryType
                                 accessoryValueObject:(NSObject *)accessoryValueObject
                                      accessoryTarget:(id)accessoryTarget
                                      accessoryAction:(SEL)accessoryAction {
    QMUIStaticTableViewCellData *data = [[QMUIStaticTableViewCellData alloc] init];
    data.identifier = identifier;
    data.style = style;
    data.height = height;
    data.image = image;
    data.text = text;
    data.detailText = detailText;
    data.didSelectTarget = didSelectTarget;
    data.didSelectAction = didSelectAction;
    data.accessoryType = accessoryType;
    data.accessoryValueObject = accessoryValueObject;
    data.accessoryTarget = accessoryTarget;
    data.accessoryAction = accessoryAction;
    return data;
}

- (instancetype)init {
    if (self = [super init]) {
        self.height = TableViewCellNormalHeight;
    }
    return self;
}

+ (UITableViewCellAccessoryType)tableViewCellAccessoryTypeWithStaticAccessoryType:(QMUIStaticTableViewCellAccessoryType)type {
    switch (type) {
        case QMUIStaticTableViewCellAccessoryTypeDisclosureIndicator:
            return UITableViewCellAccessoryDisclosureIndicator;
        case QMUIStaticTableViewCellAccessoryTypeDetailDisclosureButton:
            return UITableViewCellAccessoryDetailDisclosureButton;
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
