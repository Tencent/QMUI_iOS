/**
 * Tencent is pleased to support the open source community by making QMUI_iOS available.
 * Copyright (C) 2016-2021 THL A29 Limited, a Tencent company. All rights reserved.
 * Licensed under the MIT License (the "License"); you may not use this file except in compliance with the License. You may obtain a copy of the License at
 * http://opensource.org/licenses/MIT
 * Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.
 */
//
//  QMUIConsoleViewController.m
//  QMUIKit
//
//  Created by MoLice on 2019/J/11.
//

#import "QMUIConsoleViewController.h"
#import "QMUICore.h"
#import "QMUITableView.h"
#import "QMUITableViewCell.h"
#import "UITableView+QMUICellHeightKeyCache.h"
#import "QMUITextView.h"
#import "QMUITextField.h"
#import "QMUIButton.h"
#import "UIScrollView+QMUI.h"
#import "UIViewController+QMUI.h"
#import "UIView+QMUI.h"
#import "UIImage+QMUI.h"
#import "NSObject+QMUI.h"
#import "CAAnimation+QMUI.h"
#import "NSArray+QMUI.h"
#import "QMUIConsole.h"
#import "QMUIPopupMenuView.h"

@interface QMUIConsoleLogItem : NSObject

@property(nullable, nonatomic, copy) NSString *level;
@property(nullable, nonatomic, copy) NSString *name;
@property(nonatomic, copy) NSAttributedString *timeString;
@property(nonatomic, copy) NSAttributedString *logString;
@property(nonatomic, copy) NSAttributedString *displayString;

@property(nonatomic, copy) NSString *searchingString;
@property(nonatomic, copy) NSArray<NSTextCheckingResult *> *searchResults;
- (void)updateDisplayStringWithSearchResults:(NSArray<NSTextCheckingResult *> *)searchResults;
- (void)focusSearchResultAtIndex:(NSInteger)index;
@end

@implementation QMUIConsoleLogItem

