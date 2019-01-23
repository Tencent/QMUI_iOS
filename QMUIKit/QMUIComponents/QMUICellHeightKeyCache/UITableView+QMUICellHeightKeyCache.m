/*****
 * Tencent is pleased to support the open source community by making QMUI_iOS available.
 * Copyright (C) 2016-2019 THL A29 Limited, a Tencent company. All rights reserved.
 * Licensed under the MIT License (the "License"); you may not use this file except in compliance with the License. You may obtain a copy of the License at
 * http://opensource.org/licenses/MIT
 * Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.
 *****/

//
//  UITableView+QMUICellHeightKeyCache.m
//  QMUIKit
//
//  Created by QMUI Team on 2018/3/14.
//

#import "UITableView+QMUICellHeightKeyCache.h"
#import "QMUICore.h"
#import "QMUICellHeightKeyCache.h"
#import "UIView+QMUI.h"
#import "UIScrollView+QMUI.h"
#import "QMUITableViewProtocols.h"
#import "QMUIMultipleDelegates.h"

@interface UITableView ()

@property(nonatomic, strong) NSMutableDictionary<NSNumber *, QMUICellHeightKeyCache *> *qmui_allKeyCaches;
@end

@implementation UITableView (QMUICellHeightKeyCache)

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        SEL selectors[] = {
            @selector(setDelegate:)
        };
        for (NSUInteger index = 0; index < sizeof(selectors) / sizeof(SEL); index++) {
            SEL originalSelector = selectors[index];
            SEL swizzledSelector = NSSelectorFromString([@"qmui_" stringByAppendingString:NSStringFromSelector(originalSelector)]);
            ExchangeImplementations([self class], originalSelector, swizzledSelector);
        }
    });
}

static char kAssociatedObjectKey_qmuiCacheCellHeightByKeyAutomatically;
- (void)setQmui_cacheCellHeightByKeyAutomatically:(BOOL)qmui_cacheCellHeightByKeyAutomatically {
    objc_setAssociatedObject(self, &kAssociatedObjectKey_qmuiCacheCellHeightByKeyAutomatically, @(qmui_cacheCellHeightByKeyAutomatically), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    
    if (qmui_cacheCellHeightByKeyAutomatically) {
        
        NSAssert(!self.delegate || [self.delegate respondsToSelector:@selector(qmui_tableView:cacheKeyForRowAtIndexPath:)], @"%@ 需要实现 %@ 方法才能自动缓存 cell 高度", self.delegate, NSStringFromSelector(@selector(qmui_tableView:cacheKeyForRowAtIndexPath:)));
        NSAssert(self.estimatedRowHeight != 0, @"estimatedRowHeight 不能为 0，否则无法开启 self-sizing cells 功能");
        
        [self replaceMethodForDelegateIfNeeded:(id<QMUITableViewDelegate>)self.delegate];
        
        // 在上面那一句 replaceMethodForDelegateIfNeeded 里可能修改了 delegate 里的一些方法，所以需要通过重新设置 delegate 来触发 tableView 读取新的方法。
        self.delegate = self.delegate;
    }
}

- (BOOL)qmui_cacheCellHeightByKeyAutomatically {
    return [((NSNumber *)objc_getAssociatedObject(self, &kAssociatedObjectKey_qmuiCacheCellHeightByKeyAutomatically)) boolValue];
}

static char kAssociatedObjectKey_qmuiAllKeyCaches;
- (void)setQmui_allKeyCaches:(NSMutableDictionary<NSNumber *,QMUICellHeightKeyCache *> *)qmui_allKeyCaches {
    objc_setAssociatedObject(self, &kAssociatedObjectKey_qmuiAllKeyCaches, qmui_allKeyCaches, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSMutableDictionary<NSNumber *, QMUICellHeightKeyCache *> *)qmui_allKeyCaches {
    if (!objc_getAssociatedObject(self, &kAssociatedObjectKey_qmuiAllKeyCaches)) {
        self.qmui_allKeyCaches = [NSMutableDictionary dictionary];
    }
    return (NSMutableDictionary<NSNumber *, QMUICellHeightKeyCache *> *)objc_getAssociatedObject(self, &kAssociatedObjectKey_qmuiAllKeyCaches);
}

- (QMUICellHeightKeyCache *)qmui_currentCellHeightKeyCache {
    CGFloat width = [self widthForCacheKey];
    if (width <= 0) {
        return nil;
    }
    QMUICellHeightKeyCache *cache = self.qmui_allKeyCaches[@(width)];
    if (!cache) {
        cache = [[QMUICellHeightKeyCache alloc] init];
        self.qmui_allKeyCaches[@(width)] = cache;
    }
    return cache;
}

// 只考虑内容区域的宽度，因为 cell 的宽度就由这个来决定
- (CGFloat)widthForCacheKey {
    CGFloat width = CGRectGetWidth(self.bounds) - UIEdgeInsetsGetHorizontalValue(self.qmui_contentInset);
    return width;
}

- (void)qmui_tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (tableView.qmui_cacheCellHeightByKeyAutomatically) {
        id<NSCopying> cachedKey = [((id<QMUITableViewDelegate>)tableView.delegate) qmui_tableView:tableView cacheKeyForRowAtIndexPath:indexPath];
        [tableView.qmui_currentCellHeightKeyCache cacheHeight:CGRectGetHeight(cell.frame) forKey:cachedKey];
    }
}

- (CGFloat)qmui_tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (tableView.qmui_cacheCellHeightByKeyAutomatically) {
        id<NSCopying> cachedKey = [((id<QMUITableViewDelegate>)tableView.delegate) qmui_tableView:tableView cacheKeyForRowAtIndexPath:indexPath];
        if ([tableView.qmui_currentCellHeightKeyCache existsHeightForKey:cachedKey]) {
            return [tableView.qmui_currentCellHeightKeyCache heightForKey:cachedKey];
        }
        // 由于 QMUICellHeightKeyCache 只对 self-sizing 的 cell 生效，所以这里返回这个值，以使用 self-sizing 效果
        return UITableViewAutomaticDimension;
    } else {
        // 对于开启过 qmui_cacheCellHeightByKeyAutomatically 然后又关闭的 class 就会走到这里，做个保护而已。理论上走到这个分支本身就是没有意义的。
        return tableView.rowHeight;
    }
}

