/**
 * Tencent is pleased to support the open source community by making QMUI_iOS available.
 * Copyright (C) 2016-2021 THL A29 Limited, a Tencent company. All rights reserved.
 * Licensed under the MIT License (the "License"); you may not use this file except in compliance with the License. You may obtain a copy of the License at
 * http://opensource.org/licenses/MIT
 * Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.
 */

//
//  QMUIImagePickerViewController.m
//  qmui
//
//  Created by QMUI Team on 15/5/2.
//

#import "QMUIImagePickerViewController.h"
#import "QMUICore.h"
#import "QMUIImagePickerCollectionViewCell.h"
#import "QMUIButton.h"
#import "QMUINavigationButton.h"
#import "QMUIAssetsManager.h"
#import "QMUIAlertController.h"
#import "QMUIImagePickerHelper.h"
#import "QMUIImagePickerHelper.h"
#import "UICollectionView+QMUI.h"
#import "UIScrollView+QMUI.h"
#import "CALayer+QMUI.h"
#import "UIView+QMUI.h"
#import <MobileCoreServices/MobileCoreServices.h>
#import "QMUIEmptyView.h"
#import "UIViewController+QMUI.h"
#import "QMUILog.h"
#import "QMUIAppearance.h"

static NSString * const kVideoCellIdentifier = @"video";
static NSString * const kImageOrUnknownCellIdentifier = @"imageorunknown";


#pragma mark - QMUIImagePickerViewController (UIAppearance)

@implementation QMUIImagePickerViewController (UIAppearance)

+ (instancetype)appearance {
    return [QMUIAppearance appearanceForClass:self];
}

+ (void)initialize {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        [self initAppearance];
    });
}

+ (void)initAppearance {
    QMUIImagePickerViewController.appearance.minimumImageWidth = 75;
}

@end

#pragma mark - QMUIImagePickerViewController

@interface QMUIImagePickerViewController ()

@property(nonatomic, strong) QMUIImagePickerPreviewViewController *imagePickerPreviewViewController;
@property(nonatomic, assign) BOOL isImagesAssetLoaded;// 这个属性的作用描述：https://github.com/Tencent/QMUI_iOS/issues/219
@property(nonatomic, assign) BOOL hasScrollToInitialPosition;
@property(nonatomic, assign) BOOL canScrollToInitialPosition;// 要等数据加载完才允许滚动
@end

@implementation QMUIImagePickerViewController

- (void)didInitialize {
    [super didInitialize];
    
    [self qmui_applyAppearance];
    
    _allowsMultipleSelection = YES;
    _maximumSelectImageCount = INT_MAX;
    _minimumSelectImageCount = 0;
    _shouldShowDefaultLoadingView = YES;
}

- (void)dealloc {
    _collectionView.dataSource = nil;
    _collectionView.delegate = nil;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = UIColorWhite;
    [self.view addSubview:self.collectionView];
    if (self.allowsMultipleSelection) {
        [self.view addSubview:self.operationToolBarView];
    }
}

- (void)setupNavigationItems {
    [super setupNavigationItems];
    self.navigationItem.rightBarButtonItem = [UIBarButtonItem qmui_itemWithTitle:@"取消" target:self action:@selector(handleCancelPickerImage:)];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    // 由于被选中的图片 selectedImageAssetArray 是 property，所以可以由外部改变，
    // 因此 viewWillAppear 时检查一下图片被选中的情况，并刷新 collectionView
    if (self.allowsMultipleSelection) {
        // 只有允许多选，即底部工具栏显示时，需要重新设置底部工具栏的元素
        NSInteger selectedImageCount = [self.selectedImageAssetArray count];
        if (selectedImageCount > 0) {
            // 如果有图片被选择，则预览按钮和发送按钮可点击，并刷新当前被选中的图片数量
            self.previewButton.enabled = YES;
            self.sendButton.enabled = YES;
            self.imageCountLabel.text = [NSString stringWithFormat:@"%@", @(selectedImageCount)];
            self.imageCountLabel.hidden = NO;
        } else {
            // 如果没有任何图片被选择，则预览和发送按钮不可点击，并且隐藏显示图片数量的 Label
            self.previewButton.enabled = NO;
            self.sendButton.enabled = NO;
            self.imageCountLabel.hidden = YES;
        }
    }
    [self.collectionView reloadData];
}

