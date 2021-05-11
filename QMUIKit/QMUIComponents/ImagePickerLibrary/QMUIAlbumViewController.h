/**
 * Tencent is pleased to support the open source community by making QMUI_iOS available.
 * Copyright (C) 2016-2021 THL A29 Limited, a Tencent company. All rights reserved.
 * Licensed under the MIT License (the "License"); you may not use this file except in compliance with the License. You may obtain a copy of the License at
 * http://opensource.org/licenses/MIT
 * Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.
 */

//
//  QMUIAlbumViewController.h
//  qmui
//
//  Created by QMUI Team on 15/5/3.
//

#import <UIKit/UIKit.h>
#import "QMUICommonTableViewController.h"
#import "QMUITableViewCell.h"
#import "QMUIAssetsGroup.h"

NS_ASSUME_NONNULL_BEGIN

@class QMUIImagePickerViewController;
@class QMUIAlbumViewController;
@class QMUITableViewCell;

@protocol QMUIAlbumViewControllerDelegate <NSObject>

@required
/// 点击相簿里某一行时，需要给一个 QMUIImagePickerViewController 对象用于展示九宫格图片列表
- (QMUIImagePickerViewController *)imagePickerViewControllerForAlbumViewController:(QMUIAlbumViewController *)albumViewController;

@optional
/**
 *  取消查看相册列表后被调用
 */
- (void)albumViewControllerDidCancel:(QMUIAlbumViewController *)albumViewController;

/**
 *  即将需要显示 Loading 时调用
 *
 *  @see shouldShowDefaultLoadingView
 */
- (void)albumViewControllerWillStartLoading:(QMUIAlbumViewController *)albumViewController;

/**
 *  即将需要隐藏 Loading 时调用
 *
 *  @see shouldShowDefaultLoadingView
 */
- (void)albumViewControllerWillFinishLoading:(QMUIAlbumViewController *)albumViewController;

@end


@interface QMUIAlbumTableViewCell : QMUITableViewCell

@property(nonatomic, assign) CGFloat albumImageSize UI_APPEARANCE_SELECTOR; // 相册缩略图的大小
@property(nonatomic, assign) CGFloat albumImageMarginLeft UI_APPEARANCE_SELECTOR; // 相册缩略图的 left，-1 表示自动保持与上下 margin 相等
@property(nonatomic, assign) UIEdgeInsets albumNameInsets UI_APPEARANCE_SELECTOR; // 相册名称的上下左右间距
@property(nullable, nonatomic, strong) UIFont *albumNameFont UI_APPEARANCE_SELECTOR; // 相册名的字体
@property(nullable, nonatomic, strong) UIColor *albumNameColor UI_APPEARANCE_SELECTOR; // 相册名的颜色
@property(nullable, nonatomic, strong) UIFont *albumAssetsNumberFont UI_APPEARANCE_SELECTOR; // 相册资源数量的字体
@property(nullable, nonatomic, strong) UIColor *albumAssetsNumberColor UI_APPEARANCE_SELECTOR; // 相册资源数量的颜色

@end

/**
 *  当前设备照片里的相簿列表，使用方式：
 *  1. 使用 init 初始化。
 *  2. 指定一个 albumViewControllerDelegate，并实现 @required 方法。
 *
 *  @warning 注意，iOS 访问相册需要得到授权，建议先询问用户授权，通过了再进行 QMUIAlbumViewController 的初始化工作。关于授权的代码，可参考 QMUI Demo 项目里的 [QDImagePickerExampleViewController authorizationPresentAlbumViewControllerWithTitle] 方法。
 *  @see [QMUIAssetsManager requestAuthorization:]
 */
@interface QMUIAlbumViewController : QMUICommonTableViewController

@property(nullable, nonatomic, weak) id<QMUIAlbumViewControllerDelegate> albumViewControllerDelegate;

/// 相册列表 cell 的高度，同时也是相册预览图的宽高，默认57
@property(nonatomic, assign) CGFloat albumTableViewCellHeight UI_APPEARANCE_SELECTOR;

/// 相册展示内容的类型，可以控制只展示照片、视频或音频的其中一种，也可以同时展示所有类型的资源，默认展示所有类型的资源。
@property(nonatomic, assign) QMUIAlbumContentType contentType;

@property(nullable, nonatomic, copy) NSString *tipTextWhenNoPhotosAuthorization;
@property(nullable, nonatomic, copy) NSString *tipTextWhenPhotosEmpty;

/**
 *  加载相册列表时会出现 loading，若需要自定义 loading 的形式，可将该属性置为 NO，默认为 YES。
 *  @see albumViewControllerWillStartLoading: & albumViewControllerWillFinishLoading:
 */
@property(nonatomic, assign) BOOL shouldShowDefaultLoadingView;

/// 在 QMUIAlbumViewController 被放到 UINavigationController 里之后，可通过调用这个方法，来尝试直接进入上一次选中的相册列表
- (void)pickLastAlbumGroupDirectlyIfCan;

@end


@interface QMUIAlbumViewController (UIAppearance)

+ (instancetype)appearance;

@end

NS_ASSUME_NONNULL_END
