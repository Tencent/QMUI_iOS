/*****
 * Tencent is pleased to support the open source community by making QMUI_iOS available.
 * Copyright (C) 2016-2019 THL A29 Limited, a Tencent company. All rights reserved.
 * Licensed under the MIT License (the "License"); you may not use this file except in compliance with the License. You may obtain a copy of the License at
 * http://opensource.org/licenses/MIT
 * Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.
 *****/

//
//  UITableView+QMUI.m
//  qmui
//
//  Created by QMUI Team on 15/7/20.
//

#import "UITableView+QMUI.h"
#import "QMUICore.h"
#import "UIScrollView+QMUI.h"
#import "QMUILog.h"
#import "NSObject+QMUI.h"

const NSUInteger kFloatValuePrecision = 4;// 统一一个小数点运算精度

@implementation UITableView (QMUI)

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        ExtendImplementationOfNonVoidMethodWithTwoArguments([UITableView class], @selector(initWithFrame:style:), CGRect, UITableViewStyle, UITableView *, ^UITableView *(UITableView *selfObject, CGRect frame, UITableViewStyle style, UITableView *originReturnValue) {
            // iOS 11 之后 estimatedRowHeight 如果值为 UITableViewAutomaticDimension，estimate 效果也会生效（iOS 11 以前要 > 0 才会生效）。
            // 而当使用 estimate 效果时，会导致 contentSize 之类的计算不准确，所以这里给一个途径让项目可以方便地控制 QMUITableView（及其子类） 和 UITableView（不包含子类，例如 UIPickerTableView）的 estimatedRowHeight 效果的开关 https://github.com/Tencent/QMUI_iOS/issues/313
            if ([selfObject isKindOfClass:NSClassFromString(@"QMUITableView")] || [NSStringFromClass(selfObject.class) isEqualToString:@"UITableView"]) {
                if (TableViewEstimatedHeightEnabled) {
                    selfObject.estimatedRowHeight = TableViewCellNormalHeight;
                    selfObject.estimatedSectionHeaderHeight = TableViewCellNormalHeight;
                    selfObject.estimatedSectionFooterHeight = TableViewCellNormalHeight;
                } else {
                    selfObject.estimatedRowHeight = 0;
                    selfObject.estimatedSectionHeaderHeight = 0;
                    selfObject.estimatedSectionFooterHeight = 0;
                }
            }
            return originReturnValue;
        });
        
        OverrideImplementation([UITableView class], @selector(sizeThatFits:), ^id(__unsafe_unretained Class originClass, SEL originCMD, IMP (^originalIMPProvider)(void)) {
            return ^CGSize(UITableView *selfObject, CGSize size) {
                // avoid superclass
                if ([selfObject isKindOfClass:originClass]) {
                    [selfObject alertEstimatedHeightUsageIfDetected];
                }
                
                // call super
                CGSize (*originSelectorIMP)(id, SEL, CGSize);
                originSelectorIMP = (CGSize (*)(id, SEL, CGSize))originalIMPProvider();
                CGSize result = originSelectorIMP(selfObject, originCMD, size);
                
                return result;
            };
        });
        
        OverrideImplementation([UITableView class], @selector(scrollToRowAtIndexPath:atScrollPosition:animated:), ^id(__unsafe_unretained Class originClass, SEL originCMD, IMP (^originalIMPProvider)(void)) {
            return ^(UITableView *selfObject, NSIndexPath *indexPath, UITableViewScrollPosition scrollPosition, BOOL animated) {
                
                // avoid superclass
                if ([selfObject isKindOfClass:originClass]) {
                    if (!indexPath) {
                        return;
                    }
                    
                    BOOL isIndexPathLegal = YES;
                    NSInteger numberOfSections = [selfObject numberOfSections];
                    if (indexPath.section >= numberOfSections) {
                        isIndexPathLegal = NO;
                    } else if (indexPath.row != NSNotFound) {
                        NSInteger rows = [selfObject numberOfRowsInSection:indexPath.section];
                        isIndexPathLegal = indexPath.row < rows;
                    }
                    if (!isIndexPathLegal) {
                        QMUILogWarn(@"UITableView (QMUI)", @"%@ - target indexPath : %@ ，不合法的indexPath。\n%@", selfObject, indexPath, [NSThread callStackSymbols]);
                        if (QMUICMIActivated && !ShouldPrintQMUIWarnLogToConsole) {
                            NSAssert(NO, @"出现不合法的indexPath");
                        }
                        return;
                    }
                }
                
                // call super
                void (*originSelectorIMP)(id, SEL, NSIndexPath *, UITableViewScrollPosition, BOOL);
                originSelectorIMP = (void (*)(id, SEL, NSIndexPath *, UITableViewScrollPosition, BOOL))originalIMPProvider();
                originSelectorIMP(selfObject, originCMD, indexPath, scrollPosition, animated);
            };
        });
    });
}

