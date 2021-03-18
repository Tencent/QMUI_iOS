/**
 * Tencent is pleased to support the open source community by making QMUI_iOS available.
 * Copyright (C) 2016-2020 THL A29 Limited, a Tencent company. All rights reserved.
 * Licensed under the MIT License (the "License"); you may not use this file except in compliance with the License. You may obtain a copy of the License at
 * http://opensource.org/licenses/MIT
 * Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.
 */

//
//  QMUIEmotionView.h
//  qmui
//
//  Created by QMUI Team on 16/9/6.
//

#import <UIKit/UIKit.h>

@class QMUIButton;

/**
 *  代表一个表情的数据对象
 */
@interface QMUIEmotion : NSObject

/// 当前表情的标识符，可用于区分不同表情
@property(nonatomic, copy) NSString *identifier;

/// 当前表情展示出来的名字，可用于输入框里的占位文字，请务必使用统一的左右标识符将表情名称包裹起来（例如常见的“[]”），否则在 `QMUIEmotionInputManager` 里会因为找不到标识符而无法准确识别出一串文本里的哪些字符是代表一个表情。合法的 displayName 例子：“[委屈]”
@property(nonatomic, copy) NSString *displayName;

/// 表情对应的图片。若表情图片存放于项目内，则建议用当前表情的`identifier`作为图片名
@property(nonatomic, strong) UIImage *image;

/**
 *  快速生成一个`QMUIEmotion`对象，并且以`identifier`为图片名在当前项目里查找，作为表情的图片
 *  @param  identifier  表情的标识符，也会被当成图片的名字
 *  @param  displayName 表情展示出来的名字
 */
+ (instancetype)emotionWithIdentifier:(NSString *)identifier displayName:(NSString *)displayName;

@end




/**
 *  表情控件，支持任意表情的展示，每个表情以相同的大小显示。
 *
 *  使用方式：
 *  
 *  - 通过`initWithFrame:`初始化，如果面板高度不变，建议在init时就设置好，若最终布局以父类的`layoutSubviews`为准，则也可通过`init`方法初始化，再在`layoutSubviews`里计算布局
 *  - 通过调整`paddingInPage`、`emotionSize`等变量来自定义UI
 *  - 通过`emotions`设置要展示的表情
 *  - 通过`didSelectEmotionBlock`设置选中表情时的回调，通过`didSelectDeleteButtonBlock`来响应面板内的删除按钮
 *  - 为`sendButton`添加`addTarget:action:forState:`事件，从而触发发送逻辑
 *
 *  本控件支持通过`UIAppearance`设置全局的默认样式。若要修改控件内的`UIPageControl`的样式，可通过`[UIPageControl appearanceWhenContainedInInstancesOfClasses:@[[QMUIEmotionView class]]]`的方式来修改。
 */
@interface QMUIEmotionView : UIView<UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>

/// 要展示的所有表情
@property(nonatomic, copy) NSArray<QMUIEmotion *> *emotions;

/**
 *  选中表情时的回调
 *  @argv  index   被选中的表情在`emotions`里的索引
 *  @argv  emotion 被选中的表情对应的`QMUIEmotion`对象
 *  @see QMUIEmotion
 */
@property(nonatomic, copy) void (^didSelectEmotionBlock)(NSInteger index, QMUIEmotion *emotion);

/// 删除按钮的点击事件回调
@property(nonatomic, copy) void (^didSelectDeleteButtonBlock)(void);

/// 用于展示表情面板的横向滚动collectionView，布局撑满整个控件
@property(nonatomic, strong, readonly) UICollectionView *collectionView;

/// 用于横向按页滚动的collectionViewLayout
@property(nonatomic, strong, readonly) UICollectionViewFlowLayout *collectionViewLayout;

/// 控件底部的分页控件，可点击切换表情页面
@property(nonatomic, strong, readonly) UIPageControl *pageControl;

/// 控件右下角的发送按钮
@property(nonatomic, strong, readonly) QMUIButton *sendButton;

/// 每一页表情的上下左右padding，默认为{18, 18, 65, 18}
@property(nonatomic, assign) UIEdgeInsets paddingInPage UI_APPEARANCE_SELECTOR;

/// 每一页表情允许的最大行数，默认为4
@property(nonatomic, assign) NSInteger numberOfRowsPerPage UI_APPEARANCE_SELECTOR;

/// 表情的图片大小，不管`QMUIEmotion.image.size`多大，都会被缩放到`emotionSize`里显示，默认为{30, 30}
@property(nonatomic, assign) CGSize emotionSize UI_APPEARANCE_SELECTOR;

/// 表情点击时的背景遮罩相对于`emotionSize`往外拓展的区域，负值表示遮罩比表情还大，正值表示遮罩比表情还小，默认为{-3, -3, -3, -3}
@property(nonatomic, assign) UIEdgeInsets emotionSelectedBackgroundExtension UI_APPEARANCE_SELECTOR;

/// 表情与表情之间的最小水平间距，默认为10
@property(nonatomic, assign) CGFloat minimumEmotionHorizontalSpacing UI_APPEARANCE_SELECTOR;

/// 表情面板右下角的删除按钮的图片，默认为`[QMUIHelper imageWithName:@"QMUI_emotion_delete"]`
@property(nonatomic, strong) UIImage *deleteButtonImage UI_APPEARANCE_SELECTOR;

/// 发送按钮的文字样式，默认为{NSFontAttributeName: UIFontMake(15), NSForegroundColorAttributeName: UIColorWhite}
@property(nonatomic, strong) NSDictionary *sendButtonTitleAttributes UI_APPEARANCE_SELECTOR;

/// 发送按钮的背景色，默认为`UIColorBlue`
@property(nonatomic, strong) UIColor *sendButtonBackgroundColor UI_APPEARANCE_SELECTOR;

/// 发送按钮的圆角大小，默认为4
@property(nonatomic, assign) CGFloat sendButtonCornerRadius UI_APPEARANCE_SELECTOR;

/// 发送按钮布局时的外边距，相对于控件右下角。仅right/bottom有效，默认为{0, 0, 16, 16}
@property(nonatomic, assign) UIEdgeInsets sendButtonMargins UI_APPEARANCE_SELECTOR;

/// 分页控件距离底部的间距，默认为22
@property(nonatomic, assign) CGFloat pageControlMarginBottom UI_APPEARANCE_SELECTOR;

@end
