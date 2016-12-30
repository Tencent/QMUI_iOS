//
//  CALayer+QMUI.m
//  qmui
//
//  Created by MoLice on 16/8/12.
//  Copyright © 2016年 QMUI Team. All rights reserved.
//

#import "CALayer+QMUI.h"

@implementation CALayer (QMUI)

- (void)qmui_sendSublayerToBack:(CALayer *)sublayer {
    if (sublayer.superlayer == self) {
        [sublayer removeFromSuperlayer];
        [self insertSublayer:sublayer atIndex:0];
    }
}

- (void)qmui_bringSublayerToFront:(CALayer *)sublayer {
    if (sublayer.superlayer == self) {
        [sublayer removeFromSuperlayer];
        [self insertSublayer:sublayer atIndex:(unsigned)self.sublayers.count];
    }
}

- (void)qmui_removeDefaultAnimations {
    self.actions = @{@"sublayers": [NSNull null],
                     @"contents": [NSNull null],
                     @"bounds": [NSNull null],
                     @"frame": [NSNull null],
                     @"position": [NSNull null],
                     @"anchorPoint": [NSNull null],
                     @"cornerRadius": [NSNull null],
                     @"transform": [NSNull null],
                     @"hidden": [NSNull null],
                     @"opacity": [NSNull null],
                     @"backgroundColor": [NSNull null],
                     @"shadowColor": [NSNull null],
                     @"shadowOpacity": [NSNull null],
                     @"shadowOffset": [NSNull null],
                     @"shadowRadius": [NSNull null],
                     @"shadowPath": [NSNull null]};
}

@end
