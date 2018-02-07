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
    return [UIFont fontWithName:IOS_VERSION >= 9.0 ? @".SFUIText-Light" : @"HelveticaNeue-Light" size:fontSize];
}

+ (UIFont *)qmui_systemFontOfSize:(CGFloat)size weight:(QMUIFontWeight)weight italic:(BOOL)italic {
    BOOL isLight = weight == QMUIFontWeightLight;
    BOOL isBold = weight == QMUIFontWeightBold;
    
    BOOL shouldUsingHardCode = IOS_VERSION < 10.0;// 这 UIFontDescriptor 也是醉人，相同代码只有 iOS 10 能得出正确结果，7-9都无法获取到 Light + Italic 的字体，只能写死。
    if (shouldUsingHardCode) {
        NSString *name = IOS_VERSION < 9.0 ? @"HelveticaNeue" : @".SFUIText";
        NSString *fontSuffix = [NSString stringWithFormat:@"%@%@", isLight ? @"Light" : (isBold ? @"Bold" : @""), italic ? @"Italic" : @""];
        NSString *fontName = [NSString stringWithFormat:@"%@%@%@", name, fontSuffix.length > 0 ? @"-" : @"", fontSuffix];
        UIFont *font = [UIFont fontWithName:fontName size:size];
        return font;
    }
    
    // iOS 10 以上使用常规写法
    UIFont *font = nil;
    if ([self.class respondsToSelector:@selector(systemFontOfSize:weight:)]) {
        font = [UIFont systemFontOfSize:size weight:isLight ? UIFontWeightLight : (isBold ? UIFontWeightBold : UIFontWeightRegular)];
    } else {
        font = [UIFont systemFontOfSize:size];
    }
    
    UIFontDescriptor *fontDescriptor = font.fontDescriptor;
    NSMutableDictionary<NSString *, id> *traitsAttribute = [NSMutableDictionary dictionaryWithDictionary:fontDescriptor.fontAttributes[UIFontDescriptorTraitsAttribute]];
    if (![UIFont respondsToSelector:@selector(systemFontOfSize:weight:)]) {
        traitsAttribute[UIFontWeightTrait] = isLight ? @-1.0 : (isBold ? @1.0 : @0.0);
    }
    if (italic) {
        traitsAttribute[UIFontSlantTrait] = @1.0;
    } else {
        traitsAttribute[UIFontSlantTrait] = @0.0;
    }
    fontDescriptor = [fontDescriptor fontDescriptorByAddingAttributes:@{UIFontDescriptorTraitsAttribute: traitsAttribute}];
    font = [UIFont fontWithDescriptor:fontDescriptor size:0];
    return font;
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
