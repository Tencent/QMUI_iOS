//
//  UITableView+QMUICellHeightKeyCache.m
//  QMUIKit
//
//  Created by MoLice on 2018/3/14.
//  Copyright © 2018年 QMUI Team. All rights reserved.
//

#import "UITableView+QMUICellHeightKeyCache.h"
#import "QMUICore.h"
#import "QMUICellHeightKeyCache.h"
#import "UIView+QMUI.h"
#import "UIScrollView+QMUI.h"
#import "QMUITableViewProtocols.h"
#import <objc/runtime.h>

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
        
        [self replaceMethodForDelegateIfNeeded:self.delegate];
        
        // 在上面那一句 replaceMethodForDelegateIfNeeded 里可能修改了 delegate 里的一些方法，所以需要通过重新设置 delegate 来触发 tableView 读取新的方法。iOS 8 要先置空再设置才能生效。
        if (@available(iOS 9.0, *)) {
            self.delegate = self.delegate;
        } else {
            id <UITableViewDelegate> tempDelegate = self.delegate;
            self.delegate = nil;
            self.delegate = tempDelegate;
        }
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
    [tableView qmui_tableView:tableView willDisplayCell:cell forRowAtIndexPath:indexPath];
    if (tableView.qmui_cacheCellHeightByKeyAutomatically) {
        id<NSCopying> cachedKey = [((id<QMUICellHeightKeyCache_UITableViewDelegate>)self) qmui_tableView:tableView cacheKeyForRowAtIndexPath:indexPath];
        [tableView.qmui_currentCellHeightKeyCache cacheHeight:CGRectGetHeight(cell.frame) forKey:cachedKey];
    }
}

- (CGFloat)qmui_tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (tableView.qmui_cacheCellHeightByKeyAutomatically) {
        id<NSCopying> cachedKey = [((id<QMUICellHeightKeyCache_UITableViewDelegate>)self) qmui_tableView:tableView cacheKeyForRowAtIndexPath:indexPath];
        if ([tableView.qmui_currentCellHeightKeyCache existsHeightForKey:cachedKey]) {
            return [tableView.qmui_currentCellHeightKeyCache heightForKey:cachedKey];
        }
        // 由于 QMUICellHeightKeyCache 只对 self-sizing 的 cell 生效，所以这里返回这个值，以使用 self-sizing 效果
        return UITableViewAutomaticDimension;
    } else {
        // 对于开启过 qmui_cacheCellHeightByKeyAutomatically 然后又关闭的 class 就会走到这里，此时已经无法调用回之前被替换的方法的实现，所以直接使用 tableView.rowHeight
        // TODO: molice 最好应该在 replaceMethodForDelegateIfNeeded: 里判断在替换方法之前 delegate 是否已经有实现 heightForRow，如果有，则在这里调用回它自己的实现，如果没有，再使用 tableView.rowHeight，不然现在的做法会导致 delegate 里关闭了自动缓存的情况下就算实现了 heightForRow，也无法被调用。
        return tableView.rowHeight;
    }
}

- (void)qmui_setDelegate:(id<UITableViewDelegate>)delegate {
    [self replaceMethodForDelegateIfNeeded:delegate];
    [self qmui_setDelegate:delegate];
}

static NSMutableSet<NSString *> *qmui_methodsReplacedClasses;
- (void)replaceMethodForDelegateIfNeeded:(id<UITableViewDelegate>)delegate {
    if (self.qmui_cacheCellHeightByKeyAutomatically && delegate) {
        if (!qmui_methodsReplacedClasses) {
            qmui_methodsReplacedClasses = [NSMutableSet set];
        }
        if ([qmui_methodsReplacedClasses containsObject:NSStringFromClass(delegate.class)]) {
            return;
        }
        [qmui_methodsReplacedClasses addObject:NSStringFromClass(delegate.class)];
        
        ExchangeImplementationsInTwoClasses(delegate.class, @selector(tableView:willDisplayCell:forRowAtIndexPath:), self.class, @selector(qmui_tableView:willDisplayCell:forRowAtIndexPath:));
        ExchangeImplementationsInTwoClasses(delegate.class, @selector(tableView:heightForRowAtIndexPath:), self.class, @selector(qmui_tableView:heightForRowAtIndexPath:));
    }
}

- (void)qmui_invalidateAllCellHeightKeyCache {
    [self.qmui_allKeyCaches removeAllObjects];
}

@end
