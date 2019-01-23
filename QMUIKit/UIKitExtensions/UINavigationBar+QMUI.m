/*****
 * Tencent is pleased to support the open source community by making QMUI_iOS available.
 * Copyright (C) 2016-2019 THL A29 Limited, a Tencent company. All rights reserved.
 * Licensed under the MIT License (the "License"); you may not use this file except in compliance with the License. You may obtain a copy of the License at
 * http://opensource.org/licenses/MIT
 * Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.
 *****/

//
//  UINavigationBar+QMUI.m
//  QMUIKit
//
//  Created by QMUI Team on 2018/O/8.
//

#import "UINavigationBar+QMUI.h"

@implementation UINavigationBar (QMUI)

- (UIView *)qmui_backgroundView {
    return [self valueForKey:@"_backgroundView"];
}

- (__kindof UIView *)qmui_backgroundContentView {
    if (@available(iOS 10, *)) {
        UIImageView *imageView = [self.qmui_backgroundView valueForKey:@"_backgroundImageView"];
        UIVisualEffectView *visualEffectView = [self.qmui_backgroundView valueForKey:@"_backgroundEffectView"];
        UIView *customView = [self.qmui_backgroundView valueForKey:@"_customBackgroundView"];
        UIView *result = customView && customView.superview ? customView : (imageView && imageView.superview ? imageView : visualEffectView);
        return result;
    } else {
        UIView *backdrop = [self.qmui_backgroundView valueForKey:@"_adaptiveBackdrop"];
        UIView *result = backdrop && backdrop.superview ? backdrop : self.qmui_backgroundView;
        return result;
    }
}

- (UIImageView *)qmui_shadowImageView {
    // UINavigationBar 在 init 完就可以获取到 backgroundView 和 shadowView，无需关心调用时机的问题
    return [self.qmui_backgroundView valueForKey:@"_shadowView"];
}

@end
