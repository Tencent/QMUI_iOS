/*****
 * Tencent is pleased to support the open source community by making QMUI_iOS available.
 * Copyright (C) 2016-2018 THL A29 Limited, a Tencent company. All rights reserved.
 * Licensed under the MIT License (the "License"); you may not use this file except in compliance with the License. You may obtain a copy of the License at
 * http://opensource.org/licenses/MIT
 * Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.
 *****/
//
//  UIWindow+QMUI.m
//  qmui
//
//  Created by MoLice on 16/7/21.
//

#import "UIWindow+QMUI.h"
#import "QMUICore.h"

@implementation UIWindow (QMUI)

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        ExchangeImplementations([self class], @selector(init), @selector(qmui_init));
    });
}

- (instancetype)qmui_init {
    if (IOS_VERSION < 9.0) {
        // iOS 9 以前的版本，UIWindow init时如果不给一个frame，默认是CGRectZero，而iOS 9以后的版本，由于增加了分屏（Split View）功能，你的App可能运行在一个非全屏大小的区域内，所以UIWindow如果调用init方法（而不是initWithFrame:）来初始化，系统会自动为你的window设置一个合适的大小。所以这里对iOS 9以前的版本做适配，默认给一个全屏的frame
        UIWindow *window = [self qmui_init];
        window.frame = [[UIScreen mainScreen] bounds];
        return window;
    }
    
    return [self qmui_init];
}

@end
