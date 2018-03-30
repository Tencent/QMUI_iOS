//
//  NSObject+MultipleDelegates.h
//  QMUIKit
//
//  Created by MoLice on 2018/3/27.
//  Copyright © 2018年 QMUI Team. All rights reserved.
//

#import <Foundation/Foundation.h>

@class QMUIMultipleDelegates;

/**
 *  让所有 NSObject 都支持多个 delegate，默认只支持属性名为 delegate 的 delegate（特别地，UITableView 和 UICollectionView 额外默认支持 dataSource）。
 *  使用方式：将 qmui_multipleDelegatesEnabled 置为 YES 后像平时一样 self.delegate = xxx 即可。
 *  如果你要清掉所有的 delegate，则像平时一样 self.delegate = nil 即可。
 *  如果你把 delegate 同时赋值给 objA 和 objB，而你只要移除 objB，则可：[self.qmui_delegates[NSStringFromSelector(@selector(delegate))] removeDelegate:objB]
 *
 *  如果你要让其他命名的 delegate 属性也支持多 delegate，则可调用 qmui_registerDelegateSelector: 方法将该属性的 getter 传进去，再进行实际的 delegate 赋值，例如你的 delegate 命名为 abcDelegate，则你可以这么写：
 *  [self qmui_registerDelegateSelector:@selector(abcDelegate)];
 *  self.abcDelegate = delegateA;
 *  self.abcDelegate = delegateB;
 */
@interface NSObject (QMUIMultipleDelegates)

/// 当你需要当前的 class 支持多个 delegate，请将此属性置为 YES。默认为 NO。
@property(nonatomic, assign) BOOL qmui_multipleDelegatesEnabled;

/// 让某个 delegate 属性也支持多 delegate 模式（因为默认只帮你加了 @selector(delegate) 的支持）
- (void)qmui_registerDelegateSelector:(SEL)getter;

/// 获取当前对象所有的 QMUIMultipleDelegates 容器。key 是 delegate 的 setter 的字符串，例如 NSStringFromSelector(@selector(abcDelegate))，value 是这个 delegate 属性当前所有的 delegate 对象，例如 viewController1、viewController2
@property(nonatomic, copy, readonly) NSDictionary<NSString *, QMUIMultipleDelegates *> *qmui_delegates;
@end
