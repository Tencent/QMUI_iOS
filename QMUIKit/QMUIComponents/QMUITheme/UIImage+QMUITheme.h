/**
 * Tencent is pleased to support the open source community by making QMUI_iOS available.
 * Copyright (C) 2016-2020 THL A29 Limited, a Tencent company. All rights reserved.
 * Licensed under the MIT License (the "License"); you may not use this file except in compliance with the License. You may obtain a copy of the License at
 * http://opensource.org/licenses/MIT
 * Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.
 */
//
//  UIImage+QMUITheme.h
//  QMUIKit
//
//  Created by MoLice on 2019/J/16.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class QMUIThemeManager;

@protocol QMUIDynamicImageProtocol <NSObject>

@required

/// 获取当前 UIImage 的实际图片（返回的图片必定不是 dynamic image）
@property(nonatomic, strong, readonly) UIImage *qmui_rawImage;

/// 标志当前 UIImage 对象是否为动态图片（由 [UIImage qmui_imageWithThemeProvider:] 创建的颜色
@property(nonatomic, assign, readonly) BOOL qmui_isDynamicImage;

@end

@interface UIImage (QMUITheme) <QMUIDynamicImageProtocol>

/**
 生成一个动态的 image 对象，每次使用该图片时都会动态根据当前的 QMUIThemeManager 主题返回对应的图片。
 @param provider 当 image 被使用时，这个 provider 会被调用，返回对应当前主题的 image 值
 @return 当前主题下的实际图片，由 provider 返回
 */
+ (UIImage *)qmui_imageWithThemeProvider:(UIImage *(^)(__kindof QMUIThemeManager *manager, __kindof NSObject<NSCopying> * _Nullable identifier, __kindof NSObject * _Nullable theme))provider;

/**
 生成一个动态的 image 对象，每次使用该图片时都会动态根据当前的 QMUIThemeManager name 和主题返回对应的图片。
 @param name themeManager 的 name，用于区分不同维度的主题管理器
 @param provider 当 image 被使用时，这个 provider 会被调用，返回对应当前主题的 image 值
 @return 当前主题下的实际图片，由 provider 返回
*/
+ (UIImage *)qmui_imageWithThemeManagerName:(__kindof NSObject<NSCopying> *)name provider:(UIImage *(^)(__kindof QMUIThemeManager *manager, __kindof NSObject<NSCopying> * _Nullable identifier, __kindof NSObject * _Nullable theme))provider;

@end

NS_ASSUME_NONNULL_END
