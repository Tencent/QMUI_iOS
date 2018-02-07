//
//  QMUILogManagerViewController.h
//  QMUIKit
//
//  Created by MoLice on 2018/1/24.
//  Copyright © 2018年 QMUI Team. All rights reserved.
//

#import "QMUICommonTableViewController.h"

/// 用于管理 QMUILog name 的调试界面，可直接 init 使用
@interface QMUILogManagerViewController : QMUICommonTableViewController

/// cell 总个数大于等于这个数值时才会出搜索框和右边的 section title 索引条，方便检索。默认值为 10。
@property(nonatomic, assign) NSUInteger rowCountWhenShowSearchBar;

/// 一般项目的 logName 都会带有统一前缀（例如 @"QMUIImagePickerLibrary"），而在排序的时候，前缀通常是无意义的，因此这里提供一个 block 让你可以根据传进去的 logName 返回一个不带前缀的用于排序的 logName，且这个返回值的第一个字母将会作为 section 的索引显示在列表右边。若不实现这个 block 则直接拿原 logName 进行排序。
@property(nonatomic, copy) NSString *(^formatLogNameForSortingBlock)(NSString *logName);

/// 可自定义 cell 的文字样式，方便区分不同的 logName
@property(nonatomic, copy) NSAttributedString *(^formatCellTextBlock)(NSString *logName);
@end
