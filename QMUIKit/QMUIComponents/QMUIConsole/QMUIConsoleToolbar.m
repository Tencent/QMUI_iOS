/**
 * Tencent is pleased to support the open source community by making QMUI_iOS available.
 * Copyright (C) 2016-2020 THL A29 Limited, a Tencent company. All rights reserved.
 * Licensed under the MIT License (the "License"); you may not use this file except in compliance with the License. You may obtain a copy of the License at
 * http://opensource.org/licenses/MIT
 * Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.
 */

//
//  QMUIConsoleToolbar.m
//  QMUIKit
//
//  Created by MoLice on 2019/J/11.
//

#import "QMUIConsoleToolbar.h"
#import "QMUIConsole.h"
#import "QMUICore.h"
#import "QMUIButton.h"
#import "QMUITextField.h"
#import "UITextField+QMUI.h"
#import "UIImage+QMUI.h"
#import "UIView+QMUI.h"
#import "UIColor+QMUI.h"
#import "UIControl+QMUI.h"
#import "UIImage+QMUI.h"

@interface QMUIConsoleToolbar ()

@property(nonatomic, strong) UIView *searchRightView;
@end

@implementation QMUIConsoleToolbar

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        _levelButton = [[QMUIButton alloc] init];
        UIImage *filterImage = [[QMUIHelper imageWithName:@"QMUI_console_filter"] qmui_imageResizedInLimitedSize:CGSizeMake(14, 14)];
        UIImage *filterSelectedImage = [[QMUIHelper imageWithName:@"QMUI_console_filter_selected"] qmui_imageResizedInLimitedSize:CGSizeMake(14, 14)];
        
        [self.levelButton setImage:filterImage forState:UIControlStateNormal];
        [self.levelButton setImage:filterSelectedImage forState:UIControlStateSelected];
        [self.levelButton setImage:filterSelectedImage forState:UIControlStateSelected|UIControlStateHighlighted];
        [self.levelButton setImage:filterSelectedImage forState:UIControlStateSelected|UIControlStateDisabled];
        [self.levelButton setTitle:@"Level" forState:UIControlStateNormal];
        self.levelButton.titleLabel.font = UIFontMake(7);
        self.levelButton.imagePosition = QMUIButtonImagePositionTop;
        self.levelButton.tintColorAdjustsTitleAndImage = UIColorWhite;
        [self addSubview:self.levelButton];
        
        _nameButton = [[QMUIButton alloc] init];
        [self.nameButton setImage:filterImage forState:UIControlStateNormal];
        [self.nameButton setImage:filterSelectedImage forState:UIControlStateSelected];
        [self.nameButton setImage:filterSelectedImage forState:UIControlStateSelected|UIControlStateHighlighted];
        [self.nameButton setImage:filterSelectedImage forState:UIControlStateSelected|UIControlStateDisabled];
        [self.nameButton setTitle:@"Name" forState:UIControlStateNormal];
        self.nameButton.titleLabel.font = UIFontMake(7);
        self.nameButton.imagePosition = QMUIButtonImagePositionTop;
        self.nameButton.tintColorAdjustsTitleAndImage = UIColorWhite;
        [self addSubview:self.nameButton];
        
        _searchTextField = [[QMUITextField alloc] init];
        self.searchTextField.clearButtonMode = UITextFieldViewModeWhileEditing;
        self.searchTextField.tintColor = [QMUIConsole appearance].textAttributes[NSForegroundColorAttributeName];
        self.searchTextField.textColor = self.searchTextField.tintColor;
        self.searchTextField.placeholderColor = [self.searchTextField.textColor colorWithAlphaComponent:.6];
        self.searchTextField.font = [QMUIConsole appearance].textAttributes[NSFontAttributeName];
        self.searchTextField.keyboardAppearance = UIKeyboardAppearanceDark;
        self.searchTextField.returnKeyType = UIReturnKeySearch;
        self.searchTextField.autocapitalizationType = UITextAutocapitalizationTypeNone;
        self.searchTextField.autocorrectionType = UITextAutocorrectionTypeNo;
        self.searchTextField.layer.borderWidth = PixelOne;
        self.searchTextField.layer.borderColor = [[UIColor whiteColor] colorWithAlphaComponent:.3].CGColor;
        self.searchTextField.layer.cornerRadius = 3;
        self.searchTextField.placeholder = @"Search...";
        [self addSubview:self.searchTextField];
        
        _clearButton = [[QMUIButton alloc] init];
        [self.clearButton setImage:[QMUIHelper imageWithName:@"QMUI_console_clear"] forState:UIControlStateNormal];
        [self addSubview:self.clearButton];
        
        self.searchRightView = [[UIView alloc] init];
        
        _searchResultCountLabel = [[UILabel alloc] init];
        self.searchResultCountLabel.textColor = self.searchTextField.placeholderColor;
        self.searchResultCountLabel.font = UIFontMake(11);
        [self.searchRightView addSubview:self.searchResultCountLabel];
        
        _searchResultPreviousButton = [[QMUIButton alloc] init];
        [self.searchResultPreviousButton setTitle:@"<" forState:UIControlStateNormal];
        self.searchResultPreviousButton.titleLabel.font = UIFontMake(12);
        [self.searchResultPreviousButton setTitleColor:self.searchTextField.textColor forState:UIControlStateNormal];
        [self.searchResultPreviousButton sizeToFit];
        [self.searchRightView addSubview:self.searchResultPreviousButton];
        
        _searchResultNextButton = [[QMUIButton alloc] init];
        [self.searchResultNextButton setTitle:@">" forState:UIControlStateNormal];
        self.searchResultNextButton.titleLabel.font = UIFontMake(12);
        [self.searchResultNextButton setTitleColor:self.searchTextField.textColor forState:UIControlStateNormal];
        [self.searchResultNextButton sizeToFit];
        [self.searchRightView addSubview:self.searchResultNextButton];
        
        self.searchTextField.rightView = self.searchRightView;
        self.searchTextField.rightViewMode = UITextFieldViewModeNever;
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    UIEdgeInsets paddings = UIEdgeInsetsMake(8, 8, 8, 8);
    
    CGFloat x = paddings.left + self.qmui_safeAreaInsets.left;
    CGFloat contentHeight = CGRectGetHeight(self.bounds) - self.qmui_safeAreaInsets.bottom - UIEdgeInsetsGetVerticalValue(paddings);
    
    self.levelButton.frame = CGRectMake(x, paddings.top, contentHeight, contentHeight);
    x = CGRectGetMaxX(self.levelButton.frame);
    
    self.nameButton.frame = CGRectSetX(self.levelButton.frame, CGRectGetMaxX(self.levelButton.frame));
    x = CGRectGetMaxX(self.nameButton.frame);
    
    self.clearButton.frame = CGRectSetX(self.levelButton.frame, CGRectGetWidth(self.bounds) - self.qmui_safeAreaInsets.right - paddings.right - contentHeight);
    
    CGFloat searchTextFieldMarginHorizontal = 8;
    CGFloat searchTextFieldMinX = x + searchTextFieldMarginHorizontal;
    self.searchTextField.frame = CGRectMake(searchTextFieldMinX, paddings.top, CGRectGetMinX(self.clearButton.frame) - searchTextFieldMarginHorizontal - searchTextFieldMinX, contentHeight);
}

