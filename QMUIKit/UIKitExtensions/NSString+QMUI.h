/**
 * Tencent is pleased to support the open source community by making QMUI_iOS available.
 * Copyright (C) 2016-2021 THL A29 Limited, a Tencent company. All rights reserved.
 * Licensed under the MIT License (the "License"); you may not use this file except in compliance with the License. You may obtain a copy of the License at
 * http://opensource.org/licenses/MIT
 * Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.
 */

//
//  NSString+QMUI.h
//  qmui
//
//  Created by QMUI Team on 15/7/20.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol QMUIStringProtocol <NSObject>

/**
 *  按照中文 2 个字符、英文 1 个字符的方式来计算文本长度
 */
@property(readonly) NSUInteger qmui_lengthWhenCountingNonASCIICharacterAsTwo;

/**
 *  将字符串从指定的 index 开始裁剪到结尾，裁剪时会避免将 emoji 等 "character sequences" 拆散（一个 emoji 表情占用1-4个长度的字符）。
 *
 *  例如对于字符串“😊😞”，它的长度为4，若调用 [string qmui_substringAvoidBreakingUpCharacterSequencesFromIndex:1]，将返回“😊😞”。
 *  若调用系统的 [string substringFromIndex:1]，将返回“?😞”。（?表示乱码，因为第一个 emoji 表情被从中间裁开了）。
 *
 *  @param index 要从哪个 index 开始裁剪文字，如果 countingNonASCIICharacterAsTwo 为 YES，则 index 也要按 YES 的方式来算
 *  @param lessValue 要按小的长度取，还是按大的长度取
 *  @param countingNonASCIICharacterAsTwo 是否按照 英文 1 个字符长度、中文 2 个字符长度的方式来裁剪
 *  @return 裁剪完的字符
 */
- (nullable instancetype)qmui_substringAvoidBreakingUpCharacterSequencesFromIndex:(NSUInteger)index lessValue:(BOOL)lessValue countingNonASCIICharacterAsTwo:(BOOL)countingNonASCIICharacterAsTwo;

/**
 *  相当于 `qmui_substringAvoidBreakingUpCharacterSequencesFromIndex: lessValue:YES` countingNonASCIICharacterAsTwo:NO
 *  @see qmui_substringAvoidBreakingUpCharacterSequencesFromIndex:lessValue:countingNonASCIICharacterAsTwo:
 */
- (nullable instancetype)qmui_substringAvoidBreakingUpCharacterSequencesFromIndex:(NSUInteger)index;

/**
 *  将字符串从开头裁剪到指定的 index，裁剪时会避免将 emoji 等 "character sequences" 拆散（一个 emoji 表情占用1-4个长度的字符）。
 *
 *  例如对于字符串“😊😞”，它的长度为4，若调用 [string qmui_substringAvoidBreakingUpCharacterSequencesToIndex:1 lessValue:NO countingNonASCIICharacterAsTwo:NO]，将返回“😊”。
 *  若调用系统的 [string substringToIndex:1]，将返回“?”。（?表示乱码，因为第一个 emoji 表情被从中间裁开了）。
 *
 *  @param index 要裁剪到哪个 index 为止（不包含该 index，策略与系统的 substringToIndex: 一致），如果 countingNonASCIICharacterAsTwo 为 YES，则 index 也要按 YES 的方式来算
 *  @param lessValue 裁剪时若遇到“character sequences”，是向下取整还是向上取整。
 *  @param countingNonASCIICharacterAsTwo 是否按照 英文 1 个字符长度、中文 2 个字符长度的方式来裁剪
 *  @return 裁剪完的字符
 */
- (nullable instancetype)qmui_substringAvoidBreakingUpCharacterSequencesToIndex:(NSUInteger)index lessValue:(BOOL)lessValue countingNonASCIICharacterAsTwo:(BOOL)countingNonASCIICharacterAsTwo;

