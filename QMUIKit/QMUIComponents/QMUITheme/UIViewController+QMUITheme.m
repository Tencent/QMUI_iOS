/**
 * Tencent is pleased to support the open source community by making QMUI_iOS available.
 * Copyright (C) 2016-2021 THL A29 Limited, a Tencent company. All rights reserved.
 * Licensed under the MIT License (the "License"); you may not use this file except in compliance with the License. You may obtain a copy of the License at
 * http://opensource.org/licenses/MIT
 * Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.
 */
//
//  UIViewController+QMUITheme.m
//  QMUIKit
//
//  Created by MoLice on 2019/6/26.
//

#import "UIViewController+QMUITheme.h"
#import "QMUIModalPresentationViewController.h"

@implementation UIViewController (QMUITheme)

- (void)qmui_themeDidChangeByManager:(QMUIThemeManager *)manager identifier:(__kindof NSObject<NSCopying> *)identifier theme:(__kindof NSObject *)theme {
    /**
     https://github.com/Tencent/QMUI_iOS/issues/1451
     
     这里有个取舍——到底应该对所有的 childViewControllers 无脑触发回调，还是仅对当前可视的 childViewController 触发。
     
     如果触发所有的 childViewControllers，可能带来的问题是某些 child 只是被 add 到 parent 里，尚未被展示到屏幕上（例如 tabBarController 默认只展示了第一个 child，后面几个 child 在没被切换时，都处于“init 了但还没 load view”状态，此时如果触发他们的回调，他们在回调里进行一些 view 的操作，可能会提前触发 loadView，这不一定符合开发者的预期。换句话说，这个回调可能比 viewWillAppear:、viewDidAppear: 都要早，这不一定符合直觉。
     
     如果只触发可视的 childViewController 的回调，则在 theme 切换后，从可视的 child 回到前一个 child，前面这个 child 无法感知到在它的生命周期内曾经有 theme 被切换过。假如这个 child 在内部有一些“记录当前是哪个 theme”的行为，则这些行为也会出错，并且唯一代替这个回调的方式就只有自己监听 QMUIThemeDidChangeNotification，相对而言比较绕。
     
     综上，还是选择无脑触发所有 childViewControllers 回调的做法，至于“这个回调可能比 viewWillAppear:、viewDidAppear: 都要早”的问题，暂时交给开发者自己意识。
     */
    [self.childViewControllers enumerateObjectsUsingBlock:^(__kindof UIViewController * _Nonnull childViewController, NSUInteger idx, BOOL * _Nonnull stop) {
        [childViewController qmui_themeDidChangeByManager:manager identifier:identifier theme:theme];
    }];
    if (self.presentedViewController && self.presentedViewController.presentingViewController == self) {
        [self.presentedViewController qmui_themeDidChangeByManager:manager identifier:identifier theme:theme];
    }
}

@end

@implementation QMUIModalPresentationViewController (QMUITheme)

- (void)qmui_themeDidChangeByManager:(QMUIThemeManager *)manager identifier:(__kindof NSObject<NSCopying> *)identifier theme:(__kindof NSObject *)theme {
    [super qmui_themeDidChangeByManager:manager identifier:identifier theme:theme];
    if (self.contentViewController) {
        [self.contentViewController qmui_themeDidChangeByManager:manager identifier:identifier theme:theme];
    }
}

@end
