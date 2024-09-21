/**
 * Tencent is pleased to support the open source community by making QMUI_iOS available.
 * Copyright (C) 2016-2021 THL A29 Limited, a Tencent company. All rights reserved.
 * Licensed under the MIT License (the "License"); you may not use this file except in compliance with the License. You may obtain a copy of the License at
 * http://opensource.org/licenses/MIT
 * Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.
 */

//
//  QMUIPopupMenuView.h
//  qmui
//
//  Created by QMUI Team on 2017/2/24.
//

#import <UIKit/UIKit.h>
#import "QMUIPopupContainerView.h"
#import "QMUIPopupMenuItemViewProtocol.h"
#import "QMUIPopupMenuItem.h"
#import "QMUITableView.h"
#import "QMUILabel.h"
#import "QMUIPopupMenuItemView.h"

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, QMUIPopupMenuSelectedStyle) {
    QMUIPopupMenuSelectedStyleCheckmark,    // 小勾
    QMUIPopupMenuSelectedStyleCheckbox,     // 圆形勾
    QMUIPopupMenuSelectedStyleCustom,       // 自定义，默认不做任何表现，交给业务自行处理
};

typedef NS_ENUM(NSInteger, QMUIPopupMenuSelectedLayout) {
    QMUIPopupMenuSelectedLayoutAtEnd,
    QMUIPopupMenuSelectedLayoutAtStart,
};

/**
 *  用于弹出浮层里显示一行一行的菜单的控件。
 *  使用方式：
 *  1. 调用 init 方法初始化。
 *  2. 按需设置分隔线、item 高度等样式。
 *  3. 设置完样式后再通过 items 或 itemSections 添加菜单项，并在 item 点击事件里调用 hideWithAnimated: 隐藏浮层。
 *  4. 通过为 sourceBarItem/sourceView/sourceRect 三者中的一个赋值，来决定浮层布局的位置（参考父类）。
 *  5. 调用 showWithAnimated: 即可显示（参考父类）。
 *
 *  注意，QMUIPopupMenuView 的大小默认是按内容自适应的（item 的 sizeThatFits），但同时又受 adjustsWidthAutomatically/maximumWidth/minimumWidth 的控制。
 *
 *  关于颜色的设置：
 *  1. 如果整个菜单的颜色（包括图片、title、subtitle、checkmark、checkbox）均一致，则直接通过 menu.tintColor 设置即可，默认情况下这些元素的 tintColor 都是 nil，也即跟随 superview 的 tintColor 走。
 *  2. 如果 item 里某个元素的颜色与整体相比有差异化的诉求，则需要继承 QMUIPopupMenuItemView 实现一个子类，在子类的 setHighlighted:、setSelected:、tintColorDidChange 里处理，然后通过 menu.itemViewGenerator 返回这个子类。
 *  3. 特别的，QMUIPopupMenuItem.image 默认会以 AlwaysTemplate 方式渲染，也即由 tintColor 决定图片颜色，可显式声明为 AlwaysOriginal 来保持图片原始的颜色。
 */
@interface QMUIPopupMenuView : QMUIPopupContainerView<QMUITableViewDataSource, QMUITableViewDelegate>

/// contentView 里的 scrollView，所有 itemButton 都是放在这里面的。
@property(nonatomic, strong, readonly) QMUITableView *tableView;

/// 是否需要显示每个 item 之间的分隔线，默认为 NO，当为 YES 时，每个 section 除了最后一个 item 外其他 item 底部都会显示分隔线。分隔线显示在当前 item 上方，不占位。
@property(nonatomic, assign) BOOL shouldShowItemSeparator UI_APPEARANCE_SELECTOR;

/// item 分隔线的颜色，默认为 UIColorSeparator。
@property(nonatomic, strong, nullable) UIColor *itemSeparatorColor UI_APPEARANCE_SELECTOR;

