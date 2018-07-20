//
//  UITableViewCell+QMUI.m
//  QMUIKit
//
//  Created by MoLice on 2018/7/5.
//  Copyright © 2018年 QMUI Team. All rights reserved.
//

#import "UITableViewCell+QMUI.h"

@implementation UITableViewCell (QMUI)

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
