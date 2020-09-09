/**
 * Tencent is pleased to support the open source community by making QMUI_iOS available.
 * Copyright (C) 2016-2020 THL A29 Limited, a Tencent company. All rights reserved.
 * Licensed under the MIT License (the "License"); you may not use this file except in compliance with the License. You may obtain a copy of the License at
 * http://opensource.org/licenses/MIT
 * Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.
 */
//
//  UISearchController+QMUI.m
//  QMUIKit
//
//  Created by ziezheng on 2019/9/27.
//

#import "UISearchController+QMUI.h"
#import "UIViewController+QMUI.h"
#import "UINavigationController+QMUI.h"
#import "UIView+QMUI.h"
#import "QMUICore.h"

@implementation UISearchController (QMUI)

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        OverrideImplementation(NSClassFromString(@"_UISearchControllerView"), @selector(didMoveToWindow), ^id(__unsafe_unretained Class originClass, SEL originCMD, IMP (^originalIMPProvider)(void)) {
            return ^(UIView *selfObject) {
                void (*originSelectorIMP)(id, SEL);
                originSelectorIMP = (void (*)(id, SEL))originalIMPProvider();
                originSelectorIMP(selfObject, originCMD);
                
                // 修复 https://github.com/Tencent/QMUI_iOS/issues/680 中提到的问题二：当有一个 TableViewController A，A 的 seachBar 被激活且 searchResultsController 正在显示的情况下，A.navigationController push 一个新的 viewController B，B 用 pop 手势返回到一半松手放弃返回，此时 B 再 push 一个新的 viewController 时，在转场过程中会看到 searchResultsController 的内容。
                if (selfObject.window && [selfObject.superview isKindOfClass:NSClassFromString(@"UITransitionView")]) {
                    UIView *transitionView = selfObject.superview;
                    UISearchController *searchController = [selfObject qmui_viewController];
                    UIViewController *sourceViewController = [searchController valueForKey:@"_modalSourceViewController"];
                    UINavigationController *navigationController = sourceViewController.navigationController;
                    if (navigationController.qmui_isPushing && navigationController.topViewController.qmui_previousViewController != sourceViewController) {
                        // 系统内部错误地添加了这个 view，这里直接 remove 掉，系统内部在真正要显示的时候再次添加回来。
                        [transitionView removeFromSuperview];
                    }
                }
                
            };
        });
    });
}

@end