- (void)qmui_setDelegate:(id<QMUITableViewDelegate>)delegate {
    [self replaceMethodForDelegateIfNeeded:delegate];
    [self qmui_setDelegate:delegate];
}

static NSMutableSet<NSString *> *qmui_methodsReplacedClasses;
- (void)replaceMethodForDelegateIfNeeded:(id<QMUITableViewDelegate>)delegate {
    if (self.qmui_cacheCellHeightByKeyAutomatically && delegate) {
        if (!qmui_methodsReplacedClasses) {
            qmui_methodsReplacedClasses = [NSMutableSet set];
        }
        
        void (^addSelectorBlock)(id<QMUITableViewDelegate>) = ^void(id<QMUITableViewDelegate> aDelegate) {
            if ([qmui_methodsReplacedClasses containsObject:NSStringFromClass(aDelegate.class)]) {
                return;
            }
            [qmui_methodsReplacedClasses addObject:NSStringFromClass(aDelegate.class)];
            
            [self handleWillDisplayCellMethodForDelegate:aDelegate];
            [self handleHeightForRowMethodForDelegate:aDelegate];
        };
        
        if ([delegate isKindOfClass:[QMUIMultipleDelegates class]]) {
            NSPointerArray *delegates = [((QMUIMultipleDelegates *)delegate).delegates copy];
            for (id d in delegates) {
                if ([d conformsToProtocol:@protocol(QMUITableViewDelegate)]) {
                    addSelectorBlock((id<QMUITableViewDelegate>)d);
                }
            }
        } else {
            addSelectorBlock((id<QMUITableViewDelegate>)delegate);
        }
    }
}

