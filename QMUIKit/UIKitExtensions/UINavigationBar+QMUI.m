/**
 * Tencent is pleased to support the open source community by making QMUI_iOS available.
 * Copyright (C) 2016-2020 THL A29 Limited, a Tencent company. All rights reserved.
 * Licensed under the MIT License (the "License"); you may not use this file except in compliance with the License. You may obtain a copy of the License at
 * http://opensource.org/licenses/MIT
 * Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.
 */

//
//  UINavigationBar+QMUI.m
//  QMUIKit
//
//  Created by QMUI Team on 2018/O/8.
//

#import "UINavigationBar+QMUI.h"
#import "QMUICore.h"
#import "NSObject+QMUI.h"

@implementation UINavigationBar (QMUI)

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        // iOS 10 及以下，如果 UINavigationBar backgroundImage 为 nil，则 navigationBar 会显示磨砂背景，此时不管怎么修改 shadowImage 都无效，都会显示系统默认的分隔线，导致无法很好地统一不同 iOS 版本的表现（iOS 11 及以上没有这个限制），所以这里做了兼容。
        if (@available(iOS 11.0, *)) {
        } else {
            ExtendImplementationOfVoidMethodWithoutArguments([UINavigationBar class], NSSelectorFromString(@"_updateBackgroundView"), ^(UINavigationBar *selfObject) {
                UIImage *shadowImage = selfObject.shadowImage;// 就算 navigationBar 显示系统的分隔线，但依然能从 shadowImage 属性获取到业务自己设置的图片
                UIImageView *shadowImageView = selfObject.qmui_shadowImageView;
                if (shadowImage && shadowImageView && shadowImageView.backgroundColor && !shadowImageView.image) {
                    shadowImageView.backgroundColor = nil;
                    shadowImageView.image = shadowImage;
                }
            });
        }
    });
}

- (UIView *)qmui_contentView {
    return [self valueForKeyPath:@"visualProvider.contentView"];
}

- (UIView *)qmui_backgroundView {
    return [self qmui_valueForKey:@"_backgroundView"];
}

- (__kindof UIView *)qmui_backgroundContentView {
    if (@available(iOS 13, *)) {
        return [self.qmui_backgroundView qmui_valueForKey:@"_colorAndImageView1"];
    } else {
        UIImageView *imageView = [self.qmui_backgroundView qmui_valueForKey:@"_backgroundImageView"];
        UIVisualEffectView *visualEffectView = [self.qmui_backgroundView qmui_valueForKey:@"_backgroundEffectView"];
        UIView *customView = [self.qmui_backgroundView qmui_valueForKey:@"_customBackgroundView"];
        UIView *result = customView && customView.superview ? customView : (imageView && imageView.superview ? imageView : visualEffectView);
        return result;
    }
}

- (UIImageView *)qmui_shadowImageView {
    // UINavigationBar 在 init 完就可以获取到 backgroundView 和 shadowView，无需关心调用时机的问题
    if (@available(iOS 13, *)) {
        return [self.qmui_backgroundView qmui_valueForKey:@"_shadowView1"];
    }
    return [self.qmui_backgroundView qmui_valueForKey:@"_shadowView"];
}

@end