/**
 *  相当于 `qmui_substringAvoidBreakingUpCharacterSequencesToIndex:lessValue:YES` countingNonASCIICharacterAsTwo:NO
 *  @see qmui_substringAvoidBreakingUpCharacterSequencesToIndex:lessValue:countingNonASCIICharacterAsTwo:
 */
- (nullable instancetype)qmui_substringAvoidBreakingUpCharacterSequencesToIndex:(NSUInteger)index;

/**
 *  将字符串里指定 range 的子字符串裁剪出来，会避免将 emoji 等 "character sequences" 拆散（一个 emoji 表情占用1-4个长度的字符）。
 *
 *  例如对于字符串“😊😞”，它的长度为4，在 lessValue 模式下，裁剪 (0, 1) 得到的是空字符串，裁剪 (0, 2) 得到的是“😊”。
 *  在非 lessValue 模式下，裁剪 (0, 1) 或 (0, 2)，得到的都是“😊”。
 *
 *  @param range 要裁剪的文字位置
 *  @param lessValue 裁剪时若遇到“character sequences”，是向下取整还是向上取整（系统的 rangeOfComposedCharacterSequencesForRange: 会尽量把给定 range 里包含的所有 character sequences 都包含在内，也即 lessValue = NO）。
 *  @param countingNonASCIICharacterAsTwo 是否按照 英文 1 个字符长度、中文 2 个字符长度的方式来裁剪
 *  @return 裁剪完的字符
 */
- (nullable instancetype)qmui_substringAvoidBreakingUpCharacterSequencesWithRange:(NSRange)range lessValue:(BOOL)lessValue countingNonASCIICharacterAsTwo:(BOOL)countingNonASCIICharacterAsTwo;

/**
 *  相当于 `qmui_substringAvoidBreakingUpCharacterSequencesWithRange:lessValue:YES` countingNonASCIICharacterAsTwo:NO
 *  @see qmui_substringAvoidBreakingUpCharacterSequencesWithRange:lessValue:countingNonASCIICharacterAsTwo:
 */
- (nullable instancetype)qmui_substringAvoidBreakingUpCharacterSequencesWithRange:(NSRange)range;

/**
 *  移除指定位置的字符，可兼容emoji表情的情况（一个emoji表情占1-4个length）
 *  @param index 要删除的位置
 */
- (nullable instancetype)qmui_stringByRemoveCharacterAtIndex:(NSUInteger)index;

/**
 *  移除最后一个字符，可兼容emoji表情的情况（一个emoji表情占1-4个length）
 *  @see `qmui_stringByRemoveCharacterAtIndex:`
 */
- (nullable instancetype)qmui_stringByRemoveLastCharacter;

@end

@interface NSString (QMUI)<QMUIStringProtocol>

/// 将字符串按一个一个字符拆成数组，类似 JavaScript 里的 split("")，如果多个空格，则每个空格也会当成一个 item
@property(nullable, readonly, copy) NSArray<NSString *> *qmui_toArray;

/// 将字符串按一个一个字符拆成数组，类似 JavaScript 里的 split("")，但会自动过滤掉空白字符
@property(nullable, readonly, copy) NSArray<NSString *> *qmui_toTrimmedArray;

/// 去掉头尾的空白字符
@property(readonly, copy) NSString *qmui_trim;

/// 去掉整段文字内的所有空白字符（包括换行符）
@property(readonly, copy) NSString *qmui_trimAllWhiteSpace;

/// 将文字中的换行符替换为空格
@property(readonly, copy) NSString *qmui_trimLineBreakCharacter;

/// 把该字符串转换为对应的 md5
@property(readonly, copy) NSString *qmui_md5;

/// 返回一个符合 query value 要求的编码后的字符串，例如&、#、=等字符均会被变为 %xxx 的编码
/// @see `NSCharacterSet (QMUI) qmui_URLUserInputQueryAllowedCharacterSet`
@property(nullable, readonly, copy) NSString *qmui_stringByEncodingUserInputQuery;

