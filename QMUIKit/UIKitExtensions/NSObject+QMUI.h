/*****
 * Tencent is pleased to support the open source community by making QMUI_iOS available.
 * Copyright (C) 2016-2019 THL A29 Limited, a Tencent company. All rights reserved.
 * Licensed under the MIT License (the "License"); you may not use this file except in compliance with the License. You may obtain a copy of the License at
 * http://opensource.org/licenses/MIT
 * Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.
 *****/

//
//  NSObject+QMUI.h
//  qmui
//
//  Created by QMUI Team on 2016/11/1.
//

#import <Foundation/Foundation.h>
#import <objc/runtime.h>

@interface NSObject (QMUI)

/**
 判断当前类是否有重写某个父类的指定方法
 
 @param selector 要判断的方法
 @param superclass 要比较的父类，必须是当前类的某个 superclass
 @return YES 表示子类有重写了父类方法，NO 表示没有重写（异常情况也返回 NO，例如当前类与指定的类并非父子关系、父类本身也无法响应指定的方法）
 */
- (BOOL)qmui_hasOverrideMethod:(SEL)selector ofSuperclass:(Class)superclass;

/**
 判断指定的类是否有重写某个父类的指定方法
 
 @param selector 要判断的方法
 @param superclass 要比较的父类，必须是当前类的某个 superclass
 @return YES 表示子类有重写了父类方法，NO 表示没有重写（异常情况也返回 NO，例如当前类与指定的类并非父子关系、父类本身也无法响应指定的方法）
 */
+ (BOOL)qmui_hasOverrideMethod:(SEL)selector forClass:(Class)aClass ofSuperclass:(Class)superclass;

/**
 对 super 发送消息
 
 @param aSelector 要发送的消息
 @return 消息执行后的结果
 @link http://stackoverflow.com/questions/14635024/using-objc-msgsendsuper-to-invoke-a-class-method @/link
 */
- (id)qmui_performSelectorToSuperclass:(SEL)aSelector;

/**
 对 super 发送消息
 
 @param aSelector 要发送的消息
 @param object 作为参数传过去
 @return 消息执行后的结果
 @link http://stackoverflow.com/questions/14635024/using-objc-msgsendsuper-to-invoke-a-class-method @/link
 */
- (id)qmui_performSelectorToSuperclass:(SEL)aSelector withObject:(id)object;

/**
 *  系统的 performSelector 不支持参数或返回值为非对象的 selector 的调用，所以在 QMUI 增加了对应的方法，支持对象和非对象的 selector。
 *  这个方法用于无参数无返回值的 selector 调用。
 *  @param selector 要被调用的方法名
 */
- (void)qmui_performSelector:(SEL)selector;

/**
 *  系统的 performSelector 不支持参数或返回值为非对象的 selector 的调用，所以在 QMUI 增加了对应的方法，支持对象和非对象的 selector。
 *  @param selector 要被调用的方法名
 *  @param returnValue selector 的返回值的指针地址
 */
- (void)qmui_performSelector:(SEL)selector withReturnValue:(void *)returnValue;

/**
 *  系统的 performSelector 不支持参数或返回值为非对象的 selector 的调用，所以在 QMUI 增加了对应的方法，支持对象和非对象的 selector。
 *  @param selector 要被调用的方法名
 *  @param firstArgument 调用 selector 时要传的第一个参数的指针地址
 */
- (void)qmui_performSelector:(SEL)selector withArguments:(void *)firstArgument, ...;

/**
 *  系统的 performSelector 不支持参数或返回值为非对象的 selector 的调用，所以在 QMUI 增加了对应的方法，支持对象和非对象的 selector。
 *
 *  使用示例：
 *  CGFloat result;
 *  CGFloat arg1, arg2;
 *  [self qmui_performSelector:xxx withReturnValue:&result arguments:&arg1, &arg2, nil];
 *  // 到这里 result 已经被赋值为 selector 的 return 值
 *
 *  @param selector 要被调用的方法名
 *  @param returnValue selector 的返回值的指针地址
 *  @param firstArgument 调用 selector 时要传的第一个参数的指针地址
 */
- (void)qmui_performSelector:(SEL)selector withReturnValue:(void *)returnValue arguments:(void *)firstArgument, ...;


/**
 使用 block 遍历指定 class 的所有成员变量（也即 _xxx 那种），不包含 property 对应的 _property 成员变量，也不包含 superclasses 里定义的变量
 
 @param block 用于遍历的 block
 */
- (void)qmui_enumrateIvarsUsingBlock:(void (^)(Ivar ivar, NSString *ivarName))block;

/**
 使用 block 遍历指定 class 的所有成员变量（也即 _xxx 那种），不包含 property 对应的 _property 成员变量
 
 @param aClass 指定的 class
 @param includingInherited 是否要包含由继承链带过来的 ivars
 @param block  用于遍历的 block
 */
