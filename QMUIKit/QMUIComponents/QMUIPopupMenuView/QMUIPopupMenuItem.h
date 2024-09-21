//
//  QMUIPopupMenuItem.h
//  QMUIKit
//
//  Created by molice on 2024/6/17.
//  Copyright © 2024 QMUI Team. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@class QMUIPopupMenuView;
@class QMUIPopupMenuItemView;
@protocol QMUIPopupMenuItemViewProtocol;

NS_ASSUME_NONNULL_BEGIN

@interface QMUIPopupMenuItem : NSObject

/// item 里的文字
@property(nonatomic, copy, nullable) NSString *title;

/// item 里的第二行文字
@property(nonatomic, copy, nullable) NSString *subtitle;

/// item 里的图片，默认会以 template 形式渲染，也即由 tintColor 决定颜色，可显式声明为 AlwaysOriginal 来以图片原本的颜色显示。
@property(nonatomic, strong, nullable) UIImage *image;

/// item 的高度，默认为 -1，-1 表示高度以 QMUIPopupMenuView.itemHeight 为准。如果设置为 QMUIViewSelfSizingHeight，则表示高度由 -[self sizeThatFits:] 返回的值决定。
@property(nonatomic, assign) CGFloat height;

/// 每次将 item 关联到 itemView 上时都会调用这个 block，可以理解为在 @c QMUIPopupMenuView.itemViewConfigurationHandler 之后立马会调用 @c QMUIPopupMenuItem.configurationBlock 。
/// 业务可利用这个 block 做一些自定义的配置 itemView 的行为。
@property(nonatomic, copy) void (^configurationBlock)(__kindof QMUIPopupMenuItem *aItem, __kindof UIControl<QMUIPopupMenuItemViewProtocol> *aItemView, NSInteger section, NSInteger index);

/// item 被点击时的事件处理接口
/// @note 需要在内部自行隐藏 QMUIPopupMenuView。
@property(nonatomic, copy, nullable) void (^handler)(__kindof QMUIPopupMenuItem *aItem, __kindof UIControl<QMUIPopupMenuItemViewProtocol> *aItemView, NSInteger section, NSInteger index);

/// 当前 item 所在的 QMUIPopupMenuView 的引用，只有在 item 被添加到菜单之后才有值。
@property(nonatomic, weak, nullable) __kindof QMUIPopupMenuView *menuView;

+ (instancetype)itemWithTitle:(nullable NSString *)title
                      handler:(void (^ __nullable)(__kindof QMUIPopupMenuItem *aItem, __kindof UIControl<QMUIPopupMenuItemViewProtocol> *aItemView, NSInteger section, NSInteger index))handler;
+ (instancetype)itemWithImage:(nullable UIImage *)image
                        title:(nullable NSString *)title
                      handler:(void (^ __nullable)(__kindof QMUIPopupMenuItem *aItem, __kindof UIControl<QMUIPopupMenuItemViewProtocol> *aItemView, NSInteger section, NSInteger index))handler;
+ (instancetype)itemWithImage:(nullable UIImage *)image
                        title:(nullable NSString *)title
                     subtitle:(nullable NSString *)subtitle
                      handler:(void (^ __nullable)(__kindof QMUIPopupMenuItem *aItem, __kindof UIControl<QMUIPopupMenuItemViewProtocol> *aItemView, NSInteger section, NSInteger index))handler;

@end

NS_ASSUME_NONNULL_END
