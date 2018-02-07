//
//  QMUIAlbumViewController.m
//  qmui
//
//  Created by Kayo Lee on 15/5/3.
//  Copyright (c) 2015年 QMUI Team. All rights reserved.
//

#import "QMUIAlbumViewController.h"
#import "QMUICore.h"
#import "QMUIButton.h"
#import "UIView+QMUI.h"
#import "QMUIAssetsManager.h"
#import "QMUIImagePickerViewController.h"
#import <Photos/PHPhotoLibrary.h>
#import <Photos/PHAsset.h>
#import <Photos/PHFetchOptions.h>
#import <Photos/PHCollection.h>
#import <Photos/PHFetchResult.h>

// 相册预览图的大小默认值
const CGFloat QMUIAlbumViewControllerDefaultAlbumTableViewCellHeight = 67;
// 相册预览大小（正方形），如果想要跟图片一样高，则设置成跟 QMUIAlbumViewControllerDefaultAlbumTableViewCellHeight 一样的值就好了
const CGFloat QMUIAlbumViewControllerDefaultAlbumImageSize = 57;
// 相册缩略图的 left，默认 -1，表示和上下一样大
const CGFloat QMUIAlbumViewControllerDefaultAlbumImageLeft = -1;
// 相册名称的字号默认值
const CGFloat QMUIAlbumTableViewCellDefaultAlbumNameFontSize = 16;
// 相册资源数量的字号默认值
const CGFloat QMUIAlbumTableViewCellDefaultAlbumAssetsNumberFontSize = 16;
// 相册名称的 insets 默认值
const UIEdgeInsets QMUIAlbumTableViewCellDefaultAlbumNameInsets = {0, 8, 0, 4};


#pragma mark - QMUIAlbumTableViewCell

@implementation QMUIAlbumTableViewCell

+ (void)initialize {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        [QMUIAlbumTableViewCell appearance].albumImageSize = QMUIAlbumViewControllerDefaultAlbumImageSize;
        [QMUIAlbumTableViewCell appearance].albumImageMarginLeft = QMUIAlbumViewControllerDefaultAlbumImageLeft;
        [QMUIAlbumTableViewCell appearance].albumNameFontSize = QMUIAlbumTableViewCellDefaultAlbumNameFontSize;
        [QMUIAlbumTableViewCell appearance].albumNameInsets = QMUIAlbumTableViewCellDefaultAlbumNameInsets;
        [QMUIAlbumTableViewCell appearance].albumAssetsNumberFontSize = QMUIAlbumTableViewCellDefaultAlbumAssetsNumberFontSize;
    });
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        
        self.albumImageSize = [QMUIAlbumTableViewCell appearance].albumImageSize;
        self.albumImageMarginLeft = [QMUIAlbumTableViewCell appearance].albumImageMarginLeft;
        self.albumNameFontSize = [QMUIAlbumTableViewCell appearance].albumNameFontSize;
        self.albumNameInsets = [QMUIAlbumTableViewCell appearance].albumNameInsets;
        self.albumAssetsNumberFontSize = [QMUIAlbumTableViewCell appearance].albumAssetsNumberFontSize;
        
        self.imageView.contentMode = UIViewContentModeScaleAspectFill;
        self.imageView.clipsToBounds = YES;
        self.detailTextLabel.textColor = UIColorGrayDarken;
    }
    return self;
}

