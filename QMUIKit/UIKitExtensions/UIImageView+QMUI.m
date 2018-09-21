//
//  UIImageView+QMUI.m
//  qmui
//
//  Created by MoLice on 16/8/9.
//  Copyright © 2016年 QMUI Team. All rights reserved.
//

#import "UIImageView+QMUI.h"
#import "QMUICore.h"
#import "CALayer+QMUI.h"

@interface UIImageView ()

@property(nonatomic, strong) CADisplayLink *qimgv_displayLink;
@property(nonatomic, strong) UIImage *qimgv_animatedImage;
@property(nonatomic, assign) NSInteger qimgv_currentAnimatedImageIndex;
@end

@implementation UIImageView (QMUI)

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        SEL selectors[] = {
            @selector(initWithFrame:),
            @selector(initWithCoder:),
            @selector(setImage:),
            @selector(displayLayer:),
            @selector(didMoveToWindow),
            @selector(setHidden:),
            @selector(setAlpha:),
            @selector(setFrame:)
        };
        for (NSUInteger index = 0; index < sizeof(selectors) / sizeof(SEL); index++) {
            SEL originalSelector = selectors[index];
            SEL swizzledSelector = NSSelectorFromString([@"qimgv_" stringByAppendingString:NSStringFromSelector(originalSelector)]);
            ExchangeImplementations([self class], originalSelector, swizzledSelector);
        }
    });
}

- (instancetype)qimgv_initWithFrame:(CGRect)frame {
    [self qimgv_initWithFrame:frame];
    self.qmui_smoothAnimation = YES;
    return self;
}

- (instancetype)qimgv_initWithCoder:(NSCoder *)aDecoder {
    [self qimgv_initWithCoder:aDecoder];
    self.qmui_smoothAnimation = YES;
    return self;
}

- (void)qimgv_setImage:(UIImage *)image {
    if (self.qmui_smoothAnimation && image.images && image != self.qimgv_animatedImage) {
        self.qimgv_animatedImage = image;
        [self qimgv_requestToStartAnimation];
    } else {
        self.qimgv_animatedImage = nil;
        [self qimgv_stopAnimating];
        [self qimgv_setImage:image];
    }
}

- (BOOL)qimgv_requestToStartAnimation {
    if (![self qimgv_canStartAnimation]) return NO;
    
    if (!self.qimgv_displayLink) {
        self.qimgv_displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(handleDisplayLink:)];
        [self.qimgv_displayLink addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSRunLoopCommonModes];
        NSInteger preferredFramesPerSecond = self.qimgv_animatedImage.images.count / self.qimgv_animatedImage.duration;
        if (@available(iOS 10, *)) {
            self.qimgv_displayLink.preferredFramesPerSecond = preferredFramesPerSecond;
        } else {
            self.qimgv_displayLink.frameInterval = preferredFramesPerSecond;
        }
        self.qimgv_currentAnimatedImageIndex = -1;
        self.layer.contents = (__bridge id)self.qimgv_animatedImage.images.firstObject.CGImage;// 对于那种一开始就 pause 的图，displayLayer: 不会被调用，所以看不到图，为了避免这种情况，手动先把第一帧显示出来
    }
    
    self.qimgv_displayLink.paused = self.qmui_pause;
    
    return YES;
}

- (void)qimgv_stopAnimating {
    if (self.qimgv_displayLink) {
        [self.qimgv_displayLink invalidate];
        self.qimgv_displayLink = nil;
    }
}

- (void)qimgv_updateAnimationStateAutomatically {
    if (self.qimgv_animatedImage) {
        if (![self qimgv_requestToStartAnimation]) {
            [self qimgv_stopAnimating];
        }
    }
}

- (BOOL)qimgv_canStartAnimation {
    return self.window && !self.hidden && self.alpha > 0.01 && !CGRectIsEmpty(self.frame);
}

- (void)qimgv_didMoveToWindow {
    [self qimgv_didMoveToWindow];
    [self qimgv_updateAnimationStateAutomatically];
}

- (void)qimgv_setHidden:(BOOL)hidden {
    [self qimgv_setHidden:hidden];
    [self qimgv_updateAnimationStateAutomatically];
}

- (void)qimgv_setAlpha:(CGFloat)alpha {
    [self qimgv_setAlpha:alpha];
    [self qimgv_updateAnimationStateAutomatically];
}

