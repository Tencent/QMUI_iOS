//
//  QMUIPopupMenuItemView.m
//  QMUIKit
//
//  Created by molice on 2024/6/17.
//  Copyright © 2024 QMUI Team. All rights reserved.
//

#import "QMUIPopupMenuItemView.h"
#import "QMUICore.h"
#import "UIControl+QMUI.h"
#import "QMUIPopupMenuView.h"
#import "QMUILayouter.h"
#import "QMUIButton.h"
#import "QMUICheckbox.h"
#import "UIView+QMUI.h"

@interface QMUIPopupMenuItemView ()
@property(nonatomic, assign) QMUIPopupMenuSelectedStyle selectedStyle;
@property(nonatomic, assign) QMUIPopupMenuSelectedLayout selectedLayout;
@end

@implementation QMUIPopupMenuItemView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        _button = [[QMUIButton alloc] init];
        _button.userInteractionEnabled = NO;
        _button.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeading;
        _button.spacingBetweenImageAndTitle = 12;
        _button.titleLabel.font = UIFontMake(16);
        _button.subtitleLabel.font = UIFontMake(14);
        _button.subtitleLabel.alpha = .6;
        _button.adjustsTitleTintColorAutomatically = YES;
        _button.tintColor = nil;// 跟随 superview
        [self addSubview:_button];
        
        _padding = UIEdgeInsetsMake(8, 0, 8, 0);
        _spacingBetweenButtonAndCheck = 16;
        
        if (QMUICMIActivated) {
            self.highlightedBackgroundColor = TableViewGroupedCellSelectedBackgroundColor;
        }
    }
    return self;
}

- (QMUILayouterItem *)generateLayouter {
    QMUILayouterItem *button = [QMUILayouterItem itemWithView:self.button margin:UIEdgeInsetsZero grow:1 shrink:QMUILayouterShrinkDefault];
    UIView *checkView = self.selectedStyle == QMUIPopupMenuSelectedStyleCheckmark ? self.checkmark : (self.selectedStyle == QMUIPopupMenuSelectedStyleCheckbox ? self.checkbox : nil);
    QMUILayouterItem *check = checkView ? [QMUILayouterItem itemWithView:checkView margin:UIEdgeInsetsZero grow:QMUILayouterGrowNever shrink:QMUILayouterShrinkNever] : nil;
    check.visibleBlock = ^BOOL(QMUILayouterItem * _Nonnull aItem) {
        return YES;// 不管 checkView 显示与否都一定占位，避免切换 selected 过程中内容宽度跳动
    };
    NSArray<QMUILayouterItem *> *items = nil;
    if (check) {
        if (self.selectedLayout == QMUIPopupMenuSelectedLayoutAtEnd) {
            items = @[button, check];
        } else if (self.selectedLayout == QMUIPopupMenuSelectedLayoutAtStart) {
            items = @[check, button];
        }
    } else {
        items = @[button];
    }
    QMUILayouterLinearHorizontal *h = [QMUILayouterLinearHorizontal itemWithChildItems:items spacingBetweenItems:_spacingBetweenButtonAndCheck horizontal:QMUILayouterAlignmentFill vertical:QMUILayouterAlignmentCenter];
    h.margin = self.padding;
    QMUILayouterLinearHorizontal *container = [QMUILayouterLinearHorizontal itemWithChildItems:@[h] spacingBetweenItems:0 horizontal:QMUILayouterAlignmentFill vertical:QMUILayouterAlignmentCenter];
    return container;
}

- (CGSize)sizeThatFits:(CGSize)size {
    return [[self generateLayouter] sizeThatFits:size];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    QMUILayouterItem *l = [self generateLayouter];
    l.frame = self.bounds;
    [l layoutIfNeeded];
}

- (void)setEnabled:(BOOL)enabled {
    [super setEnabled:enabled];
    [self updateAlphaState];
}

- (void)setHighlighted:(BOOL)highlighted {
    [super setHighlighted:highlighted];
    [self updateAlphaState];
}

- (void)setSelected:(BOOL)selected {
    [super setSelected:selected];
    self.button.selected = selected;// 同步状态以使 button 上也可以感知到 selected
    if (self.selectedStyle == QMUIPopupMenuSelectedStyleCheckmark) {
        self.checkmark.hidden = !selected;
    } else if (self.selectedStyle == QMUIPopupMenuSelectedStyleCheckbox) {
        self.checkbox.hidden = NO;
        self.checkbox.selected = selected;
    } else {
        self.checkmark.hidden = YES;
        self.checkbox.hidden = YES;
        self.checkbox.selected = NO;
    }
}

- (void)setSelectedStyle:(QMUIPopupMenuSelectedStyle)selectedStyle {
    _selectedStyle = selectedStyle;
    if (selectedStyle == QMUIPopupMenuSelectedStyleCheckmark) {
        if (!_checkmark) {
            _checkmark = [[UIImageView alloc] initWithImage:[TableViewCellCheckmarkImage imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate]];
            [self addSubview:_checkmark];
        }
        _checkmark.hidden = !self.selected;
        _checkbox.hidden = YES;
    } else if (selectedStyle == QMUIPopupMenuSelectedStyleCheckbox) {
        if (!_checkbox) {
            _checkbox = QMUICheckbox.new;
            _checkbox.tintColor = nil;
            _checkbox.userInteractionEnabled = NO;
            [self addSubview:_checkbox];
        }
        _checkbox.hidden = NO;
        _checkbox.selected = self.selected;
        _checkmark.hidden = YES;
    } else {
        _checkmark.hidden = YES;
        _checkbox.hidden = YES;
    }
    [self setNeedsLayout];
}

- (void)setSelectedLayout:(QMUIPopupMenuSelectedLayout)selectedLayout {
    _selectedLayout = selectedLayout;
    [self setNeedsLayout];
}

- (void)updateAlphaState {
    if (!self.enabled) {
        [self.subviews enumerateObjectsUsingBlock:^(__kindof UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            obj.alpha = UIControlDisabledAlpha;
        }];
        if (self.highlightedBackgroundColor) {
            self.backgroundColor = nil;
        }
        return;
    }
    
    [self.subviews enumerateObjectsUsingBlock:^(__kindof UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        obj.alpha = 1;
    }];
    if (self.highlighted) {
        if (self.highlightedBackgroundColor) {
            self.backgroundColor = self.highlightedBackgroundColor;
        }
        return;
    }
    if (self.highlightedBackgroundColor) {
        self.backgroundColor = nil;
    }
}

#pragma mark - <QMUIPopupMenuItemViewProtocol>

@synthesize item = _item;
- (void)setItem:(__kindof QMUIPopupMenuItem *)item {
    _item = item;
    [self.button setImage:item.image.renderingMode == UIImageRenderingModeAutomatic ? [item.image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] : item.image forState:UIControlStateNormal];
    [self.button setTitle:item.title forState:UIControlStateNormal];
    self.button.subtitle = item.subtitle;
    
    QMUIPopupMenuView *menu = item.menuView;
    
    self.padding = UIEdgeInsetsMake(self.padding.top, menu.padding.left, self.padding.bottom, menu.padding.right);
    
    if (menu.allowsSelection) {
        self.selectedStyle = menu.selectedStyle;
        self.selectedLayout = menu.selectedLayout;
    } else {
        self.selectedStyle = (QMUIPopupMenuSelectedStyle)-1;// 表示清空
    }
    
    [self setNeedsLayout];
}

@end
