/**
 * Tencent is pleased to support the open source community by making QMUI_iOS available.
 * Copyright (C) 2016-2020 THL A29 Limited, a Tencent company. All rights reserved.
 * Licensed under the MIT License (the "License"); you may not use this file except in compliance with the License. You may obtain a copy of the License at
 * http://opensource.org/licenses/MIT
 * Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.
 */

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
    return [UIFont systemFontOfSize:fontSize weight:UIFontWeightLight];
}

+ (UIFont *)qmui_systemFontOfSize:(CGFloat)size weight:(QMUIFontWeight)weight italic:(BOOL)italic {
    UIFont *font = nil;
    font = [UIFont systemFontOfSize:size weight:weight == QMUIFontWeightLight ? UIFontWeightLight : (weight == QMUIFontWeightBold ? UIFontWeightSemibold : UIFontWeightRegular)];
    if (!italic) {
        return font;
    }
    
    UIFontDescriptor *fontDescriptor = font.fontDescriptor;
    UIFontDescriptorSymbolicTraits trait = fontDescriptor.symbolicTraits;
    trait |= UIFontDescriptorTraitItalic;
    fontDescriptor = [fontDescriptor fontDescriptorWithSymbolicTraits:trait];
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
