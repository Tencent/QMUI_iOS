/**
 * Tencent is pleased to support the open source community by making QMUI_iOS available.
 * Copyright (C) 2016-2021 THL A29 Limited, a Tencent company. All rights reserved.
 * Licensed under the MIT License (the "License"); you may not use this file except in compliance with the License. You may obtain a copy of the License at
 * http://opensource.org/licenses/MIT
 * Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.
 */
//
//  UICollectionViewCell+QMUI.m
//  QMUIKit
//
//  Created by MoLice on 2021/M/9.
//

#import "UICollectionViewCell+QMUI.h"
#import "QMUICore.h"

@interface UICollectionViewCell ()
@property(nonatomic, strong) UIView *qmuicvc_selectedBackgroundView;
@end

@implementation UICollectionViewCell (QMUI)

QMUISynthesizeIdStrongProperty(qmuicvc_selectedBackgroundView, setQmuicvc_selectedBackgroundView)

static char kAssociatedObjectKey_selectedBackgroundColor;
- (void)setQmui_selectedBackgroundColor:(UIColor *)qmui_selectedBackgroundColor {
    objc_setAssociatedObject(self, &kAssociatedObjectKey_selectedBackgroundColor, qmui_selectedBackgroundColor, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    if (qmui_selectedBackgroundColor && !self.selectedBackgroundView && !self.qmuicvc_selectedBackgroundView) {
        self.qmuicvc_selectedBackgroundView = UIView.new;
        self.selectedBackgroundView = self.qmuicvc_selectedBackgroundView;
    }
    if (self.qmuicvc_selectedBackgroundView) {
        self.qmuicvc_selectedBackgroundView.backgroundColor = qmui_selectedBackgroundColor;
    }
}

- (UIColor *)qmui_selectedBackgroundColor {
    return (UIColor *)objc_getAssociatedObject(self, &kAssociatedObjectKey_selectedBackgroundColor);
}

@end
