/**
 * Tencent is pleased to support the open source community by making QMUI_iOS available.
 * Copyright (C) 2016-2020 THL A29 Limited, a Tencent company. All rights reserved.
 * Licensed under the MIT License (the "License"); you may not use this file except in compliance with the License. You may obtain a copy of the License at
 * http://opensource.org/licenses/MIT
 * Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.
 */

//
//  QMUITableViewHeaderFooterView.m
//  QMUIKit
//
//  Created by QMUI Team on 2017/12/7.
//

#import "QMUITableViewHeaderFooterView.h"
#import "QMUICore.h"
#import "UIView+QMUI.h"

@implementation QMUITableViewHeaderFooterView

- (instancetype)initWithReuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithReuseIdentifier:reuseIdentifier]) {
        _titleLabel = [[UILabel alloc] init];
        self.titleLabel.numberOfLines = 0;
        [self.contentView addSubview:self.titleLabel];
        
        // remove system subviews
        self.textLabel.hidden = YES;
        self.detailTextLabel.hidden = YES;
        self.backgroundView = [[UIView alloc] init];// 去掉默认的背景，以使 self.backgroundColor 生效
    }
    return self;
}

- (void)updateAppearance {
    if (!self.parentTableView) return;
    if (self.type == QMUITableViewHeaderFooterViewTypeUnknow) return;
    
    BOOL isPlainStyleTableView = self.parentTableView.style == UITableViewStylePlain;
    
    if (self.type == QMUITableViewHeaderFooterViewTypeHeader) {
        self.titleLabel.font = isPlainStyleTableView ? TableViewSectionHeaderFont : TableViewGroupedSectionHeaderFont;
        self.titleLabel.textColor = isPlainStyleTableView ? TableViewSectionHeaderTextColor : TableViewGroupedSectionHeaderTextColor;
        self.contentEdgeInsets = isPlainStyleTableView ? TableViewSectionHeaderContentInset : TableViewGroupedSectionHeaderContentInset;
        self.accessoryViewMargins = isPlainStyleTableView ? TableViewSectionHeaderAccessoryMargins : TableViewGroupedSectionHeaderAccessoryMargins;
        self.backgroundView.backgroundColor = isPlainStyleTableView ? TableViewSectionHeaderBackgroundColor : UIColorClear;
    } else {
        self.titleLabel.font = isPlainStyleTableView ? TableViewSectionFooterFont : TableViewGroupedSectionFooterFont;
        self.titleLabel.textColor = isPlainStyleTableView ? TableViewSectionFooterTextColor : TableViewGroupedSectionFooterTextColor;
        self.contentEdgeInsets = isPlainStyleTableView ? TableViewSectionFooterContentInset : TableViewGroupedSectionFooterContentInset;
        self.accessoryViewMargins = isPlainStyleTableView ? TableViewSectionFooterAccessoryMargins : TableViewGroupedSectionFooterAccessoryMargins;
        self.backgroundView.backgroundColor = isPlainStyleTableView ? TableViewSectionFooterBackgroundColor : UIColorClear;
    }
}

- (void)layoutSubviews {
    [super layoutSubviews];
    if (self.accessoryView) {
        [self.accessoryView sizeToFit];
        self.accessoryView.qmui_right = self.contentView.qmui_width - self.contentEdgeInsets.right - self.accessoryViewMargins.right;
        self.accessoryView.qmui_top = self.contentEdgeInsets.top + CGFloatGetCenter(self.contentView.qmui_height - UIEdgeInsetsGetVerticalValue(self.contentEdgeInsets), self.accessoryView.qmui_height) + self.accessoryViewMargins.top - self.accessoryViewMargins.bottom;
    }
    
    self.titleLabel.qmui_left = self.contentEdgeInsets.left;
    self.titleLabel.qmui_extendToRight = self.accessoryView ? self.accessoryView.qmui_left - self.accessoryViewMargins.left : self.contentView.qmui_width - self.contentEdgeInsets.right;
    CGSize titleLabelSize = [self.titleLabel sizeThatFits:CGSizeMake(self.titleLabel.qmui_width, CGFLOAT_MAX)];
    self.titleLabel.qmui_top = self.contentEdgeInsets.top + CGFloatGetCenter(self.contentView.qmui_height - UIEdgeInsetsGetVerticalValue(self.contentEdgeInsets), titleLabelSize.height);
    self.titleLabel.qmui_height = titleLabelSize.height;
}

- (CGSize)sizeThatFits:(CGSize)size {
    CGSize resultSize = size;
    
    CGSize accessoryViewSize = self.accessoryView ? self.accessoryView.frame.size : CGSizeZero;
    if (self.accessoryView) {
        accessoryViewSize.width = accessoryViewSize.width + UIEdgeInsetsGetHorizontalValue(self.accessoryViewMargins);
        accessoryViewSize.height = accessoryViewSize.height + UIEdgeInsetsGetVerticalValue(self.accessoryViewMargins);
    }
    
    CGFloat titleLabelWidth = size.width - UIEdgeInsetsGetHorizontalValue(self.contentEdgeInsets) - accessoryViewSize.width;
    CGSize titleLabelSize = [self.titleLabel sizeThatFits:CGSizeMake(titleLabelWidth, CGFLOAT_MAX)];
    
    resultSize.height = fmax(titleLabelSize.height, accessoryViewSize.height) + UIEdgeInsetsGetVerticalValue(self.contentEdgeInsets);
    return resultSize;
}

#pragma mark - getter / setter

- (void)setAccessoryView:(UIView *)accessoryView {
    if (_accessoryView && _accessoryView != accessoryView) {
        [_accessoryView removeFromSuperview];
    }
    _accessoryView = accessoryView;
    [self.contentView addSubview:accessoryView];
}

- (void)setParentTableView:(UITableView *)parentTableView {
    _parentTableView = parentTableView;
    [self updateAppearance];
}

- (void)setType:(QMUITableViewHeaderFooterViewType)type {
    _type = type;
    [self updateAppearance];
}

- (void)setContentEdgeInsets:(UIEdgeInsets)contentEdgeInsets {
    _contentEdgeInsets = contentEdgeInsets;
    [self setNeedsLayout];
}

- (void)setAccessoryViewMargins:(UIEdgeInsets)accessoryViewMargins {
    _accessoryViewMargins = accessoryViewMargins;
    [self setNeedsLayout];
}

@end
