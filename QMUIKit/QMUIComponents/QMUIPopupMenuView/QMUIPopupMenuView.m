/**
 * Tencent is pleased to support the open source community by making QMUI_iOS available.
 * Copyright (C) 2016-2021 THL A29 Limited, a Tencent company. All rights reserved.
 * Licensed under the MIT License (the "License"); you may not use this file except in compliance with the License. You may obtain a copy of the License at
 * http://opensource.org/licenses/MIT
 * Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.
 */

//
//  QMUIPopupMenuView.m
//  qmui
//
//  Created by QMUI Team on 2017/2/24.
//

#import "QMUIPopupMenuView.h"
#import "QMUICore.h"
#import "UIView+QMUI.h"
#import "CALayer+QMUI.h"
#import "NSArray+QMUI.h"
#import "UIFont+QMUI.h"
#import "UITableViewCell+QMUI.h"

@interface QMUIPopupMenuCell : UITableViewCell
@property(nonatomic, strong) __kindof UIControl<QMUIPopupMenuItemViewProtocol> *itemView;
@end

@implementation QMUIPopupMenuCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        self.backgroundColor = UIColor.clearColor;
    }
    return self;
}

- (void)setItemView:(__kindof UIControl<QMUIPopupMenuItemViewProtocol> *)itemView {
    if (_itemView) return;
    _itemView = itemView;
    [self.contentView addSubview:itemView];
}

- (CGSize)sizeThatFits:(CGSize)size {
    CGSize result = [self.itemView sizeThatFits:size];
    result.height += self.qmui_borderWidth;
    return result;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    self.itemView.frame = CGRectInsetEdges(self.contentView.bounds, UIEdgeInsetsMake(0, 0, self.qmui_borderWidth, 0));
}

@end

@interface QMUIPopupMenuSectionHeaderView : UITableViewHeaderFooterView
@property(nonatomic, strong) QMUILabel *label;
@end

@implementation QMUIPopupMenuSectionHeaderView

- (instancetype)initWithReuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithReuseIdentifier:reuseIdentifier]) {
        _label = QMUILabel.new;
        _label.numberOfLines = 0;
        _label.font = UIFontMediumMake(13);
        _label.textColor = UIColorGray;
        _label.contentEdgeInsets = UIEdgeInsetsMake(12, 16, 2, 16);
        [self.contentView addSubview:self.label];
    }
    return self;
}

- (CGSize)sizeThatFits:(CGSize)size {
    return [self.label sizeThatFits:size];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    self.label.frame = self.contentView.bounds;
}

@end

@interface QMUIPopupMenuSectionFooterView : UITableViewHeaderFooterView
@end

@implementation QMUIPopupMenuSectionFooterView

- (instancetype)initWithReuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithReuseIdentifier:reuseIdentifier]) {
        self.backgroundView = [[UIView alloc] init];// 去掉默认的背景，以便屏蔽系统对背景色的控制
    }
    return self;
}

// 系统的 UITableViewHeaderFooterView 不允许修改 backgroundColor，都应该放到 backgroundView 里，但却没有在文档中写明，只有不小心误用时才会在 Xcode 控制台里提示，所以这里做个转换，保护误用的情况。
- (void)setBackgroundColor:(UIColor *)backgroundColor {
//    [super setBackgroundColor:backgroundColor];
    self.backgroundView.backgroundColor = backgroundColor;
}

@end

@interface QMUIPopupMenuView ()<QMUITableViewDataSource, QMUITableViewDelegate>
@end

@interface QMUIPopupMenuView (UIAppearance)

- (void)updateAppearanceForPopupMenuView;
@end

@implementation QMUIPopupMenuView

- (void)setItems:(NSArray<__kindof QMUIPopupMenuItem *> *)items {
    _items = items;
    self.itemSections = items ? @[_items] : nil;
}

- (void)setItemSections:(NSArray<NSArray<__kindof QMUIPopupMenuItem *> *> *)itemSections {
    [_itemSections qmui_enumerateNestedArrayWithBlock:^(__kindof QMUIPopupMenuItem *item, BOOL *stop) {
        item.menuView = nil;
    }];
    _itemSections = itemSections;
    [_itemSections qmui_enumerateNestedArrayWithBlock:^(__kindof QMUIPopupMenuItem *item, BOOL * _Nonnull stop) {
        item.menuView = self;
    }];
    [self reload];// 涉及到数据的必须立即刷新，否则容易因为异步导致 cell 里的 view 和当前的 item 不匹配的 bug
}

