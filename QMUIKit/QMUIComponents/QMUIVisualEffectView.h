//
//  QMUIVisualEffectView.h
//  qmui
//
//  Created by ZhoonChen on 14/12/1.
//  Copyright (c) 2014年 QMUI Team. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, QMUIVisualEffectViewStyle) {
    QMUIVisualEffectViewStyleExtraLight,
    QMUIVisualEffectViewStyleLight,
    QMUIVisualEffectViewStyleDark
};

@interface QMUIVisualEffectView : UIView

@property(nonatomic,assign,readonly) QMUIVisualEffectViewStyle style;

- (instancetype)initWithStyle:(QMUIVisualEffectViewStyle)style;
@end
