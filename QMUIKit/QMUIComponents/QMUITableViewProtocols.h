//
//  QMUITableViewProtocols.h
//  qmui
//
//  Created by MoLice on 2016/12/9.
//  Copyright © 2016年 QMUI Team. All rights reserved.
//

#import <UIKit/UIKit.h>

@class QMUITableView;

@protocol QMUICellHeightCache_UITableViewDataSource

@optional
/// 搭配 QMUICellHeightCache 使用，对于 UITableView 而言如果要用 QMUICellHeightCache 那套高度计算方式，则必须实现这个方法
- (__kindof UITableViewCell *)qmui_tableView:(UITableView *)tableView cellWithIdentifier:(NSString *)identifier;

@end

@protocol QMUICellHeightCache_UITableViewDelegate

@optional
/// 搭配 QMUICellHeightCache 使用，在 UITableView safeAreaInsetsChange 之后会通过这个方法通知到外面。至于缓存到内存的高度清理、tableView reloadData 的调用，都是在这个方法执行之后才执行。
- (void)qmui_willReloadAfterSafeAreaInsetsDidChangeInTableView:(UITableView *)tableView;

@end

@protocol QMUITableViewDelegate <UITableViewDelegate, QMUICellHeightCache_UITableViewDelegate>

@optional

/**
 * 自定义要在<i>- (BOOL)touchesShouldCancelInContentView:(UIView *)view</i>内的逻辑<br/>
 * 若delegate不实现这个方法，则默认对所有UIControl返回NO（UIButton除外，它会返回YES），非UIControl返回YES。
 */
- (BOOL)tableView:(QMUITableView *)tableView touchesShouldCancelInContentView:(UIView *)view;

@end


@protocol QMUITableViewDataSource <UITableViewDataSource, QMUICellHeightCache_UITableViewDataSource>

@end
