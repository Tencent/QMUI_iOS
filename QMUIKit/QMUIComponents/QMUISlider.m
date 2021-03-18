/**
 * Tencent is pleased to support the open source community by making QMUI_iOS available.
 * Copyright (C) 2016-2020 THL A29 Limited, a Tencent company. All rights reserved.
 * Licensed under the MIT License (the "License"); you may not use this file except in compliance with the License. You may obtain a copy of the License at
 * http://opensource.org/licenses/MIT
 * Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.
 */

//
//  QMUISlider.m
//  qmui
//
//  Created by QMUI Team on 2017/6/1.
//

#import "QMUISlider.h"
#import "QMUICore.h"
#import "UIImage+QMUI.h"

@implementation QMUISlider

- (void)setThumbSize:(CGSize)thumbSize {
    _thumbSize = thumbSize;
    [self updateThumbImage];
}

- (void)setThumbColor:(UIColor *)thumbColor {
    _thumbColor = thumbColor;
    [self updateThumbImage];
}

- (void)updateThumbImage {
    if (!CGSizeIsEmpty(self.thumbSize)) {
        UIColor *thumbColor = self.thumbColor ?: self.tintColor;
        UIImage *thumbImage = [UIImage qmui_imageWithShape:QMUIImageShapeOval size:_thumbSize tintColor:thumbColor];
        [self setThumbImage:thumbImage forState:UIControlStateNormal];
        [self setThumbImage:thumbImage forState:UIControlStateHighlighted];
    }
}

- (void)setThumbShadowColor:(UIColor *)thumbShadowColor {
    _thumbShadowColor = thumbShadowColor;
    UIView *thumbView = [self thumbViewIfExist];
    if (thumbView) {
        thumbView.layer.shadowColor = _thumbShadowColor.CGColor;
        thumbView.layer.shadowOpacity = _thumbShadowColor ? 1 : 0;
    }
}

- (void)setThumbShadowOffset:(CGSize)thumbShadowOffset {
    _thumbShadowOffset = thumbShadowOffset;
    UIView *thumbView = [self thumbViewIfExist];
    if (thumbView) {
        thumbView.layer.shadowOffset = _thumbShadowOffset;
    }
}

- (void)setThumbShadowRadius:(CGFloat)thumbShadowRadius {
    _thumbShadowRadius = thumbShadowRadius;
    UIView *thumbView = [self thumbViewIfExist];
    if (thumbView) {
        thumbView.layer.shadowRadius = thumbShadowRadius;
    }
}

- (UIView *)thumbViewIfExist {
    // thumbView 并非在一开始就存在，而是在某个时机才生成的，所以可能返回 nil
    UIView *thumbView = [self qmui_valueForKey:@"thumbView"];
    return thumbView;
}

#pragma mark - Override

- (CGRect)trackRectForBounds:(CGRect)bounds {
    CGRect result = [super trackRectForBounds:bounds];
    if (self.trackHeight == 0) {
        return result;
    }
    
    result = CGRectSetHeight(result, self.trackHeight);
    result = CGRectSetY(result, CGFloatGetCenter(CGRectGetHeight(bounds), CGRectGetHeight(result)));
    return result;
}

- (void)didAddSubview:(UIView *)subview {
    [super didAddSubview:subview];
    if (subview && subview == [self thumbViewIfExist]) {
        UIView *thumbView = subview;
        thumbView.layer.shadowColor = self.thumbShadowColor.CGColor;
        thumbView.layer.shadowOpacity = self.thumbShadowColor ? 1 : 0;
        thumbView.layer.shadowOffset = self.thumbShadowOffset;
        thumbView.layer.shadowRadius = self.thumbShadowRadius;
    }
}

@end
