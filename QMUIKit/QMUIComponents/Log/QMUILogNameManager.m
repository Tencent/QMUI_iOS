//
//  QMUILogNameManager.m
//  QMUIKit
//
//  Created by MoLice on 2018/1/24.
//  Copyright © 2018年 QMUI Team. All rights reserved.
//

#import "QMUILogNameManager.h"
#import "QMUILogger.h"

NSString *const QMUILoggerAllNamesKeyInUserDefaults = @"QMUILoggerAllNamesKeyInUserDefaults";

@interface QMUILogNameManager ()

@property(nonatomic, strong) NSMutableDictionary<NSString *, NSNumber *> *mutableAllNames;
@property(nonatomic, assign) BOOL didInitialize;
@end

@implementation QMUILogNameManager

- (instancetype)init {
    if (self = [super init]) {
        self.mutableAllNames = [[NSMutableDictionary alloc] init];
        
        NSDictionary<NSString *, NSNumber *> *allQMUILogNames = [[NSUserDefaults standardUserDefaults] dictionaryForKey:QMUILoggerAllNamesKeyInUserDefaults];
        for (NSString *logName in allQMUILogNames) {
            [self setEnabled:allQMUILogNames[logName].boolValue forLogName:logName];
        }
        
        // 初始化时从 NSUserDefaults 里获取值的过程，不希望触发 delegate，所以加这个标志位
        self.didInitialize = YES;
    }
    return self;
}

- (NSDictionary<NSString *,NSNumber *> *)allNames {
    if (self.mutableAllNames.count) {
        return [self.mutableAllNames copy];
    }
    return nil;
}

- (BOOL)containsLogName:(NSString *)logName {
    if (logName.length > 0) {
        return !!self.mutableAllNames[logName];
    }
    return NO;
}

- (void)setEnabled:(BOOL)enabled forLogName:(NSString *)logName {
    if (logName.length > 0) {
        self.mutableAllNames[logName] = @(enabled);
        
        if (!self.didInitialize) return;
        
        [self synchronizeUserDefaults];
        
        if ([[QMUILogger sharedInstance].delegate respondsToSelector:@selector(QMUILogName:didChangeEnabled:)]) {
            [[QMUILogger sharedInstance].delegate QMUILogName:logName didChangeEnabled:enabled];
        }
    }
}

- (BOOL)enabledForLogName:(NSString *)logName {
    if (logName.length > 0) {
        if ([self containsLogName:logName]) {
            return [self.mutableAllNames[logName] boolValue];
        }
    }
    return YES;
}

- (void)removeLogName:(NSString *)logName {
    if (logName.length > 0) {
        [self.mutableAllNames removeObjectForKey:logName];
        
        if (!self.didInitialize) return;
        
        [self synchronizeUserDefaults];
        
        if ([[QMUILogger sharedInstance].delegate respondsToSelector:@selector(QMUILogNameDidRemove:)]) {
            [[QMUILogger sharedInstance].delegate QMUILogNameDidRemove:logName];
        }
    }
}

- (void)removeAllNames {
    BOOL shouldCallDelegate = self.didInitialize && [[QMUILogger sharedInstance].delegate respondsToSelector:@selector(QMUILogNameDidRemove:)];
    NSDictionary<NSString *, NSNumber *> *allNames = nil;
    if (shouldCallDelegate) {
        allNames = self.allNames;
    }
    
    [self.mutableAllNames removeAllObjects];
    
    [self synchronizeUserDefaults];
    
    if (shouldCallDelegate) {
        for (NSString *logName in allNames.allKeys) {
            [[QMUILogger sharedInstance].delegate QMUILogNameDidRemove:logName];
        }
    }
}

- (void)synchronizeUserDefaults {
    [[NSUserDefaults standardUserDefaults] setObject:self.allNames forKey:QMUILoggerAllNamesKeyInUserDefaults];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

@end
