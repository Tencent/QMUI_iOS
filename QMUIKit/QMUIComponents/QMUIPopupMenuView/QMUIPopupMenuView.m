//
//  QMUIPopupMenuView.m
//  qmui
//
//  Created by MoLice on 2017/2/24.
//  Copyright © 2017年 QMUI Team. All rights reserved.
//

#import "QMUIPopupMenuView.h"
#import "QMUICore.h"
#import "UIView+QMUI.h"
#import "CALayer+QMUI.h"
#import "NSArray+QMUI.h"

@interface QMUIPopupMenuView ()

@property(nonatomic, strong) UIScrollView *scrollView;
@property(nonatomic, strong) NSMutableArray<CALayer *> *itemSeparatorLayers;
@end

@interface QMUIPopupMenuView (UIAppearance)

- (void)updateAppearanceForPopupMenuView;
@end

@implementation QMUIPopupMenuView

- (void)setItems:(NSArray<__kindof QMUIPopupMenuBaseItem *> *)items {
    [_items enumerateObjectsUsingBlock:^(__kindof QMUIPopupMenuBaseItem * _Nonnull item, NSUInteger idx, BOOL * _Nonnull stop) {
        item.menuView = nil;
    }];
    _items = items;
    if (!items) {
        self.itemSections = nil;
    } else {
        self.itemSections = @[_items];
    }
}

- (void)setItemSections:(NSArray<NSArray<__kindof QMUIPopupMenuBaseItem *> *> *)itemSections {
    [_itemSections qmui_enumerateNestedArrayWithBlock:^(__kindof QMUIPopupMenuBaseItem * item, BOOL *stop) {
        item.menuView = nil;
    }];
    _itemSections = itemSections;
    [self configureItems];
}

- (void)setItemConfigurationHandler:(void (^)(QMUIPopupMenuView *, __kindof QMUIPopupMenuBaseItem *, NSInteger, NSInteger))itemConfigurationHandler {
    _itemConfigurationHandler = [itemConfigurationHandler copy];
    if (_itemConfigurationHandler && self.itemSections.count) {
        for (NSInteger section = 0, sectionCount = self.itemSections.count; section < sectionCount; section ++) {
            NSArray<QMUIPopupMenuBaseItem *> *items = self.itemSections[section];
            for (NSInteger row = 0, rowCount = items.count; row < rowCount; row ++) {
                QMUIPopupMenuBaseItem *item = items[row];
                _itemConfigurationHandler(self, item, section, row);
            }
        }
    }
}

- (BOOL)shouldShowSeparatorAtRow:(NSInteger)row rowCount:(NSInteger)rowCount inSection:(NSInteger)section sectionCount:(NSInteger)sectionCount {
    return (!self.shouldShowSectionSeparatorOnly && self.shouldShowItemSeparator && row < rowCount - 1) || (self.shouldShowSectionSeparatorOnly && row == rowCount - 1 && section < sectionCount - 1);
}

- (void)configureItems {
    NSInteger globalItemIndex = 0;
    
    // 移除所有 item
    [self.scrollView qmui_removeAllSubviews];
    
    for (NSInteger section = 0, sectionCount = self.itemSections.count; section < sectionCount; section ++) {
        NSArray<QMUIPopupMenuBaseItem *> *items = self.itemSections[section];
        for (NSInteger row = 0, rowCount = items.count; row < rowCount; row ++) {
            QMUIPopupMenuBaseItem *item = items[row];
            item.menuView = self;
            [item updateAppearance];
            if (self.itemConfigurationHandler) {
                self.itemConfigurationHandler(self, item, section, row);
            }
            [self.scrollView addSubview:item];
            
            // 配置分隔线，注意每一个 section 里的最后一行是不显示分隔线的
            BOOL shouldShowSeparatorAtRow = [self shouldShowSeparatorAtRow:row rowCount:rowCount inSection:section sectionCount:sectionCount];
            if (globalItemIndex < self.itemSeparatorLayers.count) {
                CALayer *separatorLayer = self.itemSeparatorLayers[globalItemIndex];
                if (shouldShowSeparatorAtRow) {
                    separatorLayer.hidden = NO;
                    separatorLayer.backgroundColor = self.separatorColor.CGColor;
                } else {
                    separatorLayer.hidden = YES;
                }
            } else if (shouldShowSeparatorAtRow) {
                CALayer *separatorLayer = [CALayer layer];
                [separatorLayer qmui_removeDefaultAnimations];
                separatorLayer.backgroundColor = self.separatorColor.CGColor;
                [self.scrollView.layer addSublayer:separatorLayer];
                [self.itemSeparatorLayers addObject:separatorLayer];
            }
            
            globalItemIndex++;
        }
    }
}