+ (instancetype)logItemWithLevel:(NSString *)level name:(NSString *)name timeString:(NSString *)timeString logString:(id)logString {
    QMUIConsoleLogItem *logItem = [[self alloc] init];
    logItem.level = level ?: @"Normal";
    logItem.name = name ?: @"Default";
    
    NSDictionary<NSAttributedStringKey, id> *timeAttributes = [QMUIConsole appearance].timeAttributes;
    logItem.timeString = [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@ ", timeString] attributes:timeAttributes];
    
    NSDictionary<NSAttributedStringKey, id> *textAttributes = [QMUIConsole appearance].textAttributes;
    NSAttributedString *string = nil;
    if ([logString isKindOfClass:[NSAttributedString class]]) {
        string = (NSAttributedString *)logString;
    } else if ([logString isKindOfClass:[NSString class]]) {
        string = [[NSAttributedString alloc] initWithString:(NSString *)logString attributes:textAttributes];
    } else {
        string = [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@", logString] attributes:textAttributes];
    }
    logItem.logString = string;
    
    NSMutableAttributedString *displayString = NSMutableAttributedString.new;
    [displayString appendAttributedString:logItem.timeString];
    [displayString appendAttributedString:logItem.logString];
    logItem.displayString = displayString;
    return logItem;
}

- (void)updateDisplayStringWithSearchResults:(NSArray<NSTextCheckingResult *> *)searchResults {
    self.searchResults = searchResults;
    NSMutableAttributedString *displayString = self.displayString.mutableCopy;
    [displayString removeAttribute:NSBackgroundColorAttributeName range:NSMakeRange(0, displayString.length)];
    [searchResults enumerateObjectsUsingBlock:^(NSTextCheckingResult * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [displayString addAttribute:NSBackgroundColorAttributeName value:[[QMUIConsole appearance].searchResultHighlightedBackgroundColor colorWithAlphaComponent:.4] range:NSMakeRange(self.timeString.length + obj.range.location, obj.range.length)];
    }];
    self.displayString = displayString.copy;
}

- (void)focusSearchResultAtIndex:(NSInteger)index {
    NSAssert(index < self.searchResults.count, @"尝试聚焦一个超出 searchResults 范围的关键词");
    [self updateDisplayStringWithSearchResults:self.searchResults];// 重置之前的 focus range
    NSRange rangeInLogString = self.searchResults[index].range;
    NSRange range = NSMakeRange(self.timeString.length + rangeInLogString.location, rangeInLogString.length);
    NSMutableAttributedString *displayString = self.displayString.mutableCopy;
    [displayString addAttribute:NSBackgroundColorAttributeName value:[QMUIConsole appearance].searchResultHighlightedBackgroundColor range:range];
    self.displayString = displayString.copy;
}

@end

@interface QMUIConsoleLogItemCell : QMUITableViewCell

@property(nonatomic, strong) QMUITextView *textView;
@end

@implementation QMUIConsoleLogItemCell

- (void)didInitializeWithStyle:(UITableViewCellStyle)style {
    [super didInitializeWithStyle:style];
    self.backgroundColor = nil;
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    
    self.textView = [[QMUITextView alloc] init];
    self.textView.textContainerInset = UIEdgeInsetsMake(2, 0, 2, 0);
    self.textView.backgroundColor = [UIColor clearColor];
    self.textView.scrollsToTop = NO;
    self.textView.editable = NO;
    if (@available(iOS 11, *)) {
        self.textView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    }
    [self.contentView addSubview:self.textView];
}

- (CGSize)sizeThatFits:(CGSize)size {
    return [self.textView sizeThatFits:CGSizeMake(size.width, CGFLOAT_MAX)];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    self.textView.frame = self.contentView.bounds;
}

@end

@interface QMUIConsoleViewController ()<QMUITableViewDataSource, QMUITableViewDelegate, QMUITextFieldDelegate>

@property(nonatomic, strong) UIView *containerView;
@property(nonatomic, strong) QMUIPopupMenuView *levelMenu;
@property(nonatomic, strong) QMUIPopupMenuView *nameMenu;
@property(nonatomic, strong) NSMutableArray<QMUIConsoleLogItem *> *logItems;
@property(nonatomic, strong) NSArray<QMUIConsoleLogItem *> *showingLogItems;
@property(nonatomic, strong) NSMutableArray<NSString *> *selectedLevels;
@property(nonatomic, strong) NSMutableArray<NSString *> *selectedNames;
@property(nonatomic, strong) NSRegularExpression *searchRegularExpression;
@property(nonatomic, assign) NSInteger searchResultsTotalCount;
@property(nonatomic, assign) NSInteger currentHighlightedResultIndex;
@property(nonatomic, weak) QMUIConsoleLogItem *lastHighlightedItem;

@property(nonatomic, strong) UIPanGestureRecognizer *popoverPanGesture;
@property(nonatomic, strong) UILongPressGestureRecognizer *popoverLongPressGesture;
@property(nonatomic, assign) BOOL popoverAnimating;
@end

@implementation QMUIConsoleViewController

- (void)didInitialize {
    [super didInitialize];
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.backgroundColor = [QMUIConsole appearance].backgroundColor;
    
    _dateFormatter = [[NSDateFormatter alloc] init];
    self.dateFormatter.dateFormat = @"HH:mm:ss.SSS";
    
    self.logItems = [[NSMutableArray alloc] init];
    self.selectedLevels = [[NSMutableArray alloc] init];
    self.selectedNames = [[NSMutableArray alloc] init];
}

- (UIView *)containerView {
    if (!_containerView) {
        _containerView = [[UIView alloc] init];
        _containerView.backgroundColor = self.backgroundColor;
        _containerView.hidden = YES;
    }
    return _containerView;
}

@synthesize tableView = _tableView;
- (QMUITableView *)tableView {
    if (!_tableView) {
        _tableView = [[QMUITableView alloc] init];
        _tableView.dataSource = self;
        _tableView.delegate = self;
        _tableView.estimatedRowHeight = 44;
        _tableView.rowHeight = UITableViewAutomaticDimension;
        _tableView.qmui_cacheCellHeightByKeyAutomatically = YES;
        _tableView.backgroundColor = nil;
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _tableView.scrollsToTop = NO;
        [_tableView registerClass:QMUIConsoleLogItemCell.class forCellReuseIdentifier:@"cell"];
        if (@available(iOS 11, *)) {
            _tableView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
        }
    }
    return _tableView;
}

@synthesize toolbar = _toolbar;
- (QMUIConsoleToolbar *)toolbar {
    if (!_toolbar) {
        _toolbar = [[QMUIConsoleToolbar alloc] init];
        [_toolbar.levelButton addTarget:self action:@selector(handleLevelButtonEvent:) forControlEvents:UIControlEventTouchUpInside];
        [_toolbar.nameButton addTarget:self action:@selector(handleNameButtonEvent:) forControlEvents:UIControlEventTouchUpInside];
        [_toolbar.clearButton addTarget:self action:@selector(handleClearButtonEvent:) forControlEvents:UIControlEventTouchUpInside];
        __weak __typeof(self)weakSelf = self;
        _toolbar.searchTextField.qmui_keyboardWillChangeFrameNotificationBlock = ^(QMUIKeyboardUserInfo *keyboardUserInfo) {
            [weakSelf handleKeyboardWillChangeFrame:keyboardUserInfo];
        };
        _toolbar.searchTextField.delegate = self;
        [_toolbar.searchTextField addTarget:self action:@selector(handleSearchTextFieldChanged:) forControlEvents:UIControlEventEditingChanged];
        [_toolbar.searchResultPreviousButton addTarget:self action:@selector(handleSearchResultPreviousButtonEvent:) forControlEvents:UIControlEventTouchUpInside];
        [_toolbar.searchResultNextButton addTarget:self action:@selector(handleSearchResultNextButtonEvent:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _toolbar;
}

@synthesize popoverButton = _popoverButton;
- (QMUIButton *)popoverButton {
    if (!_popoverButton) {
        UIImage *popoverImage = [[QMUIHelper imageWithName:@"QMUI_console_logo"] qmui_imageResizedInLimitedSize:CGSizeMake(24, 24)];
        _popoverButton = [[QMUIButton alloc] qmui_initWithSize:CGSizeMake(32, 32)];
        [_popoverButton setImage:popoverImage forState:UIControlStateNormal];
        _popoverButton.adjustsButtonWhenHighlighted = NO;
        _popoverButton.backgroundColor = [[QMUIConsole appearance].backgroundColor colorWithAlphaComponent:.5];
        _popoverButton.layer.cornerRadius = CGRectGetHeight(_popoverButton.bounds) / 2;
        _popoverButton.clipsToBounds = YES;
        [_popoverButton addTarget:self action:@selector(handlePopoverTouchEvent:) forControlEvents:UIControlEventTouchUpInside];
        
        self.popoverLongPressGesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handlePopverLongPressGestureRecognizer:)];
        [_popoverButton addGestureRecognizer:self.popoverLongPressGesture];
        
        self.popoverPanGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePopoverPanGestureRecognizer:)];
        [self.popoverPanGesture requireGestureRecognizerToFail:self.popoverLongPressGesture];
        [_popoverButton addGestureRecognizer:self.popoverPanGesture];
    }
    return _popoverButton;
}

- (void)initSubviews {
    [super initSubviews];
    [self.view addSubview:self.containerView];
    [self.containerView addSubview:self.tableView];
    [self.containerView addSubview:self.toolbar];
    
    __weak __typeof(self)weakSelf = self;
    self.levelMenu = [self generatePopupMenuView];
    self.levelMenu.willHideBlock = ^(BOOL hidesByUserTap, BOOL animated) {
        weakSelf.toolbar.levelButton.selected = weakSelf.selectedLevels.count > 0;
    };
    self.levelMenu.sourceView = self.toolbar.levelButton;
    
    self.nameMenu = [self generatePopupMenuView];
    self.nameMenu.willHideBlock = ^(BOOL hidesByUserTap, BOOL animated) {
        weakSelf.toolbar.nameButton.selected = weakSelf.selectedNames.count > 0;
    };
    self.nameMenu.sourceView = self.toolbar.nameButton;
    
    [self updateToolbarButtonState];
    
    [self.view addSubview:self.popoverButton];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor clearColor];
    __weak __typeof(self)weakSelf = self;
    self.view.qmui_hitTestBlock = ^__kindof UIView * _Nonnull(CGPoint point, UIEvent * _Nonnull event, __kindof UIView * _Nonnull originalView) {
        
        QMUIPopupMenuView *menuView = weakSelf.levelMenu.isShowing ? weakSelf.levelMenu : (weakSelf.nameMenu.isShowing ? weakSelf.nameMenu : nil);
        if (menuView && ![originalView isDescendantOfView:menuView]) {
            [menuView hideWithAnimated:YES];
            return weakSelf.view;// 也即不再传递这次事件了，相当于无效点击
        }
        
        if (originalView == weakSelf.view) {
            if (weakSelf.toolbar.searchTextField.isFirstResponder) {
                [weakSelf.view endEditing:YES];
            }
            return nil;
        }
        return originalView;
    };
}

