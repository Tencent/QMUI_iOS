//
//  NSObject+QMUI.h
//  qmui
//
//  Created by MoLice on 2016/11/1.
//  Copyright © 2016年 QMUI Team. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSObject (QMUI)

/**
 判断当前类是否有重写某个父类的指定方法

 @param selector 要判断的方法
 @param superclass 要比较的父类，必须是当前类的某个 superclass
 @return YES 表示子类有重写了父类方法，NO 表示没有重写（异常情况也返回 NO，例如当前类与指定的类并非父子关系、父类本身也无法响应指定的方法）
 */
- (BOOL)qmui_hasOverrideMethod:(SEL)selector ofSuperclass:(Class)superclass;

/**
 对 super 发送消息

 @param aSelector 要发送的消息
 @return 消息执行后的结果
 @link http://stackoverflow.com/questions/14635024/using-objc-msgsendsuper-to-invoke-a-class-method
 */
- (id)qmui_performSelectorToSuperclass:(SEL)aSelector;

/**
 对 super 发送消息

 @param aSelector 要发送的消息
 @param object 作为参数传过去
 @return 消息执行后的结果
 @link http://stackoverflow.com/questions/14635024/using-objc-msgsendsuper-to-invoke-a-class-method
 */
- (id)qmui_performSelectorToSuperclass:(SEL)aSelector withObject:(id)object;

/**
 遍历某个 protocol 里的所有方法

 @param protocol 要遍历的 protocol，例如 \@protocol(xxx)
 @param block 遍历过程中调用的 block
 */
+ (void)qmui_enumerateProtocolMethods:(Protocol *)protocol usingBlock:(void (^)(SEL selector))block;
@end
