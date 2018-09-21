//
//  QMUIPopupMenuButtonItem.m
//  QMUIKit
//
//  Created by MoLice on 2018/8/21.
//  Copyright © 2018年 QMUI Team. All rights reserved.
//

#import "QMUIPopupMenuButtonItem.h"
#import "QMUIButton.h"
#import "UIControl+QMUI.h"
#import "QMUIPopupMenuView.h"
#import "QMUICore.h"

@interface QMUIPopupMenuButtonItem (UIAppearance)

- (void)updateAppearanceForMenuButtonItem;
@end

@implementation QMUIPopupMenuButtonItem

+ (instancetype)itemWithImage:(UIImage *)image title:(NSString *)title handler:(nullable void (^)(QMUIPopupMenuButtonItem *))handler {
    QMUIPopupMenuButtonItem *item = [[QMUIPopupMenuButtonItem alloc] init];
    item.image = image;
    item.title = title;
    item.handler = handler;
    return item;
}

- (instancetype)init {
    if (self = [super init]) {
        self.height = -1;
        
        _button = [[QMUIButton alloc] init];
        self.button.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
        self.button.qmui_automaticallyAdjustTouchHighlightedInScrollView = YES;
        [self.button addTarget:self action:@selector(handleButtonEvent:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:self.button];
        
        [self updateAppearanceForMenuButtonItem];
    }
    return self;
}

- (CGSize)sizeThatFits:(CGSize)size {
    return [self.button sizeThatFits:size];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    self.button.frame = self.bounds;
}

- (void)setTitle:(NSString *)title {
    [super setTitle:title];
    [self.button setTitle:title forState:UIControlStateNormal];
}

- (void)setImage:(UIImage *)image {
    _image = image;
    [self.button setImage:image forState:UIControlStateNormal];
    if (image) {
        self.button.imageEdgeInsets = UIEdgeInsetsMake(0, 0, 0, self.imageMarginRight);
    } else {
        self.button.imageEdgeInsets = UIEdgeInsetsZero;
    }
}

- (void)setHighlightedBackgroundColor:(UIColor *)highlightedBackgroundColor {
    _highlightedBackgroundColor = highlightedBackgroundColor;
    self.button.highlightedBackgroundColor = highlightedBackgroundColor;
}

- (void)handleButtonEvent:(id)sender {
    if (self.handler) {
        self.handler(self);
    }
}

- (void)updateAppearance {
    self.button.titleLabel.font = self.menuView.itemTitleFont;
    [self.button setTitleColor:self.menuView.itemTitleColor forState:UIControlStateNormal];
    self.button.contentEdgeInsets = UIEdgeInsetsMake(0, self.menuView.padding.left, 0, self.menuView.padding.right);
}

@end

@implementation QMUIPopupMenuButtonItem (UIAppearance)

+ (void)initialize {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        [self setDefaultAppearanceForPopupMenuView];
    });
}

+ (void)setDefaultAppearanceForPopupMenuView {
    QMUIPopupMenuButtonItem *appearance = [QMUIPopupMenuButtonItem appearance];
    appearance.highlightedBackgroundColor = TableViewCellSelectedBackgroundColor;
    appearance.imageMarginRight = 6;
}

- (void)updateAppearanceForMenuButtonItem {
    QMUIPopupMenuButtonItem *appearance = [QMUIPopupMenuButtonItem appearance];
    self.highlightedBackgroundColor = appearance.highlightedBackgroundColor;
    self.imageMarginRight = appearance.imageMarginRight;
}

@end