- (void)showEmptyView {
    [super showEmptyView];
    self.emptyView.backgroundColor = self.view.backgroundColor; // 为了盖住背后的 collectionView，这里加个背景色（不盖住的话会看到 collectionView 先滚到列表顶部然后跳到列表底部）
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    
    CGFloat operationToolBarViewHeight = 0;
    if (self.allowsMultipleSelection) {
        operationToolBarViewHeight = ToolBarHeight;
        CGFloat toolbarPaddingHorizontal = 12;
        self.operationToolBarView.frame = CGRectMake(0, CGRectGetHeight(self.view.bounds) - operationToolBarViewHeight, CGRectGetWidth(self.view.bounds), operationToolBarViewHeight);
        self.previewButton.frame = CGRectSetXY(self.previewButton.frame, toolbarPaddingHorizontal, CGFloatGetCenter(CGRectGetHeight(self.operationToolBarView.bounds) - SafeAreaInsetsConstantForDeviceWithNotch.bottom, CGRectGetHeight(self.previewButton.frame)));
        self.sendButton.frame = CGRectMake(CGRectGetWidth(self.operationToolBarView.bounds) - toolbarPaddingHorizontal - CGRectGetWidth(self.sendButton.frame), CGFloatGetCenter(CGRectGetHeight(self.operationToolBarView.frame) - SafeAreaInsetsConstantForDeviceWithNotch.bottom, CGRectGetHeight(self.sendButton.frame)), CGRectGetWidth(self.sendButton.frame), CGRectGetHeight(self.sendButton.frame));
        CGSize imageCountLabelSize = CGSizeMake(18, 18);
        self.imageCountLabel.frame = CGRectMake(CGRectGetMinX(self.sendButton.frame) - imageCountLabelSize.width - 5, CGRectGetMinY(self.sendButton.frame) + CGFloatGetCenter(CGRectGetHeight(self.sendButton.frame), imageCountLabelSize.height), imageCountLabelSize.width, imageCountLabelSize.height);
        self.imageCountLabel.layer.cornerRadius = CGRectGetHeight(self.imageCountLabel.bounds) / 2;
        operationToolBarViewHeight = CGRectGetHeight(self.operationToolBarView.frame);
    }
    
    if (!CGSizeEqualToSize(self.collectionView.frame.size, self.view.bounds.size)) {
        self.collectionView.frame = self.view.bounds;
    }
    UIEdgeInsets contentInset = UIEdgeInsetsMake(self.qmui_navigationBarMaxYInViewCoordinator, self.collectionView.safeAreaInsets.left, MAX(operationToolBarViewHeight, self.collectionView.safeAreaInsets.bottom), self.collectionView.safeAreaInsets.right);
    if (!UIEdgeInsetsEqualToEdgeInsets(self.collectionView.contentInset, contentInset)) {
        self.collectionView.contentInset = contentInset;
        self.collectionView.scrollIndicatorInsets = UIEdgeInsetsMake(contentInset.top, 0, contentInset.bottom, 0);
        // 放在这里是因为有时候会先走完 refreshWithAssetsGroup 里的 completion 再走到这里，此时前者不会导致 scollToInitialPosition 的滚动，所以在这里再调用一次保证一定会滚
        [self scrollToInitialPositionIfNeeded];
    }
}

