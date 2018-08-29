//
//  QMUIPopupMenuBaseItem.h
//  QMUIKit
//
//  Created by MoLice on 2018/8/21.
//  Copyright © 2018年 QMUI Team. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "QMUIPopupMenuItemProtocol.h"

/**
 用于 QMUIPopupMenuView 的 item 基类，便于自定义各种类型的 item。若有 subview 请直接添加到 self 上，布局也是写到 layoutSubviews 里即可。
 */
@interface QMUIPopupMenuBaseItem : UIView <QMUIPopupMenuItemProtocol>

@end
