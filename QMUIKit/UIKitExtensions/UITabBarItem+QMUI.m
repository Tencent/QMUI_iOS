/**
 * Tencent is pleased to support the open source community by making QMUI_iOS available.
 * Copyright (C) 2016-2020 THL A29 Limited, a Tencent company. All rights reserved.
 * Licensed under the MIT License (the "License"); you may not use this file except in compliance with the License. You may obtain a copy of the License at
 * http://opensource.org/licenses/MIT
 * Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.
 */

//
//  UITabBarItem+QMUI.m
//  qmui
//
//  Created by QMUI Team on 15/7/20.
//

#import "UITabBarItem+QMUI.h"
#import "QMUICore.h"
#import "UIBarItem+QMUI.h"

@implementation UITabBarItem (QMUI)

QMUISynthesizeIdCopyProperty(qmui_doubleTapBlock, setQmui_doubleTapBlock)

- (UIImageView *)qmui_imageView {
    return [self.class qmui_imageViewInTabBarButton:self.qmui_view];
}

+ (UIImageView *)qmui_imageViewInTabBarButton:(UIView *)tabBarButton {
    
    if (!tabBarButton) {
        return nil;
    }
    
    if (@available(iOS 13.0, *)) {
        if ([tabBarButton.subviews.firstObject isKindOfClass:[UIVisualEffectView class]] && ((UIVisualEffectView *)tabBarButton.subviews.firstObject).contentView.subviews.count) {
            // iOS 13 下如果 tabBar 是磨砂的，则每个 button 内部都会有一个磨砂，而磨砂再包裹了 imageView、label 等 subview，但某些时机后系统又会把 imageView、label 挪出来放到 button 上，所以这里做个保护
            // https://github.com/Tencent/QMUI_iOS/issues/616
            
            UIView *contentView = ((UIVisualEffectView *)tabBarButton.subviews.firstObject).contentView;
            // iOS 13 beta5 布局发生了变化，即使有磨砂 view，内部也不一定包裹着 imageView
            for (UIView *subview in contentView.subviews) {
                if ([NSStringFromClass([subview class]) isEqualToString:@"UITabBarSwappableImageView"]) {
                    return (UIImageView *)subview;
                }
            }
        }
    }
    
    for (UIView *subview in tabBarButton.subviews) {
        
        if (@available(iOS 10.0, *)) {
            // iOS10及以后，imageView都是用UITabBarSwappableImageView实现的，所以遇到这个class就直接拿
            if ([NSStringFromClass([subview class]) isEqualToString:@"UITabBarSwappableImageView"]) {
                return (UIImageView *)subview;
            }
        }
        
        // iOS10以前，选中的item的高亮是用UITabBarSelectionIndicatorView实现的，所以要屏蔽掉
        if ([subview isKindOfClass:[UIImageView class]] && ![NSStringFromClass([subview class]) isEqualToString:@"UITabBarSelectionIndicatorView"]) {
            return (UIImageView *)subview;
        }
        
    }
    return nil;
}

@end
