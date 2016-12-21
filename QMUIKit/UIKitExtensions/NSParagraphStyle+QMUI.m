//
//  NSParagraphStyle+QMUI.m
//  qmui
//
//  Created by MoLice on 16/8/9.
//  Copyright © 2016年 QMUI Team. All rights reserved.
//

#import "NSParagraphStyle+QMUI.h"

@implementation NSMutableParagraphStyle (QMUI)

+ (instancetype)paragraphStyleWithLineHeight:(CGFloat)lineHeight {
    return [self paragraphStyleWithLineHeight:lineHeight lineBreakMode:NSLineBreakByWordWrapping textAlignment:NSTextAlignmentLeft];
}

+ (instancetype)paragraphStyleWithLineHeight:(CGFloat)lineHeight lineBreakMode:(NSLineBreakMode)lineBreakMode {
    return [self paragraphStyleWithLineHeight:lineHeight lineBreakMode:lineBreakMode textAlignment:NSTextAlignmentLeft];
}

+ (instancetype)paragraphStyleWithLineHeight:(CGFloat)lineHeight lineBreakMode:(NSLineBreakMode)lineBreakMode textAlignment:(NSTextAlignment)textAlignment {
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.minimumLineHeight = lineHeight;
    paragraphStyle.maximumLineHeight = lineHeight;
    paragraphStyle.lineBreakMode = lineBreakMode;
    paragraphStyle.alignment = textAlignment;
    return paragraphStyle;
}
@end
