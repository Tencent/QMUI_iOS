//
//  NSURL+QMUI.h
//  QMUIKit
//
//  Created by TQ on 2018/11/11.
//  Copyright © 2018 QMUI Team. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NSURL (QMUI)

/**
 *  获取当前 query 的参数列表。
 *
 *  @return query 参数列表，以字典返回。如果 absoluteString 为 nil 则返回 nil
 */
@property(nonatomic, copy, readonly) NSDictionary<NSString *, NSString *> *qmui_queryItems;

@end
