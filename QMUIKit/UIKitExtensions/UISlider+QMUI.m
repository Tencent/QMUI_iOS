/**
 * Tencent is pleased to support the open source community by making QMUI_iOS available.
 * Copyright (C) 2016-2021 THL A29 Limited, a Tencent company. All rights reserved.
 * Licensed under the MIT License (the "License"); you may not use this file except in compliance with the License. You may obtain a copy of the License at
 * http://opensource.org/licenses/MIT
 * Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.
 */
//
//  UISlider+QMUI.m
//  QMUIKit
//
//  Created by MoLice on 2021/D/10.
//

#import "UISlider+QMUI.h"
#import "QMUICore.h"
#import "NSNumber+QMUI.h"
#import "UIImage+QMUI.h"
#import "UIView+QMUI.h"
#import "UILabel+QMUI.h"

@interface UISlider ()

@property(nonatomic, strong) NSMutableArray<QMUISliderStepControl *> *qmuisl_stepControls;
@property(nonatomic, copy) NSString *qmuisl_layoutCachedKey;
@property(nonatomic, assign) NSUInteger qmuisl_precedingStep;
@end

@implementation UISlider (QMUI)

QMUISynthesizeIdStrongProperty(qmuisl_stepControls, setQmuisl_stepControls)
QMUISynthesizeIdCopyProperty(qmuisl_layoutCachedKey, setQmuisl_layoutCachedKey)
QMUISynthesizeNSUIntegerProperty(qmuisl_precedingStep, setQmuisl_precedingStep)
QMUISynthesizeIdCopyProperty(qmui_stepDidChangeBlock, setQmui_stepDidChangeBlock)

- (UIView *)qmui_thumbView {
    // thumbView 并非在一开始就存在，而是在某个时机才生成的。如果使用了自己的 thumbImage，则系统用 _thumbView 来显示。如果没用自己的 thumbImage，则系统用 _innerThumbView 来存放。注意如果是 _innerThumbView，它外部还有一个 _thumbViewNeue 用来控制布局。
    UIView *slider = self;
    if (@available(iOS 14.0, *)) {
        slider = [self qmui_valueForKey:@"_visualElement"];
    }
    if (!slider) return nil;

    UIView *thumbView = [slider qmui_valueForKey:@"thumbView"] ?: [slider qmui_valueForKey:@"innerThumbView"];
    return thumbView;
}

