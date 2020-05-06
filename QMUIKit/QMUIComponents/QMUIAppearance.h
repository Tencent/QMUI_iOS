/**
 * Tencent is pleased to support the open source community by making QMUI_iOS available.
 * Copyright (C) 2016-2020 THL A29 Limited, a Tencent company. All rights reserved.
 * Licensed under the MIT License (the "License"); you may not use this file except in compliance with the License. You may obtain a copy of the License at
 * http://opensource.org/licenses/MIT
 * Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.
 */
//
//  QMUIAppearance.h
//  QMUIKit
//
//  Created by MoLice on 2020/3/25.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/**
UIKit 仅提供了对 UIView 默认的 UIAppearance 支持，如果你是一个继承自 NSObject 的对象，想要使用 UIAppearance 能力，按 UIKit 公开的 API 是无法实现的，而 QMUIAppearance 对这种场景提供了支持。

使用方法（可参考 QMUIAlertController）：

1. 为目标类增加方法 +(instancetype)appearance; 方法，返回值类型使用 instancetype 是为了保证 Xcode 能正确进行代码提示。

2. 为目标类支持 appearance 的属性、方法添加 UI_APPEARANCE_SELECTOR 标记，注意对于方法只有符合特定命名格式才支持，具体请查看 UIAppearance.h 顶部对宏 UI_APPEARANCE_SELECTOR 的注释。
 
3. 在 +appearance 方法里通过 +[QMUIAppearance appearanceForClass:self] 得到 appearance 对象并返回。
 
4. 在恰当的时机为目标类的 appearance 赋初始值，QMUI 通常在类的 +initialize 方法里赋值。
 
5. 在类初始化实例的时候（例如 init 方法里）调用 -qmui_applyQMUIAppearance 为实例赋初始值，注意如果你的父类已经调用过的话，子类不需要再重复调用。

@note 特别的，如果你正在为一个 UIView 子类支持 UIAppearance，不需要用到 QMUIAppearance，直接将属性、方法加上 UI_APPEARANCE_SELECTOR 标记即可，也不需要通过 -qmui_applyAppearance 的方式赋初始值（除非你希望这个赋值时机提前，系统默认时机是在 didMoveToWindow 时），系统都已经帮你处理好了，具体可查看 UIKit Documentation。
*/
@interface QMUIAppearance : NSObject

/**
 获取指定 Class 的 appearance 对象，每个 Class 全局只会存在一个 appearance 对象。
 */
+ (id)appearanceForClass:(Class)aClass;
@end

@interface NSObject (QMUIAppearnace)

/**
 从 appearance 里取值并赋值给当前实例，通常在对象的 init 里调用（只要在实例初始化后、使用前就可以）。适用于 QMUIAppearance 和系统的 UIAppearance。
 */
- (void)qmui_applyAppearance;
@end

NS_ASSUME_NONNULL_END
