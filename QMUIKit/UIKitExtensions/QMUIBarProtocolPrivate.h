//
//  QMUIBarProtocolPrivate.h
//  QMUIKit
//
//  Created by molice on 2022/5/18.
//  Copyright © 2022 QMUI Team. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@protocol QMUIBarProtocolPrivate <NSObject>

@required
@property(nonatomic, assign) BOOL qmuibar_hasSetEffect;
@property(nonatomic, assign) BOOL qmuibar_hasSetEffectForegroundColor;
@property(nonatomic, strong, readonly, nullable) NSArray<UIVisualEffect *> *qmuibar_backgroundEffects;
- (void)qmuibar_updateEffect;
@end

@interface QMUIBarProtocolPrivate : NSObject

+ (void)swizzleBarBackgroundViewIfNeeded;
@end

NS_ASSUME_NONNULL_END
