/*****
 * Tencent is pleased to support the open source community by making QMUI_iOS available.
 * Copyright (C) 2016-2019 THL A29 Limited, a Tencent company. All rights reserved.
 * Licensed under the MIT License (the "License"); you may not use this file except in compliance with the License. You may obtain a copy of the License at
 * http://opensource.org/licenses/MIT
 * Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.
 *****/
//
//  QMUIConsoleViewController.m
//  QMUIKit
//
//  Created by MoLice on 2019/J/11.
//

#import "QMUIConsoleViewController.h"
#import "QMUICore.h"
#import "QMUITextView.h"
#import "QMUITextField.h"
#import "QMUIButton.h"
#import "UIScrollView+QMUI.h"
#import "UIViewController+QMUI.h"
#import "UIView+QMUI.h"
#import "UIImage+QMUI.h"
#import "NSObject+QMUI.h"
#import "CAAnimation+QMUI.h"
#import "QMUIConsole.h"
#import "QMUIPopupMenuView.h"

@interface QMUIConsoleLogItem : NSObject

@property(nullable, nonatomic, copy) NSString *level;
@property(nullable, nonatomic, copy) NSString *name;
@property(nonatomic, copy) NSAttributedString *timeString;
@property(nonatomic, copy) NSAttributedString *logString;
@end

@implementation QMUIConsoleLogItem

+ (instancetype)logItemWithLevel:(NSString *)level name:(NSString *)name timeString:(NSString *)timeString logString:(id)logString {
    QMUIConsoleLogItem *logItem = [[QMUIConsoleLogItem alloc] init];
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
    
    return logItem;
}

@end

@interface QMUIConsoleViewController ()<QMUITextFieldDelegate>

@property(nonatomic, strong) UIView *containerView;
@property(nonatomic, strong) QMUIPopupMenuView *levelMenu;
@property(nonatomic, strong) QMUIPopupMenuView *nameMenu;
@property(nonatomic, strong) NSMutableArray<QMUIConsoleLogItem *> *logItems;
@property(nonatomic, strong) NSMutableArray<NSString *> *selectedLevels;
@property(nonatomic, strong) NSMutableArray<NSString *> *selectedNames;
@property(nonatomic, copy) NSArray<NSTextCheckingResult *> *searchResults;
@property(nonatomic, assign) NSInteger currentHighlightedResultIndex;

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
    
    [self loadViewIfNeeded];
}

- (void)initSubviews {
    [super initSubviews];
    
    self.containerView = [[UIView alloc] init];
    self.containerView.backgroundColor = self.backgroundColor;
    self.containerView.hidden = YES;
    [self.view addSubview:self.containerView];
    
    _textView = [[QMUITextView alloc] init];
    self.textView.backgroundColor = [UIColor clearColor];
    self.textView.scrollsToTop = NO;
    self.textView.editable = NO;
    if (@available(iOS 11, *)) {
        self.textView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    }
    [self.containerView addSubview:self.textView];
    
    _toolbar = [[QMUIConsoleToolbar alloc] init];
    [self.toolbar.levelButton addTarget:self action:@selector(handleLevelButtonEvent:) forControlEvents:UIControlEventTouchUpInside];
    [self.toolbar.nameButton addTarget:self action:@selector(handleNameButtonEvent:) forControlEvents:UIControlEventTouchUpInside];
    [self.toolbar.clearButton addTarget:self action:@selector(handleClearButtonEvent:) forControlEvents:UIControlEventTouchUpInside];
    __weak __typeof(self)weakSelf = self;
    self.toolbar.searchTextField.qmui_keyboardWillChangeFrameNotificationBlock = ^(QMUIKeyboardUserInfo *keyboardUserInfo) {
        [weakSelf handleKeyboardWillChangeFrame:keyboardUserInfo];
    };
    self.toolbar.searchTextField.delegate = self;
    [self.toolbar.searchTextField addTarget:self action:@selector(handleSearchTextFieldChanged:) forControlEvents:UIControlEventEditingChanged];
    [self.toolbar.searchResultPreviousButton addTarget:self action:@selector(handleSearchResultPreviousButtonEvent:) forControlEvents:UIControlEventTouchUpInside];
    [self.toolbar.searchResultNextButton addTarget:self action:@selector(handleSearchResultNextButtonEvent:) forControlEvents:UIControlEventTouchUpInside];
    [self.containerView addSubview:self.toolbar];
    
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
    
    UIImage *popoverImage = [[QMUIHelper imageWithName:@"QMUI_console_logo"] qmui_imageResizedInLimitedSize:CGSizeMake(24, 24)];
    _popoverButton = [[QMUIButton alloc] qmui_initWithSize:CGSizeMake(32, 32)];
    [self.popoverButton setImage:popoverImage forState:UIControlStateNormal];
    self.popoverButton.adjustsButtonWhenHighlighted = NO;
    self.popoverButton.backgroundColor = [[QMUIConsole appearance].backgroundColor colorWithAlphaComponent:.5];
    self.popoverButton.layer.cornerRadius = CGRectGetHeight(self.popoverButton.bounds) / 2;
    self.popoverButton.clipsToBounds = YES;
    [self.popoverButton addTarget:self action:@selector(handlePopoverTouchEvent:) forControlEvents:UIControlEventTouchUpInside];
    self.popoverLongPressGesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handlePopverLongPressGestureRecognizer:)];
    [self.popoverButton addGestureRecognizer:self.popoverLongPressGesture];
    self.popoverPanGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePopoverPanGestureRecognizer:)];
    [self.popoverPanGesture requireGestureRecognizerToFail:self.popoverLongPressGesture];
    [self.popoverButton addGestureRecognizer:self.popoverPanGesture];
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
    
    self.textView.qmui_width = self.containerView.qmui_width;
    self.textView.qmui_height = self.toolbar.qmui_top;
    self.textView.contentInset = UIEdgeInsetsMake(self.textView.qmui_safeAreaInsets.top, self.textView.qmui_safeAreaInsets.left, self.textView.contentInset.bottom, self.textView.qmui_safeAreaInsets.right);
    self.textView.scrollIndicatorInsets = self.textView.contentInset;
    
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
    [self.logItems addObject:logItem];
    [self updateToolbarButtonState];
    [self printLog];
}

