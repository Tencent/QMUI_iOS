/**
 * Tencent is pleased to support the open source community by making QMUI_iOS available.
 * Copyright (C) 2016-2021 THL A29 Limited, a Tencent company. All rights reserved.
 * Licensed under the MIT License (the "License"); you may not use this file except in compliance with the License. You may obtain a copy of the License at
 * http://opensource.org/licenses/MIT
 * Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.
 */

//
//  QMUIMoreOperationController.h
//  qmui
//
//  Created by QMUI Team on 17/11/15.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "QMUIModalPresentationViewController.h"
#import "QMUIButton.h"

NS_ASSUME_NONNULL_BEGIN

@class QMUIMoreOperationController;
@class QMUIMoreOperationItemView;

@protocol QMUIMoreOperationControllerDelegate <NSObject>

@optional

/// 即将显示操作面板
- (void)willPresentMoreOperationController:(QMUIMoreOperationController *)moreOperationController;

/// 已经显示操作面板
- (void)didPresentMoreOperationController:(QMUIMoreOperationController *)moreOperationController;

/// 即将降下操作面板，cancelled参数是用来区分是否触发了maskView或者cancelButton按钮降下面板还是手动调用hide方法来降下面板。
- (void)willDismissMoreOperationController:(QMUIMoreOperationController *)moreOperationController cancelled:(BOOL)cancelled;

/// 已经降下操作面板，cancelled参数是用来区分是否触发了maskView或者cancelButton按钮降下面板还是手动调用hide方法来降下面板。
- (void)didDismissMoreOperationController:(QMUIMoreOperationController *)moreOperationController cancelled:(BOOL)cancelled;

/// itemView 点击事件，可以与 itemView.handler 共存，可通过 itemView.tag 或者 itemView.indexPath 来区分不同的 itemView
- (void)moreOperationController:(QMUIMoreOperationController *)moreOperationController didSelectItemView:(QMUIMoreOperationItemView *)itemView;
@end


/**
 *  更多操作面板控件，类似系统的相册分享面板，以及微信的 webview 分享面板。功能特性包括：
 *  1. 支持多行，每行支持多个 item，由二维数组 items 控制。
 *  2. 默认自带取消按钮，也可自行隐藏。
 *  3. 支持以 UIAppearance 的方式配置样式皮肤。
 */
@interface QMUIMoreOperationController : UIViewController <QMUIModalPresentationContentViewControllerProtocol, QMUIModalPresentationViewControllerDelegate, QMUIModalPresentationComponentProtocol>

@property(nullable, nonatomic, strong) UIColor *contentBackgroundColor UI_APPEARANCE_SELECTOR;// 面板上半部分（不包含取消按钮）背景色
@property(nonatomic, assign) UIEdgeInsets contentEdgeMargins UI_APPEARANCE_SELECTOR;// 面板距离屏幕的上下左右间距
@property(nonatomic, assign) CGFloat contentMaximumWidth UI_APPEARANCE_SELECTOR;// 面板的最大宽度
@property(nonatomic, assign) CGFloat contentCornerRadius UI_APPEARANCE_SELECTOR;// 面板的圆角大小，当值大于 0 时会设置 self.view.clipsToBounds = YES
@property(nonatomic, assign) UIEdgeInsets contentPaddings UI_APPEARANCE_SELECTOR;// 面板内部的 padding，UIScrollView 会布局在除去 padding 之后的区域

@property(nullable, nonatomic, strong) UIColor *scrollViewSeparatorColor UI_APPEARANCE_SELECTOR;// 每一行之间的顶部分隔线，对第一行无效
@property(nonatomic, assign) UIEdgeInsets scrollViewContentInsets UI_APPEARANCE_SELECTOR;// 每一行内部的 padding

@property(nullable, nonatomic, strong) UIColor *itemBackgroundColor UI_APPEARANCE_SELECTOR;// 按钮的背景色
@property(nullable, nonatomic, strong) UIColor *itemTitleColor UI_APPEARANCE_SELECTOR;// 按钮的标题颜色
@property(nullable, nonatomic, strong) UIFont  *itemTitleFont UI_APPEARANCE_SELECTOR;// 按钮的标题字体
@property(nonatomic, assign) CGFloat itemPaddingHorizontal UI_APPEARANCE_SELECTOR;// 按钮内 imageView 的左右间距（按钮宽度 = 图片宽度 + 左右间距 * 2），通常用来调整文字的宽度
@property(nonatomic, assign) CGFloat itemTitleMarginTop UI_APPEARANCE_SELECTOR;// 按钮标题距离文字之间的间距
@property(nonatomic, assign) CGFloat itemMinimumMarginHorizontal UI_APPEARANCE_SELECTOR;// 按钮与按钮之间的最小间距
@property(nonatomic, assign) BOOL automaticallyAdjustItemMargins UI_APPEARANCE_SELECTOR;// 是否要自动计算默认一行展示多少个 item，YES 表示尽量让每一行末尾露出半个 item 暗示后面还有内容，NO 表示直接根据 itemMinimumMarginHorizontal 来计算布局。默认为 YES。

