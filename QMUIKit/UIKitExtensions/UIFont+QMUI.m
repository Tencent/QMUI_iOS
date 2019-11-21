/*****
 * Tencent is pleased to support the open source community by making QMUI_iOS available.
 * Copyright (C) 2016-2019 THL A29 Limited, a Tencent company. All rights reserved.
 * Licensed under the MIT License (the "License"); you may not use this file except in compliance with the License. You may obtain a copy of the License at
 * http://opensource.org/licenses/MIT
 * Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.
 *****/

//
//  UIFont+QMUI.m
//  qmui
//
//  Created by QMUI Team on 15/7/20.
//

#import "UIFont+QMUI.h"
#import "QMUICore.h"

@implementation UIFont (QMUI)

+ (UIFont *)qmui_lightSystemFontOfSize:(CGFloat)fontSize {
    return [UIFont fontWithName:@".SFUIText-Light" size:fontSize];
}

+ (UIFont *)qmui_systemFontOfSize:(CGFloat)size weight:(QMUIFontWeight)weight italic:(BOOL)italic {
    BOOL isLight = weight == QMUIFontWeightLight;
    BOOL isBold = weight == QMUIFontWeightBold;
    
    BOOL shouldUsingHardCode = IOS_VERSION < 10.0;// 这 UIFontDescriptor 也是醉人，相同代码只有 iOS 10 能得出正确结果，7-9都无法获取到 Light + Italic 的字体，只能写死。
    if (shouldUsingHardCode) {
        NSString *name = @".SFUIText";
        NSString *fontSuffix = [NSString stringWithFormat:@"%@%@", isLight ? @"Light" : (isBold ? @"Bold" : @""), italic ? @"Italic" : @""];
        NSString *fontName = [NSString stringWithFormat:@"%@%@%@", name, fontSuffix.length > 0 ? @"-" : @"", fontSuffix];
        UIFont *font = [UIFont fontWithName:fontName size:size];
        return font;
    }
    
    // iOS 10 以上使用常规写法
    UIFont *font = nil;
    if (@available(iOS 8.2, *)) {
        font = [UIFont systemFontOfSize:size weight:isLight ? UIFontWeightLight : (isBold ? UIFontWeightBold : UIFontWeightRegular)];
        
        // 后面那些都是对斜体的操作，所以如果不需要斜体就直接 return
        if (!italic) {
            return font;
        }
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

+ (UIFont *)qmui_dynamicSystemFontOfSize:(CGFloat)size weight:(QMUIFontWeight)weight italic:(BOOL)italic {
    return [self qmui_dynamicSystemFontOfSize:size upperLimitSize:size + 5 lowerLimitSize:0 weight:weight italic:italic];
}

+ (UIFont *)qmui_dynamicSystemFontOfSize:(CGFloat)pointSize
                          upperLimitSize:(CGFloat)upperLimitSize
                          lowerLimitSize:(CGFloat)lowerLimitSize
                                  weight:(QMUIFontWeight)weight
                                  italic:(BOOL)italic {
    
    // 计算出 body 类型比默认的大小要变化了多少，然后在 pointSize 的基础上叠加这个变化
    UIFont *font = [UIFont preferredFontForTextStyle:UIFontTextStyleBody];
    CGFloat offsetPointSize = font.pointSize - 17;// default UIFontTextStyleBody fontSize is 17
    CGFloat finalPointSize = pointSize + offsetPointSize;
    finalPointSize = MAX(MIN(finalPointSize, upperLimitSize), lowerLimitSize);
    font = [UIFont qmui_systemFontOfSize:finalPointSize weight:weight italic:NO];
    
    return font;
}

@end