- (void)setSectionTitles:(NSArray<NSString *> *)sectionTitles {
    _sectionTitles = sectionTitles;
    [self reload];
}

- (void)setItemViewConfigurationHandler:(void (^)(__kindof QMUIPopupMenuView * _Nonnull, __kindof QMUIPopupMenuItem * _Nonnull, __kindof UIControl<QMUIPopupMenuItemViewProtocol> * _Nonnull, NSInteger, NSInteger))itemViewConfigurationHandler {
    _itemViewConfigurationHandler = [itemViewConfigurationHandler copy];
    [self setNeedsReload];
}

- (void)setSectionTitleConfigurationHandler:(void (^)(__kindof QMUIPopupMenuView * _Nonnull, QMUILabel * _Nonnull, NSInteger))sectionTitleConfigurationHandler {
    _sectionTitleConfigurationHandler = [sectionTitleConfigurationHandler copy];
    [self setNeedsReload];
}

- (void)setPadding:(UIEdgeInsets)padding {
    _padding = padding;
    self.tableView.contentInset = UIEdgeInsetsMake(padding.top, self.tableView.contentInset.left, padding.bottom, self.tableView.contentInset.right);
    [self setNeedsReload];
}

- (void)setShouldShowItemSeparator:(BOOL)shouldShowItemSeparator {
    _shouldShowItemSeparator = shouldShowItemSeparator;
    [self setNeedsReload];
}

- (void)setItemSeparatorInset:(UIEdgeInsets)itemSeparatorInset {
    _itemSeparatorInset = itemSeparatorInset;
    [self setNeedsReload];
}

- (void)setShouldShowSectionSeparator:(BOOL)shouldShowSectionSeparator {
    _shouldShowSectionSeparator = shouldShowSectionSeparator;
    [self setNeedsReload];
}

- (void)setSectionSeparatorHeight:(CGFloat)sectionSeparatorHeight {
    _sectionSeparatorHeight = sectionSeparatorHeight;
    [self setNeedsReload];
}

- (void)setItemHeight:(CGFloat)itemHeight {
    _itemHeight = itemHeight;
    [self setNeedsReload];
}

- (void)setSelectedStyle:(QMUIPopupMenuSelectedStyle)selectedStyle {
    _selectedStyle = selectedStyle;
    [self setNeedsReload];
}

- (void)setSelectedLayout:(QMUIPopupMenuSelectedLayout)selectedLayout {
    _selectedLayout = selectedLayout;
    [self setNeedsReload];
}

- (void)setAllowsSelection:(BOOL)allowsSelection {
    _allowsSelection = allowsSelection;
    if (!allowsSelection) {
        self.selectedItemIndexPaths = nil;
    }
    [self setNeedsReload];
}

- (void)setAllowsMultipleSelection:(BOOL)allowsMultipleSelection {
    _allowsMultipleSelection = allowsMultipleSelection;
    if (allowsMultipleSelection) {
        _allowsSelection = YES;
    } else {
        if (self.selectedItemIndexPaths.count > 1) {
            self.selectedItemIndexPaths = [self.selectedItemIndexPaths subarrayWithRange:NSMakeRange(0, 1)];
        }
    }
    [self setNeedsReload];
}

BeginIgnoreClangWarning(-Wunused-property-ivar)
- (void)setSelectedItemIndex:(NSInteger)selectedItemIndex {
    if (selectedItemIndex == NSNotFound) {
        self.selectedItemIndexPath = nil;
    } else {
        self.selectedItemIndexPath = [NSIndexPath indexPathForRow:selectedItemIndex inSection:0];
    }
}

- (void)setSelectedItemIndexPath:(NSIndexPath *)selectedItemIndexPath {
    self.selectedItemIndexPaths = selectedItemIndexPath ? @[selectedItemIndexPath] : nil;
}
EndIgnoreClangWarning

