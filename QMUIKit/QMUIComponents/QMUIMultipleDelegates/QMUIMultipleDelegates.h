/**
 * Tencent is pleased to support the open source community by making QMUI_iOS available.
 * Copyright (C) 2016-2021 THL A29 Limited, a Tencent company. All rights reserved.
 * Licensed under the MIT License (the "License"); you may not use this file except in compliance with the License. You may obtain a copy of the License at
 * http://opensource.org/licenses/MIT
 * Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.
 */

//
//  QMUIMultipleDelegates.h
//  QMUIKit
//
//  Created by QMUI Team on 2018/3/27.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import "NSObject+QMUIMultipleDelegates.h"

/// 存放多个 delegate 指针的容器，必须搭配其他控件使用，一般不需要你自己 init。作用是让某个 class 支持同时存在多个 delegate。更多说明请查看 NSObject (QMUIMultipleDelegates) 的注释。
@interface QMUIMultipleDelegates : NSObject

+ (instancetype)weakDelegates;
+ (instancetype)strongDelegates;

@property(nonatomic, strong, readonly) NSPointerArray *delegates;
@property(nonatomic, weak) NSObject *parentObject;

- (void)addDelegate:(id)delegate;
- (BOOL)removeDelegate:(id)delegate;
- (void)removeAllDelegates;
- (BOOL)containsDelegate:(id)delegate;

@end
