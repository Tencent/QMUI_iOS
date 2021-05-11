/**
 * Tencent is pleased to support the open source community by making QMUI_iOS available.
 * Copyright (C) 2016-2021 THL A29 Limited, a Tencent company. All rights reserved.
 * Licensed under the MIT License (the "License"); you may not use this file except in compliance with the License. You may obtain a copy of the License at
 * http://opensource.org/licenses/MIT
 * Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.
 */

//
//  QMUIScrollAnimator.h
//  QMUIKit
//
//  Created by QMUI Team on 2018/S/30.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

/**
 一个方便地监控 UIScrollView 滚动的类，可在 didScrollBlock 里做一些与滚动位置相关的事情。
 
 使用方式：
 1. 用 init 初始化。
 2. 通过 scrollView 绑定一个 UIScrollView。
 3. 在 didScrollBlock 里做一些与滚动位置相关的事情。
 */
@interface QMUIScrollAnimator : NSObject<UIScrollViewDelegate>

/// 绑定的 UIScrollView
@property(nullable, nonatomic, weak) __kindof UIScrollView *scrollView;

/// UIScrollView 滚动时会调用这个 block
@property(nonatomic, copy) void (^didScrollBlock)(__kindof QMUIScrollAnimator *animator);

/// 当 enabled 为 NO 时，即便 scrollView 滚动，didScrollBlock 也不会被调用。默认为 YES。
@property(nonatomic, assign) BOOL enabled;

/// 立即根据当前的滚动位置更新状态
- (void)updateScroll;

@end

NS_ASSUME_NONNULL_END
