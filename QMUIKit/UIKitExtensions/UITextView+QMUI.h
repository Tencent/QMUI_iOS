/**
 * Tencent is pleased to support the open source community by making QMUI_iOS available.
 * Copyright (C) 2016-2021 THL A29 Limited, a Tencent company. All rights reserved.
 * Licensed under the MIT License (the "License"); you may not use this file except in compliance with the License. You may obtain a copy of the License at
 * http://opensource.org/licenses/MIT
 * Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.
 */

//
//  UITextView+QMUI.h
//  qmui
//
//  Created by QMUI Team on 2017/3/29.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UITextView (QMUI)


/**
 *  UITextView 只有 selectedTextRange 属性（在<UITextInput>协议里定义），这里拓展了一个方法可以将 UITextRange 类型的 selectedTextRange 转换为 NSRange 类型的 selectedRange
 */
@property(nonatomic, assign, readonly) NSRange qmui_selectedRange;

/**
 *  convert UITextRange to NSRange, for example, [self qmui_convertNSRangeFromUITextRange:self.markedTextRange]
 */
- (NSRange)qmui_convertNSRangeFromUITextRange:(UITextRange *)textRange;

/**
 *  convert NSRange to UITextRange
 *  @return return nil if range is invalidate.
 */
- (nullable UITextRange *)qmui_convertUITextRangeFromNSRange:(NSRange)range;

/**
 *  设置 text 会让 selectedTextRange 跳到最后一个字符，导致在中间修改文字后光标会跳到末尾，所以设置前要保存一下，设置后恢复过来
 */
- (void)qmui_setTextKeepingSelectedRange:(NSString *)text;

/**
 *  设置 attributedText 会让 selectedTextRange 跳到最后一个字符，导致在中间修改文字后光标会跳到末尾，所以设置前要保存一下，设置后恢复过来
 */
- (void)qmui_setAttributedTextKeepingSelectedRange:(NSAttributedString *)attributedText;

/**
 [UITextView scrollRangeToVisible:] 并不会考虑 textContainerInset.bottom，所以使用这个方法来代替

 @param range 要滚动到的文字区域，如果 range 非法则什么都不做
 */
- (void)qmui_scrollRangeToVisible:(NSRange)range;

/**
 * 将光标滚到可视区域
 */
- (void)qmui_scrollCaretVisibleAnimated:(BOOL)animated;

@end

NS_ASSUME_NONNULL_END
