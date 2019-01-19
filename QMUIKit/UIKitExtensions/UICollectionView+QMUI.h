/*****
 * Tencent is pleased to support the open source community by making QMUI_iOS available.
 * Copyright (C) 2016-2019 THL A29 Limited, a Tencent company. All rights reserved.
 * Licensed under the MIT License (the "License"); you may not use this file except in compliance with the License. You may obtain a copy of the License at
 * http://opensource.org/licenses/MIT
 * Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.
 *****/

//
//  UICollectionView+QMUI.h
//  qmui
//
//  Created by QMUI Team on 15/7/20.
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
 *  对系统的 indexPathsForVisibleItems 进行了排序后的结果
 */
- (NSArray<NSIndexPath *> *)qmui_indexPathsForVisibleItems;

/**
 *  获取可视区域内第一个cell的indexPath。
 *
 *  为什么需要这个方法是因为系统的indexPathsForVisibleItems方法返回的数组成员是无序排列的，所以不能直接通过firstObject拿到第一个cell。
 *
 *  @warning 若可视区域为CGRectZero，则返回nil
 */
- (NSIndexPath *)qmui_indexPathForFirstVisibleCell;

@end
