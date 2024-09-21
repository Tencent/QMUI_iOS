/**
 * Tencent is pleased to support the open source community by making QMUI_iOS available.
 * Copyright (C) 2016-2021 THL A29 Limited, a Tencent company. All rights reserved.
 * Licensed under the MIT License (the "License"); you may not use this file except in compliance with the License. You may obtain a copy of the License at
 * http://opensource.org/licenses/MIT
 * Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.
 */

//
//  UIActivityIndicatorView+QMUI.h
//  qmui
//
//  Created by QMUI Team on 15/7/20.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

/**
 内部通过重写系统方法来让 UIActivityIndicatorView 支持 setFrame: 方式修改尺寸，业务就像使用一个普通 UIView 一样去使用它即可。
 */
@interface UIActivityIndicatorView (QMUI)

/// 内部转圈的那个 imageView
@property(nonatomic, strong, readonly) UIImageView *qmui_animatingView;

@end

NS_ASSUME_NONNULL_END
