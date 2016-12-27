//
//  QMUIKit.h
//  QMUIKit
//
//  Created by zhoonchen on 16/9/9.
//  Copyright © 2016年 QMUI Team. All rights reserved.
//

#import <UIKit/UIKit.h>

//! Project version number for QMUIKit.
FOUNDATION_EXPORT double QMUIKitVersionNumber;

//! Project version string for QMUIKit.
FOUNDATION_EXPORT const unsigned char QMUIKitVersionString[];

// In this header, you should import all the public headers of your framework using statements like #import <QMUIKit/PublicHeader.h>


// 此项目同时存在静态库和动态库，所以为了修复一些找不到文件的报错，这里的import写了两份，一份给静态库一份给动态库。

#ifdef IS_QMUI_FRAMEWORK

/// QMUIBase
#import <QMUIKit/QMUIHelper.h>
#import <QMUIKit/QMUICommonDefines.h>
#import <QMUIKit/QMUIConfiguration.h>

/// QMUIKit
#import <QMUIKit/QMUIVisualEffectView.h>
#import <QMUIKit/QMUIButton.h>
#import <QMUIKit/QMUILabel.h>
#import <QMUIKit/QMUITextField.h>
#import <QMUIKit/QMUITextView.h>
#import <QMUIKit/QMUISearchBar.h>
#import <QMUIKit/QMUITableViewCell.h>
#import <QMUIKit/QMUITableView.h>
#import <QMUIKit/QMUITableViewProtocols.h>
#import <QMUIKit/QMUISegmentedControl.h>
#import <QMUIKit/QMUICollectionViewPagingLayout.h>
#import <QMUIKit/QMUITestView.h>

/// Category
#import <QMUIKit/NSObject+QMUI.h>
#import <QMUIKit/NSString+QMUI.h>
#import <QMUIKit/NSAttributedString+QMUI.h>
#import <QMUIKit/UIColor+QMUI.h>
#import <QMUIKit/UIImage+QMUI.h>
#import <QMUIKit/CALayer+QMUI.h>
#import <QMUIKit/UIView+QMUI.h>
#import <QMUIKit/UIFont+QMUI.h>
#import <QMUIKit/UIBezierPath+QMUI.h>
#import <QMUIKit/NSParagraphStyle+QMUI.h>
#import <QMUIKit/UILabel+QMUI.h>
#import <QMUIKit/UIImageView+QMUI.h>
#import <QMUIKit/UIControl+QMUI.h>
#import <QMUIKit/UIButton+QMUI.h>
#import <QMUIKit/UISearchBar+QMUI.h>
#import <QMUIKit/UIScrollView+QMUI.h>
#import <QMUIKit/QMUICellHeightCache.h>
#import <QMUIKit/UITableView+QMUI.h>
#import <QMUIKit/UICollectionView+QMUI.h>
#import <QMUIKit/UITabBarItem+QMUI.h>
#import <QMUIKit/UIActivityIndicatorView+QMUI.h>
#import <QMUIKit/UIWindow+QMUI.h>
#import <QMUIKit/UIViewController+QMUI.h>
#import <QMUIKit/UINavigationController+QMUI.h>
#import <QMUIKit/UINavigationBar+Transition.h>
#import <QMUIKit/UINavigationController+NavigationBarTransition.h>

/// UIComponents
#import <QMUIKit/QMUIToastBackgroundView.h>
#import <QMUIKit/QMUIToastContentView.h>
#import <QMUIKit/QMUIToastAnimator.h>
#import <QMUIKit/QMUIToastView.h>
#import <QMUIKit/QMUITips.h>
#import <QMUIKit/QMUIEmptyView.h>
#import <QMUIKit/QMUINavigationTitleView.h>
#import <QMUIKit/QMUIStaticTableViewCellData.h>
#import <QMUIKit/QMUIGridView.h>
#import <QMUIKit/QMUIFloatLayoutView.h>
#import <QMUIKit/QMUIZoomImageView.h>
#import <QMUIKit/QMUIImagePreviewView.h>
#import <QMUIKit/QMUIImagePreviewViewController.h>
#import <QMUIKit/QMUIAsset.h>
#import <QMUIKit/QMUIAssetsGroup.h>
#import <QMUIKit/QMUIImagePickerHelper.h>
#import <QMUIKit/QMUIAssetsManager.h>
#import <QMUIKit/QMUIEmotionView.h>
#import <QMUIKit/QMUIQQEmotionManager.h>
#import <QMUIKit/QMUIPieProgressView.h>
#import <QMUIKit/QMUIPopupContainerView.h>
#import <QMUIKit/QMUIModalPresentationViewController.h>
#import <QMUIKit/QMUIAlertController.h>
#import <QMUIKit/QMUIAlbumViewController.h>
#import <QMUIKit/QMUIImagePickerViewController.h>
#import <QMUIKit/QMUIImagePickerCollectionViewCell.h>
#import <QMUIKit/QMUIImagePickerPreviewViewController.h>
#import <QMUIKit/QMUIMoreOperationController.h>
#import <QMUIKit/QMUIDialogViewController.h>
#import <QMUIKit/QMUIOrderedDictionary.h>

