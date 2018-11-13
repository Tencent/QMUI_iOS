//
//  QMUIMultipleDelegates.h
//  QMUIKit
//
//  Created by MoLice on 2018/3/27.
//  Copyright © 2018年 QMUI Team. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import "NSObject+QMUIMultipleDelegates.h"

/// 存放多个 delegate 指针的容器，必须搭配其他控件使用，一般不需要你自己 init。作用是让某个 class 支持同时存在多个 delegate。更多说明请查看 NSObject (QMUIMultipleDelegates) 的注释。
@interface QMUIMultipleDelegates : NSObject

+ (instancetype)weakDelegates;
+ (instancetype)strongDelegates;

@property(nonatomic, strong, readonly) NSPointerArray *delegates;
@property(nonatomic, weak) NSObject *parentObject;

- (void)addDelegate:(id)delegate;
- (BOOL)removeDelegate:(id)delegate;
- (void)removeAllDelegates;
- (BOOL)containsDelegate:(id)delegate;
@end
