//
//  UIVisualEffect+QMUITheme.h
//  QMUIKit
//
//  Created by MoLice on 2019/7/20.
//  Copyright © 2019 QMUI Team. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class QMUIThemeManager;

@protocol QMUIDynamicEffectProtocol <NSObject>

@required

/// 获取当前 UIVisualEffect 的实际 effect（返回的 effect 必定不是 dynamic image）
@property(nonatomic, strong, readonly) __kindof UIVisualEffect *qmui_rawEffect;

/// 标志当前 UIVisualEffect 对象是否为动态 effect（由 [UIVisualEffect qmui_effectWithThemeProvider:] 创建的 effect
@property(nonatomic, assign, readonly) BOOL qmui_isDynamicEffect;

@end

@interface UIVisualEffect (QMUITheme) <QMUIDynamicEffectProtocol>

/**
 生成一个动态的 UIVisualEffect 对象，每次使用该对象时都会动态根据当前的 QMUIThemeManager 主题返回对应的 effect。
 @param provider 当 UIVisualEffect 被使用时，这个 provider 会被调用，返回对应当前主题的 effect 值
 @return 一个动态的 UIVisualEffect 对象，被使用时才会返回实际的 effect 效果
 */
+ (UIVisualEffect *)qmui_effectWithThemeProvider:(UIVisualEffect *(^)(__kindof QMUIThemeManager *manager, __kindof NSObject<NSCopying> * _Nullable identifier, __kindof NSObject * _Nullable theme))provider;
@end

NS_ASSUME_NONNULL_END
