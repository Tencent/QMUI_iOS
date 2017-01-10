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
        [self didInitialized];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)coder {
    self = [super initWithCoder:coder];
    if (self) {
        [self didInitialized];
    }
    return self;
}

- (void)didInitialized {
    [self qmui_styledAsQMUISearchBar];
}

@end