- (void)updateCellAppearanceWithIndexPath:(NSIndexPath *)indexPath {
    [super updateCellAppearanceWithIndexPath:indexPath];
    self.textLabel.font = UIFontBoldMake(self.albumNameFontSize);
    self.detailTextLabel.font = UIFontMake(self.albumAssetsNumberFontSize);
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    CGFloat imageEdgeTop = CGFloatGetCenter(CGRectGetHeight(self.contentView.bounds), self.albumImageSize);
    CGFloat imageEdgeLeft = self.albumImageMarginLeft == QMUIAlbumViewControllerDefaultAlbumImageLeft ? imageEdgeTop : self.albumImageMarginLeft;
    self.imageView.frame = CGRectMake(imageEdgeLeft, imageEdgeTop, self.albumImageSize, self.albumImageSize);
    
    self.textLabel.frame = CGRectSetXY(self.textLabel.frame, CGRectGetMaxX(self.imageView.frame) + self.albumNameInsets.left, [self.textLabel qmui_topWhenCenterInSuperview]);
    
    CGFloat textLabelMaxWidth = CGRectGetWidth(self.contentView.bounds) - CGRectGetMinX(self.textLabel.frame) - CGRectGetWidth(self.detailTextLabel.bounds) - self.albumNameInsets.right;
    if (CGRectGetWidth(self.textLabel.bounds) > textLabelMaxWidth) {
        self.textLabel.frame = CGRectSetWidth(self.textLabel.frame, textLabelMaxWidth);
    }
    
    self.detailTextLabel.frame = CGRectSetXY(self.detailTextLabel.frame, CGRectGetMaxX(self.textLabel.frame) + self.albumNameInsets.right, [self.detailTextLabel qmui_topWhenCenterInSuperview]);
}

@end


#pragma mark - QMUIAlbumViewController (UIAppearance)

@implementation QMUIAlbumViewController (UIAppearance)

+ (void)initialize {
    static dispatch_once_t onceToken1;
    dispatch_once(&onceToken1, ^{
        [self appearance]; // +initialize 时就先设置好默认样式
    });
}

static QMUIAlbumViewController *albumViewControllerAppearance;
+ (instancetype)appearance {
    static dispatch_once_t onceToken2;
    dispatch_once(&onceToken2, ^{
        if (!albumViewControllerAppearance) {
            albumViewControllerAppearance = [[QMUIAlbumViewController alloc] init];
            albumViewControllerAppearance.albumTableViewCellHeight = QMUIAlbumViewControllerDefaultAlbumTableViewCellHeight;
        }
    });
    return albumViewControllerAppearance;
}

@end


#pragma mark - QMUIAlbumViewController

@implementation QMUIAlbumViewController {
    QMUIImagePickerViewController *_imagePickerViewController;
    NSMutableArray<QMUIAssetsGroup *> *_albumsArray;
}

- (void)didInitialized {
    [super didInitialized];
    _shouldShowDefaultLoadingView = YES;
    if (albumViewControllerAppearance) {
        // 避免 albumViewControllerAppearance init 时走到这里来，导致死循环
        self.albumTableViewCellHeight = [QMUIAlbumViewController appearance].albumTableViewCellHeight;
    }
}

- (void)setNavigationItemsIsInEditMode:(BOOL)isInEditMode animated:(BOOL)animated {
    [super setNavigationItemsIsInEditMode:isInEditMode animated:animated];
    if (!self.title) {
        self.title = @"照片";
    }
    self.navigationItem.rightBarButtonItem = [QMUINavigationButton barButtonItemWithType:QMUINavigationButtonTypeNormal title:@"取消" position:QMUINavigationButtonPositionRight target:self action:@selector(handleCancelSelectAlbum:)];
}