// 防止 release 版本滚动到不合法的 indexPath 会 crash
- (void)qmui_scrollToRowAtIndexPath:(NSIndexPath *)indexPath atScrollPosition:(UITableViewScrollPosition)scrollPosition animated:(BOOL)animated {
    if (!indexPath) {
        return;
    }
    
    BOOL isIndexPathLegal = YES;
    NSInteger numberOfSections = [self numberOfSections];
    if (indexPath.section >= numberOfSections) {
        isIndexPathLegal = NO;
    } else if (indexPath.row != NSNotFound) {
        NSInteger rows = [self numberOfRowsInSection:indexPath.section];
        isIndexPathLegal = indexPath.row < rows;
    }
    if (!isIndexPathLegal) {
        QMUILogWarn(@"UITableView (QMUI)", @"%@ - target indexPath : %@ ，不合法的indexPath。\n%@", self, indexPath, [NSThread callStackSymbols]);
        if (QMUICMIActivated && !ShouldPrintQMUIWarnLogToConsole) {
            NSAssert(NO, @"出现不合法的indexPath");
        }
    } else {
        [self qmui_scrollToRowAtIndexPath:indexPath atScrollPosition:scrollPosition animated:animated];
    }
}

- (void)qmui_styledAsQMUITableView {
    
    self.rowHeight = TableViewCellNormalHeight;
    
    UIColor *backgroundColor = nil;
    if (self.style == UITableViewStylePlain) {
        backgroundColor = TableViewBackgroundColor;
        self.tableFooterView = [[UIView alloc] init]; // 去掉空白的cell
    } else {
        backgroundColor = TableViewGroupedBackgroundColor;
    }
    if (backgroundColor) {
        self.backgroundColor = backgroundColor;
    }
    self.separatorColor = TableViewSeparatorColor;
    self.backgroundView = [[UIView alloc] init]; // 设置一个空的 backgroundView，去掉系统自带的，以使 backgroundColor 生效
    
    self.sectionIndexColor = TableSectionIndexColor;
    self.sectionIndexTrackingBackgroundColor = TableSectionIndexTrackingBackgroundColor;
    self.sectionIndexBackgroundColor = TableSectionIndexBackgroundColor;
}

