/**
 * Tencent is pleased to support the open source community by making QMUI_iOS available.
 * Copyright (C) 2016-2021 THL A29 Limited, a Tencent company. All rights reserved.
 * Licensed under the MIT License (the "License"); you may not use this file except in compliance with the License. You may obtain a copy of the License at
 * http://opensource.org/licenses/MIT
 * Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.
 */

//
//  NSParagraphStyle+QMUI.h
//  qmui
//
//  Created by QMUI Team on 16/8/9.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface NSMutableParagraphStyle (QMUI)

/**
 *  快速创建一个NSMutableParagraphStyle，等同于`qmui_paragraphStyleWithLineHeight:lineBreakMode:NSLineBreakByWordWrapping textAlignment:NSTextAlignmentLeft`
 *  @param  lineHeight      行高
 *  @return 一个NSMutableParagraphStyle对象
 */
+ (instancetype)qmui_paragraphStyleWithLineHeight:(CGFloat)lineHeight;

/**
 *  快速创建一个NSMutableParagraphStyle，等同于`qmui_paragraphStyleWithLineHeight:lineBreakMode:textAlignment:NSTextAlignmentLeft`
 *  @param  lineHeight      行高
 *  @param  lineBreakMode   换行模式
 *  @return 一个NSMutableParagraphStyle对象
 */
+ (instancetype)qmui_paragraphStyleWithLineHeight:(CGFloat)lineHeight lineBreakMode:(NSLineBreakMode)lineBreakMode;

/**
 *  快速创建一个NSMutableParagraphStyle
 *  @param  lineHeight      行高
 *  @param  lineBreakMode   换行模式
 *  @param  textAlignment   文本对齐方式
 *  @return 一个NSMutableParagraphStyle对象
 */
+ (instancetype)qmui_paragraphStyleWithLineHeight:(CGFloat)lineHeight lineBreakMode:(NSLineBreakMode)lineBreakMode textAlignment:(NSTextAlignment)textAlignment;
@end
