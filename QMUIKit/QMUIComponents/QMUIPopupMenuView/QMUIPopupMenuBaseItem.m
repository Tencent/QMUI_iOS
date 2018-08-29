//
//  QMUIPopupMenuBaseItem.m
//  QMUIKit
//
//  Created by MoLice on 2018/8/21.
//  Copyright © 2018年 QMUI Team. All rights reserved.
//

#import "QMUIPopupMenuBaseItem.h"

@implementation QMUIPopupMenuBaseItem

@synthesize title = _title;
@synthesize height = _height;
@synthesize handler = _handler;
@synthesize menuView = _menuView;

- (instancetype)init {
    if (self = [super init]) {
        self.height = -1;
    }
    return self;
}

- (void)updateAppearance {
    
}

@end