- (void)setSelectedItemIndexPaths:(NSArray<NSIndexPath *> *)selectedItemIndexPaths {
    if (!selectedItemIndexPaths.count) {
        _selectedItemIndex = NSNotFound;
        _selectedItemIndexPath = nil;
    } else {
        _selectedItemIndex = selectedItemIndexPaths.firstObject.row;
        _selectedItemIndexPath = selectedItemIndexPaths.firstObject;
    }
    _selectedItemIndexPaths = selectedItemIndexPaths;
    [self setNeedsReload];
}

- (void)setNeedsReload {
    if (_shouldInvalidateLayout) return;
    _shouldInvalidateLayout = YES;
    dispatch_async(dispatch_get_main_queue(), ^{
        if (self->_shouldInvalidateLayout) {
            [self reload];
        }
    });
}

- (void)reload {
    [self.tableView reloadData];
    if (self.isShowing) {
        [self updateLayout];// updateLayout 的 super 实现里会把 _shouldInvalidateLayout 置为 NO
    }
}

- (void)updateLayout {
    [self setNeedsLayout];
    [self layoutIfNeeded];
    [super updateLayout];
}

- (NSIndexPath *)indexPathForItem:(__kindof QMUIPopupMenuItem *)aItem {
    for (NSInteger section = 0, sectionCount = self.itemSections.count; section < sectionCount; section ++) {
        NSArray<__kindof QMUIPopupMenuItem *> *items = self.itemSections[section];
        for (NSInteger row = 0, rowCount = items.count; row < rowCount; row ++) {
            QMUIPopupMenuItem *item = items[row];
            if (item == aItem) {
                return [NSIndexPath indexPathForRow:row inSection:section];
            }
        }
    }
    return nil;
}

- (void)handleItemViewEvent:(UIControl<QMUIPopupMenuItemViewProtocol> *)itemView {
    NSIndexPath *indexPath = [self indexPathForItem:itemView.item];
    if (!indexPath) {
        NSAssert(NO, @"the indexPath for the item could not be found");
        return;
    }
    
    if (self.allowsSelection) {
        BOOL shouldSelectItem = YES;
        if (self.shouldSelectItemBlock) {
            shouldSelectItem = self.shouldSelectItemBlock(itemView.item, itemView, indexPath.section, indexPath.row);
        }
        if (shouldSelectItem) {
            NSMutableArray<NSIndexPath *> *selectedIndexPaths = self.selectedItemIndexPaths ? self.selectedItemIndexPaths.mutableCopy : [[NSMutableArray alloc] init];
            if (self.allowsMultipleSelection) {
                if (itemView.selected) {
                    [selectedIndexPaths removeObject:indexPath];
                } else {
                    [selectedIndexPaths addObject:indexPath];
                }
            } else {
                // 单选，得把其他选中都清除
                [selectedIndexPaths removeAllObjects];
                if (!itemView.selected) {
                    [selectedIndexPaths addObject:indexPath];
                }
            }
            self.selectedItemIndexPaths = selectedIndexPaths.copy;
        }
    }
    
    if (itemView.item.handler) {
        itemView.item.handler(itemView.item, itemView, indexPath.section, indexPath.row);
    }
}

- (void)setBottomAccessoryView:(__kindof UIView *)bottomAccessoryView {
    if (bottomAccessoryView != _bottomAccessoryView) {
        [_bottomAccessoryView removeFromSuperview];
    }
    _bottomAccessoryView = bottomAccessoryView;
    [self.contentView addSubview:_bottomAccessoryView];
    [self setNeedsUpdateLayout];
}

- (void)tintColorDidChange {
    [super tintColorDidChange];
    [self setNeedsReload];
}

- (NSString *)reuseIdentifierAtIndexPath:(NSIndexPath *)indexPath forType:(NSInteger)type {
    if (self.shouldReuseItems) {
        return @[@"cell", @"header", @"footer"][type];
    }
    if (type == 0) {
        QMUIPopupMenuItem *item = self.itemSections[indexPath.section][indexPath.row];
        return [NSString stringWithFormat:@"cell_%p", item];
    }
    if (type == 1) {
        return [NSString stringWithFormat:@"header_%p", self.itemSections[indexPath.section]];
    }
    if (type == 2) {
        return [NSString stringWithFormat:@"footer_%p", self.itemSections[indexPath.section]];
    }
    return nil;
}

