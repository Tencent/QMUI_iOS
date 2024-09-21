/**
 * Tencent is pleased to support the open source community by making QMUI_iOS available.
 * Copyright (C) 2016-2021 THL A29 Limited, a Tencent company. All rights reserved.
 * Licensed under the MIT License (the "License"); you may not use this file except in compliance with the License. You may obtain a copy of the License at
 * http://opensource.org/licenses/MIT
 * Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.
 */

//
//  QMUILayouterItem.h
//  QMUIKit
//
//  Created by QMUI Team on 2024/1/2.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, QMUILayouterAlignment) {
    /// 对水平容器来说是从左往右，对竖直容器来说是从上往下。若容器大小不足以容纳所有 item，则末尾的 item 大小会被强制裁剪以保证不溢出。
    QMUILayouterAlignmentLeading,
    
    /// 对水平容器来说是从左往右然后整体右对齐父容器，对竖直容器来说是从上往下然后整体底对齐父容器。若 item 超过父容器大小，则与 QMUILayouterAlignmentLeading 一致。
    QMUILayouterAlignmentTrailing,
    
    /// 对水平容器来说是从左往右然后整体在父容器里居中，对竖直容器来说是从上往下然后整体在父容器里居中。若 item 超过父容器大小，则与 QMUILayouterAlignmentLeading 一致。
    QMUILayouterAlignmentCenter,
    
    /// 当表示与容器布局方向相同的方向时（例如 Linear 的水平，或 Vertical 的竖直），仅当子元素个数为1时有效，会在指定方向上撑满父容器。当子元素个数大于1时与 QMUILayouterAlignmentLeading 一致。
    /// 当表示与容器布局方向垂直的方向时（例如 Linear 的竖直，或 Vertical 的水平），则所有子元素均会在指定方向上撑满父容器。
    QMUILayouterAlignmentFill,
};

/// 表示父容器还有剩余空间时当前 item 也保持自身尺寸不变，不去拉伸填充剩余空间
extern const CGFloat QMUILayouterGrowNever;

/// 表示父容器还有剩余空间时当前 item 以最高优先级去填充（一般用1就行，不需要用到 Most）
extern const CGFloat QMUILayouterGrowMost;

/// 表示父容器空间不足以容纳所有 item，不得已要压缩 item 时，不要压缩当前 item
extern const CGFloat QMUILayouterShrinkNever;

/// 表示父容器空间不足以容纳所有 item，不得已要压缩 item 时，允许压缩当前 item（按各自尺寸比例）
extern const CGFloat QMUILayouterShrinkDefault;

/// 表示父容器空间不足以容纳所有 item，不得已要压缩 item 时，使当前 item 以最高优先级压缩
extern const CGFloat QMUILayouterShrinkMost;

@interface QMUILayouterItem : NSObject

/// 通常用于生成一个子元素角色的 item，不允许拉伸也不允许缩放。
+ (instancetype)itemWithView:(__kindof UIView *)view margin:(UIEdgeInsets)margin;

/// 通常用于生成一个子元素角色的 item
+ (instancetype)itemWithView:(__kindof UIView *)view margin:(UIEdgeInsets)margin grow:(CGFloat)grow shrink:(CGFloat)shrink;

/// 关联的实体 view，如果当前 item 是虚拟布局容器，也可以不存在关联的实体 view。
/// @note 一般将 view 添加到界面上后再赋值给这个属性，这样可确保后续的运算最准确。
@property(nonatomic, weak, nullable) __kindof UIView *view;

/// frame 的值变化时才会设置给 view 且标记为在下一次 runloop 里需要刷新布局。
@property(nonatomic, assign) CGRect frame;

/// 给 parentItem 布局自己时使用，自己内部 layout 时不使用，也不包含在自身的 sizeThatFits: 结果里。
@property(nonatomic, assign) UIEdgeInsets margin;

/// 表示父容器在布局自己时可忽略 item 自身的宽度，仅通过将所有 grow 大于0的 item 按各自 grow 比例计算得到宽度，例如一行里有两个 item，一个 item 宽度为自身内容宽度，另一个 item 撑满容器剩余空间。默认为 QMUILayouterGrowNever，也即自适应内容，设置为 QMUILayouterGrowMost 或某个大于0的数值可按比例撑满容器。
/// @warning 仅在支持比例布局的容器里有效（例如 LinearHorizontal、LinearVertical）
@property(nonatomic, assign) CGFloat grow;

