/**
 * Tencent is pleased to support the open source community by making QMUI_iOS available.
 * Copyright (C) 2016-2021 THL A29 Limited, a Tencent company. All rights reserved.
 * Licensed under the MIT License (the "License"); you may not use this file except in compliance with the License. You may obtain a copy of the License at
 * http://opensource.org/licenses/MIT
 * Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.
 */

//
//  NSRegularExpression+QMUI.h
//  QMUIKit
//
//  Created by QMUI Team on 2024/2/21.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSRegularExpression (QMUI)

/// 某些场景频繁构造 NSRegularExpression 耗时较大，所以这里提供一个缓存的方式，如果你的场景非频繁，可以不用。
+ (nullable NSRegularExpression *)qmui_cachedRegularExpressionWithPattern:(NSString *)pattern options:(NSRegularExpressionOptions)options;

/// 某些场景频繁构造 NSRegularExpression 耗时较大，所以这里提供一个缓存的方式，如果你的场景非频繁，可以不用。等价于 options 为 NSRegularExpressionCaseInsensitive。
+ (nullable NSRegularExpression *)qmui_cachedRegularExpressionWithPattern:(NSString *)pattern;
@end

NS_ASSUME_NONNULL_END
