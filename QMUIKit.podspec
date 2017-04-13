Pod::Spec.new do |s|
  s.name             = "QMUIKit"
  s.version          = "1.5.0"
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
  s.screenshot        = 'https://raw.githubusercontent.com/QMUI/QMUI_iOS/master/logo_2x.png'

  s.platform         = :ios, '7.0'
  s.source_files     = 'QMUIKit/**/*.{h,m}'
  s.preserve_paths   = 'QMUIConfigurationTemplate/*'
  s.resource         = 'QMUIKit/**/*.bundle'

  s.frameworks       = 'Foundation', 'UIKit', 'CoreGraphics', 'Photos'

end
