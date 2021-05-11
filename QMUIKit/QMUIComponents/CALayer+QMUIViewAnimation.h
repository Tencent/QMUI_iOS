/**
 * Tencent is pleased to support the open source community by making QMUI_iOS available.
 * Copyright (C) 2016-2021 THL A29 Limited, a Tencent company. All rights reserved.
 * Licensed under the MIT License (the "License"); you may not use this file except in compliance with the License. You may obtain a copy of the License at
 * http://opensource.org/licenses/MIT
 * Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.
 */
//
//  CALayer+QMUIViewAnimation.h
//  QMUIKit
//
//  Created by ziezheng on 2020/4/4.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface CALayer (QMUIViewAnimation)

/**
 开启了该属性的 CALayer 可在 +[UIView animateWithDuration:animations:]  执行动画，系统默认是不支持这种做法的。
 
 @code
 [UIView animateWithDuration:1 animations:^{
     layer.frame = xxx;
 } completion:nil];
 @endcode
 */
@property(nonatomic, assign) BOOL qmui_viewAnimationEnabled;

@end

NS_ASSUME_NONNULL_END
