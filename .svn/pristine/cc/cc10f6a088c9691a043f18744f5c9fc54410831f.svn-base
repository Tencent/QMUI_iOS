//
//  QMUITableViewHeaderFooterView.m
//  QMUIKit
//
//  Created by MoLice on 2017/12/7.
//  Copyright © 2017年 QMUI Team. All rights reserved.
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

- (void)updateStyleIfCan {
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
        self.accessoryView.qmui_right = self.contentView.qmui_width - self.contentEdgeInsets.right - self.accessoryViewMargins.right;
        self.accessoryView.qmui_top = self.contentEdgeInsets.top + CGFloatGetCenter(self.contentView.qmui_height - UIEdgeInsetsGetVerticalValue(self.contentEdgeInsets), self.accessoryView.qmui_height) + self.accessoryViewMargins.top - self.accessoryViewMargins.bottom;
    }
    
    [self.titleLabel sizeToFit];
    self.titleLabel.qmui_left = self.contentEdgeInsets.left;
    self.titleLabel.qmui_extendToRight = self.accessoryView ? self.accessoryView.qmui_left - self.accessoryViewMargins.left : self.contentView.qmui_width - self.contentEdgeInsets.right;
    self.titleLabel.qmui_top = self.contentEdgeInsets.top;
    self.titleLabel.qmui_extendToBottom = self.contentView.qmui_height - self.contentEdgeInsets.bottom;
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
    [self updateStyleIfCan];
}

- (void)setType:(QMUITableViewHeaderFooterViewType)type {
    _type = type;
    [self updateStyleIfCan];
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
