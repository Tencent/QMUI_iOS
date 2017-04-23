//
//  QMUIAlbumViewController.h
//  qmui
//
//  Created by Kayo Lee on 15/5/3.
//  Copyright (c) 2015年 QMUI Team. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "QMUICommonTableViewController.h"
#import "QMUITableViewCell.h"
#import "QMUIAssetsGroup.h"
#import "QMUIButton.h"

// 相册预览图的大小默认值
extern const CGFloat QMUIAlbumViewControllerDefaultAlbumTableViewCellHeight;
// 相册名称的字号默认值
extern const CGFloat QMUIAlbumTableViewCellDefaultAlbumNameFontSize;
// 相册资源数量的字号默认值
extern const CGFloat QMUIAlbumTableViewCellDefaultAlbumAssetsNumberFontSize;
// 相册名称的 insets 默认值
extern const UIEdgeInsets QMUIAlbumTableViewCellDefaultAlbumNameInsets;


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

@end


@interface QMUIAlbumTableViewCell : QMUITableViewCell

@property(nonatomic, assign) CGFloat albumNameFontSize UI_APPEARANCE_SELECTOR; // 相册名称的字号
@property(nonatomic, assign) CGFloat albumAssetsNumberFontSize UI_APPEARANCE_SELECTOR; // 相册资源数量的字号
@property(nonatomic, assign) UIEdgeInsets albumNameInsets UI_APPEARANCE_SELECTOR; // 相册名称的 insets

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

@property(nonatomic, assign) CGFloat albumTableViewCellHeight UI_APPEARANCE_SELECTOR; // 相册列表 cell 的高度，同时也是相册预览图的宽高

@property(nonatomic, weak) id<QMUIAlbumViewControllerDelegate> albumViewControllerDelegate;

@property(nonatomic, assign) QMUIAlbumContentType contentType; // 相册展示内容的类型，可以控制只展示照片、视频或音频（仅 iOS 8.0 及以上版本支持）的其中一种，也可以同时展示所有类型的资源，默认展示所有类型的资源。

@property(nonatomic, copy) NSString *tipTextWhenNoPhotosAuthorization;
@property(nonatomic, copy) NSString *tipTextWhenPhotosEmpty;

@end


@interface QMUIAlbumViewController (UIAppearance)

+ (instancetype)appearance;

@end
