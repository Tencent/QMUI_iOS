/**
 * Tencent is pleased to support the open source community by making QMUI_iOS available.
 * Copyright (C) 2016-2021 THL A29 Limited, a Tencent company. All rights reserved.
 * Licensed under the MIT License (the "License"); you may not use this file except in compliance with the License. You may obtain a copy of the License at
 * http://opensource.org/licenses/MIT
 * Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.
 */
//
//  UIBlurEffect+QMUI.m
//  QMUIKit
//
//  Created by MoLice on 2021/N/25.
//

#import "UIBlurEffect+QMUI.h"
#import "QMUICore.h"

@implementation UIBlurEffect (QMUI)

+ (instancetype)qmui_effectWithBlurRadius:(CGFloat)radius {
    // -[UIBlurEffect effectWithBlurRadius:]
    UIBlurEffect *effect = [self qmui_performSelector:NSSelectorFromString(@"effectWithBlurRadius:") withArguments:&radius, nil];
    return effect;
}

- (UIBlurEffectStyle)qmui_style {
    UIBlurEffectStyle style;
    // -[UIBlurEffect _style]
    [self qmui_performSelector:NSSelectorFromString(@"_style") withPrimitiveReturnValue:&style];
    return style;
}

@end