/// UIMainFrame
#import <QMUIKit/QMUISearchController.h>
#import <QMUIKit/QMUICommonViewController.h>
#import <QMUIKit/QMUICommonTableViewController.h>
#import <QMUIKit/QMUINavigationController.h>
#import <QMUIKit/QMUITabBarViewController.h>

#else

/// QMUIBase
#import "QMUIHelper.h"
#import "QMUICommonDefines.h"
#import "QMUIConfiguration.h"

/// QMUIKit
#import "QMUIVisualEffectView.h"
#import "QMUIButton.h"
#import "QMUILabel.h"
#import "QMUITextField.h"
#import "QMUITextView.h"
#import "QMUISearchBar.h"
#import "QMUITableViewCell.h"
#import "QMUITableView.h"
#import "QMUITableViewProtocols.h"
#import "QMUISegmentedControl.h"
#import "QMUICollectionViewPagingLayout.h"
#import "QMUITestView.h"

/// Category
#import "NSObject+QMUI.h"
#import "NSString+QMUI.h"
#import "NSAttributedString+QMUI.h"
#import "UIColor+QMUI.h"
#import "UIImage+QMUI.h"
#import "CALayer+QMUI.h"
#import "UIView+QMUI.h"
#import "UIFont+QMUI.h"
#import "UIBezierPath+QMUI.h"
#import "NSParagraphStyle+QMUI.h"
#import "UILabel+QMUI.h"
#import "UIImageView+QMUI.h"
#import "UIControl+QMUI.h"
#import "UIButton+QMUI.h"
#import "UISearchBar+QMUI.h"
#import "UIScrollView+QMUI.h"
#import "QMUICellHeightCache.h"
#import "UITableView+QMUI.h"
#import "UICollectionView+QMUI.h"
#import "UITabBarItem+QMUI.h"
#import "UIActivityIndicatorView+QMUI.h"
#import "UIWindow+QMUI.h"
#import "UIViewController+QMUI.h"
#import "UINavigationController+QMUI.h"
#import "UINavigationBar+Transition.h"
#import "UINavigationController+NavigationBarTransition.h"

/// UIComponents
#import "QMUIToastBackgroundView.h"
#import "QMUIToastContentView.h"
#import "QMUIToastAnimator.h"
#import "QMUIToastView.h"
#import "QMUITips.h"
#import "QMUIEmptyView.h"
#import "QMUINavigationTitleView.h"
#import "QMUIStaticTableViewCellData.h"
#import "QMUIGridView.h"
#import "QMUIFloatLayoutView.h"
#import "QMUIZoomImageView.h"
#import "QMUIImagePreviewView.h"
#import "QMUIImagePreviewViewController.h"
#import "QMUIAsset.h"
#import "QMUIAssetsGroup.h"
#import "QMUIImagePickerHelper.h"
#import "QMUIAssetsManager.h"
#import "QMUIEmotionView.h"
#import "QMUIQQEmotionManager.h"
#import "QMUIPieProgressView.h"
#import "QMUIPopupContainerView.h"
#import "QMUIModalPresentationViewController.h"
#import "QMUIAlertController.h"
#import "QMUIAlbumViewController.h"
#import "QMUIImagePickerViewController.h"
#import "QMUIImagePickerCollectionViewCell.h"
#import "QMUIImagePickerPreviewViewController.h"
#import "QMUIMoreOperationController.h"
#import "QMUIDialogViewController.h"
#import "QMUIOrderedDictionary.h"

/// UIMainFrame
#import "QMUISearchController.h"
#import "QMUICommonViewController.h"
#import "QMUICommonTableViewController.h"
#import "QMUINavigationController.h"
#import "QMUITabBarViewController.h"

#endif
