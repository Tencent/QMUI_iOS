/*****
 * Tencent is pleased to support the open source community by making QMUI_iOS available.
 * Copyright (C) 2016-2019 THL A29 Limited, a Tencent company. All rights reserved.
 * Licensed under the MIT License (the "License"); you may not use this file except in compliance with the License. You may obtain a copy of the License at
 * http://opensource.org/licenses/MIT
 * Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.
 *****/

//
//  QMUIEmptyView.h
//  qmui
//
//  Created by QMUI Team on 2016/10/9.
//

#import <UIKit/UIKit.h>

@class QMUIButton;

@protocol QMUIEmptyViewLoadingViewProtocol <NSObject>

@optional

- (void)startAnimating; // 当调用 setLoadingViewHidden:NO 时，系统将自动调用此处的 startAnimating

@end

/**
 *  通用的空界面控件，支持显示 loading、标题和副标题提示语、占位图片，QMUICommonViewController 内已集成一个 emptyView，无需额外添加。
 */
@interface QMUIEmptyView : UIView

// 布局顺序从上到下依次为：imageView, loadingView, textLabel, detailTextLabel, actionButton
@property(nonatomic, strong) UIView<QMUIEmptyViewLoadingViewProtocol> *loadingView;   // 此控件通过设置 loadingView.hidden 来控制 loadinView 的显示和隐藏，因此请确保你的loadingView 没有类似于 hidesWhenStopped = YES 之类会使 view.hidden 失效的属性
@property(nonatomic, strong, readonly) UIImageView *imageView;
@property(nonatomic, strong, readonly) UILabel *textLabel;
@property(nonatomic, strong, readonly) UILabel *detailTextLabel;
@property(nonatomic, strong, readonly) QMUIButton *actionButton;

// 可通过调整这些insets来控制间距
@property(nonatomic, assign) UIEdgeInsets imageViewInsets UI_APPEARANCE_SELECTOR;   // 默认为(0, 0, 36, 0)
@property(nonatomic, assign) UIEdgeInsets loadingViewInsets UI_APPEARANCE_SELECTOR;     // 默认为(0, 0, 36, 0)
@property(nonatomic, assign) UIEdgeInsets textLabelInsets UI_APPEARANCE_SELECTOR;   // 默认为(0, 0, 10, 0)
@property(nonatomic, assign) UIEdgeInsets detailTextLabelInsets UI_APPEARANCE_SELECTOR; // 默认为(0, 0, 10, 0)
@property(nonatomic, assign) UIEdgeInsets actionButtonInsets UI_APPEARANCE_SELECTOR;    // 默认为(0, 0, 0, 0)
@property(nonatomic, assign) CGFloat verticalOffset UI_APPEARANCE_SELECTOR; // 如果不想要内容整体垂直居中，则可通过调整此属性来进行垂直偏移。默认为-30，即内容比中间略微偏上

// 字体
@property(nonatomic, strong) UIFont *textLabelFont UI_APPEARANCE_SELECTOR;  // 默认为15pt系统字体
@property(nonatomic, strong) UIFont *detailTextLabelFont UI_APPEARANCE_SELECTOR;    // 默认为14pt系统字体
@property(nonatomic, strong) UIFont *actionButtonFont UI_APPEARANCE_SELECTOR;   // 默认为15pt系统字体

// 颜色
@property(nonatomic, strong) UIColor *textLabelTextColor UI_APPEARANCE_SELECTOR;    // 默认为(93, 100, 110)
@property(nonatomic, strong) UIColor *detailTextLabelTextColor UI_APPEARANCE_SELECTOR;  // 默认为(133, 140, 150)
@property(nonatomic, strong) UIColor *actionButtonTitleColor UI_APPEARANCE_SELECTOR;    // 默认为 ButtonTintColor

// 显示或隐藏loading图标
- (void)setLoadingViewHidden:(BOOL)hidden;

/**
 * 设置要显示的图片
 * @param image 要显示的图片，为nil则不显示
 */
- (void)setImage:(UIImage *)image;

/**
 * 设置提示语
 * @param text 提示语文本，若为nil则隐藏textLabel
 */
- (void)setTextLabelText:(NSString *)text;

/**
 * 设置详细提示语的文本
 * @param text 详细提示语文本，若为nil则隐藏detailTextLabel
 */
- (void)setDetailTextLabelText:(NSString *)text;

/**
 * 设置操作按钮的文本
 * @param title 操作按钮的文本，若为nil则隐藏actionButton
 */
- (void)setActionButtonTitle:(NSString *)title;

/**
 *  如果要继承QMUIEmptyView并添加新的子 view，则必须：
 *  1. 像其它自带 view 一样添加到 contentView 上
 *  2. 重写sizeThatContentViewFits
 */
@property(nonatomic, strong, readonly) UIView *contentView;
- (CGSize)sizeThatContentViewFits;  // 返回一个恰好容纳所有子 view 的大小

@end
