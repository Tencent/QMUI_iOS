//
//  UIView+QMUI.h
//  qmui
//
//  Created by QQMail on 15/7/20.
//  Copyright (c) 2015年 QMUI Team. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIView (QMUI)

/**
 * 设置view的width和height
 */
- (void)qmui_setWidth:(CGFloat)width height:(CGFloat)height;

/**
 * 设置view的width
 */
- (void)qmui_setWidth:(CGFloat)width;

/**
 * 设置view的height
 */
- (void)qmui_setHeight:(CGFloat)height;

/**
 * 设置view的x和y
 */
- (void)qmui_setOriginX:(CGFloat)x y:(CGFloat)y;

/**
 * 设置view的x
 */
- (void)qmui_setOriginX:(CGFloat)x;

/**
 * 设置view的y
 */
- (void)qmui_setOriginY:(CGFloat)y;

/**
 * 获取当前view在superview内的水平居中时的minX
 */
- (CGFloat)qmui_minXWhenCenterInSuperview;

/**
 * 获取当前view在superview内的垂直居中时的minX
 */
- (CGFloat)qmui_minYWhenCenterInSuperview;

- (void)qmui_removeAllSubviews;

@end


/**
 *  Debug UIView 的时候用，对某个 view 的 subviews 都添加一个半透明的背景色，方面查看 view 的布局情况
 */
@interface UIView (QMUI_Debug)

/// 是否需要添加debug背景色，默认NO
@property(nonatomic, assign) BOOL qmui_shouldShowDebugColor;
/// 是否每个view的背景色随机，如果不随机则统一使用半透明红色，默认NO
@property(nonatomic, assign) BOOL qmui_needsDifferentDebugColor;
/// 标记一个view是否已经被添加了debug背景色，外部一般不使用
@property(nonatomic, assign, readonly) BOOL qmui_hasDebugColor;

@end


typedef NS_OPTIONS(NSUInteger, QMUIBorderViewPosition) {
    QMUIBorderViewPositionNone      = 0,
    QMUIBorderViewPositionTop       = 1 << 0,
    QMUIBorderViewPositionLeft      = 1 << 1,
    QMUIBorderViewPositionBottom    = 1 << 2,
    QMUIBorderViewPositionRight     = 1 << 3
};

/**
 *  Border 为UIView增加border。系统的border只能通过view.layer来设置，并且无法只单独设置某些边，所以导致很多情况下需要重新初始化一条新的layer加在view上，略麻烦。
 *
 *  QMUI_Border分类支持为UIView设置一条border，可以是任意一条边或者多条边。
 */
@interface UIView (QMUI_Border)

/// 设置边框类型，支持组合，例如：`borderType = QMUIBorderViewTypeTop|QMUIBorderViewTypeBottom`
@property(nonatomic, assign) QMUIBorderViewPosition qmui_borderPosition;

/// 边框的大小，默认为PixelOne
@property(nonatomic, assign) IBInspectable CGFloat qmui_borderWidth;

/// 边框的颜色，默认为UIColorSeparator
@property(nonatomic, strong) IBInspectable UIColor *qmui_borderColor;

/// 虚线 : dashPhase默认是0，且当dashPattern设置了才有效
@property(nonatomic, assign) CGFloat qmui_dashPhase;
@property(nonatomic, copy) NSArray <NSNumber *> *qmui_dashPattern;

/// border的layer
@property(nonatomic, strong, readonly) CAShapeLayer *qmui_borderLayer;

@end