- (void)refreshWithAssetsGroup:(QMUIAssetsGroup *)assetsGroup {
    _assetsGroup = assetsGroup;
    if (!self.imagesAssetArray) {
        _imagesAssetArray = [[NSMutableArray alloc] init];
        _selectedImageAssetArray = [[NSMutableArray alloc] init];
    } else {
        [self.imagesAssetArray removeAllObjects];
        // 这里不用 remove 选中的图片，因为支持跨相簿选图
//        [self.selectedImageAssetArray removeAllObjects];
    }
    // 通过 QMUIAssetsGroup 获取该相册所有的图片 QMUIAsset，并且储存到数组中
    QMUIAlbumSortType albumSortType = QMUIAlbumSortTypePositive;
    // 从 delegate 中获取相册内容的排序方式，如果没有实现这个 delegate，则使用 QMUIAlbumSortType 的默认值，即最新的内容排在最后面
    if (self.imagePickerViewControllerDelegate && [self.imagePickerViewControllerDelegate respondsToSelector:@selector(albumSortTypeForImagePickerViewController:)]) {
        albumSortType = [self.imagePickerViewControllerDelegate albumSortTypeForImagePickerViewController:self];
    }
    // 遍历相册内的资源较为耗时，交给子线程去处理，因此这里需要显示 Loading
    if ([self.imagePickerViewControllerDelegate respondsToSelector:@selector(imagePickerViewControllerWillStartLoading:)]) {
        [self.imagePickerViewControllerDelegate imagePickerViewControllerWillStartLoading:self];
    }
    if (self.shouldShowDefaultLoadingView) {
        [self showEmptyViewWithLoading];
    }
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [assetsGroup enumerateAssetsWithOptions:albumSortType usingBlock:^(QMUIAsset *resultAsset) {
            // 这里需要对 UI 进行操作，因此放回主线程处理
            dispatch_async(dispatch_get_main_queue(), ^{
                if (resultAsset) {
                    self.isImagesAssetLoaded = NO;
                    [self.imagesAssetArray addObject:resultAsset];
                } else {
                    // result 为 nil，即遍历相片或视频完毕
                    self.isImagesAssetLoaded = YES;// 这个属性的作用描述： https://github.com/Tencent/QMUI_iOS/issues/219
                    [self.collectionView reloadData];
                    [self.collectionView performBatchUpdates:^{
                    } completion:^(BOOL finished) {
                        [self scrollToInitialPositionIfNeeded];
                        if (self.shouldShowDefaultLoadingView) {
                          [self hideEmptyView];
                        }
                        if ([self.imagePickerViewControllerDelegate respondsToSelector:@selector(imagePickerViewControllerDidFinishLoading:)]) {
                            [self.imagePickerViewControllerDelegate imagePickerViewControllerDidFinishLoading:self];
                        }
                    }];
                }
            });
        }];
    });
}

- (void)initPreviewViewControllerIfNeeded {
    if (!self.imagePickerPreviewViewController) {
        self.imagePickerPreviewViewController = [self.imagePickerViewControllerDelegate imagePickerPreviewViewControllerForImagePickerViewController:self];
        self.imagePickerPreviewViewController.maximumSelectImageCount = self.maximumSelectImageCount;
        self.imagePickerPreviewViewController.minimumSelectImageCount = self.minimumSelectImageCount;
    }
}

- (CGSize)referenceImageSize {
    CGFloat collectionViewWidth = CGRectGetWidth(self.collectionView.bounds);
    CGFloat collectionViewContentSpacing = collectionViewWidth - UIEdgeInsetsGetHorizontalValue(self.collectionView.contentInset) - UIEdgeInsetsGetHorizontalValue(self.collectionViewLayout.sectionInset);
    NSInteger columnCount = floor(collectionViewContentSpacing / self.minimumImageWidth);
    CGFloat referenceImageWidth = self.minimumImageWidth;
    BOOL isSpacingEnoughWhenDisplayInMinImageSize = (self.minimumImageWidth + self.collectionViewLayout.minimumInteritemSpacing) * columnCount - self.collectionViewLayout.minimumInteritemSpacing <= collectionViewContentSpacing;
    if (!isSpacingEnoughWhenDisplayInMinImageSize) {
        // 算上图片之间的间隙后发现其实还是放不下啦，所以得把列数减少，然后放大图片以撑满剩余空间
        columnCount -= 1;
    }
    referenceImageWidth = floor((collectionViewContentSpacing - self.collectionViewLayout.minimumInteritemSpacing * (columnCount - 1)) / columnCount);
    return CGSizeMake(referenceImageWidth, referenceImageWidth);
}

- (void)setMinimumImageWidth:(CGFloat)minimumImageWidth {
    _minimumImageWidth = minimumImageWidth;
    [self referenceImageSize];
    [self.collectionView.collectionViewLayout invalidateLayout];
}