+ (void)qmui_enumrateIvarsOfClass:(Class)aClass includingInherited:(BOOL)includingInherited usingBlock:(void (^)(Ivar ivar, NSString *ivarName))block;

/**
 使用 block 遍历指定 class 的所有属性，不包含 superclasses 里定义的 property
 
 @param block 用于遍历的 block，如果要获取 property 的信息，推荐用 QMUIPropertyDescriptor。
 */
- (void)qmui_enumratePropertiesUsingBlock:(void (^)(objc_property_t property, NSString *propertyName))block;

/**
 使用 block 遍历指定 class 的所有属性
 
 @param aClass 指定的 class
 @param includingInherited 是否要包含由继承链带过来的 property
 @param block 用于遍历的 block，如果要获取 property 的信息，推荐用 QMUIPropertyDescriptor。
 @see https://developer.apple.com/library/archive/documentation/Cocoa/Conceptual/ObjCRuntimeGuide/Articles/ocrtPropertyIntrospection.html#//apple_ref/doc/uid/TP40008048-CH101-SW1
 */
+ (void)qmui_enumratePropertiesOfClass:(Class)aClass includingInherited:(BOOL)includingInherited usingBlock:(void (^)(objc_property_t property, NSString *propertyName))block;

/**
 使用 block 遍历当前实例的所有方法，不包含 superclasses 里定义的 method
 */
- (void)qmui_enumrateInstanceMethodsUsingBlock:(void (^)(Method method, SEL selector))block;

/**
 使用 block 遍历指定的某个类的实例方法
 @param aClass   指定的 class
 @param includingInherited 是否要包含由继承链带过来的 method
 @param block    用于遍历的 block
 */
+ (void)qmui_enumrateInstanceMethodsOfClass:(Class)aClass includingInherited:(BOOL)includingInherited usingBlock:(void (^)(Method method, SEL selector))block;

/**
 遍历某个 protocol 里的所有方法
 
 @param protocol 要遍历的 protocol，例如 \@protocol(xxx)
 @param block 遍历过程中调用的 block
 */
+ (void)qmui_enumerateProtocolMethods:(Protocol *)protocol usingBlock:(void (^)(SEL selector))block;

@end


@interface NSObject (QMUI_DataBind)

/**
 给对象绑定上另一个对象以供后续取出使用，如果 object 传入 nil 则会清除该 key 之前绑定的对象
 
 @attention 被绑定的对象会被 strong 强引用
 @note 内部是使用 objc_setAssociatedObject / objc_getAssociatedObject 来实现
 
 @code
 - (UITableViewCell *)cellForIndexPath:(NSIndexPath *)indexPath {
 // 1）在这里给 button 绑定上 indexPath 对象
 [cell qmui_bindObject:indexPath forKey:@"indexPath"];
 }
 
 - (void)didTapButton:(UIButton *)button {
 // 2）在这里取出被点击的 button 的 indexPath 对象
 NSIndexPath *indexPathTapped = [button qmui_getBoundObjectForKey:@"indexPath"];
 }
 @endcode
 */
- (void)qmui_bindObject:(id)object forKey:(NSString *)key;

/**
 给对象绑定上另一个对象以供后续取出使用，但相比于 qmui_bindObject:forKey:，该方法不会 strong 强引用传入的 object
 */
- (void)qmui_bindObjectWeakly:(id)object forKey:(NSString *)key;

/**
 取出之前使用 bind 方法绑定的对象
 */
- (id)qmui_getBoundObjectForKey:(NSString *)key;

/**
 给对象绑定上一个 double 值以供后续取出使用
 */
- (void)qmui_bindDouble:(double)doubleValue forKey:(NSString *)key;

/**
 取出之前用 bindDouble:forKey: 绑定的值
 */
- (double)qmui_getBoundDoubleForKey:(NSString *)key;

/**
 给对象绑定上一个 BOOL 值以供后续取出使用
 */
- (void)qmui_bindBOOL:(BOOL)boolValue forKey:(NSString *)key;

/**
 取出之前用 bindBOOL:forKey: 绑定的值
 */
- (BOOL)qmui_getBoundBOOLForKey:(NSString *)key;

/**
 给对象绑定上一个 long 值以供后续取出使用
 */
- (void)qmui_bindLong:(long)longValue forKey:(NSString *)key;

/**
 取出之前用 bindLong:forKey: 绑定的值
 */
- (long)qmui_getBoundLongForKey:(NSString *)key;

/**
 移除之前使用 bind 方法绑定的对象
 */
- (void)qmui_clearBindingForKey:(NSString *)key;

/**
 移除之前使用 bind 方法绑定的所有对象
 */
- (void)qmui_clearAllBinding;

/**
 返回当前有绑定对象存在的所有的 key 的数组，如果不存在任何 key，则返回一个空数组
 @note 数组中元素的顺序是随机的
 */
- (NSArray<NSString *> *)qmui_allBindingKeys;

/**
 返回是否设置了某个 key
 */
- (BOOL)qmui_hasBindingKey:(NSString *)key;

@end