/// item 分隔线的位置偏移，默认为 UIEdgeInsetsZero。item 分隔线的默认布局是 menuView 宽度减去左右 padding，如果你希望分隔线左右贴边则可为这个属性设置一个负值的 left/right。
@property(nonatomic, assign) UIEdgeInsets itemSeparatorInset UI_APPEARANCE_SELECTOR;

/// item 分隔线的高度，默认为 PixelOne。分隔线拥有自己的占位，不与 item 重叠。
@property(nonatomic, assign) CGFloat itemSeparatorHeight UI_APPEARANCE_SELECTOR;

/// 是否显示 section 和 section 之间的分隔线，默认为 NO，当为 YES 时，除了最后一个 section，其他 section 底部都会显示一条分隔线。分隔线拥有自己的占位，不与 item、sectionSpacing 重叠。
@property(nonatomic, assign) BOOL shouldShowSectionSeparator UI_APPEARANCE_SELECTOR;

/// section 分隔线的颜色，默认为 UIColorSeparator。分隔线拥有自己的占位，不与 sectionSpacing 重叠。
@property(nonatomic, strong, nullable) UIColor *sectionSeparatorColor UI_APPEARANCE_SELECTOR;

/// section 分隔线的位置偏移，默认为 UIEdgeInsetsZero。section 分隔线的默认布局是撑满整个 menuView，如果你不希望分隔线左右贴边则可为这个属性设置一个 left/right 不为 0 的值即可。
@property(nonatomic, assign) UIEdgeInsets sectionSeparatorInset UI_APPEARANCE_SELECTOR;

/// section 分隔线的高度，默认为 PixelOne。
@property(nonatomic, assign) CGFloat sectionSeparatorHeight UI_APPEARANCE_SELECTOR;

/// section 之间的间隔，默认为0，也即贴合到一起。
@property(nonatomic, assign) CGFloat sectionSpacing UI_APPEARANCE_SELECTOR;

/// section 之间的间隔颜色，当 sectionSpacing > 0 时才有意义，默认为 UIColorSeparator。
@property(nonatomic, strong, nullable) UIColor *sectionSpacingColor UI_APPEARANCE_SELECTOR;

/// 批量设置 sectionTitleLabel 的样式
@property(nonatomic, copy, nullable) void (^sectionTitleConfigurationHandler)(__kindof QMUIPopupMenuView *aMenuView, QMUILabel *sectionTitleLabel, NSInteger section);

/// 整个 menuView 内部上下左右的 padding，其中 padding.left/right 会被作为 item.button.contentEdgeInsets.left/right，也即每个 item 的宽度一定是撑满整个 menuView 的。
@property(nonatomic, assign) UIEdgeInsets padding UI_APPEARANCE_SELECTOR;

/// 每个 item 的统一高度，默认为 44。如果某个 item 设置了自己的 height，则不受 itemHeight 属性的约束。
/// 如果将 itemHeight 设置为 QMUIViewSelfSizingHeight 则会以 item sizeThatFits: 返回的结果作为最终的 item 高度。
@property(nonatomic, assign) CGFloat itemHeight UI_APPEARANCE_SELECTOR;

/// 默认 YES，也即会自动计算每个 item 的宽度，取其中最宽的值作为整个 menu 的宽度。
/// 当数据量大的情况下请手动置为 NO 并改为用 maximumWidth、minimumWidth 控制 menu 宽度，从而获取更优的性能。
@property(nonatomic, assign) BOOL adjustsWidthAutomatically;

/// item、sectionTitle 之间是否复用以提升性能，默认为 NO。
/// 当数据量大或有复杂异步场景的情况下可改为 YES。
/// 若需要修改值，建议在设置 items/sectionItems 之前就先设置好。
@property(nonatomic, assign) BOOL shouldReuseItems;

/// 当需要创建一个 itemView 时会试图从这个 block 获取，若业务没实现这个 block，则默认返回一个 @c QMUIPopupMenuItemView 实例。
@property(nonatomic, copy, nullable) __kindof UIControl<QMUIPopupMenuItemViewProtocol> * (^itemViewGenerator)(__kindof QMUIPopupMenuView *aMenuView);