- (void)log:(id)logString {
    [self logWithLevel:nil name:nil logString:logString];
}

- (void)printLog {
    NSMutableAttributedString *string = [[NSMutableAttributedString alloc] init];
    [self.logItems enumerateObjectsUsingBlock:^(QMUIConsoleLogItem * _Nonnull logItem, NSUInteger idx, BOOL * _Nonnull stop) {
        BOOL shouldPrintLevel = !self.selectedLevels.count || [self.selectedLevels containsObject:logItem.level];
        BOOL shouldPrintName = !self.selectedNames.count || [self.selectedNames containsObject:logItem.name];
        if (shouldPrintLevel && shouldPrintName) {
            if (string.length > 0) {
                [string appendAttributedString:[[NSAttributedString alloc] initWithString:@"\n" attributes:[QMUIConsole appearance].textAttributes]];
            }
            
            [string appendAttributedString:logItem.timeString];
            [string appendAttributedString:logItem.logString];
        }
    }];
    self.textView.attributedText = string;
    if (self.toolbar.searchTextField.text.length > 0) {
        [self handleSearchTextFieldChanged:self.toolbar.searchTextField];
    } else {
        [self.textView qmui_scrollToBottomAnimated:YES];
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
    self.textView.attributedText = nil;
    self.searchResults = nil;
    [self handleSearchTextFieldChanged:self.toolbar.searchTextField];
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
            if (@available(iOS 10.0, *)) {
                [[[UIImpactFeedbackGenerator alloc] initWithStyle:UIImpactFeedbackStyleLight] impactOccurred];
            }
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

- (void)handleSearchTextFieldChanged:(QMUITextField *)searchTextField {
    
    if (self.levelMenu.isShowing) [self.levelMenu hideWithAnimated:YES];
    if (self.nameMenu.isShowing) [self.nameMenu hideWithAnimated:YES];
    
    NSError *error = nil;
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:searchTextField.text options:NSRegularExpressionCaseInsensitive error:&error];
    
    if (!error) {
        NSString *text = self.textView.text;
        self.searchResults = [regex matchesInString:text options:NSMatchingReportProgress range:NSMakeRange(0, text.length)];
        if (self.searchResults.count) {
            self.currentHighlightedResultIndex = 0;
            self.toolbar.searchResultPreviousButton.enabled = self.searchResults.count > 1;
            self.toolbar.searchResultNextButton.enabled = self.searchResults.count > 1;
            
            self.toolbar.searchResultCountLabel.text = [NSString stringWithFormat:@"%@个结果", @(self.searchResults.count)];
            [self.toolbar setNeedsLayoutSearchResultViews];
            self.toolbar.searchTextField.rightViewMode = UITextFieldViewModeAlways;
            [self updateSearchHighlighted];
            return;
        }
    }
    
    self.currentHighlightedResultIndex = -1;
    self.toolbar.searchTextField.rightViewMode = UITextFieldViewModeNever;
    [self updateSearchHighlighted];
}

- (void)handleSearchResultPreviousButtonEvent:(QMUIButton *)button {
    if (self.currentHighlightedResultIndex == 0) {
        self.currentHighlightedResultIndex = self.searchResults.count - 1;
    } else {
        self.currentHighlightedResultIndex --;
    }
    [self updateSearchHighlighted];
}

- (void)handleSearchResultNextButtonEvent:(QMUIButton *)button {
    if (self.currentHighlightedResultIndex == self.searchResults.count - 1) {
        self.currentHighlightedResultIndex = 0;
    } else {
        self.currentHighlightedResultIndex ++;
    }
    [self updateSearchHighlighted];
}

- (void)updateSearchHighlighted {
    NSMutableAttributedString *attributedText = self.textView.attributedText.mutableCopy;
    [attributedText addAttribute:NSBackgroundColorAttributeName value:[UIColor clearColor] range:NSMakeRange(0, attributedText.length)];
    if (self.currentHighlightedResultIndex >= 0) {
        [attributedText addAttribute:NSBackgroundColorAttributeName value:[QMUIConsole appearance].searchResultHighlightedBackgroundColor range:self.searchResults[self.currentHighlightedResultIndex].range];
    }
    
    self.textView.attributedText = attributedText;
    
    if (self.currentHighlightedResultIndex >= 0) {
        [self.textView scrollRangeToVisible:self.searchResults[self.currentHighlightedResultIndex].range];
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
