/**
 * Tencent is pleased to support the open source community by making QMUI_iOS available.
 * Copyright (C) 2016-2020 THL A29 Limited, a Tencent company. All rights reserved.
 * Licensed under the MIT License (the "License"); you may not use this file except in compliance with the License. You may obtain a copy of the License at
 * http://opensource.org/licenses/MIT
 * Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.
 */

//
//  QMUITableViewCell.m
//  qmui
//
//  Created by QMUI Team on 14-7-7.
//

#import "QMUITableViewCell.h"
#import "QMUICore.h"
#import "QMUIButton.h"
#import "UITableView+QMUI.h"
#import "UITableViewCell+QMUI.h"

@interface QMUITableViewCell() <UIScrollViewDelegate>

@property(nonatomic, assign) BOOL initByTableView;
@property(nonatomic, assign, readwrite) QMUITableViewCellPosition cellPosition;
@property(nonatomic, assign, readwrite) UITableViewCellStyle style;
@property(nonatomic, strong) UIImageView *defaultAccessoryImageView;
@property(nonatomic, strong) QMUIButton *defaultAccessoryButton;
@property(nonatomic, strong) UIView *defaultDetailDisclosureView;
@end

@implementation QMUITableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        if (!self.initByTableView) {
            [self didInitializeWithStyle:style];
        }
    }
    return self;
}

- (instancetype)initForTableView:(UITableView *)tableView withStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self.initByTableView = YES;
    if (self = [self initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.parentTableView = tableView;
        [self didInitializeWithStyle:style];// _isGroupedStyle 的值因为 parentTableView 的变化而变化，所以这里重新执行一次 didInitializeWithStyle: 里的 qmui_styledAsQMUITableViewCell
    }
    return self;
}

