/**
 * Tencent is pleased to support the open source community by making QMUI_iOS available.
 * Copyright (C) 2016-2021 THL A29 Limited, a Tencent company. All rights reserved.
 * Licensed under the MIT License (the "License"); you may not use this file except in compliance with the License. You may obtain a copy of the License at
 * http://opensource.org/licenses/MIT
 * Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.
 */

//
//  UITableView+QMUI.m
//  qmui
//
//  Created by QMUI Team on 15/7/20.
//

#import "UIView+QMUI.h"
#import "UITableView+QMUI.h"
#import "UITableViewCell+QMUI.h"
#import "QMUICore.h"
#import "UIScrollView+QMUI.h"
#import "QMUILog.h"
#import "NSObject+QMUI.h"
#import "CALayer+QMUI.h"

const NSUInteger kFloatValuePrecision = 4;// 统一一个小数点运算精度

@interface UITableView ()
@property(nonatomic, assign, readwrite) UITableViewStyle qmui_style;
@property(nonatomic, assign, readonly) CGRect qmui_indexFrame;
@end

@implementation UITableView (QMUI)

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        OverrideImplementation([UITableView class], @selector(initWithFrame:style:), ^id(__unsafe_unretained Class originClass, SEL originCMD, IMP (^originalIMPProvider)(void)) {
            return ^UITableView *(UITableView *selfObject, CGRect firstArgv, UITableViewStyle secondArgv) {
                
                if (@available(iOS 13.0, *)) {
                    // iOS 13 qmui_style 的 getter 直接返回 tableView.style，所以这里不需要给 qmui_style 赋值
                } else {
                    selfObject.qmui_style = secondArgv;
                    if (secondArgv == QMUITableViewStyleInsetGrouped) {
                        secondArgv = UITableViewStyleGrouped;
                    }
                }
                
                // call super
                UITableView *(*originSelectorIMP)(id, SEL, CGRect, UITableViewStyle);
                originSelectorIMP = (UITableView * (*)(id, SEL, CGRect, UITableViewStyle))originalIMPProvider();
                UITableView *result = originSelectorIMP(selfObject, originCMD, firstArgv, secondArgv);
                
                // iOS 11 之后 estimatedRowHeight 如果值为 UITableViewAutomaticDimension，estimate 效果也会生效（iOS 11 以前要 > 0 才会生效）。
                // 而当使用 estimate 效果时，会导致 contentSize 之类的计算不准确，所以这里给一个途径让项目可以方便地控制 UITableView（不包含子类，例如 UIPickerTableView）的 estimatedRowHeight 效果的开关，至于 QMUITableView 会在自己内部 init 时调用
                // https://github.com/Tencent/QMUI_iOS/issues/313
                if (QMUICMIActivated && [NSStringFromClass(selfObject.class) isEqualToString:@"UITableView"]) {
                    [selfObject _qmui_configEstimatedRowHeight];
                }
                
                return result;
            };
        });
        
        OverrideImplementation([UITableView class], @selector(sizeThatFits:), ^id(__unsafe_unretained Class originClass, SEL originCMD, IMP (^originalIMPProvider)(void)) {
            return ^CGSize(UITableView *selfObject, CGSize size) {
                [selfObject alertEstimatedHeightUsageIfDetected];
                
                // call super
                CGSize (*originSelectorIMP)(id, SEL, CGSize);
                originSelectorIMP = (CGSize (*)(id, SEL, CGSize))originalIMPProvider();
                CGSize result = originSelectorIMP(selfObject, originCMD, size);
                
                return result;
            };
        });
        
        OverrideImplementation([UITableView class], @selector(scrollToRowAtIndexPath:atScrollPosition:animated:), ^id(__unsafe_unretained Class originClass, SEL originCMD, IMP (^originalIMPProvider)(void)) {
            return ^(UITableView *selfObject, NSIndexPath *indexPath, UITableViewScrollPosition scrollPosition, BOOL animated) {
                
                if (!indexPath) {
                    return;
                }
                
                BOOL isIndexPathLegal = YES;
                NSInteger numberOfSections = [selfObject numberOfSections];
                if (indexPath.section < 0 || indexPath.section >= numberOfSections) {
                    isIndexPathLegal = NO;
                } else if (indexPath.row != NSNotFound) {
                    NSInteger rows = [selfObject numberOfRowsInSection:indexPath.section];
                    isIndexPathLegal = indexPath.row >= 0 && indexPath.row < rows;
                }
                if (!isIndexPathLegal) {
                    QMUIAssert(NO, @"UITableView (QMUI)", @"%@ - target indexPath : %@ ，不合法的indexPath。\n%@", selfObject, indexPath, [NSThread callStackSymbols]);
                    return;
                }
                
                // call super
                void (*originSelectorIMP)(id, SEL, NSIndexPath *, UITableViewScrollPosition, BOOL);
                originSelectorIMP = (void (*)(id, SEL, NSIndexPath *, UITableViewScrollPosition, BOOL))originalIMPProvider();
                originSelectorIMP(selfObject, originCMD, indexPath, scrollPosition, animated);
            };
        });
        
        // [UIKit Bug] 将 UISearchBar 作为 tableHeaderView 使用的 UITableView，如果同时设置了 estimatedRowHeight，则 contentSize 会错乱，导致滚动异常
        // https://github.com/Tencent/QMUI_iOS/issues/1161
        void (^fixBugOfTableViewContentSize)(UITableView *) = ^void(UITableView *tableView) {
            BOOL estimatesRowHeight = NO;
            [tableView qmui_performSelector:NSSelectorFromString(@"_estimatesRowHeights") withPrimitiveReturnValue:&estimatesRowHeight];
            if (estimatesRowHeight && [tableView.tableHeaderView isKindOfClass:UISearchBar.class]) {
                BeginIgnorePerformSelectorLeaksWarning
                [tableView performSelector:NSSelectorFromString(@"_updateContentSize")];
                EndIgnorePerformSelectorLeaksWarning
            }
        };
        
        /* - (void)_coalesceContentSizeUpdateWithDelta:(double)arg1; */
        OverrideImplementation([UITableView class], NSSelectorFromString(@"_coalesceContentSizeUpdateWithDelta:"), ^id(__unsafe_unretained Class originClass, SEL originCMD, IMP (^originalIMPProvider)(void)) {
            return ^(UITableView *selfObject, CGFloat firstArgv) {
                
                // call super
                void (*originSelectorIMP)(id, SEL, CGFloat);
                originSelectorIMP = (void (*)(id, SEL, CGFloat))originalIMPProvider();
                originSelectorIMP(selfObject, originCMD, firstArgv);
                
                if (fixBugOfTableViewContentSize) {
                    fixBugOfTableViewContentSize(selfObject);
                }
            };
        });
        
        OverrideImplementation([UITableView class], @selector(reloadData), ^id(__unsafe_unretained Class originClass, SEL originCMD, IMP (^originalIMPProvider)(void)) {
            return ^(UITableView *selfObject) {
                
                // [UIKit Bug] iOS 11 及以上，关闭 estimated height 的 tableView 可能出现数据错乱引发 crash
                // https://github.com/Tencent/QMUI_iOS/issues/1243
                if (![selfObject qmui_getBoundBOOLForKey:@"kHasCalledReloadDataOnce"] && [selfObject.dataSource respondsToSelector:@selector(numberOfSectionsInTableView:)]) {
                    NSInteger a = [selfObject.dataSource numberOfSectionsInTableView:selfObject];
                    NSInteger b = [selfObject numberOfSections];
                    if (a == 0 && b == 1) {
                        // - [UITableView noteNumberOfRowsChanged]
                        SEL selector = NSSelectorFromString([NSString qmui_stringByConcat:@"note", @"NumberOfRows", @"Changed", nil]);
                        if ([selfObject respondsToSelector:selector]) {
                            BeginIgnorePerformSelectorLeaksWarning
                            [selfObject performSelector:selector];
                            EndIgnorePerformSelectorLeaksWarning
                        }
                    }
                }
                
                // call super
                void (*originSelectorIMP)(id, SEL);
                originSelectorIMP = (void (*)(id, SEL))originalIMPProvider();
                originSelectorIMP(selfObject, originCMD);
                
                // 记录是否执行过一次 reloadData，目的是只对第一次 reloadData 做检查
                [selfObject qmui_bindBOOL:YES forKey:@"kHasCalledReloadDataOnce"];
                
                // [UIKit Bug] 将 UISearchBar 作为 tableHeaderView 使用的 UITableView，在 tableView 尚未添加到 window 上就同时进行了 setTableHeaderView:、reloadData 的操作，会导致滚动异常
                // https://github.com/Tencent/QMUI_iOS/issues/1215
                // 简单用“存在 superview 却不存在 window”的方式来区分该 UITableView 是 UIViewController 里的还是 UITableViewController 里的
                if (!selfObject.window && selfObject.superview && [selfObject.tableHeaderView isKindOfClass:UISearchBar.class]) {
                    [selfObject qmui_bindBOOL:YES forKey:@"kShouldFixContentSizeBugKey"];
                }
            };
        });
        OverrideImplementation([UITableView class], @selector(didMoveToWindow), ^id(__unsafe_unretained Class originClass, SEL originCMD, IMP (^originalIMPProvider)(void)) {
            return ^(UITableView *selfObject) {
                
                // call super
                void (*originSelectorIMP)(id, SEL);
                originSelectorIMP = (void (*)(id, SEL))originalIMPProvider();
                originSelectorIMP(selfObject, originCMD);
                
                if ([selfObject qmui_getBoundBOOLForKey:@"kShouldFixContentSizeBugKey"]) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [selfObject reloadData];
                    });
                    [selfObject qmui_bindBOOL:NO forKey:@"kShouldFixContentSizeBugKey"];
                }
            };
        });
        
        // [UIKit Bug] UISearchBar 作为 tableHeaderView 使用时，切换 tableView 的 sectionIndex 的显隐，searchBar 的布局可能无法刷新
        // https://github.com/Tencent/QMUI_iOS/issues/1213
        OverrideImplementation([UITableView class], NSSelectorFromString(@"_removeIndex"), ^id(__unsafe_unretained Class originClass, SEL originCMD, IMP (^originalIMPProvider)(void)) {
            return ^(UITableView *selfObject) {
                
                // call super
                void (*originSelectorIMP)(id, SEL);
                originSelectorIMP = (void (*)(id, SEL))originalIMPProvider();
                originSelectorIMP(selfObject, originCMD);
                
                UISearchBar *searchBar = (UISearchBar *)selfObject.tableHeaderView;
                if ([searchBar isKindOfClass:UISearchBar.class]) {
                    // UISearchBar 内部通过这个私有方法来根据 UITableView 的状态刷新自身的 inset，这里手动调用一次
                    [searchBar qmui_performSelector:NSSelectorFromString(@"_updateInsetsForTableView:") withArguments:&selfObject, nil];
                }
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
        QMUIAssert(NO, @"UITableView (QMUI)", @"%@ - target indexPath : %@ ，不合法的indexPath。\n%@", self, indexPath, [NSThread callStackSymbols]);
    } else {
        [self qmui_scrollToRowAtIndexPath:indexPath atScrollPosition:scrollPosition animated:animated];
    }
}

- (void)qmui_styledAsQMUITableView {
    
    if (!QMUICMIActivated) return;
    
    [self _qmui_configEstimatedRowHeight];
    
    self.backgroundColor = PreferredValueForTableViewStyle(self.qmui_style, TableViewBackgroundColor, TableViewGroupedBackgroundColor, TableViewInsetGroupedBackgroundColor);
    self.separatorColor = PreferredValueForTableViewStyle(self.qmui_style, TableViewSeparatorColor, TableViewGroupedSeparatorColor, TableViewInsetGroupedSeparatorColor);

    
    // 去掉空白的cell
    if (self.qmui_style == UITableViewStylePlain) {
        self.tableFooterView = [[UIView alloc] init];
    }
    
    self.backgroundView = [[UIView alloc] init]; // 设置一个空的 backgroundView，去掉系统自带的，以使 backgroundColor 生效（系统在 tableHeaderView 为 UISearchBar 时会自动设置一层背景灰色，导致背景色看不到。只有使用了自定义 backgroundView 才能屏蔽系统这个行为）
    
    self.sectionIndexColor = TableSectionIndexColor;
    self.sectionIndexTrackingBackgroundColor = TableSectionIndexTrackingBackgroundColor;
    self.sectionIndexBackgroundColor = TableSectionIndexBackgroundColor;
#ifdef IOS15_SDK_ALLOWED
    if (@available(iOS 15.0, *)) {
        self.sectionHeaderTopPadding = PreferredValueForTableViewStyle(self.qmui_style, TableViewSectionHeaderTopPadding, TableViewGroupedSectionHeaderTopPadding, TableViewInsetGroupedSectionHeaderTopPadding);
    }
#endif
    
    self.qmui_insetGroupedCornerRadius = TableViewInsetGroupedCornerRadius;
    self.qmui_insetGroupedHorizontalInset = TableViewInsetGroupedHorizontalInset;
}

- (void)_qmui_configEstimatedRowHeight {
    if (TableViewEstimatedHeightEnabled) {
        self.estimatedRowHeight = TableViewCellNormalHeight;
        self.rowHeight = UITableViewAutomaticDimension;
        
        self.estimatedSectionHeaderHeight = UITableViewAutomaticDimension;
        self.sectionHeaderHeight = UITableViewAutomaticDimension;
        
        self.estimatedSectionFooterHeight = UITableViewAutomaticDimension;
        self.sectionFooterHeight = UITableViewAutomaticDimension;
    } else {
        self.estimatedRowHeight = 0;
        self.rowHeight = TableViewCellNormalHeight;
        
        self.estimatedSectionHeaderHeight = 0;
        self.sectionHeaderHeight = UITableViewAutomaticDimension;
        
        self.estimatedSectionFooterHeight = 0;
        self.sectionFooterHeight = UITableViewAutomaticDimension;
    }
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
    
    NSInteger low = 0;
    NSInteger high = [self numberOfSections];
    while (low <= high) {
        NSInteger mid = low + ((high-low) >> 1);
        CGRect rectForSection = [self rectForSection:mid];
        rectForSection = CGRectToFixed(rectForSection, kFloatValuePrecision);
        if (CGRectContainsPoint(rectForSection, origin)) {
            UITableViewHeaderFooterView *headerView = [self headerViewForSection:mid];
            if (headerView && [view isDescendantOfView:headerView]) {
                return mid;
            } else {
                return -1;
            }
        } else if (rectForSection.origin.y < origin.y) {
            low = mid + 1;
        } else {
            high = mid - 1;
        }
    }
    return -1;
}

- (NSArray<NSNumber *> *)qmui_indexForVisibleSectionHeaders {
    // iOS 14 及以前的版本，只要某个 section 的 header 露出来了，该 section 里的第一个 cell 必定会出现在 visibleRows 内，但 iOS 15 必须是真的显示了 cell 才会出现在 visibleRows 里
    // 这里针对 iOS 15 做个保护：如果最后一个可视 cell 刚好是该 section 的最后一个 cell，则检测范围再扩大到下一个 section，避免遗漏
    NSMutableArray<NSNumber *> *result = NSMutableArray.new;
    NSInteger sections = self.numberOfSections;
    for (NSInteger section = 0; section < sections; section++) {
        if ([self qmui_isHeaderVisibleForSection:section]) {
            [result addObject:@(section)];
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
    if (self.qmui_style != UITableViewStylePlain) return NO;
    if (section >= [self numberOfSections]) return NO;
    
    // 系统这两个接口获取到的 rect 是在 contentSize 里的 rect，而不是实际看到的 rect
    CGRect rectForSection = [self rectForSection:section];
    CGRect rectForHeader = [self rectForHeaderInSection:section];
    BOOL isSectionScrollIntoContentInsetTop = self.contentOffset.y + self.adjustedContentInset.top > CGRectGetMinY(rectForHeader);// 表示这个 section 已经往上滚动，超过 contentInset.top 那条线了
    BOOL isSectionStayInContentInsetTop = self.contentOffset.y + self.adjustedContentInset.top <= CGRectGetMaxY(rectForSection) - CGRectGetHeight(rectForHeader);// 表示这个 section 还没被完全滚走
    BOOL isPinned = isSectionScrollIntoContentInsetTop && isSectionStayInContentInsetTop;
    return isPinned;
}

- (BOOL)qmui_isHeaderVisibleForSection:(NSInteger)section {
    if (section >= [self numberOfSections]) return NO;
    
    // 不存在 header 就不用判断
    CGRect rectForSectionHeader = [self rectForHeaderInSection:section];
    if (CGRectGetHeight(rectForSectionHeader) <= 0) return NO;
    
    // 系统这个接口获取到的 rect 是在 contentSize 里的 rect，而不是实际看到的 rect
    CGRect rectForSection = CGRectZero;
    if (self.qmui_style == UITableViewStylePlain) {
        rectForSection = [self rectForSection:section];
    } else {
        rectForSection = [self rectForHeaderInSection:section];
    }
    CGRect visibleRect = CGRectMake(self.contentOffset.x + self.adjustedContentInset.left, self.contentOffset.y + self.adjustedContentInset.top, CGRectGetWidth(self.bounds) - UIEdgeInsetsGetHorizontalValue(self.adjustedContentInset), CGRectGetHeight(self.bounds) - UIEdgeInsetsGetVerticalValue(self.adjustedContentInset));
    if (CGRectIntersectsRect(visibleRect, rectForSection)) {
        return YES;
    }
    return NO;
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

- (CGFloat)qmui_validContentWidth {
    CGRect indexFrame = self.qmui_indexFrame;
    CGFloat rightInset = MAX(self.safeAreaInsets.right + (self.qmui_style == QMUITableViewStyleInsetGrouped ? self.qmui_insetGroupedHorizontalInset : 0), CGRectGetWidth(indexFrame));
    CGFloat leftInset = self.safeAreaInsets.left + (self.qmui_style == QMUITableViewStyleInsetGrouped ? self.qmui_insetGroupedHorizontalInset : 0);
    CGFloat width = CGRectGetWidth(self.bounds) - leftInset - rightInset;
    return width;
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
        BOOL canScroll = self.qmui_realContentSize.height + UIEdgeInsetsGetVerticalValue(self.adjustedContentInset) > CGRectGetHeight(self.bounds);
        return canScroll;
    } else {
        return [super qmui_canScroll];
    }
}

- (void)alertEstimatedHeightUsageIfDetected {
    BOOL usingEstimatedRowHeight = [self.delegate respondsToSelector:@selector(tableView:estimatedHeightForRowAtIndexPath:)] || self.estimatedRowHeight > 0;
    BOOL usingEstimatedSectionHeaderHeight = [self.delegate respondsToSelector:@selector(tableView:estimatedHeightForHeaderInSection:)] || self.estimatedSectionHeaderHeight > 0;
    BOOL usingEstimatedSectionFooterHeight = [self.delegate respondsToSelector:@selector(tableView:estimatedHeightForFooterInSection:)] || self.estimatedSectionFooterHeight > 0;
    
    if (usingEstimatedRowHeight || usingEstimatedSectionHeaderHeight || usingEstimatedSectionFooterHeight) {
        [self QMUISymbolicUsingTableViewEstimatedHeightMakeWarning];
    }
}

- (void)QMUISymbolicUsingTableViewEstimatedHeightMakeWarning {
    QMUILog(@"UITableView (QMUI)", @"当开启了 UITableView 的 estimatedRow(SectionHeader / SectionFooter)Height 功能后，不应该手动修改 contentOffset 和 contentSize，也会影响 contentSize、sizeThatFits:、rectForXxx 等方法的计算，请注意确认当前是否存在不合理的业务代码。可添加 '%@' 的 Symbolic Breakpoint 以捕捉此类信息\n%@", NSStringFromSelector(_cmd), [NSThread callStackSymbols]);
}

- (void)qmui_performBatchUpdates:(void (NS_NOESCAPE ^ _Nullable)(void))updates completion:(void (^ _Nullable)(BOOL finished))completion {
    [self performBatchUpdates:updates completion:completion];
}

- (CGRect)qmui_indexFrame {
    CGRect indexFrame = CGRectZero;
    [self qmui_performSelector:NSSelectorFromString(@"indexFrame") withPrimitiveReturnValue:&indexFrame];
    return indexFrame;
}

@end

@interface UITableViewCell (QMUI_Private)

@property(nonatomic, assign, readwrite) QMUITableViewCellPosition qmui_cellPosition;
@end

const UITableViewStyle QMUITableViewStyleInsetGrouped = UITableViewStyleGrouped + 1;

@implementation UITableView (QMUI_InsetGrouped)

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        // -[UITableViewDelegate tableView:willDisplayCell:forRowAtIndexPath:] 比这个还晚，所以不用担心触发 delegate
        OverrideImplementation([UITableView class], NSSelectorFromString(@"_configureCellForDisplay:forIndexPath:"), ^id(__unsafe_unretained Class originClass, SEL originCMD, IMP (^originalIMPProvider)(void)) {
            return ^(UITableView *selfObject, UITableViewCell *cell, NSIndexPath *indexPath) {
                
                // call super
                void (*originSelectorIMP)(id, SEL, UITableViewCell *, NSIndexPath *);
                originSelectorIMP = (void (*)(id, SEL, UITableViewCell *, NSIndexPath *))originalIMPProvider();
                originSelectorIMP(selfObject, originCMD, cell, indexPath);
                
                // UITableViewCell(QMUI) 内会根据 cellPosition 调整 separator 的布局，所以先在这里赋值以供那边使用
                QMUITableViewCellPosition position = [selfObject qmui_positionForRowAtIndexPath:indexPath];
                cell.qmui_cellPosition = position;
                
                if (selfObject.qmui_style == QMUITableViewStyleInsetGrouped) {
                    CGFloat cornerRadius = selfObject.qmui_insetGroupedCornerRadius;
                    if (position == QMUITableViewCellPositionMiddleInSection || position == QMUITableViewCellPositionNone) {
                        cornerRadius = 0;
                    }
                    // InsetGrouped 的圆角，iOS 13 系统有另外的私有方法去设置，所以这里在 qmui_cellPosition 的值更新时设置一次，下方在 _setContentClipCorners:updateCorners: 时再覆盖一次。iOS 12 只需要在这里处理一次即可
                    if (@available(iOS 13.0, *)) {
                    } else {
                        CACornerMask mask = kCALayerMinXMinYCorner|kCALayerMaxXMinYCorner|kCALayerMinXMaxYCorner|kCALayerMaxXMaxYCorner;
                        switch (position) {
                            case QMUITableViewCellPositionFirstInSection:
                                mask = kCALayerMinXMinYCorner|kCALayerMaxXMinYCorner;
                                break;
                            case QMUITableViewCellPositionLastInSection:
                                mask = kCALayerMinXMaxYCorner|kCALayerMaxXMaxYCorner;
                                break;
                            default:
                                break;
                        }
                        cell.layer.maskedCorners = mask;
                        cell.layer.masksToBounds = YES;
                    }
                    cell.layer.cornerRadius = cornerRadius;
                }
                
                if (cell.qmui_configureStyleBlock) {
                    cell.qmui_configureStyleBlock(selfObject, cell, indexPath);
                }
            };
        });
        
        if (@available(iOS 13.0, *)) {
            
            // -[UITableViewCell _setContentClipCorners:updateCorners:]，用来控制系统 InsetGrouped 的圆角（很多情况都会触发系统更新圆角，例如设置 cell.backgroundColor、...，对于 iOS 12 及以下的系统，则靠 -[UITableView _configureCellForDisplay:forIndexPath:] 来处理
            // - (void) _setContentClipCorners:(unsigned long)arg1 updateCorners:(BOOL)arg2; (0x10db0a5b7)
            OverrideImplementation([UITableViewCell class], NSSelectorFromString([NSString qmui_stringByConcat:@"_setContentClipCorners", @":", @"updateCorners", @":", nil]), ^id(__unsafe_unretained Class originClass, SEL originCMD, IMP (^originalIMPProvider)(void)) {
                return ^(UITableViewCell *selfObject, CACornerMask firstArgv, BOOL secondArgv) {
                    
                    // call super
                    void (*originSelectorIMP)(id, SEL, CACornerMask, BOOL);
                    originSelectorIMP = (void (*)(id, SEL, CACornerMask, BOOL))originalIMPProvider();
                    originSelectorIMP(selfObject, originCMD, firstArgv, secondArgv);
                    
                    UITableView *tableView = selfObject.qmui_tableView;
                    if (tableView && tableView.qmui_style == QMUITableViewStyleInsetGrouped) {
                        CGFloat cornerRadius = tableView.qmui_insetGroupedCornerRadius;
                        if (selfObject.qmui_cellPosition == QMUITableViewCellPositionMiddleInSection || selfObject.qmui_cellPosition == QMUITableViewCellPositionNone) {
                            cornerRadius = 0;
                        }
                        selfObject.layer.cornerRadius = cornerRadius;
                    }
                };
            });
            
            
            // -[UITableView layoutMargins]，用来控制系统 InsetGrouped 的左右间距
            OverrideImplementation([UITableView class], @selector(layoutMargins), ^id(__unsafe_unretained Class originClass, SEL originCMD, IMP (^originalIMPProvider)(void)) {
                return ^UIEdgeInsets(UITableView *selfObject) {
                    // call super
                    UIEdgeInsets (*originSelectorIMP)(id, SEL);
                    originSelectorIMP = (UIEdgeInsets (*)(id, SEL))originalIMPProvider();
                    UIEdgeInsets result = originSelectorIMP(selfObject, originCMD);
                    
                    if (selfObject.qmui_style == QMUITableViewStyleInsetGrouped) {
                        result.left = selfObject.safeAreaInsets.left + selfObject.qmui_insetGroupedHorizontalInset;
                        result.right = selfObject.safeAreaInsets.right + selfObject.qmui_insetGroupedHorizontalInset;
                    }
                    
                    return result;
                };
            });
        }
    });
}

