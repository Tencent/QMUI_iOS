//
//  QMUIPopupMenuView.h
//  qmui
//
//  Created by MoLice on 2017/2/24.
//  Copyright © 2017年 QMUI Team. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "QMUIPopupContainerView.h"
#import "QMUIPopupMenuItemProtocol.h"
#import "QMUIPopupMenuBaseItem.h"
#import "QMUIPopupMenuButtonItem.h"

/**
 *  用于弹出浮层里显示一行一行的菜单的控件。
 *  使用方式：
 *  1. 调用 init 方法初始化。
 *  2. 按需设置分隔线、item 高度等样式。
 *  3. 设置完样式后再通过 items 或 itemSections 添加菜单项。
 *  4. 调用 layoutWithTargetView: 或 layoutWithTargetRectInScreenCoordinate: 来布局菜单（参考父类）。
 *  5. 调用 showWithAnimated: 即可显示（参考父类）。
 */
@interface QMUIPopupMenuView : QMUIPopupContainerView

/// 是否需要显示每个 item 之间的分隔线，默认为 NO。当开启了 shouldShowSectionSeparatorOnly 后，这个属性无效。
@property(nonatomic, assign) BOOL shouldShowItemSeparator UI_APPEARANCE_SELECTOR;

/// 是否只显示 section 和 section 之间的分隔线，默认为 NO，开启这个属性会让 shouldShowItemSeparator 失效。
@property(nonatomic, assign) BOOL shouldShowSectionSeparatorOnly UI_APPEARANCE_SELECTOR;

/// item 之间的分隔线、section 之间的分隔线的颜色，默认为 UIColorSeparator。
@property(nonatomic, strong, nullable) UIColor *separatorColor UI_APPEARANCE_SELECTOR;

/// item 里文字的字体，默认为 UIFontMake(16)。
@property(nonatomic, strong, nullable) UIFont *itemTitleFont UI_APPEARANCE_SELECTOR;

/// item 里文字的颜色，默认为 UIColorBlue
@property(nonatomic, strong, nullable) UIColor *itemTitleColor UI_APPEARANCE_SELECTOR;

/// 整个 menuView 内部上下左右的 padding，其中 padding.left/right 会被作为 item.button.contentEdgeInsets.left/right，也即每个 item 的宽度一定是撑满整个 menuView 的。
@property(nonatomic, assign) UIEdgeInsets padding UI_APPEARANCE_SELECTOR;

/// 每个 item 的统一高度，默认为 44。如果某个 item 设置了自己的 height，则不受 itemHeight 属性的约束。
@property(nonatomic, assign) CGFloat itemHeight UI_APPEARANCE_SELECTOR;

/// item、section 之间的分隔线的位置偏移，默认为 UIEdgeInsetsZero。分隔线的默认布局是撑满整个 menuView，如果你不希望分隔线左右贴边则可为这个属性设置一个 left/right 不为 0 的值即可。
@property(nonatomic, assign) UIEdgeInsets separatorInset UI_APPEARANCE_SELECTOR;

/// 批量设置 item 的样式
@property(nonatomic, copy, nullable) void (^itemConfigurationHandler)(QMUIPopupMenuView *aMenuView, __kindof QMUIPopupMenuBaseItem *aItem, NSInteger section, NSInteger index);

/// 设置 item，均处于同一个 section 内
@property(nonatomic, copy, nullable) NSArray<__kindof QMUIPopupMenuBaseItem *> *items;

/// 设置多个 section 的多个 item
@property(nonatomic, copy, nullable) NSArray<NSArray<__kindof QMUIPopupMenuBaseItem *> *> *itemSections;

@end
