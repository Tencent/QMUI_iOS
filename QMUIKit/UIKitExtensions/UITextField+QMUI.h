//
//  UITextField+QMUI.h
//  qmui
//
//  Created by zhoonchen on 2017/3/29.
//  Copyright © 2017年 QMUI Team. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface UITextField (QMUI)

/// UITextField只有selectedTextRange属性（在<UITextInput>协议里定义），这里拓展了一个方法可以将UITextRange类型的selectedTextRange转换为NSRange类型的selectedRange
@property(nonatomic, assign, readonly) NSRange qmui_selectedRange;

/// 输入框右边的 clearButton，在 UITextField 初始化后就存在
@property(nullable, nonatomic, weak, readonly) UIButton *qmui_clearButton;

/// 自定义 clearButton 的图片，注意如果设置过则无法再恢复到系统默认的图片
@property(nonnull, nonatomic, strong) UIImage *qmui_clearButtonImage UI_APPEARANCE_SELECTOR;

@end
