//
//  UIControl+QMUI.h
//  qmui
//
//  Created by ZhoonChen on 15/7/20.
//  Copyright (c) 2015年 QMUI Team. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIControl (QMUI)

/**
 *  是否接管control的touch事件
 *  UIControl在UIScrollView上会有300毫秒的延迟，如果手动取消系统的这个延迟，则系统无法判断是否要点击还是滚动，导致setHighlighted会有问题
 *  所以，这里把qmui_needsTakeOverTouchEvent设置为yes，则会通过重写touch事件来模拟系统的延迟效果，但是同时又比较优雅的处理setHighlighted的问题
 *  @warning 不需要搭配 UIScrollView.delaysContentTouches 使用。
 */
@property(nonatomic,assign,readwrite) BOOL qmui_needsTakeOverTouchEvent;
/*
 * 响应区域需要改变的大小，负值表示往外扩大，正值表示往内缩小
 */
@property(nonatomic,assign) UIEdgeInsets qmui_outsideEdge;


@end
