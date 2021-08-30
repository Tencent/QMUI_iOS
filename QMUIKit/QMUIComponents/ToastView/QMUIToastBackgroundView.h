/**
 * Tencent is pleased to support the open source community by making QMUI_iOS available.
 * Copyright (C) 2016-2021 THL A29 Limited, a Tencent company. All rights reserved.
 * Licensed under the MIT License (the "License"); you may not use this file except in compliance with the License. You may obtain a copy of the License at
 * http://opensource.org/licenses/MIT
 * Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.
 */

//
//  QMUIToastBackgroundView.h
//  qmui
//
//  Created by QMUI Team on 2016/12/11.
//

#import <UIKit/UIKit.h>

@interface QMUIToastBackgroundView : UIView

/**
 * 是否需要磨砂，默认NO。仅支持iOS8及以上版本。可以通过修改`styleColor`来控制磨砂的效果。
 */
@property(nonatomic, assign) BOOL shouldBlurBackgroundView;

@property(nullable, nonatomic, strong, readonly) UIVisualEffectView *effectView;

/**
 * 如果不设置磨砂，则styleColor直接作为`QMUIToastBackgroundView`的backgroundColor；如果需要磨砂，则会新增加一个`UIVisualEffectView`放在`QMUIToastBackgroundView`上面。
 */
@property(nullable, nonatomic, strong) UIColor *styleColor UI_APPEARANCE_SELECTOR;

/**
 * 设置圆角。
 */
@property(nonatomic, assign) CGFloat cornerRadius UI_APPEARANCE_SELECTOR;

@end
