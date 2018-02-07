//
//  QMUIAlbumViewController.m
//  qmui
//
//  Created by Kayo Lee on 15/5/3.
//  Copyright (c) 2015年 QMUI Team. All rights reserved.
//

#import "QMUIAlbumViewController.h"
#import "QMUICommonDefines.h"
#import "QMUIConfiguration.h"
#import "QMUIHelper.h"
#import "UIView+QMUI.h"
#import "QMUIAssetsManager.h"
#import "QMUIImagePickerViewController.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import <Photos/PHPhotoLibrary.h>
#import <Photos/PHAsset.h>
#import <Photos/PHFetchOptions.h>
#import <Photos/PHCollection.h>
#import <Photos/PHFetchResult.h>

// 相册预览图的大小默认值
const CGFloat QMUIAlbumViewControllerDefaultAlbumTableViewCellHeight = 57;
// 相册名称的字号默认值
const CGFloat QMUIAlbumTableViewCellDefaultAlbumNameFontSize = 16;
// 相册资源数量的字号默认值
const CGFloat QMUIAlbumTableViewCellDefaultAlbumAssetsNumberFontSize = 16;
// 相册名称的 insets 默认值
const UIEdgeInsets QMUIAlbumTableViewCellDefaultAlbumNameInsets = {0, 8, 0, 4};


#pragma mark - QMUIAlbumTableViewCell

@implementation QMUIAlbumTableViewCell {
    CALayer *_bottomLineLayer;
}

+ (void)initialize {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        [QMUIAlbumTableViewCell appearance].albumNameFontSize = QMUIAlbumTableViewCellDefaultAlbumNameFontSize;
        [QMUIAlbumTableViewCell appearance].albumAssetsNumberFontSize = QMUIAlbumTableViewCellDefaultAlbumAssetsNumberFontSize;
        [QMUIAlbumTableViewCell appearance].albumNameInsets = QMUIAlbumTableViewCellDefaultAlbumNameInsets;
    });
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.albumNameFontSize = [QMUIAlbumTableViewCell appearance].albumNameFontSize;
        self.albumAssetsNumberFontSize = [QMUIAlbumTableViewCell appearance].albumAssetsNumberFontSize;
        self.albumNameInsets = [QMUIAlbumTableViewCell appearance].albumNameInsets;
        
        self.imageView.contentMode = UIViewContentModeScaleAspectFill;
        self.imageView.clipsToBounds = YES;
        self.detailTextLabel.textColor = UIColorGrayDarken;
        
        _bottomLineLayer = [[CALayer alloc] init];
        _bottomLineLayer.backgroundColor = UIColorSeparator.CGColor;
        // 让分隔线垫在背后
        [self.layer insertSublayer:_bottomLineLayer atIndex:0];
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
    // 避免iOS7下seletedBackgroundView会往上下露出1px（以盖住系统分隔线，但我们的分隔线是自定义的）
    self.selectedBackgroundView.frame = self.bounds;
    
    CGFloat contentViewPaddingRight = 10;
    self.imageView.frame = CGRectMake(0, 0, CGRectGetHeight(self.contentView.bounds), CGRectGetHeight(self.contentView.bounds));
    self.textLabel.frame = CGRectSetXY(self.textLabel.frame, CGRectGetMaxX(self.imageView.frame) + self.albumNameInsets.left, flat([self.textLabel qmui_minYWhenCenterInSuperview]));
    CGFloat textLabelMaxWidth = CGRectGetWidth(self.contentView.bounds) - contentViewPaddingRight - CGRectGetWidth(self.detailTextLabel.frame) - self.albumNameInsets.right - CGRectGetMinX(self.textLabel.frame);
    if (CGRectGetWidth(self.textLabel.frame) > textLabelMaxWidth) {
        self.textLabel.frame = CGRectSetWidth(self.textLabel.frame, textLabelMaxWidth);
    }
    
    self.detailTextLabel.frame = CGRectSetXY(self.detailTextLabel.frame, CGRectGetMaxX(self.textLabel.frame) + self.albumNameInsets.right, flat([self.detailTextLabel qmui_minYWhenCenterInSuperview]));
    _bottomLineLayer.frame = CGRectMake(0, CGRectGetHeight(self.contentView.bounds) - PixelOne, CGRectGetWidth(self.bounds), PixelOne);
}

- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated {
    [super setHighlighted:highlighted animated:animated];
    _bottomLineLayer.hidden = highlighted;
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
    NSMutableArray *_albumsArray;
    
    BOOL _usePhotoKit;
}

- (instancetype)initWithStyle:(UITableViewStyle)style {
    if (self = [super initWithStyle:style]) {
        _usePhotoKit = IOS_VERSION >= 8.0;
        if (albumViewControllerAppearance) {
            // 避免 albumViewControllerAppearance init 时走到这里来，导致死循环
            self.albumTableViewCellHeight = [QMUIAlbumViewController appearance].albumTableViewCellHeight;
        }
    }
    return self;
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
        if (!self.tipTextWhenNoPhotosAuthorization) {
            NSDictionary *mainInfoDictionary = [[NSBundle mainBundle] infoDictionary];
            NSString *appName = [mainInfoDictionary objectForKey:@"CFBundleDisplayName"];
            if (!appName) {
                appName = [mainInfoDictionary objectForKey:(NSString *)kCFBundleNameKey];
            }
            self.tipTextWhenNoPhotosAuthorization = [NSString stringWithFormat:@"请在设备的\"设置-隐私-照片\"选项中，允许%@访问你的手机相册", appName];
        }
        [self showEmptyViewWithText:self.tipTextWhenNoPhotosAuthorization detailText:nil buttonTitle:nil buttonAction:nil];
    } else {
        
        _albumsArray = [[NSMutableArray alloc] init];
        
        [[QMUIAssetsManager sharedInstance] enumerateAllAlbumsWithAlbumContentType:self.contentType usingBlock:^(QMUIAssetsGroup *resultAssetsGroup) {
            if (resultAssetsGroup) {
                [_albumsArray addObject:resultAssetsGroup];
            } else {
                [self refreshAlbumAndShowEmptyTipIfNeed];
            }
        }];
    }
}

- (void)refreshAlbumAndShowEmptyTipIfNeed {
    if ([_albumsArray count] > 0) {
        [self.tableView reloadData];
    } else {
        if (!self.tipTextWhenPhotosEmpty) {
            self.tipTextWhenPhotosEmpty = @"空照片";
        }
        [self showEmptyViewWithText:self.tipTextWhenPhotosEmpty detailText:nil buttonTitle:nil buttonAction:nil];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
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
    cell.detailTextLabel.text = [NSString stringWithFormat:@"(%ld)", (long)assetsGroup.numberOfAssets];
    
    [cell updateCellAppearanceWithIndexPath:indexPath];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (!_imagePickerViewController) {
        if (self.albumViewControllerDelegate && [self.albumViewControllerDelegate respondsToSelector:@selector(imagePickerViewControllerForAlbumViewController:)]) {
            _imagePickerViewController = [self.albumViewControllerDelegate imagePickerViewControllerForAlbumViewController:self];
        }
    }
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
