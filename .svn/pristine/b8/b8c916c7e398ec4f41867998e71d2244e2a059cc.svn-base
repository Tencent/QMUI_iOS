//
//  NSString+QMUI.h
//  qmui
//
//  Created by ZhoonChen on 15/7/20.
//  Copyright (c) 2015年 QMUI Team. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreGraphics/CGBase.h>

@interface NSString (QMUI)

/// 判断是否包含某个子字符串
- (BOOL)qmui_includesString:(NSString *)string;

/// 去掉头尾的空白字符
- (NSString *)qmui_trim;

/// 去掉整段文字内的所有空白字符（包括换行符）
- (NSString *)qmui_trimAllWhiteSpace;

/// 将文字中的换行符替换为空格
- (NSString *)qmui_trimLineBreakCharacter;

/// 把该字符串转换为对应的 md5
- (NSString *)qmui_md5;

/// 把某个十进制数字转换成十六进制的数字的字符串，例如“10”->“A”
+ (NSString *)qmui_hexStringWithInteger:(NSInteger)integer;

/**
 * 用正则表达式匹配的方式去除字符串里一些特殊字符，避免UI上的展示问题
 * @link http://www.croton.su/en/uniblock/Diacriticals.html
 */
- (NSString *)qmui_removeMagicalChar;

/**
 *  按照中文 2 个字符、英文 1 个字符的方式来计算文本长度
 */
- (NSUInteger)qmui_lengthWhenCountingNonASCIICharacterAsTwo;

/**
 *  将字符串从指定的 index 开始裁剪到结尾，裁剪时会避免将 emoji 等 "character sequences" 拆散（一个 emoji 表情占用1-4个长度的字符）。
 *
 *  例如对于字符串“😊😞”，它的长度为4，若调用 [string qmui_substringAvoidBreakingUpCharacterSequencesFromIndex:1]，将返回“😊😞”。
 *  若调用系统的 [string substringFromIndex:1]，将返回“?😞”。（?表示乱码，因为第一个 emoji 表情被从中间裁开了）。
 *
 *  @param index 要从哪个 index 开始裁剪文字
 *  @param lessValue 要按小的长度取，还是按大的长度取
 *  @param countingNonASCIICharacterAsTwo 是否按照 英文 1 个字符长度、中文 2 个字符长度的方式来裁剪
 *  @return 裁剪完的字符
 */
- (NSString *)qmui_substringAvoidBreakingUpCharacterSequencesFromIndex:(NSUInteger)index lessValue:(BOOL)lessValue countingNonASCIICharacterAsTwo:(BOOL)countingNonASCIICharacterAsTwo;

/**
 *  相当于 `qmui_substringAvoidBreakingUpCharacterSequencesFromIndex: lessValue:YES` countingNonASCIICharacterAsTwo:NO
 *  @see qmui_substringAvoidBreakingUpCharacterSequencesFromIndex:lessValue:countingNonASCIICharacterAsTwo:
 */
- (NSString *)qmui_substringAvoidBreakingUpCharacterSequencesFromIndex:(NSUInteger)index;

/**
 *  将字符串从开头裁剪到指定的 index，裁剪时会避免将 emoji 等 "character sequences" 拆散（一个 emoji 表情占用1-4个长度的字符）。
 *
 *  例如对于字符串“😊😞”，它的长度为4，若调用 [string qmui_substringAvoidBreakingUpCharacterSequencesToIndex:1]，将返回“😊”。
 *  若调用系统的 [string substringToIndex:1]，将返回“?”。（?表示乱码，因为第一个 emoji 表情被从中间裁开了）。
 *
 *  @param index 要裁剪到哪个 index
 *  @return 裁剪完的字符
 *  @param countingNonASCIICharacterAsTwo 是否按照 英文 1 个字符长度、中文 2 个字符长度的方式来裁剪
 */
- (NSString *)qmui_substringAvoidBreakingUpCharacterSequencesToIndex:(NSUInteger)index lessValue:(BOOL)lessValue countingNonASCIICharacterAsTwo:(BOOL)countingNonASCIICharacterAsTwo;

/**
 *  相当于 `qmui_substringAvoidBreakingUpCharacterSequencesToIndex:lessValue:YES` countingNonASCIICharacterAsTwo:NO
 *  @see qmui_substringAvoidBreakingUpCharacterSequencesToIndex:lessValue:countingNonASCIICharacterAsTwo:
 */
- (NSString *)qmui_substringAvoidBreakingUpCharacterSequencesToIndex:(NSUInteger)index;

/**
 *  将字符串里指定 range 的子字符串裁剪出来，会避免将 emoji 等 "character sequences" 拆散（一个 emoji 表情占用1-4个长度的字符）。
 *
 *  例如对于字符串“😊😞”，它的长度为4，在 lessValue 模式下，裁剪 (0, 1) 得到的是空字符串，裁剪 (0, 2) 得到的是“😊”。
 *  在非 lessValue 模式下，裁剪 (0, 1) 或 (0, 2)，得到的都是“😊”。
 *
 *  @param range 要裁剪的文字位置
 *  @param lessValue 裁剪时若遇到“character sequences”，是向下取整还是向上取整。
 *  @param countingNonASCIICharacterAsTwo 是否按照 英文 1 个字符长度、中文 2 个字符长度的方式来裁剪
 *  @return 裁剪完的字符
 */
- (NSString *)qmui_substringAvoidBreakingUpCharacterSequencesWithRange:(NSRange)range lessValue:(BOOL)lessValue countingNonASCIICharacterAsTwo:(BOOL)countingNonASCIICharacterAsTwo;

/**
 *  相当于 `qmui_substringAvoidBreakingUpCharacterSequencesWithRange:lessValue:YES` countingNonASCIICharacterAsTwo:NO
 *  @see qmui_substringAvoidBreakingUpCharacterSequencesWithRange:lessValue:countingNonASCIICharacterAsTwo:
 */
- (NSString *)qmui_substringAvoidBreakingUpCharacterSequencesWithRange:(NSRange)range;

/**
 *  移除指定位置的字符，可兼容emoji表情的情况（一个emoji表情占1-4个length）
 *  @param index 要删除的位置
 */
- (NSString *)qmui_stringByRemoveCharacterAtIndex:(NSUInteger)index;

/**
 *  移除最后一个字符，可兼容emoji表情的情况（一个emoji表情占1-4个length）
 *  @see `qmui_stringByRemoveCharacterAtIndex:`
 */
- (NSString *)qmui_stringByRemoveLastCharacter;

@end

@interface NSString (QMUI_StringFormat)

+ (instancetype)qmui_stringWithNSInteger:(NSInteger)integerValue;
+ (instancetype)qmui_stringWithCGFloat:(CGFloat)floatValue;
+ (instancetype)qmui_stringWithCGFloat:(CGFloat)floatValue decimal:(NSUInteger)decimal;
@end
