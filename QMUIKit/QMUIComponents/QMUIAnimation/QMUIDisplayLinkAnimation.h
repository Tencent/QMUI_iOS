/**
 * Tencent is pleased to support the open source community by making QMUI_iOS available.
 * Copyright (C) 2016-2021 THL A29 Limited, a Tencent company. All rights reserved.
 * Licensed under the MIT License (the "License"); you may not use this file except in compliance with the License. You may obtain a copy of the License at
 * http://opensource.org/licenses/MIT
 * Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.
 */
//
//  QMUIDisplayLinkAnimation.h
//  WeRead
//
//  Created by zhoonchen on 2018/9/3.
//

#import <UIKit/UIKit.h>
#import "QMUIAnimationHelper.h"

#define SpringAnimationDefaultDuration 0.5


/*
 * 通过 CADisplayLink 来做动画，接口尽可能模拟 CAAnimation。有如下好处：
 * 1、跟随系统刷新频率
 * 2、因为使用了 CADisplayLink，所以理论上所有数据都可以做动画，而不局限于 CALayer 的 UI 属性
 * 3、避免 CAAnimation 有时候系统会自动暂停（例如 app 退到后台再进来，或者切到其他界面再回来）
 * 4、更多动画曲线可以选择，包括弹簧动画以及类似系统的键盘曲线动画。
 * @warning: ⚠️⚠️⚠️ 当动画是无限循环的时候，需要在某个时机去 stop 动画（例如 dealloc 里面），否则 `QMUIDisplayLinkAnimation` 对象永远都不会释放，对应的 CADisplayLink 在后台都会被调用。
 */

@interface QMUIDisplayLinkAnimation : NSObject

@property(nonatomic, strong, readonly) CADisplayLink *displayLink;

@property(nonatomic, strong) id fromValue;
@property(nonatomic, strong) id toValue;

/// 动画时间
@property(nonatomic, assign) NSTimeInterval duration;

/// 动画曲线
@property(nonatomic, assign) QMUIAnimationEasings easing;

/// 是否需要重复，如果设置为YES，那么会无限重复动画，默认NO
/// TODO: 目前功能上不支持小数点的循环次数，例如 0.5 1.5
@property(nonatomic, assign) BOOL repeat;

/// 延迟开始动画
@property(nonatomic, assign) NSTimeInterval beginTime;

/// 只有设置了repeat之后这个值才有用
@property(nonatomic, assign) float repeatCount;

/// 只有设置了repeat之后这个值才有用。如果YES，则往前做动画之后自动往后做动画，默认NO
@property(nonatomic, assign) BOOL autoreverses;

/// 做动画的block，适用于只有一个属性需要做动画，curValue是经过计算后当前帧的值
@property(nonatomic, copy) void (^animation)(id curValue);

/// 做动画的block，适用于多个属性做动画，需要在block里面自己计算当前帧的所有属性的值
@property(nonatomic, copy) void (^animations)(QMUIDisplayLinkAnimation *animation, CGFloat curTime);

- (instancetype)initWithDuration:(NSTimeInterval)duration
                          easing:(QMUIAnimationEasings)easing
                       fromValue:(id)fromValue
                         toValue:(id)toValue
                       animation:(void (^)(id curValue))animation;

- (instancetype)initWithDuration:(NSTimeInterval)duration
                          easing:(QMUIAnimationEasings)easing
                      animations:(void (^)(QMUIDisplayLinkAnimation *animation, CGFloat curTime))animations;

/// 开始动画，无论是第一次做动画或者暂停之后再重新做动画，都调用这个方法
- (void)startAnimation;

/// 停止动画，CADisplayLink 对象会被移出
- (void)stopAnimation;

/// 即将开始做动画
@property(nonatomic, copy) void (^willStartAnimation)(void);

/// 动画结束
@property(nonatomic, copy) void (^didStopAnimation)(void);

@end


@interface QMUIDisplayLinkAnimation (ConvenienceClassMethod)

/*
 * 这些类方法在动画执行之后会自动销毁 QMUIDisplayLinkAnimation 对象，因为此时没有人持有这个对象（有个坑就是如果这个动画是无限循环的，那么就一直无法销毁，需要业务手动销毁）。如果想要持有对象以便在后续操作，可以把返回值保存到其他属性里面。
 * `createdBlock` 是 animation 创建之后，开始动画之前的回调，一般用来设置 animation 属性，比如是否重复动画以及重复的次数。
 * `didStopBlock` 是动画结束之后的回调。
 * @warning: block 中的代码记得使用弱引用，以免内存泄漏。
 */

+ (instancetype)springAnimateWithFromValue:(id)fromValue
                                   toValue:(id)toValue
                                 animation:(void (^)(id curValue))animation
                              createdBlock:(void (^)(QMUIDisplayLinkAnimation *animation))createdBlock;

+ (instancetype)animateWithDuration:(NSTimeInterval)duration
                             easing:(QMUIAnimationEasings)easing
                          fromValue:(id)fromValue
                            toValue:(id)toValue
                          animation:(void (^)(id curValue))animation;

+ (instancetype)animateWithDuration:(NSTimeInterval)duration
                             easing:(QMUIAnimationEasings)easing
                          fromValue:(id)fromValue
                            toValue:(id)toValue
                          animation:(void (^)(id curValue))animation
                       createdBlock:(void (^)(QMUIDisplayLinkAnimation *animation))createdBlock;

+ (instancetype)animateWithDuration:(NSTimeInterval)duration
                             easing:(QMUIAnimationEasings)easing
                          fromValue:(id)fromValue
                            toValue:(id)toValue
                          animation:(void (^)(id curValue))animation
                       createdBlock:(void (^)(QMUIDisplayLinkAnimation *animation))createdBlock
                       didStopBlock:(void (^)(QMUIDisplayLinkAnimation *animation))didStopBlock;

+ (instancetype)springAnimateWithAnimations:(void (^)(QMUIDisplayLinkAnimation *animation, CGFloat curTime))animations
                               createdBlock:(void (^)(QMUIDisplayLinkAnimation *animation))createdBlock;

+ (instancetype)animateWithDuration:(NSTimeInterval)duration
                             easing:(QMUIAnimationEasings)easing
                         animations:(void (^)(QMUIDisplayLinkAnimation *animation, CGFloat curTime))animations;

+ (instancetype)animateWithDuration:(NSTimeInterval)duration
                             easing:(QMUIAnimationEasings)easing
                         animations:(void (^)(QMUIDisplayLinkAnimation *animation, CGFloat curTime))animations
                       createdBlock:(void (^)(QMUIDisplayLinkAnimation *animation))createdBlock;

+ (instancetype)animateWithDuration:(NSTimeInterval)duration
                             easing:(QMUIAnimationEasings)easing
                         animations:(void (^)(QMUIDisplayLinkAnimation *animation, CGFloat curTime))animations
                       createdBlock:(void (^)(QMUIDisplayLinkAnimation *animation))createdBlock
                       didStopBlock:(void (^)(QMUIDisplayLinkAnimation *animation))didStopBlock;

@end
