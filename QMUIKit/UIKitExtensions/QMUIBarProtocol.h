//
//  QMUIBarProtocol.h
//  QMUIKit
//
//  Created by molice on 2022/5/18.
//  Copyright © 2022 QMUI Team. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/**
 UINavigationBar、UITabBar 在一些特性上基本相同，但它们又是分别继承自 UIView 的，导致很多属性、方法都需要两边添加，所以这里建了个协议，分别在 UINavigationBar、UITabBar 里实现，以保证两边的功能是相同的。
 */
@protocol QMUIBarProtocol <NSObject>

/**
 bar 的背景 view，可能显示磨砂、背景图。
 在 iOS 10 及以后是私有的 _UIBarBackground 类。
 在 iOS 9 及以前是私有的类，对 UINavigationBar 来说是 _UINavigationBarBackground，对 UITabBar 来说是 _UITabBarBackgroundView。
 */
@property(nullable, nonatomic, strong, readonly) UIView *qmui_backgroundView;

/**
 qmui_backgroundView 内的 subview，用于显示分隔线 shadowImage，注意这个 view 是溢出到 qmui_backgroundView 外的。若 shadowImage 为 [UIImage new]，则这个 view 的高度为 0。
 */
@property(nullable, nonatomic, strong, readonly) UIImageView *qmui_shadowImageView;

/**
 获取 bar 里面的磨砂背景，具体的 view 层级是 UIBar → _UIBarBackground → UIVisualEffectView。仅在 bar 的样式确定之后系统才会创建。
 iOS 15 及以后，bar 里可能会同时存在多个磨砂背景（详见 @c qmui_effectViews ），这个属性会获取其中正在显示的那个磨砂，如果两个都在显示，则取 view 层级树里更上层的那个。
 */
@property(nullable, nonatomic, strong, readonly) UIVisualEffectView *qmui_effectView;

/**
 iOS 15 及以后，由于 bar 的样式在滚动到顶部和底部会有不同，所以可能同时存在两个 effectView。
 */
@property(nullable, nonatomic, strong, readonly) NSArray<UIVisualEffectView *> *qmui_effectViews;

/**
 允许直接指定 tab 具体的磨砂样式（系统的仅在 iOS 13 及以后用 UINavigation(Tab)BarAppearance.backgroundEffects 才可以实现）。默认为 nil，如果你没设置过这个属性，那么 nil 的行为就是维持系统的样式，但如果你主动设置过这个属性，那么后续的 nil 则表示把磨砂清空（也即可能出现背景透明的 bar）。
 @note 生效的前提是 backgroundImage、barTintColor 都为空，因为这两者的优先级都比磨砂高。
 */
@property(nullable, nonatomic, strong) UIBlurEffect *qmui_effect;

/**
 当 tabBar 展示磨砂的样式时，可以通过这个属性精准指定磨砂的前景色（可参考 CALayer(QMUI).qmui_foregroundColor），因为系统的某些 UIBlurEffectStyle 会自带前景色，且不可去掉，那种情况下你就无法得到准确的自定义前景色了（即便你试图通过设置半透明的 barTintColor 来达到前景色的效果，那也依然会叠加一层系统自带的半透明前景色）。
 */
@property(nullable, nonatomic, strong) UIColor *qmui_effectForegroundColor;

@end

NS_ASSUME_NONNULL_END
