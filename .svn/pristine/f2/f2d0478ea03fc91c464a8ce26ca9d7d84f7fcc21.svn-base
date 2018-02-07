//
//  QMUIQQEmotionManager.m
//  qmui
//
//  Created by MoLice on 16/9/8.
//  Copyright © 2016年 QMUI Team. All rights reserved.
//

#import "QMUIQQEmotionManager.h"
#import "QMUIHelper.h"
#import "NSString+QMUI.h"

NSString *const QQEmotionString = @"0-[微笑];1-[撇嘴];2-[色];3-[发呆];4-[得意];5-[流泪];6-[害羞];7-[闭嘴];8-[睡];9-[大哭];10-[尴尬];11-[发怒];12-[调皮];13-[呲牙];14-[惊讶];15-[难过];16-[酷];17-[冷汗];18-[抓狂];19-[吐];20-[偷笑];21-[可爱];22-[白眼];23-[傲慢];24-[饥饿];25-[困];26-[惊恐];27-[流汗];28-[憨笑];29-[大兵];30-[奋斗];31-[咒骂];32-[疑问];33-[嘘];34-[晕];35-[折磨];36-[衰];37-[骷髅];38-[敲打];39-[再见];40-[擦汗];41-[抠鼻];42-[鼓掌];43-[糗大了];44-[坏笑];45-[左哼哼];46-[右哼哼];47-[哈欠];48-[鄙视];49-[委屈];50-[快哭了];51-[阴险];52-[亲亲];53-[吓];54-[可怜];55-[菜刀];56-[西瓜];57-[啤酒];58-[篮球];59-[乒乓];60-[咖啡];61-[饭];62-[猪头];63-[玫瑰];64-[凋谢];65-[示爱];66-[爱心];67-[心碎];68-[蛋糕];69-[闪电];70-[炸弹];71-[刀];72-[足球];73-[瓢虫];74-[便便];75-[月亮];76-[太阳];77-[礼物];78-[拥抱];79-[强];80-[弱];81-[握手];82-[胜利];83-[抱拳];84-[勾引];85-[拳头];86-[差劲];87-[爱你];88-[NO];89-[OK];90-[爱情];91-[飞吻];92-[跳跳];93-[发抖];94-[怄火];95-[转圈];96-[磕头];97-[回头];98-[跳绳];99-[挥手];100-[激动];101-[街舞];102-[献吻];103-[左太极];104-[右太极];105-[嘿哈];106-[捂脸];107-[奸笑];108-[机智];109-[皱眉];110-[耶];111-[红包];112-[鸡]";

static NSArray<QMUIEmotion *> *QQEmotionArray;

@protocol QMUIQQEmotionInputViewProtocol <UITextInput>

@property(nonatomic, copy) NSString *text;
@property(nonatomic, assign, readonly) NSRange selectedRange;
@end

@implementation QMUIQQEmotionManager

- (instancetype)init {
    self = [super init];
    if (self) {
        _emotionView = [[QMUIEmotionView alloc] init];
        self.emotionView.emotions = [QMUIQQEmotionManager emotionsForQQ];
        __weak QMUIQQEmotionManager *weakSelf = self;
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
                selectedRange = NSMakeRange(inputText.length, 0);
            }
            weakSelf.selectedRangeForBoundTextInput = selectedRange;
        };
        self.emotionView.didSelectDeleteButtonBlock = ^{
            [weakSelf deleteEmotionDisplayNameAtCurrentSelectedRangeForce:YES];
        };
    }
    return self;
}

- (UIView<QMUIQQEmotionInputViewProtocol> *)boundInputView {
    if (self.boundTextField) {
        return (UIView<QMUIQQEmotionInputViewProtocol> *)self.boundTextField;
    } else if (self.boundTextView) {
        return (UIView<QMUIQQEmotionInputViewProtocol> *)self.boundTextView;
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
    NSInteger emotionDisplayNameMinimumLength = 3;// QQ表情里的最短displayName的长度
    NSInteger lengthForStringBeforeSelectedRange = selectedRange.location;
    NSString *lastCharacterBeforeSelectedRange = [text substringWithRange:NSMakeRange(selectedRange.location - 1, 1)];
    if ([lastCharacterBeforeSelectedRange isEqualToString:@"]"] && lengthForStringBeforeSelectedRange >= emotionDisplayNameMinimumLength) {
        NSInteger beginIndex = lengthForStringBeforeSelectedRange - (emotionDisplayNameMinimumLength - 1);// 从"]"之前的第n个字符开始查找
        NSInteger endIndex = MAX(0, lengthForStringBeforeSelectedRange - 5);// 直到"]"之前的第n个字符结束查找，这里写5只是简单的限定，这个数字只要比所有QQ表情的displayName长度长就行了
        for (NSInteger i = beginIndex; i >= endIndex; i --) {
            NSString *checkingCharacter = [text substringWithRange:NSMakeRange(i, 1)];
            if ([checkingCharacter isEqualToString:@"]"]) {
                // 查找过程中还没遇到"["就已经遇到"]"了，说明是非法的表情字符串，所以直接终止
                break;
            }
            
            if ([checkingCharacter isEqualToString:@"["]) {
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

+ (UIImage *)imageForQQEmotionWithIdentifier:(NSString *)identifier {
    return [QMUIHelper imageInBundle:[QMUIHelper resourcesBundleWithName:QMUIResourcesQQEmotionBundleName] withName:identifier];
}

+ (NSArray<QMUIEmotion *> *)emotionsForQQ {
    if (QQEmotionArray) {
        return QQEmotionArray;
    }
    
    NSMutableArray<QMUIEmotion *> *emotions = [[NSMutableArray alloc] init];
    NSArray<NSString *> *emotionStringArray = [QQEmotionString componentsSeparatedByString:@";"];
    for (NSString *emotionString in emotionStringArray) {
        NSArray<NSString *> *emotionItem = [emotionString componentsSeparatedByString:@"-"];
        NSString *identifier = [NSString stringWithFormat:@"smiley_%@", emotionItem.firstObject];
        QMUIEmotion *emotion = [QMUIEmotion emotionWithIdentifier:identifier displayName:emotionItem.lastObject];
        [emotions addObject:emotion];
    }
    
    QQEmotionArray = [NSArray arrayWithArray:emotions];
    [self asyncLoadImages:emotions];
    return QQEmotionArray;
}

// 在子线程预加载
+ (void)asyncLoadImages:(NSArray<QMUIEmotion *> *)emotions {
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        for (QMUIEmotion *e in emotions) {
            [e image];
        }
    });
}

@end
