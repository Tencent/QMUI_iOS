//
//  QMUITableViewProtocols.h
//  qmui
//
//  Created by MoLice on 2016/12/9.
//  Copyright © 2016年 QMUI Team. All rights reserved.
//

#import <UIKit/UIKit.h>

@class QMUITableView;

@protocol qmui_UITableViewDataSource

@optional
- (__kindof UITableViewCell *)qmui_tableView:(UITableView *)tableView cellWithIdentifier:(NSString *)identifier;

@end

@protocol QMUITableViewDelegate <UITableViewDelegate>

@optional

/**
 * 自定义要在<i>- (BOOL)touchesShouldCancelInContentView:(UIView *)view</i>内的逻辑<br/>
 * 若delegate不实现这个方法，则默认对所有UIControl返回NO（UIButton除外，它会返回YES），非UIControl返回YES。
 */
- (BOOL)tableView:(QMUITableView *)tableView touchesShouldCancelInContentView:(UIView *)view;

@end


@protocol QMUITableViewDataSource <UITableViewDataSource, qmui_UITableViewDataSource>

@end
