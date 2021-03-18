/**
 * Tencent is pleased to support the open source community by making QMUI_iOS available.
 * Copyright (C) 2016-2020 THL A29 Limited, a Tencent company. All rights reserved.
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

@interface UIActivityIndicatorView (QMUI)

/**
 * 创建一个指定大小的UIActivityIndicatorView
 *
 * 系统的UIActivityIndicatorView尺寸是由UIActivityIndicatorViewStyle决定的，固定不变。因此创建后通过CGAffineTransformMakeScale将其缩放到指定大小。self.frame获取的值也是缩放后的值，不影响布局。
 *
 * @param style UIActivityIndicatorViewStyle
 * @param size  UIActivityIndicatorView的大小
 *
 * @return UIActivityIndicatorView对象
 */
- (instancetype)initWithActivityIndicatorStyle:(UIActivityIndicatorViewStyle)style size:(CGSize)size;

@end
