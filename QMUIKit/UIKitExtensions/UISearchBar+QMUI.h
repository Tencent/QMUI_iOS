//
//  UISearchBar+QMUI.h
//  qmui
//
//  Created by MoLice on 16/5/26.
//  Copyright © 2016年 QMUI Team. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface UISearchBar (QMUI)

@property(nonatomic, strong) UIColor *qmui_placeholderColor;
@property(nonatomic, strong) UIColor *qmui_textColor;

- (void)qmui_styledAsQMUISearchBar;

@end