static char kAssociatedObjectKey_initialContentInset;
- (void)setQmui_initialContentInset:(UIEdgeInsets)qmui_initialContentInset {
    objc_setAssociatedObject(self, &kAssociatedObjectKey_initialContentInset, [NSValue valueWithUIEdgeInsets:qmui_initialContentInset], OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    self.contentInset = qmui_initialContentInset;
    self.scrollIndicatorInsets = qmui_initialContentInset;
    [self qmui_scrollToTopUponContentInsetTopChange];
}

- (UIEdgeInsets)qmui_initialContentInset {
    return [((NSValue *)objc_getAssociatedObject(self, &kAssociatedObjectKey_initialContentInset)) UIEdgeInsetsValue];
}

- (NSIndexPath *)qmui_indexPathForRowAtView:(UIView *)view {
    if (!view || !view.superview) {
        return nil;
    }
    
    if ([view isKindOfClass:[UITableViewCell class]] && ([NSStringFromClass(view.superview.class) isEqualToString:@"UITableViewWrapperView"] ? view.superview.superview : view.superview) == self) {
        // iOS 11 下，cell.superview 是 UITableView，iOS 11 以前，cell.superview 是 UITableViewWrapperView
        return [self indexPathForCell:(UITableViewCell *)view];
    }
    
    return [self qmui_indexPathForRowAtView:view.superview];
}

- (NSInteger)qmui_indexForSectionHeaderAtView:(UIView *)view {
    [self alertEstimatedHeightUsageIfDetected];
    
    if (!view || ![view isKindOfClass:[UIView class]]) {
        return -1;
    }
    
    CGPoint origin = [self convertPoint:view.frame.origin fromView:view.superview];
    origin = CGPointToFixed(origin, kFloatValuePrecision);// 避免一些浮点数精度问题导致的计算错误
    
    NSUInteger numberOfSection = [self numberOfSections];
    // TODO: molice 针对 section 特别多的场景，优化一下这里的遍历查找
    for (NSInteger i = 0; i < numberOfSection; i++) {
        CGRect rectForSection = [self rectForSection:i];// TODO: 这里的判断用整个 section 的 rect，可能需要加上“view 是否在 sectionHeader 上的判断”
        rectForSection = CGRectToFixed(rectForSection, kFloatValuePrecision);
        if (CGRectContainsPoint(rectForSection, origin)) {
            return i;
        }
    }
    return -1;
}

- (NSArray<NSNumber *> *)qmui_indexForVisibleSectionHeaders {
    NSArray<NSIndexPath *> *visibleCellIndexPaths = [self indexPathsForVisibleRows];
    NSMutableArray<NSNumber *> *visibleSections = [[NSMutableArray alloc] init];
    NSMutableArray<NSNumber *> *result = [[NSMutableArray alloc] init];
    for (NSInteger i = 0; i < visibleCellIndexPaths.count; i++) {
        if (visibleSections.count == 0 || visibleCellIndexPaths[i].section != visibleSections.lastObject.integerValue) {
            [visibleSections addObject:@(visibleCellIndexPaths[i].section)];
        }
    }
    for (NSInteger i = 0; i < visibleSections.count; i++) {
        NSInteger section = visibleSections[i].integerValue;
        if ([self qmui_isHeaderVisibleForSection:section]) {
            [result addObject:visibleSections[i]];
        }
    }
    if (result.count == 0) {
        result = nil;
    }
    return result;
}

- (NSInteger)qmui_indexOfPinnedSectionHeader {
    NSArray<NSNumber *> *visibleSectionIndex = [self qmui_indexForVisibleSectionHeaders];
    for (NSInteger i = 0; i < visibleSectionIndex.count; i++) {
        NSInteger section = visibleSectionIndex[i].integerValue;
        if ([self qmui_isHeaderPinnedForSection:section]) {
            return section;
        } else {
            continue;
        }
    }
    return -1;
}

- (BOOL)qmui_isHeaderPinnedForSection:(NSInteger)section {
    if (self.style != UITableViewStylePlain) return NO;
    if (section >= [self numberOfSections]) return NO;
    
    // 系统这两个接口获取到的 rect 是在 contentSize 里的 rect，而不是实际看到的 rect
    CGRect rectForSection = [self rectForSection:section];
    CGRect rectForHeader = [self rectForHeaderInSection:section];
    BOOL isSectionScrollIntoContentInsetTop = self.contentOffset.y + self.qmui_contentInset.top > CGRectGetMinY(rectForSection);// 表示这个 section 已经往上滚动，超过 contentInset.top 那条线了
    BOOL isSectionStayInContentInsetTop = self.contentOffset.y + self.qmui_contentInset.top <= CGRectGetMaxY(rectForSection) - CGRectGetHeight(rectForHeader);// 表示这个 section 还没被完全滚走
    BOOL isPinned = isSectionScrollIntoContentInsetTop && isSectionStayInContentInsetTop;
    return isPinned;
}

- (BOOL)qmui_isHeaderVisibleForSection:(NSInteger)section {
    if (self.style != UITableViewStylePlain) return NO;
    if (section >= [self numberOfSections]) return NO;
    
    // 不存在 header 就不用判断
    CGRect rectForSectionHeader = [self rectForHeaderInSection:section];
    if (CGRectGetHeight(rectForSectionHeader) <= 0) return NO;
    
    // 系统这个接口获取到的 rect 是在 contentSize 里的 rect，而不是实际看到的 rect
    CGRect rectForSection = [self rectForSection:section];
    BOOL isSectionScrollIntoBounds = CGRectGetMinY(rectForSection) < self.contentOffset.y + CGRectGetHeight(self.bounds);
    BOOL isSectionStayInContentInsetTop = self.contentOffset.y + self.qmui_contentInset.top < CGRectGetMaxY(rectForSection);// 表示这个 section 还没被完全滚走
    BOOL isVisible = isSectionScrollIntoBounds && isSectionStayInContentInsetTop;
    return isVisible;
}

- (QMUITableViewCellPosition)qmui_positionForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSInteger numberOfRowsInSection = [self.dataSource tableView:self numberOfRowsInSection:indexPath.section];
    if (numberOfRowsInSection == 1) {
        return QMUITableViewCellPositionSingleInSection;
    }
    if (indexPath.row == 0) {
        return QMUITableViewCellPositionFirstInSection;
    }
    if (indexPath.row == numberOfRowsInSection - 1) {
        return QMUITableViewCellPositionLastInSection;
    }
    return QMUITableViewCellPositionMiddleInSection;
}

- (BOOL)qmui_cellVisibleAtIndexPath:(NSIndexPath *)indexPath {
    NSArray<NSIndexPath *> *visibleCellIndexPaths = self.indexPathsForVisibleRows;
    for (NSIndexPath *visibleIndexPath in visibleCellIndexPaths) {
        if ([indexPath isEqual:visibleIndexPath]) {
            return YES;
        }
    }
    return NO;
}

