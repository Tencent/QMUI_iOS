//
//  QMUITestView.m
//  qmui
//
//  Created by MoLice on 16/1/28.
//  Copyright © 2016年 QMUI Team. All rights reserved.
//

#import "QMUITestView.h"
#import "QMUILog.h"

@implementation QMUITestView

- (instancetype)init {
    if (self = [super init]) {
        
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        
    }
    return self;
}

- (void)dealloc {
    QMUILog(NSStringFromClass(self.class), @"%@, dealloc", self);
}

- (void)setFrame:(CGRect)frame {
    CGRect oldFrame = self.frame;
    BOOL isFrameChanged = CGRectEqualToRect(oldFrame, frame);
    if (!isFrameChanged) {
        QMUILog(NSStringFromClass(self.class), @"frame 发生变化, 旧的是 %@, 新的是 %@", NSStringFromCGRect(oldFrame), NSStringFromCGRect(frame));
    }
    [super setFrame:frame];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    QMUILog(NSStringFromClass(self.class), @"%s, frame = %@", __func__, NSStringFromCGRect(self.frame));
}

- (void)didMoveToSuperview {
    [super didMoveToSuperview];
    QMUILog(NSStringFromClass(self.class), @"%s, superview is %@", __func__, self.superview);
}

- (void)didMoveToWindow {
    [super didMoveToWindow];
    QMUILog(NSStringFromClass(self.class), @"%s, self.window is %@", __func__, self.window);
}

- (void)addSubview:(UIView *)view {
    [super addSubview:view];
    QMUILog(NSStringFromClass(self.class), @"%s, subview is %@, subviews.count before addSubview is %@", __func__, view, @(self.subviews.count));
}

- (void)setHidden:(BOOL)hidden {
    [super setHidden:hidden];
    QMUILog(NSStringFromClass(self.class), @"%s, hidden is %@", __func__, @(hidden));
}

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
    UIView *view = [super hitTest:point withEvent:event];
    return view;
}

@end

@implementation QMUITestWindow

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        
    }
    return self;
}

- (void)dealloc {
    QMUILog(NSStringFromClass(self.class), @"dealloc, %@", self);
}

- (void)setRootViewController:(UIViewController *)rootViewController {
    [super setRootViewController:rootViewController];
}

- (void)makeKeyAndVisible {
    [super makeKeyAndVisible];
}

- (void)makeKeyWindow {
    [super makeKeyWindow];
}

- (void)setHidden:(BOOL)hidden {
    [super setHidden:hidden];
}

- (void)addSubview:(UIView *)view {
    [super addSubview:view];
    QMUILog(NSStringFromClass(self.class), @"QMUITestWindow, subviews = %@, view = %@", self.subviews, view);
}

- (void)setFrame:(CGRect)frame {
    CGRect oldFrame = self.frame;
    BOOL isFrameChanged = CGRectEqualToRect(oldFrame, frame);
    if (isFrameChanged) {
        QMUILog(NSStringFromClass(self.class), @"QMUITestWindow, frame发生变化, old is %@, new is %@", NSStringFromCGRect(oldFrame), NSStringFromCGRect(frame));
    }
    [super setFrame:frame];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    QMUILog(NSStringFromClass(self.class), @"QMUITestWindow, layoutSubviews");
}

- (void)setAlpha:(CGFloat)alpha {
    [super setAlpha:alpha];
}

@end
