//
//  NSArray+QMUI.h
//  QMUIKit
//
//  Created by MoLice on 2017/11/14.
//  Copyright © 2017年 QMUI Team. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSArray (QMUI)

/**
 *  将多维数组打平成一维数组再遍历所有子元素
 */
- (void)qmui_enumerateNestedArrayWithBlock:(void (^)(id obj, BOOL *stop))block;

/**
 *  将多维数组递归转换成 mutable 多维数组
 */
- (NSMutableArray *)qmui_mutableCopyNestedArray;
@end