- (CGRect)safetyPopoverButtonFrame:(CGRect)popoverButtonFrame {
    CGRect safetyBounds = CGRectInsetEdges(self.view.bounds, self.view.qmui_safeAreaInsets);
    if (!CGRectContainsRect(safetyBounds, self.popoverButton.frame)) {
        popoverButtonFrame = CGRectSetX(popoverButtonFrame, MAX(self.view.qmui_safeAreaInsets.left, MIN(CGRectGetMaxX(safetyBounds) - CGRectGetWidth(popoverButtonFrame), CGRectGetMinX(popoverButtonFrame))));
        popoverButtonFrame = CGRectSetY(popoverButtonFrame, MAX(self.view.qmui_safeAreaInsets.top, MIN(CGRectGetMaxY(safetyBounds) - CGRectGetHeight(popoverButtonFrame), CGRectGetMinY(popoverButtonFrame))));
    }
    return popoverButtonFrame;
}

- (void)layoutPopoverButton {
    if (self.popoverPanGesture.enabled) {
        CGPoint popoverButtonOrigin;
        NSValue *bindObject = [self.popoverButton qmui_getBoundObjectForKey:@"origin"];
        if (bindObject) {
            popoverButtonOrigin = ((NSValue *)[self.popoverButton qmui_getBoundObjectForKey:@"origin"]).CGPointValue;
        } else {
            popoverButtonOrigin = CGPointMake(16 + self.view.qmui_safeAreaInsets.left, CGRectGetHeight(self.view.bounds) * 3.0 / 4.0);
        }
        self.popoverButton.qmui_frameApplyTransform = [self safetyPopoverButtonFrame:CGRectSetXY(self.popoverButton.frame, popoverButtonOrigin.x, popoverButtonOrigin.y)];
    } else {
        self.popoverButton.qmui_frameApplyTransform = CGRectSetXY(self.popoverButton.frame, CGRectGetMaxX(self.containerView.frame) - 10 - CGRectGetWidth(self.popoverButton.bounds), CGRectGetMinY(self.containerView.frame) + 10);
    }
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    
    if (self.popoverAnimating) return;
    
    [self layoutPopoverButton];
    
    CGSize containerViewSize = CGSizeMake(CGRectGetWidth(self.view.bounds), MAX(100, CGRectGetHeight(self.view.bounds) / 3));
    self.containerView.qmui_frameApplyTransform = CGRectMake(0, CGRectGetHeight(self.view.bounds) - containerViewSize.height, containerViewSize.width, containerViewSize.height);
    
    CGFloat toolbarHeight = 44 + self.containerView.qmui_safeAreaInsets.bottom;
    self.toolbar.qmui_height = toolbarHeight;
    self.toolbar.qmui_width = self.containerView.qmui_width;
    self.toolbar.qmui_bottom = self.containerView.qmui_height;
    
    self.tableView.qmui_width = self.containerView.qmui_width;
    self.tableView.qmui_height = self.toolbar.qmui_top;
    self.tableView.contentInset = UIEdgeInsetsMake(self.tableView.qmui_safeAreaInsets.top, self.tableView.qmui_safeAreaInsets.left, self.tableView.contentInset.bottom, self.tableView.qmui_safeAreaInsets.right);
    self.tableView.scrollIndicatorInsets = self.tableView.contentInset;
    
    [@[self.levelMenu, self.nameMenu] enumerateObjectsUsingBlock:^(QMUIPopupMenuView *menuView, NSUInteger idx, BOOL * _Nonnull stop) {
        menuView.safetyMarginsOfSuperview = UIEdgeInsetsConcat(UIEdgeInsetsMake(2, 2, 2, 2), self.view.qmui_safeAreaInsets);
    }];
}

