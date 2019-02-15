/*****
 * Tencent is pleased to support the open source community by making QMUI_iOS available.
 * Copyright (C) 2016-2019 THL A29 Limited, a Tencent company. All rights reserved.
 * Licensed under the MIT License (the "License"); you may not use this file except in compliance with the License. You may obtain a copy of the License at
 * http://opensource.org/licenses/MIT
 * Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.
 *****/

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
    
    for (UIView *subview in tabBarButton.subviews) {
        // iOS10及以后，imageView都是用UITabBarSwappableImageView实现的，所以遇到这个class就直接拿
        if ([NSStringFromClass([subview class]) isEqualToString:@"UITabBarSwappableImageView"]) {
            return (UIImageView *)subview;
        }
        
        if (IOS_VERSION < 10) {
            // iOS10以前，选中的item的高亮是用UITabBarSelectionIndicatorView实现的，所以要屏蔽掉
            if ([subview isKindOfClass:[UIImageView class]] && ![NSStringFromClass([subview class]) isEqualToString:@"UITabBarSelectionIndicatorView"]) {
                return (UIImageView *)subview;
            }
        }
        
    }
    return nil;
}

@end