#pragma mark - <QMUITableViewDataSource, QMUITableViewDelegate>

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.itemSections.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.itemSections[section].count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *identifier = [self reuseIdentifierAtIndexPath:indexPath forType:0];
    QMUIPopupMenuCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (!cell) {
        cell = [[QMUIPopupMenuCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    }
    if (!cell.itemView) {
        UIControl<QMUIPopupMenuItemViewProtocol> *itemView = nil;
        if (self.itemViewGenerator) {
            itemView = self.itemViewGenerator(self);
        } else {
            itemView = [[QMUIPopupMenuItemView alloc] init];
        }
        cell.itemView = itemView;
    }
    
    cell.itemView.tintColor = self.tintColor;
    
    QMUITableViewCellPosition position = [tableView qmui_positionForRowAtIndexPath:indexPath];
    if (self.shouldShowItemSeparator && !(position & QMUITableViewCellPositionLastInSection)) {
        cell.qmui_borderPosition = QMUIViewBorderPositionBottom;
        cell.qmui_borderWidth = self.itemSeparatorHeight;
        cell.qmui_borderInsets = UIEdgeInsetsMake(self.itemSeparatorInset.bottom, self.itemSeparatorInset.right, self.itemSeparatorInset.top, self.itemSeparatorInset.left);
        cell.qmui_borderColor = self.itemSeparatorColor;
    } else {
        cell.qmui_borderWidth = 0;
        cell.qmui_borderPosition = QMUIViewBorderPositionNone;
    }
    
    QMUIPopupMenuItem *item = self.itemSections[indexPath.section][indexPath.row];
    cell.itemView.item = item;
    [cell.itemView addTarget:self action:@selector(handleItemViewEvent:) forControlEvents:UIControlEventTouchUpInside];
    
    if ([self.selectedItemIndexPaths containsObject:indexPath]) {
        cell.itemView.selected = YES;
    } else {
        cell.itemView.selected = NO;
    }
    
    // 这个 block 是给业务自定义的机会，所以要放在最后面才能覆盖
    if (self.itemViewConfigurationHandler) {
        self.itemViewConfigurationHandler(self, item, cell.itemView, indexPath.section, indexPath.row);
    }
    
    if (item.configurationBlock) {
        item.configurationBlock(item, cell.itemView, indexPath.section, indexPath.row);
    }
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    QMUIPopupMenuItem *item = self.itemSections[indexPath.section][indexPath.row];
    if (item.height == QMUIViewSelfSizingHeight) {
        return UITableViewAutomaticDimension;
    }
    if (item.height >= 0 || self.itemHeight != QMUIViewSelfSizingHeight) {
        CGFloat height = item.height >= 0 ? item.height : self.itemHeight;
        QMUITableViewCellPosition position = [tableView qmui_positionForRowAtIndexPath:indexPath];
        if (self.shouldShowItemSeparator && !(position & QMUITableViewCellPositionLastInSection)) {
            height += self.itemSeparatorHeight;
        }
        return height;
    }
    return UITableViewAutomaticDimension;// self.itemHeight == QMUIViewSelfSizingHeight
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    if (section >= self.sectionTitles.count) return nil;
    NSString *string = self.sectionTitles[section];
    if (!string.length) return nil;
    NSString *identifier = [self reuseIdentifierAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:section] forType:1];
    QMUIPopupMenuSectionHeaderView *header = [tableView dequeueReusableHeaderFooterViewWithIdentifier:identifier];
    if (!header) {
        header = [[QMUIPopupMenuSectionHeaderView alloc] initWithReuseIdentifier:identifier];
    }
    header.label.text = string;
    if (self.sectionTitleConfigurationHandler) {
        self.sectionTitleConfigurationHandler(self, header.label, section);
    }
    return header;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if (section >= self.sectionTitles.count) return CGFLOAT_MIN;
    NSString *string = self.sectionTitles[section];
    if (!string.length) return CGFLOAT_MIN;
    return UITableViewAutomaticDimension;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    BOOL shouldShowSectionSeparator = self.shouldShowSectionSeparator && self.sectionSeparatorHeight;
    BOOL shouldShowSectionFooter = shouldShowSectionSeparator || self.sectionSpacing > 0;
    if (shouldShowSectionFooter && section != tableView.numberOfSections - 1) {
        NSString *identifier = [self reuseIdentifierAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:section] forType:2];
        QMUIPopupMenuSectionFooterView *footer = [tableView dequeueReusableHeaderFooterViewWithIdentifier:identifier];
        if (!footer) {
            footer = [[QMUIPopupMenuSectionFooterView alloc] initWithReuseIdentifier:identifier];
        }
        if (shouldShowSectionSeparator) {
            footer.qmui_borderPosition = QMUIViewBorderPositionTop;
            footer.qmui_borderWidth = self.sectionSeparatorHeight;
            footer.qmui_borderColor = self.sectionSeparatorColor;
            footer.qmui_borderInsets = self.sectionSeparatorInset;
        } else {
            footer.qmui_borderPosition = QMUIViewBorderPositionNone;
        }
        if (self.sectionSpacing > 0) {
            footer.backgroundColor = self.sectionSpacingColor;
        } else {
            footer.backgroundColor = nil;
        }
        return footer;
    }
    return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    if (section == tableView.numberOfSections - 1) {
        return CGFLOAT_MIN;
    }
    CGFloat height = 0;
    if (self.shouldShowSectionSeparator && self.sectionSeparatorHeight) {
        height += self.sectionSeparatorHeight;
    }
    if (self.sectionSpacing > 0) {
        height += self.sectionSpacing;
    }
    return height > 0 ? height : CGFLOAT_MIN;
}

