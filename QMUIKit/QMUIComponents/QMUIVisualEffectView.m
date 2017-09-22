//
//  QMUIVisualEffectView.m
//  qmui
//
//  Created by ZhoonChen on 14/12/1.
//  Copyright (c) 2014年 QMUI Team. All rights reserved.
//

#import "QMUIVisualEffectView.h"

@implementation QMUIVisualEffectView
{
    UIVisualEffectView *_effectView_8;  // iOS8 及以上
    UIToolbar *_effectView_7;           // iOS7
    UIView *_effectView_6;              // iOS6 及以下
}

- (instancetype)init {
    self = [self initWithStyle:QMUIVisualEffectViewStyleLight];
    if (self) {
    }
    return self;
}

- (instancetype)initWithStyle:(QMUIVisualEffectViewStyle)style {
    self = [super init];
    if (self) {
        _style = style;
        [self initEffectViewUI];
    }
    return self;
}

- (void)initEffectViewUI {
    if ([UIVisualEffectView class]) {
        UIBlurEffectStyle effStyle;
        switch (_style) {
            case QMUIVisualEffectViewStyleExtraLight:
                effStyle = UIBlurEffectStyleExtraLight;
                break;
            case QMUIVisualEffectViewStyleLight:
                effStyle = UIBlurEffectStyleLight;
                break;
            case QMUIVisualEffectViewStyleDark:
                effStyle = UIBlurEffectStyleDark;
            default:
                break;
        }
        _effectView_8 = [[UIVisualEffectView alloc] initWithEffect:[UIBlurEffect effectWithStyle:effStyle]];
        _effectView_8.clipsToBounds = YES;
        [self addSubview:_effectView_8];
    } else {
        _effectView_7 = [[UIToolbar alloc] init];
        _effectView_7.clipsToBounds = YES;
        [self addSubview:_effectView_7];
    }
}

- (void)setBackgroundColor:(UIColor *)backgroundColor {
    _effectView_6.backgroundColor = backgroundColor;
    _effectView_7.backgroundColor = backgroundColor;
    _effectView_8.backgroundColor = backgroundColor;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    if ([UIVisualEffectView class]) {
        _effectView_8.frame = CGRectMake(0, 0, CGRectGetWidth(self.bounds), CGRectGetHeight(self.bounds));
    } else {
        _effectView_7.frame = CGRectMake(0, 0, CGRectGetWidth(self.bounds), CGRectGetHeight(self.bounds));
    }
}

@end
