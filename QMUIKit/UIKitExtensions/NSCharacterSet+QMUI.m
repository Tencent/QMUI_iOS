/**
 * Tencent is pleased to support the open source community by making QMUI_iOS available.
 * Copyright (C) 2016-2021 THL A29 Limited, a Tencent company. All rights reserved.
 * Licensed under the MIT License (the "License"); you may not use this file except in compliance with the License. You may obtain a copy of the License at
 * http://opensource.org/licenses/MIT
 * Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.
 */

//
//  NSCharacterSet+QMUI.m
//  QMUIKit
//
//  Created by QMUI Team on 2018/9/17.
//

#import "NSCharacterSet+QMUI.h"

@implementation NSCharacterSet (QMUI)

+ (NSCharacterSet *)qmui_URLUserInputQueryAllowedCharacterSet {
    NSMutableCharacterSet *set = [NSCharacterSet URLQueryAllowedCharacterSet].mutableCopy;
    [set removeCharactersInString:@"#&="];
    return set.copy;
}

@end