- (BOOL)shouldAutorotate {
    return [QMUIHelper visibleViewController].shouldAutorotate;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return [QMUIHelper visibleViewController].supportedInterfaceOrientations;
}

- (void)setBackgroundColor:(UIColor *)backgroundColor {
    _backgroundColor = backgroundColor;
    if (self.isViewLoaded) {
        self.containerView.backgroundColor = backgroundColor;
    }
}

- (void)logWithLevel:(NSString *)level name:(NSString *)name logString:(id)logString {
    QMUIConsoleLogItem *logItem = [QMUIConsoleLogItem logItemWithLevel:level name:name timeString:[self.dateFormatter stringFromDate:[NSDate new]] logString:logString];
    [self searchInLogItem:logItem];
    [self.logItems addObject:logItem];
    dispatch_async(dispatch_get_main_queue(), ^{// 避免频繁打 log 时卡顿
        [self printLog];
    });
}

- (void)log:(id)logString {
    [self logWithLevel:nil name:nil logString:logString];
}

- (void)printLog {
    self.showingLogItems = [self.logItems qmui_filterWithBlock:^BOOL(QMUIConsoleLogItem * _Nonnull logItem) {
        BOOL shouldPrintLevel = !self.selectedLevels.count || [self.selectedLevels containsObject:logItem.level];
        BOOL shouldPrintName = !self.selectedNames.count || [self.selectedNames containsObject:logItem.name];
        return shouldPrintLevel && shouldPrintName;
    }];
    if (_tableView) {
        [self updateToolbarButtonState];
        
        [self.tableView reloadData];
        [self.tableView qmui_performBatchUpdates:^{
        } completion:^(BOOL finished) {
            NSArray<QMUIConsoleLogItem *> *matchedItems = [self.showingLogItems qmui_filterWithBlock:^BOOL(QMUIConsoleLogItem * _Nonnull item) {
                return item.searchResults.count > 0;
            }];
            NSArray<NSArray<NSTextCheckingResult *> *> *matchedResults = [matchedItems qmui_mapWithBlock:^id _Nonnull(QMUIConsoleLogItem * _Nonnull item) {
                return item.searchResults;
            }];
            self.searchResultsTotalCount = 0;
            [matchedResults enumerateObjectsUsingBlock:^(NSArray<NSTextCheckingResult *> * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                self.searchResultsTotalCount += obj.count;
            }];
            
            BOOL shouldShowCountLabel = self.toolbar.searchTextField.text.length > 0;// 不管有没有结果，只要有搜索文本，就显示结果计数
            if (shouldShowCountLabel) {
                self.toolbar.searchTextField.rightViewMode = UITextFieldViewModeAlways;
                self.toolbar.searchResultPreviousButton.enabled = self.searchResultsTotalCount > 1;
                self.toolbar.searchResultNextButton.enabled = self.searchResultsTotalCount > 1;
            } else {
                self.toolbar.searchTextField.rightViewMode = UITextFieldViewModeNever;
            }
            if (self.searchResultsTotalCount == 0) {
                self.currentHighlightedResultIndex = -1;// < 0 时不会自动滚动，所以需要手动再滚到列表末尾
                if ([self.tableView numberOfRowsInSection:0] > 0) {
                    NSIndexPath *lastRow = [NSIndexPath indexPathForRow:[self.tableView numberOfRowsInSection:0] - 1 inSection:0];
                    [self.tableView scrollToRowAtIndexPath:lastRow atScrollPosition:UITableViewScrollPositionMiddle animated:YES];
                }
            } else {
                self.currentHighlightedResultIndex = 0;// >= 0 时内部会自动滚动
            }
        }];
    }
}

