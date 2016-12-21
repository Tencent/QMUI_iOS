//
//  QMUITableView.h
//  qmui
//
//  Created by QQMail on 14-7-2.
//  Copyright (c) 2014年 QMUI Team. All rights reserved.
//

#import "QMUITableViewProtocols.h"

@interface QMUITableView : UITableView

@property(nonatomic, weak) id<QMUITableViewDelegate> delegate;
@property(nonatomic, weak) id<QMUITableViewDataSource> dataSource;

@end