static char kAssociatedObjectKey_style;
- (void)setQmui_style:(UITableViewStyle)qmui_style {
    if (@available(iOS 13.0, *)) {
    } else {
        objc_setAssociatedObject(self, &kAssociatedObjectKey_style, @(qmui_style), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
}

- (UITableViewStyle)qmui_style {
    if (@available(iOS 13.0, *)) {
        return self.style;
    }
    return [((NSNumber *)objc_getAssociatedObject(self, &kAssociatedObjectKey_style)) integerValue];
}

static char kAssociatedObjectKey_insetGroupedCornerRadius;
- (void)setQmui_insetGroupedCornerRadius:(CGFloat)qmui_insetGroupedCornerRadius {
    objc_setAssociatedObject(self, &kAssociatedObjectKey_insetGroupedCornerRadius, @(qmui_insetGroupedCornerRadius), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    if (self.qmui_style == QMUITableViewStyleInsetGrouped && self.indexPathsForVisibleRows.count) {
        [self reloadData];
    }
}

- (CGFloat)qmui_insetGroupedCornerRadius {
    NSNumber *associatedValue = (NSNumber *)objc_getAssociatedObject(self, &kAssociatedObjectKey_insetGroupedCornerRadius);
    if (!associatedValue) {
        // 从来没设置过（包括业务主动设置或者通过 UIAppearance 方式设置），则用 iOS 13 系统默认值
        // 不在 UITableView init 时设置是因为那样会使 UIAppearance 失效
        return 10;
    }
    return associatedValue.qmui_CGFloatValue;
}

static char kAssociatedObjectKey_insetGroupedHorizontalInset;
- (void)setQmui_insetGroupedHorizontalInset:(CGFloat)qmui_insetGroupedHorizontalInset {
    objc_setAssociatedObject(self, &kAssociatedObjectKey_insetGroupedHorizontalInset, @(qmui_insetGroupedHorizontalInset), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    if (self.qmui_style == QMUITableViewStyleInsetGrouped && self.indexPathsForVisibleRows.count) {
        [self reloadData];
    }
}

- (CGFloat)qmui_insetGroupedHorizontalInset {
    NSNumber *associatedValue = (NSNumber *)objc_getAssociatedObject(self, &kAssociatedObjectKey_insetGroupedHorizontalInset);
    if (!associatedValue) {
        // 从来没设置过（包括业务主动设置或者通过 UIAppearance 方式设置），则用 iOS 13 系统默认值
        // 不在 UITableView init 时设置是因为那样会使 UIAppearance 失效
        return PreferredValueForVisualDevice(20, 15);
    }
    return associatedValue.qmui_CGFloatValue;
}

@end
