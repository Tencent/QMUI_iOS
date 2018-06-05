//
//  QMUISearchBar.m
//  qmui
//
//  Created by MoLice on 14-7-2.
//  Copyright (c) 2014年 QMUI Team. All rights reserved.
//

#import "QMUISearchBar.h"
#import "UISearchBar+QMUI.h"

@implementation QMUISearchBar

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self didInitialize];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)coder {
    self = [super initWithCoder:coder];
    if (self) {
        [self didInitialize];
    }
    return self;
}

- (void)didInitialize {
    [self qmui_styledAsQMUISearchBar];
}

@end