static char kAssociatedObjectKey_trackHeight;
- (void)setQmui_trackHeight:(CGFloat)trackHeight {
    objc_setAssociatedObject(self, &kAssociatedObjectKey_trackHeight, @(trackHeight), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    if (trackHeight <= 0) return;
    
    [QMUIHelper executeBlock:^{
        OverrideImplementation([UISlider class], @selector(trackRectForBounds:), ^id(__unsafe_unretained Class originClass, SEL originCMD, IMP (^originalIMPProvider)(void)) {
            return ^CGRect(UISlider *selfObject, CGRect bounds) {
                
                // call super
                CGRect (*originSelectorIMP)(id, SEL, CGRect);
                originSelectorIMP = (CGRect (*)(id, SEL, CGRect))originalIMPProvider();
                CGRect result = originSelectorIMP(selfObject, originCMD, bounds);
                
                if (selfObject.qmui_trackHeight > 0) {
                    result = CGRectSetHeight(result, selfObject.qmui_trackHeight);
                    result = CGRectSetY(result, CGFloatGetCenter(CGRectGetHeight(bounds), CGRectGetHeight(result)));
                }
                
                return result;
            };
        });
    } oncePerIdentifier:@"UISlider (QMUI) trackHeight"];
    
    [self setNeedsLayout];
}

- (CGFloat)qmui_trackHeight {
    return [((NSNumber *)objc_getAssociatedObject(self, &kAssociatedObjectKey_trackHeight)) qmui_CGFloatValue];
}

static char kAssociatedObjectKey_thumbSize;
- (void)setQmui_thumbSize:(CGSize)thumbSize {
    objc_setAssociatedObject(self, &kAssociatedObjectKey_thumbSize, @(thumbSize), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    if (CGSizeIsEmpty(thumbSize)) return;
    [self qmuisl_updateThumbImage];
}

- (CGSize)qmui_thumbSize {
    return [((NSNumber *)objc_getAssociatedObject(self, &kAssociatedObjectKey_thumbSize)) CGSizeValue];
}

static char kAssociatedObjectKey_thumbColor;
- (void)setQmui_thumbColor:(UIColor *)thumbColor {
    objc_setAssociatedObject(self, &kAssociatedObjectKey_thumbColor, thumbColor, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    [self qmuisl_updateThumbImage];
}

- (UIColor *)qmui_thumbColor {
    return (UIColor *)objc_getAssociatedObject(self, &kAssociatedObjectKey_thumbColor);
}

- (void)qmuisl_updateThumbImage {
    if (!CGSizeIsEmpty(self.qmui_thumbSize)) {
        UIColor *thumbColor = self.qmui_thumbColor ?: self.tintColor;
        UIImage *thumbImage = [UIImage qmui_imageWithShape:QMUIImageShapeOval size:self.qmui_thumbSize tintColor:thumbColor];
        [self setThumbImage:thumbImage forState:UIControlStateNormal];
        [self setThumbImage:thumbImage forState:UIControlStateHighlighted];
    }
}

static char kAssociatedObjectKey_thumbShadowColor;
- (void)setQmui_thumbShadowColor:(UIColor *)qmui_thumbShadowColor {
    objc_setAssociatedObject(self, &kAssociatedObjectKey_thumbShadowColor, qmui_thumbShadowColor, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    if (qmui_thumbShadowColor) {
        [QMUIHelper executeBlock:^{
            if (@available(iOS 14.0, *)) {
                // -[_UISlideriOSVisualElement didAddSubview:]
                OverrideImplementation(NSClassFromString([NSString qmui_stringByConcat:@"_", @"UISlider", @"iOS", @"VisualElement", nil]), @selector(didAddSubview:), ^id(__unsafe_unretained Class originClass, SEL originCMD, IMP (^originalIMPProvider)(void)) {
                    return ^(UIView *selfObject, UIView *subview) {
                        
                        // call super
                        void (*originSelectorIMP)(id, SEL, UIView *);
                        originSelectorIMP = (void (*)(id, SEL, UIView *))originalIMPProvider();
                        originSelectorIMP(selfObject, originCMD, subview);
                        
                        UISlider *slider = (UISlider *)selfObject.superview;
                        if (![slider isKindOfClass:UISlider.class]) return;
                        UIView *tv = slider.qmui_thumbView;
                        if (tv) {
                            tv.layer.shadowColor = slider.qmui_thumbShadowColor.CGColor;
                            tv.layer.shadowOpacity = slider.qmui_thumbShadowColor ? 1 : 0;
                            tv.layer.shadowOffset = slider.qmui_thumbShadowOffset;
                            tv.layer.shadowRadius = slider.qmui_thumbShadowRadius;
                        }
                    };
                });
            } else {
                OverrideImplementation([UISlider class], @selector(didAddSubview:), ^id(__unsafe_unretained Class originClass, SEL originCMD, IMP (^originalIMPProvider)(void)) {
                    return ^(UISlider *selfObject, UIView *subview) {
                        
                        // call super
                        void (*originSelectorIMP)(id, SEL, UIView *);
                        originSelectorIMP = (void (*)(id, SEL, UIView *))originalIMPProvider();
                        originSelectorIMP(selfObject, originCMD, subview);
                        
                        UIView *tv = selfObject.qmui_thumbView;
                        if (tv) {
                            tv.layer.shadowColor = selfObject.qmui_thumbShadowColor.CGColor;
                            tv.layer.shadowOpacity = selfObject.qmui_thumbShadowColor ? 1 : 0;
                            tv.layer.shadowOffset = selfObject.qmui_thumbShadowOffset;
                            tv.layer.shadowRadius = selfObject.qmui_thumbShadowRadius;
                        }
                    };
                });
            }
        } oncePerIdentifier:@"UISlider (QMUI) thumbShadowColor"];
    }
    UIView *thumbView = self.qmui_thumbView;
    if (thumbView) {
        thumbView.layer.shadowColor = qmui_thumbShadowColor.CGColor;
        thumbView.layer.shadowOpacity = qmui_thumbShadowColor ? 1 : 0;
    }
}

- (UIColor *)qmui_thumbShadowColor {
    return (UIColor *)objc_getAssociatedObject(self, &kAssociatedObjectKey_thumbShadowColor);
}

static char kAssociatedObjectKey_thumbShadowOffset;
- (void)setQmui_thumbShadowOffset:(CGSize)qmui_thumbShadowOffset {
    objc_setAssociatedObject(self, &kAssociatedObjectKey_thumbShadowOffset, @(qmui_thumbShadowOffset), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    UIView *thumbView = self.qmui_thumbView;
    if (thumbView) {
        thumbView.layer.shadowOffset = qmui_thumbShadowOffset;
    }
}

- (CGSize)qmui_thumbShadowOffset {
    return [((NSNumber *)objc_getAssociatedObject(self, &kAssociatedObjectKey_thumbShadowOffset)) CGSizeValue];
}

static char kAssociatedObjectKey_thumbShadowRadius;
- (void)setQmui_thumbShadowRadius:(CGFloat)qmui_thumbShadowRadius {
    objc_setAssociatedObject(self, &kAssociatedObjectKey_thumbShadowRadius, @(qmui_thumbShadowRadius), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    UIView *thumbView = self.qmui_thumbView;
    if (thumbView) {
        thumbView.layer.shadowRadius = qmui_thumbShadowRadius;
    }
}

- (CGFloat)qmui_thumbShadowRadius {
    return [((NSNumber *)objc_getAssociatedObject(self, &kAssociatedObjectKey_thumbShadowRadius)) qmui_CGFloatValue];
}

#pragma mark - Steps

static char kAssociatedObjectKey_numberOfSteps;
- (void)setQmui_numberOfSteps:(NSUInteger)numberOfSteps {
    objc_setAssociatedObject(self, &kAssociatedObjectKey_numberOfSteps, @(numberOfSteps), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    if (numberOfSteps < 2) {
        [self.qmuisl_stepControls enumerateObjectsUsingBlock:^(QMUISliderStepControl * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            [obj removeFromSuperview];
        }];
        self.qmuisl_stepControls = nil;
        [self removeTarget:self action:@selector(qmuisl_handleValueChanged:) forControlEvents:UIControlEventValueChanged];
        return;
    }
    
    [self qmuisl_swizzleForStepsIfNeeded];
    
    // step 的逻辑都是基于 [0, 1] 来计算的，所以这里强制保证一下值
    self.minimumValue = 0;
    self.maximumValue = 1;
    
    if (!self.qmuisl_stepControls) {
        self.qmuisl_stepControls = NSMutableArray.new;
    }
    NSInteger diff = self.qmuisl_stepControls.count - numberOfSteps;
    if (diff < 0) {
        for (NSInteger i = 0; i < diff * -1; i++) {
            QMUISliderStepControl *stepControl = QMUISliderStepControl.new;
            [stepControl addTarget:self action:@selector(qmuisl_handleStepControlEvent:) forControlEvents:UIControlEventTouchUpInside];
            [self addSubview:stepControl];// stepControl 要在最前面，才能做到点击 stepControl 时响应到点击事件
            [self.qmuisl_stepControls addObject:stepControl];
        }
    } else if (diff > 0) {
        for (NSInteger i = self.qmuisl_stepControls.count - 1, l = self.qmuisl_stepControls.count - diff - 1; i >= l; i--) {
            [self.qmuisl_stepControls[i] removeFromSuperview];
            [self.qmuisl_stepControls removeObjectAtIndex:i];
        }
    }
    if (self.qmui_stepControlConfiguration) {
        [self.qmuisl_stepControls enumerateObjectsUsingBlock:^(QMUISliderStepControl * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            self.qmui_stepControlConfiguration(self, obj, idx);
        }];
    }
    [self qmuisl_setNeedsLayout];
    
    [self removeTarget:self action:@selector(qmuisl_handleValueChanged:) forControlEvents:UIControlEventValueChanged];
    [self addTarget:self action:@selector(qmuisl_handleValueChanged:) forControlEvents:UIControlEventValueChanged];
}

- (NSUInteger)qmui_numberOfSteps {
    return [((NSNumber *)objc_getAssociatedObject(self, &kAssociatedObjectKey_numberOfSteps)) unsignedIntValue];
}

- (void)setQmui_step:(NSUInteger)step {
    if (self.qmui_numberOfSteps < 2) return;
    CGFloat value = (self.maximumValue - self.minimumValue) * ((CGFloat)step / (CGFloat)(self.qmui_numberOfSteps - 1));
    self.value = value;
    [self sendActionsForControlEvents:UIControlEventValueChanged];
}

- (NSUInteger)qmui_step {
    NSUInteger step = [self qmuisl_stepWithValue:self.value];
    return step;
}

static char kAssociatedObjectKey_stepControlConfiguration;
- (void)setQmui_stepControlConfiguration:(void (^)(__kindof UISlider * _Nonnull, QMUISliderStepControl * _Nonnull, NSUInteger))stepControlConfiguration {
    objc_setAssociatedObject(self, &kAssociatedObjectKey_stepControlConfiguration, stepControlConfiguration, OBJC_ASSOCIATION_COPY_NONATOMIC);
    if (stepControlConfiguration) {
        [self.qmuisl_stepControls enumerateObjectsUsingBlock:^(QMUISliderStepControl * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            stepControlConfiguration(self, obj, idx);
        }];
        [self qmuisl_setNeedsLayout];
    }
}

- (void (^)(__kindof UISlider * _Nonnull, QMUISliderStepControl * _Nonnull, NSUInteger))qmui_stepControlConfiguration {
    return (void (^)(UISlider * _Nonnull, QMUISliderStepControl * _Nonnull, NSUInteger))objc_getAssociatedObject(self, &kAssociatedObjectKey_stepControlConfiguration);
}

- (void)qmuisl_handleValueChanged:(UISlider *)slider {
    if (slider.qmui_numberOfSteps < 2) return;
    
    NSUInteger step = [slider qmuisl_stepWithValue:slider.value];
    if (step != slider.qmuisl_precedingStep) {
        if (slider.qmui_stepDidChangeBlock) {
            slider.qmui_stepDidChangeBlock(slider, slider.qmuisl_precedingStep);
        }
        // 即便不存在 qmui_stepDidChangeBlock 也要记录 precedingStep
        // https://github.com/Tencent/QMUI_iOS/issues/1413
        slider.qmuisl_precedingStep = step;
    }
}

- (void)qmuisl_handleStepControlEvent:(QMUISliderStepControl *)stepControl {
    NSInteger step = [self.qmuisl_stepControls indexOfObject:stepControl];
    self.qmui_step = step;
}

- (NSUInteger)qmuisl_stepWithValue:(float)value {
    CGFloat progress = value / (self.maximumValue - self.minimumValue);
    NSUInteger step = round(progress * (self.qmui_numberOfSteps - 1));
    return step;
}

- (void)qmuisl_swizzleForStepsIfNeeded {
    [QMUIHelper executeBlock:^{
        OverrideImplementation([UISlider class], @selector(layoutSubviews), ^id(__unsafe_unretained Class originClass, SEL originCMD, IMP (^originalIMPProvider)(void)) {
            return ^(UISlider *selfObject) {
                
                // call super
                void (*originSelectorIMP)(id, SEL);
                originSelectorIMP = (void (*)(id, SEL))originalIMPProvider();
                originSelectorIMP(selfObject, originCMD);
                
                [selfObject qmuisl_layoutStepControls];
            };
        });
        
        OverrideImplementation([UISlider class], @selector(setEnabled:), ^id(__unsafe_unretained Class originClass, SEL originCMD, IMP (^originalIMPProvider)(void)) {
            return ^(UISlider *selfObject, BOOL enabled) {
                
                // call super
                void (*originSelectorIMP)(id, SEL, BOOL);
                originSelectorIMP = (void (*)(id, SEL, BOOL))originalIMPProvider();
                originSelectorIMP(selfObject, originCMD, enabled);
                
                if (selfObject.qmui_stepControlConfiguration) {
                    [selfObject.qmuisl_stepControls enumerateObjectsUsingBlock:^(QMUISliderStepControl * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                        selfObject.qmui_stepControlConfiguration(selfObject, obj, idx);
                    }];
                }
            };
        });
        
        OverrideImplementation([UISlider class], @selector(tintColorDidChange), ^id(__unsafe_unretained Class originClass, SEL originCMD, IMP (^originalIMPProvider)(void)) {
            return ^(UISlider *selfObject) {
                
                // call super
                void (*originSelectorIMP)(id, SEL);
                originSelectorIMP = (void (*)(id, SEL))originalIMPProvider();
                originSelectorIMP(selfObject, originCMD);
                
                [selfObject qmuisl_tintColorDidChange];
            };
        });
        
        OverrideImplementation([UISlider class], @selector(pointInside:withEvent:), ^id(__unsafe_unretained Class originClass, SEL originCMD, IMP (^originalIMPProvider)(void)) {
            return ^BOOL(UISlider *selfObject, CGPoint point, UIEvent *event) {
                
                // call super
                BOOL (*originSelectorIMP)(id, SEL, CGPoint, UIEvent *);
                originSelectorIMP = (BOOL (*)(id, SEL, CGPoint, UIEvent *))originalIMPProvider();
                BOOL result = originSelectorIMP(selfObject, originCMD, point, event);
                
                if (!result && selfObject.qmuisl_stepControls.count) {
                    __block BOOL pointInStepControl = NO;
                    [selfObject.qmuisl_stepControls enumerateObjectsUsingBlock:^(QMUISliderStepControl * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                        CGPoint p = [selfObject convertPoint:point toView:obj];
                        if ([obj pointInside:p withEvent:event]) {
                            pointInStepControl = YES;
                            *stop = YES;
                        }
                    }];
                    if (pointInStepControl) return YES;
                }
                
                return result;
            };
        });
        
        // - (CGRect)thumbRectForBounds:(CGRect)bounds trackRect:(CGRect)rect value:(float)value;
        OverrideImplementation([UISlider class], @selector(thumbRectForBounds:trackRect:value:), ^id(__unsafe_unretained Class originClass, SEL originCMD, IMP (^originalIMPProvider)(void)) {
            return ^CGRect(UISlider *selfObject, CGRect bounds, CGRect trackRect, float value) {
                
                // call super
                CGRect (*originSelectorIMP)(id, SEL, CGRect, CGRect, float);
                originSelectorIMP = (CGRect (*)(id, SEL, CGRect, CGRect, float))originalIMPProvider();
                CGRect result = originSelectorIMP(selfObject, originCMD, bounds, trackRect, value);

                if (selfObject.qmui_numberOfSteps >= 2) {
                    NSInteger step = [selfObject qmuisl_stepWithValue:value];
                    CGFloat thumbCenterX = CGRectGetMinX(trackRect) + (CGRectGetWidth(trackRect) / (selfObject.qmui_numberOfSteps - 1)) * step;
                    result = CGRectSetX(result, thumbCenterX - CGRectGetWidth(result) / 2);
                    return result;
                }
                
                return result;
            };
        });
        
        OverrideImplementation([UISlider class], @selector(setValue:animated:), ^id(__unsafe_unretained Class originClass, SEL originCMD, IMP (^originalIMPProvider)(void)) {
            return ^(UISlider *selfObject, float value, BOOL animated) {
                
                // 关闭 continuous 本质上只是让系统在 touch 结束时才 send value changed event，实际上不管 continuous 的值是什么，拖动过程中都会不断调用 setValue:animated: 并且实时设置当前的 value，所以需要重写这个方法，在抬手时强制把当前抬手位置的 value 转换成 UI 上 thumView 当前位置对应的 value 值，然后业务才能在 value changed 回调里获取到正确的 value（虽然业务应该获取 step 而不是 value）
                if (selfObject.qmui_numberOfSteps >= 2) {
                    NSUInteger step = [selfObject qmuisl_stepWithValue:value];
                    value = (float)step / (selfObject.qmui_numberOfSteps - 1);
                }
                
                // call super
                void (*originSelectorIMP)(id, SEL, float, BOOL);
                originSelectorIMP = (void (*)(id, SEL, float, BOOL))originalIMPProvider();
                originSelectorIMP(selfObject, originCMD, value, animated);
                
                
            };
        });
    } oncePerIdentifier:@"UISlider (QMUI) stepControl"];
}

- (void)qmuisl_layoutStepControls {
    NSInteger count = self.qmuisl_stepControls.count;
    if (!count) return;
    
    // 根据当前 thumbView 的位置，控制重叠的那个 stepControl 的事件响应和显隐，由于 slider 可能是 continuous 的，所以这段逻辑必须每次 layout 都调用，不能放在 layoutCachedKey 的保护里
    CGRect thumbRect = self.qmui_thumbView.frame;
    CGRect trackRect = [self trackRectForBounds:self.bounds];
    NSUInteger step = (CGRectGetMidX(thumbRect) - CGRectGetMinX(trackRect)) / CGRectGetWidth(trackRect) * (count - 1);
    [self.qmuisl_stepControls enumerateObjectsUsingBlock:^(QMUISliderStepControl * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        obj.userInteractionEnabled = idx != step;// 让 stepControl 不要影响 thumbView 的事件
        obj.indicator.hidden = idx == step;
    }];
    
    NSString *layoutCachedKey = [NSString stringWithFormat:@"%.0f-%@", CGRectGetWidth(trackRect), @(count)];
    if ([self.qmuisl_layoutCachedKey isEqualToString:layoutCachedKey]) return;
    
    __block CGFloat totalStepsWidth = 0;
    [self.qmuisl_stepControls enumerateObjectsUsingBlock:^(QMUISliderStepControl * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        totalStepsWidth += obj.indicatorSize.width;
    }];
    CGFloat stepMargin = (CGRectGetWidth(trackRect) - totalStepsWidth) / (count - 1);
    __block CGFloat stepIndicatorMinX = CGRectGetMinX(trackRect);
    [self.qmuisl_stepControls enumerateObjectsUsingBlock:^(QMUISliderStepControl * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (idx == count - 1) {
            // 因为布局过程中可能存在一些像素不对齐的情况，因此对最后一个 indicator 做保护，一定贴着 slider 的 maxX
            stepIndicatorMinX = CGRectGetMaxX(trackRect) - obj.indicatorSize.width;
        }
        CGRect indicatorFrame = CGRectFlatMake(stepIndicatorMinX, CGRectGetMinY(trackRect) + CGFloatGetCenter(CGRectGetHeight(trackRect), obj.indicatorSize.height), obj.indicatorSize.width, obj.indicatorSize.height);
        stepIndicatorMinX = CGRectGetMaxX(indicatorFrame) + stepMargin;
        
        CGSize stepControlSize = [obj sizeThatFits:CGSizeMax];
        obj.frame = CGRectFlatMake(CGRectGetMinX(indicatorFrame) - (stepControlSize.width - CGRectGetWidth(indicatorFrame)) / 2, CGRectGetMaxY(indicatorFrame) - stepControlSize.height, stepControlSize.width, stepControlSize.height);
    }];
}

- (void)qmuisl_tintColorDidChange {
    NSInteger count = self.qmuisl_stepControls.count;
    if (!count) return;
    [self.qmuisl_stepControls enumerateObjectsUsingBlock:^(QMUISliderStepControl * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        obj.tintColor = self.tintColor;
    }];
}

- (void)qmuisl_setNeedsLayout {
    self.qmuisl_layoutCachedKey = nil;
    [self setNeedsLayout];
}

@end

@implementation QMUISliderStepControl

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        _titleLabel = [[UILabel alloc] qmui_initWithFont:UIFontMake(12) textColor:UIColorGray];
        self.titleLabel.userInteractionEnabled = NO;
        [self addSubview:self.titleLabel];
        
        _indicator = [[UIView alloc] init];
        self.indicator.userInteractionEnabled = NO;
        self.indicator.backgroundColor = UIColorGray;
        [self addSubview:self.indicator];
        
        self.indicatorSize = CGSizeMake(1, 8);
        self.spacingBetweenTitleAndIndicator = 8;
        
        // 避免只显示 indicator 时 size 太小，很难点到
        self.qmui_outsideEdge = UIEdgeInsetsMake(-12, -12, -12, -12);
    }
    return self;
}

- (void)setIndicatorSize:(CGSize)indicatorSize {
    _indicatorSize = indicatorSize;
    [((UISlider *)self.superview) qmuisl_setNeedsLayout];
}

- (void)setSpacingBetweenTitleAndIndicator:(CGFloat)spacingBetweenTitleAndIndicator {
    _spacingBetweenTitleAndIndicator = spacingBetweenTitleAndIndicator;
    [((UISlider *)self.superview) qmuisl_setNeedsLayout];
}

- (CGSize)sizeThatFits:(CGSize)size {
    CGSize titleLabelSize = self.titleLabel.text.length ? [self.titleLabel sizeThatFits:CGSizeMax] : CGSizeZero;
    if (CGSizeIsEmpty(titleLabelSize)) return self.indicatorSize;
    
    CGSize result = CGSizeZero;
    result.width = MAX(titleLabelSize.width, self.indicatorSize.width);
    result.height = titleLabelSize.height + self.spacingBetweenTitleAndIndicator + self.indicatorSize.height;
    return result;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    CGSize titleLabelSize = self.titleLabel.text.length ? [self.titleLabel sizeThatFits:CGSizeMax] : CGSizeZero;
    if (CGSizeIsEmpty(titleLabelSize)) {
        self.indicator.frame = CGRectMakeWithSize(self.indicatorSize);
    } else {
        self.titleLabel.frame = CGRectFlatMake(CGFloatGetCenter(CGRectGetWidth(self.bounds), titleLabelSize.width), 0, titleLabelSize.width, titleLabelSize.height);
        self.indicator.frame = CGRectFlatMake(CGFloatGetCenter(CGRectGetWidth(self.bounds), self.indicatorSize.width), CGRectGetMaxY(self.titleLabel.frame) + self.spacingBetweenTitleAndIndicator, self.indicatorSize.width, self.indicatorSize.height);
    }
}

@end
