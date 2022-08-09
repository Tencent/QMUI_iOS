/**
 * Tencent is pleased to support the open source community by making QMUI_iOS available.
 * Copyright (C) 2016-2021 THL A29 Limited, a Tencent company. All rights reserved.
 * Licensed under the MIT License (the "License"); you may not use this file except in compliance with the License. You may obtain a copy of the License at
 * http://opensource.org/licenses/MIT
 * Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.
 */

//
//  QMUIPopupMenuButtonItem.m
//  QMUIKit
//
//  Created by QMUI Team on 2018/8/21.
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

+ (instancetype)itemWithImage:(UIImage *)image title:(NSString *)title handler:(nullable void (^)(__kindof QMUIPopupMenuButtonItem *))handler {
    QMUIPopupMenuButtonItem *item = [[self alloc] init];
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
        self.button.tintColor = nil;
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
    [self updateButtonImageEdgeInsets];
}

- (void)setImageMarginRight:(CGFloat)imageMarginRight {
    _imageMarginRight = imageMarginRight;
    [self updateButtonImageEdgeInsets];
}

- (void)updateButtonImageEdgeInsets {
    if (self.button.currentImage) {
        self.button.imageEdgeInsets = UIEdgeInsetsSetRight(self.button.imageEdgeInsets, self.imageMarginRight);
    }
}

- (void)setHighlightedBackgroundColor:(UIColor *)highlightedBackgroundColor {
    _highlightedBackgroundColor = highlightedBackgroundColor;
    self.button.highlightedBackgroundColor = highlightedBackgroundColor;
}

- (void)handleButtonEvent:(id)sender {
    if (self.menuView.willHandleButtonItemEventBlock) {
        BOOL found = NO;
        for (NSInteger section = 0, sectionCount = self.menuView.itemSections.count; section < sectionCount; section ++) {
            NSArray<QMUIPopupMenuBaseItem *> *items = self.menuView.itemSections[section];
            for (NSInteger row = 0, rowCount = items.count; row < rowCount; row ++) {
                QMUIPopupMenuBaseItem *item = items[row];
                if (item == self) {
                    self.menuView.willHandleButtonItemEventBlock(self.menuView, self, section, row);
                    found = YES;
                    break;
                }
            }
            if (found) {
                break;
            }
        }
    }
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
