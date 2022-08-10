/**
 * Tencent is pleased to support the open source community by making QMUI_iOS available.
 * Copyright (C) 2016-2021 THL A29 Limited, a Tencent company. All rights reserved.
 * Licensed under the MIT License (the "License"); you may not use this file except in compliance with the License. You may obtain a copy of the License at
 * http://opensource.org/licenses/MIT
 * Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.
 */

//
//  UIActivityIndicatorView+QMUI.m
//  qmui
//
//  Created by QMUI Team on 15/7/20.
//

#import "UIActivityIndicatorView+QMUI.h"
#import "UIView+QMUI.h"

@implementation UIActivityIndicatorView (QMUI)

- (instancetype)initWithActivityIndicatorStyle:(UIActivityIndicatorViewStyle)style size:(CGSize)size {
    if (self = [self initWithActivityIndicatorStyle:style]) {
        self.qmui_size = size;
    }
    return self;
}

- (void)setQmui_size:(CGSize)size {
//    [super setQmui_size:qmui_size];
    CGSize initialSize = self.bounds.size;
    CGFloat scale = size.width / initialSize.width;
    self.transform = CGAffineTransformMakeScale(scale, scale);
}

@end
