//
//  NSPointerArray+QMUI.h
//  QMUIKit
//
//  Created by MoLice on 2018/4/12.
//  Copyright © 2018年 QMUI Team. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSPointerArray (QMUI)

- (NSUInteger)qmui_indexOfPointer:(nullable void *)pointer;
- (BOOL)qmui_containsPointer:(nullable void *)pointer;
@end
