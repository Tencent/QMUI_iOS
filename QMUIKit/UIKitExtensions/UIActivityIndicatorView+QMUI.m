//
//  UIActivityIndicatorView+QMUI.m
//  qmui
//
//  Created by ZhoonChen on 15/7/20.
//  Copyright (c) 2015年 QMUI Team. All rights reserved.
//

#import "UIActivityIndicatorView+QMUI.h"

@implementation UIActivityIndicatorView (QMUI)

- (instancetype)initWithActivityIndicatorStyle:(UIActivityIndicatorViewStyle)style size:(CGSize)size {
    if (self = [self initWithActivityIndicatorStyle:style]) {
        CGSize initialSize = self.bounds.size;
        CGFloat scale = size.width / initialSize.width;
        self.transform = CGAffineTransformMakeScale(scale, scale);
    }
    return self;
}

@end