- (void)initTableView {
    [super initTableView];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    if ([QMUIAssetsManager authorizationStatus] == QMUIAssetAuthorizationStatusNotAuthorized) {
        // 如果没有获取访问授权，或者访问授权状态已经被明确禁止，则显示提示语，引导用户开启授权
        NSString *tipString = self.tipTextWhenNoPhotosAuthorization;
        if (!tipString) {
            NSDictionary *mainInfoDictionary = [[NSBundle mainBundle] infoDictionary];
            NSString *appName = [mainInfoDictionary objectForKey:@"CFBundleDisplayName"];
            if (!appName) {
                appName = [mainInfoDictionary objectForKey:(NSString *)kCFBundleNameKey];
            }
            tipString = [NSString stringWithFormat:@"请在设备的\"设置-隐私-照片\"选项中，允许%@访问你的手机相册", appName];
        }
        [self showEmptyViewWithText:tipString detailText:nil buttonTitle:nil buttonAction:nil];
    } else {
        _albumsArray = [[NSMutableArray alloc] init];
        // 获取相册列表较为耗时，交给子线程去处理，因此这里需要显示 Loading
        if ([self.albumViewControllerDelegate respondsToSelector:@selector(albumViewControllerWillStartLoading:)]) {
            [self.albumViewControllerDelegate albumViewControllerWillStartLoading:self];
        }
        if (self.shouldShowDefaultLoadingView) {
            [self showEmptyViewWithLoading];
        }
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
            [[QMUIAssetsManager sharedInstance] enumerateAllAlbumsWithAlbumContentType:self.contentType usingBlock:^(QMUIAssetsGroup *resultAssetsGroup) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    // 这里需要对 UI 进行操作，因此放回主线程处理
                    if (resultAssetsGroup) {
                        [_albumsArray addObject:resultAssetsGroup];
                    } else {
                        [self refreshAlbumAndShowEmptyTipIfNeed];
                    }
                });
            }];
        });
    }
}

- (void)refreshAlbumAndShowEmptyTipIfNeed {
    if ([_albumsArray count] > 0) {
        if ([self.albumViewControllerDelegate respondsToSelector:@selector(albumViewControllerWillFinishLoading:)]) {
            [self.albumViewControllerDelegate albumViewControllerWillFinishLoading:self];
        }
        if (self.shouldShowDefaultLoadingView) {
            [self hideEmptyView];
        }
        [self.tableView reloadData];
    } else {
        NSString *tipString = self.tipTextWhenPhotosEmpty ? : @"空照片";
        [self showEmptyViewWithText:tipString detailText:nil buttonTitle:nil buttonAction:nil];
    }
}

#pragma mark - <UITableViewDelegate,UITableViewDataSource>

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [_albumsArray count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return self.albumTableViewCellHeight;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *kCellIdentifer = @"cell";
    QMUIAlbumTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellIdentifer];
    if (!cell) {
        cell = [[QMUIAlbumTableViewCell alloc] initForTableView:self.tableView withStyle:UITableViewCellStyleSubtitle reuseIdentifier:kCellIdentifer];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    QMUIAssetsGroup *assetsGroup = [_albumsArray objectAtIndex:indexPath.row];
    // 显示相册缩略图
    cell.imageView.image = [assetsGroup posterImageWithSize:CGSizeMake(self.albumTableViewCellHeight, self.albumTableViewCellHeight)];
    // 显示相册名称
    cell.textLabel.text = [assetsGroup name];
    // 显示相册中所包含的资源数量
    cell.detailTextLabel.text = [NSString stringWithFormat:@"(%@)", @(assetsGroup.numberOfAssets)];
    [cell updateCellAppearanceWithIndexPath:indexPath];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (!_imagePickerViewController) {
        _imagePickerViewController = [self.albumViewControllerDelegate imagePickerViewControllerForAlbumViewController:self];
    }
    NSAssert(_imagePickerViewController, @"self.%@ 必须实现 %@ 并返回一个 %@ 对象", NSStringFromSelector(@selector(albumViewControllerDelegate)), NSStringFromSelector(@selector(imagePickerViewControllerForAlbumViewController:)), NSStringFromClass([QMUIImagePickerViewController class]));
    QMUIAssetsGroup *assetsGroup = [_albumsArray objectAtIndex:indexPath.row];
    [_imagePickerViewController refreshWithAssetsGroup:assetsGroup];
    _imagePickerViewController.title = [assetsGroup name];
    [self.navigationController pushViewController:_imagePickerViewController animated:YES];
}

- (void)handleCancelSelectAlbum:(id)sender {
    [self.navigationController dismissViewControllerAnimated:YES completion:^(void) {
        if (self.albumViewControllerDelegate && [self.albumViewControllerDelegate respondsToSelector:@selector(albumViewControllerDidCancel:)]) {
            [self.albumViewControllerDelegate albumViewControllerDidCancel:self]; 
        }
    }];
}

@end
