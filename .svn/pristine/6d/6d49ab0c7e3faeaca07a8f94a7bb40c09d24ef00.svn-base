//
//  UICollectionView+QMUI.h
//  qmui
//
//  Created by ZhoonChen on 15/7/20.
//  Copyright (c) 2015年 QMUI Team. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface UICollectionView (QMUI)

/**
 *  清除所有已选中的item的选中状态
 */
- (void)qmui_clearsSelection;

/**
 *  重新`reloadData`，同时保持`reloadData`前item的选中状态
 */
- (void)qmui_reloadDataKeepingSelection;

/**
 *  获取某个view在collectionView内对应的indexPath
 *
 *  例如某个view是某个cell里的subview，在这个view的点击事件回调方法里，就能通过`qmui_indexPathForItemAtView:`获取被点击的view所处的cell的indexPath
 *
 *  @warning 注意返回的indexPath有可能为nil，要做保护。
 */
- (NSIndexPath *)qmui_indexPathForItemAtView:(id)sender;

/**
 *  判断当前 indexPath 的 item 是否为可视的 item
 */
- (BOOL)qmui_itemVisibleAtIndexPath:(NSIndexPath *)indexPath;

/**
 *  获取可视区域内第一个cell的indexPath。
 *
 *  为什么需要这个方法是因为系统的indexPathsForVisibleItems方法返回的数组成员是无序排列的，所以不能直接通过firstObject拿到第一个cell。
 *
 *  @warning 若可视区域为CGRectZero，则返回nil
 */
- (NSIndexPath *)qmui_indexPathForFirstVisibleCell;

@end
