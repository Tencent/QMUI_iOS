/**
 * Tencent is pleased to support the open source community by making QMUI_iOS available.
 * Copyright (C) 2016-2020 THL A29 Limited, a Tencent company. All rights reserved.
 * Licensed under the MIT License (the "License"); you may not use this file except in compliance with the License. You may obtain a copy of the License at
 * http://opensource.org/licenses/MIT
 * Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.
 */

//
//  QMUIWeakObjectContainer.h
//  QMUIKit
//
//  Created by QMUI Team on 2018/7/24.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/**
 一个常见的场景：当通过 objc_setAssociatedObject 以弱引用的方式（OBJC_ASSOCIATION_ASSIGN）绑定对象A时，假如对象A稍后被释放了，则通过 objc_getAssociatedObject 再次试图访问对象A时会导致野指针。
 这时你可以将对象A包装为一个 QMUIWeakObjectContainer，并改为通过强引用方式（OBJC_ASSOCIATION_RETAIN_NONATOMIC/OBJC_ASSOCIATION_RETAIN）绑定这个 QMUIWeakObjectContainer，进而安全地获取原始对象A。
 */
@interface QMUIWeakObjectContainer : NSProxy

/// 将一个 object 包装到一个 QMUIWeakObjectContainer 里
- (instancetype)initWithObject:(id)object;
- (instancetype)init;
+ (instancetype)containerWithObject:(id)object;

/// 获取原始对象 object，如果 object 已被释放则该属性返回 nil
@property (nullable, nonatomic, weak) id object;

@end

NS_ASSUME_NONNULL_END
