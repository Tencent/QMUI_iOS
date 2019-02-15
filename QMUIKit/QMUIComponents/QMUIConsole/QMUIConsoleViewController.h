//
//  QMUIConsoleViewController.h
//  QMUIKit
//
//  Created by MoLice on 2019/J/11.
//  Copyright © 2019 QMUI Team. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "QMUICommonViewController.h"

NS_ASSUME_NONNULL_BEGIN

@class QMUIButton;
@class QMUITextView;
@class QMUIConsoleToolbar;

@interface QMUIConsoleViewController : QMUICommonViewController

@property(nonatomic, strong, readonly) QMUIButton *popoverButton;
@property(nonatomic, strong, readonly) QMUITextView *textView;
@property(nonatomic, strong, readonly) QMUIConsoleToolbar *toolbar;
@property(nonatomic, strong, readonly) NSDateFormatter *dateFormatter;

@property(nonatomic, strong) UIColor *backgroundColor;

- (void)logWithLevel:(nullable NSString *)level name:(nullable NSString *)name logString:(id)logString;
- (void)log:(id)logString;
- (void)clear;
@end

NS_ASSUME_NONNULL_END
