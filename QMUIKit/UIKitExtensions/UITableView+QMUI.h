//
//  UITableView+QMUI.h
//  qmui
//
//  Created by ZhoonChen on 15/7/20.
//  Copyright (c) 2015年 QMUI Team. All rights reserved.
//

#import "QMUICellHeightCache.h"
#import "QMUITableView.h"

typedef NS_ENUM(NSInteger, QMUITableViewCellPosition) {
    QMUITableViewCellPositionNone = -1, // 初始化用
    QMUITableViewCellPositionFirstInSection,
    QMUITableViewCellPositionMiddleInSection,
    QMUITableViewCellPositionLastInSection,
    QMUITableViewCellPositionSingleInSection,
    QMUITableViewCellPositionNormal,
};

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
- (NSIndexPath *)qmui_indexPathForRowAtView:(UIView *)view;

/**
 *  计算某个 view 处于当前 tableView 里的哪个 sectionHeaderView 内
 *  @param view 要计算的 UIView
 *  @return view 所在的 sectionHeaderView 的 section，若不存在则返回 -1
 */
- (NSInteger)qmui_indexForSectionHeaderAtView:(UIView *)view;

/**
 * 根据给定的indexPath，配合dataSource得到对应的cell在当前section中所处的位置
 * @param indexPath cell所在的indexPath
 * @return 给定indexPath对应的cell在当前section中所处的位置
 */
- (QMUITableViewCellPosition)qmui_positionForRowAtIndexPath:(NSIndexPath *)indexPath;

/// 判断当前 indexPath 的 item 是否为可视的 item
- (BOOL)qmui_cellVisibleAtIndexPath:(NSIndexPath *)indexPath;

// 取消选择状态
- (void)qmui_clearsSelection;

/**
 * 将指定的row滚到指定的位置（row的顶边缘和指定位置重叠），并对一些特殊情况做保护（例如列表内容不够一屏、要滚动的row是最后一条等）
 * @param offsetY 目标row要滚到的y值，这个y值是相对于tableView的frame而言的
 * @param indexPath 要滚动的目标indexPath，请自行保证indexPath是合法的
 * @param animated 是否需要动画
 */
- (void)qmui_scrollToRowFittingOffsetY:(CGFloat)offsetY atIndexPath:(NSIndexPath *)indexPath animated:(BOOL)animated;

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

@end


/// ====================== 动态计算 cell 高度相关 =======================

/**
 *  UITableView 定义了一套动态计算 cell 高度的方式：
 *
 *  其思路是参考开源代码：https://github.com/forkingdog/UITableView-FDTemplateLayoutCell。
 *
 *  1. cell 必须实现 sizeThatFits: 方法，在里面计算自身的高度并返回
 *  2. 初始化一个 QMUITableView，并为其指定一个 QMUITableViewDataSource
 *  3. 实现 qmui_tableView:cellWithIdentifier: 方法，在里面为不同的 identifier 创建不同的 cell 实例
 *  4. 在 tableView:cellForRowAtIndexPath: 里使用 qmui_tableView:cellWithIdentifier: 获取 cell 
 *  5. 在 tableView:heightForRowAtIndexPath: 里使用 UITableView (QMUILayoutCell) 提供的几种方法得到 cell 的高度
 *
 *  这套方式的好处是 tableView 能直接操作 cell 的实例，cell 无需增加额外的专门用于获取 cell 高度的方法。并且这套方式支持基本的高度缓存（可按 key 缓存或按 indexPath 缓存），若使用了缓存，请注意在适当的时机去更新缓存（例如某个 cell 的内容发生变化，可能 cell 的高度也会变化，则需要更新这个 cell 已被缓存起来的高度）。
 *
 *  使用这套方式额外的消耗是每个 identifier 都会生成一个多余的 cell 实例（专用于高度计算），但大部分情况下一个生成一个 cell 实例并不会带来过多的负担，所以一般不用担心这个问题。
 */

@interface UITableView (QMUILayoutCell)

/**
 *  通过 qmui_tableView:cellWithIdentifier: 得到 identifier 对应的 cell 实例，并在 configuration 里对 cell 进行渲染后，得到 cell 的高度。
 *  @param  identifier cell 的 identifier
 *  @param  configuration 用于渲染 cell 的block，一般与 tableView:cellForRowAtIndexPath: 里渲染 cell 的代码一样
 */
- (CGFloat)qmui_heightForCellWithIdentifier:(NSString *)identifier configuration:(void (^)(__kindof UITableViewCell *cell))configuration;

/**
 *  通过 qmui_tableView:cellWithIdentifier: 得到 identifier 对应的 cell 实例，并在 configuration 里对 cell 进行渲染后，得到 cell 的高度。
 *
 *  以 indexPath 为单位进行缓存，相同的 indexPath 高度将不会重复计算，若需刷新高度，请参考 QMUICellHeightIndexPathCache
 *
 *  @param  identifier cell 的 identifier
 *  @param  configuration 用于渲染 cell 的block，一般与 tableView:cellForRowAtIndexPath: 里渲染 cell 的代码一样
 */
- (CGFloat)qmui_heightForCellWithIdentifier:(NSString *)identifier cacheByIndexPath:(NSIndexPath *)indexPath configuration:(void (^)(__kindof UITableViewCell *cell))configuration;

/**
 *  通过 qmui_tableView:cellWithIdentifier: 得到 identifier 对应的 cell 实例，并在 configuration 里对 cell 进行渲染后，得到 cell 的高度。
 *
 *  以自定义的 key 为单位进行缓存，相同的 key 高度将不会重复计算，若需刷新高度，请参考 QMUICellHeightKeyCache
 *
 *  @param  identifier cell 的 identifier
 *  @param  configuration 用于渲染 cell 的block，一般与 tableView:cellForRowAtIndexPath: 里渲染 cell 的代码一样
 */
- (CGFloat)qmui_heightForCellWithIdentifier:(NSString *)identifier cacheByKey:(id<NSCopying>)key configuration:(void (^)(__kindof UITableViewCell *cell))configuration;

@end

@interface UITableView (QMUIKeyedHeightCache)

@property (nonatomic, strong, readonly) QMUICellHeightKeyCache *qmui_keyedHeightCache;

@end

@interface UITableView (QMUICellHeightIndexPathCache)

@property (nonatomic, strong, readonly) QMUICellHeightIndexPathCache *qmui_indexPathHeightCache;

@end

@interface UITableView (QMUIIndexPathHeightCacheInvalidation)

/// 当需要reloadData的时候，又不想使布局失效，可以调用下面这个方法。例如在底部加载更多。
- (void)qmui_reloadDataWithoutInvalidateIndexPathHeightCache;

@end
