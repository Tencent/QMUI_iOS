//
//  QMUIPopupMenuView.m
//  qmui
//
//  Created by MoLice on 2017/2/24.
//  Copyright © 2017年 QMUI Team. All rights reserved.
//

#import "QMUIPopupMenuView.h"
#import "QMUIButton.h"
#import "UIView+QMUI.h"
#import "CALayer+QMUI.h"
#import "UIButton+QMUI.h"
#import "QMUICommonDefines.h"
#import "QMUIConfiguration.h"

@interface QMUIPopupMenuItem ()

@property(nonatomic, strong, readwrite) QMUIButton *button;
@end

@interface QMUIPopupMenuView ()

@property(nonatomic, strong) UIScrollView *scrollView;
@property(nonatomic, strong) NSMutableArray<CALayer *> *itemSeparatorLayers;
@end

@interface QMUIPopupMenuView (UIAppearance)

- (void)updateAppearanceForPopupMenuView;
@end

@implementation QMUIPopupMenuView

- (void)setItems:(NSArray<QMUIPopupMenuItem *> *)items {
    _items = items;
    self.itemSections = @[_items];
}

- (void)setItemSections:(NSArray<NSArray<QMUIPopupMenuItem *> *> *)itemSections {
    _itemSections = itemSections;
    [self configureItems];
}

- (BOOL)shouldShowSeparatorAtRow:(NSInteger)row rowCount:(NSInteger)rowCount inSection:(NSInteger)section sectionCount:(NSInteger)sectionCount {
    return (!self.shouldShowSectionSeparatorOnly && self.shouldShowItemSeparator && row < rowCount - 1) || (self.shouldShowSectionSeparatorOnly && row == rowCount - 1 && section < sectionCount - 1);
}

- (void)configureItems {
    NSInteger globalItemIndex = 0;
    
    // 移除所有 item
    [self.scrollView qmui_removeAllSubviews];
    
    for (NSInteger section = 0, sectionCount = self.itemSections.count; section < sectionCount; section ++) {
        NSArray<QMUIPopupMenuItem *> *items = self.itemSections[section];
        for (NSInteger row = 0, rowCount = items.count; row < rowCount; row ++) {
            QMUIPopupMenuItem *item = items[row];
            item.button.titleLabel.font = self.itemTitleFont;
            item.button.highlightedBackgroundColor = self.itemHighlightedBackgroundColor;
            item.button.imageEdgeInsets = UIEdgeInsetsMake(0, -self.imageMarginRight, 0, self.imageMarginRight);
            item.button.contentEdgeInsets = UIEdgeInsetsMake(0, self.padding.left - item.button.imageEdgeInsets.left, 0, self.padding.right);
            [self.scrollView addSubview:item.button];
            
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

- (void)didInitialized {
    [super didInitialized];
    self.contentEdgeInsets = UIEdgeInsetsZero;
    
    self.scrollView = [[UIScrollView alloc] init];
    self.scrollView.scrollsToTop = NO;
    self.scrollView.showsHorizontalScrollIndicator = NO;
    self.scrollView.showsVerticalScrollIndicator = NO;
    [self.contentView addSubview:self.scrollView];
    
    self.itemSeparatorLayers = [[NSMutableArray alloc] init];
    
    [self updateAppearanceForPopupMenuView];
}

- (CGSize)sizeThatFitsInContentView:(CGSize)size {
    CGFloat height = UIEdgeInsetsGetVerticalValue(self.padding);
    for (NSArray<QMUIPopupMenuItem *> *section in self.itemSections) {
        height += section.count * self.itemHeight;
    }
    size.height = fminf(height, size.height);
    return size;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    self.scrollView.frame = self.contentView.bounds;
    
    CGFloat minY = self.padding.top;
    CGFloat contentWidth = CGRectGetWidth(self.scrollView.bounds);
    NSInteger separatorIndex = 0;
    for (NSInteger section = 0, sectionCount = self.itemSections.count; section < sectionCount; section ++) {
        NSArray<QMUIPopupMenuItem *> *items = self.itemSections[section];
        for (NSInteger row = 0, rowCount = items.count; row < rowCount; row ++) {
            QMUIButton *button = items[row].button;
            button.frame = CGRectMake(0, minY, contentWidth, self.itemHeight);
            minY = CGRectGetMaxY(button.frame);
            
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
    appearance.separatorColor = UIColorSeparator;
    appearance.itemTitleFont = UIFontMake(16);
    appearance.itemHighlightedBackgroundColor = TableViewCellSelectedBackgroundColor;
    appearance.padding = UIEdgeInsetsMake([QMUIPopupContainerView appearance].cornerRadius / 2.0, 16, [QMUIPopupContainerView appearance].cornerRadius / 2.0, 16);
    appearance.itemHeight = 44;
    appearance.imageMarginRight = 6;
    appearance.separatorInset = UIEdgeInsetsZero;
}

- (void)updateAppearanceForPopupMenuView {
    QMUIPopupMenuView *appearance = [QMUIPopupMenuView appearance];
    self.separatorColor = appearance.separatorColor;
    self.itemTitleFont = appearance.itemTitleFont;
    self.itemHighlightedBackgroundColor = appearance.itemHighlightedBackgroundColor;
    self.padding = appearance.padding;
    self.itemHeight = appearance.itemHeight;
    self.imageMarginRight = appearance.imageMarginRight;
    self.separatorInset = appearance.separatorInset;
}

@end

@implementation QMUIPopupMenuItem

+ (instancetype)itemWithImage:(UIImage *)image title:(NSString *)title handler:(void (^)())handler {
    QMUIPopupMenuItem *item = [[QMUIPopupMenuItem alloc] init];
    item.image = image;
    item.title = title;
    item.handler = handler;
    
    QMUIButton *button = [[QMUIButton alloc] initWithImage:image title:title];
    button.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    button.qmui_needsTakeOverTouchEvent = YES;
    [button addTarget:item action:@selector(handleButtonEvent:) forControlEvents:UIControlEventTouchUpInside];
    item.button = button;
    return item;
}

- (void)setTitle:(NSString *)title {
    _title = title;
    [self.button setTitle:title forState:UIControlStateNormal];
}

- (void)setImage:(UIImage *)image {
    _image = image;
    [self.button setImage:image forState:UIControlStateNormal];
}

- (void)handleButtonEvent:(id)sender {
    if (self.handler) {
        self.handler();
    }
}

@end
