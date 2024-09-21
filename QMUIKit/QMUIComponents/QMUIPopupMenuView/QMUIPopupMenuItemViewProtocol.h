//
//  QMUIPopupMenuItemViewProtocol.h
//  QMUIKit
//
//  Created by molice on 2024/6/17.
//  Copyright © 2024 QMUI Team. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class QMUIPopupMenuItem;

@protocol QMUIPopupMenuItemViewProtocol <NSObject>

@required

/// 当前 itemView 关联的 item，在 cellForRow 时会被设置。itemView 内所有与 item 强相关的内容均应在 setItem: 方法里设置。
@property(nonatomic, weak, nullable) __kindof QMUIPopupMenuItem *item;
@end

NS_ASSUME_NONNULL_END
