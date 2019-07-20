/*****
 * Tencent is pleased to support the open source community by making QMUI_iOS available.
 * Copyright (C) 2016-2019 THL A29 Limited, a Tencent company. All rights reserved.
 * Licensed under the MIT License (the "License"); you may not use this file except in compliance with the License. You may obtain a copy of the License at
 * http://opensource.org/licenses/MIT
 * Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.
 *****/

//
//  UITableView+QMUI.h
//  qmui
//
//  Created by QMUI Team on 15/7/20.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/// cell 在当前 section 里的位置，注意判断时要用 (var & xxx) == xxx 的方式
typedef NS_OPTIONS(NSInteger, QMUITableViewCellPosition) {
    QMUITableViewCellPositionNone               = 0, // 默认
    QMUITableViewCellPositionFirstInSection     = 1 << 0,
    QMUITableViewCellPositionMiddleInSection    = 1 << 1,
    QMUITableViewCellPositionLastInSection      = 1 << 2,
    QMUITableViewCellPositionSingleInSection    = QMUITableViewCellPositionFirstInSection | QMUITableViewCellPositionLastInSection,
};

/**
 *  这个分类提供额外的功能包括：
 *  1. 将给定的 UITableView 格式化为 QMUITableView 风格的样式，以统一为配置表里的值
 *  2. 计算给定的某个 view 处于哪个 indexPath 的 cell 上
 *  3. 计算给定的某个 view 处于哪个 sectionHeader 上
 *  4. 获取所有可视范围内的 sectionHeader 的 index
 *  5. 获取正处于 pinned 状态（也即悬停在顶部）的 sectionHeader 的 index
 *  6. 判断某个给定的 sectionHeader 是否处于 pinned 状态
 *  7. 判断某个给定的 cell indexPath 是否处于可视范围内
 *  8. 计算给定的 cell 的 indexPath 所对应的 QMUITableViewCellPosition
 *  9. 清除当前列表的所有 selection（选中的背景灰色）
 *  10. 判断列表当前内容是否足够滚动
 *  11. 让某个 row 滚动到指定的位置（系统默认只可以将 row 滚动到 Top/Middle/Bottom）
 *  12. 在将 searchBar 作为 tableHeaderView 的情况下，获取列表真实的 contentSize（系统为了实现列表内容不足一屏时依然可以将 searchBar 滚动到 navigationBar 下，在这种情况下会强制增大 contentSize）
 *  13. 在将 searchBar 作为 tableHeaderView 的情况下，判断列表内容是否足够多到可滚动
 */
@interface UITableView (QMUI)

/// 将当前tableView按照QMUI统一定义的宏来渲染外观
- (void)qmui_styledAsQMUITableView;

/**
 *  获取某个 view 在 tableView 里的 indexPath
 *
 *  使用场景：例如每个 cell 内均有一个按钮，在该按钮的 addTarget 点击事件回调里可以用这个方法计算出按钮所在的 indexPath
 *
 *  @param view 要计算的 UIView
 *  @return view 所在的 indexPath，若不存在则返回 nil
 */
- (nullable NSIndexPath *)qmui_indexPathForRowAtView:(nullable UIView *)view;

/**
 *  计算某个 view 处于当前 tableView 里的哪个 sectionHeaderView 内
 *  @param view 要计算的 UIView
 *  @return view 所在的 sectionHeaderView 的 section，若不存在则返回 -1
 */
- (NSInteger)qmui_indexForSectionHeaderAtView:(nullable UIView *)view;

/// 获取可视范围内的所有 sectionHeader 的 index
@property(nonatomic, readonly, nullable) NSArray<NSNumber *> *qmui_indexForVisibleSectionHeaders;

/// 获取正处于 pinned（悬停在顶部）状态的 sectionHeader 的序号
@property(nonatomic, readonly) NSInteger qmui_indexOfPinnedSectionHeader;

/**
 *  判断给定的 section 的 header 是否处于 pinned 状态
 *  @param section 给定的 section 的序号
 *  @note 当列表往上滚动的过程中，header1 处于将要离开 pinned 状态、header2 即将进入 pinned 状态的这个过程，header1 和 header2 均不处于 pinned 状态
 */
- (BOOL)qmui_isHeaderPinnedForSection:(NSInteger)section;

/// 判断当前 indexPath 的 item 是否为可视的 item
- (BOOL)qmui_cellVisibleAtIndexPath:(nullable NSIndexPath *)indexPath;

/**
 * 根据给定的indexPath，配合dataSource得到对应的cell在当前section中所处的位置
 * @param indexPath cell所在的indexPath
 * @return 给定indexPath对应的cell在当前section中所处的位置
 */
- (QMUITableViewCellPosition)qmui_positionForRowAtIndexPath:(nullable NSIndexPath *)indexPath;

/// 取消选择状态
- (void)qmui_clearsSelection;

/**
 * 将指定的row滚到指定的位置（row的顶边缘和指定位置重叠），并对一些特殊情况做保护（例如列表内容不够一屏、要滚动的row是最后一条等）
 * @param offsetY 目标row要滚到的y值，这个y值是相对于tableView的frame而言的
 * @param indexPath 要滚动的目标indexPath，如果该 indexPath 不合法则该方法不会有任何效果
 * @param animated 是否需要动画
 */
- (void)qmui_scrollToRowFittingOffsetY:(CGFloat)offsetY atIndexPath:(nonnull NSIndexPath *)indexPath animated:(BOOL)animated;

/**
 *  当tableHeaderView为UISearchBar时，tableView为了实现searchbar滚到顶部自动吸附的效果，会强制让self.contentSize.height至少为frame.size.height那么高（这样才能滚动，否则不满一屏就无法滚动了），所以此时如果通过self.contentSize获取tableView的内容大小是不准确的，此时可以使用`qmui_realContentSize`替代。
 *
 *  `qmui_realContentSize`是实时通过计算最后一个section的frame，与footerView的frame比较得到实际的内容高度，这个过程不会导致额外的cellForRow调用，请放心使用。
 */
@property(nonatomic, assign, readonly) CGSize qmui_realContentSize;

/**
 *  UITableView的tableHeaderView如果是UISearchBar的话，tableView.contentSize会强制设置为至少比bounds高（从而实现headerView的吸附效果），从而导致qmui_canScroll的判断不准确。所以为UITableView重写了qmui_canScroll方法
 */
- (BOOL)qmui_canScroll;

/**
 等同于 UITableView 自 iOS 11 开始新增的同名方法，但兼容 iOS 11 以下的系统使用。

 @param updates insert/delete/reload/move calls
 @param completion completion callback
 */
- (void)qmui_performBatchUpdates:(void (NS_NOESCAPE ^ _Nullable)(void))updates completion:(void (^ _Nullable)(BOOL finished))completion;

@end

NS_ASSUME_NONNULL_END
