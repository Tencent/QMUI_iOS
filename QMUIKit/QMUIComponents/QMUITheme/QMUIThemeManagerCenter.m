/*****
 * Tencent is pleased to support the open source community by making QMUI_iOS available.
 * Copyright (C) 2016-2019 THL A29 Limited, a Tencent company. All rights reserved.
 * Licensed under the MIT License (the "License"); you may not use this file except in compliance with the License. You may obtain a copy of the License at
 * http://opensource.org/licenses/MIT
 * Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.
 *****/
//
//  QMUIThemeManagerCenter.m
//  QMUIKit
//
//  Created by MoLice on 2019/S/4.
//

#import "QMUIThemeManagerCenter.h"

NSString *const QMUIThemeManagerNameDefault = @"Default";

@interface QMUIThemeManager ()

// 这个方法的实现在 QMUIThemeManager.m 里，这里只是为了内部使用而显式声明一次
- (instancetype)initWithName:(__kindof NSObject<NSCopying> *)name;
@end

@interface QMUIThemeManagerCenter ()

@property(nonatomic, strong) NSMutableArray<QMUIThemeManager *> *allManagers;
@end

@implementation QMUIThemeManagerCenter

+ (instancetype)sharedInstance {
    static dispatch_once_t onceToken;
    static QMUIThemeManagerCenter *instance = nil;
    dispatch_once(&onceToken,^{
        instance = [[super allocWithZone:NULL] init];
        instance.allManagers = NSMutableArray.new;
    });
    return instance;
}

+ (id)allocWithZone:(struct _NSZone *)zone{
    return [self sharedInstance];
}

+ (QMUIThemeManager *)themeManagerWithName:(__kindof NSObject<NSCopying> *)name {
    QMUIThemeManagerCenter *center = [QMUIThemeManagerCenter sharedInstance];
    for (QMUIThemeManager *manager in center.allManagers) {
        if ([manager.name isEqual:name]) return manager;
    }
    QMUIThemeManager *manager = [[QMUIThemeManager alloc] initWithName:name];
    [center.allManagers addObject:manager];
    return manager;
}

+ (QMUIThemeManager *)defaultThemeManager {
    return [QMUIThemeManagerCenter themeManagerWithName:QMUIThemeManagerNameDefault];
}

+ (NSArray<QMUIThemeManager *> *)themeManagers {
    return [QMUIThemeManagerCenter sharedInstance].allManagers.copy;
}

@end