- (void)handleWillDisplayCellMethodForDelegate:(id<QMUITableViewDelegate>)delegate {
    // 如果 delegate 本身没有实现 tableView:willDisplayCell:forRowAtIndexPath:，则为它添加一个。
    // 如果 delegate 已经有实现，则在调用完 delegate 自身的实现后，再调用我们自己的实现去存储计算后的 cell 高度
    SEL willDisplayCellSelector = @selector(tableView:willDisplayCell:forRowAtIndexPath:);
    Method willDisplayCellMethod = class_getInstanceMethod([self class], @selector(qmui_tableView:willDisplayCell:forRowAtIndexPath:));
    IMP willDisplayCellIMP = method_getImplementation(willDisplayCellMethod);
    void (*willDisplayCellFunction)(id<QMUITableViewDelegate>, SEL, UITableView *, UITableViewCell *, NSIndexPath *);
    willDisplayCellFunction = (void (*)(id<QMUITableViewDelegate>, SEL, UITableView *, UITableViewCell *, NSIndexPath *))willDisplayCellIMP;
    
    BOOL addedSuccessfully = class_addMethod(delegate.class, willDisplayCellSelector, willDisplayCellIMP, method_getTypeEncoding(willDisplayCellMethod));
    if (!addedSuccessfully) {
        OverrideImplementation([delegate class], willDisplayCellSelector, ^id(__unsafe_unretained Class originClass, SEL originCMD, IMP originIMP) {
            return ^(id<QMUITableViewDelegate> delegateSelf, UITableView *tableView, UITableViewCell *cell, NSIndexPath *indexPath) {
                
                // call super
                void (*originSelectorIMP)(id<QMUITableViewDelegate>, SEL, UITableView *, UITableViewCell *, NSIndexPath *);
                originSelectorIMP = (void (*)(id<QMUITableViewDelegate>, SEL, UITableView *, UITableViewCell *, NSIndexPath *))originIMP;
                originSelectorIMP(delegateSelf, originCMD, tableView, cell, indexPath);
                
                // avoid superclass
                if (![delegateSelf isKindOfClass:originClass]) return;
                
                // call QMUI
                willDisplayCellFunction(delegateSelf, willDisplayCellSelector, tableView, cell, indexPath);
            };
        });
    }
}

- (void)handleHeightForRowMethodForDelegate:(id<QMUITableViewDelegate>)delegate {
    // 如果 delegate 本身没有实现 tableView:heightForRowAtIndexPath:，则为它添加一个。
    // 如果 delegate 已经有实现，则优先拿它的实现的值来 return，如果它的值小于0（例如-1），则认为它想用 QMUICellHeightKeyCache 的计算，此时再 return 我们自己的计算结果
    SEL heightForRowSelector = @selector(tableView:heightForRowAtIndexPath:);
    Method heightForRowMethod = class_getInstanceMethod([self class], @selector(qmui_tableView:heightForRowAtIndexPath:));
    IMP heightForRowIMP = method_getImplementation(heightForRowMethod);
    CGFloat (*heightForRowFunction)(id<QMUITableViewDelegate>, SEL, UITableView *, NSIndexPath *);
    heightForRowFunction = (CGFloat (*)(id<QMUITableViewDelegate>, SEL, UITableView *, NSIndexPath *))heightForRowIMP;
    
    BOOL addedSuccessfully = class_addMethod([delegate class], heightForRowSelector, heightForRowIMP, method_getTypeEncoding(heightForRowMethod));
    if (!addedSuccessfully) {
        OverrideImplementation([delegate class], heightForRowSelector, ^id(__unsafe_unretained Class originClass, SEL originCMD, IMP originIMP) {
            return ^CGFloat(id<QMUITableViewDelegate> delegateSelf, UITableView *tableView, NSIndexPath *indexPath) {
                
                // call super
                CGFloat (*originSelectorIMP)(id<QMUITableViewDelegate>, SEL, UITableView *, NSIndexPath *);
                originSelectorIMP = (CGFloat (*)(id<QMUITableViewDelegate>, SEL, UITableView *, NSIndexPath *))originIMP;
                CGFloat result = originSelectorIMP(delegateSelf, originCMD, tableView, indexPath);
                
                // avoid superclass
                if (![delegateSelf isKindOfClass:originClass]) return result;
                
                if (result >= 0) {
                    return result;
                }
                
                // call QMUI
                return heightForRowFunction(delegateSelf, heightForRowSelector, tableView, indexPath);
            };
        });
    }
}

- (void)qmui_invalidateCellHeightCachedForKey:(id<NSCopying>)key {
    [self.qmui_allKeyCaches enumerateKeysAndObjectsUsingBlock:^(NSNumber * _Nonnull key, QMUICellHeightKeyCache * _Nonnull obj, BOOL * _Nonnull stop) {
        [obj invalidateHeightForKey:key];
    }];
}

- (void)qmui_invalidateAllCellHeightKeyCache {
    [self.qmui_allKeyCaches removeAllObjects];
}

@end