- (void)qmui_clearsSelection {
    NSArray<NSIndexPath *> *selectedIndexPaths = [self indexPathsForSelectedRows];
    for (NSIndexPath *indexPath in selectedIndexPaths) {
        [self deselectRowAtIndexPath:indexPath animated:YES];
    }
}

- (void)qmui_scrollToRowFittingOffsetY:(CGFloat)offsetY atIndexPath:(NSIndexPath *)indexPath animated:(BOOL)animated {
    [self alertEstimatedHeightUsageIfDetected];
    
    if (![self qmui_canScroll]) {
        return;
    }
    
    CGRect rectForRow = [self rectForRowAtIndexPath:indexPath];
    if (CGRectEqualToRect(rectForRow, CGRectZero)) {
        return;
    }
    
    // 如果要滚到的row在列表尾部，则这个row是不可能滚到顶部的（因为列表尾部已经不够空间了），所以要判断一下
    BOOL canScrollRowToTop = CGRectGetMaxY(rectForRow) + CGRectGetHeight(self.frame) - (offsetY + CGRectGetHeight(rectForRow)) <= self.contentSize.height;
    if (canScrollRowToTop) {
        [self setContentOffset:CGPointMake(self.contentOffset.x, CGRectGetMinY(rectForRow) - offsetY) animated:animated];
    } else {
        [self qmui_scrollToBottomAnimated:animated];
    }
}

- (CGSize)qmui_realContentSize {
    [self alertEstimatedHeightUsageIfDetected];
    
    if (!self.dataSource || !self.delegate) {
        return CGSizeZero;
    }
    
    CGSize contentSize = self.contentSize;
    CGFloat footerViewMaxY = CGRectGetMaxY(self.tableFooterView.frame);
    CGSize realContentSize = CGSizeMake(contentSize.width, footerViewMaxY);
    
    NSInteger lastSection = [self numberOfSections] - 1;
    if (lastSection < 0) {
        // 说明numberOfSetions为0，tableView没有cell，则直接取footerView的底边缘
        return realContentSize;
    }
    
    CGRect lastSectionRect = [self rectForSection:lastSection];
    realContentSize.height = fmax(realContentSize.height, CGRectGetMaxY(lastSectionRect));
    return realContentSize;
}

- (BOOL)qmui_canScroll {
    // 没有高度就不用算了，肯定不可滚动，这里只是做个保护
    if (CGRectGetHeight(self.bounds) <= 0) {
        return NO;
    }
    
    if ([self.tableHeaderView isKindOfClass:[UISearchBar class]]) {
        BOOL canScroll = self.qmui_realContentSize.height + UIEdgeInsetsGetVerticalValue(self.qmui_contentInset) > CGRectGetHeight(self.bounds);
        return canScroll;
    } else {
        return [super qmui_canScroll];
    }
}

- (void)alertEstimatedHeightUsageIfDetected {
    BOOL usingEstimatedRowHeight = self.estimatedRowHeight == UITableViewAutomaticDimension;
    BOOL usingEstimatedSectionHeaderHeight = self.estimatedSectionHeaderHeight == UITableViewAutomaticDimension;
    BOOL usingEstimatedSectionFooterHeight = self.estimatedSectionFooterHeight == UITableViewAutomaticDimension;
    
    if (usingEstimatedRowHeight || usingEstimatedSectionHeaderHeight || usingEstimatedSectionFooterHeight) {
        [self QMUISymbolicUsingTableViewEstimatedHeightMakeWarning];
    }
}

- (void)QMUISymbolicUsingTableViewEstimatedHeightMakeWarning {
    QMUILog(@"UITableView 的 estimatedRow(SectionHeader / SectionFooter)Height 属性会影响 contentSize、sizeThatFits:、rectForXxx 等方法的计算，导致计算结果不准确，建议重新考虑是否要使用 estimated。可添加 '%@' 的 Symbolic Breakpoint 以捕捉此类信息\n%@", NSStringFromSelector(_cmd), [NSThread callStackSymbols]);
}

- (void)qmui_performBatchUpdates:(void (NS_NOESCAPE ^ _Nullable)(void))updates completion:(void (^ _Nullable)(BOOL finished))completion {
    if (@available(iOS 11.0, *)) {
        [self performBatchUpdates:updates completion:completion];
    } else {
        if (!updates && completion) {
            completion(YES);// 私有方法对 updates 为空的情况，不会调用 completion，但 iOS 11 新增的方法是可以的，所以这里对齐新版本的行为
        } else {
            [self qmui_performSelector:NSSelectorFromString([NSString stringWithFormat:@"_%@BatchUpdates:%@:", @"perform", @"completion"]) withArguments:&updates, &completion, nil];
        }
    }
}

@end
