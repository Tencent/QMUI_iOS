
<p align="center">
  <img src="https://user-images.githubusercontent.com/1190261/43357675-f18b3096-92b7-11e8-807e-809717ca504a.png" width="220" alt="Banner" />
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

## 支持iOS版本

从 3.0.0 开始，QMUI 支持 iOS 9+，2.x 版本支持 iOS 8+。

## 使用方法

请查看官网的[开始使用](http://qmuiteam.com/ios/page/start.html)。

## 代码示例

请下载 QMUI Demo：[https://github.com/QMUI/QMUIDemo_iOS](https://github.com/QMUI/QMUIDemo_iOS)。

![Launch](https://user-images.githubusercontent.com/1190261/49869307-041fdf00-fe4b-11e8-8f77-8007317e71c6.gif)
![QMUITheme](https://user-images.githubusercontent.com/1190261/66378391-ecbb6f00-e9e5-11e9-9d47-8456347ba886.gif)
![QMUIPopup](https://user-images.githubusercontent.com/1190261/49869336-169a1880-fe4b-11e8-9fab-b3ff8233d562.gif)
![QMUIMarqueeLabel](https://user-images.githubusercontent.com/1190261/49869323-100ba100-fe4b-11e8-947c-92082fb4ddd8.gif)

## 注意事项

- 关于 AutoLayout：通常可以配合 Masonry 等常见的 AutoLayout 框架使用，若遇到不兼容的个案请提 issue。
- 关于 xib / storyboard：现已全面支持。
- 关于 Swift：可以正常使用，如遇到问题请提 issue。
- 关于隐私：从 2.8.0 版本开始，QMUIKit 默认会在 Debug 模式下启动 App 时发送当前 App 的 Bundle Identifier 和 Display Name 给 QMUI 作统计用，Release 下不会发送。你也可以通过配置表的 `SendAnalyticsToQMUITeam` 开关将统计关闭。统计的代码在 [QMUIConfiguration.m:91](https://github.com/Tencent/QMUI_iOS/blob/master/QMUIKit/QMUICore/QMUIConfiguration.m#L91-L101)，可直接查看。

## 设计资源

QMUIKit 框架内自带图片资源的组件主要是 QMUIConsole、QMUIEmotion、QMUIImagePicker、QMUITips，另外作为 Sample Code 使用的 QMUI Demo 是另一个独立的项目，它拥有自己另外一套设计。

QMUIKit 和 QMUI Demo 的 Sketch 设计稿均存放在 [https://github.com/QMUI/QMUIDemo_Design](https://github.com/QMUI/QMUIDemo_Design)。

## 其他

建议搭配 QMUI 专用的 Code Snippets 及文件模板使用：
1. [QMUI_iOS_CodeSnippets](https://github.com/QMUI/QMUI_iOS_CodeSnippets)
2. [QMUI_iOS_Templates](https://github.com/QMUI/QMUI_iOS_Templates)