- (void)clear {
    [self.selectedLevels removeAllObjects];
    [self.selectedNames removeAllObjects];
    [self.logItems removeAllObjects];
    self.toolbar.levelButton.enabled = NO;
    self.toolbar.levelButton.selected = NO;
    self.toolbar.nameButton.enabled = NO;
    self.toolbar.nameButton.selected = NO;
    [self printLog];
}

#pragma mark - <QMUITableViewDataSource, QMUITableViewDelegate>

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.showingLogItems.count;
}

- (id<NSCopying>)qmui_tableView:(UITableView *)tableView cacheKeyForRowAtIndexPath:(NSIndexPath *)indexPath {
    return self.showingLogItems[indexPath.row].logString.string;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    QMUIConsoleLogItemCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
    QMUIConsoleLogItem *logItem = self.showingLogItems[indexPath.row];
    cell.textView.attributedText = logItem.displayString.copy;
    [cell updateCellAppearanceWithIndexPath:indexPath];
    return cell;
}

#pragma mark - Popover Button

- (void)handlePopoverTouchEvent:(QMUIButton *)button {
    [self.view setNeedsLayout];
    [self.view layoutIfNeeded];
    
    self.popoverAnimating = YES;
    CGAffineTransform scale = CGAffineTransformMakeScale(CGRectGetWidth(self.popoverButton.frame) / CGRectGetWidth(self.containerView.frame), CGRectGetHeight(self.popoverButton.frame) / CGRectGetHeight(self.containerView.frame));
    CGAffineTransform translation = CGAffineTransformMakeTranslation(self.popoverButton.center.x - self.containerView.center.x, self.popoverButton.center.y - self.containerView.center.y);
    CGAffineTransform transform = CGAffineTransformConcat(scale, translation);
    CGFloat cornerRadius = MIN(CGRectGetWidth(self.containerView.bounds), CGRectGetHeight(self.containerView.bounds));
    
    if (self.containerView.hidden) {
        self.popoverPanGesture.enabled = NO;
        self.popoverLongPressGesture.enabled = NO;
        [UIView animateWithDuration:.1 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
            self.popoverButton.alpha = 0;
        } completion:nil];
        
        self.containerView.alpha = 0;
        self.containerView.hidden = NO;
        self.containerView.layer.cornerRadius = cornerRadius / 2;
        self.containerView.transform = transform;
        [UIView animateWithDuration:0.4 delay:0 usingSpringWithDamping:0.69 initialSpringVelocity:5 options:UIViewAnimationOptionCurveEaseInOut animations:^{
            self.containerView.alpha = 1;
            self.containerView.transform = CGAffineTransformIdentity;
            self.containerView.layer.cornerRadius = 0;
        } completion:^(BOOL finished) {
            [self layoutPopoverButton];
            self.popoverButton.transform = CGAffineTransformMakeScale(0, 0);
            [UIView animateWithDuration:0.4 delay:0 usingSpringWithDamping:0.69 initialSpringVelocity:5 options:UIViewAnimationOptionCurveEaseInOut animations:^{
                self.popoverButton.alpha = .3;
                self.popoverButton.transform = CGAffineTransformIdentity;
            } completion:^(BOOL finished) {
                self.popoverAnimating = NO;
            }];
        }];
    } else {
        self.popoverPanGesture.enabled = YES;
        self.popoverLongPressGesture.enabled = YES;
        [UIView animateWithDuration:0.4 delay:0 usingSpringWithDamping:0.69 initialSpringVelocity:5 options:UIViewAnimationOptionCurveEaseInOut animations:^{
            self.popoverButton.alpha = 1;
            self.containerView.alpha = 0;
            self.containerView.transform = transform;
            self.containerView.layer.cornerRadius = cornerRadius / 2;
            [self.view endEditing:YES];
        } completion:^(BOOL finished) {
            self.containerView.hidden = YES;
            self.containerView.transform = CGAffineTransformIdentity;
            self.containerView.layer.cornerRadius = 0;
            
            [UIView animateWithDuration:0.4 delay:0 usingSpringWithDamping:0.69 initialSpringVelocity:5 options:UIViewAnimationOptionCurveEaseInOut animations:^{
                [self layoutPopoverButton];
                self.popoverButton.alpha = 1;
            } completion:^(BOOL finished) {
                self.popoverAnimating = NO;
            }];
        }];
    }
}