- (instancetype)initForTableView:(UITableView *)tableView withReuseIdentifier:(NSString *)reuseIdentifier {
    return [self initForTableView:tableView withStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier];
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
        [self didInitializeWithStyle:UITableViewCellStyleDefault];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    BOOL hasCustomAccessoryEdgeInset = self.accessoryView.superview && !UIEdgeInsetsEqualToEdgeInsets(self.accessoryEdgeInsets, UIEdgeInsetsZero);
    if (hasCustomAccessoryEdgeInset) {
        CGRect accessoryViewOldFrame = self.accessoryView.frame;
        accessoryViewOldFrame = CGRectSetX(accessoryViewOldFrame, CGRectGetMinX(accessoryViewOldFrame) - self.accessoryEdgeInsets.right);
        accessoryViewOldFrame = CGRectSetY(accessoryViewOldFrame, CGRectGetMinY(accessoryViewOldFrame) + self.accessoryEdgeInsets.top - self.accessoryEdgeInsets.bottom);
        self.accessoryView.frame = accessoryViewOldFrame;
        
        CGRect contentViewOldFrame = self.contentView.frame;
        contentViewOldFrame = CGRectSetWidth(contentViewOldFrame, CGRectGetMinX(accessoryViewOldFrame) - self.accessoryEdgeInsets.left);
        self.contentView.frame = contentViewOldFrame;
    }

    if (self.style == UITableViewCellStyleDefault || self.style == UITableViewCellStyleSubtitle) {
        
        BOOL hasCustomImageEdgeInsets = self.imageView.image && !UIEdgeInsetsEqualToEdgeInsets(self.imageEdgeInsets, UIEdgeInsetsZero);
        
        BOOL hasCustomTextLabelEdgeInsets = self.textLabel.text.length > 0 && !UIEdgeInsetsEqualToEdgeInsets(self.textLabelEdgeInsets, UIEdgeInsetsZero);
        
        BOOL shouldChangeDetailTextLabelFrame = self.style == UITableViewCellStyleSubtitle;
        BOOL hasCustomDetailLabelEdgeInsets = shouldChangeDetailTextLabelFrame && self.detailTextLabel.text.length > 0 && !UIEdgeInsetsEqualToEdgeInsets(self.detailTextLabelEdgeInsets, UIEdgeInsetsZero);
        
        CGRect imageViewFrame = self.imageView.frame;
        CGRect textLabelFrame = self.textLabel.frame;
        CGRect detailTextLabelFrame = self.detailTextLabel.frame;
        
        if (hasCustomImageEdgeInsets) {
            imageViewFrame.origin.x += self.imageEdgeInsets.left - self.imageEdgeInsets.right;
            imageViewFrame.origin.y += self.imageEdgeInsets.top - self.imageEdgeInsets.bottom;
            
            textLabelFrame.origin.x += self.imageEdgeInsets.left;
            textLabelFrame.size.width = fmin(CGRectGetWidth(textLabelFrame), CGRectGetWidth(self.contentView.bounds) - CGRectGetMinX(textLabelFrame));
            
            if (shouldChangeDetailTextLabelFrame) {
                detailTextLabelFrame.origin.x += self.imageEdgeInsets.left;
                detailTextLabelFrame.size.width = fmin(CGRectGetWidth(detailTextLabelFrame), CGRectGetWidth(self.contentView.bounds) - CGRectGetMinX(detailTextLabelFrame));
            }
        }
        if (hasCustomTextLabelEdgeInsets) {
            textLabelFrame.origin.x += self.textLabelEdgeInsets.left - self.imageEdgeInsets.right;
            textLabelFrame.origin.y += self.textLabelEdgeInsets.top - self.textLabelEdgeInsets.bottom;
            textLabelFrame.size.width = fmin(CGRectGetWidth(textLabelFrame), CGRectGetWidth(self.contentView.bounds) - CGRectGetMinX(textLabelFrame));
        }
        if (hasCustomDetailLabelEdgeInsets) {
            detailTextLabelFrame.origin.x += self.detailTextLabelEdgeInsets.left - self.detailTextLabelEdgeInsets.right;
            detailTextLabelFrame.origin.y += self.detailTextLabelEdgeInsets.top - self.detailTextLabelEdgeInsets.bottom;
            detailTextLabelFrame.size.width = fmin(CGRectGetWidth(detailTextLabelFrame), CGRectGetWidth(self.contentView.bounds) - CGRectGetMinX(detailTextLabelFrame));
        }
        
        self.imageView.frame = imageViewFrame;
        self.textLabel.frame = textLabelFrame;
        self.detailTextLabel.frame = detailTextLabelFrame;
        
        // `layoutSubviews`这里不可以拿textLabel的minX来设置separatorInset，如果要设置只能写死一个值
        // 否则会导致textLabel的minX逐渐叠加从而使textLabel被移出屏幕外
    }
    
    // 由于调整 accessoryEdgeInsets 可能会影响 contentView 的宽度，所以几个 subviews 的布局也要保护一下
    if (hasCustomAccessoryEdgeInset) {
        if (CGRectGetMaxX(self.textLabel.frame) > CGRectGetWidth(self.contentView.bounds)) {
            self.textLabel.frame = CGRectSetWidth(self.textLabel.frame, CGRectGetWidth(self.contentView.bounds) - CGRectGetMinX(self.textLabel.frame));
        }
        if (CGRectGetMaxX(self.detailTextLabel.frame) > CGRectGetWidth(self.contentView.bounds)) {
            self.detailTextLabel.frame = CGRectSetWidth(self.detailTextLabel.frame, CGRectGetWidth(self.contentView.bounds) - CGRectGetMinX(self.detailTextLabel.frame));
        }
    }
}

- (BOOL)_isGroupedStyle {
    return self.parentTableView && self.parentTableView.style == UITableViewStyleGrouped;
}

- (void)setBackgroundColor:(UIColor *)backgroundColor {
    [super setBackgroundColor:backgroundColor];
    if (self.backgroundView) {
        self.backgroundView.backgroundColor = backgroundColor;
    }
}

- (void)setEnabled:(BOOL)enabled {
    if (_enabled != enabled) {
        if (enabled) {
            self.userInteractionEnabled = YES;
            UIColor *titleLabelColor = self.qmui_styledTextLabelColor;
            if (titleLabelColor) {
                self.textLabel.textColor = titleLabelColor;
            }
            UIColor *detailLabelColor = self.qmui_styledDetailTextLabelColor;
            if (detailLabelColor) {
                self.detailTextLabel.textColor = detailLabelColor;
            }
        } else {
            self.userInteractionEnabled = NO;
            UIColor *disabledColor = UIColorDisabled;
            if (disabledColor) {
                self.textLabel.textColor = disabledColor;
                self.detailTextLabel.textColor = disabledColor;
            }
        }
        _enabled = enabled;
    }
}

- (void)initDefaultAccessoryImageViewIfNeeded {
    if (!self.defaultAccessoryImageView) {
        self.defaultAccessoryImageView = [[UIImageView alloc] init];
        self.defaultAccessoryImageView.contentMode = UIViewContentModeCenter;
    }
}