- (void)qimgv_setFrame:(CGRect)frame {
    [self qimgv_setFrame:frame];
    [self qimgv_updateAnimationStateAutomatically];
}


- (void)handleDisplayLink:(CADisplayLink *)displayLink {
    self.qimgv_currentAnimatedImageIndex = self.qimgv_currentAnimatedImageIndex < self.qimgv_animatedImage.images.count - 1 ? (self.qimgv_currentAnimatedImageIndex + 1) : 0;
    [self.layer setNeedsDisplay];
}

- (void)qimgv_displayLayer:(CALayer *)layer {
    if (self.qimgv_animatedImage) {
        layer.contents = (__bridge id)self.qimgv_animatedImage.images[self.qimgv_currentAnimatedImageIndex].CGImage;
    } else {
        [self qimgv_displayLayer:layer];
    }
}

static char kAssociatedObjectKey_displayLink;
- (void)setQimgv_displayLink:(CADisplayLink *)qimgv_displayLink {
    objc_setAssociatedObject(self, &kAssociatedObjectKey_displayLink, qimgv_displayLink, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (CADisplayLink *)qimgv_displayLink {
    return (CADisplayLink *)objc_getAssociatedObject(self, &kAssociatedObjectKey_displayLink);
}

static char kAssociatedObjectKey_animatedImage;
- (void)setQimgv_animatedImage:(UIImage *)qimgv_animatedImage {
    objc_setAssociatedObject(self, &kAssociatedObjectKey_animatedImage, qimgv_animatedImage, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (UIImage *)qimgv_animatedImage {
    return (UIImage *)objc_getAssociatedObject(self, &kAssociatedObjectKey_animatedImage);
}

static char kAssociatedObjectKey_currentImageIndex;
- (void)setQimgv_currentAnimatedImageIndex:(NSInteger)qimgv_currentAnimatedImageIndex {
    objc_setAssociatedObject(self, &kAssociatedObjectKey_currentImageIndex, @(qimgv_currentAnimatedImageIndex), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSInteger)qimgv_currentAnimatedImageIndex {
    return [((NSNumber *)objc_getAssociatedObject(self, &kAssociatedObjectKey_currentImageIndex)) integerValue];
}

static char kAssociatedObjectKey_smoothAnimation;
- (void)setQmui_smoothAnimation:(BOOL)qmui_smoothAnimation {
    objc_setAssociatedObject(self, &kAssociatedObjectKey_smoothAnimation, @(qmui_smoothAnimation), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    if (qmui_smoothAnimation && self.image.images) {
        self.image = self.image;
    } else if (!qmui_smoothAnimation && self.qimgv_animatedImage) {
        self.image = self.qimgv_animatedImage;
    }
}

- (BOOL)qmui_smoothAnimation {
    return [((NSNumber *)objc_getAssociatedObject(self, &kAssociatedObjectKey_smoothAnimation)) boolValue];
}

static char kAssociatedObjectKey_pause;
- (void)setQmui_pause:(BOOL)qmui_pause {
    objc_setAssociatedObject(self, &kAssociatedObjectKey_pause, @(qmui_pause), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    if (self.animationImages || self.image.images) {
        self.layer.qmui_pause = qmui_pause;
    }
    if (self.qimgv_displayLink) {
        self.qimgv_displayLink.paused = qmui_pause;
    }
}

- (BOOL)qmui_pause {
    return [((NSNumber *)objc_getAssociatedObject(self, &kAssociatedObjectKey_pause)) boolValue];
}

- (void)qmui_sizeToFitKeepingImageAspectRatioInSize:(CGSize)limitSize {
    if (!self.image) {
        return;
    }
    CGSize currentSize = self.frame.size;
    if (currentSize.width <= 0) {
        currentSize.width = self.image.size.width;
    }
    if (currentSize.height <= 0) {
        currentSize.height = self.image.size.height;
    }
    CGFloat horizontalRatio = limitSize.width / currentSize.width;
    CGFloat verticalRatio = limitSize.height / currentSize.height;
    CGFloat ratio = fmin(horizontalRatio, verticalRatio);
    CGRect frame = self.frame;
    frame.size.width = flat(currentSize.width * ratio);
    frame.size.height = flat(currentSize.height * ratio);
    self.frame = frame;
}

@end
