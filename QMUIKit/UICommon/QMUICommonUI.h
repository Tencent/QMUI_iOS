//
//  QMUICommonUI.h
//  qmui
//
//  Created by QQMail on 14-6-23.
//  Copyright (c) 2014年 QMUI Team. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface QMUICommonUI : NSObject

/**
 * 设置全局UIAppearance的代码，所有控件的appearance均可写在这里
 *
 * 在application:didFinishLaunchingWithOptions:的时候被调用
 */
+ (void)renderGlobalAppearances;

@end