- (void)initDefaultAccessoryButtonIfNeeded {
    if (!self.defaultAccessoryButton) {
        self.defaultAccessoryButton = [[QMUIButton alloc] init];
        [self.defaultAccessoryButton addTarget:self action:@selector(handleAccessoryButtonEvent:) forControlEvents:UIControlEventTouchUpInside];
    }
}

- (void)initDefaultDetailDisclosureViewIfNeeded {
    if (!self.defaultDetailDisclosureView) {
        self.defaultDetailDisclosureView = [[UIView alloc] init];
    }
}

// 重写accessoryType，如果是UITableViewCellAccessoryDisclosureIndicator类型的，则使用 QMUIConfigurationTemplate.m 配置表里的图片
- (void)setAccessoryType:(UITableViewCellAccessoryType)accessoryType {
    [super setAccessoryType:accessoryType];
    
    if (accessoryType == UITableViewCellAccessoryDisclosureIndicator) {
        UIImage *indicatorImage = TableViewCellDisclosureIndicatorImage;
        if (indicatorImage) {
            [self initDefaultAccessoryImageViewIfNeeded];
            self.defaultAccessoryImageView.image = indicatorImage;
            [self.defaultAccessoryImageView sizeToFit];
            self.accessoryView = self.defaultAccessoryImageView;
            return;
        }
    }
    
    if (accessoryType == UITableViewCellAccessoryCheckmark) {
        UIImage *checkmarkImage = TableViewCellCheckmarkImage;
        if (checkmarkImage) {
            [self initDefaultAccessoryImageViewIfNeeded];
            self.defaultAccessoryImageView.image = checkmarkImage;
            [self.defaultAccessoryImageView sizeToFit];
            self.accessoryView = self.defaultAccessoryImageView;
            return;
        }
    }
    
    if (accessoryType == UITableViewCellAccessoryDetailButton) {
        UIImage *detailButtonImage = TableViewCellDetailButtonImage;
        if (detailButtonImage) {
            [self initDefaultAccessoryButtonIfNeeded];
            [self.defaultAccessoryButton setImage:detailButtonImage forState:UIControlStateNormal];
            [self.defaultAccessoryButton sizeToFit];
            self.accessoryView = self.defaultAccessoryButton;
            return;
        }
    }
    
    if (accessoryType == UITableViewCellAccessoryDetailDisclosureButton) {
        UIImage *detailButtonImage = TableViewCellDetailButtonImage;
        UIImage *indicatorImage = TableViewCellDisclosureIndicatorImage;
        
        if (detailButtonImage) {
            NSAssert(!!indicatorImage, @"TableViewCellDetailButtonImage 和 TableViewCellDisclosureIndicatorImage 必须同时使用，但目前后者为 nil");
            [self initDefaultDetailDisclosureViewIfNeeded];
            [self initDefaultAccessoryButtonIfNeeded];
            [self.defaultAccessoryButton setImage:detailButtonImage forState:UIControlStateNormal];
            [self.defaultAccessoryButton sizeToFit];
            if (self.accessoryView == self.defaultAccessoryButton) {
                self.accessoryView = nil;
            }
            [self.defaultDetailDisclosureView addSubview:self.defaultAccessoryButton];
        }
        
        if (indicatorImage) {
            NSAssert(!!detailButtonImage, @"TableViewCellDetailButtonImage 和 TableViewCellDisclosureIndicatorImage 必须同时使用，但目前前者为 nil");
            [self initDefaultDetailDisclosureViewIfNeeded];
            [self initDefaultAccessoryImageViewIfNeeded];
            self.defaultAccessoryImageView.image = indicatorImage;
            [self.defaultAccessoryImageView sizeToFit];
            if (self.accessoryView == self.defaultAccessoryImageView) {
                self.accessoryView = nil;
            }
            [self.defaultDetailDisclosureView addSubview:self.defaultAccessoryImageView];
        }
        
        if (indicatorImage && detailButtonImage) {
            CGFloat spacingBetweenDetailButtonAndIndicatorImage = TableViewCellSpacingBetweenDetailButtonAndDisclosureIndicator;
            self.defaultDetailDisclosureView.frame = CGRectFlatMake(CGRectGetMinX(self.defaultDetailDisclosureView.frame), CGRectGetMinY(self.defaultDetailDisclosureView.frame), CGRectGetWidth(self.defaultAccessoryButton.frame) + spacingBetweenDetailButtonAndIndicatorImage + CGRectGetWidth(self.defaultAccessoryImageView.frame), fmax(CGRectGetHeight(self.defaultAccessoryButton.frame), CGRectGetHeight(self.defaultAccessoryImageView.frame)));
            self.defaultAccessoryButton.frame = CGRectSetXY(self.defaultAccessoryButton.frame, 0, CGRectGetMinYVerticallyCenterInParentRect(self.defaultDetailDisclosureView.frame, self.defaultAccessoryButton.frame));
            self.defaultAccessoryImageView.frame = CGRectSetXY(self.defaultAccessoryImageView.frame, CGRectGetMaxX(self.defaultAccessoryButton.frame) + spacingBetweenDetailButtonAndIndicatorImage, CGRectGetMinYVerticallyCenterInParentRect(self.defaultDetailDisclosureView.frame, self.defaultAccessoryImageView.frame));
            self.accessoryView = self.defaultDetailDisclosureView;
            return;
        }
    }
    
    self.accessoryView = nil;
}

