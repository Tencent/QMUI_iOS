//
//  UIFont+QMUI.m
//  qmui
//
//  Created by ZhoonChen on 15/7/20.
//  Copyright (c) 2015年 QMUI Team. All rights reserved.
//

#import "UIFont+QMUI.h"
#import "QMUICommonDefines.h"

@implementation UIFont (QMUI)

+ (UIFont *)qmui_lightSystemFontOfSize:(CGFloat)fontSize {
    return [UIFont fontWithName:IOS_VERSION >= 9.0 ? @"PingFangSC-Light" : @"HelveticaNeue-Light" size:fontSize];
}

+ (UIFont *)qmui_dynamicFontWithSize:(CGFloat)pointSize upperLimitSize:(CGFloat)upperLimitSize lowerLimitSize:(CGFloat)lowerLimitSize bold:(BOOL)bold {
    
    UIFont *font;
    UIFontDescriptor *descriptor;
    NSString *textStyle;
    
    // 如果是系统的字号，先映射到系统提供的UIFontTextStyle，否则用UIFontDescriptor来做偏移计算
    if (pointSize == 17) {
        textStyle = UIFontTextStyleBody;
    } else if (pointSize == 15) {
        textStyle = UIFontTextStyleSubheadline;
    } else if (pointSize == 13) {
        textStyle = UIFontTextStyleFootnote;
    } else if (pointSize == 12) {
        textStyle = UIFontTextStyleCaption1;
    } else if (pointSize == 11) {
        textStyle = UIFontTextStyleCaption2;
    }
    
    if (textStyle)
    {
        descriptor = [UIFontDescriptor preferredFontDescriptorWithTextStyle:textStyle];
        if (bold) {
            descriptor = [descriptor fontDescriptorWithSymbolicTraits:UIFontDescriptorTraitBold];
            font = [UIFont fontWithDescriptor:descriptor size:0];
            if (upperLimitSize > 0 && font.pointSize > upperLimitSize) {
                font = [UIFont fontWithDescriptor:descriptor size:upperLimitSize];
            } else if (lowerLimitSize > 0 && font.pointSize < lowerLimitSize) {
                font = [UIFont fontWithDescriptor:descriptor size:lowerLimitSize];
            }
        } else {
            font = [UIFont preferredFontForTextStyle:textStyle];
            if (upperLimitSize > 0 && font.pointSize > upperLimitSize) {
                font = [UIFont systemFontOfSize:upperLimitSize];
            } else if (lowerLimitSize > 0 && font.pointSize < lowerLimitSize) {
                font = [UIFont systemFontOfSize:lowerLimitSize];
            }
        }
    } else {
        textStyle = UIFontTextStyleBody;
        descriptor = [UIFontDescriptor preferredFontDescriptorWithTextStyle:textStyle];
        // 对于非系统默认字号的情况，用body类型去做偏移计算
        font = [UIFont preferredFontForTextStyle:textStyle];// default fontSize = 17
        CGFloat offsetPointSize = font.pointSize - 17;
        descriptor = [descriptor fontDescriptorWithSize:pointSize + offsetPointSize];
        if (bold) {
            descriptor = [descriptor fontDescriptorWithSymbolicTraits:UIFontDescriptorTraitBold];
        }
        font = [UIFont fontWithDescriptor:descriptor size:0];
        if (upperLimitSize > 0 && font.pointSize > upperLimitSize) {
            font = [UIFont fontWithDescriptor:descriptor size:upperLimitSize];
        } else if (lowerLimitSize > 0 && font.pointSize < lowerLimitSize) {
            font = [UIFont fontWithDescriptor:descriptor size:lowerLimitSize];
        }
    }
    
    return font;
}

+ (UIFont *)qmui_dynamicFontWithSize:(CGFloat)pointSize bold:(BOOL)bold {
    return [UIFont qmui_dynamicFontWithSize:pointSize upperLimitSize:pointSize + 3 lowerLimitSize:0 bold:bold];
}

@end
