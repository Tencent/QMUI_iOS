//
//  NSCharacterSet+QMUI.h
//  QMUIKit
//
//  Created by MoLice on 2018/9/17.
//  Copyright © 2018年 QMUI Team. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSCharacterSet (QMUI)

/**
 也即在系统的 URLQueryAllowedCharacterSet 基础上去掉“#&=”这3个字符，专用于 URL query 里来源于用户输入的 value，避免服务器解析出现异常。
 */
@property (class, readonly, copy) NSCharacterSet *qmui_URLUserInputQueryAllowedCharacterSet;

@end