#pragma mark - <UIScrollViewDelegate>

// 为了修复因优化accessoryView导致的向左滑动cell容易触发accessoryView事件 a little dirty by molice
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    self.accessoryView.userInteractionEnabled = NO;
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    self.accessoryView.userInteractionEnabled = YES;
}

#pragma mark - Touch Event

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
    UIView *view = [super hitTest:point withEvent:event];
    if (!view) {
        return nil;
    }
    // 对于使用自定义的accessoryView的情况，扩大其响应范围。最小范围至少是一个靠在屏幕右边缘的“宽高都为cell高度”的正方形区域
    if (self.accessoryView
        && !self.accessoryView.hidden
        && self.accessoryView.userInteractionEnabled
        && !self.editing
        // UISwitch被点击时，[super hitTest:point withEvent:event]返回的不是UISwitch，而是它的一个subview，如果这里直接返回UISwitch会导致控件无法使用，因此对UISwitch做特殊屏蔽
        && ![self.accessoryView isKindOfClass:[UISwitch class]]
        ) {
        
        CGRect accessoryViewFrame = self.accessoryView.frame;
        CGRect responseEventFrame;
        responseEventFrame.origin.x = CGRectGetMinX(accessoryViewFrame) + self.accessoryHitTestEdgeInsets.left;
        responseEventFrame.origin.y = CGRectGetMinY(accessoryViewFrame) + self.accessoryHitTestEdgeInsets.top;
        responseEventFrame.size.width = CGRectGetWidth(accessoryViewFrame) + UIEdgeInsetsGetHorizontalValue(self.accessoryHitTestEdgeInsets);
        responseEventFrame.size.height = CGRectGetHeight(accessoryViewFrame) + UIEdgeInsetsGetVerticalValue(self.accessoryHitTestEdgeInsets);
        if (CGRectContainsPoint(responseEventFrame, point)) {
            return self.accessoryView;
        }
    }
    return view;
}

- (void)handleAccessoryButtonEvent:(QMUIButton *)detailButton {
    if ([self.qmui_tableView.delegate respondsToSelector:@selector(tableView:accessoryButtonTappedForRowWithIndexPath:)]) {
        [self.qmui_tableView.delegate tableView:self.qmui_tableView accessoryButtonTappedForRowWithIndexPath:[self.qmui_tableView qmui_indexPathForRowAtView:detailButton]];
    }
}

@end

@implementation QMUITableViewCell(QMUISubclassingHooks)

- (void)didInitializeWithStyle:(UITableViewCellStyle)style {
    self.initByTableView = NO;
    _cellPosition = QMUITableViewCellPositionNone;
    
    _style = style;
    _enabled = YES;
    _accessoryHitTestEdgeInsets = UIEdgeInsetsMake(-12, -12, -12, -12);
    
    // 因为在hitTest里扩大了accessoryView的响应范围，因此提高了系统一个与此相关的bug的出现几率，所以又在scrollView.delegate里做一些补丁性质的东西来修复
    if ([self.subviews.firstObject isKindOfClass:[UIScrollView class]]) {
        UIScrollView *scrollView = (UIScrollView *)[self.subviews objectAtIndex:0];
        scrollView.delegate = self;
    }
    
    [self qmui_styledAsQMUITableViewCell];
}

- (void)updateCellAppearanceWithIndexPath:(NSIndexPath *)indexPath {
    // 子类继承
    if (indexPath && self.parentTableView) {
        QMUITableViewCellPosition position = [self.parentTableView qmui_positionForRowAtIndexPath:indexPath];
        self.cellPosition = position;
    } else {
        self.cellPosition = QMUITableViewCellPositionNone;
    }
}

@end
