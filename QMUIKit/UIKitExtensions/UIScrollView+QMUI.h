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
@property(nonatomic, assign, readonly) BOOL alreadyAtTop;

/// 判断UIScrollView是否已经处于底部（当UIScrollView内容不够多不可滚动时，也认为是在底部）
@property(nonatomic, assign, readonly) BOOL alreadyAtBottom;

/**
 * 判断当前的scrollView内容是否足够滚动
 * @warning 避免与<i>scrollEnabled</i>混淆
 */
- (BOOL)canScroll;

/**
 * 不管当前scrollView是否可滚动，直接将其滚动到最顶部
 * @param force 是否无视[self canScroll]而强制滚动
 * @param animated 是否用动画表现
 */
- (void)scrollToTopForce:(BOOL)force animated:(BOOL)animated;

/**
 * 等同于[self scrollToTopForce:NO animated:animated]
 */
- (void)scrollToTopAnimated:(BOOL)animated;

/// 等同于[self scrollToTopAnimated:NO]
- (void)scrollToTop;

/**
 * 如果当前的scrollView可滚动，则将其滚动到最底部
 * @param animated 是否用动画表现
 * @see [UIScrollView canScroll]
 */
- (void)scrollToBottomAnimated:(BOOL)animated;

/// 等同于[self scrollToBottomAnimated:NO]
- (void)scrollToBottom;

// 立即停止滚动，用于那种手指已经离开屏幕但列表还在滚动的情况。
- (void)stopDeceleratingIfNeeded;

@end
