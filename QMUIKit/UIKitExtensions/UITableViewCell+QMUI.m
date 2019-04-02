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

+ (void)initialize {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        SEL selectors[] = {
            @selector(setHighlighted:animated:),
            @selector(setSelected:animated:)
        };
        for (NSUInteger index = 0; index < sizeof(selectors) / sizeof(SEL); index++) {
            SEL originalSelector = selectors[index];
            SEL swizzledSelector = NSSelectorFromString([@"qmuicell_" stringByAppendingString:NSStringFromSelector(originalSelector)]);
            ExchangeImplementations([self class], originalSelector, swizzledSelector);
        }
    });
}

- (void)qmuicell_setHighlighted:(BOOL)highlighted animated:(BOOL)animated {
    [self qmuicell_setHighlighted:highlighted animated:animated];
    if (self.qmui_setHighlightedBlock) {
        self.qmui_setHighlightedBlock(highlighted, animated);
    }
}

- (void)qmuicell_setSelected:(BOOL)selected animated:(BOOL)animated {
    [self qmuicell_setSelected:selected animated:animated];
    if (self.qmui_setSelectedBlock) {
        self.qmui_setSelectedBlock(selected, animated);
    }
}

- (UIView *)qmui_accessoryView {
    if (self.editing) {
        if (self.editingAccessoryView) {
            return self.editingAccessoryView;
        }
        return [self valueForKey:@"_editingAccessoryView"];
    }
    if (self.accessoryView) {
        return self.accessoryView;
    }
    return [self valueForKey:@"_accessoryView"];
}

@end
