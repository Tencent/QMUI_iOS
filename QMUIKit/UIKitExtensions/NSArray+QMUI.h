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

/**
 *  过滤数组元素，将 block 返回 YES 的 item 重新组装成一个数组返回
 */
- (instancetype)qmui_filterWithBlock:(BOOL (^)(id item))block;
@end