/// 当父容器空间不足以容纳所有 item 时，由每个 item 的 shrink 值及 item 的尺寸来决定该压缩哪个 item 的尺寸、压缩多少。默认为 QMUILayouterShrinkNever，值越大则压缩得越狠。
@property(nonatomic, assign) CGFloat shrink;

/// 最大的尺寸，在自身 sizeThatFits、父容器 grow 时生效，在 setFrame 时不限制（也即非要的话你也可以设置一个突破限制的尺寸），默认为 CGSizeMax
@property(nonatomic, assign) CGSize maximumSize;

/// 最小的尺寸，在自身 sizeThatFits、父容器 shrink 时生效，在 setFrame 时不限制（也即非要的话你也可以设置一个突破限制的尺寸），默认为 CGSizeZero
@property(nonatomic, assign) CGSize minimumSize;

/// 当前 item 是否可视，仅可视的 item 会参与布局运算。
@property(nonatomic, assign, readonly) BOOL visible;

/// 允许业务自定义 visible 的逻辑。
@property(nonatomic, copy, nullable) BOOL (^visibleBlock)(QMUILayouterItem *aItem);

/// 父容器，在 setChildItems: 时会将父子关系关联起来。
@property(nonatomic, weak, readonly, nullable) __kindof QMUILayouterItem *parentItem;

/// 所有子元素
@property(nonatomic, strong) NSArray<QMUILayouterItem *> *childItems;

/// 所有 visible 为 YES 的子元素，布局运算时使用这个。
@property(nonatomic, weak, readonly, nullable) NSArray<QMUILayouterItem *> *visibleChildItems;

// 便捷方法，会自动判空
@property(nonatomic, weak, readonly, nullable) QMUILayouterItem *visibleChildItem0;
@property(nonatomic, weak, readonly, nullable) QMUILayouterItem *visibleChildItem1;
@property(nonatomic, weak, readonly, nullable) QMUILayouterItem *visibleChildItem2;
@property(nonatomic, weak, readonly, nullable) QMUILayouterItem *visibleChildItem3;

/// 计算在特定宽高下的自身尺寸，注意 self.margin 不参与其中。通常将 height 传 CGFLOAT_MAX 以得到一个自适应内容的大小。
- (CGSize)sizeThatFits:(CGSize)size;

/// 允许业务自定义 sizeThatFits: 的逻辑（注意这个主要用于父容器布局时询问子元素大小用，不用于元素计算自身内容大小时用），在调用完 block 后才进行 min/height 保护。
@property(nonatomic, copy, nullable) CGSize (^sizeThatFitsBlock)(QMUILayouterItem *aItem, CGSize size, CGSize superResult);

/// 保持 x/y 不变，将自身大小设置为不受宽高限制的尺寸，并将布局标记为需要被刷新。
- (void)sizeToFit;

/// 标记需要刷新布局，在同一个 runloop 里的所有 setNeedsLayout 会统一在下一个 runloop 里才一起布局。
- (void)setNeedsLayout;

/// 如果当前布局待刷新，则立即刷新，以便得到最新的布局结果。
- (void)layoutIfNeeded;

/// 是否在指定 view 的坐标系里显示自身及所有子元素的布局边框（颜色随机），请在 layoutSubviews、viewDidLayoutSubviews 里调用（也即每次参数 view 的布局发生变化时）。
- (void)showDebugBorderRecursivelyInView:(UIView *)view;

/// 一般用作调试时区分用，业务随意赋值。
@property(nonatomic, copy, nullable) NSString *identifier;
@end

@interface QMUILayouterItem (UISubclassingHooks)

/// 子类计算自身大小的逻辑请写在这个方法里，如果是外部希望得知当前元素的大小，请调用 sizeThatFits: 或 sizeToFit。
/// @param shouldConsiderBlock 计算大小时是否需要考虑 sizeThatFitsBlock:，如果当前是外部询问元素大小，参数为 YES，如果是内部希望得知内容实际大小，参数为 NO。
- (CGSize)sizeThatFits:(CGSize)size shouldConsiderBlock:(BOOL)shouldConsiderBlock;

/// 子类重写布局时使用，外部不要直接调用它。可视情况自行决定是否要调用 super。
- (void)layout;
@end

NS_ASSUME_NONNULL_END
