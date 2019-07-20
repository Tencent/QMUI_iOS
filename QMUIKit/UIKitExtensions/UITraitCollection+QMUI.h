//
//  UITraitCollection+QMUI.h
//  QMUIKit
//
//  Created by ziezheng on 2019/7/19.
//  Copyright © 2019 QMUI Team. All rights reserved.
//


#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

/// iOS 13 下当 UIUserInterfaceStyle 发生变化前的通知，可用于更新状态，例如 QMUIThemeManager 利用其来自动切换主题
extern NSNotificationName const QMUIUserInterfaceStyleWillChangeNotification API_AVAILABLE(ios(13.0));

NS_ASSUME_NONNULL_END
