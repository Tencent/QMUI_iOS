//
//  UIBarItem+QMUI.m
//  QMUIKit
//
//  Created by MoLice on 2018/4/5.
//  Copyright © 2018年 QMUI Team. All rights reserved.
//

#import "UIBarItem+QMUI.h"

@implementation UIBarItem (QMUI)

- (UIView *)qmui_view {
    return [self valueForKey:@"view"];
}

@end