#pragma mark - (UISubclassingHooks)

- (void)didInitialize {
    [super didInitialize];
    _adjustsWidthAutomatically = YES;
    _selectedItemIndex = NSNotFound;
    self.contentEdgeInsets = UIEdgeInsetsZero;
    
    _tableView = [[QMUITableView alloc] initWithFrame:CGRectZero style:UITableViewStyleGrouped];
    self.tableView.scrollsToTop = NO;
    self.tableView.alwaysBounceHorizontal = NO;
    self.tableView.alwaysBounceVertical = NO;
    self.tableView.showsHorizontalScrollIndicator = NO;
    self.tableView.showsVerticalScrollIndicator = NO;
    self.tableView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.backgroundColor = nil;
    self.tableView.tableHeaderView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 0, CGFLOAT_MIN)];
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 0, CGFLOAT_MIN)];// 避免尾部出现20pt空白
    self.tableView.backgroundView = UIView.new;
    self.tableView.estimatedRowHeight = self.itemHeight;
    self.tableView.estimatedSectionHeaderHeight = 20;
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    [self.contentView addSubview:self.tableView];
    
    [self updateAppearanceForPopupMenuView];
}

- (CGSize)sizeThatFitsInContentView:(CGSize)size {
    __block CGSize result = [self.tableView sizeThatFits:CGSizeMake(size.width, CGFLOAT_MAX)];
    if (self.adjustsWidthAutomatically) {
        self.tableView.frame = CGRectMakeWithSize(result);
        [self.tableView layoutIfNeeded];
        result = CGSizeZero;
        [self.itemSections enumerateObjectsUsingBlock:^(NSArray<__kindof QMUIPopupMenuItem *> * _Nonnull sectionItems, NSUInteger section, BOOL * _Nonnull aStop) {
            if (self.sectionTitles.count > section && self.sectionTitles[section].length) {
                QMUIPopupMenuSectionHeaderView *header = (QMUIPopupMenuSectionHeaderView *)[self.tableView headerViewForSection:section];
                CGSize headerSize = [header sizeThatFits:CGSizeMake(size.width, CGFLOAT_MAX)];
                result.height += headerSize.height;
                result.width = MAX(result.width, MIN(headerSize.width, size.width));
            }
            [sectionItems enumerateObjectsUsingBlock:^(__kindof QMUIPopupMenuItem * _Nonnull rowItem, NSUInteger row, BOOL * _Nonnull bStop) {
                QMUIPopupMenuCell *cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:row inSection:section]];
                CGSize itemSize = [cell.itemView sizeThatFits:CGSizeMake(size.width, CGFLOAT_MAX)];
                CGFloat itemHeight = rowItem.height;
                if (itemHeight < 0) {
                    itemHeight = self.itemHeight;
                }
                // QMUIViewSelfSizingHeight
                if (isinf(itemHeight)) {
                    itemHeight = itemSize.height;
                }
                if (self.shouldShowItemSeparator) {
                    itemHeight += self.itemSeparatorHeight;// 每个 section 结尾的那个 item 不需要算分隔线高度，在下文减去
                }
                result.height += itemHeight;
                result.width = MAX(result.width, MIN(itemSize.width, size.width));
            }];
        }];
        result.height += (self.itemSections.count - 1) * self.sectionSpacing;
        if (self.shouldShowSectionSeparator) {
            result.height += (self.itemSections.count - 1) * self.sectionSeparatorHeight;
        }
        if (self.shouldShowItemSeparator) {
            result.height -= self.itemSections.count * self.itemSeparatorHeight;// 减去每个 section 结尾的那个 item 的分隔线
        }
    }
    if (self.bottomAccessoryView) {
        CGSize accessoryViewSize = [self.bottomAccessoryView sizeThatFits:CGSizeMake(size.width, CGFLOAT_MAX)];
        result.height += accessoryViewSize.height;
    }
    result.height += UIEdgeInsetsGetVerticalValue(self.padding);// contentInset 不在系统 sizeThatFits: 返回结果内，要自己加
    return result;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    CGRect contentRect = self.contentView.bounds;
    if (self.bottomAccessoryView) {
        CGSize accessoryViewSize = [self.bottomAccessoryView sizeThatFits:CGSizeMake(CGRectGetWidth(contentRect), CGFLOAT_MAX)];
        self.bottomAccessoryView.frame = CGRectMake(0, CGRectGetHeight(contentRect) - accessoryViewSize.height, CGRectGetWidth(contentRect), accessoryViewSize.height);
        contentRect = CGRectSetHeight(contentRect, CGRectGetMinY(self.bottomAccessoryView.frame));
    }
    self.tableView.frame = contentRect;
}

