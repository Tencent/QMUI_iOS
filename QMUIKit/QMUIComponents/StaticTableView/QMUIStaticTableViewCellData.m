/**
 * Tencent is pleased to support the open source community by making QMUI_iOS available.
 * Copyright (C) 2016-2021 THL A29 Limited, a Tencent company. All rights reserved.
 * Licensed under the MIT License (the "License"); you may not use this file except in compliance with the License. You may obtain a copy of the License at
 * http://opensource.org/licenses/MIT
 * Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.
 */

//
//  QMUIStaticTableViewCellData.m
//  qmui
//
//  Created by QMUI Team on 15/5/3.
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
    return [self staticTableViewCellDataWithIdentifier:identifier
                                             cellClass:[QMUITableViewCell class]
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
                                            cellClass:(Class)cellClass
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
    QMUIStaticTableViewCellData *data = [[self alloc] init];
    data.identifier = identifier;
    data.cellClass = cellClass;
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
        self.cellClass = [QMUITableViewCell class];
        self.height = TableViewCellNormalHeight;
    }
    return self;
}

- (void)setCellClass:(Class)cellClass {
    NSAssert([cellClass isSubclassOfClass:[QMUITableViewCell class]], @"%@.cellClass 必须为 QMUITableViewCell 的子类", NSStringFromClass(self.class));
    _cellClass = cellClass;
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
