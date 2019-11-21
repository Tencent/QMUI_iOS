/*****
 * Tencent is pleased to support the open source community by making QMUI_iOS available.
 * Copyright (C) 2016-2019 THL A29 Limited, a Tencent company. All rights reserved.
 * Licensed under the MIT License (the "License"); you may not use this file except in compliance with the License. You may obtain a copy of the License at
 * http://opensource.org/licenses/MIT
 * Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.
 *****/

//
//  QMUIEmotionInputManager.m
//  qmui
//
//  Created by QMUI Team on 16/9/8.
//

#import "QMUIEmotionInputManager.h"
#import "QMUICore.h"
#import "NSString+QMUI.h"
#import "QMUIEmotionView.h"

@protocol QMUIEmotionInputViewProtocol <UITextInput>

@property(nonatomic, copy) NSString *text;
@property(nonatomic, assign, readonly) NSRange selectedRange;
@end

@implementation QMUIEmotionInputManager

- (instancetype)init {
    self = [super init];
    if (self) {
        _emotionView = [[QMUIEmotionView alloc] init];
        __weak QMUIEmotionInputManager *weakSelf = self;
        self.emotionView.didSelectEmotionBlock = ^(NSInteger index, QMUIEmotion *emotion) {
            if (!weakSelf.boundInputView) return;
            
            NSString *inputText = weakSelf.boundInputView.text;
            // 用一个局部变量先保存selectedRangeForBoundTextInput的值，是为了避免在接下来这段代码执行的过程中，外部可能修改了self.selectedRangeForBoundTextInput的值，导致计算错误
            NSRange selectedRange = weakSelf.selectedRangeForBoundTextInput;
            if (selectedRange.location <= inputText.length) {
                // 在输入框文字的中间插入表情
                NSMutableString *mutableText = [NSMutableString stringWithString:inputText ?: @""];
                [mutableText insertString:emotion.displayName atIndex:selectedRange.location];
                weakSelf.boundInputView.text = mutableText;// UITextView setText:会触发textViewDidChangeSelection:，而如果在这个delegate里更新self.selectedRangeForBoundTextInput，就会导致计算错误
                selectedRange = NSMakeRange(selectedRange.location + emotion.displayName.length, 0);
            } else {
                // 在输入框文字的结尾插入表情
                inputText = [inputText stringByAppendingString:emotion.displayName];
                weakSelf.boundInputView.text = inputText;
                selectedRange = NSMakeRange(weakSelf.boundInputView.text.length, 0);// 始终都应该从 boundInputView.text 获取最终的文字，因为可能在 setText: 时受 maximumTextLength 的限制导致文字截断
            }
            weakSelf.selectedRangeForBoundTextInput = selectedRange;
        };
        self.emotionView.didSelectDeleteButtonBlock = ^{
            [weakSelf deleteEmotionDisplayNameAtCurrentSelectedRangeForce:YES];
        };
    }
    return self;
}

- (UIView<QMUIEmotionInputViewProtocol> *)boundInputView {
    if (self.boundTextField) {
        return (UIView<QMUIEmotionInputViewProtocol> *)self.boundTextField;
    } else if (self.boundTextView) {
        return (UIView<QMUIEmotionInputViewProtocol> *)self.boundTextView;
    }
    return nil;
}

