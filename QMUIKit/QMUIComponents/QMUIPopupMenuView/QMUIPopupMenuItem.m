//
//  QMUIPopupMenuItem.m
//  QMUIKit
//
//  Created by molice on 2024/6/17.
//  Copyright © 2024 QMUI Team. All rights reserved.
//

#import "QMUIPopupMenuItem.h"

@implementation QMUIPopupMenuItem

- (instancetype)init {
    self = [super init];
    if (self) {
        _height = -1;
    }
    return self;
}

+ (instancetype)itemWithImage:(UIImage *)image title:(NSString *)title subtitle:(NSString *)subtitle handler:(void (^ _Nullable)(__kindof QMUIPopupMenuItem * _Nonnull, __kindof UIControl<QMUIPopupMenuItemViewProtocol> * _Nonnull, NSInteger, NSInteger))handler {
    QMUIPopupMenuItem *item = [[self alloc] init];
    item.image = image;
    item.title = title;
    item.subtitle = subtitle;
    item.handler = handler;
    return item;
}

+ (instancetype)itemWithTitle:(NSString *)title handler:(void (^ _Nullable)(__kindof QMUIPopupMenuItem * _Nonnull, __kindof UIControl<QMUIPopupMenuItemViewProtocol> * _Nonnull, NSInteger, NSInteger))handler {
    return [self itemWithImage:nil title:title subtitle:nil handler:handler];
}

+ (instancetype)itemWithImage:(UIImage *)image title:(NSString *)title handler:(void (^ _Nullable)(__kindof QMUIPopupMenuItem * _Nonnull, __kindof UIControl<QMUIPopupMenuItemViewProtocol> * _Nonnull, NSInteger, NSInteger))handler {
    return [self itemWithImage:image title:title subtitle:nil handler:handler];
}

@end
