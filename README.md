
<p align="center">
  <img src="https://raw.githubusercontent.com/QMUI/QMUI_iOS/master/logo_2x.png" width="220" alt="Banner" />
</p>

# QMUI iOS
QMUI iOS 是一个致力于提高项目 UI 开发效率的解决方案，其设计目的是用于辅助快速搭建一个具备基本设计还原效果的 iOS 项目，同时利用自身提供的丰富控件及兼容处理，
让开发者能专注于业务需求而无需耗费精力在基础代码的设计上。不管是新项目的创建，或是已有项目的维护，均可使开发效率和项目质量得到大幅度提升。

官网：[http://qmuiteam.com/ios](http://qmuiteam.com/ios)

[![QMUI Team Name](https://img.shields.io/badge/Team-QMUI-brightgreen.svg?style=flat)](https://github.com/QMUI "QMUI Team")
[![License](https://img.shields.io/badge/license-MIT-blue.svg?style=flat)](http://opensource.org/licenses/MIT "Feel free to contribute.")

## 功能特性
### 全局 UI 配置

只需要修改一份配置表就可以调整 App 的全局样式，包括颜色、导航栏、输入框、列表等。一处修改，全局生效。

### UIKit 拓展及版本兼容

拓展多个 UIKit 的组件，提供更加丰富的特性和功能，提高开发效率；解决不同 iOS 版本常见的兼容性问题。

### 丰富的 UI 控件

提供丰富且常用的 UI 控件，使用方便灵活，并且支持自定义控件的样式。

### 高效的工具方法及宏

提供高效的工具方法，包括设备信息、动态字体、键盘管理、状态栏管理等，可以解决各种常见场景并大幅度提升开发效率。

## 如何安装
有三种方式可以使用QMUI，分别是：

- 使用CocoaPods
- 使用Carthage
- 将QMUI作为子项目

### 使用 CocoaPods
#### Podfile
```
platform :ios, '7.0'
pod 'QMUIKit', '~>1.1.4'
```
如果你的项目支持 iOS 8+，建议使用QMUI的动态库：

```
platform :ios, '8.0'
use_frameworks!
```
### 使用 Carthage (iOS 8+)

[Carthage](https://github.com/Carthage/Carthage) 是一个比CocoaPods更加轻量的包管理器，如何安装请查考[这里](https://github.com/Carthage/Carthage)。

#### Cartfile
```
github "QMUI/QMUI_iOS" ~>1.1.4
```
### 作为子项目
具体请查看我们的[开始使用](http://qmuiteam.com/ios/page/start.html#qw_downloadForUse)文档。

## 相关文档

接口文档：[http://qmuiteam.com/ios/page/document.html](http://qmuiteam.com/ios/page/document.html)

下载Demo：[https://github.com/QMUI/QMUIDemo_iOS](https://github.com/QMUI/QMUIDemo_iOS)

## 支持iOS版本
QMUI iOS 支持 iOS 7+

## 注意事项
- 关于 AutoLayout：目前暂未支持，考虑到 AutoLayout 的普及性，我们将会尽快支持。
- 关于 xib / storyboard：正在支持中，请关注版本更新。
- 关于 Swift：暂未检查过在 Swift 下使用 QMUI 的问题，如遇到问题可以反馈给我们，我们会尽快兼容。

## 其他
建议搭配 QMUI 专用的 Code Snippets 使用： [https://github.com/QMUI/qmui-ios-codesnippets](https://github.com/QMUI/qmui-ios-codesnippets)
