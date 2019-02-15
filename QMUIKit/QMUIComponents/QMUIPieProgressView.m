/*****
 * Tencent is pleased to support the open source community by making QMUI_iOS available.
 * Copyright (C) 2016-2019 THL A29 Limited, a Tencent company. All rights reserved.
 * Licensed under the MIT License (the "License"); you may not use this file except in compliance with the License. You may obtain a copy of the License at
 * http://opensource.org/licenses/MIT
 * Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.
 *****/

//
//  QMUIPieProgressView.m
//  qmui
//
//  Created by QMUI Team on 15/9/8.
//

#import "QMUIPieProgressView.h"
#import "QMUICore.h"

@interface QMUIPieProgressLayer : CALayer

@property(nonatomic, strong) UIColor *fillColor;
@property(nonatomic, assign) float progress;
@property(nonatomic, assign) CFTimeInterval progressAnimationDuration;
@property(nonatomic, assign) BOOL shouldChangeProgressWithAnimation; // default is YES
@property(nonatomic, assign) CGFloat borderInset;
@end

@implementation QMUIPieProgressLayer
// 加dynamic才能让自定义的属性支持动画
@dynamic fillColor;
@dynamic progress;

- (instancetype)init {
    if (self = [super init]) {
        self.shouldChangeProgressWithAnimation = YES;
    }
    return self;
}

+ (BOOL)needsDisplayForKey:(NSString *)key {
    return [key isEqualToString:@"progress"] || [super needsDisplayForKey:key];
}

- (id<CAAction>)actionForKey:(NSString *)event {
    if ([event isEqualToString:@"progress"] && self.shouldChangeProgressWithAnimation) {
        CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:event];
        animation.fromValue = [self.presentationLayer valueForKey:event];
        animation.duration = self.progressAnimationDuration;
        return animation;
    }
    return [super actionForKey:event];
}

- (void)drawInContext:(CGContextRef)context {
    if (CGRectIsEmpty(self.bounds)) {
        return;
    }
    
    // 绘制扇形进度区域
    CGPoint center = CGPointGetCenterWithRect(self.bounds);
    CGFloat radius = MIN(center.x, center.y) - self.borderWidth - self.borderInset;
    CGFloat startAngle = -M_PI_2;
    CGFloat endAngle = M_PI * 2 * self.progress + startAngle;
    CGContextSetFillColorWithColor(context, self.fillColor.CGColor);
    CGContextMoveToPoint(context, center.x, center.y);
    CGContextAddArc(context, center.x, center.y, radius, startAngle, endAngle, 0);
    CGContextClosePath(context);
    CGContextFillPath(context);
    
    [super drawInContext:context];
}

- (void)setFrame:(CGRect)frame {
    [super setFrame:frame];
    self.cornerRadius = CGRectGetHeight(frame) / 2;
}

@end

@implementation QMUIPieProgressView

+ (Class)layerClass {
    return [QMUIPieProgressLayer class];
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = UIColorClear;
        self.tintColor = UIColorBlue;
        self.borderWidth = 1;
        self.borderInset = 0;
        
        [self didInitialize];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
        [self didInitialize];
        // 从 xib 初始化的话，在 IB 里设置了 tintColor 也不会触发 tintColorDidChange，所以这里手动调用一下
        [self tintColorDidChange];
    }
    return self;
}

- (void)didInitialize {
    self.progress = 0.0;
    self.progressAnimationDuration = 0.5;
    
    self.layer.contentsScale = ScreenScale;// 要显示指定一个倍数
    [self.layer setNeedsDisplay];
}

- (void)setProgress:(float)progress {
    [self setProgress:progress animated:NO];
}

- (void)setProgress:(float)progress animated:(BOOL)animated {
    _progress = fmax(0.0, fmin(1.0, progress));
    QMUIPieProgressLayer *layer = (QMUIPieProgressLayer *)self.layer;
    layer.shouldChangeProgressWithAnimation = animated;
    layer.progress = _progress;
    
    [self sendActionsForControlEvents:UIControlEventValueChanged];
}

- (void)setProgressAnimationDuration:(CFTimeInterval)progressAnimationDuration {
    _progressAnimationDuration = progressAnimationDuration;
    self.progressLayer.progressAnimationDuration = progressAnimationDuration;
}

- (void)setBorderWidth:(CGFloat)borderWidth {
    _borderWidth = borderWidth;
    self.layer.borderWidth = borderWidth;
}

- (void)setBorderInset:(CGFloat)borderInset {
    _borderInset = borderInset;
    self.progressLayer.borderInset = borderInset;
}

- (void)tintColorDidChange {
    [super tintColorDidChange];
    self.progressLayer.fillColor = self.tintColor;
    self.progressLayer.borderColor = self.tintColor.CGColor;
}

- (QMUIPieProgressLayer *)progressLayer {
    return (QMUIPieProgressLayer *)self.layer;
}

@end