- (void)handlePopoverPanGestureRecognizer:(UIPanGestureRecognizer *)gesture {
    switch (gesture.state) {
        case UIGestureRecognizerStateBegan:
            self.popoverAnimating = YES;
            [self.popoverButton qmui_bindObject:[NSValue valueWithCGPoint:self.popoverButton.frame.origin] forKey:@"origin"];
            break;
        case UIGestureRecognizerStateChanged: {
            CGPoint translation = [gesture translationInView:self.view];
            self.popoverButton.transform = CGAffineTransformMakeTranslation(translation.x, translation.y);
        }
            break;
        case UIGestureRecognizerStateCancelled:
        case UIGestureRecognizerStateEnded:
        case UIGestureRecognizerStateFailed: {
            CGRect popoverButtonFrame = [self safetyPopoverButtonFrame:self.popoverButton.frame];
            BOOL animated = CGRectEqualToRect(popoverButtonFrame, self.popoverButton.frame);
            [UIView qmui_animateWithAnimated:animated duration:.25 delay:0 options:QMUIViewAnimationOptionsCurveOut animations:^{
                self.popoverButton.transform = CGAffineTransformIdentity;
                self.popoverButton.frame = popoverButtonFrame;
            } completion:^(BOOL finished) {
                [self.popoverButton qmui_bindObject:[NSValue valueWithCGPoint:popoverButtonFrame.origin] forKey:@"origin"];
                self.popoverAnimating = NO;
            }];
        }
            break;
        default:
            break;
    }
}

- (void)handlePopverLongPressGestureRecognizer:(UILongPressGestureRecognizer *)gesture {
    if (gesture.state == UIGestureRecognizerStateBegan) {
        CFTimeInterval duration = 0.5;
        CAKeyframeAnimation *scale = [CAKeyframeAnimation animationWithKeyPath:@"transform.scale"];
        scale.values = @[@1.0, @1.2, @0.2];
        scale.keyTimes = @[@0.0, @(.2 / duration), @1];
        scale.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn];
        scale.duration = duration;
        scale.fillMode = kCAFillModeForwards;
        scale.removedOnCompletion = NO;
        __weak __typeof(self)weakSelf = self;
        scale.qmui_animationDidStopBlock = ^(__kindof CAAnimation *aAnimation, BOOL finished) {
            [QMUIConsole hide];
            [weakSelf.popoverButton.layer removeAnimationForKey:@"scale"];
            [[[UIImpactFeedbackGenerator alloc] initWithStyle:UIImpactFeedbackStyleMedium] impactOccurred];
        };
        [self.popoverButton.layer addAnimation:scale forKey:@"scale"];
    }
}