- (void)setNeedsLayoutSearchResultViews {
    CGFloat paddingHorizontal = 4;
    CGFloat buttonSpacing = 2;
    CGFloat countLabelMarginRight = 4;
    [self.searchResultCountLabel sizeToFit];
    
    self.searchRightView.qmui_width = paddingHorizontal * 2 + self.searchResultCountLabel.qmui_width + countLabelMarginRight + self.searchResultPreviousButton.qmui_width + buttonSpacing + self.searchResultNextButton.qmui_width;
    self.searchRightView.qmui_height = self.searchTextField.qmui_height;
    
    self.searchResultNextButton.qmui_right = self.searchRightView.qmui_width - paddingHorizontal;
    self.searchResultNextButton.qmui_top = self.searchResultNextButton.qmui_topWhenCenterInSuperview;
    self.searchResultNextButton.qmui_outsideEdge = UIEdgeInsetsMake(-self.searchResultNextButton.qmui_top, -buttonSpacing / 2, -self.searchResultNextButton.qmui_top, -paddingHorizontal);
    
    self.searchResultPreviousButton.qmui_right = self.searchResultNextButton.qmui_left - buttonSpacing;
    self.searchResultPreviousButton.qmui_top = self.searchResultPreviousButton.qmui_topWhenCenterInSuperview;
    self.searchResultNextButton.qmui_outsideEdge = UIEdgeInsetsMake(-self.searchResultPreviousButton.qmui_top, -buttonSpacing / 2, -self.searchResultPreviousButton.qmui_top, -paddingHorizontal);
    
    
    self.searchResultCountLabel.qmui_right = self.searchResultPreviousButton.qmui_left - countLabelMarginRight;
    self.searchResultCountLabel.qmui_top = self.searchResultCountLabel.qmui_topWhenCenterInSuperview;
    
    [self.searchTextField setNeedsLayout];
}

@end
