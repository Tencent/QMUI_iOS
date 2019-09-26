/*****
 * Tencent is pleased to support the open source community by making QMUI_iOS available.
 * Copyright (C) 2016-2019 THL A29 Limited, a Tencent company. All rights reserved.
 * Licensed under the MIT License (the "License"); you may not use this file except in compliance with the License. You may obtain a copy of the License at
 * http://opensource.org/licenses/MIT
 * Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.
 *****/
//
//  UITraitCollection+QMUI.m
//  QMUIKit
//
//  Created by ziezheng on 2019/7/19.
//

#import "UITraitCollection+QMUI.h"
#import "QMUICore.h"

NSNotificationName const QMUIUserInterfaceStyleWillChangeNotification = @"QMUIUserInterfaceStyleWillChangeNotification";

@implementation UIWindow (QMUIUserInterfaceStyleWillChangeNotification)

#ifdef IOS13_SDK_ALLOWED
+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (@available(iOS 13.0, *)) {
            static UIUserInterfaceStyle qmui_lastNotifiedUserInterfaceStyle;
            qmui_lastNotifiedUserInterfaceStyle = [UITraitCollection currentTraitCollection].userInterfaceStyle;
            OverrideImplementation([UIWindow class] , @selector(traitCollection), ^id(__unsafe_unretained Class originClass, SEL originCMD, IMP (^originalIMPProvider)(void)) {
                return ^UITraitCollection *(UIWindow *selfObject) {
                    
                    id (*originSelectorIMP)(id, SEL);
                    originSelectorIMP = (id (*)(id, SEL))originalIMPProvider();
                    UITraitCollection *traitCollection = originSelectorIMP(selfObject, originCMD);
                    
                    BOOL snapshotFinishedOnBackground = traitCollection.userInterfaceLevel != 0;
                     // 进入后台且完成截图了就不继续去响应 style 变化（实测 iPad 进入后台并完成截图后，仍会多次改变 style，但是系统并没有调用界面的相关刷新方法）
                    if (selfObject.windowScene && !snapshotFinishedOnBackground) {
                        NSPointerArray *windows = [[selfObject windowScene] valueForKeyPath:@"_contextBinder._attachedBindables"];
                        // 系统会按照这个数组的顺序去更新 window 的 traitCollection，所以第 0 个就是那个最先响应样式更新的 window
                        if (windows.count > 0 && selfObject == [windows pointerAtIndex:0]) {
                            if (qmui_lastNotifiedUserInterfaceStyle != traitCollection.userInterfaceStyle) {
                                qmui_lastNotifiedUserInterfaceStyle = traitCollection.userInterfaceStyle;
                                [[NSNotificationCenter defaultCenter] postNotificationName:QMUIUserInterfaceStyleWillChangeNotification object:traitCollection];
                            }
                        }
                    }
                    return traitCollection;
                    
                };
            });
        }
    });
}
#endif

@end