/// 批量设置 itemView 的样式
@property(nonatomic, copy, nullable) void (^itemViewConfigurationHandler)(__kindof QMUIPopupMenuView *aMenuView, __kindof QMUIPopupMenuItem *aItem, __kindof UIControl<QMUIPopupMenuItemViewProtocol> *aItemView, NSInteger section, NSInteger index);

/// 设置 item，均处于同一个 section 内
@property(nonatomic, copy, nullable) NSArray<__kindof QMUIPopupMenuItem *> *items;

/// 设置多个 section 的多个 item
@property(nonatomic, copy, nullable) NSArray<NSArray<__kindof QMUIPopupMenuItem *> *> *itemSections;

/// 为每个 section 设置标题，不需要显示标题的 section 请使用空字符串占位。必须保证 @c sectionTitles 和 @c itemSections 长度相等。
/// @note 请在设置 item、itemSections 之前先设置本属性。
@property(nonatomic, copy, nullable) NSArray<NSString *> *sectionTitles;

/// 是否允许出现勾选，默认为 NO。
@property(nonatomic, assign) BOOL allowsSelection;

/// 是否允许多选，默认为 NO。当置为 YES 时会同时把 @c allowsSelection 也置为 YES。所以如果你只是想判断当前是否处于勾选状态，不关心单选还是多选，则直接访问 @c allowsSelection 即可。
@property(nonatomic, assign) BOOL allowsMultipleSelection;

/// 勾选的样式，默认为 checkmark。
@property(nonatomic, assign) QMUIPopupMenuSelectedStyle selectedStyle;

/// 勾选出现的位置，默认为 AtEnd，也即在按钮右侧。
@property(nonatomic, assign) QMUIPopupMenuSelectedLayout selectedLayout;

/// 当前选中的 item 序号，若当前是多选，则会返回第一个被选中的 item 的序号。
/// 若想清空选中状态，可赋值为 @c NSNotFound ，默认为 @c NSNotFound 。
/// @warning 仅用于单 section 的场景，多 section 场景请使用 @c selectedItemIndexPath 。
@property(nonatomic, assign) NSInteger selectedItemIndex;

/// 当前选中的 item 序号，若当前是多选，则会返回第一个被选中的 item 的序号。
/// 若想清空选中状态，可赋值为 @c nil ，默认为 @c nil 。
/// @note 可用于多 section 的场景。
@property(nonatomic, strong, nullable) NSIndexPath *selectedItemIndexPath;

/// 当前选中的所有 item 的序号。
/// 若想清空选中状态，可赋值为 @c nil ，默认为 @c nil 。
@property(nonatomic, strong, nullable) NSArray<NSIndexPath *> *selectedItemIndexPaths;

/// 当处于 @c allowsSelection 模式时，默认每个 item 都可被选中。如果希望某个 item 不参与 selected 操作，可通过该 block 返回 NO 来实现。
/// 如果想实现“最少选择n个”或“选择任意一个后无法再清空选择”的交互，也可通过这个 block 实现。
@property(nonatomic, copy, nullable) BOOL (^shouldSelectItemBlock)(__kindof QMUIPopupMenuItem *aItem, __kindof UIControl<QMUIPopupMenuItemViewProtocol> *aItemView, NSInteger section, NSInteger index);

/// 固定显示在菜单底部的 view，不跟随滚动，大小通过调用自身的 sizeThatFits: 获取。
/// @note 菜单的 padding 会作用在 item 上（也即列表），不会作用在 bottomAccessoryView 上，bottomAccessoryView 始终都是宽度撑满菜单，底部紧贴菜单。
@property(nonatomic, strong, nullable) __kindof UIView *bottomAccessoryView;

/// 刷新当前菜单的内容及布局
- (void)reload;

@end

NS_ASSUME_NONNULL_END
