//
//  QMUIMarqueeLabel.h
//  qmui
//
//  Created by MoLice on 2017/5/31.
//  Copyright © 2017年 QMUI Team. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
 *  简易的跑马灯 label 控件，在文字超过 label 可视区域时会自动开启跑马灯效果展示文字。
 *  @warning lineBreakMode 默认为 NSLineBreakByClipping（UILabel 默认值为 NSLineBreakByTruncatingTail）
 *  @warning 会忽略 numberOfLines 属性，强制以 1 来展示。
 */
@interface QMUIMarqueeLabel : UILabel

/// 控制滚动的速度，1 表示一帧滚动 1pt，10 表示一帧滚动 10pt
@property(nonatomic, assign) CGFloat speed;

/// 当文字滚动到开头和结尾两处时都要停顿一下，这个属性控制停顿的时长，默认为 1，单位为秒。
@property(nonatomic, assign) NSTimeInterval pauseDurationWhenMoveToEdge;

/**
 *  自动判断 label 的 frame 是否超出当前的 UIWindow 可视范围，超出则自动停止动画。默认为 YES。
 *  @warning 某些场景并无法触发这个自动检测（例如直接调整 label.superview 的 frame 而不是 label 自身的 frame），这种情况暂不处理。
 */
@property(nonatomic, assign) BOOL automaticallyValidateVisibleFrame;

/// 在文字滚动到左右边缘时，是否要显示一个阴影渐变遮罩，默认为 NO。
@property(nonatomic, assign) BOOL shouldFadeAtEdge;
@property(nonatomic, assign) CGFloat fadeWidth;
@property(nonatomic, strong) UIColor *fadeStartColor;
@property(nonatomic, strong) UIColor *fadeEndColor;
@end


/// 如果在可复用的 UIView 里使用（例如 UITableViewCell、UICollectionViewCell），由于 UIView 可能重复被使用，因此需要在某些显示/隐藏的时机去手动开启/关闭 label 的动画。如果在普通的 UIView 里使用则无需关注这一部分的代码。
@interface QMUIMarqueeLabel (ReusableView)

/**
 *  尝试开启 label 的滚动动画
 *  @return 是否成功开启
 */
- (BOOL)requestToStartAnimation;

/**
 *  尝试停止 label 的滚动动画
 *  @return 是否成功停止
 */
- (BOOL)requestToStopAnimation;
@end
