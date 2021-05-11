/**
 * Tencent is pleased to support the open source community by making QMUI_iOS available.
 * Copyright (C) 2016-2021 THL A29 Limited, a Tencent company. All rights reserved.
 * Licensed under the MIT License (the "License"); you may not use this file except in compliance with the License. You may obtain a copy of the License at
 * http://opensource.org/licenses/MIT
 * Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.
 */
//
//  QMUIDisplayLinkAnimation.m
//  WeRead
//
//  Created by zhoonchen on 2018/9/3.
//

#import "QMUIDisplayLinkAnimation.h"
#import "QMUICore.h"

@interface QMUIDisplayLinkAnimation ()

@property(nonatomic, strong, readwrite) CADisplayLink *displayLink;

@property(nonatomic, assign) NSTimeInterval timeOffset;
@property(nonatomic, assign) NSInteger curRepeatCount;
@property(nonatomic, assign) BOOL isReversing;

@end

@implementation QMUIDisplayLinkAnimation

- (instancetype)init {
    self = [super init];
    if (self) {
        self.displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(handleDisplayLink:)];
        self.fromValue = nil;
        self.toValue = nil;
        self.duration = 0;
        self.repeatCount = 0;
        self.easing = QMUIAnimationEasingsLinear;
        self.timeOffset = 0;
        self.animation = nil;
    }
    return self;
}

- (instancetype)initWithDuration:(CFTimeInterval)duration
                          easing:(QMUIAnimationEasings)easing
                       fromValue:(id)fromValue
                         toValue:(id)toValue
                       animation:(void (^)(id curValue))animation {
    if (self = [self init]) {
        self.duration = duration;
        self.easing = easing;
        self.fromValue = fromValue;
        self.toValue = toValue;
        self.animation = animation;
    }
    return self;
}

- (instancetype)initWithDuration:(CFTimeInterval)duration
                          easing:(QMUIAnimationEasings)easing
                      animations:(void (^)(QMUIDisplayLinkAnimation *animation, CGFloat curTime))animations {
    if (self = [self init]) {
        self.duration = duration;
        self.easing = easing;
        self.animations = animations;
    }
    return self;
}

- (void)dealloc {
    [_displayLink invalidate];
    _displayLink = nil;
}

- (void)startAnimation {
    if (!self.displayLink) {
        NSAssert(NO, @"QMUIDisplayLinkAnimation 使用错误，当前没有 CADisplayLink 对象，请查看头文件再试试。");
        return;
    }
    if (self.displayLink.paused) {
        self.displayLink.paused = NO;
        return;
    }
    if (self.beginTime > 0) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(self.beginTime * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            if (self.displayLink) {
                if (self.willStartAnimation) {
                    self.willStartAnimation();
                }
                [self.displayLink addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSRunLoopCommonModes];
            }
        });
    } else {
        if (self.willStartAnimation) {
            self.willStartAnimation();
        }
        [self.displayLink addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSRunLoopCommonModes];
    }
}

- (void)stopAnimation {
    [self.displayLink invalidate];
    self.displayLink = nil;
    if (self.didStopAnimation) {
        self.didStopAnimation();
    }
}

- (void)handleDisplayLink:(CADisplayLink *)displayLink {
    if (!self.animation && !self.animations) {
        NSAssert(NO, @"没有动画Block");
        return;
    }
    NSTimeInterval oneFrame = 1.0 / [self preferredFramesPerSecond];
    if (self.autoreverses && self.isReversing) {
        self.timeOffset = MAX(self.timeOffset - oneFrame, 0);
    } else {
        self.timeOffset = MIN(self.timeOffset + oneFrame, self.duration);
    }
    CGFloat time = self.timeOffset / self.duration;
    if (self.animations) {
        self.animations(self, time);
    } else if (self.animation) {
        id curValue = [QMUIAnimationHelper interpolateFromValue:self.fromValue toValue:self.toValue time:time easing:self.easing];
        self.animation(curValue);
    }
    if (self.timeOffset >= self.duration) {
        [self beginToDecrease];
    } else if (self.timeOffset <= 0) {
        [self beginToIncrease];
    }
}

- (void)beginToIncrease {
    if (self.repeat && self.repeatCount > 0) {
        self.curRepeatCount++;
    }
    if (self.autoreverses) {
        self.isReversing = NO;
    }
    if (self.curRepeatCount >= self.repeatCount) {
        [self stopAnimation];
    }
}

- (void)beginToDecrease {
    if (self.repeat && self.repeatCount > 0) {
        self.curRepeatCount++;
    }
    if (self.repeat) {
        if (self.autoreverses) {
            self.isReversing = YES;
        } else {
            self.timeOffset = 0;
        }
        if (self.curRepeatCount >= self.repeatCount) {
            [self stopAnimation];
        }
    } else {
        [self stopAnimation];
    }
}

- (NSInteger)preferredFramesPerSecond {
    if (self.displayLink.preferredFramesPerSecond == 0) {
        // 不能写死60，而要拿当前设备支持的最大帧率来计算。根据 CADisplayLink 的官方文档，如果返回一个超过当前设备实际帧率的数字，实际依然会用设备实际帧率来计算，所以不用担心设备降频导致帧率降低后动画时长是否有问题。
        return UIScreen.mainScreen.maximumFramesPerSecond;
    }
    return self.displayLink.preferredFramesPerSecond;
}