#pragma mark - Toolbar Buttons

- (void)updateToolbarButtonState {
    self.toolbar.levelButton.enabled = self.logItems.count > 0;
    self.toolbar.nameButton.enabled = self.logItems.count > 0;
}

- (QMUIPopupMenuView *)generatePopupMenuView {
    QMUIPopupMenuView *menuView = [[QMUIPopupMenuView alloc] init];
    menuView.padding = UIEdgeInsetsMake(3, 6, 3, 6);
    menuView.cornerRadius = 3;
    menuView.arrowSize = CGSizeMake(8, 4);
    menuView.borderWidth = 0;
    menuView.itemHeight = 28;
    menuView.itemTitleFont = UIFontMake(12);
    menuView.itemTitleColor = UIColorMake(53, 60, 70);
    menuView.maskViewBackgroundColor = nil;
    menuView.backgroundColor = UIColorWhite;
    menuView.itemConfigurationHandler = ^(QMUIPopupMenuView *aMenuView, QMUIPopupMenuButtonItem *aItem, NSInteger section, NSInteger index) {
        aItem.highlightedBackgroundColor = [[UIColor blackColor] colorWithAlphaComponent:.15];
        QMUIButton *button = aItem.button;
        button.imagePosition = QMUIButtonImagePositionRight;
        button.spacingBetweenImageAndTitle = 10;
        UIImage *selectedImage = [UIImage qmui_imageWithShape:QMUIImageShapeCheckmark size:CGSizeMake(12, 9) lineWidth:1 tintColor:aMenuView.itemTitleColor];
        UIImage *normalImage = [UIImage qmui_imageWithColor:UIColorClear size:selectedImage.size cornerRadius:0];
        [button setImage:normalImage forState:UIControlStateNormal];// 无图像也弄一张空白图，以保证 state 变化时布局不跳动
        [button setImage:selectedImage forState:UIControlStateSelected];
        [button setImage:selectedImage forState:UIControlStateSelected|UIControlStateHighlighted];
    };
    menuView.hidden = YES;
    [self.view addSubview:menuView];
    return menuView;
}

- (NSArray<QMUIPopupMenuButtonItem *> *)popupMenuItemsByTitleBlock:(nullable NSString * (^)(QMUIConsoleLogItem *logItem))titleBlock selectedArray:(NSMutableArray<NSString *> *)selectedArray {
    __weak __typeof(self)weakSelf = self;
    NSMutableArray<QMUIPopupMenuButtonItem *> *items = [[NSMutableArray alloc] init];
    NSMutableSet<NSString *> *itemTitles = [[NSMutableSet alloc] init];
    [self.logItems enumerateObjectsUsingBlock:^(QMUIConsoleLogItem * _Nonnull logItem, NSUInteger idx, BOOL * _Nonnull stop) {
        [itemTitles addObject:titleBlock(logItem)];
    }];
    [[itemTitles sortedArrayUsingDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:NSStringFromSelector(@selector(description)) ascending:YES]]] enumerateObjectsUsingBlock:^(NSString * _Nonnull title, NSUInteger idx, BOOL * _Nonnull stop) {
        QMUIPopupMenuButtonItem *item = [QMUIPopupMenuButtonItem itemWithImage:nil title:title handler:^(QMUIPopupMenuButtonItem *aItem) {
            aItem.button.selected = !aItem.button.selected;
            if (aItem.button.selected) {
                [selectedArray addObject:title];
            } else {
                [selectedArray removeObject:title];
            }
            [weakSelf printLog];
        }];
        item.button.contentHorizontalAlignment = UIControlContentHorizontalAlignmentFill;
        item.button.selected = [selectedArray containsObject:title];
        [items addObject:item];
    }];
    return items.copy;
}

- (void)handleLevelButtonEvent:(UIButton *)button {
    self.levelMenu.items = [self popupMenuItemsByTitleBlock:^NSString *(QMUIConsoleLogItem *logItem) {
        return logItem.level;
    } selectedArray:self.selectedLevels];
    [self.levelMenu showWithAnimated:YES];
    button.selected = YES;
}

- (void)handleNameButtonEvent:(UIButton *)button {
    self.nameMenu.items = [self popupMenuItemsByTitleBlock:^NSString *(QMUIConsoleLogItem *logItem) {
        return logItem.name;
    } selectedArray:self.selectedNames];
    [self.nameMenu showWithAnimated:YES];
    button.selected = YES;
}

- (void)handleClearButtonEvent:(UIButton *)button {
    [self clear];
}

#pragma mark - Search

