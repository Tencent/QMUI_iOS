//
//  QMUITableView.h
//  qmui
//
//  Created by QMUI Team on 14-7-2.
//  Copyright (c) 2014年 QMUI Team. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "QMUITableViewProtocols.h"

@interface QMUITableView : UITableView

@property(nonatomic, nullable, weak) id<QMUITableViewDelegate> delegate;
@property(nonatomic, nullable, weak) id<QMUITableViewDataSource> dataSource;

@end