#pragma mark - (UISubclassingHooks)

- (void)didInitialize {
    [super didInitialize];
    self.contentEdgeInsets = UIEdgeInsetsZero;
    
    self.scrollView = [[UIScrollView alloc] init];
    self.scrollView.scrollsToTop = NO;
    self.scrollView.showsHorizontalScrollIndicator = NO;
    self.scrollView.showsVerticalScrollIndicator = NO;
    if (@available(iOS 11, *)) {
        self.scrollView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    }
    [self.contentView addSubview:self.scrollView];
    
    self.itemSeparatorLayers = [[NSMutableArray alloc] init];
    
    [self updateAppearanceForPopupMenuView];
}

- (CGSize)sizeThatFitsInContentView:(CGSize)size {
    __block CGFloat height = UIEdgeInsetsGetVerticalValue(self.padding);
    [self.itemSections qmui_enumerateNestedArrayWithBlock:^(__kindof QMUIPopupMenuBaseItem *item, BOOL *stop) {
        height += item.height >= 0 ? item.height : self.itemHeight;
    }];
    size.height = MIN(height, size.height);
    return size;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    self.scrollView.frame = self.contentView.bounds;
    
    CGFloat minY = self.padding.top;
    CGFloat contentWidth = CGRectGetWidth(self.scrollView.bounds);
    NSInteger separatorIndex = 0;
    for (NSInteger section = 0, sectionCount = self.itemSections.count; section < sectionCount; section ++) {
        NSArray<QMUIPopupMenuBaseItem *> *items = self.itemSections[section];
        for (NSInteger row = 0, rowCount = items.count; row < rowCount; row ++) {
            QMUIPopupMenuBaseItem *item = items[row];
            item.frame = CGRectMake(0, minY, contentWidth, item.height >= 0 ? item.height : self.itemHeight);
            minY = CGRectGetMaxY(item.frame);
            
            BOOL shouldShowSeparatorAtRow = [self shouldShowSeparatorAtRow:row rowCount:rowCount inSection:section sectionCount:sectionCount];
            if (shouldShowSeparatorAtRow) {
                self.itemSeparatorLayers[separatorIndex].frame = CGRectMake(self.separatorInset.left, minY - PixelOne + self.separatorInset.top - self.separatorInset.bottom, contentWidth - UIEdgeInsetsGetHorizontalValue(self.separatorInset), PixelOne);
                separatorIndex++;
            }
        }
    }
    minY += self.padding.bottom;
    self.scrollView.contentSize = CGSizeMake(contentWidth, minY);
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
    appearance.shouldShowItemSeparator = NO;
    appearance.shouldShowSectionSeparatorOnly = NO;
    appearance.separatorColor = UIColorSeparator;
    appearance.itemTitleFont = UIFontMake(16);
    appearance.itemTitleColor = UIColorBlue;
    appearance.padding = UIEdgeInsetsMake([QMUIPopupContainerView appearance].cornerRadius / 2.0, 16, [QMUIPopupContainerView appearance].cornerRadius / 2.0, 16);
    appearance.itemHeight = 44;
    appearance.separatorInset = UIEdgeInsetsZero;
}

- (void)updateAppearanceForPopupMenuView {
    QMUIPopupMenuView *appearance = [QMUIPopupMenuView appearance];
    self.shouldShowItemSeparator = appearance.shouldShowItemSeparator;
    self.shouldShowSectionSeparatorOnly = appearance.shouldShowSectionSeparatorOnly;
    self.separatorColor = appearance.separatorColor;
    self.itemTitleFont = appearance.itemTitleFont;
    self.itemTitleColor = appearance.itemTitleColor;
    self.padding = appearance.padding;
    self.itemHeight = appearance.itemHeight;
    self.separatorInset = appearance.separatorInset;
}

@end
