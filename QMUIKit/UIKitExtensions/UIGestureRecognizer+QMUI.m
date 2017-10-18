//
//  UIGestureRecognizer+QMUI.m
//  qmui
//
//  Created by MoLice on 2017/8/21.
//  Copyright © 2017年 QMUI Team. All rights reserved.
//

#import "UIGestureRecognizer+QMUI.h"

@implementation UIGestureRecognizer (QMUI)

- (nullable UIView *)qmui_targetView {
    CGPoint location = [self locationInView:self.view];
    UIView *targetView = [self.view hitTest:location withEvent:nil];
    return targetView;
}

@end
