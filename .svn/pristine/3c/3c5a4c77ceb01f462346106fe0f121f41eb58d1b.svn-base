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
 * 控制是否在列表顶部显示搜索框。在QMUICommonTableViewController里已经接管了searchBar的初始化工作，所以外部只需要控制“显示/隐藏”，不需要自己再初始化一次。
 */
- (BOOL)shouldShowSearchBarInTableView:(QMUITableView *)tableView DEPRECATED_MSG_ATTRIBUTE("在 QMUI 1.3.7 里废弃，请使用 QMUICommonTableViewController.shouldShowSearchBar 代替");

/**
 * 自定义要在<i>- (BOOL)touchesShouldCancelInContentView:(UIView *)view</i>内的逻辑<br/>
 * 若delegate不实现这个方法，则默认对所有UIControl返回NO（UIButton除外，它会返回YES），非UIControl返回YES。
 */
- (BOOL)tableView:(QMUITableView *)tableView touchesShouldCancelInContentView:(UIView *)view;

@end


@protocol QMUITableViewDataSource <UITableViewDataSource, qmui_UITableViewDataSource>

@end