@end

@implementation QMUIPopupMenuView (UIAppearance)

+ (void)initialize {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        [self setDefaultAppearanceForPopupMenuView];
    });
}

+ (void)setDefaultAppearanceForPopupMenuView {
    QMUIPopupMenuView *appearance = [QMUIPopupMenuView appearance];
    appearance.shouldShowItemSeparator = YES;
    appearance.itemSeparatorColor = UIColorSeparator;
    appearance.itemSeparatorInset = UIEdgeInsetsZero;
    appearance.itemSeparatorHeight = PixelOne;
    appearance.shouldShowSectionSeparator = YES;
    appearance.sectionSeparatorColor = UIColorSeparator;
    appearance.sectionSeparatorInset = UIEdgeInsetsZero;
    appearance.sectionSeparatorHeight = PixelOne;
    appearance.sectionSpacing = 8;
    appearance.sectionSpacingColor = UIColorSeparator;
    appearance.padding = UIEdgeInsetsMake([QMUIPopupContainerView appearance].cornerRadius / 2.0, 16, [QMUIPopupContainerView appearance].cornerRadius / 2.0, 16);
    appearance.itemHeight = 44;
}

- (void)updateAppearanceForPopupMenuView {
    QMUIPopupMenuView *appearance = [QMUIPopupMenuView appearance];
    self.shouldShowItemSeparator = appearance.shouldShowItemSeparator;
    self.itemSeparatorColor = appearance.itemSeparatorColor;
    self.itemSeparatorInset = appearance.itemSeparatorInset;
    self.itemSeparatorHeight = appearance.itemSeparatorHeight;
    self.shouldShowSectionSeparator = appearance.shouldShowSectionSeparator;
    self.sectionSeparatorHeight = appearance.sectionSeparatorHeight;
    self.sectionSeparatorColor = appearance.sectionSeparatorColor;
    self.sectionSeparatorInset = appearance.sectionSeparatorInset;
    self.sectionSeparatorHeight = appearance.sectionSeparatorHeight;
    self.sectionSpacing = appearance.sectionSpacing;
    self.sectionSpacingColor = appearance.sectionSpacingColor;
    self.padding = appearance.padding;
    self.itemHeight = appearance.itemHeight;
}

@end