- (void)scrollToInitialPositionIfNeeded {
    if (_collectionView.qmui_visible && self.isImagesAssetLoaded && !self.hasScrollToInitialPosition) {
        if ([self.imagePickerViewControllerDelegate respondsToSelector:@selector(albumSortTypeForImagePickerViewController:)] && [self.imagePickerViewControllerDelegate albumSortTypeForImagePickerViewController:self] == QMUIAlbumSortTypeReverse) {
            [_collectionView qmui_scrollToTop];
        } else {
            [_collectionView qmui_scrollToBottom];
        }
        self.hasScrollToInitialPosition = YES;
    }
}

- (void)willPopInNavigationControllerWithAnimated:(BOOL)animated {
    self.hasScrollToInitialPosition = NO;
}

#pragma mark - Getters & Setters

@synthesize collectionViewLayout = _collectionViewLayout;
- (UICollectionViewFlowLayout *)collectionViewLayout {
    if (!_collectionViewLayout) {
        _collectionViewLayout = [[UICollectionViewFlowLayout alloc] init];
        CGFloat inset = PixelOne * 2; // no why, just beautiful
        _collectionViewLayout.sectionInset = UIEdgeInsetsMake(inset, inset, inset, inset);
        _collectionViewLayout.minimumLineSpacing = _collectionViewLayout.sectionInset.bottom;
        _collectionViewLayout.minimumInteritemSpacing = _collectionViewLayout.sectionInset.left;
    }
    return _collectionViewLayout;
}

@synthesize collectionView = _collectionView;
- (UICollectionView *)collectionView {
    if (!_collectionView) {
        _collectionView = [[UICollectionView alloc] initWithFrame:self.isViewLoaded ? self.view.bounds : CGRectZero collectionViewLayout:self.collectionViewLayout];
        _collectionView.delegate = self;
        _collectionView.dataSource = self;
        _collectionView.showsHorizontalScrollIndicator = NO;
        _collectionView.alwaysBounceHorizontal = NO;
        _collectionView.backgroundColor = UIColorClear;
        [_collectionView registerClass:[QMUIImagePickerCollectionViewCell class] forCellWithReuseIdentifier:kVideoCellIdentifier];
        [_collectionView registerClass:[QMUIImagePickerCollectionViewCell class] forCellWithReuseIdentifier:kImageOrUnknownCellIdentifier];
        _collectionView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    }
    return _collectionView;
}

@synthesize operationToolBarView = _operationToolBarView;
- (UIView *)operationToolBarView {
    if (!_operationToolBarView) {
        _operationToolBarView = [[UIView alloc] init];
        _operationToolBarView.backgroundColor = UIColorWhite;
        _operationToolBarView.qmui_borderPosition = QMUIViewBorderPositionTop;
        
        [_operationToolBarView addSubview:self.sendButton];
        [_operationToolBarView addSubview:self.previewButton];
        [_operationToolBarView addSubview:self.imageCountLabel];
    }
    return _operationToolBarView;
}

