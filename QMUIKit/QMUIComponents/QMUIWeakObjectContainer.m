/*****
 * Tencent is pleased to support the open source community by making QMUI_iOS available.
 * Copyright (C) 2016-2019 THL A29 Limited, a Tencent company. All rights reserved.
 * Licensed under the MIT License (the "License"); you may not use this file except in compliance with the License. You may obtain a copy of the License at
 * http://opensource.org/licenses/MIT
 * Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.
 *****/

//
//  QMUIWeakObjectContainer.m
//  QMUIKit
//
//  Created by QMUI Team on 2018/7/24.
//

#import "QMUIWeakObjectContainer.h"

@implementation QMUIWeakObjectContainer

- (instancetype)initWithObject:(id)object {
    if (self = [super init]) {
        _object = object;
    }
    return self;
}

@end
