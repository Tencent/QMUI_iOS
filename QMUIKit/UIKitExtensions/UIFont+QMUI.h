/**
 * Tencent is pleased to support the open source community by making QMUI_iOS available.
 * Copyright (C) 2016-2020 THL A29 Limited, a Tencent company. All rights reserved.
 * Licensed under the MIT License (the "License"); you may not use this file except in compliance with the License. You may obtain a copy of the License at
 * http://opensource.org/licenses/MIT
 * Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.
 */

//
//  UIFont+QMUI.h
//  qmui
//
//  Created by QMUI Team on 15/7/20.
//

#import <UIKit/UIKit.h>

#define UIFontLightMake(size) [UIFont qmui_lightSystemFontOfSize:size]
#define UIFontLightWithFont(_font) [UIFont qmui_lightSystemFontOfSize:_font.pointSize]
#define UIDynamicFontMake(_pointSize) [UIFont qmui_dynamicSystemFontOfSize:_pointSize weight:QMUIFontWeightNormal italic:NO]
#define UIDynamicFontMakeWithLimit(_pointSize, _upperLimitSize, _lowerLimitSize) [UIFont qmui_dynamicSystemFontOfSize:_pointSize upperLimitSize:_upperLimitSize lowerLimitSize:_lowerLimitSize weight:QMUIFontWeightNormal italic:NO]
#define UIDynamicFontBoldMake(_pointSize) [UIFont qmui_dynamicSystemFontOfSize:_pointSize weight:QMUIFontWeightBold italic:NO]
#define UIDynamicFontBoldMakeWithLimit(_pointSize, _upperLimitSize, _lowerLimitSize) [UIFont qmui_dynamicSystemFontOfSize:_pointSize upperLimitSize:_upperLimitSize lowerLimitSize:_lowerLimitSize weight:QMUIFontWeightBold italic:NO]
#define UIDynamicFontLightMake(_pointSize) [UIFont qmui_dynamicSystemFontOfSize:_pointSize weight:QMUIFontWeightLight italic:NO]
#define UIDynamicFontLightMakeWithLimit(_pointSize, _upperLimitSize, _lowerLimitSize) [UIFont qmui_dynamicSystemFontOfSize:_pointSize upperLimitSize:_upperLimitSize lowerLimitSize:_lowerLimitSize weight:QMUIFontWeightLight italic:NO]

typedef NS_ENUM(NSUInteger, QMUIFontWeight) {
    QMUIFontWeightLight,    // 对应 UIFontWeightLight
    QMUIFontWeightNormal,   // 对应 UIFontWeightRegular
    QMUIFontWeightBold      // 对应 UIFontWeightSemibold
};

@interface UIFont (QMUI)

/**
 *  返回系统字体的细体
 *
 *  @param fontSize 字体大小
 *
 *  @return 变细的系统字体的 UIFont 对象
 */
+ (UIFont *)qmui_lightSystemFontOfSize:(CGFloat)fontSize;

/**
 *  根据需要生成一个 UIFont 对象并返回
 *  @param size     字号大小
 *  @param weight   字体粗细
 *  @param italic   是否斜体
 */
+ (UIFont *)qmui_systemFontOfSize:(CGFloat)size
                           weight:(QMUIFontWeight)weight
                           italic:(BOOL)italic;

/**
 *  根据需要生成一个支持响应动态字体大小调整的 UIFont 对象并返回
 *  @param  size    字号大小
 *  @param  weight  字重
 *  @param  italic  是否斜体
 *  @return         支持响应动态字体大小调整的 UIFont 对象
 */
+ (UIFont *)qmui_dynamicSystemFontOfSize:(CGFloat)size
                                  weight:(QMUIFontWeight)weight
                                  italic:(BOOL)italic;

/**
 *  返回支持动态字体的UIFont，支持定义最小和最大字号
 *
 *  @param pointSize        默认的size
 *  @param upperLimitSize   最大的字号限制
 *  @param lowerLimitSize   最小的字号显示
 *  @param weight           字重
 *  @param italic           是否斜体
 *
 *  @return                 支持响应动态字体大小调整的 UIFont 对象
 */
+ (UIFont *)qmui_dynamicSystemFontOfSize:(CGFloat)pointSize
                          upperLimitSize:(CGFloat)upperLimitSize
                          lowerLimitSize:(CGFloat)lowerLimitSize
                                  weight:(QMUIFontWeight)weight
                                  italic:(BOOL)italic;

@end
