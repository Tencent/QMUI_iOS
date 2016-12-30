//
//  UIImageView+QMUI.h
//  qmui
//
//  Created by MoLice on 16/8/9.
//  Copyright © 2016年 QMUI Team. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface UIImageView (QMUI)

/**
 *  把UIImageView的宽高调整为能保持image宽高比例不变的同时又不超过给定的`limitSize`大小的最小frame
 *
 *  建议在设置完x/y之后调用
 */
- (void)qmui_sizeToFitKeepingImageAspectRatioInSize:(CGSize)limitSize;
@end
