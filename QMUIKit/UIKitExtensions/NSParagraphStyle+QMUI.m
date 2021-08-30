/**
 * Tencent is pleased to support the open source community by making QMUI_iOS available.
 * Copyright (C) 2016-2021 THL A29 Limited, a Tencent company. All rights reserved.
 * Licensed under the MIT License (the "License"); you may not use this file except in compliance with the License. You may obtain a copy of the License at
 * http://opensource.org/licenses/MIT
 * Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.
 */

//
//  NSParagraphStyle+QMUI.m
//  qmui
//
//  Created by QMUI Team on 16/8/9.
//

#import "NSParagraphStyle+QMUI.h"

@implementation NSParagraphStyle (QMUI)

+ (instancetype)qmui_paragraphStyleWithLineHeight:(CGFloat)lineHeight {
    return [self qmui_paragraphStyleWithLineHeight:lineHeight lineBreakMode:NSLineBreakByWordWrapping textAlignment:NSTextAlignmentLeft];
}

+ (instancetype)qmui_paragraphStyleWithLineHeight:(CGFloat)lineHeight lineBreakMode:(NSLineBreakMode)lineBreakMode {
    return [self qmui_paragraphStyleWithLineHeight:lineHeight lineBreakMode:lineBreakMode textAlignment:NSTextAlignmentLeft];
}

+ (instancetype)qmui_paragraphStyleWithLineHeight:(CGFloat)lineHeight lineBreakMode:(NSLineBreakMode)lineBreakMode textAlignment:(NSTextAlignment)textAlignment {
    Class className = ![self isMemberOfClass:NSMutableParagraphStyle.class] ? NSMutableParagraphStyle.class : self;// 保证如果有 NSMutableParagraphStyle 的子类来调用这个方法，也可以用子类的 Class 去初始化
    NSMutableParagraphStyle *paragraphStyle = [[className alloc] init];
    paragraphStyle.minimumLineHeight = lineHeight;
    paragraphStyle.maximumLineHeight = lineHeight;
    paragraphStyle.lineBreakMode = lineBreakMode;
    paragraphStyle.alignment = textAlignment;
    return paragraphStyle;
}
@end
