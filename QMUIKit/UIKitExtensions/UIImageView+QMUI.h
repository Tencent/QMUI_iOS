/*****
 * Tencent is pleased to support the open source community by making QMUI_iOS available.
 * Copyright (C) 2016-2019 THL A29 Limited, a Tencent company. All rights reserved.
 * Licensed under the MIT License (the "License"); you may not use this file except in compliance with the License. You may obtain a copy of the License at
 * http://opensource.org/licenses/MIT
 * Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.
 *****/

//
//  UIImageView+QMUI.h
//  qmui
//
//  Created by QMUI Team on 16/8/9.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface UIImageView (QMUI)

/**
 暂停/恢复当前 UIImageView 上的 animation images（包括通过 animationImages 设置的图片数组，以及通过 [UIImage animatedImage] 系列方法创建的动图）的播放，默认为 NO。
 */
@property(nonatomic, assign) BOOL qmui_pause;

/**
 是否要用 QMUI 提供的高性能方式去渲染由 [UIImage animatedImage] 创建的 UIImage，（系统原生的方式在 UIImageView 被放在 UIScrollView 内时会卡顿），默认为 YES。
 */
@property(nonatomic, assign) BOOL qmui_smoothAnimation;

/**
 *  把 UIImageView 的宽高调整为能保持 image 宽高比例不变的同时又不超过给定的 `limitSize` 大小的最大frame
 *
 *  建议在设置完x/y之后调用
 */
- (void)qmui_sizeToFitKeepingImageAspectRatioInSize:(CGSize)limitSize;
@end
