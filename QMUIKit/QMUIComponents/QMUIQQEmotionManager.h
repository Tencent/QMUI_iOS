//
//  QMUIQQEmotionManager.h
//  qmui
//
//  Created by MoLice on 16/9/8.
//  Copyright © 2016年 QMUI Team. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "QMUIEmotionView.h"

/**
 *  提供一个QQ表情面板，能为绑定的`UITextField`或`UITextView`提供表情的相关功能，包括点击表情输入对应的表情名字、点击删除按钮删除表情。由于表情的插入、删除都会受当前输入框的光标所在位置的影响，所以请在适当的时机更新`selectedRangeForBoundTextInput`的值，具体情况请查看属性的注释。
 *  @warning 由于QQ表情图片较多（文件大小约400K），因此表情图片被以bundle的形式存放在
 *  @warning 一个`QMUIQQEmotionManager`无法同时绑定`boundTextField`和`boundTextView`，在两者都绑定的情况下，优先使用`boundTextField`。
 *  @warning 由于`QMUIQQEmotionManager`里面多个地方会调用`boundTextView.text`，而`setText:`并不会触发`UITextViewDelegate`的`textViewDidChange:`或`UITextViewTextDidChangeNotification`，从而在刷新表情面板里的发送按钮的enabled状态时可能不及时，所以`QMUIQQEmotionManager`要求绑定的`QMUITextView`必须打开`shouldResponseToProgrammaticallyTextChanges`属性
 */
@interface QMUIQQEmotionManager : NSObject

/// 要绑定的UITextField
@property(nonatomic, weak) UITextField *boundTextField;

/// 要绑定的UITextView
@property(nonatomic, weak) UITextView *boundTextView;

/**
 *  `selectedRangeForBoundTextInput`决定了表情将会被插入（删除）的位置，因此使用控件的时候需要及时更新它。
 *
 *  通常用到的更新时机包括：
 *  - 降下键盘显示QQ表情面板之前（调用resignFirstResponder、endEditing:之前）
 *  - <UITextViewDelegate>的`textViewDidChangeSelection:`回调里
 *  - 输入框里的文字发生变化时，例如点了发送按钮后输入框文字会被清空，此时要重置`selectedRangeForBoundTextInput`为0
 */
@property(nonatomic, assign) NSRange selectedRangeForBoundTextInput;

/**
 *  显示QQ表情的表情面板，已被设置了默认的`didSelectEmotionBlock`和`didSelectDeleteButtonBlock`，在`QMUIQQEmotionManager`初始化完后，即可将`emotionView`添加到界面上。
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

/**
 *  QQ表情的数组，会做缓存，图片只会加载一次
 */
+ (NSArray<QMUIEmotion *> *)emotionsForQQ;
@end