- (BOOL)deleteEmotionDisplayNameAtCurrentSelectedRangeForce:(BOOL)forceDelete {
    if (!self.boundInputView) return NO;
    
    NSRange selectedRange = self.selectedRangeForBoundTextInput;
    NSString *text = self.boundInputView.text;
    
    // 没有文字或者光标位置前面没文字
    if (!text.length || NSMaxRange(selectedRange) == 0) {
        return NO;
    }
    
    BOOL hasDeleteEmotionDisplayNameSuccess = NO;
    NSString *exampleEmotionDisplayName = self.emotionView.emotions.firstObject.displayName;
    NSString *emotionDisplayNameLeftSign = exampleEmotionDisplayName ? [exampleEmotionDisplayName substringWithRange:NSMakeRange(0, 1)] : nil;
    NSString *emotionDisplayNameRightSign = exampleEmotionDisplayName ? [exampleEmotionDisplayName substringWithRange:NSMakeRange(exampleEmotionDisplayName.length - 1, 1)] : nil;
    NSInteger emotionDisplayNameMinimumLength = 3;// 表情里的最短displayName的长度，也即“[x]”
    NSInteger lengthForStringBeforeSelectedRange = selectedRange.location;
    NSString *lastCharacterBeforeSelectedRange = [text substringWithRange:NSMakeRange(selectedRange.location - 1, 1)];
    if ([lastCharacterBeforeSelectedRange isEqualToString:emotionDisplayNameRightSign] && lengthForStringBeforeSelectedRange >= emotionDisplayNameMinimumLength) {
        NSInteger beginIndex = lengthForStringBeforeSelectedRange - (emotionDisplayNameMinimumLength - 1);// 从"]"之前的第n个字符开始查找
        NSInteger endIndex = MAX(0, lengthForStringBeforeSelectedRange - 5);// 直到"]"之前的第n个字符结束查找，这里写5只是简单的限定，这个数字只要比所有表情的displayName长度长就行了
        for (NSInteger i = beginIndex; i >= endIndex; i --) {
            NSString *checkingCharacter = [text substringWithRange:NSMakeRange(i, 1)];
            if ([checkingCharacter isEqualToString:emotionDisplayNameRightSign]) {
                // 查找过程中还没遇到"["就已经遇到"]"了，说明是非法的表情字符串，所以直接终止
                break;
            }
            
            if ([checkingCharacter isEqualToString:emotionDisplayNameLeftSign]) {
                NSRange deletingDisplayNameRange = NSMakeRange(i, lengthForStringBeforeSelectedRange - i);
                self.boundInputView.text = [text stringByReplacingCharactersInRange:deletingDisplayNameRange withString:@""];
                self.selectedRangeForBoundTextInput = NSMakeRange(deletingDisplayNameRange.location, 0);
                hasDeleteEmotionDisplayNameSuccess = YES;
                break;
            }
        }
    }
    
    if (hasDeleteEmotionDisplayNameSuccess) {
        return YES;
    }
    
    if (forceDelete) {
        if (NSMaxRange(selectedRange) <= text.length) {
            if (selectedRange.length > 0) {
                // 如果选中区域是一段文字，则删掉这段文字
                self.boundInputView.text = [text stringByReplacingCharactersInRange:selectedRange withString:@""];
                self.selectedRangeForBoundTextInput = NSMakeRange(selectedRange.location, 0);
            } else if (selectedRange.location > 0) {
                // 如果并没有选中一段文字，则删掉光标前一个字符
                NSString *textAfterDelete = [text qmui_stringByRemoveCharacterAtIndex:selectedRange.location - 1];
                self.boundInputView.text = textAfterDelete;
                self.selectedRangeForBoundTextInput = NSMakeRange(selectedRange.location - (text.length - textAfterDelete.length), 0);
            }
        } else {
            // 选中区域超过文字长度了，非法数据，则直接删掉最后一个字符
            self.boundInputView.text = [text qmui_stringByRemoveLastCharacter];
            self.selectedRangeForBoundTextInput = NSMakeRange(self.boundInputView.text.length, 0);
        }
        
        return YES;
    }
    
    return NO;
}

- (BOOL)shouldTakeOverControlDeleteKeyWithChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    BOOL isDeleteKeyPressed = text.length == 0 && self.boundInputView.text.length - 1 == range.location;
    BOOL hasMarkedText = !!self.boundInputView.markedTextRange;
    return isDeleteKeyPressed && !hasMarkedText;
}

@end
