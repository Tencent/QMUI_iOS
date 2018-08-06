//
//  QMUIWeakObjectContainer.m
//  QMUIKit
//
//  Created by 李凯 on 2018/7/24.
//  Copyright © 2018年 QMUI Team. All rights reserved.
//

#import "QMUIWeakObjectContainer.h"

@implementation QMUIWeakObjectContainer

- (instancetype)initWithObject:(id)object {
    if (self = [super init]) {
        _object = object;
    }
    return self;
}

@end
