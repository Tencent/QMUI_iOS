/*****
 * Tencent is pleased to support the open source community by making QMUI_iOS available.
 * Copyright (C) 2016-2019 THL A29 Limited, a Tencent company. All rights reserved.
 * Licensed under the MIT License (the "License"); you may not use this file except in compliance with the License. You may obtain a copy of the License at
 * http://opensource.org/licenses/MIT
 * Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.
 *****/

//
//  UITabBarItem+QMUI.h
//  qmui
//
//  Created by QMUI Team on 15/7/20.
//

#import <UIKit/UIKit.h>

@interface UITabBarItem (QMUI)

/**
 *  双击 tabBarItem 时的回调，默认为 nil。
 *  @arg tabBarItem 被双击的 UITabBarItem
 *  @arg index      被双击的 UITabBarItem 的序号
 */
@property(nonatomic, copy) void (^qmui_doubleTapBlock)(UITabBarItem *tabBarItem, NSInteger index);

/**
 * 获取一个UITabBarItem内显示图标的UIImageView，如果找不到则返回nil
 * @warning 需要对nil的返回值做保护
 */
- (UIImageView *)qmui_imageView;

+ (UIImageView *)qmui_imageViewInTabBarButton:(UIView *)tabBarButton;

@end
