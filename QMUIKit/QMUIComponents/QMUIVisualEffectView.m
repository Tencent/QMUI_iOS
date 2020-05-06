/**
 * Tencent is pleased to support the open source community by making QMUI_iOS available.
 * Copyright (C) 2016-2020 THL A29 Limited, a Tencent company. All rights reserved.
 * Licensed under the MIT License (the "License"); you may not use this file except in compliance with the License. You may obtain a copy of the License at
 * http://opensource.org/licenses/MIT
 * Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.
 */

//
//  QMUIVisualEffectView.m
//  QMUIKit
//
//  Created by QMUI Team on 2018/6/19.
//

#import "QMUIVisualEffectView.h"
#import "QMUICore.h"
#import "CALayer+QMUI.h"
#import "CALayer+QMUIViewAnimation.h"

@interface QMUIVisualEffectView ()

@property(nonatomic, strong) CALayer *foregroundLayer;

@end

@implementation QMUIVisualEffectView

- (instancetype)initWithEffect:(nullable UIVisualEffect *)effect {
    if (self = [super initWithEffect:effect]) {
        [self didInitialize];
    }
    return self;
}

- (nullable instancetype)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
        [self didInitialize];
    }
    return self;
}

- (void)didInitialize {
    self.foregroundLayer = [CALayer layer];
    self.foregroundLayer.qmui_viewAnimaitonEnabled = YES;
    [self.foregroundLayer qmui_removeDefaultAnimations];
    [self.contentView.layer addSublayer:self.foregroundLayer];
}

- (void)setForegroundColor:(UIColor *)foregroundColor {
    _foregroundColor = foregroundColor;
    self.foregroundLayer.backgroundColor = foregroundColor.CGColor;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    self.foregroundLayer.frame = self.contentView.bounds;
}

@end
