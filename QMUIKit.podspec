Pod::Spec.new do |s|
  s.name             = "QMUIKit"
  s.version          = "4.0.1"
  s.summary          = "致力于提高项目 UI 开发效率的解决方案"
  s.description      = <<-DESC
                       QMUI iOS 是一个致力于提高项目 UI 开发效率的解决方案，其设计目的是用于辅助快速搭建一个具备基本设计还原效果的 iOS 项目，同时利用自身提供的丰富控件及兼容处理， 让开发者能专注于业务需求而无需耗费精力在基础代码的设计上。不管是新项目的创建，或是已有项目的维护，均可使开发效率和项目质量得到大幅度提升。
                       DESC
  s.homepage         = "https://qmuiteam.com/ios"
  s.license          = 'MIT'
  s.author           = {"qmuiteam" => "contact@qmuiteam.com"}
  s.source           = {:git => "https://github.com/Tencent/QMUI_iOS.git", :tag => s.version.to_s}
  #s.source           = {:git => "https://github.com/Tencent/QMUI_iOS.git", :branch => 'master'}
  s.social_media_url = 'https://github.com/Tencent/QMUI_iOS'
  s.requires_arc     = true
  s.documentation_url = 'https://qmuiteam.com/ios/page/document.html'
  s.screenshot       = 'https://cloud.githubusercontent.com/assets/1190261/26751376/63f96538-486a-11e7-81cf-5bc83a945207.png'

  s.platform         = :ios, '9.0'
  s.frameworks       = 'Foundation', 'UIKit', 'CoreGraphics', 'Photos'
  s.preserve_paths   = 'QMUIConfigurationTemplate/*'
  s.source_files     = 'QMUIKit/QMUIKit.h'

  s.subspec 'QMUICore' do |ss|
    ss.source_files = 'QMUIKit/QMUIKit.h', 'QMUIKit/QMUICore', 'QMUIKit/UIKitExtensions'
    ss.dependency 'QMUIKit/QMUIWeakObjectContainer'
    ss.dependency 'QMUIKit/QMUILog'
  end

  s.subspec 'QMUIResources' do |ss|
    ss.resource = 'QMUIKit/QMUIResources/*.*'
  end

  s.subspec 'QMUIMainFrame' do |ss|
    ss.source_files = 'QMUIKit/QMUIMainFrame'
    ss.dependency 'QMUIKit/QMUICore'
    ss.dependency 'QMUIKit/QMUIComponents/QMUINavigationTitleView'
    ss.dependency 'QMUIKit/QMUIComponents/QMUITableView'
    ss.dependency 'QMUIKit/QMUIComponents/QMUITableViewHeaderFooterView'
    ss.dependency 'QMUIKit/QMUIComponents/QMUIEmptyView'
    ss.dependency 'QMUIKit/QMUIComponents/QMUIKeyboardManager'
    ss.dependency 'QMUIKit/QMUILog'
    ss.dependency 'QMUIKit/QMUIComponents/QMUIMultipleDelegates'
  end

  s.subspec 'QMUIWeakObjectContainer' do |ss|
    ss.source_files = 'QMUIKit/QMUIComponents/QMUIWeakObjectContainer.{h,m}'
  end

  s.subspec 'QMUILog' do |ss|
    ss.source_files = 'QMUIKit/QMUIComponents/QMUILog/*.{h,m}'
  end

  s.subspec 'QMUIComponents' do |ss|

    ss.dependency 'QMUIKit/QMUICore'

    ss.subspec 'QMUICAAnimationExtension' do |sss|
      sss.source_files = 'QMUIKit/QMUIComponents/CAAnimation+QMUI.{h,m}'
      sss.dependency 'QMUIKit/QMUIComponents/QMUIMultipleDelegates'
    end

    ss.subspec 'QMUIAnimation' do |sss|
      sss.source_files = 'QMUIKit/QMUIComponents/QMUIAnimation'
    end

    ss.subspec 'QMUINavigationTitleView' do |sss|
      sss.source_files = 'QMUIKit/QMUIComponents/QMUINavigationTitleView.{h,m}'
      sss.dependency 'QMUIKit/QMUIComponents/QMUIButton'
    end

    ss.subspec 'QMUIButton' do |sss|
      sss.source_files = 'QMUIKit/QMUIComponents/QMUIButton/QMUIButton.{h,m}'
    end

    ss.subspec 'QMUIFillButton' do |sss|
      sss.source_files = 'QMUIKit/QMUIComponents/QMUIButton/QMUIFillButton.{h,m}'
      sss.dependency 'QMUIKit/QMUIComponents/QMUIButton'
    end

    ss.subspec 'QMUIGhostButton' do |sss|
      sss.source_files = 'QMUIKit/QMUIComponents/QMUIButton/QMUIGhostButton.{h,m}'
      sss.dependency 'QMUIKit/QMUIComponents/QMUIButton'
    end

    ss.subspec 'QMUILinkButton' do |sss|
      sss.source_files = 'QMUIKit/QMUIComponents/QMUIButton/QMUILinkButton.{h,m}'
      sss.dependency 'QMUIKit/QMUIComponents/QMUIButton'
    end

    ss.subspec 'QMUINavigationButton' do |sss|
      sss.source_files = 'QMUIKit/QMUIComponents/QMUIButton/QMUINavigationButton.{h,m}'
      sss.dependency 'QMUIKit/QMUIMainFrame'
    end

    ss.subspec 'QMUIToolbarButton' do |sss|
      sss.source_files = 'QMUIKit/QMUIComponents/QMUIButton/QMUIToolbarButton.{h,m}'
    end

    ss.subspec 'QMUITableView' do |sss|
      sss.source_files = 'QMUIKit/QMUIComponents/QMUITableView.{h,m}'
      sss.dependency 'QMUIKit/QMUIComponents/QMUITableViewProtocols'
    end

    ss.subspec 'QMUITableViewProtocols' do |sss|
      sss.source_files = 'QMUIKit/QMUIComponents/QMUITableViewProtocols.{h,m}'
    end

    ss.subspec 'QMUIEmptyView' do |sss|
      sss.source_files = 'QMUIKit/QMUIComponents/QMUIEmptyView.{h,m}'
      sss.dependency 'QMUIKit/QMUIComponents/QMUIButton'
    end

    ss.subspec 'QMUILabel' do |sss|
      sss.source_files = 'QMUIKit/QMUIComponents/QMUILabel.{h,m}'
    end

    ss.subspec 'QMUIKeyboardManager' do |sss|
      sss.source_files = 'QMUIKit/QMUIComponents/QMUIKeyboardManager.{h,m}'
    end

    # 从这里开始就是非必须的组件
    
    ss.subspec 'QMUIMultipleDelegates' do |sss|
      sss.source_files = 'QMUIKit/QMUIComponents/QMUIMultipleDelegates/*.{h,m}'
    end
    
    ss.subspec 'QMUIAlertController' do |sss|
      sss.source_files = 'QMUIKit/QMUIComponents/QMUIAlertController.{h,m}'
      sss.dependency 'QMUIKit/QMUIComponents/QMUIModalPresentationViewController'
			sss.dependency 'QMUIKit/QMUIComponents/QMUIButton'
			sss.dependency 'QMUIKit/QMUIComponents/QMUITextField'
    end

    ss.subspec 'QMUICellHeightCache' do |sss|
      sss.source_files = 'QMUIKit/QMUIComponents/QMUICellHeightCache.{h,m}'
      sss.dependency 'QMUIKit/QMUIComponents/QMUITableViewProtocols'
    end

    ss.subspec 'QMUICellHeightKeyCache' do |sss|
      sss.source_files = 'QMUIKit/QMUIComponents/QMUICellHeightKeyCache/*.{h,m}'
      sss.dependency 'QMUIKit/QMUIComponents/QMUITableViewProtocols'
      sss.dependency 'QMUIKit/QMUIComponents/QMUIMultipleDelegates'
    end

    ss.subspec 'QMUICellSizeKeyCache' do |sss|
      sss.source_files = 'QMUIKit/QMUIComponents/QMUICellSizeKeyCache/*.{h,m}'
      sss.dependency 'QMUIKit/QMUIComponents/QMUIMultipleDelegates'
    end

    ss.subspec 'QMUIConsole' do |sss|
      sss.source_files = 'QMUIKit/QMUIComponents/QMUIConsole/*.{h,m}'
      sss.dependency 'QMUIKit/QMUIComponents/QMUITextView'
      sss.dependency 'QMUIKit/QMUIComponents/QMUITextField'
      sss.dependency 'QMUIKit/QMUIComponents/QMUIButton'
      sss.dependency 'QMUIKit/QMUIComponents/QMUIPopupMenuView'
      sss.dependency 'QMUIKit/QMUIComponents/QMUICAAnimationExtension'
    end

    ss.subspec 'QMUICollectionViewPagingLayout' do |sss|
      sss.source_files = 'QMUIKit/QMUIComponents/QMUICollectionViewPagingLayout.{h,m}'
    end

    ss.subspec 'QMUIDialogViewController' do |sss|
      sss.source_files = 'QMUIKit/QMUIComponents/QMUIDialogViewController.{h,m}'
      sss.dependency 'QMUIKit/QMUIMainFrame'
			sss.dependency 'QMUIKit/QMUIComponents/QMUILabel'
      sss.dependency 'QMUIKit/QMUIComponents/QMUIModalPresentationViewController'
			sss.dependency 'QMUIKit/QMUIComponents/QMUITableView'
			sss.dependency 'QMUIKit/QMUIComponents/QMUIButton'
			sss.dependency 'QMUIKit/QMUIComponents/QMUITextField'
			sss.dependency 'QMUIKit/QMUIComponents/QMUITableViewCell'
			sss.dependency 'QMUIKit/QMUIComponents/QMUINavigationTitleView'
    end

    ss.subspec 'QMUIEmotionView' do |sss|
      sss.source_files = 'QMUIKit/QMUIComponents/QMUIEmotionView.{h,m}'
      sss.dependency 'QMUIKit/QMUIComponents/QMUIButton'
      sss.dependency 'QMUIKit/QMUIResources'
    end

    ss.subspec 'QMUIFloatLayoutView' do |sss|
      sss.source_files = 'QMUIKit/QMUIComponents/QMUIFloatLayoutView.{h,m}'
    end

    ss.subspec 'QMUIGridView' do |sss|
      sss.source_files = 'QMUIKit/QMUIComponents/QMUIGridView.{h,m}'
    end

    ss.subspec 'QMUIImagePreviewView' do |sss|
      sss.source_files = 'QMUIKit/QMUIComponents/QMUIImagePreviewView/*.{h,m}'
      sss.dependency 'QMUIKit/QMUIComponents/QMUIZoomImageView'
			sss.dependency 'QMUIKit/QMUIComponents/QMUICollectionViewPagingLayout'
			sss.dependency 'QMUIKit/QMUIComponents/QMUIEmptyView'
			sss.dependency 'QMUIKit/QMUIComponents/QMUIPieProgressView'
			sss.dependency 'QMUIKit/QMUIComponents/QMUIButton'
      sss.dependency 'QMUIKit/QMUIMainFrame'
    end

    ss.subspec 'QMUIMarqueeLabel' do |sss|
      sss.source_files = 'QMUIKit/QMUIComponents/QMUIMarqueeLabel.{h,m}'
    end

    ss.subspec 'QMUIModalPresentationViewController' do |sss|
      sss.source_files = 'QMUIKit/QMUIComponents/QMUIModalPresentationViewController.{h,m}'
			sss.dependency 'QMUIKit/QMUIComponents/QMUIKeyboardManager'
    end

    ss.subspec 'QMUIMoreOperationController' do |sss|
      sss.source_files = 'QMUIKit/QMUIComponents/QMUIMoreOperationController.{h,m}'
      sss.dependency 'QMUIKit/QMUIComponents/QMUIModalPresentationViewController'
			sss.dependency 'QMUIKit/QMUIComponents/QMUIButton'
    end

    ss.subspec 'QMUIOrderedDictionary' do |sss|
      sss.source_files = 'QMUIKit/QMUIComponents/QMUIOrderedDictionary.{h,m}'
    end

    ss.subspec 'QMUIPieProgressView' do |sss|
      sss.source_files = 'QMUIKit/QMUIComponents/QMUIPieProgressView.{h,m}'
    end

    ss.subspec 'QMUIPopupContainerView' do |sss|
      sss.source_files = 'QMUIKit/QMUIComponents/QMUIPopupContainerView.{h,m}'
      sss.dependency 'QMUIKit/QMUIMainFrame'
    end

    ss.subspec 'QMUIPopupMenuView' do |sss|
      sss.source_files = 'QMUIKit/QMUIComponents/QMUIPopupMenuView/*.{h,m}'
      sss.dependency 'QMUIKit/QMUIComponents/QMUIButton'
      sss.dependency 'QMUIKit/QMUIComponents/QMUIPopupContainerView'
    end
    
    ss.subspec 'QMUIScrollAnimator' do |sss|
      sss.source_files = 'QMUIKit/QMUIComponents/QMUIScrollAnimator/*.{h,m}'
      sss.dependency 'QMUIKit/QMUIComponents/QMUIMultipleDelegates'
    end

    ss.subspec 'QMUIEmotionInputManager' do |sss|
      sss.source_files = 'QMUIKit/QMUIComponents/QMUIEmotionInputManager.{h,m}'
      sss.dependency 'QMUIKit/QMUIComponents/QMUIEmotionView'
    end

    ss.subspec 'QMUISearchBar' do |sss|
      sss.source_files = 'QMUIKit/QMUIComponents/QMUISearchBar.{h,m}'
    end

    ss.subspec 'QMUISearchController' do |sss|
      sss.source_files = 'QMUIKit/QMUIComponents/QMUISearchController.{h,m}'
      sss.dependency 'QMUIKit/QMUIMainFrame'
      sss.dependency 'QMUIKit/QMUIComponents/QMUISearchBar'
			sss.dependency 'QMUIKit/QMUIComponents/QMUIEmptyView'
    end

    ss.subspec 'QMUISegmentedControl' do |sss|
      sss.source_files = 'QMUIKit/QMUIComponents/QMUISegmentedControl.{h,m}'
    end

    ss.subspec 'QMUISlider' do |sss|
      sss.source_files = 'QMUIKit/QMUIComponents/QMUISlider.{h,m}'
    end

    ss.subspec 'QMUITableViewCell' do |sss|
      sss.source_files = 'QMUIKit/QMUIComponents/QMUITableViewCell.{h,m}'
      sss.dependency 'QMUIKit/QMUIComponents/QMUIButton'
    end

    ss.subspec 'QMUITableViewHeaderFooterView' do |sss|
      sss.source_files = 'QMUIKit/QMUIComponents/QMUITableViewHeaderFooterView.{h,m}'
    end

    ss.subspec 'QMUITestView' do |sss|
      sss.source_files = 'QMUIKit/QMUIComponents/QMUITestView.{h,m}'
    end

    ss.subspec 'QMUITextField' do |sss|
      sss.source_files = 'QMUIKit/QMUIComponents/QMUITextField.{h,m}'
      sss.dependency 'QMUIKit/QMUIComponents/QMUIMultipleDelegates'
    end

    ss.subspec 'QMUITextView' do |sss|
      sss.source_files = 'QMUIKit/QMUIComponents/QMUITextView.{h,m}'
      sss.dependency 'QMUIKit/QMUIComponents/QMUILabel'
      sss.dependency 'QMUIKit/QMUIComponents/QMUIMultipleDelegates'
    end

    ss.subspec 'QMUITheme' do |sss|
      sss.source_files = 'QMUIKit/QMUIComponents/QMUITheme/*.{h,m}'
      sss.dependency 'QMUIKit/QMUIComponents/QMUIImagePickerLibrary'
      sss.dependency 'QMUIKit/QMUIComponents/QMUIAlertController'
      sss.dependency 'QMUIKit/QMUIComponents/QMUIButton'
      sss.dependency 'QMUIKit/QMUIComponents/QMUIFillButton'
      sss.dependency 'QMUIKit/QMUIComponents/QMUIGhostButton'
      sss.dependency 'QMUIKit/QMUIComponents/QMUILinkButton'
      sss.dependency 'QMUIKit/QMUIComponents/QMUIConsole'
      sss.dependency 'QMUIKit/QMUIComponents/QMUIEmotionView'
      sss.dependency 'QMUIKit/QMUIComponents/QMUIEmptyView'
      sss.dependency 'QMUIKit/QMUIComponents/QMUIGridView'
      sss.dependency 'QMUIKit/QMUIComponents/QMUIImagePreviewView'
      sss.dependency 'QMUIKit/QMUIComponents/QMUILabel'
      sss.dependency 'QMUIKit/QMUIComponents/QMUIPopupContainerView'
      sss.dependency 'QMUIKit/QMUIComponents/QMUIPopupMenuView'
      sss.dependency 'QMUIKit/QMUIComponents/QMUISlider'
      sss.dependency 'QMUIKit/QMUIComponents/QMUITextField'
      sss.dependency 'QMUIKit/QMUIComponents/QMUITextView'
      sss.dependency 'QMUIKit/QMUIComponents/QMUIVisualEffectView'
      sss.dependency 'QMUIKit/QMUIComponents/QMUIToastView'
      sss.dependency 'QMUIKit/QMUIComponents/QMUIModalPresentationViewController'
    end

    ss.subspec 'QMUITips' do |sss|
      sss.source_files = 'QMUIKit/QMUIComponents/QMUITips.{h,m}'
      sss.dependency 'QMUIKit/QMUIComponents/QMUIToastView'
      sss.dependency 'QMUIKit/QMUIResources'
    end
    
    ss.subspec 'QMUIVisualEffectView' do |sss|
      sss.source_files = 'QMUIKit/QMUIComponents/QMUIVisualEffectView.{h,m}'
    end

    ss.subspec 'QMUIWindowSizeMonitor' do |sss|
      sss.source_files = 'QMUIKit/QMUIComponents/QMUIWindowSizeMonitor.{h,m}'
    end

    ss.subspec 'QMUIZoomImageView' do |sss|
      sss.source_files = 'QMUIKit/QMUIComponents/QMUIZoomImageView.{h,m}'
      sss.dependency 'QMUIKit/QMUIComponents/QMUIEmptyView'
			sss.dependency 'QMUIKit/QMUIComponents/QMUIButton'
			sss.dependency 'QMUIKit/QMUIComponents/QMUISlider'
      sss.dependency 'QMUIKit/QMUIComponents/QMUIPieProgressView'
      sss.dependency 'QMUIKit/QMUIComponents/QMUIAssetLibrary'
    end

    ss.subspec 'QMUIAssetLibrary' do |sss|
      sss.source_files = 'QMUIKit/QMUIComponents/AssetLibrary/*.{h,m}'
    end

    ss.subspec 'QMUIImagePickerLibrary' do |sss|
      sss.source_files = 'QMUIKit/QMUIComponents/ImagePickerLibrary/*.{h,m}'
      sss.dependency 'QMUIKit/QMUIMainFrame'
      sss.dependency 'QMUIKit/QMUIResources'
      sss.dependency 'QMUIKit/QMUIComponents/QMUIImagePreviewView'
      sss.dependency 'QMUIKit/QMUIComponents/QMUITableViewCell'
      sss.dependency 'QMUIKit/QMUIComponents/QMUIButton'
      sss.dependency 'QMUIKit/QMUIComponents/QMUINavigationButton'
      sss.dependency 'QMUIKit/QMUIComponents/QMUIAssetLibrary'
      sss.dependency 'QMUIKit/QMUIComponents/QMUIZoomImageView'
      sss.dependency 'QMUIKit/QMUIComponents/QMUIAlertController'
      sss.dependency 'QMUIKit/QMUIComponents/QMUIEmptyView'
    end


    ss.subspec 'QMUILogManagerViewController' do |sss|
      sss.source_files = 'QMUIKit/QMUIComponents/QMUILogManagerViewController.{h,m}'
      sss.dependency 'QMUIKit/QMUIMainFrame'
      sss.dependency 'QMUIKit/QMUIComponents/QMUIStaticTableView'
      sss.dependency 'QMUIKit/QMUIComponents/QMUITableView'
      sss.dependency 'QMUIKit/QMUIComponents/QMUIPopupMenuView'
      sss.dependency 'QMUIKit/QMUIComponents/QMUISearchController'
    end

    ss.subspec 'QMUILogWithConfigurationSupported' do |sss|
      sss.source_files = 'QMUIKit/QMUIComponents/QMUILogger+QMUIConfigurationTemplate.{h,m}'
    end

    ss.subspec 'NavigationBarTransition' do |sss|
      sss.source_files = 'QMUIKit/QMUIComponents/NavigationBarTransition/*.{h,m}'
      sss.dependency 'QMUIKit/QMUIMainFrame'
      sss.dependency 'QMUIKit/QMUIComponents/QMUINavigationTitleView'
    end

    ss.subspec 'QMUIBadge' do |sss|
      sss.source_files = 'QMUIKit/QMUIComponents/QMUIBadge/*.{h,m}'
      sss.dependency 'QMUIKit/QMUIComponents/QMUILabel'
    end

    ss.subspec 'QMUIToastView' do |sss|
      sss.source_files = 'QMUIKit/QMUIComponents/ToastView/*.{h,m}'
      sss.dependency 'QMUIKit/QMUIComponents/QMUIKeyboardManager'
      sss.dependency 'QMUIKit/QMUIComponents/QMUIVisualEffectView'
    end

    ss.subspec 'QMUIStaticTableView' do |sss|
      sss.source_files = 'QMUIKit/QMUIComponents/StaticTableView/*.{h,m}'
      sss.dependency 'QMUIKit/QMUIComponents/QMUITableViewCell'
      sss.dependency 'QMUIKit/QMUIComponents/QMUIMultipleDelegates'
    end

  end

end
