//
//  QMUIThemeManager.h
//  QMUIKit
//
//  Created by MoLice on 2019/J/20.
//  Copyright © 2019 QMUI Team. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

extern NSString *const QMUIThemeIdentifierLight;
extern NSString *const QMUIThemeIdentifierDark;

@interface QMUIThemeManager : NSObject

+ (instancetype)sharedInstance;

@property(nonatomic, strong, readonly) NSMutableDictionary<NSObject<NSCopying> *, NSObject *> *themes;
@property(nonatomic, strong, nullable) NSObject *currentTheme;
@property(nonatomic, copy, nullable) NSObject<NSCopying> *currentThemeIdentifier;
@property(nonatomic, assign) BOOL adjustSystemUserInterfaceStyleAutomatically;
@end

NS_ASSUME_NONNULL_END
