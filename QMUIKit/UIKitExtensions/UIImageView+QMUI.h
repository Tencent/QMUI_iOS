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
 *  把 UIImageView 的宽高调整为能保持 image 宽高比例不变的同时又不超过给定的 `limitSize` 大小的最大frame
 *
 *  建议在设置完x/y之后调用
 */
- (void)qmui_sizeToFitKeepingImageAspectRatioInSize:(CGSize)limitSize;
@end
