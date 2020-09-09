/**
 * Tencent is pleased to support the open source community by making QMUI_iOS available.
 * Copyright (C) 2016-2020 THL A29 Limited, a Tencent company. All rights reserved.
 * Licensed under the MIT License (the "License"); you may not use this file except in compliance with the License. You may obtain a copy of the License at
 * http://opensource.org/licenses/MIT
 * Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.
 */

//
//  QMUITableView.m
//  qmui
//
//  Created by QMUI Team on 14-7-2.
//

#import "QMUITableView.h"
#import "UITableView+QMUI.h"
#import "UIView+QMUI.h"

@implementation QMUITableView

@dynamic delegate;
@dynamic dataSource;

- (instancetype)initWithFrame:(CGRect)frame style:(UITableViewStyle)style {
    if (self = [super initWithFrame:frame style:style]) {
        [self didInitialize];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
        [self didInitialize];
    }
    return self;
}

- (void)didInitialize {
    [self qmui_styledAsQMUITableView];
}

- (void)dealloc {
    self.delegate = nil;
    self.dataSource = nil;
}

// 保证一直存在tableFooterView，以去掉列表内容不满一屏时尾部的空白分割线
- (void)setTableFooterView:(UIView *)tableFooterView {
    if (!tableFooterView) {
        tableFooterView = [[UIView alloc] init];
    }
    [super setTableFooterView:tableFooterView];
}

- (BOOL)touchesShouldCancelInContentView:(UIView *)view {
    if ([self.delegate respondsToSelector:@selector(tableView:touchesShouldCancelInContentView:)]) {
        return [self.delegate tableView:self touchesShouldCancelInContentView:view];
    }
    // 默认情况下只有当view是非UIControl的时候才会返回yes，这里统一对UIButton也返回yes
    // 原因是UITableView上面把事件延迟去掉了，但是这样如果拖动的时候手指是在UIControl上面的话，就拖动不了了
    if ([view isKindOfClass:[UIControl class]]) {
        if ([view isKindOfClass:[UIButton class]]) {
            return YES;
        } else {
            return NO;
        }
    }
    return YES;
}

@end