- (void)searchInLogItem:(QMUIConsoleLogItem *)logItem {
    NSString *searchingText = self.toolbar.searchTextField.text ?: @"";
    BOOL valueChanged = ![searchingText isEqualToString:logItem.searchingString ?: @""];// UITextField.text 不会为 nil，至少是 @""，为了保证 isEqualToString: 的正确性，这里对 searchingString 也做了 nil -> @"" 的转换
    if (!valueChanged) return;
    logItem.searchingString = searchingText;
    NSArray<NSTextCheckingResult *> *matches = [self.searchRegularExpression matchesInString:logItem.logString.string options:NSMatchingReportCompletion range:NSMakeRange(0, logItem.logString.string.length)];
    [logItem updateDisplayStringWithSearchResults:matches];
}

- (void)handleSearchTextFieldChanged:(QMUITextField *)searchTextField {
    
    if (self.levelMenu.isShowing) [self.levelMenu hideWithAnimated:YES];
    if (self.nameMenu.isShowing) [self.nameMenu hideWithAnimated:YES];
    
    self.searchRegularExpression = [NSRegularExpression regularExpressionWithPattern:searchTextField.text options:NSRegularExpressionCaseInsensitive error:nil];
    [self.logItems enumerateObjectsUsingBlock:^(QMUIConsoleLogItem * _Nonnull logItem, NSUInteger idx, BOOL * _Nonnull stop) {
        [self searchInLogItem:logItem];
    }];
    [self printLog];
}

- (void)handleSearchResultPreviousButtonEvent:(QMUIButton *)button {
    if (self.currentHighlightedResultIndex == 0) {
        self.currentHighlightedResultIndex = self.searchResultsTotalCount - 1;
    } else {
        self.currentHighlightedResultIndex --;
    }
}

- (void)handleSearchResultNextButtonEvent:(QMUIButton *)button {
    if (self.currentHighlightedResultIndex == self.searchResultsTotalCount - 1) {
        self.currentHighlightedResultIndex = 0;
    } else {
        self.currentHighlightedResultIndex ++;
    }
}

- (void)setCurrentHighlightedResultIndex:(NSInteger)currentHighlightedResultIndex {
    _currentHighlightedResultIndex = currentHighlightedResultIndex;
    [self.lastHighlightedItem updateDisplayStringWithSearchResults:self.lastHighlightedItem.searchResults];// clear focus
    self.toolbar.searchResultCountLabel.text = currentHighlightedResultIndex >= 0 ? [NSString stringWithFormat:@"%@/%@", @(currentHighlightedResultIndex + 1), @(self.searchResultsTotalCount)] : @"0";
    [self.toolbar setNeedsLayoutSearchResultViews];
    if (currentHighlightedResultIndex >= 0) {
        
        NSInteger row = NSNotFound;
        NSInteger indexInItem = NSNotFound;
        for (NSInteger i = 0, j = 0; i < self.showingLogItems.count; i++) {
            if (self.currentHighlightedResultIndex < j + self.showingLogItems[i].searchResults.count) {
                row = i;
                indexInItem = self.currentHighlightedResultIndex - j;
                break;
            }
            j += self.showingLogItems[i].searchResults.count;
        }
        if (row != NSNotFound) {
            [self.showingLogItems[row] focusSearchResultAtIndex:indexInItem];
            [self.tableView reloadData];
            self.lastHighlightedItem = self.showingLogItems[row];
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:row inSection:0];
            BOOL shouldScrollToVisible = ![self.tableView qmui_cellVisibleAtIndexPath:indexPath];
            if (!shouldScrollToVisible) {
                // 本来就可视的，可能 cell 比较高，只露出屏幕一半，高亮的那个地方没露出来，这种要手动计算
                CGRect rect = [self.tableView rectForRowAtIndexPath:indexPath];
                if (!CGRectContainsRect(self.tableView.bounds, rect)) {
                    shouldScrollToVisible = YES;
                }
            }
            if (shouldScrollToVisible) {
                [self.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionMiddle animated:YES];
            }
        }
    }
}

- (void)handleKeyboardWillChangeFrame:(QMUIKeyboardUserInfo *)userInfo {
    CGFloat height = [userInfo heightInView:self.view];
    self.containerView.transform = CGAffineTransformMakeTranslation(0, -height);
    dispatch_async(dispatch_get_main_queue(), ^{
        if (self.levelMenu.isShowing) [self.levelMenu updateLayout];
        if (self.nameMenu.isShowing) [self.nameMenu updateLayout];
    });
}

#pragma mark - <QMUITextFieldDelegate>

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    return YES;
}

@end
