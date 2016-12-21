//
//  QMUICollectionViewPagingLayout.h
//  qmui
//
//  Created by QQMail on 15/9/24.
//  Copyright © 2015年 QMUI Team. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, QMUICollectionViewPagingLayoutStyle) {
    QMUICollectionViewPagingLayoutStyleDefault, // 普通模式，水平滑动
    QMUICollectionViewPagingLayoutStyleScale,   // 缩放模式，两边的item会小一点，逐渐向中间放大
    QMUICollectionViewPagingLayoutStyleRotation // 旋转模式，围绕底部某个点为中心旋转
};

/**
 *  支持按页横向滚动的 UICollectionViewLayout，可切换不同类型的滚动动画。
 */
@interface QMUICollectionViewPagingLayout : UICollectionViewFlowLayout

- (instancetype)initWithStyle:(QMUICollectionViewPagingLayoutStyle)style NS_DESIGNATED_INITIALIZER;

@property(nonatomic, assign, readonly) QMUICollectionViewPagingLayoutStyle style;

/**
 *  规定超过这个滚动速度就强制翻页，从而使翻页更容易触发。默认为 0.4
 */
@property(nonatomic, assign) CGFloat velocityForEnsurePageDown;

/**
 *  是否支持一次滑动可以滚动多个 item，默认为 YES
 */
@property(nonatomic, assign) BOOL allowsMultipleItemScroll;

/**
 *  规定了当支持一次滑动允许滚动多个 item 的时候，滑动速度要达到多少才会滚动多个 item，默认为 0.7
 *
 *  仅当 allowsMultipleItemScroll 为 YES 时生效
 */
@property(nonatomic, assign) CGFloat mutipleItemScrollVelocityLimit;

@end


@interface QMUICollectionViewPagingLayout (ScaleStyle)

/**
 *  中间那张卡片基于初始大小的缩放倍数，默认为 1.0
 */
@property(nonatomic, assign) CGFloat maximumScale;

/**
 *  除了中间之外的其他卡片基于初始大小的缩放倍数，默认为 0.9
 */
@property(nonatomic, assign) CGFloat minimumScale;
@end


extern const CGFloat QMUICollectionViewPagingLayoutRotationRadiusAutomatic;

@interface QMUICollectionViewPagingLayout (RotationStyle)

/**
 *  旋转卡片相关
 *  左右两个卡片最终旋转的角度有 rotationRadius * 90 计算出来
 *  rotationRadius表示旋转的半径
 *  @warning 仅当 style 为 QMUICollectionViewPagingLayoutStyleRotation 时才生效
 */
@property(nonatomic, assign) CGFloat rotationRatio;
@property(nonatomic, assign) CGFloat rotationRadius;
@end
