Pod::Spec.new do |s|
  s.name             = "QMUIKit"
  s.version          = "2.4.0"
  s.summary          = "致力于提高项目 UI 开发效率的解决方案"
  s.description      = <<-DESC
                       QMUI iOS 是一个致力于提高项目 UI 开发效率的解决方案，其设计目的是用于辅助快速搭建一个具备基本设计还原效果的 iOS 项目，同时利用自身提供的丰富控件及兼容处理， 让开发者能专注于业务需求而无需耗费精力在基础代码的设计上。不管是新项目的创建，或是已有项目的维护，均可使开发效率和项目质量得到大幅度提升。
                       DESC
  s.homepage         = "http://qmuiteam.com/ios"
  s.license          = 'MIT'
  s.author           = {"qmuiteam" => "qmuiteam@qq.com"}
  s.source           = {:git => "https://github.com/QMUI/QMUI_iOS.git", :tag => s.version.to_s}
  s.social_media_url = 'https://github.com/QMUI/QMUI_iOS'
  s.requires_arc     = true
  s.documentation_url = 'http://qmuiteam.com/ios/page/document.html'
  s.screenshot       = 'https://cloud.githubusercontent.com/assets/1190261/26751376/63f96538-486a-11e7-81cf-5bc83a945207.png'

  s.platform         = :ios, '8.0'
  s.frameworks       = 'Foundation', 'UIKit', 'CoreGraphics', 'Photos'
  s.preserve_paths   = 'QMUIConfigurationTemplate/*'
  s.source_files     = 'QMUIKit/QMUIKit.h'

  s.subspec 'QMUICore' do |ss|
    ss.source_files = 'QMUIKit/QMUIKit.h', 'QMUIKit/QMUICore', 'QMUIKit/UIKitExtensions'
  end

  s.subspec 'QMUIResources' do |ss|
    ss.resource = 'QMUIKit/QMUIResources/*.bundle'
  end

  s.subspec 'QMUIMainFrame' do |ss|
    ss.source_files = 'QMUIKit/QMUIMainFrame'
    ss.dependency 'QMUIKit/QMUICore'
    ss.dependency 'QMUIKit/QMUIComponents/QMUINavigationTitleView'
    ss.dependency 'QMUIKit/QMUIComponents/QMUITableView'
    ss.dependency 'QMUIKit/QMUIComponents/QMUITableViewHeaderFooterView'
    ss.dependency 'QMUIKit/QMUIComponents/QMUIEmptyView'
    ss.dependency 'QMUIKit/QMUIComponents/QMUIKeyboardManager'
  end

  s.subspec 'QMUIComponents' do |ss|

    ss.dependency 'QMUIKit/QMUICore'

    ss.subspec 'QMUINavigationTitleView' do |sss|
      sss.source_files = 'QMUIKit/QMUIComponents/QMUINavigationTitleView.{h,m}'
      sss.dependency 'QMUIKit/QMUIComponents/QMUIButton'
    end

    ss.subspec 'QMUIButton' do |sss|
      sss.source_files = 'QMUIKit/QMUIComponents/QMUIButton.{h,m}'
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
    end

    ss.subspec 'QMUILabel' do |sss|
      sss.source_files = 'QMUIKit/QMUIComponents/QMUILabel.{h,m}'
    end

    ss.subspec 'QMUIKeyboardManager' do |sss|
      sss.source_files = 'QMUIKit/QMUIComponents/QMUIKeyboardManager.{h,m}'
    end

    # 从这里开始就是非必须的组件
    
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
      sss.source_files = 'QMUIKit/QMUIComponents/QMUIImagePreviewView.{h,m}'
      sss.dependency 'QMUIKit/QMUIComponents/QMUIZoomImageView'
			sss.dependency 'QMUIKit/QMUIComponents/QMUICollectionViewPagingLayout'
			sss.dependency 'QMUIKit/QMUIComponents/QMUIEmptyView'
			sss.dependency 'QMUIKit/QMUIComponents/QMUIPieProgressView'
			sss.dependency 'QMUIKit/QMUIComponents/QMUIButton'
      sss.dependency 'QMUIKit/QMUIComponents/QMUILog'
    end

    ss.subspec 'QMUIImagePreviewViewController' do |sss|
      sss.source_files = 'QMUIKit/QMUIComponents/QMUIImagePreviewViewController.{h,m}'
      sss.dependency 'QMUIKit/QMUIMainFrame'
      sss.dependency 'QMUIKit/QMUIComponents/QMUIImagePreviewView'
    end

    ss.subspec 'QMUIMarqueeLabel' do |sss|
      sss.source_files = 'QMUIKit/QMUIComponents/QMUIMarqueeLabel.{h,m}'
    end

    ss.subspec 'QMUIModalPresentationViewController' do |sss|
      sss.source_files = 'QMUIKit/QMUIComponents/QMUIModalPresentationViewController.{h,m}'
    end

    ss.subspec 'QMUIMoreOperationController' do |sss|
      sss.source_files = 'QMUIKit/QMUIComponents/QMUIMoreOperationController.{h,m}'
      sss.dependency 'QMUIKit/QMUIComponents/QMUIModalPresentationViewController'
			sss.dependency 'QMUIKit/QMUIComponents/QMUIButton'
      sss.dependency 'QMUIKit/QMUIComponents/QMUILog'
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
      sss.source_files = 'QMUIKit/QMUIComponents/QMUIPopupMenuView.{h,m}'
      sss.dependency 'QMUIKit/QMUIComponents/QMUIButton'
      sss.dependency 'QMUIKit/QMUIComponents/QMUIPopupContainerView'
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
    end

    ss.subspec 'QMUITextView' do |sss|
      sss.source_files = 'QMUIKit/QMUIComponents/QMUITextView.{h,m}'
      sss.dependency 'QMUIKit/QMUIComponents/QMUILabel'
    end

    ss.subspec 'QMUITips' do |sss|
      sss.source_files = 'QMUIKit/QMUIComponents/QMUITips.{h,m}'
      sss.dependency 'QMUIKit/QMUIComponents/QMUIToastView'
      sss.dependency 'QMUIKit/QMUIResources'
    end

    ss.subspec 'QMUIVisualEffectView' do |sss|
      sss.source_files = 'QMUIKit/QMUIComponents/QMUIVisualEffectView.{h,m}'
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
      sss.dependency 'QMUIKit/QMUIComponents/QMUILog'
    end

    ss.subspec 'QMUIImagePickerLibrary' do |sss|
      sss.source_files = 'QMUIKit/QMUIComponents/ImagePickerLibrary/*.{h,m}'
      sss.dependency 'QMUIKit/QMUIMainFrame'
      sss.dependency 'QMUIKit/QMUIResources'
      sss.dependency 'QMUIKit/QMUIComponents/QMUIImagePreviewViewController'
      sss.dependency 'QMUIKit/QMUIComponents/QMUITableViewCell'
      sss.dependency 'QMUIKit/QMUIComponents/QMUIButton'
      sss.dependency 'QMUIKit/QMUIComponents/QMUIAssetLibrary'
      sss.dependency 'QMUIKit/QMUIComponents/QMUIZoomImageView'
      sss.dependency 'QMUIKit/QMUIComponents/QMUIAlertController'
      sss.dependency 'QMUIKit/QMUIComponents/QMUIEmptyView'
      sss.dependency 'QMUIKit/QMUIComponents/QMUILog'
    end

    ss.subspec 'QMUILog' do |sss|
      sss.source_files = 'QMUIKit/QMUIComponents/Log/*.{h,m}'
      sss.dependency 'QMUIKit/QMUIMainFrame'
      sss.dependency 'QMUIKit/QMUIComponents/QMUIStaticTableView'
      sss.dependency 'QMUIKit/QMUIComponents/QMUITableView'
      sss.dependency 'QMUIKit/QMUIComponents/QMUICellHeightCache'
      sss.dependency 'QMUIKit/QMUIComponents/QMUIPopupMenuView'
      sss.dependency 'QMUIKit/QMUIComponents/QMUISearchController'
    end

    ss.subspec 'NavigationBarTransition' do |sss|
      sss.source_files = 'QMUIKit/QMUIComponents/NavigationBarTransition/*.{h,m}'
      sss.dependency 'QMUIKit/QMUIMainFrame'
      sss.dependency 'QMUIKit/QMUIComponents/QMUINavigationTitleView'
    end

    ss.subspec 'QMUIToastView' do |sss|
      sss.source_files = 'QMUIKit/QMUIComponents/ToastView/*.{h,m}'
      sss.dependency 'QMUIKit/QMUIComponents/QMUIKeyboardManager'
    end

    ss.subspec 'QMUIStaticTableView' do |sss|
      sss.source_files = 'QMUIKit/QMUIComponents/StaticTableView/*.{h,m}'
      sss.dependency 'QMUIKit/QMUIComponents/QMUITableViewCell'
    end

  end

end