/// 把当前文本的第一个字符改为大写，其他的字符保持不变，例如 backgroundView.qmui_capitalizedString -> BackgroundView（系统的 capitalizedString 会变成 Backgroundview）
@property(nullable, readonly, copy) NSString *qmui_capitalizedString;

/**
 * 用正则表达式匹配的方式去除字符串里一些特殊字符，避免UI上的展示问题
 * @link http://www.croton.su/en/uniblock/Diacriticals.html @/link
 */
@property(nullable, readonly, copy) NSString *qmui_removeMagicalChar;

/**
 用正则表达式匹配字符串，将匹配到的第一个结果返回，大小写不敏感

 @param pattern 正则表达式
 @return 匹配到的第一个结果，如果没有匹配成功则返回 nil
 */
- (NSString *)qmui_stringMatchedByPattern:(NSString *)pattern;

/**
 用正则表达式匹配字符串，返回匹配到的第一个结果里的指定分组（由参数 index 指定）。
 例如使用 @"ing([\\d\\.]+)" 表达式匹配字符串 @"string0.05" 并指定参数 index = 1，则返回 @"0.05"。
 @param pattern 正则表达式，可用括号表示分组
 @param index 要返回第几个分组，0表示整个正则表达式匹配到的结果，1表示匹配到的结果里的第1个分组（第1个括号）
 @return 返回匹配到的第一个结果里的指定分组，如果 index 超过总分组数则返回 nil。匹配失败也返回 nil。
 */
- (NSString *)qmui_stringMatchedByPattern:(NSString *)pattern groupIndex:(NSInteger)index;

/**
 用正则表达式匹配字符串，返回匹配到的第一个结果里的指定分组（由参数 name 指定）。
 例如使用 @"ing(?<number>[\\d\\.]+)" 表达式匹配字符串 @"string0.05" 并指定参数 name 为 @"number"，则返回 @"0.05"。
 @param pattern 正则表达式，可用括号表示分组，分组必须用 ?<name> 的语法来为分组命名。
 @param name 要返回的分组名称，可通过 pattern 里的 ?<name> 语法对分组进行命名。
 @return 返回匹配到的第一个结果里的指定分组，如果 name 不存在则返回 nil。匹配失败也返回 nil。
 */
- (NSString *)qmui_stringMatchedByPattern:(NSString *)pattern groupName:(NSString *)name;

/**
 *  用正则表达式匹配字符串并将其替换为指定的另一个字符串，大小写不敏感
 *  @param pattern 正则表达式
 *  @param replacement 要替换为的字符串
 *  @return 最终替换后的完整字符串，如果正则表达式匹配不成功则返回原字符串
 */
- (NSString *)qmui_stringByReplacingPattern:(NSString *)pattern withString:(NSString *)replacement;

/// 把某个十进制数字转换成十六进制的数字的字符串，例如“10”->“A”
+ (NSString *)qmui_hexStringWithInteger:(NSInteger)integer;

/// 把参数列表拼接成一个字符串并返回，相当于用另一种语法来代替 [NSString stringWithFormat:]
+ (NSString *)qmui_stringByConcat:(id)firstArgv, ...;

/**
 * 将秒数转换为同时包含分钟和秒数的格式的字符串，例如 100->"01:40"
 */
+ (NSString *)qmui_timeStringWithMinsAndSecsFromSecs:(double)seconds;

@end

@interface NSString (QMUI_StringFormat)

+ (NSString *)qmui_stringWithNSInteger:(NSInteger)integerValue;
+ (NSString *)qmui_stringWithCGFloat:(CGFloat)floatValue;
+ (NSString *)qmui_stringWithCGFloat:(CGFloat)floatValue decimal:(NSUInteger)decimal;
@end

NS_ASSUME_NONNULL_END
