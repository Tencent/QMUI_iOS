//
//  QMUIPopupMenuView.h
//  qmui
//
//  Created by MoLice on 2017/2/24.
//  Copyright © 2017年 QMUI Team. All rights reserved.
//

#import "QMUIPopupContainerView.h"

@class QMUIPopupMenuItem;
@class QMUIButton;

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

@property(nonatomic, assign) BOOL shouldShowItemSeparator;
@property(nonatomic, assign) BOOL shouldShowSectionSeparatorOnly;
@property(nonatomic, strong) UIColor *separatorColor UI_APPEARANCE_SELECTOR;

@property(nonatomic, strong) UIFont *itemTitleFont UI_APPEARANCE_SELECTOR;
@property(nonatomic, strong) UIColor *itemHighlightedBackgroundColor UI_APPEARANCE_SELECTOR;

@property(nonatomic, assign) UIEdgeInsets padding UI_APPEARANCE_SELECTOR;
@property(nonatomic, assign) CGFloat itemHeight UI_APPEARANCE_SELECTOR;
@property(nonatomic, assign) CGFloat imageMarginRight UI_APPEARANCE_SELECTOR;
@property(nonatomic, assign) UIEdgeInsets separatorInset UI_APPEARANCE_SELECTOR;

@property(nonatomic, copy) NSArray<QMUIPopupMenuItem *> *items;
@property(nonatomic, copy) NSArray<NSArray<QMUIPopupMenuItem *> *> *itemSections;

@end

/**
 *  配合 QMUIPopupMenuView 使用，用于表示一项菜单项。
 *  支持显示图片和标题，以及点击事件的回调。
 *  可在 QMUIPopupMenuView 里统一修改菜单项的样式，如果某个菜单项需要特殊调整，可获取到对应的 QMUIPopupMenuItem.button 并进行调整。
 */
@interface QMUIPopupMenuItem : NSObject

@property(nonatomic, strong) UIImage *image;
@property(nonatomic, copy) NSString *title;
@property(nonatomic, strong, readonly) QMUIButton *button;
@property(nonatomic, copy) void (^handler)();

+ (instancetype)itemWithImage:(UIImage *)image title:(NSString *)title handler:(void (^)())handler;
@end
