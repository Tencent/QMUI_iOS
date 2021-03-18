/**
 * Tencent is pleased to support the open source community by making QMUI_iOS available.
 * Copyright (C) 2016-2020 THL A29 Limited, a Tencent company. All rights reserved.
 * Licensed under the MIT License (the "License"); you may not use this file except in compliance with the License. You may obtain a copy of the License at
 * http://opensource.org/licenses/MIT
 * Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.
 */

//
//  QMUIConsoleToolbar.h
//  QMUIKit
//
//  Created by MoLice on 2019/J/11.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class QMUIButton;
@class QMUITextField;

@interface QMUIConsoleToolbar : UIView

@property(nonatomic, strong, readonly) QMUIButton *levelButton;
@property(nonatomic, strong, readonly) QMUIButton *nameButton;
@property(nonatomic, strong, readonly) QMUIButton *clearButton;
@property(nonatomic, strong, readonly) QMUITextField *searchTextField;
@property(nonatomic, strong, readonly) UILabel *searchResultCountLabel;
@property(nonatomic, strong, readonly) QMUIButton *searchResultPreviousButton;
@property(nonatomic, strong, readonly) QMUIButton *searchResultNextButton;

- (void)setNeedsLayoutSearchResultViews;
@end

NS_ASSUME_NONNULL_END
