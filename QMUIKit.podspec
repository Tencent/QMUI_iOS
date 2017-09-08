Pod::Spec.new do |s|
  s.name             = "QMUIKit"
  s.version          = "2.0.0"
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

  s.platform         = :ios, '7.0'
  s.frameworks       = 'Foundation', 'UIKit', 'CoreGraphics', 'Photos'
  s.preserve_paths   = 'QMUIConfigurationTemplate/*'
  s.resource         = 'QMUIKit/**/*.bundle'
  s.source_files     = 'QMUIKit/QMUIKit.h'

  s.subspec 'QMUICore' do |sss|
    sss.source_files = 'QMUIKit/QMUIKit.h', 'QMUIKit/UICore', 'QMUIKit/UIKitExtensions'
  end

  s.subspec 'QMUIMainFrame' do |sss|
    sss.source_files = 'QMUIKit/UIMainFrame'
    sss.dependency 'QMUIKit/QMUICore'
    sss.dependency 'QMUIKit/QMUIComponents/QMUINavigationTitleView'
    sss.dependency 'QMUIKit/QMUIComponents/QMUITableView'
    sss.dependency 'QMUIKit/QMUIComponents/QMUIEmptyView'
    sss.dependency 'QMUIKit/QMUIComponents/QMUILabel'
    sss.dependency 'QMUIKit/QMUIComponents/QMUIKeyboardManager'
  end

  s.subspec 'QMUIComponents' do |ss|

    ss.dependency 'QMUIKit/QMUICore'

    ss.subspec 'QMUINavigationTitleView' do |sss|
      sss.source_files = 'QMUIKit/UIComponents/QMUINavigationTitleView.{h,m}'
      sss.dependency 'QMUIKit/QMUIComponents/QMUIButton'
    end

    ss.subspec 'QMUIButton' do |sss|
      sss.source_files = 'QMUIKit/UIComponents/QMUIButton.{h,m}'
    end

    ss.subspec 'QMUITableView' do |sss|
      sss.source_files = 'QMUIKit/UIComponents/QMUITableView.{h,m}'
      sss.dependency 'QMUIKit/QMUIComponents/QMUITableViewProtocols'
    end

    ss.subspec 'QMUITableViewProtocols' do |sss|
      sss.source_files = 'QMUIKit/UIComponents/QMUITableViewProtocols.{h,m}'
    end

    ss.subspec 'QMUIEmptyView' do |sss|
      sss.source_files = 'QMUIKit/UIComponents/QMUIEmptyView.{h,m}'
    end

    ss.subspec 'QMUILabel' do |sss|
      sss.source_files = 'QMUIKit/UIComponents/QMUILabel.{h,m}'
    end

    ss.subspec 'QMUIKeyboardManager' do |sss|
      sss.source_files = 'QMUIKit/UIComponents/QMUIKeyboardManager.{h,m}'
    end

    # 从这里开始就是非必须的组件
    
    ss.subspec 'QMUIAlertController' do |sss|
      sss.source_files = 'QMUIKit/UIComponents/QMUIAlertController.{h,m}'
      sss.dependency 'QMUIKit/QMUIComponents/QMUIModalPresentationViewController'
			sss.dependency 'QMUIKit/QMUIComponents/QMUIButton'
			sss.dependency 'QMUIKit/QMUIComponents/QMUITextField'
    end

    ss.subspec 'QMUICellHeightCache' do |sss|
      sss.source_files = 'QMUIKit/UIComponents/QMUICellHeightCache.{h,m}'
      sss.dependency 'QMUIKit/QMUIComponents/QMUITableViewProtocols'
    end

    ss.subspec 'QMUICollectionViewPagingLayout' do |sss|
      sss.source_files = 'QMUIKit/UIComponents/QMUICollectionViewPagingLayout.{h,m}'
    end

    ss.subspec 'QMUIDialogViewController' do |sss|
      sss.source_files = 'QMUIKit/UIComponents/QMUIDialogViewController.{h,m}'
      sss.dependency 'QMUIKit/QMUIMainFrame'
      sss.dependency 'QMUIKit/QMUIComponents/QMUIModalPresentationViewController'
			sss.dependency 'QMUIKit/QMUIComponents/QMUITableView'
			sss.dependency 'QMUIKit/QMUIComponents/QMUIButton'
			sss.dependency 'QMUIKit/QMUIComponents/QMUITextField'
			sss.dependency 'QMUIKit/QMUIComponents/QMUITableViewCell'
			sss.dependency 'QMUIKit/QMUIComponents/QMUINavigationTitleView'
    end

    ss.subspec 'QMUIEmotionView' do |sss|
      sss.source_files = 'QMUIKit/UIComponents/QMUIEmotionView.{h,m}'
      sss.dependency 'QMUIKit/QMUIComponents/QMUIButton'
    end

    ss.subspec 'QMUIFloatLayoutView' do |sss|
      sss.source_files = 'QMUIKit/UIComponents/QMUIFloatLayoutView.{h,m}'
    end

    ss.subspec 'QMUIGridView' do |sss|
      sss.source_files = 'QMUIKit/UIComponents/QMUIGridView.{h,m}'
    end

    ss.subspec 'QMUIImagePreviewView' do |sss|
      sss.source_files = 'QMUIKit/UIComponents/QMUIImagePreviewView.{h,m}'
      sss.dependency 'QMUIKit/QMUIComponents/QMUIZoomImageView'
			sss.dependency 'QMUIKit/QMUIComponents/QMUICollectionViewPagingLayout'
			sss.dependency 'QMUIKit/QMUIComponents/QMUIEmptyView'
    end

    ss.subspec 'QMUIImagePreviewViewController' do |sss|
      sss.source_files = 'QMUIKit/UIComponents/QMUIImagePreviewViewController.{h,m}'
      sss.dependency 'QMUIKit/QMUIMainFrame'
      sss.dependency 'QMUIKit/QMUIComponents/QMUIImagePreviewView'
    end

    ss.subspec 'QMUIMarqueeLabel' do |sss|
      sss.source_files = 'QMUIKit/UIComponents/QMUIMarqueeLabel.{h,m}'
    end

    ss.subspec 'QMUIModalPresentationViewController' do |sss|
      sss.source_files = 'QMUIKit/UIComponents/QMUIModalPresentationViewController.{h,m}'
    end

    ss.subspec 'QMUIMoreOperationController' do |sss|
      sss.source_files = 'QMUIKit/UIComponents/QMUIMoreOperationController.{h,m}'
      sss.dependency 'QMUIKit/QMUIComponents/QMUIModalPresentationViewController'
			sss.dependency 'QMUIKit/QMUIComponents/QMUIButton'
    end

    ss.subspec 'QMUIOrderedDictionary' do |sss|
      sss.source_files = 'QMUIKit/UIComponents/QMUIOrderedDictionary.{h,m}'
    end

    ss.subspec 'QMUIPieProgressView' do |sss|
      sss.source_files = 'QMUIKit/UIComponents/QMUIPieProgressView.{h,m}'
    end

    ss.subspec 'QMUIPopupContainerView' do |sss|
      sss.source_files = 'QMUIKit/UIComponents/QMUIPopupContainerView.{h,m}'
      sss.dependency 'QMUIKit/QMUIMainFrame'
    end

    ss.subspec 'QMUIPopupMenuView' do |sss|
      sss.source_files = 'QMUIKit/UIComponents/QMUIPopupMenuView.{h,m}'
      sss.dependency 'QMUIKit/QMUIComponents/QMUIButton'
      sss.dependency 'QMUIKit/QMUIComponents/QMUIPopupContainerView'
    end

    ss.subspec 'QMUIQQEmotionManager' do |sss|
      sss.source_files = 'QMUIKit/UIComponents/QMUIQQEmotionManager.{h,m}'
      sss.dependency 'QMUIKit/QMUIComponents/QMUIEmotionView'
    end

    ss.subspec 'QMUISearchBar' do |sss|
      sss.source_files = 'QMUIKit/UIComponents/QMUISearchBar.{h,m}'
    end

    ss.subspec 'QMUISearchController' do |sss|
      sss.source_files = 'QMUIKit/UIComponents/QMUISearchController.{h,m}'
      sss.dependency 'QMUIKit/QMUIMainFrame'
      sss.dependency 'QMUIKit/QMUIComponents/QMUISearchBar'
			sss.dependency 'QMUIKit/QMUIComponents/QMUIEmptyView'
    end

    ss.subspec 'QMUISegmentedControl' do |sss|
      sss.source_files = 'QMUIKit/UIComponents/QMUISegmentedControl.{h,m}'
    end

    ss.subspec 'QMUISlider' do |sss|
      sss.source_files = 'QMUIKit/UIComponents/QMUISlider.{h,m}'
    end

    ss.subspec 'QMUITableViewCell' do |sss|
      sss.source_files = 'QMUIKit/UIComponents/QMUITableViewCell.{h,m}'
      sss.dependency 'QMUIKit/QMUIComponents/QMUIButton'
    end

    ss.subspec 'QMUITestView' do |sss|
      sss.source_files = 'QMUIKit/UIComponents/QMUITestView.{h,m}'
    end

    ss.subspec 'QMUITextField' do |sss|
      sss.source_files = 'QMUIKit/UIComponents/QMUITextField.{h,m}'
    end

    ss.subspec 'QMUITextView' do |sss|
      sss.source_files = 'QMUIKit/UIComponents/QMUITextView.{h,m}'
      sss.dependency 'QMUIKit/QMUIComponents/QMUILabel'
    end

    ss.subspec 'QMUITips' do |sss|
      sss.source_files = 'QMUIKit/UIComponents/QMUITips.{h,m}'
      sss.dependency 'QMUIKit/QMUIComponents/QMUIToastView'
    end

    ss.subspec 'QMUIVisualEffectView' do |sss|
      sss.source_files = 'QMUIKit/UIComponents/QMUIVisualEffectView.{h,m}'
    end

    ss.subspec 'QMUIZoomImageView' do |sss|
      sss.source_files = 'QMUIKit/UIComponents/QMUIZoomImageView.{h,m}'
      sss.dependency 'QMUIKit/QMUIComponents/QMUIEmptyView'
			sss.dependency 'QMUIKit/QMUIComponents/QMUIButton'
			sss.dependency 'QMUIKit/QMUIComponents/QMUISlider'
    end

    ss.subspec 'QMUIAssetLibrary' do |sss|
      sss.source_files = 'QMUIKit/UIComponents/AssetLibrary/*.{h,m}'
    end

    ss.subspec 'QMUIImagePickerLibrary' do |sss|
      sss.source_files = 'QMUIKit/UIComponents/ImagePickerLibrary/*.{h,m}'
      sss.dependency 'QMUIKit/QMUIMainFrame'
      sss.dependency 'QMUIKit/QMUIComponents/QMUIImagePreviewViewController'
      sss.dependency 'QMUIKit/QMUIComponents/QMUITableViewCell'
      sss.dependency 'QMUIKit/QMUIComponents/QMUIButton'
      sss.dependency 'QMUIKit/QMUIComponents/QMUIAssetLibrary'
      sss.dependency 'QMUIKit/QMUIComponents/QMUIZoomImageView'
      sss.dependency 'QMUIKit/QMUIComponents/QMUIPieProgressView'
      sss.dependency 'QMUIKit/QMUIComponents/QMUIAlertController'
      sss.dependency 'QMUIKit/QMUIComponents/QMUIEmptyView'
    end

    ss.subspec 'NavigationBarTransition' do |sss|
      sss.source_files = 'QMUIKit/UIComponents/NavigationBarTransition/*.{h,m}'
      sss.dependency 'QMUIKit/QMUIMainFrame'
      sss.dependency 'QMUIKit/QMUIComponents/QMUINavigationTitleView'
    end

    ss.subspec 'QMUIToastView' do |sss|
      sss.source_files = 'QMUIKit/UIComponents/ToastView/*.{h,m}'
    end

    ss.subspec 'QMUIStaticTableView' do |sss|
      sss.source_files = 'QMUIKit/UIComponents/StaticTableView/*.{h,m}'
      sss.dependency 'QMUIKit/QMUIComponents/QMUITableViewCell'
    end

  end

end
