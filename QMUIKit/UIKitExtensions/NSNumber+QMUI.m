//
//  NSNumber+QMUI.m
//  QMUIKit
//
//  Created by MoLice on 2018/1/16.
//  Copyright © 2018年 QMUI Team. All rights reserved.
//

#import "NSNumber+QMUI.h"

@implementation NSNumber (QMUI)

- (CGFloat)qmui_CGFloatValue {
#if CGFLOAT_IS_DOUBLE
    return self.doubleValue;
#else
    return self.floatValue;
#endif
}

@end
