//
//  NSMethodSignature+QMUI.h
//  QMUIKit
//
//  Created by MoLice on 2019/A/28.
//  Copyright © 2019 QMUI Team. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSMethodSignature (QMUI)

/**
 以 NSString 格式返回当前 NSMethodSignature 的 typeEncoding，例如 v@:
 */
@property(nullable, nonatomic, copy, readonly) NSString *qmui_typeString;

/**
 以 const char 格式返回当前 NSMethodSignature 的 typeEncoding，例如 v@:
 */
@property(nullable, nonatomic, readonly) const char *qmui_typeEncoding;
@end

NS_ASSUME_NONNULL_END
