/*****
 * Tencent is pleased to support the open source community by making QMUI_iOS available.
 * Copyright (C) 2016-2019 THL A29 Limited, a Tencent company. All rights reserved.
 * Licensed under the MIT License (the "License"); you may not use this file except in compliance with the License. You may obtain a copy of the License at
 * http://opensource.org/licenses/MIT
 * Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.
 *****/

//
//  UITableViewCell+QMUI.m
//  QMUIKit
//
//  Created by QMUI Team on 2018/7/5.
//

#import "UITableViewCell+QMUI.h"
#import <objc/runtime.h>
#import "QMUICore.h"

@implementation UITableViewCell (QMUI)

QMUISynthesizeIdCopyProperty(qmui_setHighlightedBlock, setQmui_setHighlightedBlock)
QMUISynthesizeIdCopyProperty(qmui_setSelectedBlock, setQmui_setSelectedBlock)

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        ExtendImplementationOfVoidMethodWithTwoArguments([UITableViewCell class], @selector(setHighlighted:animated:), BOOL, BOOL, ^(UITableViewCell *selfObject, BOOL highlighted, BOOL animated) {
            if (selfObject.qmui_setHighlightedBlock) {
                selfObject.qmui_setHighlightedBlock(highlighted, animated);
            }
        });
        
        ExtendImplementationOfVoidMethodWithTwoArguments([UITableViewCell class], @selector(setSelected:animated:), BOOL, BOOL, ^(UITableViewCell *selfObject, BOOL selected, BOOL animated) {
            if (selfObject.qmui_setSelectedBlock) {
                selfObject.qmui_setSelectedBlock(selected, animated);
            }
        });
    });
}

- (UITableView *)qmui_tableView {
    return [self valueForKey:@"tableView"];
}

static char kAssociatedObjectKey_selectedBackgroundColor;
- (void)setQmui_selectedBackgroundColor:(UIColor *)qmui_selectedBackgroundColor {
    objc_setAssociatedObject(self, &kAssociatedObjectKey_selectedBackgroundColor, qmui_selectedBackgroundColor, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    if (qmui_selectedBackgroundColor) {
        // 系统默认的 selectedBackgroundView 是 UITableViewCellSelectedBackground，无法修改自定义背景色，所以改为用普通的 UIView
        if ([NSStringFromClass(self.selectedBackgroundView.class) hasPrefix:@"UITableViewCell"]) {
            self.selectedBackgroundView = [[UIView alloc] init];
        }
        self.selectedBackgroundView.backgroundColor = qmui_selectedBackgroundColor;
    }
}

- (UIColor *)qmui_selectedBackgroundColor {
    return (UIColor *)objc_getAssociatedObject(self, &kAssociatedObjectKey_selectedBackgroundColor);
}

- (UIView *)qmui_accessoryView {
    if (self.editing) {
        if (self.editingAccessoryView) {
            return self.editingAccessoryView;
        }
        return [self qmui_valueForKey:@"_editingAccessoryView"];
    }
    if (self.accessoryView) {
        return self.accessoryView;
    }
    return [self qmui_valueForKey:@"_accessoryView"];
}

@end

@implementation UITableViewCell (QMUI_Styled)

- (void)qmui_styledAsQMUITableViewCell {
    
    self.textLabel.font = UIFontMake(16);
    self.textLabel.backgroundColor = UIColorClear;
    UIColor *textLabelColor = self.qmui_styledTextLabelColor;
    if (textLabelColor) {
        self.textLabel.textColor = textLabelColor;
    }
    
    self.detailTextLabel.font = UIFontMake(15);
    self.detailTextLabel.backgroundColor = UIColorClear;
    UIColor *detailLabelColor = self.qmui_styledDetailTextLabelColor;
    if (detailLabelColor) {
        self.detailTextLabel.textColor = detailLabelColor;
    }
    
    UIColor *backgroundColor = self.qmui_styledBackgroundColor;
    if (backgroundColor) {
        self.backgroundColor = backgroundColor;
    }
    
    UIColor *selectedBackgroundColor = self.qmui_styledSelectedBackgroundColor;
    if (selectedBackgroundColor) {
        self.qmui_selectedBackgroundColor = selectedBackgroundColor;
    }
}

- (BOOL)_isGroupedStyle {
    return self.qmui_tableView && self.qmui_tableView.style == UITableViewStyleGrouped;
}

- (UIColor *)qmui_styledTextLabelColor {
    return self._isGroupedStyle ? TableViewGroupedCellTitleLabelColor : TableViewCellTitleLabelColor;
}

- (UIColor *)qmui_styledDetailTextLabelColor {
    return self._isGroupedStyle ? TableViewGroupedCellDetailLabelColor : TableViewCellDetailLabelColor;
}

- (UIColor *)qmui_styledBackgroundColor {
    return self._isGroupedStyle ? TableViewGroupedCellBackgroundColor : TableViewCellBackgroundColor;
}

- (UIColor *)qmui_styledSelectedBackgroundColor {
    return self._isGroupedStyle ? TableViewGroupedCellSelectedBackgroundColor : TableViewCellSelectedBackgroundColor;
}

- (UIColor *)qmui_styledWarningBackgroundColor {
    return self._isGroupedStyle ? TableViewGroupedCellWarningBackgroundColor : TableViewCellWarningBackgroundColor;
}

@end
