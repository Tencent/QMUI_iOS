//
//  UIScrollView+QMUI.h
//  qmui
//
//  Created by ZhoonChen on 15/7/20.
//  Copyright (c) 2015年 QMUI Team. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIScrollView (QMUI)

/// 判断UIScrollView是否已经处于顶部（当UIScrollView内容不够多不可滚动时，也认为是在顶部）
@property(nonatomic, assign, readonly) BOOL qmui_alreadyAtTop;

/// 判断UIScrollView是否已经处于底部（当UIScrollView内容不够多不可滚动时，也认为是在底部）
@property(nonatomic, assign, readonly) BOOL qmui_alreadyAtBottom;

/**
 * 判断当前的scrollView内容是否足够滚动
 * @warning 避免与<i>scrollEnabled</i>混淆
 */
- (BOOL)qmui_canScroll;

/**
 * 不管当前scrollView是否可滚动，直接将其滚动到最顶部
 * @param force 是否无视[self qmui_canScroll]而强制滚动
 * @param animated 是否用动画表现
 */
- (void)qmui_scrollToTopForce:(BOOL)force animated:(BOOL)animated;

/**
 * 等同于[self qmui_scrollToTopForce:NO animated:animated]
 */
- (void)qmui_scrollToTopAnimated:(BOOL)animated;

/// 等同于[self qmui_scrollToTopAnimated:NO]
- (void)qmui_scrollToTop;

/**
 * 如果当前的scrollView可滚动，则将其滚动到最底部
 * @param animated 是否用动画表现
 * @see [UIScrollView qmui_canScroll]
 */
- (void)qmui_scrollToBottomAnimated:(BOOL)animated;

/// 等同于[self qmui_scrollToBottomAnimated:NO]
- (void)qmui_scrollToBottom;

// 立即停止滚动，用于那种手指已经离开屏幕但列表还在滚动的情况。
- (void)qmui_stopDeceleratingIfNeeded;

@end