@end


@implementation QMUIDisplayLinkAnimation (ConvenienceClassMethod)

+ (instancetype)springAnimateWithFromValue:(id)fromValue
                                   toValue:(id)toValue
                                 animation:(void (^)(id curValue))animation
                              createdBlock:(void (^)(QMUIDisplayLinkAnimation *animation))createdBlock {
    return [self animateWithDuration:SpringAnimationDefaultDuration
                              easing:QMUIAnimationEasingsSpringKeyboard
                           fromValue:fromValue
                             toValue:toValue
                           animation:animation
                        createdBlock:createdBlock];
}

+ (instancetype)animateWithDuration:(NSTimeInterval)duration
                             easing:(QMUIAnimationEasings)easing
                          fromValue:(id)fromValue
                            toValue:(id)toValue
                          animation:(void (^)(id curValue))animation {
    return [self animateWithDuration:duration
                              easing:easing
                           fromValue:fromValue
                             toValue:toValue
                           animation:animation
                        createdBlock:nil];
}

+ (instancetype)animateWithDuration:(NSTimeInterval)duration
                             easing:(QMUIAnimationEasings)easing
                          fromValue:(id)fromValue
                            toValue:(id)toValue
                          animation:(void (^)(id curValue))animation
                       createdBlock:(void (^)(QMUIDisplayLinkAnimation *animation))createdBlock {
    return [self animateWithDuration:duration
                              easing:easing
                           fromValue:fromValue
                             toValue:toValue
                           animation:animation
                        createdBlock:createdBlock
                        didStopBlock:nil];
}

+ (instancetype)animateWithDuration:(NSTimeInterval)duration
                             easing:(QMUIAnimationEasings)easing
                          fromValue:(id)fromValue
                            toValue:(id)toValue
                          animation:(void (^)(id curValue))animation
                       createdBlock:(void (^)(QMUIDisplayLinkAnimation *animation))createdBlock
                       didStopBlock:(void (^)(QMUIDisplayLinkAnimation *animation))didStopBlock {
    QMUIDisplayLinkAnimation *displayLinkAnimation = [[self alloc] initWithDuration:duration
                                                                                                 easing:easing
                                                                                              fromValue:fromValue
                                                                                                toValue:toValue
                                                                                              animation:animation];
    if (createdBlock) {
        createdBlock(displayLinkAnimation);
    }
    __weak QMUIDisplayLinkAnimation *weakDisplayLinkAnimation = displayLinkAnimation;
    displayLinkAnimation.didStopAnimation = ^{
        if (didStopBlock) {
            didStopBlock(weakDisplayLinkAnimation);
        }
    };
    [displayLinkAnimation startAnimation];
    return displayLinkAnimation;
}

+ (instancetype)springAnimateWithAnimations:(void (^)(QMUIDisplayLinkAnimation *animation, CGFloat curTime))animations
                               createdBlock:(void (^)(QMUIDisplayLinkAnimation *animation))createdBlock {
    return [self animateWithDuration:SpringAnimationDefaultDuration
                              easing:QMUIAnimationEasingsSpringKeyboard
                          animations:animations
                        createdBlock:createdBlock];
}

+ (instancetype)animateWithDuration:(NSTimeInterval)duration
                             easing:(QMUIAnimationEasings)easing
                         animations:(void (^)(QMUIDisplayLinkAnimation *animation, CGFloat curTime))animations {
    return [self animateWithDuration:duration
                              easing:easing
                          animations:animations
                        createdBlock:nil];
}

+ (instancetype)animateWithDuration:(NSTimeInterval)duration
                             easing:(QMUIAnimationEasings)easing
                         animations:(void (^)(QMUIDisplayLinkAnimation *animation, CGFloat curTime))animations
                       createdBlock:(void (^)(QMUIDisplayLinkAnimation *animation))createdBlock {
    return [self animateWithDuration:duration
                              easing:easing
                          animations:animations
                        createdBlock:createdBlock
                        didStopBlock:nil];
}

+ (instancetype)animateWithDuration:(NSTimeInterval)duration
                             easing:(QMUIAnimationEasings)easing
                         animations:(void (^)(QMUIDisplayLinkAnimation *animation, CGFloat curTime))animations
                       createdBlock:(void (^)(QMUIDisplayLinkAnimation *animation))createdBlock
                       didStopBlock:(void (^)(QMUIDisplayLinkAnimation *animation))didStopBlock {
    QMUIDisplayLinkAnimation *displayLinkAnimation = [[self alloc] initWithDuration:duration
                                                                                                 easing:easing
                                                                                             animations:animations];
    if (createdBlock) {
        createdBlock(displayLinkAnimation);
    }
    __weak QMUIDisplayLinkAnimation *weakDisplayLinkAnimation = displayLinkAnimation;
    displayLinkAnimation.didStopAnimation = ^{
        if (didStopBlock) {
            didStopBlock(weakDisplayLinkAnimation);
        }
    };
    [displayLinkAnimation startAnimation];
    return displayLinkAnimation;
}

@end