@property(nullable, nonatomic, strong) UIColor *cancelButtonBackgroundColor UI_APPEARANCE_SELECTOR;// 取消按钮的背景色
@property(nullable, nonatomic, strong) UIColor *cancelButtonTitleColor UI_APPEARANCE_SELECTOR;// 取消按钮的标题颜色
@property(nullable, nonatomic, strong) UIColor *cancelButtonSeparatorColor UI_APPEARANCE_SELECTOR;// 取消按钮的顶部分隔线颜色
@property(nullable, nonatomic, strong) UIFont  *cancelButtonFont UI_APPEARANCE_SELECTOR;// 取消按钮的字体
@property(nonatomic, assign) CGFloat cancelButtonHeight UI_APPEARANCE_SELECTOR;// 取消按钮的高度
@property(nonatomic, assign) CGFloat cancelButtonMarginTop UI_APPEARANCE_SELECTOR;// 取消按钮距离内容面板的间距

@property(nullable, nonatomic, weak) id<QMUIMoreOperationControllerDelegate> delegate;

@property(nullable, nonatomic, strong, readonly) UIView *contentView;// 放 UIScrollView 的容器，与 cancelButton 区分开
@property(nullable, nonatomic, copy, readonly) NSArray<UIScrollView *> *scrollViews;// 获取当前的所有 UIScrollView

/// 取消按钮，如果不需要，则自行设置其 hidden 为 YES
@property(nullable, nonatomic, strong, readonly) QMUIButton *cancelButton;

/// 在 iPhoneX 机器上是否延伸底部背景色。因为在 iPhoneX 上我们会把整个面板往上移动 safeArea 的距离，如果你的面板本来就配置成撑满全屏的样式，那么就会露出底部的空隙，isExtendBottomLayout 可以帮助你把空暇填补上。默认为NO。
@property(nonatomic, assign) BOOL isExtendBottomLayout UI_APPEARANCE_SELECTOR;

@property(nullable, nonatomic, copy) NSArray<NSArray<QMUIMoreOperationItemView *> *> *items;

/// 添加一个 itemView 到指定 section 的末尾
- (void)addItemView:(QMUIMoreOperationItemView *)itemView inSection:(NSInteger)section;

/// 插入一个 itemView 到指定的位置，NSIndexPath 请使用 section-item 组合，其中 section 表示行，item 表示 section 里的元素序号
- (void)insertItemView:(QMUIMoreOperationItemView *)itemView atIndexPath:(NSIndexPath *)indexPath;

/// 移除指定位置的 itemView，NSIndexPath 请使用 section-item 组合，其中 section 表示行，item 表示 section 里的元素序号
- (void)removeItemViewAtIndexPath:(NSIndexPath *)indexPath;

/// 获取指定 tag 的 itemView，如果不存在则返回 nil
- (QMUIMoreOperationItemView * _Nullable)itemViewWithTag:(NSInteger)tag;

/// 获取指定 itemView 在当前控件里的 indexPath，如果不存在则返回 nil
- (NSIndexPath * _Nullable)indexPathWithItemView:(QMUIMoreOperationItemView *)itemView;

/// 弹出面板，一般在 init 完并且设置好 items 之后就调用这个接口来显示面板
- (void)showFromBottom;

/// 隐藏面板
- (void)hideToBottom;

/// 更多操作面板是否正在显示
@property(nonatomic, assign, getter=isShowing, readonly) BOOL showing;
@property(nonatomic, assign, getter=isAnimating, readonly) BOOL animating;

@end


@interface QMUIMoreOperationController (UIAppearance)

+ (instancetype)appearance;

@end


@interface QMUIMoreOperationItemView : QMUIButton

@property(nullable, nonatomic, strong, readonly) NSIndexPath *indexPath;
@property(nonatomic, assign) NSInteger tag;

+ (instancetype)itemViewWithImage:(UIImage * _Nullable)image
                            title:(NSString * _Nullable)title
                          handler:(void (^ _Nullable)(QMUIMoreOperationController *moreOperationController, QMUIMoreOperationItemView *itemView))handler;

+ (instancetype)itemViewWithImage:(UIImage * _Nullable)image
                    selectedImage:(UIImage * _Nullable)selectedImage
                            title:(NSString * _Nullable)title
                    selectedTitle:(NSString * _Nullable)selectedTitle
                          handler:(void (^ _Nullable)(QMUIMoreOperationController *moreOperationController, QMUIMoreOperationItemView *itemView))handler;

+ (instancetype)itemViewWithImage:(UIImage * _Nullable)image
                            title:(NSString * _Nullable)title
                              tag:(NSInteger)tag
                          handler:(void (^ _Nullable)(QMUIMoreOperationController *moreOperationController, QMUIMoreOperationItemView *itemView))handler;

+ (instancetype)itemViewWithImage:(UIImage * _Nullable)image
                    selectedImage:(UIImage * _Nullable)selectedImage
                            title:(NSString * _Nullable)title
                    selectedTitle:(NSString * _Nullable)selectedTitle
                              tag:(NSInteger)tag
                          handler:(void (^ _Nullable)(QMUIMoreOperationController *moreOperationController, QMUIMoreOperationItemView *itemView))handler;

@end

NS_ASSUME_NONNULL_END