@synthesize sendButton = _sendButton;
- (QMUIButton *)sendButton {
    if (!_sendButton) {
        _sendButton = [[QMUIButton alloc] init];
        _sendButton.enabled = NO;
        _sendButton.titleLabel.font = UIFontMake(16);
        _sendButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
        [_sendButton setTitleColor:UIColorMake(124, 124, 124) forState:UIControlStateNormal];
        [_sendButton setTitleColor:UIColorGray forState:UIControlStateDisabled];
        [_sendButton setTitle:@"发送" forState:UIControlStateNormal];
        _sendButton.qmui_outsideEdge = UIEdgeInsetsMake(-12, -20, -12, -20);
        [_sendButton sizeToFit];
        [_sendButton addTarget:self action:@selector(handleSendButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _sendButton;
}

@synthesize previewButton = _previewButton;
- (QMUIButton *)previewButton {
    if (!_previewButton) {
        _previewButton = [[QMUIButton alloc] init];
        _previewButton.enabled = NO;
        _previewButton.titleLabel.font = self.sendButton.titleLabel.font;
        [_previewButton setTitleColor:[self.sendButton titleColorForState:UIControlStateNormal] forState:UIControlStateNormal];
        [_previewButton setTitleColor:[self.sendButton titleColorForState:UIControlStateDisabled] forState:UIControlStateDisabled];
        [_previewButton setTitle:@"预览" forState:UIControlStateNormal];
        _previewButton.qmui_outsideEdge = UIEdgeInsetsMake(-12, -20, -12, -20);
        [_previewButton sizeToFit];
        [_previewButton addTarget:self action:@selector(handlePreviewButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _previewButton;
}

@synthesize imageCountLabel = _imageCountLabel;
- (UILabel *)imageCountLabel {
    if (!_imageCountLabel) {
        _imageCountLabel = [[UILabel alloc] init];
        _imageCountLabel.userInteractionEnabled = NO;// 不要影响 sendButton 的事件
        _imageCountLabel.backgroundColor = ButtonTintColor;
        _imageCountLabel.textColor = UIColorWhite;
        _imageCountLabel.font = UIFontMake(12);
        _imageCountLabel.textAlignment = NSTextAlignmentCenter;
        _imageCountLabel.lineBreakMode = NSLineBreakByCharWrapping;
        _imageCountLabel.layer.masksToBounds = YES;
        _imageCountLabel.hidden = YES;
    }
    return _imageCountLabel;
}

- (void)setAllowsMultipleSelection:(BOOL)allowsMultipleSelection {
    _allowsMultipleSelection = allowsMultipleSelection;
    if (self.isViewLoaded) {
        if (_allowsMultipleSelection) {
            [self.view addSubview:self.operationToolBarView];
        } else {
            [_operationToolBarView removeFromSuperview];
        }
    }
}

#pragma mark - <UICollectionViewDelegate, UICollectionViewDataSource>

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return [self.imagesAssetArray count];
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return [self referenceImageSize];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    QMUIAsset *imageAsset = [self.imagesAssetArray objectAtIndex:indexPath.item];
    
    NSString *identifier = nil;
    if (imageAsset.assetType == QMUIAssetTypeVideo) {
        identifier = kVideoCellIdentifier;
    } else {
        identifier = kImageOrUnknownCellIdentifier;
    }
    QMUIImagePickerCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:identifier forIndexPath:indexPath];
    [cell renderWithAsset:imageAsset referenceSize:[self referenceImageSize]];
    
    [cell.checkboxButton addTarget:self action:@selector(handleCheckBoxButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    cell.selectable = self.allowsMultipleSelection;
    if (cell.selectable) {
        // 如果该图片的 QMUIAsset 被包含在已选择图片的数组中，则控制该图片被选中
        cell.checked = [self.selectedImageAssetArray containsObject:imageAsset];
    }
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    QMUIAsset *imageAsset = self.imagesAssetArray[indexPath.item];
    if ([self.imagePickerViewControllerDelegate respondsToSelector:@selector(imagePickerViewController:didSelectImageWithImagesAsset:afterImagePickerPreviewViewControllerUpdate:)]) {
        [self.imagePickerViewControllerDelegate imagePickerViewController:self didSelectImageWithImagesAsset:imageAsset afterImagePickerPreviewViewControllerUpdate:self.imagePickerPreviewViewController];
    }
    if ([self.imagePickerViewControllerDelegate respondsToSelector:@selector(imagePickerPreviewViewControllerForImagePickerViewController:)]) {
        [self initPreviewViewControllerIfNeeded];
        if (!self.allowsMultipleSelection) {
            // 单选的情况下
            [self.imagePickerPreviewViewController updateImagePickerPreviewViewWithImagesAssetArray:@[imageAsset].mutableCopy
                                                                        selectedImageAssetArray:nil
                                                                              currentImageIndex:0
                                                                                singleCheckMode:YES];
        } else {
            // cell 处于编辑状态，即图片允许多选
            [self.imagePickerPreviewViewController updateImagePickerPreviewViewWithImagesAssetArray:self.imagesAssetArray
                                                                        selectedImageAssetArray:self.selectedImageAssetArray
                                                                              currentImageIndex:indexPath.item
                                                                                singleCheckMode:NO];
        }
        [self.navigationController pushViewController:self.imagePickerPreviewViewController animated:YES];
    }
}

#pragma mark - 按钮点击回调

- (void)handleSendButtonClick:(id)sender {
    if (self.imagePickerViewControllerDelegate && [self.imagePickerViewControllerDelegate respondsToSelector:@selector(imagePickerViewController:didFinishPickingImageWithImagesAssetArray:)]) {
        [self.imagePickerViewControllerDelegate imagePickerViewController:self didFinishPickingImageWithImagesAssetArray:self.selectedImageAssetArray];
    }
    [self.selectedImageAssetArray removeAllObjects];
    [self dismissViewControllerAnimated:YES completion:NULL];
}

- (void)handlePreviewButtonClick:(id)sender {
    [self initPreviewViewControllerIfNeeded];
    // 手工更新图片预览界面
    [self.imagePickerPreviewViewController updateImagePickerPreviewViewWithImagesAssetArray:[self.selectedImageAssetArray copy]
                                                                selectedImageAssetArray:self.selectedImageAssetArray
                                                                      currentImageIndex:0
                                                                        singleCheckMode:NO];
    [self.navigationController pushViewController:self.imagePickerPreviewViewController animated:YES];
}

- (void)handleCancelPickerImage:(id)sender {
    [self dismissViewControllerAnimated:YES completion:^() {
        if (self.imagePickerViewControllerDelegate && [self.imagePickerViewControllerDelegate respondsToSelector:@selector(imagePickerViewControllerDidCancel:)]) {
            [self.imagePickerViewControllerDelegate imagePickerViewControllerDidCancel:self];
        }
        [self.selectedImageAssetArray removeAllObjects];
    }];
}

- (void)handleCheckBoxButtonClick:(UIButton *)checkboxButton {
    NSIndexPath *indexPath = [_collectionView qmui_indexPathForItemAtView:checkboxButton];
    
    if ([self.imagePickerViewControllerDelegate respondsToSelector:@selector(imagePickerViewController:shouldCheckImageAtIndex:)] && ![self.imagePickerViewControllerDelegate imagePickerViewController:self shouldCheckImageAtIndex:indexPath.item]) {
        return;
    }
    
    QMUIImagePickerCollectionViewCell *cell = (QMUIImagePickerCollectionViewCell *)[_collectionView cellForItemAtIndexPath:indexPath];
    QMUIAsset *imageAsset = [self.imagesAssetArray objectAtIndex:indexPath.item];
    if (cell.checked) {
        // 移除选中状态
        if ([self.imagePickerViewControllerDelegate respondsToSelector:@selector(imagePickerViewController:willUncheckImageAtIndex:)]) {
            [self.imagePickerViewControllerDelegate imagePickerViewController:self willUncheckImageAtIndex:indexPath.item];
        }
        
        cell.checked = NO;
        [self.selectedImageAssetArray removeObject:imageAsset];
        
        if ([self.imagePickerViewControllerDelegate respondsToSelector:@selector(imagePickerViewController:didUncheckImageAtIndex:)]) {
            [self.imagePickerViewControllerDelegate imagePickerViewController:self didUncheckImageAtIndex:indexPath.item];
        }
        
        // 根据选择图片数控制预览和发送按钮的 enable，以及修改已选中的图片数
        [self updateImageCountAndCheckLimited];
    } else {
        // 选中该资源
        if ([self.selectedImageAssetArray count] >= _maximumSelectImageCount) {
            if (!_alertTitleWhenExceedMaxSelectImageCount) {
                _alertTitleWhenExceedMaxSelectImageCount = [NSString stringWithFormat:@"你最多只能选择%@张图片", @(_maximumSelectImageCount)];
            }
            if (!_alertButtonTitleWhenExceedMaxSelectImageCount) {
                _alertButtonTitleWhenExceedMaxSelectImageCount = [NSString stringWithFormat:@"我知道了"];
            }
            
            QMUIAlertController *alertController = [QMUIAlertController alertControllerWithTitle:_alertTitleWhenExceedMaxSelectImageCount message:nil preferredStyle:QMUIAlertControllerStyleAlert];
            [alertController addAction:[QMUIAlertAction actionWithTitle:_alertButtonTitleWhenExceedMaxSelectImageCount style:QMUIAlertActionStyleCancel handler:nil]];
            [alertController showWithAnimated:YES];
            return;
        }
        
        if ([self.imagePickerViewControllerDelegate respondsToSelector:@selector(imagePickerViewController:willCheckImageAtIndex:)]) {
            [self.imagePickerViewControllerDelegate imagePickerViewController:self willCheckImageAtIndex:indexPath.item];
        }
        
        cell.checked = YES;
        [self.selectedImageAssetArray addObject:imageAsset];
        
        if ([self.imagePickerViewControllerDelegate respondsToSelector:@selector(imagePickerViewController:didCheckImageAtIndex:)]) {
            [self.imagePickerViewControllerDelegate imagePickerViewController:self didCheckImageAtIndex:indexPath.item];
        }
        
        // 根据选择图片数控制预览和发送按钮的 enable，以及修改已选中的图片数
        [self updateImageCountAndCheckLimited];
        
        // 发出请求获取大图，如果图片在 iCloud，则会发出网络请求下载图片。这里同时保存请求 id，供取消请求使用
        [self requestImageWithIndexPath:indexPath];
    }
}

- (void)updateImageCountAndCheckLimited {
    NSInteger selectedImageCount = [self.selectedImageAssetArray count];
    if (selectedImageCount > 0 && selectedImageCount >= _minimumSelectImageCount) {
        self.previewButton.enabled = YES;
        self.sendButton.enabled = YES;
        self.imageCountLabel.text = [NSString stringWithFormat:@"%@", @(selectedImageCount)];
        self.imageCountLabel.hidden = NO;
        [QMUIImagePickerHelper springAnimationOfImageSelectedCountChangeWithCountLabel:self.imageCountLabel];
    } else {
        self.previewButton.enabled = NO;
        self.sendButton.enabled = NO;
        self.imageCountLabel.hidden = YES;
    }
}

#pragma mark - Request Image

- (void)requestImageWithIndexPath:(NSIndexPath *)indexPath {
    // 发出请求获取大图，如果图片在 iCloud，则会发出网络请求下载图片。这里同时保存请求 id，供取消请求使用
    QMUIAsset *imageAsset = [self.imagesAssetArray objectAtIndex:indexPath.item];
    QMUIImagePickerCollectionViewCell *cell = (QMUIImagePickerCollectionViewCell *)[_collectionView cellForItemAtIndexPath:indexPath];
    imageAsset.requestID = [imageAsset requestOriginImageWithCompletion:^(UIImage *result, NSDictionary *info) {
        
        BOOL downloadSucceed = (result && !info) || (![[info objectForKey:PHImageCancelledKey] boolValue] && ![info objectForKey:PHImageErrorKey] && ![[info objectForKey:PHImageResultIsDegradedKey] boolValue]);
        
        if (downloadSucceed) {
            // 资源资源已经在本地或下载成功
            [imageAsset updateDownloadStatusWithDownloadResult:YES];
            cell.downloadStatus = QMUIAssetDownloadStatusSucceed;
            
        } else if ([info objectForKey:PHImageErrorKey] ) {
            // 下载错误
            [imageAsset updateDownloadStatusWithDownloadResult:NO];
            cell.downloadStatus = QMUIAssetDownloadStatusFailed;
        }
        
    } withProgressHandler:^(double progress, NSError *error, BOOL *stop, NSDictionary *info) {
        imageAsset.downloadProgress = progress;
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if ([self.collectionView qmui_itemVisibleAtIndexPath:indexPath]) {
                
                QMUILogInfo(@"QMUIImagePickerLibrary", @"Download iCloud image, current progress is : %f", progress);
                
                if (cell.downloadStatus != QMUIAssetDownloadStatusDownloading) {
                    cell.downloadStatus = QMUIAssetDownloadStatusDownloading;
                    // 预先设置预览界面的下载状态
                    self.imagePickerPreviewViewController.downloadStatus = QMUIAssetDownloadStatusDownloading;
                }
                if (error) {
                    QMUILog(@"QMUIImagePickerLibrary", @"Download iCloud image Failed, current progress is: %f", progress);
                    cell.downloadStatus = QMUIAssetDownloadStatusFailed;
                }
            }
        });
    }];
}

@end
