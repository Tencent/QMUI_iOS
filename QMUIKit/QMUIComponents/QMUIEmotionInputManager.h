/**
 * Tencent is pleased to support the open source community by making QMUI_iOS available.
 * Copyright (C) 2016-2021 THL A29 Limited, a Tencent company. All rights reserved.
 * Licensed under the MIT License (the "License"); you may not use this file except in compliance with the License. You may obtain a copy of the License at
 * http://opensource.org/licenses/MIT
 * Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.
 */

//
//  QMUIEmotionInputManager.h
//  qmui
//
//  Created by QMUI Team on 16/9/8.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@class QMUIEmotionView;

/**
 *  提供一个常见的通用表情面板，能为绑定的`UITextField`或`UITextView`提供表情的相关功能，包括点击表情输入对应的表情名字、点击删除按钮删除表情。
 *  使用方式：
 *  1. 使用 init 方法初始化。
 *  2. 通过 `boundTextField` 或 `boundTextView` 关联一个输入框，建议这些输入框使用 `QMUITextField` 或 `QMUITextView`，原因看下面的 warning。
 *  3. 将所有表情通过 `self.emotionView.emotions` 设置进去，注意这个数组里的所有 `QMUIEmotion` 的 `displayName` 都应该使用左右标识符包裹起来（例如中括号“[]”），并且所有表情的左右标识符都应该保持一致。
 *  4. 将 `self.emotionView` add 到界面上即可。
 *
 *  @warning 一个`QMUIEmotionInputManager`无法同时绑定`boundTextField`和`boundTextView`，在两者都绑定的情况下，优先使用`boundTextField`。
 *  @warning 由于`QMUIEmotionInputManager`里面多个地方会调用`boundTextView.text`，而`setText:`并不会触发`UITextViewDelegate`的`textViewDidChange:`或`UITextViewTextDidChangeNotification`，以及 `UITextField` 的 `UIControlEventEditingChanged` 事件，从而在刷新表情面板里的发送按钮的enabled状态时可能不及时，所以推荐使用 `QMUITextView` 代替 `UITextView`、用 `QMUITextField` 代替 `UITextField`，并确保它们的`shouldResponseToProgrammaticallyTextChanges`属性是 `YES`（默认即为 `YES`）。
 *  @warning 由于表情的插入、删除都会受当前输入框的光标所在位置的影响，所以请在适当的时机更新`selectedRangeForBoundTextInput`的值，具体情况请查看该属性的注释。
 */
@interface QMUIEmotionInputManager : NSObject

/// 要绑定的 UITextField
@property(nonatomic, weak) UITextField *boundTextField;

/// 要绑定的 UITextView
@property(nonatomic, weak) UITextView *boundTextView;

/**
 *  `selectedRangeForBoundTextInput`决定了表情将会被插入（删除）的位置，因此使用控件的时候需要及时更新它。
 *
 *  通常用到的更新时机包括：
 *  - 降下键盘显示表情面板之前（调用resignFirstResponder、endEditing:之前）
 *  - <UITextViewDelegate>的`textViewDidChangeSelection:`回调里
 *  - 输入框里的文字发生变化时，例如点了发送按钮后输入框文字会被清空，此时要重置`selectedRangeForBoundTextInput`为0
 */
@property(nonatomic, assign) NSRange selectedRangeForBoundTextInput;

/**
 *  表情面板，已被设置了默认的`didSelectEmotionBlock`和`didSelectDeleteButtonBlock`，在`QMUIEmotionInputManager`初始化完后，即可将`emotionView`添加到界面上。
 */
@property(nonatomic, strong, readonly) QMUIEmotionView *emotionView;

/**
 *  将当前光标所在位置的表情删除，在调用前请注意更新`selectedRangeForBoundTextInput`
 *  @param forceDelete 当没有删除掉表情的情况下（可能光标前面并不是一个表情字符），要不要强制删掉光标前的字符。YES表示强制删掉，NO表示不删，交给系统键盘处理
 *  @return 表示是否成功删除了文字（如果并不是删除表情，而是删除普通字符，也是返回YES）
 */
- (BOOL)deleteEmotionDisplayNameAtCurrentSelectedRangeForce:(BOOL)forceDelete;

/**
 *  在 `UITextViewDelegate` 的 `textView:shouldChangeTextInRange:replacementText:` 或者 `QMUITextFieldDelegate` 的 `textField:shouldChangeTextInRange:replacementText:` 方法里调用，根据返回值来决定是否应该调用 `deleteEmotionDisplayNameAtCurrentSelectedRangeForce:`

 @param range 要发生变化的文字所在的range
 @param text  要被替换为的文字

 @return 是否会接管键盘的删除按钮事件，`YES` 表示接管，可调用 `deleteEmotionDisplayNameAtCurrentSelectedRangeForce:` 方法，`NO` 表示不可接管，应该使用系统自身的删除事件响应。
 */
- (BOOL)shouldTakeOverControlDeleteKeyWithChangeTextInRange:(NSRange)range replacementText:(NSString *)text;

@end
